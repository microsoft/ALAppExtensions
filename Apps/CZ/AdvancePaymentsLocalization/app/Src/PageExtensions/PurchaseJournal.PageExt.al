#if not CLEAN19
pageextension 31042 "Purchase Journal CZZ" extends "Purchase Journal"
{
    layout
    {
#pragma warning disable AL0432
        modify("Prepayment Type")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
    }

    actions
    {
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
    }

    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
        AdvancePaymentsEnabledCZZ: Boolean;

    trigger OnOpenPage()
    begin
        AdvancePaymentsEnabledCZZ := AdvancePaymentsMgtCZZ.IsEnabled();
    end;
}

#endif