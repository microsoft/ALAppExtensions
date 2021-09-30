#if not CLEAN19
pageextension 31036 "Sales Invoice Subform CZZ" extends "Sales Invoice Subform"
{
    layout
    {
#pragma warning disable AL0432
        modify("Prepayment %")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt. Line Amount")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Visible = not AdvancePaymentsEnabledCZZ;
        }
        modify("Prepmt Amt to Deduct")
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