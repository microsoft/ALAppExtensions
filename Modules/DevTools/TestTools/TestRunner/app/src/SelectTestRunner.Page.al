page 130454 "Select TestRunner"
{
    Editable = false;
    PageType = List;
    SourceTable = AllObjWithCaption;
    SourceTableView = WHERE("Object Type"=CONST(Codeunit),
                            "Object Subtype"=CONST('TestRunner'));

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Object ID";"Object ID")
                {
                    ApplicationArea = All;
                }
                field("Object Name";"Object Name")
                {
                    ApplicationArea = All;
                }
            }
        }
    }

    actions
    {
    }
}

