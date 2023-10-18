namespace Microsoft.Intercompany.CrossEnvironment;

using Microsoft.Intercompany.GLAccount;

page 30405 "API - IC G/L Accounts"
{
    PageType = API;
    APIPublisher = 'microsoft';
    APIGroup = 'intercompany';
    APIVersion = 'v1.0';
    EntityName = 'intercompanyGeneralLedgerAccount';
    EntitySetName = 'intercompanyGeneralLedgerAccounts';
    EntityCaption = 'Intercompany General Ledger Account';
    EntitySetCaption = 'Intercompany General Ledger Accounts';
    SourceTable = "IC G/L Account";
    DelayedInsert = true;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    ODataKeyFields = SystemId;
    Extensible = false;
    Editable = false;
    DataAccessIntent = ReadOnly;

    layout
    {
        area(Content)
        {
            field(id; Rec.SystemId)
            {
                Caption = 'Id';
            }
            field(accountNumber; Rec."No.")
            {
                Caption = 'Account Number';
            }
            field(name; Rec.Name)
            {
                Caption = 'Name';
            }
            field(accountType; Rec."Account Type")
            {
                Caption = 'Account Type';
            }
            field(incomeBalance; Rec."Income/Balance")
            {
                Caption = 'Income/Balance';
            }
            field(blocked; Rec.Blocked)
            {
                Caption = 'Blocked';
            }
        }
    }
}