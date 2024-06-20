namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Comment;
using Microsoft.Sales.History;

/// <summary>
/// Codeunit Draft Orders API (ID 30159).
/// </summary>
codeunit 30159 "Shpfy Draft Orders API"
{
    Access = Internal;

    var
        ShpfyShop: Record "Shpfy Shop";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";

    internal procedure ExportOrderToShopify(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    ) ResponseJsonToken: JsonToken
    var
        ShpfyBackgroundSyncs: Codeunit "Shpfy Background Syncs";
        DraftOrderId: BigInteger;
        NumberOfLines: Integer;
        GraphQuery: TextBuilder;
    begin
        CreateDraftOrderGraphQL(TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines, GraphQuery, NumberOfLines);
        DraftOrderId := SendDraftOrderGraphQLRequest(GraphQuery);
        ResponseJsonToken := CompleteDraftOrder(DraftOrderId, NumberOfLines);
        FulfillShopifyOrder(ResponseJsonToken);
        ShpfyBackgroundSyncs.InventorySync(ShpfyShop.Code);
    end;

    local procedure CreateDraftOrderGraphQL(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal];
        var GraphQuery: TextBuilder;
        var NumberOfLines: Integer
    )
    begin
        GraphQuery.Append('{"query":"mutation {draftOrderCreate(input: {');
        if TempShpfyOrderHeader.Email <> '' then begin
            GraphQuery.Append('email: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader.Email));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Phone No." <> '' then begin
            GraphQuery.Append('phone: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Phone No."));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Discount Amount" <> 0 then
            AddDiscountAmountToGraphQuery(GraphQuery, TempShpfyOrderHeader."Discount Amount", 'Invoice Discount Amount');

        GraphQuery.Append(', taxExempt: true');

        AddShippingAddressTOGraphQuery(GraphQuery, TempShpfyOrderHeader);
        AddBillingAddressTOGraphQuery(GraphQuery, TempShpfyOrderHeader);
        AddLineItemsToGraphQuery(GraphQuery, TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines, NumberOfLines);
        AddNote(GraphQuery, TempShpfyOrderHeader);
        if TempShpfyOrderHeader.Unpaid then
            AddPaymentTerms(GraphQuery, TempShpfyOrderHeader);

        GraphQuery.Append('}) {draftOrder {id } userErrors {field, message}}');
        GraphQuery.Append('}"}');
    end;

    local procedure SendDraftOrderGraphQLRequest(GraphQuery: TextBuilder): BigInteger
    var
        ShpfyPaymentTermAPI: Codeunit "Shpfy Payment Terms API";
        ResponseJsonToken: JsonToken;
    begin
        ResponseJsonToken := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        exit(ParseShopifyResponse(ResponseJsonToken, 'data.draftOrderCreate.draftOrder.id'));
    end;

    local procedure CompleteDraftOrder(DraftOrderId: BigInteger; NumberOfLines: Integer): JsonToken
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        GraphQLType := "Shpfy GraphQL Type"::DraftOrderComplete;
        Parameters.Add('DraftOrderId', Format(DraftOrderId));
        Parameters.Add('NumberOfOrders', Format(NumberOfLines));
        exit(ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters));
    end;

    local procedure FulfillShopifyOrder(ResponseJsonToken: JsonToken)
    var
        FulfillmentOrderList: List of [Text];
        FulfillmentOrderId: Text;
        ResponseToken: JsonToken;
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
    begin
        FulfillmentOrderList := ParseFulfillmentOrders(ResponseJsonToken);

        GraphQLType := "Shpfy GraphQL Type"::FulfillOrder;

        foreach FulfillmentOrderId in FulfillmentOrderList do begin
            Parameters.Add('FulfillmentOrderId', FulfillmentOrderId);
            ResponseToken := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            Clear(Parameters);
        end;
    end;

    local procedure ParseFulfillmentOrders(ResponseJsonToken: JsonToken) FulfillmentOrderList: List of [Text]
    var

        Counter: Integer;
        FulfillmentOrderArray: JsonArray;
        FulfillmentObject: JsonObject;
        FulfillmentOrderToken: JsonToken;
        JToken: JsonToken;
    begin
        FulfillmentObject := ResponseJsonToken.AsObject();
        FulfillmentObject.SelectToken('data.draftOrderComplete.draftOrder.order.fulfillmentOrders.nodes', JToken);
        FulfillmentOrderArray := ShpfyJsonHelper.GetJsonArray(JToken, '');

        for Counter := 0 to FulfillmentOrderArray.Count() - 1 do begin
            FulfillmentOrderArray.Get(Counter, FulfillmentOrderToken);
            FulfillmentOrderList.Add(Format(ParseShopifyResponse(FulfillmentOrderToken, 'id')));
        end;
    end;

    internal procedure ParseShopifyResponse(JsonTokenResponse: JsonToken; TokenPath: Text): BigInteger
    var
        ShopifyParsedResponse: BigInteger;
        ShopifyParsedText: Text;
    begin
        ShopifyParsedText := ShpfyJsonHelper.GetValueAsText(JsonTokenResponse, TokenPath);
        ShopifyParsedText := CopyStr(ShopifyParsedText, ShopifyParsedText.LastIndexOf('/') + 1, StrLen(ShopifyParsedText));
        Evaluate(ShopifyParsedResponse, ShopifyParsedText);
        exit(ShopifyParsedResponse);
    end;

    local procedure AddShippingAddressTOGraphQuery(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
    var
        myInt: Integer;
    begin
        GraphQuery.Append(', shippingAddress: {');
        if TempShpfyOrderHeader."Ship-to Address" <> '' then begin
            GraphQuery.Append('address1: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to Address"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Ship-to Address 2" <> '' then begin
            GraphQuery.Append(', address2: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to Address 2"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Ship-to City" <> '' then begin
            GraphQuery.Append(', city: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to City"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Ship-to Country/Region Code" <> '' then begin
            GraphQuery.Append(', countryCode: ');
            GraphQuery.Append(TempShpfyOrderHeader."Ship-to Country/Region Code");
        end;
        if TempShpfyOrderHeader."Ship-to Post Code" <> '' then begin
            GraphQuery.Append(', zip: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to Post Code"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Ship-to Name" <> '' then begin
            GraphQuery.Append(', firstName: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to Name"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Ship-to Name 2" <> '' then begin
            GraphQuery.Append(', lastName: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Ship-to Name 2"));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append('}');
    end;

    local procedure AddBillingAddressTOGraphQuery(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
    begin
        GraphQuery.Append(', billingAddress: {');
        if TempShpfyOrderHeader."Bill-to Address" <> '' then begin
            GraphQuery.Append('address1: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to Address"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Bill-to Address 2" <> '' then begin
            GraphQuery.Append(', address2: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to Address 2"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Bill-to City" <> '' then begin
            GraphQuery.Append(', city: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to City"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Bill-to Country/Region Code" <> '' then begin
            GraphQuery.Append(', countryCode: ');
            GraphQuery.Append(TempShpfyOrderHeader."Bill-to Country/Region Code");
        end;
        if TempShpfyOrderHeader."Bill-to Post Code" <> '' then begin
            GraphQuery.Append(', zip: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to Post Code"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Bill-to Name" <> '' then begin
            GraphQuery.Append(', firstName: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to Name"));
            GraphQuery.Append('\"');
        end;
        if TempShpfyOrderHeader."Bill-to Name 2" <> '' then begin
            GraphQuery.Append(', lastName: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderHeader."Bill-to Name 2"));
            GraphQuery.Append('\"');
        end;
        GraphQuery.Append('}');
    end;

    local procedure AddLineItemsToGraphQuery(
        var GraphQuery: TextBuilder;
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal];
        var NumberOfLines: Integer)
    var
        TaxTitle: Text;
    begin
        TempShpfyOrderLine.SetRange("Shopify Order Id", TempShpfyOrderHeader."Shopify Order Id");
        if TempShpfyOrderLine.FindSet(false) then begin
            GraphQuery.Append(', lineItems: [');
            repeat
                GraphQuery.Append('{');
                GraphQuery.Append('title: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TempShpfyOrderLine.Description));
                GraphQuery.Append('\"');

                if TempShpfyOrderLine."Shopify Variant Id" <> 0 then begin
                    GraphQuery.Append(', variantId: \"gid://shopify/ProductVariant/');
                    GraphQuery.Append(Format(TempShpfyOrderLine."Shopify Variant Id"));
                    GraphQuery.Append('\"');
                end;

                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(TempShpfyOrderLine.Quantity, 0, 9));

                GraphQuery.Append(', originalUnitPrice :');
                GraphQuery.Append(Format(TempShpfyOrderLine."Unit Price", 0, 9));

                // if TempShpfyOrderLine."Discount Amount" <> 0 then
                //     AddDiscountAmountToGraphQuery(GraphQuery, TempShpfyOrderLine."Discount Amount", 'Line Discount Amount');

                GraphQuery.Append('},');

                NumberOfLines += 1;
            until TempShpfyOrderLine.Next() = 0;

            foreach TaxTitle in ShpfyOrderTaxLines.Keys() do begin
                GraphQuery.Append('{');
                GraphQuery.Append('title: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TaxTitle));
                GraphQuery.Append('\"');

                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(1, 0, 9));

                GraphQuery.Append(', originalUnitPrice: ');
                //GraphQuery.Append(Format(ShpfyOrderTaxLines.Get(TaxTitle))); //TODO: If the invoice discount amount is filled, not sure how to add that if the vat calculation types are different
                GraphQuery.Append(Format(TempShpfyOrderHeader."VAT Amount"));

                GraphQuery.Append('},');
                NumberOfLines += 1;
            end;
            GraphQuery.Remove(GraphQuery.Length(), 1);
        end;
        GraphQuery.Append(']');
    end;

    local procedure AddDiscountAmountToGraphQuery(var GraphQuery: TextBuilder; DiscountAmount: Decimal; DiscountTitle: Text)
    var
        myInt: Integer;
    begin
        GraphQuery.Append(', appliedDiscount: {');
        GraphQuery.Append('description: \"');
        GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(DiscountTitle));
        GraphQuery.Append('\"');

        GraphQuery.Append(', value: ');
        GraphQuery.Append(Format(DiscountAmount));

        GraphQuery.Append(', valueType: ');
        GraphQuery.Append('FIXED_AMOUNT');

        GraphQuery.Append(', title: \"');
        GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(DiscountTitle));
        GraphQuery.Append('\"');

        GraphQuery.Append('}');
    end;

    local procedure AddNote(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
    var
        SalesCommentLine: Record "Sales Comment Line";
        NotesTextBuilder: TextBuilder;
    begin
        SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Invoice");
        SalesCommentLine.SetRange("No.", TempShpfyOrderHeader."Sales Invoice No.");

        if SalesCommentLine.FindSet() then begin
            GraphQuery.Append(', note: \"');
            repeat
                NotesTextBuilder.Append(SalesCommentLine.Comment + '\n');
            until SalesCommentLine.Next() = 0;
            GraphQuery.Append(NotesTextBuilder.ToText());
            GraphQuery.Append('\"');
        end;
    end;

    local procedure AddPaymentTerms(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ShpfyPaymentTerm: Record "Shpfy Payment Terms";
        DueAtDateTime: DateTime;
        IssuedAtDateTime: DateTime;
    begin
        if not ShopifyPaymentTermsExists(ShpfyPaymentTerm, TempShpfyOrderHeader, SalesInvoiceHeader) then
            exit;

        GraphQuery.Append(', paymentTerms: {');
        GraphQuery.Append('paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/');
        GraphQuery.Append(Format(ShpfyPaymentTerm."Id"));
        GraphQuery.Append('\"');

        Evaluate(IssuedAtDateTime, Format(SalesInvoiceHeader."Document Date"));
        Evaluate(DueAtDateTime, Format(SalesInvoiceHeader."Due Date"));

        GraphQuery.Append(', paymentSchedules: {');
        if ShpfyPaymentTerm.Type = 'FIXED' then begin //TODO: Maybe an Enum?
            GraphQuery.Append('dueAt: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(DueAtDateTime, 0, 9)));
            GraphQuery.Append('\"');
        end else
            if ShpfyPaymentTerm.Type = 'NET' then begin //TODO: Maybe an Enum?
                GraphQuery.Append(', issuedAt: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(IssuedAtDateTime, 0, 9)));
                GraphQuery.Append('\"');
            end;

        GraphQuery.Append('}}');
    end;

    local procedure ShopifyPaymentTermsExists(
        var ShpfyPaymentTerm: Record "Shpfy Payment Terms";
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var SalesInvoiceHeader: Record "Sales Invoice Header"
    ): Boolean
    begin
        SalesInvoiceHeader.Get(TempShpfyOrderHeader."Sales Invoice No.");
        ShpfyPaymentTerm.SetRange("Payment Terms Code", SalesInvoiceHeader."Payment Terms Code");
        ShpfyPaymentTerm.SetRange("Shop Code", ShpfyShop.Code);

        if not ShpfyPaymentTerm.FindFirst() then begin
            ShpfyPaymentTerm.SetRange("Payment Terms Code");
            ShpfyPaymentTerm.SetRange("Is Primary", true);

            if not ShpfyPaymentTerm.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    internal procedure SetShop(ShopCode: Code[20])
    begin
        Clear(ShpfyShop);
        ShpfyShop.Get(ShopCode);
        ShpfyCommunicationMgt.SetShop(ShpfyShop);
    end;
}