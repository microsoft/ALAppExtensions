#if not CLEAN19
#pragma warning disable AL0432
pageextension 31184 "Sales Advance Letters CZZ" extends "Sales Advance Letters"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif