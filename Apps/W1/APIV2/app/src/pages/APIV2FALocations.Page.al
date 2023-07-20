page 30097 "APIV2 - FA Locations"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'FALocation';
    EntitySetCaption = 'FALocations';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'faLocation';
    EntitySetName = 'faLocations';
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
                field(name; Rec.Name)
                {
                    Caption = 'Name';
                }
            }
        }
    }
}