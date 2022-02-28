codeunit 31432 "Acc. Sched. Ext. Handler CZZ"
{
#if not CLEAN20
    var
        AdvancePaymentsMgtCZZ: Codeunit "Advance Payments Mgt. CZZ";
#endif
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Acc. Sched. Extension Mgt. CZL", 'OnAfterSetCustLedgEntryFilters', '', false, false)]
    local procedure SetFiltersOnAfterSetCustLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var CustLedgerEntry: Record "Cust. Ledger Entry")
    begin
#if not CLEAN20
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;
#pragma warning disable AL0432
        CustLedgerEntry.SetRange(Prepayment);
#pragma warning restore AL0432
#endif
        case AccScheduleExtensionCZL."Advance Payments CZZ" of
            AccScheduleExtensionCZL."Advance Payments CZZ"::Yes:
                CustLedgerEntry.SetFilter("Advance Letter No. CZZ", '<>%1', '');
            AccScheduleExtensionCZL."Advance Payments CZZ"::No:
                CustLedgerEntry.SetRange("Advance Letter No. CZZ", '');
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Acc. Sched. Extension Mgt. CZL", 'OnAfterSetVendLedgEntryFilters', '', false, false)]
    local procedure SetFiltersOnAfterSetVendLedgEntryFilters(AccScheduleExtensionCZL: Record "Acc. Schedule Extension CZL"; var VendorLedgerEntry: Record "Vendor Ledger Entry")
    begin
#if not CLEAN20
        if not AdvancePaymentsMgtCZZ.IsEnabled() then
            exit;
#pragma warning disable AL0432
        VendorLedgerEntry.SetRange(Prepayment);
#pragma warning restore AL0432
#endif
        case AccScheduleExtensionCZL."Advance Payments CZZ" of
            AccScheduleExtensionCZL."Advance Payments CZZ"::Yes:
                VendorLedgerEntry.SetFilter("Advance Letter No. CZZ", '<>%1', '');
            AccScheduleExtensionCZL."Advance Payments CZZ"::No:
                VendorLedgerEntry.SetRange("Advance Letter No. CZZ", '');
        end;
    end;
}