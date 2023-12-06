namespace Microsoft.HumanResources.Payables;

using Microsoft.Finance.GeneralLedger.Journal;

codeunit 31136 "Emp. Ledger Entry Handler CZL"
{
    Access = Internal;

    [EventSubscriber(ObjectType::Table, Database::"Employee Ledger Entry", 'OnAfterCopyEmployeeLedgerEntryFromGenJnlLine', '', false, false)]
    local procedure OnAfterCopyEmployeeLedgerEntryFromGenJnlLine(var EmployeeLedgerEntry: Record "Employee Ledger Entry"; GenJournalLine: Record "Gen. Journal Line")
    begin
        EmployeeLedgerEntry."Specific Symbol CZL" := GenJournalLine."Specific Symbol CZL";
        EmployeeLedgerEntry."Variable Symbol CZL" := GenJournalLine."Variable Symbol CZL";
        EmployeeLedgerEntry."Constant Symbol CZL" := GenJournalLine."Constant Symbol CZL";
    end;
}