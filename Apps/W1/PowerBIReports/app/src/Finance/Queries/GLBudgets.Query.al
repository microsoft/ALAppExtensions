namespace Microsoft.Finance.PowerBIReports;

using Microsoft.Finance.GeneralLedger.Budget;

query 36961 "G/L Budgets"
{
    Access = Internal;
    QueryType = API;
    Caption = 'Power BI G/L Budgets';
    APIPublisher = 'microsoft';
    APIGroup = 'analytics';
    APIVersion = 'v0.5';
    EntityName = 'generalLedgerBudget';
    EntitySetName = 'generalLedgerBudgets';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLBudgetName; "G/L Budget Name")
        {
            column(budgetName; Name)
            {
            }
            column(budgetDescription; Description)
            {
            }
        }
    }
}