namespace Microsoft.API.V2;

using Microsoft.Sustainability.Account;

page 30070 "APIV2 - Sustainability Account"
{

    APIVersion = 'v2.0';
    PageType = API;
    DelayedInsert = true;
    EntityName = 'sustainabilityAccount';
    EntitySetName = 'sustainabilityAccounts';
    EntityCaption = 'Sustainability Account';
    EntitySetCaption = 'Sustainability Accounts';
    ODataKeyFields = SystemId;
    SourceTable = 'Sustainability Account';
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
                field(Name; Rec.Name)
                {
                    Caption = 'Account Name';
                }
                field("Number"; Rec."No.")
                {
                    Caption = 'Account Number';
                }
                field("Net_Change_CO2"; Rec."Net Change (CO2)")
                {
                    Caption = 'Net Change (CO2))';
                }
                field("Balance_CO2"; Rec."Balance (CO2)")
                {
                    Caption = 'Balance (CO2))';

                }
                field("Account_Type"; Rec."Account Type")
                {
                    Caption = 'Account Type';
                }
            }
        }
    }
}