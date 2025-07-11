namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Manufacturing.Document;

query 36972 "Prod. Order Lines - Invt."
{
    Access = Internal;
    Caption = 'Power BI Qty. on Production Orders';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'inventoryProdOrderLine';
    EntitySetName = 'inventoryProdOrderLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(prodOrderLine; "Prod. Order Line")
        {
            DataItemTableFilter = Status = filter(Planned .. Released);
            column(status; Status)
            {
            }
            column(documentNo; "Prod. Order No.")
            {
            }

            column(itemNo; "Item No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(remainingQtyBase; "Remaining Qty. (Base)")
            {
                Method = Sum;
            }
            column(dueDate; "Due Date")
            {
            }
            column(startingDate; "Starting Date")
            {
            }
            column(dimensionSetID; "Dimension Set ID")
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