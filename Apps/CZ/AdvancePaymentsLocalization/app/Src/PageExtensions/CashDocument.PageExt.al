#if not CLEAN19
pageextension 31193 "Cash Document CZZ" extends "Cash Document CZP"
{
    actions
    {
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