namespace Microsoft.API.V2;

using Microsoft.Finance.GeneralLedger.Account;

page 30014 "APIV2 - Accounts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Account';
    EntitySetCaption = 'Accounts';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'account';
    EntitySetName = 'accounts';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "G/L Account";
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Display Name';
                }
                field(category; Rec."Account Category")
                {
                    Caption = 'Category';
                }
                field(subCategory; Rec."Account Subcategory Descript.")
                {
                    Caption = 'Subcategory';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(accountType; Rec."API Account Type")
                {
                    Caption = 'Account Type';
                }
                field(directPosting; Rec."Direct Posting")
                {
                    Caption = 'Direct Posting';
                }
                field(netChange; Rec."Net Change")
                {
                    Caption = 'Net Change';
                }
                field(consolidationTranslationMethod; Rec."Consol. Translation Method")
                {
                    Caption = 'Consolidation Translation Method';
                }
                field(consolidationDebitAccount; Rec."Consol. Debit Acc.")
                {
                    Caption = 'Consolidation Debit Account';
                }
                field(consolidationCreditAccount; Rec."Consol. Credit Acc.")
                {
                    Caption = 'Consolidation Credit Account';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }

    actions
    {
    }
}
