// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Sustainability.ExciseTax;

using Microsoft.Foundation.NoSeries;
using System.Utilities;

codeunit 6271 "Sust. Excise Jnl.-Post"
{
    TableNo = "Sust. Excise Jnl. Line";

    trigger OnRun()
    var
        ConfirmManagement: Codeunit "Confirm Management";
        SustainabilityExcisePostMgt: Codeunit "Sustainability Excise Post Mgt";
        Window: Dialog;
        ShowConfirmDialog: Boolean;
    begin
        ShowConfirmDialog := true;
        OnBeforeConfirmDialog(ShowConfirmDialog);
        if ShowConfirmDialog then
            if not ConfirmManagement.GetResponseOrDefault(SustainabilityExcisePostMgt.GetPostConfirmMessage(), true) then
                exit;

        Rec.LockTable();

        if GuiAllowed() then
            Window.Open(SustainabilityExcisePostMgt.GetStartPostingProgressMessage());

        CheckJournalLinesBeforePosting(Rec, Window);

        ProcessLines(Rec, Window);

        Rec.DeleteAll(true);

        if GuiAllowed() then begin
            Window.Close();
            Message(SustainabilityExcisePostMgt.GetJnlLinesPostedMessage());
        end;

        SustainabilityExcisePostMgt.ResetFilters(Rec);
    end;

    local procedure CheckJournalLinesBeforePosting(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var DialogInstance: Dialog)
    var
        SustainabilityExciseJnlCheck: Codeunit "Sust. Excise Jnl.-Check";
        SustainabilityExcisePostMgt: Codeunit "Sustainability Excise Post Mgt";
    begin
        SustainabilityExciseJnlCheck.CheckCommonConditionsBeforePosting(SustainabilityExciseJnlLine);

        if SustainabilityExciseJnlLine.FindSet() then
            repeat
                if GuiAllowed() then
                    DialogInstance.Update(1, SustainabilityExcisePostMgt.GetCheckJournalLineProgressMessage(SustainabilityExciseJnlLine."Line No."));

                SustainabilityExciseJnlCheck.CheckSustainabilityExciseJournalLine(SustainabilityExciseJnlLine);
            until SustainabilityExciseJnlLine.Next() = 0;
    end;

    local procedure ProcessLines(var SustainabilityExciseJnlLine: Record "Sust. Excise Jnl. Line"; var DialogInstance: Dialog)
    var
        SustainabilityExciseJnlBatch: Record "Sust. Excise Journal Batch";
        SustainabilityExcisePostMgt: Codeunit "Sustainability Excise Post Mgt";
        NoSeriesBatch: Codeunit "No. Series - Batch";
        PreviousDocumentNo: Code[20];
    begin
        SustainabilityExciseJnlBatch.Get(SustainabilityExciseJnlLine."Journal Template Name", SustainabilityExciseJnlLine."Journal Batch Name");
        PreviousDocumentNo := '';

        if SustainabilityExciseJnlLine.FindSet() then
            repeat
                if GuiAllowed() then
                    DialogInstance.Update(1, SustainabilityExcisePostMgt.GetProgressingLineMessage(SustainabilityExciseJnlLine."Line No."));

                if PreviousDocumentNo <> SustainabilityExciseJnlLine."Document No." then
                    if SustainabilityExciseJnlLine."Document No." = NoSeriesBatch.PeekNextNo(SustainabilityExciseJnlBatch."No Series", SustainabilityExciseJnlLine."Posting Date") then
                        NoSeriesBatch.GetNextNo(SustainabilityExciseJnlBatch."No Series", SustainabilityExciseJnlLine."Posting Date")
                    else
                        NoSeriesBatch.TestManual(SustainabilityExciseJnlBatch."No Series", SustainabilityExciseJnlLine."Document No.");

                PreviousDocumentNo := SustainabilityExciseJnlLine."Document No.";

                SustainabilityExciseJnlLine.UpdateSustainabilityJnlLineWithPostingSign(SustainabilityExciseJnlLine, SustainabilityExciseJnlLine.GetPostingSign(SustainabilityExciseJnlLine));

                SustainabilityExcisePostMgt.InsertExciseTaxesTransactionLog(SustainabilityExciseJnlLine);
            until SustainabilityExciseJnlLine.Next() = 0;

        NoSeriesBatch.SaveState();
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeConfirmDialog(var ShowConfirmDialog: Boolean)
    begin
    end;
}