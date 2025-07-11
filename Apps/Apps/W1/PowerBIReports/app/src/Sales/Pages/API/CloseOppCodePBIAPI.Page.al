namespace Microsoft.Sales.PowerBIReports;

using Microsoft.CRM.Opportunity;

page 37083 "Close Opp. Code - PBI API"
{
    PageType = API;
    Caption = 'Power BI Close Opportunity Codes';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'closeOpportunityCode';
    EntitySetName = 'closeOpportunityCodes';
    SourceTable = "Close Opportunity Code";
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
                field(closeOpportunityCode; Rec.Code) { }
                field(closeOpportunityType; Rec."Type") { }
                field(closeOpportunityDescription; Rec."Description") { }
            }
        }
    }
}