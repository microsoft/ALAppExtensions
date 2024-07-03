namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Comment;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;
using Microsoft.Inventory.Item.Attribute;
using Microsoft.Inventory.Item;

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

    /// <summary>
    /// Creates a draft order in shopify by constructing and sending a graphQL request.
    /// </summary>
    /// <param name="TempShpfyOrderHeader">Header information for a shopify order.</param>
    /// <param name="TempShpfyOrderLine">Line items for a shopify order.</param>
    /// <param name="ShpfyOrderTaxLines">Tax lines for a shopify order.</param>
    /// <returns>Unique id of the created draft order in shopify.</returns>
    internal procedure CreateDraftOrder(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    ): BigInteger
    var
        DraftOrderId: BigInteger;
        GraphQuery: TextBuilder;
    begin
        GraphQuery := CreateDraftOrderGQLRequest(TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);
        DraftOrderId := SendDraftOrderGraphQLRequest(GraphQuery);
        exit(DraftOrderId);
    end;

    /// <summary>
    /// Completes a draft order in shopify by converting it to an order.
    /// </summary>
    /// <param name="DraftOrderId">Draft order id that needs to be completed.</param>
    /// <returns>Json response of a created order in shopify.</returns>
    internal procedure CompleteDraftOrder(DraftOrderId: BigInteger): JsonToken
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        GraphQLType := "Shpfy GraphQL Type"::DraftOrderComplete;
        Parameters.Add('DraftOrderId', Format(DraftOrderId));
        JResponse := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        exit(JResponse);
    end;

    /// <summary>
    /// Sets a global shopify shop to be used for draft orders api functionality.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(ShopCode: Code[20])
    begin
        Clear(ShpfyShop);
        ShpfyShop.Get(ShopCode);
        ShpfyCommunicationMgt.SetShop(ShpfyShop);
    end;

    local procedure CreateDraftOrderGQLRequest(
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var TempShpfyOrderLine: Record "Shpfy Order Line" temporary;
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    ): TextBuilder
    var
        GraphQuery: TextBuilder;
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
        if TempShpfyOrderHeader."Currency Code" <> '' then begin
            GraphQuery.Append('presentmentCurrencyCode: ');
            GraphQuery.Append(Format(GetISOCode(TempShpfyOrderHeader."Currency Code")));
        end;
        if TempShpfyOrderHeader."Discount Amount" <> 0 then
            AddDiscountAmountToGraphQuery(GraphQuery, TempShpfyOrderHeader."Discount Amount", 'Invoice Discount Amount');

        GraphQuery.Append(', taxExempt: true');

        AddShippingAddressToGraphQuery(GraphQuery, TempShpfyOrderHeader);
        AddBillingAddressToGraphQuery(GraphQuery, TempShpfyOrderHeader);
        AddNote(GraphQuery, TempShpfyOrderHeader);
        if TempShpfyOrderHeader.Unpaid then
            AddPaymentTerms(GraphQuery, TempShpfyOrderHeader);

        AddLineItemsToGraphQuery(GraphQuery, TempShpfyOrderHeader, TempShpfyOrderLine, ShpfyOrderTaxLines);

        GraphQuery.Append('}) {draftOrder { legacyResourceId } userErrors {field, message}}');
        GraphQuery.Append('}"}');

        exit(GraphQuery);
    end;

    local procedure SendDraftOrderGraphQLRequest(GraphQuery: TextBuilder): BigInteger
    var
        DraftOrderId: BigInteger;
        JResponse: JsonToken;
    begin
        JResponse := ShpfyCommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        DraftOrderId := ShpfyJsonHelper.GetValueAsBigInteger(JResponse, 'data.draftOrderCreate.draftOrder.legacyResourceId');
        exit(DraftOrderId);
    end;

    local procedure AddShippingAddressToGraphQuery(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
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

    local procedure AddBillingAddressToGraphQuery(var GraphQuery: TextBuilder; var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary)
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
        var ShpfyOrderTaxLines: Dictionary of [Text, Decimal]
    )
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

                    AddItemAttributes(GraphQuery, TempShpfyOrderLine."Item No.");
                end;

                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(TempShpfyOrderLine.Quantity, 0, 9));

                GraphQuery.Append(', originalUnitPrice :');
                GraphQuery.Append(Format(TempShpfyOrderLine."Unit Price", 0, 9));

                GraphQuery.Append('},');
            until TempShpfyOrderLine.Next() = 0;

            foreach TaxTitle in ShpfyOrderTaxLines.Keys() do begin
                GraphQuery.Append('{');
                GraphQuery.Append('title: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(TaxTitle));
                GraphQuery.Append('\"');

                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(1, 0, 9));

                GraphQuery.Append(', originalUnitPrice: ');
                GraphQuery.Append(Format(ShpfyOrderTaxLines.Get(TaxTitle), 0, 9));

                GraphQuery.Append('},');
            end;
            GraphQuery.Remove(GraphQuery.Length(), 1);
        end;
        GraphQuery.Append(']');
    end;

    local procedure AddDiscountAmountToGraphQuery(var GraphQuery: TextBuilder; DiscountAmount: Decimal; DiscountTitle: Text)
    begin
        GraphQuery.Append(', appliedDiscount: {');
        GraphQuery.Append('description: \"');
        GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(DiscountTitle));
        GraphQuery.Append('\"');

        GraphQuery.Append(', value: ');
        GraphQuery.Append(Format(DiscountAmount, 0, 9));

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
        ShpfyPaymentTerms: Record "Shpfy Payment Terms";
        DueAtDateTime: DateTime;
        IssuedAtDateTime: DateTime;
    begin
        if not ShopifyPaymentTermsExists(ShpfyPaymentTerms, TempShpfyOrderHeader, SalesInvoiceHeader) then
            exit;

        GraphQuery.Append(', paymentTerms: {');
        GraphQuery.Append('paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/');
        GraphQuery.Append(Format(ShpfyPaymentTerms.Id));
        GraphQuery.Append('\"');

        Evaluate(IssuedAtDateTime, Format(SalesInvoiceHeader."Document Date"));
        Evaluate(DueAtDateTime, Format(SalesInvoiceHeader."Due Date"));

        GraphQuery.Append(', paymentSchedules: {');
        if ShpfyPaymentTerms.Type = 'FIXED' then begin
            GraphQuery.Append('dueAt: \"');
            GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(DueAtDateTime, 0, 9)));
            GraphQuery.Append('\"');
        end else
            if ShpfyPaymentTerms.Type = 'NET' then begin
                GraphQuery.Append(', issuedAt: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(IssuedAtDateTime, 0, 9)));
                GraphQuery.Append('\"');
            end;

        GraphQuery.Append('}}');
    end;

    local procedure ShopifyPaymentTermsExists(
        var ShpfyPaymentTerms: Record "Shpfy Payment Terms";
        var TempShpfyOrderHeader: Record "Shpfy Order Header" temporary;
        var SalesInvoiceHeader: Record "Sales Invoice Header"
    ): Boolean
    begin
        SalesInvoiceHeader.Get(TempShpfyOrderHeader."Sales Invoice No.");
        ShpfyPaymentTerms.SetRange("Payment Terms Code", SalesInvoiceHeader."Payment Terms Code");
        ShpfyPaymentTerms.SetRange("Shop Code", ShpfyShop.Code);

        if not ShpfyPaymentTerms.FindFirst() then begin
            ShpfyPaymentTerms.SetRange("Payment Terms Code");
            ShpfyPaymentTerms.SetRange("Is Primary", true);

            if not ShpfyPaymentTerms.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure GetISOCode(CurrencyCode: Code[10]): Code[3]
    var
        Currency: Record Currency;
    begin
        Currency.Get(CurrencyCode);
        exit(Currency."ISO Code");
    end;

    local procedure AddItemAttributes(var GraphQuery: TextBuilder; ItemNo: Code[20])
    var
        Item: Record Item;
        ItemAttribute: Record "Item Attribute";
        ItemAttributeValue: Record "Item Attribute Value";
        ItemAttributeValueMapping: Record "Item Attribute Value Mapping";
    begin
        Item.Get(ItemNo);
        ItemAttributeValueMapping.SetRange("Table ID", Database::Item);
        ItemAttributeValueMapping.SetRange("No.", ItemNo);
        if ItemAttributeValueMapping.FindSet() then begin
            GraphQuery.Append(', customAttributes: [');
            repeat
                ItemAttribute.Get(ItemAttributeValueMapping."Item Attribute ID");
                ItemAttributeValue.Get(ItemAttribute.ID, ItemAttributeValueMapping."Item Attribute Value ID");

                GraphQuery.Append('{');
                GraphQuery.Append('key: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(ItemAttribute.Name)));
                GraphQuery.Append('\"');

                GraphQuery.Append(', value: \"');
                GraphQuery.Append(ShpfyCommunicationMgt.EscapeGrapQLData(Format(ItemAttributeValue.Value)));
                GraphQuery.Append('\"');
                GraphQuery.Append('},')
            until ItemAttributeValueMapping.Next() = 0;
            GraphQuery.Append(']');
        end;

    end;
}