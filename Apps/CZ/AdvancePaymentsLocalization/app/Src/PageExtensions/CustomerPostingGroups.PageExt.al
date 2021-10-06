#if not CLEAN19
pageextension 31191 "Customer Posting Groups CZZ" extends "Customer Posting Groups"
{
    layout
    {
#pragma warning disable AL0432
        modify("Advance Account")
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