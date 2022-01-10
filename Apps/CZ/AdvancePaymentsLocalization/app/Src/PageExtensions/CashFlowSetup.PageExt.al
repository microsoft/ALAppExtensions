pageextension 31195 "Cash Flow Setup CZZ" extends "Cash Flow Setup"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("S. Adv. Letter CF Account No.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("P. Adv. Letter CF Account No.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addafter("FA Disposal CF Account No.")
        {
            field("S. Adv. Letter CF Account No. CZZ"; Rec."S. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for sales advance letters';
#if not CLEAN19
                Visible = AdvancePaymentsEnabledCZZ;
#endif
            }
            field("P. Adv. Letter CF Account No. CZZ"; Rec."P. Adv. Letter CF Acc. No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the number of the cash flow account for purchase advance letters ';
#if not CLEAN19
                Visible = AdvancePaymentsEnabledCZZ;
#endif
            }
        }
    }
#if not CLEAN19
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
#endif
}