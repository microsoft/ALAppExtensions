// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 37023 "Purch. Value Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Purchase Value Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v1.0';
    EntityName = 'purchaseValueEntry';
    EntitySetName = 'purchaseValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PurchaseValueEntry; "Value Entry")
        {
            DataItemTableFilter = "Source Type" = filter(Vendor);

            column(entryNo; "Entry No.")
            {
            }
            column(entryType; "Entry Type")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(vendorNo; "Source No.")
            {
            }
            column(postingDate; "Posting Date")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(invoicedQuantity; "Invoiced Quantity")
            {
            }
            column(costAmountActual; "Cost Amount (Actual)")
            {
            }
            column(salespersonPurchaserCode; "Salespers./Purch. Code")
            {
            }
            column(returnReasonCode; "Return Reason Code")
            {
            }
            column(projectNo; "Job No.")
            {
            }
            column(adjustment; Adjustment)
            {
            }
            column(capacityLedgerEntryNo; "Capacity Ledger Entry No.")
            {
            }
            column(discountAmount; "Discount Amount")
            {
            }
            dataitem(ItemLedgerEntry; "Item Ledger Entry")
            {
                DataItemLink = "Entry No." = PurchaseValueEntry."Item Ledger Entry No.";
                column(itemLedgerEntryNo; "Entry No.")
                {
                }
                column(itemLedgerEntryType; "Entry Type")
                {
                }
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