page 20204 "Script Variables Part"
{
    Caption = 'Variables';
    DataCaptionExpression = Name;
    PageType = StandardDialog;
    SourceTable = "Script Variable";
    MultipleNewLines = true;
    AutoSplitKey = true;
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
                field(Datatype; Datatype)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the data type of variable.';
                }
            }
        }
    }
}