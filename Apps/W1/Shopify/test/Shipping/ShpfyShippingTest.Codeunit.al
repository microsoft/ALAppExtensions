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
        ShpfyExportShipment: Codeunit "Shpfy Export Shipments";
        JHelper: Codeunit "Shpfy Json Helper";
        JFulFillmentRequest: JsonToken;
        JFulFillment: JsonObject;
        JLineItems: JsonArray;
        JLineItem: JsonToken;
        ShopifyOrderId: BigInteger;
        LocationId: BigInteger;
        LocationCode: Code[10];
    begin
        // [SCENARIO] Export a Sales Shipment record into a Json token that contains the shipping info
        // [GIVEN] A random Sales Shipment, a random LocationId, a random LocationCode
        LocationId := Any.IntegerInRange(10000, 99999);
        LocationCode := Any.AlphanumericText(MaxStrLen(LocationCode));
        ShopifyOrderId := CreateRandomShopifyOrder();
        CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId, LocationCode);

        // [WHEN] Invoke the function CreateFulfillmentRequest()
        JFulFillmentRequest.ReadFrom(ShpfyExportShipment.CreateFulfillmentRequest(SalesShipmentHeader, LocationId, LocationCode));

        // [THEN] We must find the correct fulfilment data in the json token
        JHelper.GetJsonObject(JFulFillmentRequest, JFulFillment, 'fulfillment');
        LibraryAssert.AreEqual(LocationId, JHelper.GetValueAsBigInteger(JFulFillment, 'location_id'), 'location Id check');
        LibraryAssert.AreEqual(SalesShipmentHeader."Package Tracking No.", JHelper.GetValueAsText(JFulFillment, 'tracking_number'), 'tracking number check');

        // [THEN] We must find the fulfilment lines in the json token
        JHelper.GetJsonArray(JFulFillment, JLineItems, 'line_items');
        foreach JLineItem in JLineItems do begin
            SalesShipmentLine.SetRange("Shpfy Order Line Id", JHelper.GetValueAsBigInteger(JLineItem, 'id'));
            SalesShipmentLine.FindFirst();
            LibraryAssert.AreEqual(SalesShipmentLine.Quantity, JHelper.GetValueAsDecimal(JLineItem, 'quantity'), 'quanity check');
        end;
    end;

    local procedure CreateRandomShopifyOrder(): BigInteger;
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
        ShopifyOrderLine: Record "Shpfy Order Line";
    begin
        Clear(ShopifyOrderHeader);
        ShopifyOrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 99999);
        ShopifyOrderHeader.Insert();

        Clear(ShopifyOrderLine);
        ShopifyOrderLine."Shopify Order Id" := ShopifyOrderHeader."Shopify Order Id";
        ShopifyOrderLine."Line Id" := Any.IntegerInRange(10000, 99999);
        ShopifyOrderLine.Insert();

        exit(ShopifyOrderHeader."Shopify Order Id");
    end;

    local procedure CreateRandomSalesShipment(var SalesShipmentHeader: record "Sales Shipment Header"; ShopifyOrderId: BigInteger; LocationCode: Code[10])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShopifyOrderLine: Record "Shpfy Order Line";
    begin
        Clear(SalesShipmentHeader);
        SalesShipmentHeader."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."No."));
        SalesShipmentHeader."Shpfy Order Id" := ShopifyOrderId;
        SalesShipmentHeader."Package Tracking No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."Package Tracking No."));
        SalesShipmentHeader.Insert();

        ShopifyOrderLine.Reset();
        ShopifyOrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if ShopifyOrderLine.FindSet() then
            repeat
                Clear(SalesShipmentLine);
                SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
                SalesShipmentLine.Type := SalesShipmentLine.type::Item;
                SalesShipmentLine."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentLine."No."));
                SalesShipmentLine."Shpfy Order Line Id" := ShopifyOrderLine."Line Id";
                SalesShipmentLine.Quantity := Any.DecimalInRange(10, 0);
                SalesShipmentLine."Location Code" := LocationCode;
                SalesShipmentLine.Insert();
            until ShopifyOrderLine.Next() = 0;
    end;
}