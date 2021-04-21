page 20203 "Script Variable List"
{
    Caption = 'Variables';
    Editable = false;
    PageType = List;
    SourceTable = "Script Variable";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of variable.';
                }
            }
        }
    }
}