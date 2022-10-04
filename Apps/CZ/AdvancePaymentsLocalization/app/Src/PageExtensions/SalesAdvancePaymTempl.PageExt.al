#if not CLEAN19
#pragma warning disable AL0432
pageextension 31186 "Sales Advance Paym. Templ. CZZ" extends "Sales Advanced Paym. Templates"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif