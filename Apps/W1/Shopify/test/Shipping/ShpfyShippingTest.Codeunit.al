codeunit 139606 "Shpfy Shipping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestExportShipment()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SalesShipmentLine: Record "Sales Shipment Line";
        Shop: Record "Shpfy Shop";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        JsonHelper: Codeunit "Shpfy Json Helper";
        DeliveryMethodType: Enum "Shpfy Delivery Method Type";
        FulfillmentRequest: Text;
        JFulfillment: JsonObject;
        JLineItems: JsonArray;
        JLineItem: JsonToken;
        ShopifyOrderId: BigInteger;
        ShopifyFulfillmentOrderId: BigInteger;
        LocationId: BigInteger;
    begin
        // [SCENARIO] Export a Sales Shipment record into a Json token that contains the shipping info
        // [GIVEN] A random Sales Shipment, a random LocationId, a random Shop
        Shop.Init();
        LocationId := Any.IntegerInRange(10000, 99999);
        DeliveryMethodType := DeliveryMethodType::Shipping;
        ShopifyOrderId := CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShopifyFulfillmentOrderId := CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);
        CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke the function CreateFulfillmentRequest()
        FulfillmentRequest := ExportShipments.CreateFulfillmentOrderRequest(SalesShipmentHeader, Shop, LocationId, DeliveryMethodType);

        // [THEN] We must find the correct fulfilment data in the json token
        LibraryAssert.IsTrue(FulfillmentRequest.Contains(Format(ShopifyFulfillmentOrderId)), 'Fulfillmentorder Id Check');
        LibraryAssert.IsTrue(FulFillmentRequest.Contains(SalesShipmentHeader."Package Tracking No."), 'tracking number check');

        // [THEN] We must find the fulfilment lines in the json token
        JsonHelper.GetJsonArray(JFulfillment, JLineItems, 'line_items');
        foreach JLineItem in JLineItems do begin
            SalesShipmentLine.SetRange("Shpfy Order Line Id", JsonHelper.GetValueAsBigInteger(JLineItem, 'id'));
            SalesShipmentLine.FindFirst();
            LibraryAssert.AreEqual(SalesShipmentLine.Quantity, JsonHelper.GetValueAsDecimal(JLineItem, 'quantity'), 'quanity check');
        end;
    end;

    local procedure CreateRandomShopifyOrder(LocationId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        OrderHeader: Record "Shpfy Order Header";
        OrderLine: Record "Shpfy Order Line";
    begin
        Clear(OrderHeader);
        OrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 99999);
        OrderHeader.Insert();

        Clear(OrderLine);
        OrderLine."Shopify Order Id" := OrderHeader."Shopify Order Id";
        OrderLine."Shopify Product Id" := Any.IntegerInRange(10000, 99999);
        OrderLine."Shopify Variant Id" := Any.IntegerInRange(10000, 99999);
        OrderLine."Line Id" := Any.IntegerInRange(10000, 99999);
        OrderLine.Quantity := Any.IntegerInRange(1, 10);
        OrderLine."Location Id" := LocationId;
        OrderLine."Delivery Method Type" := DeliveryMethodType;
        OrderLine.Insert();

        exit(OrderHeader."Shopify Order Id");
    end;

    local procedure CreateShopifyFulfillmentOrder(ShopifyOrderId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        OrderLine: Record "Shpfy Order Line";
        FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header";
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
    begin
        Clear(FulfillmentOrderHeader);
        FulfillmentOrderHeader."Shopify Fulfillment Order Id" := Any.IntegerInRange(10000, 99999);
        FulfillmentOrderHeader."Shopify Order Id" := ShopifyOrderId;
        FulfillmentOrderHeader."Delivery Method Type" := FulfillmentOrderHeader."Delivery Method Type"::Shipping;
        FulfillmentOrderHeader.Insert();

        OrderLine.Reset();
        OrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if OrderLine.FindSet() then
            repeat
                Clear(FulfillmentOrderLine);
                FulfillmentOrderLine."Shopify Fulfillment Order Id" := FulfillmentOrderHeader."Shopify Fulfillment Order Id";
                FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id" := Any.IntegerInRange(10000, 99999);
                FulfillmentOrderLine."Shopify Order Id" := FulfillmentOrderHeader."Shopify Order Id";
                FulfillmentOrderLine."Shopify Product Id" := OrderLine."Shopify Product Id";
                FulfillmentOrderLine."Shopify Variant Id" := OrderLine."Shopify Variant Id";
                FulfillmentOrderLine."Remaining Quantity" := OrderLine.Quantity;
                FulfillmentOrderLine."Shopify Location Id" := OrderLine."Location Id";
                FulfillmentOrderLine."Delivery Method Type" := DeliveryMethodType;
                FulfillmentOrderLine.Insert();
            until OrderLine.Next() = 0;

        exit(FulfillmentOrderHeader."Shopify Fulfillment Order Id");
    end;

    local procedure CreateRandomSalesShipment(var SalesShipmentHeader: Record "Sales Shipment Header"; ShopifyOrderId: BigInteger)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        OrderLine: Record "Shpfy Order Line";
    begin
        Clear(SalesShipmentHeader);
        SalesShipmentHeader."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."No."));
        SalesShipmentHeader."Shpfy Order Id" := ShopifyOrderId;
        SalesShipmentHeader."Package Tracking No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."Package Tracking No."));
        SalesShipmentHeader.Insert();

        OrderLine.Reset();
        OrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if OrderLine.FindSet() then
            repeat
                Clear(SalesShipmentLine);
                SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
                SalesShipmentLine.Type := SalesShipmentLine.type::Item;
                SalesShipmentLine."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentLine."No."));
                SalesShipmentLine."Shpfy Order Line Id" := OrderLine."Line Id";
                SalesShipmentLine.Quantity := OrderLine.Quantity;
                SalesShipmentLine.Insert();
            until OrderLine.Next() = 0;
    end;
}