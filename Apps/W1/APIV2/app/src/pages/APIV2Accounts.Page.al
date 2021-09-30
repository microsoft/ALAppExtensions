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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(number; "No.")
                {
                    Caption = 'No.';
                }
                field(displayName; Name)
                {
                    Caption = 'Display Name';
                }
                field(category; "Account Category")
                {
                    Caption = 'Category';
                }
                field(subCategory; "Account Subcategory Descript.")
                {
                    Caption = 'Subcategory';
                }
                field(blocked; Blocked)
                {
                    Caption = 'Blocked';
                }
                field(accountType; "API Account Type")
                {
                    Caption = 'Account Type';
                }
                field(directPosting; "Direct Posting")
                {
                    Caption = 'Direct Posting';
                }
                field(netChange; "Net Change")
                {
                    Caption = 'Net Change';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
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