namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Manufacturing.Document;

query 36971 "Prod. Order Comp. - Invt."
{
    Access = Internal;
    Caption = 'Power BI Qty. on Component Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'inventoryProdOrderComponentLine';
    EntitySetName = 'inventoryProdOrderComponentLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(prodOrderComponent; "Prod. Order Component")
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