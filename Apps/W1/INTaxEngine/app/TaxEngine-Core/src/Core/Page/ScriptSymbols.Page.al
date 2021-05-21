page 20131 "Script Symbols"
{
    Caption = 'Symbols';
    PageType = List;
    SourceTable = "Script Symbol";
    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Name; Name)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the Symbol.';
                }
                field(Datatype; Datatype)
                {
                    Caption = 'Datatype';
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the datatype of the Symbol.';
                }
            }
        }
    }
}