namespace Microsoft.Sustainability.PowerBIReports;

using Microsoft.Sustainability.Account;

query 6217 "SusSub Act Category - PBI API"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Sustainability Entries';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    ApiVersion = 'v0.5', 'v1.0';
    EntityName = 'pbiSustainabilitySubAccountCategory';
    EntitySetName = 'pbiSustainabilitySubAccountCategories';
    DataAccessIntent = ReadOnly;
    elements
    {
        dataitem(SustainabilitySubcategory; "Sustain. Account Subcategory")
        {
            column(categoryCode; "Category Code") { }
            column(subcategoryCode; Code) { }
            column(subCategoryDescription; Description) { }
            column(subCategoryRenewableEnergy; "Renewable Energy") { }
        }
    }
}