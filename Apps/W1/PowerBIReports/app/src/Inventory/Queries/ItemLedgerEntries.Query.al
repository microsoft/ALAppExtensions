namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 36968 "Item Ledger Entries"
{
    Access = Internal;
    Caption = 'Power BI Item Ledger Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemLedgerEntry';
    EntitySetName = 'itemLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(itemLedgerEntry; "Item Ledger Entry")
        {
            column(entryNo; "Entry No.")
            {
            }
            column(entryType; "Entry Type")
            {
            }
            column(sourceType; "Source Type")
            {
            }
            column(sourceNo; "Source No.")
            {
            }
            column(documentNo; "Document No.")
            {
            }
            column(documentType; "Document Type")
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
            column(serialNo; "Serial No.")
            {
            }
            column(expirationDate; "Expiration Date")
            {
            }
            column(lotNo; "Lot No.")
            {
            }
            column(quantity; Quantity)
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
            column(remainingQuantity; "Remaining Quantity")
            {
            }
            column(costAmountActual; "Cost Amount (Actual)")
            {
            }
            column(salesAmountActual; "Sales Amount (Actual)")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            column(open; Open)
            {
            }
            column(positive; Positive)
            {
            }
            column(invoicedQuantity; "Invoiced Quantity")
            {
            }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure")
            {
            }
        }
    }
}