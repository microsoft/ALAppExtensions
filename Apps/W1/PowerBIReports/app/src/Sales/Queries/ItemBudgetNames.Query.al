namespace Microsoft.Sales.PowerBIReports;

using Microsoft.Inventory.Analysis;

query 37002 "Item Budget Names"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI Item Budgets';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'itemBudget';
    EntitySetName = 'itemBudgets';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(ItemBudgetName; "Item Budget Name")
        {
            column(analysisArea; "Analysis Area")
            {
            }
            column(budgetName; Name)
            {
            }
            column(budgetDescription; Description)
            {
            }
        }
    }
}