namespace Microsoft.Integration.Shopify;

using Microsoft.Foundation.Shipping;
using Microsoft.Sales.History;

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
        NoCorrespondingFulfillmentLinesLbl: Label 'No corresponding fulfillment lines found.';
        NoFulfillmentCreatedInShopifyLbl: Label 'Fulfillment was not created in Shopify.';

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
                    CreateShopifyFulfillment(SalesShipmentHeader, ShipmentLocation.LocationId, ShipmentLocation.DeliveryMethodType);
        end;
    end;

    local procedure CreateShopifyFulfillment(var SalesShipmentHeader: Record "Sales Shipment Header"; LocationId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type");
    var
        Shop: Record "Shpfy Shop";
        ShopifyOrderHeader: Record "Shpfy Order Header";
        OrderFulfillments: Codeunit "Shpfy Order Fulfillments";
        JsonHelper: Codeunit "Shpfy Json Helper";
        SkippedRecord: Codeunit "Shpfy Skipped Record";
        JFulfillment: JsonToken;
        JResponse: JsonToken;
        FulfillmentOrderRequest: Text;
        FulfillmentId: BigInteger;
        FulfillmentOrderRequests: List of [Text];
    begin
        if ShopifyOrderHeader.Get(SalesShipmentHeader."Shpfy Order Id") then begin
            ShopifyCommunicationMgt.SetShop(ShopifyOrderHeader."Shop Code");
            Shop.Get(ShopifyOrderHeader."Shop Code");
            FulfillmentOrderRequests := CreateFulfillmentOrderRequest(SalesShipmentHeader, Shop, LocationId, DeliveryMethodType);
            if FulfillmentOrderRequests.Count <> 0 then
                foreach FulfillmentOrderRequest in FulfillmentOrderRequests do begin
                    JResponse := ShopifyCommunicationMgt.ExecuteGraphQL(FulfillmentOrderRequest);
                    JFulfillment := JsonHelper.GetJsonToken(JResponse, 'data.fulfillmentCreate.fulfillment');
                    if (JFulfillment.IsObject) then begin
                        FulfillmentId := OrderFulfillments.ImportFulfillment(SalesShipmentHeader."Shpfy Order Id", JFulfillment);
                        if SalesShipmentHeader."Shpfy Fulfillment Id" <> -1 then // partial fulfillment errors
                            SalesShipmentHeader."Shpfy Fulfillment Id" := FulfillmentId;
                    end else begin
                        SkippedRecord.LogSkippedRecord(SalesShipmentHeader."Shpfy Order Id", SalesShipmentHeader.RecordId, NoFulfillmentCreatedInShopifyLbl, Shop);
                        SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
                    end;
                end
            else begin
                SkippedRecord.LogSkippedRecord(SalesShipmentHeader."Shpfy Order Id", SalesShipmentHeader.RecordId, NoCorrespondingFulfillmentLinesLbl, Shop);
                SalesShipmentHeader."Shpfy Fulfillment Id" := -1;
            end;
            SalesShipmentHeader.Modify(true);
        end;
    end;

    internal procedure CreateFulfillmentOrderRequest(SalesShipmentHeader: Record "Sales Shipment Header"; Shop: Record "Shpfy Shop"; LocationId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type") Requests: List of [Text];
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShippingAgent: Record "Shipping Agent";
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
        OrderLine: Record "Shpfy Order Line";
        TempFulfillmentOrderLine: Record "Shpfy FulFillment Order Line" temporary;
        TrackingCompany: Enum "Shpfy Tracking Companies";
        PrevFulfillmentOrderId: BigInteger;
        IsHandled: Boolean;
        TrackingUrl: Text;
        GraphQueryStart: Text;
        GraphQuery: TextBuilder;
        LineCount: Integer;
        GraphQueries: List of [Text];
    begin
        Clear(PrevFulfillmentOrderId);

        SalesShipmentLine.Reset();
        SalesShipmentLine.SetRange("Document No.", SalesShipmentHeader."No.");
        SalesShipmentLine.SetRange(Type, SalesShipmentLine.Type::Item);
        SalesShipmentLine.SetFilter("Shpfy Order Line Id", '<>%1', 0);
        SalesShipmentLine.SetFilter(Quantity, '>%1', 0);
        if SalesShipmentLine.FindSet() then begin
            repeat
                if OrderLine.Get(SalesShipmentHeader."Shpfy Order Id", SalesShipmentLine."Shpfy Order Line Id") then
                    if (OrderLine."Location Id" = LocationId) and (OrderLine."Delivery Method Type" = DeliveryMethodType) then
                        if FindFulfillmentOrderLine(SalesShipmentHeader, SalesShipmentLine, FulfillmentOrderLine) then begin
                            FulfillmentOrderLine."Quantity to Fulfill" += Round(SalesShipmentLine.Quantity, 1, '=');
                            FulfillmentOrderLine."Remaining Quantity" := FulfillmentOrderLine."Remaining Quantity" - Round(SalesShipmentLine.Quantity, 1, '=');
                            FulfillmentOrderLine.Modify();

                            if TempFulfillmentOrderLine.Get(FulfillmentOrderLine."Shopify Fulfillment Order Id", FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id") then begin
                                TempFulfillmentOrderLine."Quantity to Fulfill" += Round(SalesShipmentLine.Quantity, 1, '=');
                                TempFulfillmentOrderLine.Modify();
                            end else begin
                                TempFulfillmentOrderLine := FulfillmentOrderLine;
                                TempFulfillmentOrderLine."Quantity to Fulfill" := Round(SalesShipmentLine.Quantity, 1, '=');
                                TempFulfillmentOrderLine.Insert();
                            end;
                        end;
            until SalesShipmentLine.Next() = 0;

            TempFulfillmentOrderLine.Reset();
            if TempFulfillmentOrderLine.FindSet() then begin
                GraphQuery.Append('{"query": "mutation {fulfillmentCreate( fulfillment: {');
                if GetNotifyCustomer(Shop, SalesShipmentHeader, LocationId) then
                    GraphQuery.Append('notifyCustomer: true, ')
                else
                    GraphQuery.Append('notifyCustomer: false, ');
                if SalesShipmentHeader."Package Tracking No." <> '' then begin
                    GraphQuery.Append('trackingInfo: {');
                    if SalesShipmentHeader."Shipping Agent Code" <> '' then begin
                        GraphQuery.Append('company: \"');
                        if ShippingAgent.Get(SalesShipmentHeader."Shipping Agent Code") then
                            if ShippingAgent."Shpfy Tracking Company" = ShippingAgent."Shpfy Tracking Company"::" " then begin
                                if ShippingAgent.Name = '' then
                                    GraphQuery.Append(ShippingAgent.Code)
                                else
                                    GraphQuery.Append(ShippingAgent.Name)
                            end else
                                GraphQuery.Append(TrackingCompany.Names.Get(TrackingCompany.Ordinals.IndexOf(ShippingAgent."Shpfy Tracking Company".AsInteger())));
                        GraphQuery.Append('\",');
                    end;

                    GraphQuery.Append('number: \"');
                    GraphQuery.Append(SalesShipmentHeader."Package Tracking No.");
                    GraphQuery.Append('\",');
                    ShippingEvents.OnBeforeRetrieveTrackingUrl(SalesShipmentHeader, TrackingUrl, IsHandled);
                    if not IsHandled then
                        if ShippingAgent."Internet Address" <> '' then
                            TrackingUrl := ShippingAgent.GetTrackingInternetAddr(SalesShipmentHeader."Package Tracking No.");

                    if TrackingUrl <> '' then begin
                        GraphQuery.Append('url: \"');
                        GraphQuery.Append(TrackingUrl);
                        GraphQuery.Append('\"');
                    end;

                    GraphQuery.Append('}');
                end;
                GraphQuery.Append('lineItemsByFulfillmentOrder: [');
                GraphQueryStart := GraphQuery.ToText();
                repeat
                    if PrevFulfillmentOrderId <> TempFulfillmentOrderLine."Shopify Fulfillment Order Id" then begin
                        if PrevFulfillmentOrderId <> 0 then
                            GraphQuery.Append(']},');

                        GraphQuery.Append('{');
                        GraphQuery.Append('fulfillmentOrderId: \"gid://shopify/FulfillmentOrder/');
                        GraphQuery.Append(Format(TempFulfillmentOrderLine."Shopify Fulfillment Order Id"));
                        GraphQuery.Append('\",');
                        GraphQuery.Append('fulfillmentOrderLineItems: [');
                        PrevFulfillmentOrderId := TempFulfillmentOrderLine."Shopify Fulfillment Order Id";
                    end else
                        GraphQuery.Append(',');
                    GraphQuery.Append('{');
                    GraphQuery.Append('id: \"gid://shopify/FulfillmentOrderLineItem/');
                    GraphQuery.Append(Format(TempFulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id"));
                    GraphQuery.Append('\",');
                    GraphQuery.Append('quantity: ');
                    GraphQuery.Append(Format(TempFulfillmentOrderLine."Quantity to Fulfill", 0, 9));
                    GraphQuery.Append('}');
                    LineCount += 1;
                    if LineCount = 250 then begin
                        LineCount := 0;
                        GraphQuery.Append(']}]})');
                        GraphQuery.Append('{fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type } fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id isGiftCard }}}}, userErrors {field,message}}}"}');
                        GraphQueries.Add(GraphQuery.ToText());
                        GraphQuery.Clear();
                        GraphQuery.Append(GraphQueryStart);
                        Clear(PrevFulfillmentOrderId);
                    end;
                until TempFulfillmentOrderLine.Next() = 0;
                GraphQuery.Append(']}]})');
                GraphQuery.Append('{fulfillment { legacyResourceId name createdAt updatedAt deliveredAt displayStatus estimatedDeliveryAt status totalQuantity location { legacyResourceId } trackingInfo { number url company } service { serviceName type } fulfillmentLineItems(first: 10) { pageInfo { endCursor hasNextPage } nodes { id quantity originalTotalSet { presentmentMoney { amount } shopMoney { amount }} lineItem { id isGiftCard }}}}, userErrors {field,message}}}"}');
                GraphQueries.Add(GraphQuery.ToText());
            end;
            exit(GraphQueries);
        end;
    end;

    local procedure FindFulfillmentOrderLine(SalesShipmentHeader: Record "Sales Shipment Header"; SalesShipmentLine: Record "Sales Shipment Line"; var FulfillmentOrderLine: Record "Shpfy FulFillment Order Line"): Boolean
    var
        OrderLine: Record "Shpfy Order Line";
    begin
        if OrderLine.Get(SalesShipmentHeader."Shpfy Order Id", SalesShipmentLine."Shpfy Order Line Id") then begin
            FulfillmentOrderLine.Reset();
            FulfillmentOrderLine.SetRange("Shopify Order Id", OrderLine."Shopify Order Id");
            FulfillmentOrderLine.SetRange("Shopify Variant Id", OrderLine."Shopify Variant Id");
            FulfillmentOrderLine.SetRange("Shopify Location Id", OrderLine."Location Id");
            FulfillmentOrderLine.SetRange("Delivery Method Type", OrderLine."Delivery Method Type");
            FulfillmentOrderLine.SetFilter("Remaining Quantity", '>=%1', Round(SalesShipmentLine.Quantity, 1, '='));
            FulfillmentOrderLine.SetFilter("Fulfillment Status", '<>%1', 'CLOSED');
            if FulfillmentOrderLine.FindFirst() then
                exit(true);
        end;
    end;

    local procedure GetNotifyCustomer(Shop: Record "Shpfy Shop"; SalesShipmmentHeader: Record "Sales Shipment Header"; LocationId: BigInteger): Boolean
    var
        IsHandled: Boolean;
        NotifyCustomer: Boolean;
    begin
        ShippingEvents.OnGetNotifyCustomer(SalesShipmmentHeader, LocationId, NotifyCustomer, IsHandled);
        if IsHandled then
            exit(NotifyCustomer)
        else
            exit(Shop."Send Shipping Confirmation");
    end;
}