pageextension 31022 "General Ledger Setup CZZ" extends "General Ledger Setup"
{
    layout
    {
        addlast(General)
        {
            field("Adv. Deduction Exch. Rate CZZ"; Rec."Adv. Deduction Exch. Rate CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance deduction exchange rate.';
                Importance = Additional;
                Visible = AdvancePaymentsEnabledCZZ;
            }
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify(Advances)
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
