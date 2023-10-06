namespace Microsoft.API.V1;

using Microsoft.Finance.Dimension;

page 20021 "APIV1 - Dimensions"
{
    APIVersion = 'v1.0';
    Caption = 'dimensions', Locked = true;
    DelayedInsert = true;
    DeleteAllowed = false;
    Editable = false;
    EntityName = 'dimension';
    EntitySetName = 'dimensions';
    InsertAllowed = false;
    ModifyAllowed = false;
    ODataKeyFields = SystemId;
    PageType = API;
    SourceTable = Dimension;
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
                field("code"; Rec.Code)
                {
                    Caption = 'code', Locked = true;
                }
                field(displayName; Rec.Name)
                {
                    Caption = 'displayName', Locked = true;
                }
                field(lastModifiedDateTime; Rec."Last Modified Date Time")
                {
                    Caption = 'lastModifiedDateTime', Locked = true;
                }
                part(dimensionValues; "APIV1 Dimension Values Entity")
                {
                    Caption = 'DimensionValues', Locked = true;
                    EntityName = 'dimensionValue';
                    EntitySetName = 'dimensionValues';
                    SubPageLink = "Dimension Code" = field(Code);
                }
            }
        }
    }

    actions
    {
    }
}


