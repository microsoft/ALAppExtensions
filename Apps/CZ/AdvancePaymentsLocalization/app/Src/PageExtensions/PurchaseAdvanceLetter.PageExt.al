#if not CLEAN19
#pragma warning disable AL0432
pageextension 31187 "Purchase Advance Letter CZZ" extends "Purchase Advance Letter"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif