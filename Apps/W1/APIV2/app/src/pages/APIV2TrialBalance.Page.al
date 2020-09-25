page 30034 "APIV2 - Trial Balance"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Trial Balance';
    EntitySetCaption = 'Trial Balances';
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'trialBalance';
    EntitySetName = 'trialBalances';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Trial Balance Entity Buffer";
    SourceTableTemporary = true;
    Extensible = false;
    ODataKeyFields = "Account Id";

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(accountId; "Account Id")
                {
                    Caption = 'Account Id';
                }
                field(accountType; "Account Type")
                {
                    Caption = 'Account Type';
                }
                field(display; Name)
                {
                    Caption = 'Name';
                }
                field(totalDebit; "Total Debit")
                {
                    Caption = 'Total Debit';
                }
                field(totalCredit; "Total Credit")
                {
                    Caption = 'Total Credit';
                }
                field(balanceAtDateDebit; "Balance at Date Debit")
                {
                    Caption = 'Balance At Date Debit';
                }
                field(balanceAtDateCredit; "Balance at Date Credit")
                {
                    Caption = 'Balance At Date Credit';
                }
                field(dateFilter; "Date Filter")
                {
                    Caption = 'Date Filter';
                }
            }
        }
    }

    actions
    {
    }

    trigger OnOpenPage()
    var
        GraphMgtReports: Codeunit "Graph Mgt - Reports";
        RecVariant: Variant;
    begin
        RecVariant := Rec;
        GraphMgtReports.SetUpTrialBalanceAPIData(RecVariant);
    end;
}


