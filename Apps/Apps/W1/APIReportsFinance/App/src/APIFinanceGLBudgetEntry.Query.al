namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.GeneralLedger.Budget;

query 30305 "API Finance - GL Budget Entry"
{
    QueryType = API;
    EntityCaption = 'General Budget Entry';
    EntityName = 'generalLedgerBudgetEntry';
    EntitySetName = 'generalLedgerBudgetEntries';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;

    elements
    {
        dataitem(GLBudgetEntry; "G/L Budget Entry")
        {
            column(id; SystemId)
            {
                Caption = 'Id';
            }
            column(number; "Entry No.")
            {
                Caption = 'Number';
            }
            column(description; Description)
            {
                Caption = 'Description';
            }
            column(budgetName; "Budget Name")
            {
                Caption = 'Budget Name';
            }
            column(businessUnitCode; "Business Unit Code")
            {
                Caption = 'Business Unit Code';
            }
            column(date; Date)
            {
                Caption = 'Date';
            }
            column(accountNo; "G/L Account No.")
            {
                Caption = 'Account Number';
            }
            column(amount; Amount)
            {
                Caption = 'Amount';
            }
            column(generalLedgerAccountNumber; "G/L Account No.")
            {
                Caption = 'G/L Account No.';
            }
            column(dimensionSetID; "Dimension Set ID")
            {
                Caption = 'Dimension Set ID';
            }
            column(globalDimension1Code; "Global Dimension 1 Code")
            {
                Caption = 'Global Dimension 1 Code';
            }
            column(globalDimension2Code; "Global Dimension 2 Code")
            {
                Caption = 'Global Dimension 2 Code';
            }
            column(budgetDimension1Code; "Budget Dimension 1 Code")
            {
                Caption = 'Budget Dimension 1 Code';
            }
            column(budgetDimension2Code; "Budget Dimension 2 Code")
            {
                Caption = 'Budget Dimension 2 Code';
            }
            column(budgetDimension3Code; "Budget Dimension 3 Code")
            {
                Caption = 'Budget Dimension 3 Code';
            }
            column(budgetDimension4Code; "Budget Dimension 4 Code")
            {
                Caption = 'Budget Dimension 4 Code';
            }
            column(lastModifiedDateTime; SystemModifiedAt)
            {
                Caption = 'Last  Modified Date Time';
            }
        }
    }
}