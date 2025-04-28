namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Account;

query 37069 "Sust Accounts - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'pbiSustainabilityAccount';
    EntitySetName = 'pbiSustainabilityAccounts';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(SustainabilityAccount; "Sustainability Account")
        {
            column(sustainabilityAccountNo; "No.") { }
            column(sustainabilityAccountName; Name) { }
            column(sustainabilityAccountCategory; Category) { }
            column(sustainabilityAccountSubCategory; Subcategory) { }
        }
    }
}