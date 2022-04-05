/// <summary>
/// Codeunit Shpfy Sync Shop Locations (ID 30198).
/// </summary>
codeunit 30198 "Shpfy Sync Shop Locations"
{
    Access = Internal;
    TableNo = "Shpfy Shop";

    trigger OnRun()
    begin
        ShpfyShop := Rec;
        ShpfyCommunicationMgt.SetShop(Rec);
        SyncLocations();
    end;

    var
        ShpfyShop: record "Shpfy Shop";
        ShpfyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
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
        if JsonHelper.GetValueAsBoolean(JLocation, 'legacy') then
            exit;
        if JsonHelper.GetJsonValue(JLocation, JValue, 'id') then begin
            if not ShopLocation.Get(ShpfyShop.Code, JValue.AsBigInteger()) then begin
                ShopLocation.Init();
                ShopLocation."Shop Code" := ShpfyShop.Code;
                ShopLocation.Id := JValue.AsBigInteger();
                IsNew := true;
            end;
#pragma warning disable AA0139
            ShopLocation.Name := JsonHelper.GetValueAsText(JLocation, 'name', MaxStrLen(ShopLocation.Name));
#pragma warning restore AA0139
            ShopLocation.Active := JsonHelper.GetValueAsBoolean(JLocation, 'active');
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
    local procedure SyncLocations()
    var
        JRequest: JsonToken;
        JResponse: JsonToken;
        Url: Text;
    begin
        Url := ShpfyCommunicationMgt.CreateWebRequestURL('locations.json');
        JResponse := ShpfyCommunicationMgt.ExecuteWebRequest(Url, 'GET', JRequest);
        SyncLocations(JResponse);
    end;

    internal procedure SyncLocations(JLocationResult: JsonToken)
    var
        ShopLocation: Record "Shpfy Shop Location";
        TempShopLocation: Record "Shpfy Shop Location" temporary;
        JLocations: JsonArray;
        JLocation: JsonToken;
    begin
        ShopLocation.SetRange("Shop Code", ShpfyShop.Code);
        if ShopLocation.FindSet(false, false) then
            repeat
                TempShopLocation := ShopLocation;
                TempShopLocation.Insert(false);
            until ShopLocation.Next() = 0;

        if JsonHelper.GetJsonArray(JLocationResult.AsObject(), JLocations, 'locations') then
            foreach JLocation in JLocations do
                ImportLocation(JLocation.AsObject(), TempShopLocation);

        if TempShopLocation.FindSet(false, false) then
            repeat
                if ShopLocation.Get(TempShopLocation."Shop Code", TempShopLocation.Id) then
                    ShopLocation.Delete(true);
            until TempShopLocation.Next() = 0;
    end;

    internal procedure SetShop(Shop: Record "Shpfy Shop")
    begin
        ShpfyShop := Shop;
    end;

}