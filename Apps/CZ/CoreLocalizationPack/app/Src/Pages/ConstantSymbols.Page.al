page 11700 "Constant Symbols CZL"
{
    ApplicationArea = Basic, Suite;
    Caption = 'Constant Symbols';
    PageType = List;
    SourceTable = "Constant Symbol CZL";
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(Control1)
            {
                ShowCaption = false;
                field("Code"; Rec.Code)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the code for a constant symbol.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies a description of the constant symbol.';
                }
            }
        }
    }
}
