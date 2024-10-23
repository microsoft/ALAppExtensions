namespace Microsoft.Projects.PowerBIReports;

using Microsoft.Projects.Project.Planning;

query 36993 "Job Planning Lines"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Job Planning Line';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'jobPlanningLine';
    EntitySetName = 'jobPlanningLines';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(jobPlanningLine; "Job Planning Line")
        {
            column(jobNo; "Job No.")
            {
            }
            column(jobTaskNo; "Job Task No.")
            {
            }
            column(lineNo; "Line No.")
            {
            }
            column(jobType; Type)
            {
            }
            column(lineType; "Line Type")
            {
            }
            column(no; "No.")
            {
            }
            column(description; Description)
            {
            }
            column(quantity; Quantity)
            {
            }
            column(unitCostLCY; "Unit Cost (LCY)")
            {
            }
            column(totalCostLCY; "Total Cost (LCY)")
            {
            }
            column(unitPriceLCY; "Unit Price (LCY)")
            {
            }
            column(lineAmountLCY; "Line Amount (LCY)")
            {
            }
            column(totalPriceLCY; "Total Price (LCY)")
            {
            }
        }
    }
}
