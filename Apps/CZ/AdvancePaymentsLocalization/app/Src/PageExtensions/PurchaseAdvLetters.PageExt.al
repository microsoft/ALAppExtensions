#if not CLEAN19
#pragma warning disable AL0432
pageextension 31189 "Purchase Adv. Letters CZZ" extends "Purchase Adv. Letters"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif