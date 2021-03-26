page 20202 "Script Record Variable Fields"
{
    Editable = false;
    PageType = List;
    AutoSplitKey = true;
    SourceTable = "Script Record Variable";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the field name.';
                }
                field(Datatype; Datatype)
                {
                    Editable = false;
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the datatype of record field.';
                }
            }
        }
    }
}