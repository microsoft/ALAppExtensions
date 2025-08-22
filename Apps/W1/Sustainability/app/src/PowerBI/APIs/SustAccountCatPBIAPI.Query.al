namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Account;

query 6218 "Sust Account Cat - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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