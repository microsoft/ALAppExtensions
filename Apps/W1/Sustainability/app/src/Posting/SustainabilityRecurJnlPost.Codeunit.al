namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.NoSeries;

codeunit 6214 "Sustainability Recur Jnl.-Post"
{
    TableNo = "Sustainability Jnl. Line";
    Permissions =
        tabledata "Sustainability Jnl. Line" = rm,
        tabledata "Sustainability Jnl. Batch" = r;

    trigger OnRun()
    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        NoSeriesCode: Code[20];
    begin
        Rec.LockTable();

        CheckAndMarkRecurringLinesBeforePosting(Rec);

        NoSeriesCode := SustainabilityPostMgt.GetNoSeriesFromJournalLine(Rec);

        if Rec.FindSet() then
            repeat
                Rec.Validate("Document No.", NoSeriesMgt.DoGetNextNo(NoSeriesCode, Rec."Posting Date", true, false));
                SustainabilityPostMgt.InsertLedgerEntry(Rec);

                ProcessRecurringJournalLine(Rec);
            until Rec.Next() = 0;
    end;

    // Could be replaced by running codeunit "Check Sustainability Jnl. Line", but need to check for recurring specific fields
    local procedure CheckAndMarkRecurringLinesBeforePosting(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
    begin
        SustainabilityJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityJnlLine);

        if SustainabilityJnlLine.FindSet() then
            repeat
                // Posting Date needs to be checked before IsExpiredJournalLine is called
                SustainabilityJnlLine.TestField("Posting Date");

                if not IsExpiredJournalLine(SustainabilityJnlLine) then begin
                    SustainabilityJnlLine.TestField("Recurring Method");
                    SustainabilityJnlLine.TestField("Recurring Frequency");

                    SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJnlLine);
                    SustainabilityJnlLine.Mark(true);
                end;
            until SustainabilityJnlLine.Next() = 0;

        SustainabilityJnlLine.MarkedOnly(true);

        if SustainabilityJnlLine.IsEmpty() then
            Error(AllRecurringLinesExpiredErr);
    end;

    local procedure ProcessRecurringJournalLine(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        if SustainabilityJnlLine."Recurring Method" = Enum::"Sustain. Jnl. Recur. Method"::"V Variable" then
            ClearAmountOnRecurringJournalLines(SustainabilityJnlLine);

        SustainabilityJnlLine.Validate("Posting Date", CalcDate(SustainabilityJnlLine."Recurring Frequency", SustainabilityJnlLine."Posting Date"));

        SustainabilityJnlLine.Modify(true);
    end;

    local procedure ClearAmountOnRecurringJournalLines(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    begin
        SustainabilityJnlLine.Validate("Fuel/Electricity", 0);
        SustainabilityJnlLine.Validate(Distance, 0);
        SustainabilityJnlLine.Validate("Custom Amount", 0);
        SustainabilityJnlLine.Validate("Installation Multiplier", 0);
        SustainabilityJnlLine.Validate("Time Factor", 0);
    end;

    local procedure IsExpiredJournalLine(SustainabilityJnlLine: Record "Sustainability Jnl. Line"): Boolean
    begin
        if SustainabilityJnlLine."Expiration Date" = 0D then
            exit(false);

        exit(SustainabilityJnlLine."Posting Date" >= SustainabilityJnlLine."Expiration Date")
    end;

    var
        AllRecurringLinesExpiredErr: Label 'All recurring lines are expired, please check the Expiration Date and Posting Date set on each recurring journal lines.';
}