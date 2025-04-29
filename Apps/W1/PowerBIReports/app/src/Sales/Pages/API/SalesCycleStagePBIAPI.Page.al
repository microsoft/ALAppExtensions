namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

page 37082 "Sales Cycle Stage - PBI API"
{
    PageType = API;
    Caption = 'Power BI Sales Cycle Stages';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'salesCycleStage';
    EntitySetName = 'salesCycleStages';
    SourceTable = "Sales Cycle Stage";
    DelayedInsert = true;
    DataAccessIntent = ReadOnly;
    Editable = false;
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field(salesCycleCode; Rec."Sales Cycle Code") { }
                field(salesCycleStage; Rec."Stage") { }
                field(salesCycleStageDescription; Rec."Description") { }
            }
        }
    }
}