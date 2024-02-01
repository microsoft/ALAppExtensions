namespace Microsoft.Sustainability.Posting;

using Microsoft.Sustainability.Journal;
using Microsoft.Foundation.NoSeries;

codeunit 6213 "Sustainability Jnl.-Post"
{
    TableNo = "Sustainability Jnl. Line";
    Permissions =
        tabledata "Sustainability Jnl. Line" = rd,
        tabledata "Sustainability Jnl. Batch" = r;

    trigger OnRun()
    var
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        IsManualNo: Boolean;
    begin
        Rec.LockTable();

        // sort journal lines by Document No. to ensure that the No. Series is processed in the correct order
        Rec.SetCurrentKey("Document No.");

        IsManualNo := CheckAndFindIfManualNoBeforePosting(Rec);

        if not IsManualNo then
            ProcessNoSeriesOnJournalLines(Rec);

        if Rec.FindSet() then
            repeat
                SustainabilityPostMgt.InsertLedgerEntry(Rec);
            until Rec.Next() = 0;

        Rec.DeleteAll(true);
    end;

    // Could be replaced by running codeunit "Check Sustainability Jnl. Line", but need to check for manual No. Series
    local procedure CheckAndFindIfManualNoBeforePosting(var SustainabilityJnlLine: Record "Sustainability Jnl. Line") IsManualNo: Boolean
    var
        SustainabilityJnlBatch: Record "Sustainability Jnl. Batch";
        SustainabilityJnlCheck: Codeunit "Sustainability Jnl.-Check";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        PreviousDocumentNo: Code[20];
    begin
        SustainabilityJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityJnlLine);

        SustainabilityJnlBatch.Get(SustainabilityJnlLine."Journal Template Name", SustainabilityJnlLine."Journal Batch Name");

        if SustainabilityJnlLine.FindSet() then
            repeat
                if IsNoSeriesLineChanged(SustainabilityJnlBatch."No Series", SustainabilityJnlLine."Posting Date", NoSeriesMgt) then
                    PreviousDocumentNo := '';

                if (PreviousDocumentNo = '') or (SustainabilityJnlLine."Document No." <> PreviousDocumentNo) then
                    if not IsManualNo then
                        IsManualNo := (SustainabilityJnlLine."Document No." <> NoSeriesMgt.GetNextNo(SustainabilityJnlBatch."No Series", SustainabilityJnlLine."Posting Date", false));

                PreviousDocumentNo := SustainabilityJnlLine."Document No.";

                SustainabilityJnlCheck.CheckSustainabilityJournalLine(SustainabilityJnlLine);
            until SustainabilityJnlLine.Next() = 0;

        if IsManualNo then
            NoSeriesMgt.TestManual(SustainabilityJnlBatch."No Series");
    end;

    local procedure ProcessNoSeriesOnJournalLines(var SustainabilityJnlLine: Record "Sustainability Jnl. Line")
    var
        NoSeriesMgt: Codeunit NoSeriesManagement;
        SustainabilityPostMgt: Codeunit "Sustainability Post Mgt";
        NoSeriesCode: Code[20];
        PreviousDocumentNo: Code[20];
    begin
        NoSeriesCode := SustainabilityPostMgt.GetNoSeriesFromJournalLine(SustainabilityJnlLine);

        if SustainabilityJnlLine.FindSet() then
            repeat
                if IsNoSeriesLineChanged(NoSeriesCode, SustainabilityJnlLine."Posting Date", NoSeriesMgt) then
                    PreviousDocumentNo := '';

                if (PreviousDocumentNo = '') or (SustainabilityJnlLine."Document No." <> PreviousDocumentNo) then
                    if SustainabilityJnlLine."Document No." <> NoSeriesMgt.GetNextNo(NoSeriesCode, SustainabilityJnlLine."Posting Date", true) then
                        Error(ManualNoSeriesFoundDuringProcessingErr);

                PreviousDocumentNo := SustainabilityJnlLine."Document No.";
            until SustainabilityJnlLine.Next() = 0;
    end;

    local procedure IsNoSeriesLineChanged(NoSeriesCode: Code[20]; PostingDate: Date; var NoSeriesMgtInstance: Codeunit NoSeriesManagement): Boolean
    var
        NoSeriesLine: Record "No. Series Line";
    begin
        if NoSeriesMgtInstance.FindNoSeriesLine(NoSeriesLine, NoSeriesCode, PostingDate) then
            exit(not NoSeriesMgtInstance.IsCurrentNoSeriesLine(NoSeriesLine))
        else
            Error(NoSeriesLineNotFoundErr, NoSeriesCode, PostingDate);
    end;

    var
        NoSeriesLineNotFoundErr: Label 'No. Series Line not found for the No. Series Code %1 and Posting Date %2.', Comment = '%1 = No. Series Code, %2 = Posting Date';
        ManualNoSeriesFoundDuringProcessingErr: Label 'Manual No. Series found during processing.';
}