namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Journal;

query 36981 "Whse. Journal Lines - To Bin"
{
    Access = Internal;
    Caption = 'Power BI To Bin Warehouse Journal Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'toBinWarehouseJournalLine';
    EntitySetName = 'toBinWarehouseJournalLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(warehouseJournalLine; "Warehouse Journal Line")
        {

            column(toBinCode; "To Bin Code")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(qtyBase; "Qty. (Absolute, Base)")
            {
                Method = Sum;
            }
            column(lotNo; "Lot No.")
            {
            }
            column(serialNo; "Serial No.")
            {
            }
            column(toZoneCode; "To Zone Code")
            {
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