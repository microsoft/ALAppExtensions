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
                field(id; SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(category; "Account Category")
                {
                    Caption = 'category', Locked = true;
                }
                field(subCategory; "Account Subcategory Descript.")
                {
                    Caption = 'subCategory', Locked = true;
                }
                field(blocked; Blocked)
                {
                    Caption = 'blocked', Locked = true;
                    ToolTip = 'Specifies the status of the account.';
                }
                field(lastModifiedDateTime; "Last Modified Date Time")
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
        SETRANGE("Account Type", "Account Type"::Posting);
        SETRANGE("Direct Posting", TRUE);
    end;

    local procedure SetCalculatedFields()
    begin
    end;
}

