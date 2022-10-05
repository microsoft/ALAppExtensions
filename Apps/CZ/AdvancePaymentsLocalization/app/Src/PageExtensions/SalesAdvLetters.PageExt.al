#if not CLEAN19
#pragma warning disable AL0432
pageextension 31185 "Sales Adv. Letters CZZ" extends "Sales Adv. Letters"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif