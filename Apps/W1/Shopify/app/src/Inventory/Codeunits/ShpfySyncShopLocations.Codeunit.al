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
    internal procedure ImportLocation(JLocation: JsonObject; var TempShopLocation: Record "Shpfy Shop Location" temporary) Cursor: Text
    var
        ShopLocation: Record "Shpfy Shop Location";
        IsNew: Boolean;
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonValue(JLocation, JValue, 'node.legacyResourceId') then begin
            if not ShopLocation.Get(Shop.Code, JValue.AsBigInteger()) then begin
                ShopLocation.Init();
                ShopLocation."Shop Code" := Shop.Code;
                ShopLocation.Id := JValue.AsBigInteger();
                IsNew := true;
            end;
#pragma warning disable AA0139
            ShopLocation.Name := JsonHelper.GetValueAsText(JLocation, 'node.name', MaxStrLen(ShopLocation.Name));
#pragma warning restore AA0139
            ShopLocation.Active := JsonHelper.GetValueAsBoolean(JLocation, 'node.isActive');
            ShopLocation."Is Primary" := JsonHelper.GetValueAsBoolean(JLocation, 'node.isPrimary');
            if IsNew then
                ShopLocation.Insert()
            else begin
                ShopLocation.Modify();
                if TempShopLocation.Get(ShopLocation."Shop Code", ShopLocation.Id) then
                    TempShopLocation.Delete();
            end;
            Cursor := JsonHelper.GetValueAsText(JLocation, 'cursor');
        end;
    end;

    /// <summary> 
    /// Sync Locations.
    /// </summary>
    local procedure SyncLocations()
    var
        Parameters: Dictionary of [Text, Text];
        GraphQLType: Enum "Shpfy GraphQL Type";
        Cursor: Text;
        JLocations: JsonObject;
        JResponse: JsonToken;
    begin
        GraphQLType := "Shpfy GraphQL Type"::GetLocations;
        repeat
            JResponse := CommunicationMgt.ExecuteGraphQL(GraphQLType, Parameters);
            Clear(Cursor);
            if JsonHelper.GetJsonObject(JResponse, JLocations, 'data.locations') then begin
                Cursor := SyncLocations(JLocations);
                GraphQLType := GraphQLType::GetNextLocations;
                if Parameters.ContainsKey('After') then
                    Parameters.Set('After', Cursor)
                else
                    Parameters.Add('After', Cursor);
            end;
        until not HasNextResults(JLocations);
    end;

    local procedure HasNextResults(JObject: JsonObject): Boolean
    var
        JPageInfo: JsonObject;
        JValue: JsonValue;
    begin
        if JsonHelper.GetJsonObject(JObject, JPageInfo, 'pageInfo') then
            if JsonHelper.GetJsonValue(JPageInfo, JValue, 'hasNextPage') then
                exit(JValue.AsBoolean());
    end;

    internal procedure SyncLocations(JLocationResult: JsonObject) Cursor: Text
    var
        ShopLocation: Record "Shpfy Shop Location";
        TempShopLocation: Record "Shpfy Shop Location" temporary;
        JLocations: JsonArray;
        JLocation: JsonToken;
    begin
        ShopLocation.SetRange("Shop Code", Shop.Code);
        if ShopLocation.FindSet(false, false) then
            repeat
                TempShopLocation := ShopLocation;
                TempShopLocation.Insert(false);
            until ShopLocation.Next() = 0;

        if JsonHelper.GetJsonArray(JLocationResult, JLocations, 'edges') then
            foreach JLocation in JLocations do
                Cursor := ImportLocation(JLocation.AsObject(), TempShopLocation);

        if TempShopLocation.FindSet(false, false) then
            repeat
                if ShopLocation.Get(TempShopLocation."Shop Code", TempShopLocation.Id) then
                    ShopLocation.Delete(true);
            until TempShopLocation.Next() = 0;
    end;

    internal procedure SetShop(ShopifyShop: Record "Shpfy Shop")
    begin
        Shop := ShopifyShop;
    end;

}