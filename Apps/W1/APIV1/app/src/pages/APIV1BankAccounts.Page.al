namespace Microsoft.API.V1;

using Microsoft.Bank.BankAccount;

page 20051 "APIV1 - Bank Accounts"
{
    APIVersion = 'v1.0';
    Caption = 'bankAccounts', Locked = true;
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
            }
        }
    }
}
