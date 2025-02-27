namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Account;

query 37068 "Sust Account Cat - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiSustainabilityAccountCategory';
    EntitySetName = 'pbiSustainabilityAccountCategories';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SustainabilityAccountCat; "Sustain. Account Category")
        {
            column(code; Code) { }
            column(description; Description) { }
            column(emissionScope; "Emission Scope") { }
        }
    }
}