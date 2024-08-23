namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Payment Terms API (ID 30360).
/// </summary>
codeunit 30360 "Shpfy Payment Terms API"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        ShopCode: Code[20];

    /// <summary>
    /// Synchronizes payment terms from shopify, ensuring that the payment terms are up-to-date with those defined in the shopify store.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be used.</param>
    internal procedure PullPaymentTermsCodes()
    var
        GraphQLType: Enum "Shpfy GraphQL Type";
        JTemplates: JsonArray;
        JTemplate: JsonToken;
        JResponse: JsonToken;
    begin
        GraphQLType := GraphQLType::GetPaymentTerms;
        JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType);

        JsonHelper.GetJsonArray(JResponse, JTemplates, 'data.paymentTermsTemplates');
        foreach JTemplate in JTemplates do
            UpdatePaymentTerms(JTemplate);
    end;

    /// <summary>
    /// Sets a global shopify shop to be used form payment terms api functionality.
    /// </summary>
    /// <param name="ShopCode">Shopify shop code to be set.</param>
    internal procedure SetShop(NewShopCode: Code[20])
    begin
        ShopCode := NewShopCode;
        CommunicationMgt.SetShop(NewShopCode);
    end;

    local procedure UpdatePaymentTerms(JTemplate: JsonToken)
    var
        ShpfyPaymentTerms: Record "Shpfy Payment Terms";
        PaymentTermRecordRef: RecordRef;
        Id: BigInteger;
        IsNew: Boolean;
    begin
        Id := CommunicationMgt.GetIdOfGId(JsonHelper.GetValueAsText(JTemplate, 'id'));
        IsNew := not ShpfyPaymentTerms.Get(ShopCode, Id);

        if IsNew then begin
            Clear(ShpfyPaymentTerms);
            ShpfyPaymentTerms.Id := Id;
            ShpfyPaymentTerms."Shop Code" := ShopCode;
        end;

        PaymentTermRecordRef.GetTable(ShpfyPaymentTerms);
        JsonHelper.GetValueIntoField(JTemplate, 'name', PaymentTermRecordRef, ShpfyPaymentTerms.FieldNo(Name));
        JsonHelper.GetValueIntoField(JTemplate, 'paymentTermsType', PaymentTermRecordRef, ShpfyPaymentTerms.FieldNo(Type));
        JsonHelper.GetValueIntoField(JTemplate, 'dueInDays', PaymentTermRecordRef, ShpfyPaymentTerms.FieldNo("Due In Days"));
        JsonHelper.GetValueIntoField(JTemplate, 'description', PaymentTermRecordRef, ShpfyPaymentTerms.FieldNo(Description));
        PaymentTermRecordRef.SetTable(ShpfyPaymentTerms);

        if ShpfyPaymentTerms.Type = 'FIXED' then
            if ShouldBeMarkedAsPrimary() then
                ShpfyPaymentTerms.Validate("Is Primary", true);

        if IsNew then
            ShpfyPaymentTerms.Insert(true)
        else
            ShpfyPaymentTerms.Modify(true);
    end;

    local procedure ShouldBeMarkedAsPrimary(): Boolean
    var
        ShpfyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShpfyPaymentTerms.SetRange("Shop Code", ShopCode);
        ShpfyPaymentTerms.SetRange("Is Primary", true);
        exit(ShpfyPaymentTerms.IsEmpty());
    end;
}