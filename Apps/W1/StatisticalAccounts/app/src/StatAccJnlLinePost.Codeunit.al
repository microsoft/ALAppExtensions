namespace Microsoft.Finance.Analysis.StatisticalAccount;

codeunit 2624 "Stat. Acc. Jnl. Line Post"
{
    TableNo = "Statistical Acc. Journal Line";

    trigger OnRun()
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.Copy(Rec);
        PostLine(StatisticalAccJournalLine);
        Rec.Copy(StatisticalAccJournalLine);
    end;

    internal procedure PostLine(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        LastStatisticalLedgerEntry: Record "Statistical Ledger Entry";
        StatAccTelemetry: Codeunit "Stat. Acc. Telemetry";
        NextEntryNo: Integer;
        TransactionNumber: Integer;
    begin
        StatAccTelemetry.LogPostingUsage();

        LastStatisticalLedgerEntry.LockTable();
        if LastStatisticalLedgerEntry.FindLast() then;
        NextEntryNo := LastStatisticalLedgerEntry."Entry No." + 1;
        TransactionNumber := LastStatisticalLedgerEntry."Transaction No." + 1;
        PostLine(StatisticalAccJournalLine, NextEntryNo, TransactionNumber);
    end;

    internal procedure PostLine(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var NextEntryNo: Integer; TransactionNumber: Integer)
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        StatisticalLedgerEntry."Entry No." := NextEntryNo;
        NextEntryNo += 1;
        StatisticalLedgerEntry."Transaction No." := TransactionNumber;
        TransferStatisticalAccJournalLineTo(StatisticalAccJournalLine, StatisticalLedgerEntry);
        OnBeforeInsertStatisticalLedgerEntry(StatisticalAccJournalLine, StatisticalLedgerEntry);
        StatisticalLedgerEntry.Insert(true);
    end;

    procedure TransferStatisticalAccJournalLineTo(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    begin
        StatisticalLedgerEntry."Statistical Account No." := StatisticalAccJournalLine."Statistical Account No.";
        StatisticalLedgerEntry."Posting Date" := StatisticalAccJournalLine."Posting Date";
        StatisticalLedgerEntry.Description := StatisticalAccJournalLine.Description;
        StatisticalLedgerEntry.Amount := StatisticalAccJournalLine.Amount;
        StatisticalLedgerEntry."Journal Batch Name" := StatisticalAccJournalLine."Journal Batch Name";
        StatisticalLedgerEntry."Dimension Set ID" := StatisticalAccJournalLine."Dimension Set ID";
        StatisticalLedgerEntry."Document No." := StatisticalAccJournalLine."Document No.";
        StatisticalLedgerEntry."Global Dimension 1 Code" := StatisticalAccJournalLine."Shortcut Dimension 1 Code";
        StatisticalLedgerEntry."Global Dimension 2 Code" := StatisticalAccJournalLine."Shortcut Dimension 2 Code";
        OnAfterTransferStatisticalAccJournalLineTo(StatisticalAccJournalLine, StatisticalLedgerEntry);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInsertStatisticalLedgerEntry(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterTransferStatisticalAccJournalLineTo(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
    begin
    end;
}