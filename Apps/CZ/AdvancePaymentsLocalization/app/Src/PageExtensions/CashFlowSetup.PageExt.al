pageextension 31195 "Cash Flow Setup CZZ" extends "Cash Flow Setup"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("S. Adv. Letter CF Account No.")
        {
            Visible = false;
        }
        modify("P. Adv. Letter CF Account No.")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        addafter("FA Disposal CF Account No.")
        {
            field("S. Adv. Letter CF Account No. CZZ"; Rec."S. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for sales advance letters';
            }
            field("P. Adv. Letter CF Account No. CZZ"; Rec."P. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for purchase advance letters ';
            }
        }
    }
}
