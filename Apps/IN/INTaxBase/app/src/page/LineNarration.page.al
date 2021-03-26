page 18551 "Line Narration"
{
    AutoSplitKey = true;
    Caption = 'Line Narration';
    DelayedInsert = true;
    PageType = Worksheet;
    SourceTable = "Gen. Journal Narration";
    UsageCategory = None;

    layout
    {
        area(content)
        {
            field("Document No."; Rec."Document No.")
            {
                Editable = false;
                ApplicationArea = Basic, Suite;
                Caption = 'Document No.';
                ToolTip = 'Specifies document number for which the voucher lines will be posted.';
            }
            repeater(Control1500000)
            {
                field(Narration; Rec.Narration)
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Narration';
                    ToolTip = 'Select Narration option to specify the narration of a voucher.';
                }
            }
        }
    }
}