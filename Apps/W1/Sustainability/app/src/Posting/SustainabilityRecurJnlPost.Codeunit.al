namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.NoSeries;
using System.Utilities;

codeunit 6214 "Sustainability Recur Jnl.-Post"
{
    TableNo = "Sustainability Jnl. Line";

    trigger OnRun()
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        ConfirmManagement: Codeunit "Confirm Management";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        Window: Dialog;
    begin
        if not ConfirmManagement.GetResponseOrDefault(SustainabilityPostMgt.GetPostConfirmMessage(), true) then
            exit;

        Rec.LockTable();

        if GuiAllowed() then
            Window.Open(SustainabilityPostMgt.GetStartPostingProgressMessage());

        CheckAndMarkRecurringLinesBeforePosting(Rec, Window);

        SustainabilityJnlBatch.Get(Rec."Journal Template Name", Rec."Journal Batch Name");

        if Rec.FindSet() then
            repeat
                if GuiAllowed() then
                    Window.Update(1, SustainabilityPostMgt.GetProgressingLineMessage(Rec."Line No."));

                Rec.Validate("Document No.", NoSeriesBatch.GetNextNo(SustainabilityJnlBatch."No Series", Rec."Posting Date"));
                SustainabilityPostMgt.InsertLedgerEntry(Rec);

                ProcessRecurringJournalLine(Rec);
            until Rec.Next() = 0;

        NoSeriesBatch.SaveState();

        if GuiAllowed() then begin
            Window.Close();
            Message(SustainabilityPostMgt.GetJnlLinesPostedMessage());
        end;

        SustainabilityPostMgt.ResetFilters(Rec);
    end;

    local procedure CheckAndMarkRecurringLinesBeforePosting(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var DialogInstance: Dialog)
    var
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityJnlLine);

        if SustainabilityJnlLine.FindSet() then
            repeat
                if GuiAllowed() then
                    DialogInstance.Update(1, SustainabilityPostMgt.GetCheckJournalLineProgressMessage(SustainabilityJnlLine."Line No."));

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

        if SustainabilityJnlLine.IsEmpty() then begin
            SustainabilityJnlLine.MarkedOnly(false);
            Error(AllRecurringLinesExpiredErr, SustainabilityJnlLine.FieldCaption("Expiration Date"), SustainabilityJnlLine.FieldCaption("Posting Date"));
        end;
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
        AllRecurringLinesExpiredErr: Label 'All recurring lines are expired, please check the %1 and %2 set on each recurring journal lines.', Comment = '%1 = Expiration Date Field Caption, %2 = Posting Date Field Caption';
}