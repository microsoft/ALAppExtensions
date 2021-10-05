page 30096 "APIV2 - Inventory Post. Group"
{
    APIVersion = 'v2.0';
    EntityCaption = 'Inventory Posting Group';
    EntitySetCaption = 'Inventory Posting Groups';
    DelayedInsert = true;
    EntityName = 'inventoryPostingGroup';
    EntitySetName = 'inventoryPostingGroups';
    PageType = API;
    SourceTable = "Inventory Posting Group";
    Extensible = false;
    ODataKeyFields = SystemId;
    InsertAllowed = false;
    DeleteAllowed = false;
    ModifyAllowed = false;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(id; SystemId)
                {
                    Caption = 'Id';
                }
                field(code; "code")
                {
                    Caption = 'Code';
                }

                field(description; "Description")
                {
                    Caption = 'Description';
                }
            }
        }
    }

    actions
    {
    }

}