page 30079 "APIV2 - Gen. Prod. Post. Group"
{
    APIVersion = 'v2.0';
    EntityCaption = 'General Product Posting Group';
    EntitySetCaption = 'General Product Posting Groups';
    DelayedInsert = true;
    EntityName = 'generalProductPostingGroup';
    EntitySetName = 'generalProductPostingGroups';
    PageType = API;
    SourceTable = "Gen. Product Posting Group";
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
                field(defaultVATProductPostingGroup; "Def. VAT Prod. Posting Group")
                {
                    Caption = 'Default VAT Product Posting Group';
                }
                field(autoInsertDefault; "Auto Insert Default")
                {
                    Caption = 'Auto Insert Default';
                }
            }
        }
    }

    actions
    {
    }

}