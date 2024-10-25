namespace Microsoft.API.V2;

using Microsoft.Sustainability.Account;

page 30075 "APIV2 - Sust. Accounts"
{

    APIVersion = 'v2.0';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityAccount';
    EntitySetName = 'sustainabilityAccounts';
    EntityCaption = 'Sustainability Account';
    EntitySetCaption = 'Sustainability Accounts';
    ODataKeyFields = SystemId;
    SourceTable = "Sustainability Account";
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
                field(name; Rec.Name)
                {
                    Caption = 'Account name';
                }
                field(number; Rec."No.")
                {
                    Caption = 'Account number';
                }
                field(netChangeCo2; Rec."Net Change (CO2)")
                {
                    Caption = 'Net change (CO2))';
                }
                field(balanceCo2; Rec."Balance (CO2)")
                {
                    Caption = 'Balance (CO2))';
                }
                field(accountType; Rec."Account Type")
                {
                    Caption = 'Account type';
                }
            }
        }
    }
}