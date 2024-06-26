namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;

codeunit 30314 "Shpfy Update Sales Invoice"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Inv. - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure OnAfterRecordChanged(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var IsChanged: Boolean)
    begin
        if IsChanged then
            exit;
        IsChanged := SalesInvoiceHeader."Shpfy Order Id" <> xSalesInvoiceHeader."Shpfy Order Id";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", 'OnOnRunOnBeforeTestFieldNo', '', false, false)]
    local procedure OnBeforeSalesShptHeaderModify(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."Shpfy Order Id" := SalesInvoiceHeaderRec."Shpfy Order Id";
    end;
}