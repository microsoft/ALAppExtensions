/// <summary>
/// Codeunit Shpfy Shipping Methods (ID 30193).
/// </summary>
codeunit 30193 "Shpfy Shipping Methods"
{
    Access = Internal;

    var
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        JsonHelper: Codeunit "Shpfy Json Helper";

    /// <summary> 
    /// Description for GetShippingMethods.
    /// </summary>
    /// <param name="ShopifyShop">Parameter of type Record "Shopify Shop".</param>
    internal procedure GetShippingMethods(var ShopifyShop: Record "Shpfy Shop")
    var
        ShipmentMethod: Record "Shpfy Shipment Method Mapping";
        Shop: Record "Shpfy Shop";
        JRates: JsonArray;
        JZones: JsonArray;
        JRate: JsonToken;
        JResponse: JsonToken;
        JZone: JsonToken;
        Name: Text;
    begin
        if ShopifyShop.GetFilters = '' then begin
            Shop := ShopifyShop;
            Shop.SetRecFilter();
        end else
            Shop.CopyFilters(ShopifyShop);
        if Shop.FindSet(false, false) then begin
            CommunicationMgt.SetShop(Shop);
            JResponse := CommunicationMgt.ExecuteWebRequest(CommunicationMgt.CreateWebRequestURL('shipping_zones.json'), 'GET', JResponse);
            if JsonHelper.GetJsonArray(JResponse, JZones, 'shipping_zones') then
                foreach Jzone in JZones do
                    if JsonHelper.GetJsonArray(JZone, JRates, 'price_based_shipping_rates') then
                        foreach JRate in JRates do begin
                            Name := JsonHelper.GetValueAsText(JRate, 'name', MaxStrLen(ShipmentMethod.Name));
                            if Name <> '' then
                                if not ShipmentMethod.Get(Shop.Code, Name) then begin
                                    Clear(ShipmentMethod);
                                    ShipmentMethod."Shop Code" := Shop.Code;
                                    ShipmentMethod.Name := CopyStr(Name, 1, MaxStrLen(ShipmentMethod.Name));
                                    ShipmentMethod.Insert();
                                end;
                        end;
        end;
    end;

}