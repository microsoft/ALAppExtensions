namespace Microsoft.API.V1;

using Microsoft.Projects.Project.Job;

page 20050 "APIV1 - Jobs"
{
    APIVersion = 'v1.0';
    Caption = 'projects', Locked = true;
    DelayedInsert = true;
    EntityName = 'project';
    EntitySetName = 'projects';
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Job;
    Extensible = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'id', Locked = true;
                    Editable = false;
                }
                field(number; Rec."No.")
                {
                    Caption = 'number', Locked = true;
                }
                field(displayName; Rec.Description)
                {
                    Caption = 'displayName', Locked = true;
                }
            }
        }
    }
}
