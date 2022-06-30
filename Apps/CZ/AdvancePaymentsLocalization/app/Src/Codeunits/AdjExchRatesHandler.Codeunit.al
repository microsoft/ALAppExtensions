#if not CLEAN21
#pragma warning disable AL0432
codeunit 31414 "Adj. Exch. Rates handler CZZ"
{
    [EventSubscriber(ObjectType::Report, Report::"Adjust Exchange Rates CZL", 'OnSkipCustLedgerEntry', '', false, false)]
    local procedure AdjusExchnageRatesCZLOnSkipCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; SkipAdvancePayments: Boolean; var SkipCustLedgerEntry: Boolean)
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        if SkipCustLedgerEntry then
            exit;
        if (CustLedgerEntry."Advance Letter No. CZZ" = '') or not SkipAdvancePayments then
            exit;
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;

        SkipCustLedgerEntry := true;
    end;

    [EventSubscriber(ObjectType::Report, Report::"Adjust Exchange Rates CZL", 'OnSkipVendorLedgerEntry', '', false, false)]
    local procedure AdjusExchnageRatesCZLOnSkipVendorLedgerEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; SkipAdvancePayments: Boolean; var SkipVendorLedgerEntry: Boolean)
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
    begin
        if SkipVendorLedgerEntry then
            exit;
        if (VendorLedgerEntry."Advance Letter No. CZZ" = '') or not SkipAdvancePayments then
            exit;
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;

        SkipVendorLedgerEntry := true;
    end;
}
#pragma warning restore AL0432
#endif
