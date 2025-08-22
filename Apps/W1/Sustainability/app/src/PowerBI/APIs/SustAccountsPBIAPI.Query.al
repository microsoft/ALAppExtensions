namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Account;

query 6219 "Sust Accounts - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
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