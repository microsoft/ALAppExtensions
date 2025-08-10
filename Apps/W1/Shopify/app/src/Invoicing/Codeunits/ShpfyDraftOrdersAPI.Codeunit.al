// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.Comment;
using Microsoft.Sales.History;
using Microsoft.Finance.Currency;

/// <summary>
/// Codeunit Draft Orders API (ID 30159).
/// </summary>
codeunit 30159 "Shpfy Draft Orders API"
{
    Access = Internal;

    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary>
    /// Creates a draft order in Shopify by constructing and sending a graphQL request.
    /// </summary>
    /// <param name="TempOrderHeader">Header information for a Shopify order.</param>
    /// <param name="TempOrderLine">Line items for a Shopify order.</param>
    /// <param name="OrderTaxLines">Tax lines for a Shopify order.</param>
    /// <returns>Unique id of the created draft order in Shopify.</returns>
    internal procedure CreateDraftOrder(
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        var TempOrderLine: Record "Shpfy Order Line" temporary;
        var OrderTaxLines: Dictionary of [Text, Decimal]
    ): BigInteger
    var
        DraftOrderId: BigInteger;
        GraphQuery: TextBuilder;
    begin
        GraphQuery := CreateDraftOrderGQLRequest(TempOrderHeader, TempOrderLine, OrderTaxLines);
        DraftOrderId := SendDraftOrderGraphQLRequest(GraphQuery);
        exit(DraftOrderId);
    end;

    /// <summary>
    /// Completes a draft order in Shopify by converting it to an order.
    /// </summary>
    /// <param name="DraftOrderId">Draft order id that needs to be completed.</param>
    /// <returns>Json response of a created order in Shopify.</returns>
    internal procedure CompleteDraftOrder(DraftOrderId: BigInteger): JsonToken
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        Parameters: Dictionary of [Text, Text];
        JResponse: JsonToken;
    begin
        GraphQLType := "Shpfy GraphQL Type"::DraftOrderComplete;
        Parameters.Add('DraftOrderId', Format(DraftOrderId));
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
        exit(JResponse);
    end;

    /// <summary>
    /// Sets a global Shopify shop to be used for draft orders api functionality.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(ShopCode: Code[20])
    begin
        Clear(Shop);
        Shop.Get(ShopCode);
        CommunicationMgt.SetShop(Shop);
    end;

    local procedure CreateDraftOrderGQLRequest(
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        var TempOrderLine: Record "Shpfy Order Line" temporary;
        var OrderTaxLines: Dictionary of [Text, Decimal]
    ): TextBuilder
    var
        GraphQuery: TextBuilder;
    begin
        GraphQuery.Append('{"query":"mutation {draftOrderCreate(input: {');
        if TempOrderHeader.Email <> '' then
            AddFieldToGraphQuery(GraphQuery, 'email', TempOrderHeader.Email, true);
        if TempOrderHeader."Phone No." <> '' then
            AddFieldToGraphQuery(GraphQuery, 'phone', TempOrderHeader."Phone No.", true);
        if TempOrderHeader."Currency Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'presentmentCurrencyCode', GetISOCode(TempOrderHeader."Currency Code"), false);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        if TempOrderHeader."Discount Amount" <> 0 then
            AddDiscountAmountToGraphQuery(GraphQuery, TempOrderHeader."Discount Amount", 'Invoice Discount Amount');

        GraphQuery.Append(', taxExempt: true');

        AddShippingAddressToGraphQuery(GraphQuery, TempOrderHeader);
        AddBillingAddressToGraphQuery(GraphQuery, TempOrderHeader);
        AddNote(GraphQuery, TempOrderHeader);
        if TempOrderHeader.Unpaid then
            AddPaymentTerms(GraphQuery, TempOrderHeader);

        AddLineItemsToGraphQuery(GraphQuery, TempOrderHeader, TempOrderLine, OrderTaxLines);

        GraphQuery.Append('}) {draftOrder { legacyResourceId } userErrors {field, message}}');
        GraphQuery.Append('}"}');

        exit(GraphQuery);
    end;

    local procedure SendDraftOrderGraphQLRequest(GraphQuery: TextBuilder): BigInteger
    var
        DraftOrderId: BigInteger;
        JResponse: JsonToken;
    begin
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQuery.ToText());
        DraftOrderId := JsonHelper.GetValueAsBigInteger(JResponse, 'data.draftOrderCreate.draftOrder.legacyResourceId');
        exit(DraftOrderId);
    end;

    local procedure AddShippingAddressToGraphQuery(var GraphQuery: TextBuilder; var TempOrderHeader: Record "Shpfy Order Header" temporary)
    begin
        GraphQuery.Append(', shippingAddress: {');
        if TempOrderHeader."Ship-to Address" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address1', TempOrderHeader."Ship-to Address", true);
        if TempOrderHeader."Ship-to Address 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address2', TempOrderHeader."Ship-to Address 2", true);
        if TempOrderHeader."Ship-to City" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'city', TempOrderHeader."Ship-to City", true);
        if TempOrderHeader."Ship-to Country/Region Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'countryCode', TempOrderHeader."Ship-to Country/Region Code", false);
        if TempOrderHeader."Ship-to Post Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zip', TempOrderHeader."Ship-to Post Code", true);
        if TempOrderHeader."Ship-to Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', TempOrderHeader."Ship-to Name", true);
        if TempOrderHeader."Ship-to Name 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', TempOrderHeader."Ship-to Name 2", true);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        GraphQuery.Append('}');
    end;

    local procedure AddBillingAddressToGraphQuery(var GraphQuery: TextBuilder; var TempOrderHeader: Record "Shpfy Order Header" temporary)
    begin
        GraphQuery.Append(', billingAddress: {');
        if TempOrderHeader."Bill-to Address" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address1', TempOrderHeader."Bill-to Address", true);
        if TempOrderHeader."Bill-to Address 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'address2', TempOrderHeader."Bill-to Address 2", true);
        if TempOrderHeader."Bill-to City" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'city', TempOrderHeader."Bill-to City", true);
        if TempOrderHeader."Bill-to Country/Region Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'countryCode', TempOrderHeader."Bill-to Country/Region Code", false);
        if TempOrderHeader."Bill-to Post Code" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'zip', TempOrderHeader."Bill-to Post Code", true);
        if TempOrderHeader."Bill-to Name" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'firstName', TempOrderHeader."Bill-to Name", true);
        if TempOrderHeader."Bill-to Name 2" <> '' then
            AddFieldToGraphQuery(GraphQuery, 'lastName', TempOrderHeader."Bill-to Name 2", true);
        GraphQuery.Remove(GraphQuery.Length - 1, 2);
        GraphQuery.Append('}');
    end;

    local procedure AddLineItemsToGraphQuery(
        var GraphQuery: TextBuilder;
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        var TempOrderLine: Record "Shpfy Order Line" temporary;
        var OrderTaxLines: Dictionary of [Text, Decimal]
    )
    var
        TaxTitle: Text;
    begin
        TempOrderLine.SetRange("Shopify Order Id", TempOrderHeader."Shopify Order Id");
        if TempOrderLine.FindSet(false) then begin
            GraphQuery.Append(', lineItems: [');
            repeat
                GraphQuery.Append('{');
                GraphQuery.Append('title: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(TempOrderLine.Description));
                GraphQuery.Append('\"');
                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(TempOrderLine.Quantity, 0, 9));
                GraphQuery.Append(', originalUnitPriceWithCurrency: {amount: ');
                GraphQuery.Append(Format(TempOrderLine."Unit Price", 0, 9));
                GraphQuery.Append(', currencyCode: ');
                GraphQuery.Append(GetISOCode(TempOrderHeader."Currency Code"));
                GraphQuery.Append('}, weight: {value: ');
                GraphQuery.Append(Format(TempOrderLine.Weight, 0, 9));
                GraphQuery.Append(', unit: ');
                if Shop."Weight Unit" = Shop."Weight Unit"::" " then begin
                    Shop."Weight Unit" := Shop.GetShopWeightUnit();
                    Shop.Modify();
                end;
                GraphQuery.Append(Shop."Weight Unit".Names.Get(Shop."Weight Unit".Ordinals.IndexOf(Shop."Weight Unit".AsInteger())).Trim().ToUpper().Replace(' ', '_'));
                GraphQuery.Append('}},');
            until TempOrderLine.Next() = 0;

            foreach TaxTitle in OrderTaxLines.Keys() do begin
                GraphQuery.Append('{');
                GraphQuery.Append('title: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(TaxTitle));
                GraphQuery.Append('\"');
                GraphQuery.Append(', quantity: ');
                GraphQuery.Append(Format(1, 0, 9));
                GraphQuery.Append(', originalUnitPriceWithCurrency: {amount: ');
                GraphQuery.Append(Format(OrderTaxLines.Get(TaxTitle), 0, 9));
                GraphQuery.Append(', currencyCode: ');
                GraphQuery.Append(GetISOCode(TempOrderHeader."Currency Code"));
                GraphQuery.Append('}},');
            end;
            GraphQuery.Remove(GraphQuery.Length(), 1);
        end;
        GraphQuery.Append(']');
    end;

    local procedure AddDiscountAmountToGraphQuery(var GraphQuery: TextBuilder; DiscountAmount: Decimal; DiscountTitle: Text)
    begin
        GraphQuery.Append(', appliedDiscount: {');
        GraphQuery.Append('description: \"');
        GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(DiscountTitle));
        GraphQuery.Append('\"');

        GraphQuery.Append(', value: ');
        GraphQuery.Append(Format(DiscountAmount, 0, 9));

        GraphQuery.Append(', valueType: ');
        GraphQuery.Append('FIXED_AMOUNT');

        GraphQuery.Append(', title: \"');
        GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(DiscountTitle));
        GraphQuery.Append('\"');

        GraphQuery.Append('}');
    end;

    local procedure AddNote(var GraphQuery: TextBuilder; var TempOrderHeader: Record "Shpfy Order Header" temporary)
    var
        SalesCommentLine: Record "Sales Comment Line";
        NotesTextBuilder: TextBuilder;
    begin
        SalesCommentLine.SetRange("Document Type", SalesCommentLine."Document Type"::"Posted Invoice");
        SalesCommentLine.SetRange("No.", TempOrderHeader."Sales Invoice No.");

        if SalesCommentLine.FindSet() then begin
            GraphQuery.Append(', note: \"');
            repeat
                NotesTextBuilder.Append(SalesCommentLine.Comment + '\n');
            until SalesCommentLine.Next() = 0;
            GraphQuery.Append(NotesTextBuilder.ToText());
            GraphQuery.Append('\"');
        end;
    end;

    local procedure AddPaymentTerms(var GraphQuery: TextBuilder; var TempOrderHeader: Record "Shpfy Order Header" temporary)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
        DueAtDateTime: DateTime;
        IssuedAtDateTime: DateTime;
    begin
        if not ShopifyPaymentTermsExists(ShopifyPaymentTerms, TempOrderHeader, SalesInvoiceHeader) then
            exit;

        GraphQuery.Append(', paymentTerms: {');
        GraphQuery.Append('paymentTermsTemplateId: \"gid://shopify/PaymentTermsTemplate/');
        GraphQuery.Append(Format(ShopifyPaymentTerms.Id));
        GraphQuery.Append('\"');

        Evaluate(IssuedAtDateTime, Format(SalesInvoiceHeader."Document Date"));
        Evaluate(DueAtDateTime, Format(SalesInvoiceHeader."Due Date"));

        GraphQuery.Append(', paymentSchedules: {');
        if ShopifyPaymentTerms.Type = 'FIXED' then begin
            GraphQuery.Append('dueAt: \"');
            GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(Format(DueAtDateTime, 0, 9)));
            GraphQuery.Append('\"');
        end else
            if ShopifyPaymentTerms.Type = 'NET' then begin
                GraphQuery.Append(', issuedAt: \"');
                GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(Format(IssuedAtDateTime, 0, 9)));
                GraphQuery.Append('\"');
            end;

        GraphQuery.Append('}}');
    end;

    local procedure ShopifyPaymentTermsExists(
        var ShopifyPaymentTerms: Record "Shpfy Payment Terms";
        var TempOrderHeader: Record "Shpfy Order Header" temporary;
        var SalesInvoiceHeader: Record "Sales Invoice Header"
    ): Boolean
    begin
        SalesInvoiceHeader.Get(TempOrderHeader."Sales Invoice No.");
        ShopifyPaymentTerms.SetRange("Payment Terms Code", SalesInvoiceHeader."Payment Terms Code");
        ShopifyPaymentTerms.SetRange("Shop Code", Shop.Code);

        if not ShopifyPaymentTerms.FindFirst() then begin
            ShopifyPaymentTerms.SetRange("Payment Terms Code");
            ShopifyPaymentTerms.SetRange("Is Primary", true);

            if not ShopifyPaymentTerms.FindFirst() then
                exit(false);
        end;

        exit(true);
    end;

    local procedure GetISOCode(CurrencyCode: Code[10]): Code[3]
    var
        Currency: Record Currency;
    begin
        if Currency.Get(CurrencyCode) then
            if Currency."ISO Code" <> '' then
                exit(Currency."ISO Code");

        exit(CopyStr(CurrencyCode, 1, 3)); // If it is not found in the currency table then it is LCY
    end;

    local procedure AddFieldToGraphQuery(var GraphQuery: TextBuilder; FieldName: Text; ValueAsVariant: Variant; ValueAsString: Boolean): Boolean
    begin
        GraphQuery.Append(FieldName);
        if ValueAsString then
            GraphQuery.Append(': \"')
        else
            GraphQuery.Append(': ');
        GraphQuery.Append(CommunicationMgt.EscapeGraphQLData(Format(ValueAsVariant)));
        if ValueAsString then
            GraphQuery.Append('\", ')
        else
            GraphQuery.Append(', ');
        exit(true);
    end;
}