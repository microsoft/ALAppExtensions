namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

/// <summary>
/// Report Shpfy Sync Shipm. to Shopify (ID 30109).
/// </summary>
report 30109 "Shpfy Sync Shipm. to Shopify"
{
    ApplicationArea = All;
    Caption = 'Sync Shipments To Shopify';
    ProcessingOnly = true;
    UsageCategory = Tasks;
    Permissions = tabledata "Sales Shipment Line" = r,
                  tabledata "Sales Shipment Header" = m;

    dataset
    {
        dataitem("Sales Shipment Header"; "Sales Shipment Header")
        {
            RequestFilterFields = "No.", "Posting Date";

            trigger OnPreDataItem();
            begin
                SetFilter("Shpfy Order Id", '<>%1', 0);
                SetRange("Shpfy Fulfillment Id", 0);
            end;

            trigger OnAfterGetRecord();
            var
                ShopifyOrderHeader: Record "Shpfy Order Header";
                ShipmentLine: Record "Sales Shipment Line";
                Shop: Record "Shpfy Shop";
            begin
                ShipmentLine.SetRange("Document No.", "No.");
                ShipmentLine.SetRange(Type, ShipmentLine.Type::"Item");
                ShipmentLine.SetFilter(Quantity, '>0');
                if ShipmentLine.IsEmpty() then begin
                    "Shpfy Fulfillment Id" := -2;
                    Modify();
                end else
                    if ShopifyOrderHeader.Get("Sales Shipment Header"."Shpfy Order Id") then begin
                        Shop.Get(ShopifyOrderHeader."Shop Code");
                        FulfillmentOrdersAPI.GetShopifyFulfillmentOrdersFromShopifyOrder(Shop, "Sales Shipment Header"."Shpfy Order Id");
                        ExportShipments.CreateShopifyFulfillment("Sales Shipment Header");
                    end;
            end;
        }
    }

    var
        ExportShipments: Codeunit "Shpfy Export Shipments";
        FulfillmentOrdersAPI: Codeunit "Shpfy Fulfillment Orders API";
}