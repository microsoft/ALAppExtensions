namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Service.Document;

query 36976 "Service Lines - Order"
{
    Access = Internal;
    Caption = 'Power BI Qty. on Service Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'orderServiceLine';
    EntitySetName = 'orderServiceLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(serviceLine; "Service Line")
        {
            DataItemTableFilter = "Document Type" = const(Order), Type = const(Item);

            column(documentNo; "Document No.")
            {
            }

            column(itemNo; "No.")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(outstandingQtyBase; "Outstanding Qty. (Base)")
            {
                Method = Sum;
            }
            column(neededByDate; "Needed by Date")
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