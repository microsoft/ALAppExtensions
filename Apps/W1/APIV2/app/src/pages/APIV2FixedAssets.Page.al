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
                field(fixedAssetLocationCode; Rec."FA Location Code")
                {
                    Caption = 'Fixed Asset Location Code';
                }
                field(fixedAssetLocationId; Rec."FA Location Id")
                {
                    Caption = 'Fixed Asset Location Id';
                }
                field(classCode; Rec."FA Class Code")
                {
                    Caption = 'Class Code';
                }
                field(subclassCode; Rec."FA Subclass Code")
                {
                    Caption = 'Subclass Code';
                }
                field(blocked; Rec.Blocked)
                {
                    Caption = 'Blocked';
                }
                field(serialNumber; Rec."Serial No.")
                {
                    Caption = 'Serial No.';
                }
                field(employeeNumber; Rec."Responsible Employee")
                {
                    Caption = 'Employee No.';
                }
                field(employeeId; Rec."Responsible Employee Id")
                {
                    Caption = 'Employee Id';
                }
                field(underMaintenance; Rec."Under Maintenance")
                {
                    Caption = 'Under Maintenance';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(fixedAssetLocation; "APIV2 - FA Locations")
                {
                    Caption = 'Fixed Asset Location';
                    EntityName = 'fixedAssetLocation';
                    EntitySetName = 'fixedAssetLocations';
                    SubPageLink = SystemId = field("FA Location Id");
                    Multiplicity = ZeroOrOne;
                }
                part(employee; "APIV2 - Employees")
                {
                    Caption = 'Employee';
                    EntityName = 'employee';
                    EntitySetName = 'employees';
                    SubPageLink = SystemId = field("Responsible Employee Id");
                    Multiplicity = ZeroOrOne;
                }
            }
        }
    }
}