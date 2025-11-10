namespace Microsoft.API.V2;

using Microsoft.Finance.FinancialReports;
using Microsoft.Integration.Graph;

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
    AboutText = 'Exposes trial balance data for all general ledger accounts, including account numbers, names, types, debit and credit balances, and period-based filters. Supports GET operations for financial reconciliation, auditing, and integration with external reporting or financial statement automation tools. Enables accurate retrieval of account balances to ensure completeness and integrity of financial records in external systems.';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(accountId; Rec."Account Id")
                {
                    Caption = 'Account Id';
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account Type';
                }
                field(display; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(totalDebit; Rec."Total Debit")
                {
                    Caption = 'Total Debit';
                }
                field(totalCredit; Rec."Total Credit")
                {
                    Caption = 'Total Credit';
                }
                field(balanceAtDateDebit; Rec."Balance at Date Debit")
                {
                    Caption = 'Balance At Date Debit';
                }
                field(balanceAtDateCredit; Rec."Balance at Date Credit")
                {
                    Caption = 'Balance At Date Credit';
                }
                field(dateFilter; Rec."Date Filter")
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


