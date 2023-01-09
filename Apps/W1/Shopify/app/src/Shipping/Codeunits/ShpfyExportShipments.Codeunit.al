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
    begin
        if ShopifyOrderHeader.Get(SalesShipmentHeader."Shpfy Order Id") then begin
            ShopifyCommunicationMgt.SetShop(ShopifyOrderHeader."Shop Code");
            JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(CreateFulfillmentRequest(SalesShipmentHeader, LocationId, LocationCode));
            JFulfillment := JsonHelper.GetJsonToken(JResponse, 'data.fulfillmentCreate.fulfillment');
            if (JFulfillment.IsObject) then
                SalesShipmentHeader."Shpfy Fulfillment Id" := OrderFulfillments.ImportFulfillment(SalesShipmentHeader."Shpfy Order Id", JFulfillment)
            else
                SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
            SalesShipmentHeader.Modify(true);
        end;
    end;

    internal procedure CreateFulfillmentRequest(SalesShipmentHeader: Record 110; LocationId: BigInteger; LocationCode: Code[10]) Request: Text;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShippingAgent: Record "Shipping Agent";
        TrackingCompany: Enum "Shpfy Tracking Companies";
        IsHandled: Boolean;
        TrackingUrl: Text;
        GraphQuery: TextBuilder;
        LinesBuilder: TextBuilder;
    begin
        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Shpfy Order Line Id", '<>%1', 0);
        SalesShipmentLine.SetFilter(Quantity, '>%1', 0);
        SalesShipmentLine.SetRange("Location Code", LocationCode);
        if SalesShipmentLine.FindSet() then begin
            repeat
                if LinesBuilder.Length > 0 then
                    LinesBuilder.Append(', ');
                LinesBuilder.Append('{id: \"gid://shopify/LineItem/');
                LinesBuilder.Append(Format(SalesShipmentLine."Shpfy Order Line Id"));
                LinesBuilder.Append('\", quantity: ');
                LinesBuilder.Append(Format(SalesShipmentLine.Quantity));
                LinesBuilder.Append('}');
            until SalesShipmentLine.Next() = 0;

            GraphQuery.Append('{"query": "mutation { fulfillmentCreate(input: {orderId: \"gid://shopify/Order/');
            GraphQuery.Append(Format(SalesShipmentHeader."Shpfy Order Id"));
            GraphQuery.Append('\", locationId: \"gid://shopify/Location/');
            GraphQuery.Append(Format(LocationId));
            GraphQuery.Append('\", notifyCustomer: true, ');
            if SalesShipmentHeader."Package Tracking No." <> '' then begin
                GraphQuery.Append('trackingCompany: \"');
                if SalesShipmentHeader."Shipping Agent Code" <> '' then
                    if ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code") then begin
                        if ShippingAgent."Shpfy Tracking Company" = ShippingAgent."Shpfy Tracking Company"::" " then begin
                            if ShippingAgent.Name = '' then
                                GraphQuery.Append(ShippingAgent.Code)
                            else
                                GraphQuery.Append(ShippingAgent.Code)
                        end else
                            GraphQuery.Append(TrackingCompany.Names.Get(TrackingCompany.Ordinals.IndexOf(ShippingAgent."Shpfy Tracking Company".AsInteger())));
                    end else
                        GraphQuery.Append('""');

                GraphQuery.Append('\", trackingNumbers: \"');
                GraphQuery.Append(SalesShipmentHeader."Package Tracking No.");
                GraphQuery.Append('\", trackingUrls: \"');
                ShippingEvents.BeforeRetrieveTrackingUrl(SalesShipmentHeader, TrackingUrl, IsHandled);
                if not IsHandled then
                    TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");
                GraphQuery.Append(TrackingUrl);
                GraphQuery.Append('\", ');
            end;
            GraphQuery.Append('lineItems: [');
            GraphQuery.Append(LinesBuilder.ToText());
            GraphQuery.Append(']}) {fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type shippingMethods { code label }} fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id product { isGiftCard }}}}}}}"}');
            exit(GraphQuery.ToText());
        end;
    end;

    // TODO Remove (CleanUp)
    /// <summary> 
    /// Create Fulfillment Request.
    /// </summary>
    /// <param name="SalesShipmentHeader">Parameter of type Record 110.</param>
    /// <returns>Return variable "Request" of type Text.</returns>
    local procedure CreateFulfillmentRequestOld(SalesShipmentHeader: Record 110; LocationId: BigInteger; LocationCode: Code[10]) Request: Text;
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        OrderHeader: Record "Shpfy Order Header";
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
        if OrderHeader.Get(SalesShipmentHeader."Shpfy Order Id") then begin
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