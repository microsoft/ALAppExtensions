// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 37025 "Sales Value Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sales Value Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v1.0';
    EntityName = 'salesValueEntry';
    EntitySetName = 'salesValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Source Type" = filter(Customer);
            column(itemLedgerEntryNo; "Entry No.") { }
            column(itemLedgerEntryType; "Entry Type") { }
            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = ItemLedgerEntry."Entry No.";
                column(entryNo; "Entry No.") { }
                column(entryType; "Entry Type") { }
                column(documentNo; "Document No.") { }
                column(documentType; "Document Type") { }
                column(invoicedQuantity; "Invoiced Quantity") { }
                column(salesAmountActual; "Sales Amount (Actual)") { }
                column(costAmountActual; "Cost Amount (Actual)") { }
                column(costAmountNonInvtbl; "Cost Amount (Non-Invtbl.)") { }
                column(costPostedToGL; "Cost Posted to G/L") { }
                column(customerNo; "Source No.") { }
                column(postingDate; "Posting Date") { }
                column(documentDate; "Document Date") { }
                column(itemNo; "Item No.") { }
                column(locationCode; "Location Code") { }
                column(dimensionSetID; "Dimension Set ID") { }
                column(salespersonPurchaserCode; "Salespers./Purch. Code") { }
                column(returnReasonCode; "Return Reason Code") { }
                column(projectNo; "Job No.") { }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Sales Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateItemSalesReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}