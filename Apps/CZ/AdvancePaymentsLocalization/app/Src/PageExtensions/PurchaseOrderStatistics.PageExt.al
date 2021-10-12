pageextension 31046 "Purchase Order Statistics CZZ" extends "Purchase Order Statistics"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Prepayment (Deduct)")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Invoicing (Final)")
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
