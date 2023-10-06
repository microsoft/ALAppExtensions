namespace Microsoft.API.V1;

using Microsoft.Finance.GeneralLedger.Account;

page 20014 "APIV1 - Accounts"
{
    APIVersion = 'v1.0';
    Caption = 'accounts', Locked = true;
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
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(category; Rec."Account Category")
                {
                    Caption = 'category', Locked = true;
                }
                field(subCategory; Rec."Account Subcategory Descript.")
                {
                    Caption = 'subCategory', Locked = true;
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'blocked', Locked = true;
                    ToolTip = 'Specifies the status of the account.';
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }

    trigger OnAfterGetRecord()
    begin
        SetCalculatedFields();
    end;

    trigger OnOpenPage()
    begin
        Rec.SETRANGE("Account Type", Rec."Account Type"::Posting);
        Rec.SetRange("Direct Posting", true);
    end;

    local procedure SetCalculatedFields()
    begin
    end;
}


