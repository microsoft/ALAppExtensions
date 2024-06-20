namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Payment Terms API (ID 30168).
/// </summary>
codeunit 30168 "Shpfy Payment Terms API"
{
    internal procedure PullPaymentTermsCodes(ShopCode: Code[20])
    var
        Shop: Record "Shpfy Shop";
        PaymentTerms: Record "Shpfy Payment Terms";
        PaymentTermRecordRef: RecordRef;
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShpfyDraftOrdersAPI: Codeunit "Shpfy Draft Orders API";
        JsonHelper: Codeunit "Shpfy Json Helper";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JArray: JsonArray;
        JToken: JsonToken;
        JResponse: JsonToken;
        IsNew: Boolean;
        Id: BigInteger;
    begin
        Shop.Get(ShopCode);

        CommunicationMgt.SetShop(Shop.Code);

        GraphQLType := GraphQLType::GetPaymentTerms;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType);

        JsonHelper.GetJsonArray(JResponse, JArray, 'data.paymentTermsTemplates');
        foreach JToken in JArray do begin
            Id := ShpfyDraftOrdersAPI.ParseShopifyResponse(JToken, 'id');
            IsNew := not PaymentTerms.Get(ShopCode, Id);

            if IsNew then begin
                Clear(PaymentTerms);
                PaymentTerms."Id" := Id;
                PaymentTerms."Shop Code" := ShopCode;
            end;

            PaymentTermRecordRef.GetTable(PaymentTerms);
            JsonHelper.GetValueIntoField(JToken, 'name', PaymentTermRecordRef, PaymentTerms.FieldNo(Name));
            JsonHelper.GetValueIntoField(JToken, 'paymentTermsType', PaymentTermRecordRef, PaymentTerms.FieldNo(Type));
            JsonHelper.GetValueIntoField(JToken, 'dueInDays', PaymentTermRecordRef, PaymentTerms.FieldNo("Due In Days"));
            JsonHelper.GetValueIntoField(JToken, 'description', PaymentTermRecordRef, PaymentTerms.FieldNo(Description));
            PaymentTermRecordRef.SetTable(PaymentTerms);

            if IsNew then
                PaymentTerms.Insert()
            else
                PaymentTerms.Modify();
        end;
    end;
}