page 30097 "APIV2 - FA Locations"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'Fixed Asset Location';
    EntitySetCaption = 'Fixed Asset Locations';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'fixedAssetLocation';
    EntitySetName = 'fixedAssetLocations';
    SourceTable = "FA Location";
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
                field(code; Rec.Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'Name';
                }
                field(lastModifiedDateTime; Rec.SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
            }
        }
    }
}