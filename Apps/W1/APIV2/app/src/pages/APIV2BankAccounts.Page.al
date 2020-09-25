page 30051 "APIV2 - Bank Accounts"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Bank Account';
    EntitySetCaption = 'Bank Accounts';
    DelayedInsert = true;
    EntityName = 'bankAccount';
    EntitySetName = 'bankAccounts';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Bank Account";
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
            }
        }
    }
}