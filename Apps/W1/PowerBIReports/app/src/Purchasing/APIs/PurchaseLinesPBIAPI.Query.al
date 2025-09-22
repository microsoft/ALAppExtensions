// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Purchases.Document;

query 37073 "Purchase Lines - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Purchase Lines';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'purchaseLine';
    EntitySetName = 'purchaseLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(purchaseHeader; "Purchase Header")
        {
            column(orderNo; "No.") { }
            column(documentType; "Document Type") { }
            column(payToVendorNo; "Pay-to Vendor No.") { }
            column(buyFromVendorNo; "Buy-from Vendor No.") { }
            column(purchaserCode; "Purchaser Code") { }
            column(quoteNo; "Quote No.") { }
            column(orderDate; "Order Date") { }
            column(documentDate; "Document Date") { }
            column(dueDate; "Due Date") { }
            column(campaignNo; "Campaign No.") { }
            dataitem(purchaseLine; "Purchase Line")
            {
                DataItemTableFilter = Type = filter("Item" | "G/L Account" | "Resource");
                DataItemLink = "Document Type" = purchaseHeader."Document Type", "Document No." = purchaseHeader."No.";
                column(purchaseLineDocumentType; "Document Type") { }
                column(documentNo; "Document No.") { }
                column(type; Type) { }
                column(description; Description) { }
                column(lineNo; "Line No.") { }
                column(itemNo; "No.") { }
                column(locationCode; "Location Code") { }
                column(quantityBase; "Quantity (Base)") { }
                column(outstandingQtyBase; "Outstanding Qty. (Base)") { }
                column(outstandingAmountLCY; "Outstanding Amount (LCY)") { }
                column(amount; Amount) { }
                column(unitCostLCY; "Unit Cost (LCY)") { }
                column(outstandingQuantity; "Outstanding Quantity") { }
                column(returnReasonCode; "Return Reason Code") { }
                column(plannedReceiptDate; "Planned Receipt Date") { }
                column(expectedReceiptDate; "Expected Receipt Date") { }
                column(promisedReceiptDate; "Promised Receipt Date") { }
                column(requestedReceiptDate; "Requested Receipt Date") { }
                column(dimensionSetID; "Dimension Set ID") { }
                column(qtyRcdNotInvd; "Qty. Rcd. Not Invoiced") { }
                column(qtyRcdNotInvdBase; "Qty. Rcd. Not Invoiced (Base)") { }
                column(qtyToReceive; "Qty. to Receive") { }
                column(qtyToReceiveBase; "Qty. to Receive (Base)") { }
                column(amtRcdNotInvdExVATLCY; "A. Rcd. Not Inv. Ex. VAT (LCY)") { }
                column(amtRcdNotInvd; "Amt. Rcd. Not Invoiced") { }
                column(amtRcdNotInvdLCY; "Amt. Rcd. Not Invoiced (LCY)") { }
                column(qtyReceived; "Quantity Received") { }
                column(qtyReceivedBase; "Qty. Received (Base)") { }
                column(quantityInvoiced; "Quantity Invoiced") { }
                column(projectNo; "Job No.") { }
                column(prepmtAmountInvLCY; "Prepmt. Amount Inv. (LCY)") { }
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
            CurrQuery.SetFilter(orderDate, DateFilterText);
    end;
}