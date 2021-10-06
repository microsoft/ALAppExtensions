pageextension 31049 "Payment Journal CZZ" extends "Payment Journal"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepayment Type")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Advance VAT Base Amount")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
        addlast(Control1)
        {
            field("Advance Letter No. CZZ"; Rec."Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter no.';
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
    }

    actions
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify("Link Advance Letters")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Link Whole Advance Letter")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("UnLink Linked Advance Letters")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#pragma warning restore AL0432
#endif
    }

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}
