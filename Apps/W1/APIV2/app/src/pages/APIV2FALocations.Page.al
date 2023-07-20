page 60100 "APIV2 - FA Locations"
{
    DelayedInsert = true;
    APIVersion = 'v2.0';
    EntityCaption = 'FALocation';
    EntitySetCaption = 'FALocations';
    PageType = API;
    ODataKeyFields = SystemId;
    EntityName = 'falocation';
    EntitySetName = 'falocations';
    SourceTable = "FA Location";
    Extensible = false;
    APIPublisher = 'Temp';
    APIGroup = 'Temp';

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