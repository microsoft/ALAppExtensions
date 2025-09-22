// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Purchases.History;

query 37107 "Purchase Invoice Lines"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Purchase Invoice Lines';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'purchaseInvoiceLine';
    EntitySetName = 'purchaseInvoiceLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PurchaseInvoiceLine; "Purch. Inv. Line")
        {
            DataItemTableFilter = Type = filter("G/L Account" | "Resource");
            column(postingDate; "Posting Date") { }
            column(type; Type) { }
            column(description; Description) { }
            column(documentNo; "Document No.") { }
            column(lineNo; "Line No.") { }
            column(no; "No.") { }
            column(locationCode; "Location Code") { }
            column(quantityBase; "Quantity (Base)") { }
            column(amount; Amount) { }
            column(unitCostLCY; "Unit Cost (LCY)") { }
            column(returnReasonCode; "Return Reason Code") { }
            column(expectedReceiptDate; "Expected Receipt Date") { }
            column(dimensionSetID; "Dimension Set ID") { }
            column(projectNo; "Job No.") { }
            column(payToVendorNo; "Pay-to Vendor No.") { }
            column(buyFromVendorNo; "Buy-from Vendor No.") { }
            dataitem(PurchaseInvoiceHeader; "Purch. Inv. Header")
            {
                DataItemLink = "No." = PurchaseInvoiceLine."Document No.";
                column(purchaseInvoiceDocumentNo; "No.") { }
                column(campaignNo; "Campaign No.") { }
                column(purchaserCode; "Purchaser Code") { }
                column(quoteNo; "Quote No.") { }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Purchases Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemPurchasesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}