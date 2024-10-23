namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Warehouse.Activity;

query 36978 "Warehouse Activity Lines"
{
    Access = Internal;
    Caption = 'Power BI Warehouse Activity Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'warehouseActivityLine';
    EntitySetName = 'warehouseActivityLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(warehouseActivityLine; "Warehouse Activity Line")
        {
            DataItemTableFilter = "Action Type" = filter('Take|Place');
            column(actionType; "Action Type")
            {
            }
            column(assembleToOrder; "Assemble to Order")
            {
            }
            column(atoComponent; "ATO Component")
            {
            }
            column(binCode; "Bin Code")
            {
            }
            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(qtyBase; "Qty. (Base)")
            {
                Method = Sum;
            }
            column(lotNo; "Lot No.")
            {
            }
            column(serialNo; "Serial No.")
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