namespace Microsoft.Purchases.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 37000 "Value Entries - Purch."
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Purchase Value Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'purchaseValueEntry';
    EntitySetName = 'purchaseValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(PurchValueEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = const(Purchase);
            column(itemLedgerEntryNo; "Entry No.")
            {
            }
            dataitem(ValueEntry; "Value Entry")
            {
                DataItemLink = "Item Ledger Entry No." = PurchValueEntry."Entry No.";
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