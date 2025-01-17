namespace Microsoft.API.V2;

using Microsoft.CRM.Team;

page 30075 "APIV2 - Salesperson/Purchaser"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Salesperson/Purchaser';
    EntitySetCaption = 'Salespeople/Purchasers';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'salespersonPurchaser';
    EntitySetName = 'salespeoplePurchasers';
    SourceTable = "Salesperson/Purchaser";
    Extensible = false;

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field(code; Rec."Code")
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(email; Rec."E-Mail")
                {
                    Caption = 'Email';
                }
                field(email2; Rec."E-Mail 2")
                {
                    Caption = 'Email 2';
                }
                field(phoneNo; Rec."Phone No.")
                {
                    Caption = 'Phone No.';
                }
                field(jobTitle; Rec."Job Title")
                {
                    Caption = 'Job Title';
                }
                field(commisionPercent; Rec."Commission %")
                {
                    Caption = 'Commission %';
                }
                field(privacyBlocked; Rec."Privacy Blocked")
                {
                    Caption = 'Privacy Blocked';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                    Editable = false;
                }
            }
        }
    }
}
