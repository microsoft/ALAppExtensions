namespace Microsoft.Sales.Receivables;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31132 "Cust. Ledger Entry Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Cust. Ledger Entry", 'OnAfterCopyCustLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure UpdateEntryOnAfterCopyCustLedgerEntryFromGenJnlLine(var CustLedgerEntry: Record "Cust. Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        CustLedgerEntry."Specific Symbol CZL" := GenJournalLine."Specific Symbol CZL";
        CustLedgerEntry."Variable Symbol CZL" := GenJournalLine."Variable Symbol CZL";
        CustLedgerEntry."Constant Symbol CZL" := GenJournalLine."Constant Symbol CZL";
        CustLedgerEntry."Bank Account Code CZL" := GenJournalLine."Bank Account Code CZL";
        CustLedgerEntry."Bank Account No. CZL" := GenJournalLine."Bank Account No. CZL";
        CustLedgerEntry."Transit No. CZL" := GenJournalLine."Transit No. CZL";
        CustLedgerEntry."IBAN CZL" := GenJournalLine."IBAN CZL";
        CustLedgerEntry."SWIFT Code CZL" := GenJournalLine."SWIFT Code CZL";
        CustLedgerEntry."VAT Date CZL" := GenJournalLine."VAT Reporting Date";
    end;
}