/// <summary>
/// Codeunit Shpfy Sync Countries (ID 30107).
/// </summary>
codeunit 30107 "Shpfy Sync Countries"
{
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        ShopifyShop := Rec;
        ShopifyCommunicationMgt.SetShop(Rec);
        SyncCountries();
        Commit();
    end;

    var
        ShopifyShop: record "Shpfy Shop";
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Import Country.
    /// </summary>
    /// <param name="JCountry">Parameter of type JsonObject.</param>
    local procedure ImportCountry(JCountry: JsonObject)
    var
        ShopCustomerTemplate: Record "Shpfy Customer Template";
        JProvinces: JsonArray;
        JProvince: JsonToken;
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonValue(JCountry, JValue, 'code') then begin
            ShopCustomerTemplate.Init();
            ShopCustomerTemplate."Shop Code" := ShopifyShop.Code;
            ShopCustomerTemplate."Country Code" := CopyStr(JValue.AsCode(), 1, MaxStrLen(ShopCustomerTemplate."Country Code"));
            if (ShopCustomerTemplate."Country Code" <> '') and (ShopCustomerTemplate."Country Code" <> '*') then begin
                if ShopCustomerTemplate.Insert() then;
                if JsonHelper.GetJsonArray(JCountry, JProvinces, 'provinces') then
                    foreach JProvince in JProvinces do
                        ImportProvince(JProvince.AsObject(), ShopCustomerTemplate."Country Code");
            end;
        end;
    end;

    /// <summary> 
    /// Import Province.
    /// </summary>
    /// <param name="JProvince">Parameter of type JsonObject.</param>
    /// <param name="CountrCode">Parameter of type Text.</param>
    local procedure ImportProvince(JProvince: JsonObject; CountrCode: Text)
    var
        ShopifyTaxArea: Record "Shpfy Tax Area";
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonValue(JProvince, JValue, 'name') then begin
            ShopifyTaxArea.Init();
            ShopifyTaxArea."Country Code" := CopyStr(CountrCode, 1, MaxStrLen(ShopifyTaxArea."Country Code"));
            ShopifyTaxArea.County := CopyStr(JValue.AsText(), 1, MaxStrLen(ShopifyTaxArea.County));
            if ShopifyTaxArea.Insert() then;
        end;
    end;

    /// <summary> 
    /// Sync Countries.
    /// </summary>
    local procedure SyncCountries()
    var
        ShopCustomerTemplate: Record "Shpfy Customer Template";
        JCountries: JsonArray;
        JCountry: JsonToken;
        JRequest: JsonToken;
        JResponse: JsonToken;
        Url: Text;
    begin
        ShopCustomerTemplate.SetRange("Shop Code", ShopifyShop.Code);
        ShopCustomerTemplate.SetFilter("Country Code", '%1|%2', '', '*');
        ShopCustomerTemplate.DeleteAll(true);
        if ShopifyShop."Shopify URL".EndsWith('/') then
            Url := ShopifyShop."Shopify URL" + 'admin/countries.json'
        else
            Url := ShopifyShop."Shopify URL" + '/admin/countries.json';
        JResponse := ShopifyCommunicationMgt.ExecuteWebRequest(Url, 'GET', JRequest);
        if JsonHelper.GetJsonArray(JResponse.AsObject(), JCountries, 'countries') then
            foreach JCountry in JCountries do
                ImportCountry(JCountry.AsObject());
    end;
}