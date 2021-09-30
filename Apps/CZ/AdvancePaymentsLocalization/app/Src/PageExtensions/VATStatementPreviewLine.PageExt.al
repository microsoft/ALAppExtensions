#if not CLEAN19
pageextension 31056 "VAT Statement Preview Line CZZ" extends "VAT Statement Preview Line"
{
    layout
    {
#pragma warning disable AL0432
        modify("Prepayment Type")
#pragma warning restore AL0432
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
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