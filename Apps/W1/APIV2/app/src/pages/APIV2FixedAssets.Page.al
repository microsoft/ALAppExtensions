page 30098 "APIV2 - Fixed Assets"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Fixed Asset';
    EntitySetCaption = 'Fixed Assets';
    ChangeTrackingAllowed = true;
    DelayedInsert = true;
    EntityName = 'fixedAsset';
    EntitySetName = 'fixedAssets';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = "Fixed Asset";
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
                field(displayName; Rec.Description)
                {
                    Caption = 'Description';
                }
                field(faLocationCode; Rec."FA Location Code")
                {
                    Caption = 'FA Location Code';
                }
                field(faClassCode; Rec."FA Class Code")
                {
                    Caption = 'FA Class Code';
                }
                field(faSubclassCode; Rec."FA Subclass Code")
                {
                    Caption = 'FA Subclass Code';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(serialNo; Rec."Serial No.")
                {
                    Caption = 'Serial No.';
                }
                field(responsibleEmployee; Rec."Responsible Employee")
                {
                    Caption = 'Responsible Employee';
                }
                field(underMaintenance; Rec."Under Maintenance")
                {
                    Caption = 'Under Maintenance';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }
}
