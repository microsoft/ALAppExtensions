#if not CLEAN19
#pragma warning disable AL0432
pageextension 31188 "Purchase Advance Letters CZZ" extends "Purchase Advance Letters"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif