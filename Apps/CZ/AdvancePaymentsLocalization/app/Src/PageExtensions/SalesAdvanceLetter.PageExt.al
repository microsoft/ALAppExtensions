#if not CLEAN19
#pragma warning disable AL0432
pageextension 31183 "Sales Advance Letter CZZ" extends "Sales Advance Letter"
{
    trigger OnOpenPage()
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        AdvancePaymentsMgtCZZ.DontUseObsoleteAdvancePayments();
    end;
}
#endif