page 18692 "TDS Nature Of Remittances"
{
    PageType = List;
    ApplicationArea = Basic, Suite;
    UsageCategory = Lists;
    SourceTable = "TDS Nature of Remittance";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field(Code; Rec.Code)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specify the type of remittance deductee deals with.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = Suite;
                    ToolTip = 'Specifies description of TDS nature of remittance.';
                }
            }
        }
    }
}