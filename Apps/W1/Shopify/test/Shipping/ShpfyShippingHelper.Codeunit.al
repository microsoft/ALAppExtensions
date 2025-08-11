// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.History;
using System.TestLibraries.Utilities;

codeunit 139559 "Shpfy Shipping Helper"
{
    internal procedure CreateRandomShopifyOrder(LocationId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        OrderHeader: Record "Shpfy Order Header";
        OrderLine: Record "Shpfy Order Line";
        Any: Codeunit Any;
    begin
        Any.SetDefaultSeed();
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

    internal procedure CreateOrderLines(ShopifyOrderId: BigInteger; LocationId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type"; NumberOfLines: Integer): BigInteger
    var
        OrderLine: Record "Shpfy Order Line";
        Any: Codeunit Any;
        i: Integer;
    begin
        Any.SetDefaultSeed();
        for i := 1 to NumberOfLines do begin
            Clear(OrderLine);
            OrderLine."Shopify Order Id" := ShopifyOrderId;
            OrderLine."Shopify Product Id" := Any.IntegerInRange(10000, 99999);
            OrderLine."Shopify Variant Id" := Any.IntegerInRange(10000, 99999);
            OrderLine."Line Id" := 100 + i;
            OrderLine.Quantity := Any.IntegerInRange(1, 10);
            OrderLine."Location Id" := LocationId;
            OrderLine."Delivery Method Type" := DeliveryMethodType;
            OrderLine.Insert();
        end;
    end;

    internal procedure CreateShopifyFulfillmentOrder(ShopifyOrderId: BigInteger; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        OrderLine: Record "Shpfy Order Line";
        FulfillmentOrderHeader: Record "Shpfy FulFillment Order Header";
        FulfillmentOrderLine: Record "Shpfy FulFillment Order Line";
        Any: Codeunit Any;
        OrderLineCountLineCount: Integer;
    begin
        Any.SetDefaultSeed();
        Clear(FulfillmentOrderHeader);
        FulfillmentOrderHeader."Shopify Fulfillment Order Id" := Any.IntegerInRange(10000, 99999);
        FulfillmentOrderHeader."Shopify Order Id" := ShopifyOrderId;
        FulfillmentOrderHeader."Delivery Method Type" := FulfillmentOrderHeader."Delivery Method Type"::Shipping;
        FulfillmentOrderHeader.Insert();

        OrderLine.Reset();
        OrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if OrderLine.FindSet() then
            repeat
                OrderLineCountLineCount += 1;
                Clear(FulfillmentOrderLine);
                FulfillmentOrderLine."Shopify Fulfillment Order Id" := FulfillmentOrderHeader."Shopify Fulfillment Order Id";
                FulfillmentOrderLine."Shopify Fulfillm. Ord. Line Id" := 100 + OrderLineCountLineCount;
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

    internal procedure CreateRandomSalesShipment(var SalesShipmentHeader: Record "Sales Shipment Header"; ShopifyOrderId: BigInteger)
    var
        SalesShipmentLine: Record "Sales Shipment Line";
        OrderLine: Record "Shpfy Order Line";
        Any: Codeunit Any;
    begin
        Any.SetDefaultSeed();
        Clear(SalesShipmentHeader);
        SalesShipmentHeader."No." := CopyStr(Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."No.")), 1, MaxStrLen(SalesShipmentHeader."No."));
        SalesShipmentHeader."Shpfy Order Id" := ShopifyOrderId;
        SalesShipmentHeader."Package Tracking No." := CopyStr(Any.AlphanumericText(MaxStrLen(SalesShipmentHeader."Package Tracking No.")), 1, MaxStrLen(SalesShipmentHeader."Package Tracking No."));
        SalesShipmentHeader.Insert();

        OrderLine.Reset();
        OrderLine.SetRange("Shopify Order Id", ShopifyOrderId);
        if OrderLine.FindSet() then
            repeat
                Clear(SalesShipmentLine);
                SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
                SalesShipmentLine."Line No." := OrderLine."Line Id";
                SalesShipmentLine.Type := SalesShipmentLine.type::Item;
                SalesShipmentLine."No." := CopyStr(Any.AlphanumericText(MaxStrLen(SalesShipmentLine."No.")), 1, MaxStrLen(SalesShipmentLine."No."));
                SalesShipmentLine."Shpfy Order Line Id" := OrderLine."Line Id";
                SalesShipmentLine.Quantity := OrderLine.Quantity;
                SalesShipmentLine.Insert();
            until OrderLine.Next() = 0;
    end;
}