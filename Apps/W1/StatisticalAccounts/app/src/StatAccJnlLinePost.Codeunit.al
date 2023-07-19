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
        LastEntryNo: Integer;
        TransactionNumber: Integer;
    begin
        StatAccTelemetry.LogPostingUsage();

        LastStatisticalLedgerEntry.LockTable();
        if LastStatisticalLedgerEntry.FindLast() then;
        LastEntryNo := LastStatisticalLedgerEntry."Entry No.";
        TransactionNumber := LastStatisticalLedgerEntry."Transaction No." + 1;
        PostLine(StatisticalAccJournalLine, LastEntryNo, TransactionNumber);
    end;

    internal procedure PostLine(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var NextEntryNo: Integer; TransactionNumber: Integer)
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        StatisticalLedgerEntry."Entry No." := NextEntryNo;
        NextEntryNo += 1;
        StatisticalLedgerEntry."Transaction No." := TransactionNumber;
        TransferStatisticalAccJournalLineTo(StatisticalAccJournalLine, StatisticalLedgerEntry);
        StatisticalLedgerEntry.Insert(true);
    end;

    local procedure TransferStatisticalAccJournalLineTo(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var StatisticalLedgerEntry: Record "Statistical Ledger Entry")
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
    end;
}