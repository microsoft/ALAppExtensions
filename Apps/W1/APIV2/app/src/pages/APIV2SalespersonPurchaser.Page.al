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
                field(eMail; Rec."E-Mail")
                {
                    Caption = 'Email';
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
