#if not CLEAN19
pageextension 31048 "Purchase Statistics CZZ" extends "Purchase Statistics"
{
    layout
    {
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