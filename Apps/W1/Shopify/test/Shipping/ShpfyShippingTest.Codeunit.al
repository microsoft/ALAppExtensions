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
        ShpfyExportShipments: Codeunit "Shpfy Export Shipments";
        ShpfyJsonHelper: Codeunit "Shpfy Json Helper";
        FulfillmentRequest: Text;
        JFulfillment: JsonObject;
        JLineItems: JsonArray;
        JLineItem: JsonToken;
        ShopifyOrderId: BigInteger;
        LocationId: BigInteger;
        LocationCode: Code[10];
        GidLocationLbl: Label 'gid://shopify/Location/%1', Locked = true, Comment = '%1 = Location Id';
    begin
        // [SCENARIO] Export a Sales Shipment record into a Json token that contains the shipping info
        // [GIVEN] A random Sales Shipment, a random LocationId, a random LocationCode
        LocationId := Any.IntegerInRange(10000, 99999);
        LocationCode := Any.AlphanumericText(MaxStrLen(LocationCode));
        ShopifyOrderId := CreateRandomShopifyOrder();
        CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId, LocationCode);

        // [WHEN] Invoke the function CreateFulfillmentRequest()
        FulfillmentRequest := ShpfyExportShipments.CreateFulfillmentRequest(SalesShipmentHeader, LocationId, LocationCode);

        // [THEN] We must find the correct fulfilment data in the json token
        LibraryAssert.IsTrue(FulFillmentRequest.Contains(StrSubstNo(GidLocationLbl, LocationId)), 'location Id check');
        LibraryAssert.IsTrue(FulFillmentRequest.Contains(SalesShipmentHeader."Package Tracking No."), 'tracking number check');

        // [THEN] We must find the fulfilment lines in the json token
        ShpfyJsonHelper.GetJsonArray(JFulfillment, JLineItems, 'line_items');
        foreach JLineItem in JLineItems do begin
            SalesShipmentLine.SetRange("Shpfy Order Line Id", ShpfyJsonHelper.GetValueAsBigInteger(JLineItem, 'id'));
            SalesShipmentLine.FindFirst();
            LibraryAssert.AreEqual(SalesShipmentLine.Quantity, ShpfyJsonHelper.GetValueAsDecimal(JLineItem, 'quantity'), 'quanity check');
        end;
    end;

    local procedure CreateRandomShopifyOrder(): BigInteger;
    var
        ShpfyOrderHeader: Record "Shpfy Order Header";
        ShpfyOrderLine: Record "Shpfy Order Line";
    begin
        Clear(ShpfyOrderHeader);
        ShpfyOrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 99999);
        ShpfyOrderHeader.Insert();

        Clear(ShpfyOrderLine);
        ShpfyOrderLine."Shopify Order Id" := ShpfyOrderHeader."Shopify Order Id";
        ShpfyOrderLine."Line Id" := Any.IntegerInRange(10000, 99999);
        ShpfyOrderLine.Insert();

        exit(ShpfyOrderHeader."Shopify Order Id");
    end;

    local procedure CreateRandomSalesShipment(var SalesShipmentHeader: record "Sales Shipment Header"; ShopifyOrderId: BigInteger; LocationCode: Code[10])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        ShpfyOrderLine: Record "Shpfy Order Line";
    begin
        Clear(SalesShipmentHeader);
        SalesShipmentHeader."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."No."));
        SalesShipmentHeader."Shpfy Order Id" := ShopifyOrderId;
        SalesShipmentHeader."Package Tracking No." := Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."Package Tracking No."));
        SalesShipmentHeader.Insert();

        ShpfyOrderLine.Reset();
        ShpfyOrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if ShpfyOrderLine.FindSet() then
            repeat
                Clear(SalesShipmentLine);
                SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
                SalesShipmentLine.Type := SalesShipmentLine.type::Item;
                SalesShipmentLine."No." := Any.AlphanumericText(MaxStrLen(SalesShipmentLine."No."));
                SalesShipmentLine."Shpfy Order Line Id" := ShpfyOrderLine."Line Id";
                SalesShipmentLine.Quantity := Any.DecimalInRange(10, 0);
                SalesShipmentLine."Location Code" := LocationCode;
                SalesShipmentLine.Insert();
            until ShpfyOrderLine.Next() = 0;
    end;
}