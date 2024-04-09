namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.NoSeries;
using System.Utilities;

codeunit 6213 "Sustainability Jnl.-Post"
{
    TableNo = "Sustainability Jnl. Line";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        Window: Dialog;
    begin
        if not ConfirmManagement.GetResponseOrDefault(SustainabilityPostMgt.GetPostConfirmMessage(), true) then
            exit;

        Rec.LockTable();

        if GuiAllowed() then
            Window.Open(SustainabilityPostMgt.GetStartPostingProgressMessage());

        CheckJournalLinesBeforePosting(Rec, Window);

        ProcessLines(Rec, Window);

        Rec.DeleteAll(true);

        if GuiAllowed() then begin
            Window.Close();
            Message(SustainabilityPostMgt.GetJnlLinesPostedMessage());
        end;

        SustainabilityPostMgt.ResetFilters(Rec);
    end;

    local procedure CheckJournalLinesBeforePosting(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var DialogInstance: Dialog)
    var
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
    begin
        SustainabilityJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityJnlLine);

        if SustainabilityJnlLine.FindSet() then
            repeat
                if GuiAllowed() then
                    DialogInstance.Update(1, SustainabilityPostMgt.GetCheckJournalLineProgressMessage(SustainabilityJnlLine."Line No."));

                SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJnlLine);
            until SustainabilityJnlLine.Next() = 0;
    end;

    local procedure ProcessLines(var SustainabilityJnlLine: Record "Sustainability Jnl. Line"; var DialogInstance: Dialog)
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        PreviousDocumentNo: Code[20];
    begin
        SustainabilityJnlBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name");
        PreviousDocumentNo := '';

        if SustainabilityJnlLine.FindSet() then
            repeat
                if GuiAllowed() then
                    DialogInstance.Update(1, SustainabilityPostMgt.GetProgressingLineMessage(SustainabilityJnlLine."Line No."));

                if PreviousDocumentNo <> SustainabilityJnlLine."Document No." then
                    if SustainabilityJnlLine."Document No." = NoSeriesBatch.PeekNextNo(SustainabilityJnlBatch."No Series", SustainabilityJnlLine."Posting Date") then
                        NoSeriesBatch.GetNextNo(SustainabilityJnlBatch."No Series", SustainabilityJnlLine."Posting Date")
                    else
                        NoSeriesBatch.TestManual(SustainabilityJnlBatch."No Series", SustainabilityJnlLine."Document No.");

                PreviousDocumentNo := SustainabilityJnlLine."Document No.";

                SustainabilityPostMgt.InsertLedgerEntry(SustainabilityJnlLine);
            until SustainabilityJnlLine.Next() = 0;

        NoSeriesBatch.SaveState();
    end;
}