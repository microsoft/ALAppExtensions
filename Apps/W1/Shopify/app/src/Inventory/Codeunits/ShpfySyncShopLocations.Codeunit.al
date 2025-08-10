// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

/// <summary>
/// Codeunit Shpfy Sync Shop Locations (ID 30198).
/// </summary>
codeunit 30198 "Shpfy Sync Shop Locations"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        Shop := Rec;
        CommunicationMgt.SetShop(Rec);
        SyncLocations();
    end;

    var
        Shop: record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Import Location.
    /// </summary>
    /// <param name="JLocation">Parameter of type JsonObject.</param>
    /// <param name="TempShopLocation">Parameter of type Record "Shpfy Shop Location" containing existing Locations.</param>
    internal procedure ImportLocation(JLocation: JsonObject; var TempShopLocation: Record "Shpfy Shop Location" temporary)
    var
        ShopLocation: Record "Shpfy Shop Location";
        IsNew: Boolean;
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonValue(JLocation, JValue, 'legacyResourceId') then begin
            if not ShopLocation.Get(Shop.Code, JValue.AsBigInteger()) then begin
                ShopLocation.Init();
                ShopLocation."Shop Code" := Shop.Code;
                ShopLocation.Id := JValue.AsBigInteger();
                IsNew := true;
            end;
#pragma warning disable AA0139
            ShopLocation.Name := JsonHelper.GetValueAsText(JLocation, 'name', MaxStrLen(ShopLocation.Name));
#pragma warning restore AA0139
            ShopLocation.Active := JsonHelper.GetValueAsBoolean(JLocation, 'isActive');
            ShopLocation."Is Primary" := JsonHelper.GetValueAsBoolean(JLocation, 'isPrimary');
            ShopLocation."Is Fulfillment Service" := JsonHelper.GetJsonToken(JLocation.AsToken(), 'fulfillmentService').IsObject;
            if IsNew then
                ShopLocation.Insert()
            else begin
                ShopLocation.Modify();
                if TempShopLocation.Get(ShopLocation."Shop Code", ShopLocation.Id) then
                    TempShopLocation.Delete();
            end;
        end;
    end;

    /// <summary> 
    /// Sync Locations.
    /// </summary>
    internal procedure SyncLocations()
    var
        ShopLocation: Record "Shpfy Shop Location";
        TempShopLocation: Record "Shpfy Shop Location" temporary;
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JLocation: JsonToken;
        JPageInfo: JsonObject;
        JResponse: JsonToken;
    begin
        ShopLocation.SetRange("Shop Code", Shop.Code);
        if ShopLocation.FindSet(false) then
            repeat
                TempShopLocation := ShopLocation;
                TempShopLocation.Insert(false);
            until ShopLocation.Next() = 0;

        GraphQLType := "Shpfy GraphQL Type"::GetLocations;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            Clear(Cursor);
            if JsonHelper.GetJsonObject(JResponse, JPageInfo, 'data.locations.pageInfo') then begin
                Cursor := JsonHelper.GetValueAsText(JPageInfo, 'endCursor');
                GraphQLType := GraphQLType::GetNextLocations;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
                foreach JLocation in JsonHelper.GetJsonArray(JResponse, 'data.locations.nodes') do
                    ImportLocation(JLocation.AsObject(), TempShopLocation)
            end;
        until not HasNextResults(JPageInfo);

        if TempShopLocation.FindSet(false) then
            repeat
                if ShopLocation.Get(TempShopLocation."Shop Code", TempShopLocation.Id) then
                    ShopLocation.Delete(true);
            until TempShopLocation.Next() = 0;
    end;

    local procedure HasNextResults(JObject: JsonObject): Boolean
    begin
        exit(JsonHelper.GetValueAsBoolean(JObject, 'hasNextPage'));
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;

}