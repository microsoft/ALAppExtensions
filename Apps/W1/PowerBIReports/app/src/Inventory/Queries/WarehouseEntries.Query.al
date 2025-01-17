namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Ledger;

query 36979 "Warehouse Entries"
{
    Access = Internal;
    Caption = 'Power BI Warehouse Entries';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'warehouseEntry';
    EntitySetName = 'warehouseEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(warehouseEntry; "Warehouse Entry")
        {
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(lotNo; "Lot No.")
            {
            }
            column(serialNo; "Serial No.")
            {
            }
            column(zoneCode; "Zone Code")
            {
            }
            column(binCode; "Bin Code")
            {
            }
            column(qtyBase; "Qty. (Base)")
            {
                Method = Sum;
            }
            column(qtyPerUnitOfMeasure; "Qty. per Unit of Measure")
            {
            }
            column(unitOfMeasureCode; "Unit of Measure Code")
            {
            }
        }
    }
}