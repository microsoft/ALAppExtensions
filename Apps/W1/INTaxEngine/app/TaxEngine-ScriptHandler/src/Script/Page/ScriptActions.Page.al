page 20196 "Script Actions"
{
    Caption = 'Actions';
    Editable = false;
    PageType = List;
    DataCaptionExpression = "Text";
    SourceTable = "Script Action";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {
                field(Text; Text)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the name of the action.';
                }
            }
        }
    }
}