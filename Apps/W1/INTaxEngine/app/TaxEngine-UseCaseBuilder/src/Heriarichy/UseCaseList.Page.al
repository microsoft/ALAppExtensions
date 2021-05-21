page 20299 "Use Case List"
{
    PageType = List;
    SourceTable = "Tax Use Case";
    DataCaptionExpression = Rec.Description;
    Editable = false;
    InsertAllowed = false;
    ModifyAllowed = false;
    DeleteAllowed = false;
    layout
    {
        area(Content)
        {
            repeater(GroupName)
            {
                field("Tax Type"; Rec."Tax Type")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Tax Type';
                    ToolTip = 'Specifies the Tax Type of the use case.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Description';
                    ToolTip = 'Specifies the description of the use case.';
                }
            }
        }
    }
}