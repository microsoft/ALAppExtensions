#pragma warning disable AA0247
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
    AboutText = 'Manages fixed asset location records, including codes, names, and last modified dates, enabling full CRUD operations for tracking, auditing, and integrating asset location data with external asset management and accounting systems. Supports scenarios such as monitoring asset whereabouts and maintaining accurate asset records across buildings, departments, or sites.';

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
