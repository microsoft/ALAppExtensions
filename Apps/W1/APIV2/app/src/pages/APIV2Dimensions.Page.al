page 30021 "APIV2 - Dimensions"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Dimension';
    EntitySetCaption = 'Dimensions';
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
                field(id; SystemId)
                {
                    Caption = 'Id';
                    Editable = false;
                }
                field("code"; Code)
                {
                    Caption = 'Code';
                }
                field(displayName; Name)
                {
                    Caption = 'Display Name';
                }
                field(lastModifiedDateTime; SystemModifiedAt)
                {
                    Caption = 'Last Modified Date';
                }
                part(dimensionValues; "APIV2 Dimension Values Entity")
                {
                    Caption = 'Dimension Values';
                    EntityName = 'dimensionValue';
                    EntitySetName = 'dimensionValues';
                    SubPageLink = "Dimension Id" = Field(SystemId);
                }
            }
        }
    }

    actions
    {
    }
}

