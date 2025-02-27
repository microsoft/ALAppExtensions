namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

query 37018 "Opportunity Entries - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Opportunity Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'opportunityEntry';
    EntitySetName = 'opportunityEntries';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(opportunityEntry; "Opportunity Entry")
        {
            column(opportunityEntryEntryNo; "Entry No.") { }
            column(opportunityEntryOpportunity; "Opportunity No.") { }
            column(salespersonCode; "Salesperson Code") { }
            column(opportunityEntryActive; Active) { }
            column(opportunityEntryActionTaken; "Action Taken") { }
            column(opportunityEntryDateChange; "Date of Change") { }
            column(opportunityEntryEstCloseDate; "Estimated Close Date") { }
            column(opportunityEntryEstValue; "Estimated Value (LCY)") { }
            column(opportunityEntryCalcCurrentValue; "Calcd. Current Value (LCY)") { }
            column(opportunityEntryCompleted; "Completed %") { }
            column(opportunityEntryChanceSuccess; "Chances of Success %") { }
            column(opportunityEntryProbability; "Probability %") { }
            column(opportunityEntrySalesCycleCode; "Sales Cycle Code") { }
            column(opportunityEntrySalesCycleStage; "Sales Cycle Stage") { }
            column(opportunityEntrySalesCycleStageDescription; "Sales Cycle Stage Description") { }
            column(opportunityContactNo; "Contact No.") { }

        }
    }
}