// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify;

using Microsoft.Sales.History;
using Microsoft.Utilities;
using Microsoft.Sales.Document;

codeunit 30364 "Shpfy Update Sales Invoice"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Page, Page::"Posted Sales Inv. - Update", 'OnAfterRecordChanged', '', false, false)]
    local procedure CheckShopifyOrderIdOnAfterRecordChanged(var SalesInvoiceHeader: Record "Sales Invoice Header"; xSalesInvoiceHeader: Record "Sales Invoice Header"; var IsChanged: Boolean)
    begin
        if IsChanged then
            exit;
        IsChanged := SalesInvoiceHeader."Shpfy Order Id" <> xSalesInvoiceHeader."Shpfy Order Id";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales Inv. Header - Edit", 'OnOnRunOnBeforeTestFieldNo', '', false, false)]
    local procedure SetShopifyOrderIdOnBeforeSalesShptHeaderModify(var SalesInvoiceHeader: Record "Sales Invoice Header"; SalesInvoiceHeaderRec: Record "Sales Invoice Header")
    begin
        SalesInvoiceHeader."Shpfy Order Id" := SalesInvoiceHeaderRec."Shpfy Order Id";
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Copy Document Mgt.", 'OnCopySalesDocOnAfterTransferPostedInvoiceFields', '', false, false)]
    local procedure OnCopySalesDocOnAfterCopySalesDocUpdateHeader(var ToSalesHeader: Record "Sales Header")
    begin
        Clear(ToSalesHeader."Shpfy Order Id");
        Clear(ToSalesHeader."Shpfy Order No.");
        Clear(ToSalesHeader."Shpfy Refund Id");
    end;
}