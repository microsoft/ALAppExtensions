namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

codeunit 30279 "Shpfy Update Sales Shipment"
{
    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Shipment - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure OnAfterRecordChanged(var SalesShipmentHeader: Record "Sales Shipment Header"; xSalesShipmentHeader: Record "Sales Shipment Header"; var IsChanged: Boolean)
    begin
        if IsChanged then
            exit;
        IsChanged := SalesShipmentHeader."Shpfy Fulfillment Id" <> xSalesShipmentHeader."Shpfy Fulfillment Id";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shipment Header - Edit", 'OnBeforeSalesShptHeaderModify', '', false, false)]
    local procedure OnBeforeSalesShptHeaderModify(var SalesShptHeader: Record "Sales Shipment Header"; FromSalesShptHeader: Record "Sales Shipment Header")
    begin
        SalesShptHeader."Shpfy Fulfillment Id" := FromSalesShptHeader."Shpfy Fulfillment Id";
    end;
}