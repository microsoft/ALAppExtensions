/// <summary>
/// Codeunit Shpfy Export Shipments (ID 30190).
/// </summary>
codeunit 30190 "Shpfy Export Shipments"
{
    Access = Internal;
    Permissions =
        tabledata "Sales Shipment Header" = rm,
        tabledata "Sales Shipment Line" = r,
        tabledata "Shipping Agent" = r;

    var
        ShopifyCommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        ShippingEvents: Codeunit "Shpfy Shipping Events";

    /// <summary> 
    /// Create Shopify Fulfillment.
    /// </summary>
    /// <param name="SalesShipmentHeader">Parameter of type Record "Sales Shipment Header".</param>
    internal procedure CreateShopifyFulfillment(var SalesShipmentHeader: Record "Sales Shipment Header");
    var
        ShipmentLocation: Query "Shpfy Shipment Location";
    begin
        if (SalesShipmentHeader."Shpfy Order Id" <> 0) and (SalesShipmentHeader."Shpfy Fulfillment Id" = 0) then begin
            ShipmentLocation.SetRange(No, SalesShipmentHeader."No.");
            if ShipmentLocation.Open() then
                while ShipmentLocation.Read() do
                    CreateShopifyFulfillment(SalesShipmentHeader, ShipmentLocation.LocationId, ShipmentLocation.LocationCode);
        end;
    end;

    local procedure CreateShopifyFulfillment(var SalesShipmentHeader: Record "Sales Shipment Header"; LocationId: BigInteger; LocationCode: Code[10]);
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
        OrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        JsonHelper: Codeunit "Shpfy Json Helper";
        JFulfillment: JsonToken;
        JResponse: JsonToken;
        Request: Text;
        Response: Text;
        Url: Text;
        JErrors: JsonToken;
        JErrorsBase: JsonArray;
        OrderFulFillmentUrlTxt: Label 'orders/%1/fulfillments.json', Comment = '%1 = Shopify order if.', Locked = true;
    begin
        if ShopifyOrderHeader.Get(SalesShipmentHeader."Shpfy Order Id") then begin
            ShopifyCommunicationMgt.SetShop(ShopifyOrderHeader."Shop Code");
            Url := ShopifyCommunicationMgt.CreateWebRequestURL(StrSubstNo(OrderFulfillmentUrlTxt, SalesShipmentHeader."Shpfy Order Id"));
            Request := CreateFulfillmentRequest(SalesShipmentHeader, LocationId, LocationCode);
            if Request <> '' then begin
                Response := ShopifyCommunicationMgt.ExecuteWebRequest(Url, 'POST', Request);
                if JResponse.ReadFrom(Response) then
                    if JResponse.IsObject() then begin
                        JFulfillment := JsonHelper.GetJsonToken(JResponse, 'fulfillment');
                        if JFulfillment.IsObject then begin
                            SalesShipmentHeader."Shpfy Fulfillment Id" := OrderFulfillments.ImportFulfillment(JFulfillment);
                            SalesShipmentHeader.Modify(true);
                        end else
                            if JResponse.AsObject().Contains('errors') then begin
                                JErrors := JsonHelper.GetJsonToken(JResponse, 'errors');
                                if JErrors.IsObject then
                                    if JsonHelper.GetJsonArray(JErrors.AsObject(), JErrorsBase, 'base') then
                                        if JErrorsBase.IndexOf('Line items are already fulfilled') > 0 then begin
                                            SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
                                            SalesShipmentHeader.Modify(true);
                                        end else
                                            foreach JErrors in JErrorsBase do
                                                if DelChr(JErrors.AsValue().AsText(), '=', '123456789') = 'Line item '''' is already fulfilled' then begin
                                                    SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
                                                    SalesShipmentHeader.Modify(true);
                                                end;
                                if JErrors.IsValue then
                                    if JErrors.AsValue().AsText() = 'Not Found' then begin
                                        SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
                                        SalesShipmentHeader.Modify(true);
                                    end;
                            end;
                    end;
            end;
        end;
    end;


    /// <summary> 
    /// Create Fulfillment Request.
    /// </summary>
    /// <param name="SalesShipmentHeader">Parameter of type Record 110.</param>
    /// <returns>Return variable "Request" of type Text.</returns>
    local procedure CreateFulfillmentRequest(SalesShipmentHeader: Record 110; LocationId: BigInteger; LocationCode: Code[10]) Request: Text;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShopifyOrder: Record "Shpfy Order Header";
        ShopifyOrderLine: Record "Shpfy Order Line";
        ShippingAgent: Record "Shipping Agent";
        TrackingCompany: Enum "Shpfy Tracking Companies";
        Quantity: Integer;
        JLines: JsonArray;
        JFulfillment: JsonObject;
        JLine: JsonObject;
        JObject: JsonObject;
        IsHandled: Boolean;
        TrackingUrl: Text;
    begin
        if ShopifyOrder.Get(SalesShipmentHeader."Shpfy Order Id") then begin
            JFulfillment.Add('location_id', LocationId);
            if SalesShipmentHeader."Package Tracking No." <> '' then begin
                JFulfillment.Add('tracking_number', SalesShipmentHeader."Package Tracking No.");
                if SalesShipmentHeader."Shipping Agent Code" <> '' then
                    if ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code") then begin
                        if ShippingAgent."Shpfy Tracking Company" = ShippingAgent."Shpfy Tracking Company"::" " then begin
                            if ShippingAgent.Name = '' then
                                JFulfillment.Add('tracking_company', ShippingAgent.Code)
                            else
                                JFulfillment.Add('tracking_company', ShippingAgent.Name);
                        end else
                            JFulfillment.Add('tracking_company', TrackingCompany.Names.Get(TrackingCompany.Ordinals.IndexOf(ShippingAgent."Shpfy Tracking Company".AsInteger())));
                        ShippingEvents.BeforeRetrieveTrackingUrl(SalesShipmentHeader, TrackingUrl, IsHandled);
                        if not IsHandled then
                            TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");
                        JFulfillment.Add('tracking_url', TrackingUrl);
                    end;
            end;
        end;

        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Shpfy Order Line Id", '<>%1', 0);
        SalesShipmentLine.SetFilter(Quantity, '>%1', 0);
        SalesShipmentLine.SetRange("Location Code", LocationCode);
        if SalesShipmentLine.FindSet() then
            repeat
                ShopifyOrderLine.SetRange("Line Id", SalesShipmentLine."Shpfy Order Line Id");
                if ShopifyOrderLine.IsEmpty then
                    exit('')
                else begin
                    Clear(JLine);
                    JLine.Add('id', SalesShipmentLine."Shpfy Order Line Id");
                    Quantity := Round(SalesShipmentLine.Quantity, 1, '=');
                    JLine.Add('quantity', Quantity);
                    JLines.Add(JLine);
                end;
            until SalesShipmentLine.Next() = 0;
        JFulfillment.Add('line_items', JLines);

        JFulfillment.Add('status', 'success');
        JFulfillment.Add('notify_customer', true);
        JObject.Add('fulfillment', JFulfillment);
        JObject.WriteTo(Request);
    end;

}