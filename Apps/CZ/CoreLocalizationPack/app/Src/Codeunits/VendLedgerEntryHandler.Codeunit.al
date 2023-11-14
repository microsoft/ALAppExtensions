namespace Microsoft.Purchases.Payables;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31134 "Vend. Ledger Entry Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Vendor Ledger Entry", 'OnAfterCopyVendLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyVendorLedgerEntryFromGenJnlLine(var VendorLedgerEntry: Record "Vendor Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        VendorLedgerEntry."Specific Symbol CZL" := GenJournalLine."Specific Symbol CZL";
        VendorLedgerEntry."Variable Symbol CZL" := GenJournalLine."Variable Symbol CZL";
        VendorLedgerEntry."Constant Symbol CZL" := GenJournalLine."Constant Symbol CZL";
        VendorLedgerEntry."Bank Account Code CZL" := GenJournalLine."Bank Account Code CZL";
        VendorLedgerEntry."Bank Account No. CZL" := GenJournalLine."Bank Account No. CZL";
        VendorLedgerEntry."Transit No. CZL" := GenJournalLine."Transit No. CZL";
        VendorLedgerEntry."IBAN CZL" := GenJournalLine."IBAN CZL";
        VendorLedgerEntry."SWIFT Code CZL" := GenJournalLine."SWIFT Code CZL";
#if not CLEAN22
#pragma warning disable AL0432
        if not GenJournalLine.IsReplaceVATDateEnabled() then
            GenJournalLine."VAT Reporting Date" := GenJournalLine."VAT Date CZL";
#pragma warning restore AL0432
#endif
        VendorLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;
}