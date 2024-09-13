namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 36967 "Value Entries - Item"
{
    Access = Internal;
    Caption = 'Power BI Inventory Value';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemValueEntry';
    EntitySetName = 'itemValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(valueEntry; "Value Entry")
        {
            DataItemTableFilter = "Item No." = filter(<> '');

            column(entryNo; "Entry No.")
            {
            }
            column(valuationDate; "Valuation Date")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(costAmountActual; "Cost Amount (Actual)")
            {
            }
            column(costAmountExpected; "Cost Amount (Expected)")
            {
            }
            column(costPostedToGL; "Cost Posted to G/L")
            {
            }
            column(invoicedQuantity; "Invoiced Quantity")
            {
            }
            column(expectedCostPostedToGL; "Expected Cost Posted to G/L")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(itemLedgerEntryType; "Item Ledger Entry Type")
            {
            }
            column(postingDate; "Posting Date")
            {
            }
            column(documentType; "Document Type")
            {
            }
            column(type; Type)
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
        }
    }
}