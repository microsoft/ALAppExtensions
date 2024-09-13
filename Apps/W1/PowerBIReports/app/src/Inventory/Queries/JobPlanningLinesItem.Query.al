namespace Microsoft.Inventory.PowerBIReports;

using Microsoft.Projects.Project.Planning;

query 36969 "Job Planning Lines - Item"
{
    Access = Internal;
    Caption = 'Power BI Job Planning Lines';
    QueryType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemJobPlanningLine';
    EntitySetName = 'itemJobPlanningLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(jobPlanningLine; "Job Planning Line")
        {

            DataItemTableFilter = Type = const(Item), Status = const(Order);
            column(itemNo; "No.")
            {
            }
            column(remainingQtyBase; "Remaining Qty. (Base)")
            {
                Method = Sum;
            }
            column(planningDate; "Planning Date")
            {
            }
            column(locationCode; "Location Code")
            {
            }
            column(documentNo; "Document No.")
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