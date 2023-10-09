namespace Microsoft.API.FinancialManagement;

using Microsoft.Finance.GeneralLedger.Budget;

page 30305 "API Finance - GL Budgets"
{
    PageType = API;
    EntityCaption = 'General Ledger Budgets';
    EntityName = 'generalLedgerBudgets';
    EntitySetName = 'generalLedgerBudgets';
    APIGroup = 'reportsFinance';
    APIPublisher = 'microsoft';
    APIVersion = 'beta';
    DataAccessIntent = ReadOnly;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    SourceTable = "G/L Budget Name";
    ODataKeyFields = SystemId;

    layout
    {
        area(Content)
        {
            group(GroupName)
            {
                field(id; Rec.SystemID)
                {
                    Caption = 'Id';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(description; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(budgetDimension1Code; Rec."Budget Dimension 1 Code")
                {
                    Caption = 'Budget Dimension 1 Code';
                }
                field(budgetDimension2Code; Rec."Budget Dimension 2 Code")
                {
                    Caption = 'Budget Dimension 2 Code';
                }
                field(budgetDimension3Code; Rec."Budget Dimension 3 Code")
                {
                    Caption = 'Budget Dimension 3 Code';
                }
                field(budgetDimension4Code; Rec."Budget Dimension 4 Code")
                {
                    Caption = 'Budget Dimension 4 Code';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last  Modified Date Time';
                }
            }
        }
    }
}