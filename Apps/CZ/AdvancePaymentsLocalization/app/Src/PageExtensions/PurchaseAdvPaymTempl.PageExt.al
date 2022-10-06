#if not CLEAN19
#pragma warning disable AL0432
pageextension 31190 "Purchase Adv. Paym. Templ. CZZ" extends "Purchase Adv. Paym. Templates"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif