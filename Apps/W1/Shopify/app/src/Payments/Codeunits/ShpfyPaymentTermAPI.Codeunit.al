namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Payment Terms API (ID 30168).
/// </summary>
codeunit 30168 "Shpfy Payment Terms API"
{
    var
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary>
    /// Synchronizes payment terms from shopify, ensuring that the payment terms are up-to-date with those defined in the shopify store.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be used.</param>
    internal procedure PullPaymentTermsCodes(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
        PaymentTerms: Record "Shpfy Payment Terms";
        PaymentTermRecordRef: RecordRef;
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JTemplates: JsonArray;
        JTemplate: JsonToken;
        JResponse: JsonToken;
        IsNew: Boolean;
        Id: BigInteger;
    begin
        Shop.Get(ShopCode);

        CommunicationMgt.SetShop(Shop.Code);

        GraphQLType := GraphQLType::GetPaymentTerms;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType);

        JsonHelper.GetJsonArray(JResponse, JTemplates, 'data.paymentTermsTemplates');
        foreach JTemplate in JTemplates do begin
            Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTemplate, 'id'));
            IsNew := not PaymentTerms.Get(ShopCode, Id);

            if IsNew then begin
                Clear(PaymentTerms);
                PaymentTerms."Id" := Id;
                PaymentTerms."Shop Code" := ShopCode;
            end;

            PaymentTermRecordRef.GetTable(PaymentTerms);
            JsonHelper.GetValueIntoField(JTemplate, 'name', PaymentTermRecordRef, PaymentTerms.FieldNo(Name));
            JsonHelper.GetValueIntoField(JTemplate, 'paymentTermsType', PaymentTermRecordRef, PaymentTerms.FieldNo(Type));
            JsonHelper.GetValueIntoField(JTemplate, 'dueInDays', PaymentTermRecordRef, PaymentTerms.FieldNo("Due In Days"));
            JsonHelper.GetValueIntoField(JTemplate, 'description', PaymentTermRecordRef, PaymentTerms.FieldNo(Description));
            PaymentTermRecordRef.SetTable(PaymentTerms);

            if IsNew then
                PaymentTerms.Insert()
            else
                PaymentTerms.Modify();
        end;
    end;
}