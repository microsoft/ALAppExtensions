page 20034 "APIV1 - Trial Balance"
{
    APIVersion = 'v1.0';
    Caption = 'trialBalance', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'trialBalance';
    EntitySetName = 'trialBalance';
    InsertAllowed = false;
    ModifyAllowed = false;
    PageType = API;
    SourceTable = "Trial Balance Entity Buffer";
    SourceTableTemporary = true;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(accountId; "Account Id")
                {
                    Caption = 'accountId', Locked = true;
                }
                field(accountType; "Account Type")
                {
                    Caption = 'accountType', Locked = true;
                }
                field(display; Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(totalDebit; "Total Debit")
                {
                    Caption = 'totalDebit', Locked = true;
                }
                field(totalCredit; "Total Credit")
                {
                    Caption = 'totalCredit', Locked = true;
                }
                field(balanceAtDateDebit; "Balance at Date Debit")
                {
                    Caption = 'balanceAtDateDebit', Locked = true;
                }
                field(balanceAtDateCredit; "Balance at Date Credit")
                {
                    Caption = 'balanceAtDateCredit', Locked = true;
                }
                field(dateFilter; "Date Filter")
                {
                    Caption = 'dateFilter', Locked = true;
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


