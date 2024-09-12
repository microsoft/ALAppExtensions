namespace Microsoft.Manufacturing.PowerBIReports;

using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;

query 36986 "Item Ledger Entries - Prod."
{
    Access = Internal;
    Caption = 'Power BI Prod. Item Ledger Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'prodItemLedgerEntry';
    EntitySetName = 'prodItemLedgerEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemLedgerEntry; "Item Ledger Entry")
        {
            DataItemTableFilter = "Entry Type" = filter(Output | Consumption);
            column(entryType; "Entry Type")
            {
            }
            column(orderType; "Order Type")
            {
            }
            column(orderNo; "Order No.")
            {
            }
            column(orderLineNo; "Order Line No.")
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
            column(lotNo; "Lot No.")
            {
            }
            column(quantity; Quantity)
            {
                Method = Sum;
            }
            column(costAmountActual; "Cost Amount (Actual)")
            {
                Method = Sum;
            }
            column(dimensionSetID; "Dimension Set ID")
            {
            }
            dataitem(Location; Location)
            {
                DataItemLink = Code = ItemLedgerEntry."Location Code";
                column(Location_Name; Name)
                {
                }
            }
        }
    }

    trigger OnBeforeOpen()
    var
        PBIMgt: Codeunit "Manuf. Filter Helper";
        DateFilterText: Text;
    begin
        DateFilterText := PBIMgt.GenerateManufacturingReportDateFilter();
        if DateFilterText <> '' then
            CurrQuery.SetFilter(postingDate, DateFilterText);
    end;
}