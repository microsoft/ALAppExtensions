namespace Microsoft.Finance.Analysis.StatisticalAccount;

codeunit 2626 "Stat. Acc. Post. Batch"
{
    TableNo = "Statistical Acc. Journal Line";

    trigger OnRun()
    var
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccJournalLine.Copy(Rec);
        PostJournal(StatisticalAccJournalLine);
        Rec.Copy(StatisticalAccJournalLine);
    end;

    local procedure PostJournal(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        IsHandled: Boolean;
    begin
        OnBeforePostJournal(StatisticalAccJournalLine, IsHandled);
        if IsHandled then
            exit;

        StatisticalAccJournalLine.SetRange("Journal Template Name", StatisticalAccJournalLine."Journal Template Name");
        StatisticalAccJournalLine.SetRange("Journal Batch Name", StatisticalAccJournalLine."Journal Batch Name");
        if StatisticalAccJournalLine.IsEmpty() then
            Error(NotingToPostErr);

        StatisticalAccJournalLine.LockTable();
        VerifyLines(StatisticalAccJournalLine);
        ProcessLines(StatisticalAccJournalLine);
        StatisticalAccJournalLine.DeleteAll();

        Commit();

        if not DoNotShowUI then
            if GuiAllowed() then
                Message(JournalLinesWereSuccesfullyRegisteredMsg);
    end;

    local procedure VerifyLines(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        BackupStatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        StatAccJnlCheckLine: Codeunit "Stat. Acc. Jnl Check Line";
    begin
        BackupStatisticalAccJournalLine.Copy(StatisticalAccJournalLine);
        if not StatisticalAccJournalLine.FindSet() then
            exit;

        repeat
            StatAccJnlCheckLine.RunCheck(StatisticalAccJournalLine);
        until StatisticalAccJournalLine.Next() = 0;
        StatisticalAccJournalLine.Copy(BackupStatisticalAccJournalLine);
    end;

    local procedure ProcessLines(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        BackupStatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        LastStatisticalLedgerEntry: Record "Statistical Ledger Entry";
        StatAccJnlLinePost: Codeunit "Stat. Acc. Jnl. Line Post";
    begin
        BackupStatisticalAccJournalLine.Copy(StatisticalAccJournalLine);
        LastStatisticalLedgerEntry.LockTable();
        InitNextEntryNo();

        if StatisticalAccJournalLine.FindSet() then begin
            repeat
                StatAccJnlLinePost.PostLine(StatisticalAccJournalLine, NextEntryNo, NextTransactionNo);
            until StatisticalAccJournalLine.Next() = 0;
            Commit();
        end;
        StatisticalAccJournalLine.Copy(BackupStatisticalAccJournalLine);
    end;

    local procedure InitNextEntryNo()
    var
        LastStatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        LastStatisticalLedgerEntry.LockTable();
        if LastStatisticalLedgerEntry.FindLast() then;
        NextEntryNo := LastStatisticalLedgerEntry."Entry No." + 1;
        NextTransactionNo := LastStatisticalLedgerEntry."Transaction No." + 1;
    end;

    internal procedure SetDoNotShowUI(NewDoNotShowUI: Boolean)
    begin
        DoNotShowUI := NewDoNotShowUI;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforePostJournal(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line"; var IsHandled: Boolean)
    begin
    end;

    var
        DoNotShowUI: Boolean;
        NextEntryNo: Integer;
        NextTransactionNo: Integer;
        JournalLinesWereSuccesfullyRegisteredMsg: Label 'The journal lines were successfully registered.';
        NotingToPostErr: Label 'There is nothing to register.';
}
