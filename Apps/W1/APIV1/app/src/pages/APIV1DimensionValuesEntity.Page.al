namespace Microsoft.API.V1;

using Microsoft.Finance.Dimension;

page 20053 "APIV1 Dimension Values Entity"
{
    APIVersion = 'v1.0';
    Caption = 'dimensionValues', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    SourceTable = "Dimension Value";
    ODataKeyFields = SystemId;
    PageType = API;
    EntityName = 'dimensionValue';
    EntitySetName = 'dimensionValues';

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; Rec.SystemId)
                {
                    Caption = 'Id', Locked = true;
                    Editable = false;
                }

                field("code"; Rec.Code)
                {
                    Caption = 'Code', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'DisplayName', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'LastModifiedDateTime', Locked = true;
                }
            }
        }
    }

    actions
    {
    }
}
