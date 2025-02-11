namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Inventory.Ledger;

query 37011 "Manuf. Value Entries - PBI API"
{
    Access = Internal;
    Caption = 'Power BI Manufacturing Value Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'manufacturingValueEntry';
    EntitySetName = 'manufacturingValueEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(valueEntry; "Value Entry")
        {
            DataItemTableFilter = "Item No." = filter(<> ''), "Item Ledger Entry Type" = filter(Consumption | Output);

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
            column(costPerUnit; "Cost per Unit")
            {
            }
            column(itemLedgerEntryQuantity; "Item Ledger Entry Quantity")
            {
            }
            column(valuedQuantity; "Valued Quantity")
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
            column(type; Type)
            {
            }
            column(no; "No.")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
        }
    }
}