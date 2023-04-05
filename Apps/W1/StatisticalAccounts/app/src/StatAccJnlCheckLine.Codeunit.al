codeunit 2623 "Stat. Acc. Jnl Check Line"
{
    TableNo = "Statistical Acc. Journal Line";

    trigger OnRun()
    begin
        RunCheck(Rec);
    end;

    internal procedure RunCheck(var StatisticalAccJournalLine: Record "Statistical Acc. Journal Line")
    var
        StatisticalAccount: Record "Statistical Account";
        DimensionManagement: Codeunit DimensionManagement;
        TableID: array[10] of Integer;
        No: array[10] of Code[20];
    begin
        StatisticalAccJournalLine.TestField("Statistical Account No.");
        StatisticalAccJournalLine.TestField(Amount);
        StatisticalAccount.Get(StatisticalAccJournalLine."Statistical Account No.");
        if StatisticalAccount.Blocked then
            Error(StatisticalAccountIsBlockedErr, StatisticalAccJournalLine."Statistical Account No.", StatisticalAccJournalLine."Line No.");

        No[1] := StatisticalAccount."No.";
        TableID[1] := DATABASE::"Statistical Account";
        if not DimensionManagement.CheckDimValuePosting(TableID, No, StatisticalAccJournalLine."Dimension Set ID") then
            Error(DimensionManagement.GetDimErr());
    end;

    var
        StatisticalAccountIsBlockedErr: Label 'Statistical account %1 is blocked. Journal line %2.', Comment = '%1 number of statistical account. %2 number of journal line';
}