namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Sync Countries (ID 30107).
/// </summary>
codeunit 30107 "Shpfy Sync Countries"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        ShopifyShop := Rec;
        ShopifyCommunicationMgt.SetShop(Rec);
        JCountries := GetCountries();
        SyncCountries();
        Commit();
    end;

    var
        ShopifyShop: Record "Shpfy Shop";
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JCountries: JsonArray;

    local procedure SyncCountries()
    var
        ShopCustomerTemplate: Record "Shpfy Customer Template";
        GraphQLType: Enum "Shpfy GraphQL Type";
        JShipToCountries: JsonArray;
        JShipToCountry: JsonToken;
        JResponse: JsonToken;
    begin
        ShopCustomerTemplate.SetRange("Shop Code", ShopifyShop.Code);
        ShopCustomerTemplate.SetFilter("Country/Region Code", '%1|%2', '', '*');
        ShopCustomerTemplate.DeleteAll(true);

        GraphQLType := GraphQLType::GetShipToCountries;
        JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(GraphQLType);
        if JsonHelper.GetJsonArray(JResponse, JShipToCountries, 'data.shop.shipsToCountries') then
            foreach JShipToCountry in JShipToCountries do
                ImportCountry(JShipToCountry.AsValue());
    end;

    local procedure ImportCountry(CountryCode: JsonValue);
    var
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
    begin
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Shop Code" := ShopifyShop.Code;
        ShopifyCustomerTemplate."Country/Region Code" := CopyStr(CountryCode.AsCode(), 1, MaxStrLen(ShopifyCustomerTemplate."Country/Region Code"));
        if (ShopifyCustomerTemplate."Country/Region Code" <> '') and (ShopifyCustomerTemplate."Country/Region Code" <> '*') then begin
            if ShopifyCustomerTemplate.Insert() then;
            ImportProvince(CountryCode);
        end;
    end;

    local procedure ImportProvince(CountryCode: JsonValue)
    var
        ShopifyTaxArea: Record "Shpfy Tax Area";
        JProvinces: JsonArray;
        JCountry: JsonToken;
        JProvince: JsonToken;
    begin
        foreach JCountry in JCountries do
            if JsonHelper.GetValueAsCode(JCountry.AsObject(), 'code') = CountryCode.AsCode() then begin
                if JsonHelper.GetJsonArray(JCountry.AsObject(), JProvinces, 'provinces') then
                    foreach JProvince in JProvinces do begin
                        ShopifyTaxArea.Init();
                        ShopifyTaxArea."Country/Region Code" := CopyStr(CountryCode.AsCode(), 1, MaxStrLen(ShopifyTaxArea."Country/Region Code"));
                        ShopifyTaxArea.County := CopyStr(JsonHelper.GetValueAsText(JProvince, 'name'), 1, MaxStrLen(ShopifyTaxArea.County));
                        ShopifyTaxArea."County Code" := CopyStr(JsonHelper.GetValueAsText(JProvince, 'code'), 1, MaxStrLen(ShopifyTaxArea."County Code"));
                        if ShopifyTaxArea.Insert() then;
                    end;
                exit;
            end;
    end;

    local procedure GetCountries(): JsonArray
    var
        Line: Text;
        CountryList: TextBuilder;
        ResInStream: InStream;
        JCountry: JsonObject;
    begin
        NavApp.GetResource('data/provinces.yml', ResInStream, TextEncoding::UTF8);
        while not ResInStream.EOS do begin
            ResInStream.ReadText(Line);
            CountryList.AppendLine(Line);
        end;
        JCountry.ReadFromYaml(CountryList.ToText());
        exit(JsonHelper.GetJsonArray(JCountry, 'countries'));
    end;
}