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
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
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
        ShopifyOrderId := ShippingHelper.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShopifyFulfillmentOrderId := ShippingHelper.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);
        ShippingHelper.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

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
}