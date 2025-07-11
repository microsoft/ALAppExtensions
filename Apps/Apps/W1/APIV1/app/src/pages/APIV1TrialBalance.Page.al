namespace Microsoft.API.V1;

using Microsoft.Finance.FinancialReports;
using Microsoft.Integration.Graph;

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
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(accountId; Rec."Account Id")
                {
                    Caption = 'accountId', Locked = true;
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'accountType', Locked = true;
                }
                field(display; Rec.Name)
                {
                    Caption = 'name', Locked = true;
                }
                field(totalDebit; Rec."Total Debit")
                {
                    Caption = 'totalDebit', Locked = true;
                }
                field(totalCredit; Rec."Total Credit")
                {
                    Caption = 'totalCredit', Locked = true;
                }
                field(balanceAtDateDebit; Rec."Balance at Date Debit")
                {
                    Caption = 'balanceAtDateDebit', Locked = true;
                }
                field(balanceAtDateCredit; Rec."Balance at Date Credit")
                {
                    Caption = 'balanceAtDateCredit', Locked = true;
                }
                field(dateFilter; Rec."Date Filter")
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



