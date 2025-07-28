// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.History;

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
        OrderLine: Record "Shpfy Order Line";
        Shop: Record "Shpfy Shop";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
        DeliveryMethodType: Enum "Shpfy Delivery Method Type";
        FulfillmentRequest: Text;
        FulfillmentRequests: List of [Text];
        ShopifyOrderId: BigInteger;
        ShopifyFulfillmentOrderId: BigInteger;
        LocationId: BigInteger;
        QuantityLbl: Label 'quantity: %1', Comment = '%1 - quantity', Locked = true;
    begin
        // [SCENARIO] Export a Sales Shipment record into a Json token that contains the shipping info
        // [GIVEN] A random Sales Shipment, a random LocationId, a random Shop
        LocationId := Any.IntegerInRange(10000, 99999);
        DeliveryMethodType := DeliveryMethodType::Shipping;
        ShopifyOrderId := ShippingHelper.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShopifyFulfillmentOrderId := ShippingHelper.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);
        ShippingHelper.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke the function CreateFulfillmentRequest()
        FulfillmentRequests := ExportShipments.CreateFulfillmentOrderRequest(SalesShipmentHeader, Shop, LocationId, DeliveryMethodType);

        // [THEN] We must find the correct fulfilment data in the json token
        LibraryAssert.AreEqual(1, FulfillmentRequests.Count, 'FulfillmentRequest count check');
        FulfillmentRequests.Get(1, FulfillmentRequest);
        LibraryAssert.IsTrue(FulfillmentRequest.Contains(Format(ShopifyFulfillmentOrderId)), 'Fulfillmentorder Id Check');
        LibraryAssert.IsTrue(FulfillmentRequest.Contains(SalesShipmentHeader."Package Tracking No."), 'tracking number check');

        // [THEN] We must find the fulfilment lines in the json token
        OrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        OrderLine.FindFirst();
#pragma warning disable AA0210
        SalesShipmentLine.SetRange("Shpfy Order Line Id", OrderLine."Line Id");
#pragma warning restore AA0210
        SalesShipmentLine.FindFirst();
        LibraryAssert.IsTrue(FulfillmentRequest.Contains(StrSubstNo(QuantityLbl, SalesShipmentLine.Quantity)), 'quantity check');
    end;

    [Test]
    procedure UnitTestExportShipment250Lines()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        Shop: Record "Shpfy Shop";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
        DeliveryMethodType: Enum "Shpfy Delivery Method Type";
        FulfillmentRequest: Text;
        FulfillmentRequests: List of [Text];
        ShopifyOrderId: BigInteger;
        ShopifyFulfillmentOrderId: BigInteger;
        LocationId: BigInteger;
    begin
        // [SCENARIO] Export a Sales Shipment with more than 250 lines creates two fulfillment requests
        // [GIVEN] A random Sales Shipment, a random LocationId, a random Shop
        LocationId := Any.IntegerInRange(10000, 99999);
        DeliveryMethodType := DeliveryMethodType::Shipping;
        ShopifyOrderId := ShippingHelper.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShippingHelper.CreateOrderLines(ShopifyOrderId, LocationId, DeliveryMethodType, 300);
        ShopifyFulfillmentOrderId := ShippingHelper.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);
        ShippingHelper.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke the function CreateFulfillmentRequest()
        FulfillmentRequests := ExportShipments.CreateFulfillmentOrderRequest(SalesShipmentHeader, Shop, LocationId, DeliveryMethodType);

        // [THEN] We must find the correct fulfilment data in the json token
        LibraryAssert.AreEqual(2, FulfillmentRequests.Count(), 'FulfillmentRequest count check');
        foreach FulfillmentRequest in FulfillmentRequests do begin
            LibraryAssert.IsTrue(FulfillmentRequest.Contains(Format(ShopifyFulfillmentOrderId)), 'Fulfillmentorder Id Check');
            LibraryAssert.IsTrue(FulfillmentRequest.Contains(SalesShipmentHeader."Package Tracking No."), 'tracking number check');
        end;
    end;
}