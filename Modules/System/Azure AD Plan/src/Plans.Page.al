page 9824 Plans
{
    Caption = 'Plans';
    Editable = false;
    Extensible = false;
    LinksAllowed = false;
    PageType = List;
    ShowFilter = false;
    SourceTable = Plan;

    layout
    {
        area(content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = All;
                    ToolTip = 'Specifies the name of the record.';
                }
            }
        }
        area(factboxes) { }
    }

    actions
    {
        area(navigation) { }
    }
}

