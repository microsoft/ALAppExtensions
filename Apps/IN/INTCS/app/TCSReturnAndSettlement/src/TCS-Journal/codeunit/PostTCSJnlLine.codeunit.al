// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;

codeunit 18871 "Post-TCS Jnl. Line"
{
    var
        TempNoSeries: Record "No. Series" temporary;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        DocNo: Code[20];
        CheckLineLbl: Label 'Checking lines        #1######\', Comment = '#1=Line check';
        PostLineLbl: Label 'Posting lines         #2###### @3@@@@@@@@@@@@@\', Comment = '#2=Post Line';
        JnlLinePostMsg: Label 'Journal lines posted successfully.';
        JnlBatchNameLbl: Label 'Journal Batch Name    #4##########\\', Comment = '#4=Journal Batch Name';
        PostTCSAdjQst: Label 'Do you want to post the journal lines?';
        PostingNoSeriesErr: Label 'A maximum of %1 posting number series can be used in each journal.', Comment = '%1Posting Number Series.,';

    procedure PostTCSJournal(var TCSJournalLine: Record "TCS Journal Line")
    var
        CopyTCSJournalLine: Record "TCS Journal Line";
        LineCount: Integer;
        Dialog: Dialog;
    begin
        if not Confirm(PostTCSAdjQst) then
            Error('');

        CopyTCSJournalLine.Copy(TCSJournalLine);
        if CopyTCSJournalLine.FindFirst() then begin
            Dialog.Open(JnlBatchNameLbl + CheckLineLbl + PostLineLbl);
            LineCount := 0;
        end;
        repeat
            CheckLines(CopyTCSJournalLine);
            LineCount := LineCount + 1;
            Dialog.Update(4, CopyTCSJournalLine."Journal Batch Name");
            Dialog.Update(1, LineCount);
        until CopyTCSJournalLine.Next() = 0;

        LineCount := 0;
        if CopyTCSJournalLine.FindFirst() then
            repeat
                PostGenJnlLine(CopyTCSJournalLine);
                LineCount := LineCount + 1;
                Dialog.Update(4, CopyTCSJournalLine."Journal Batch Name");
                Dialog.Update(2, LineCount);
                Dialog.Update(3, Round(LineCount / CopyTCSJournalLine.Count() * 10000, 1));
            until CopyTCSJournalLine.Next() = 0;

        Clear(GenJnlPostLine);
        CopyTCSJournalLine.DeleteAll(true);
        Dialog.Close();
        Message(JnlLinePostMsg);
        TCSJournalLine := CopyTCSJournalLine;
    end;

    procedure CheckLines(var TCSJournalLine: Record "TCS Journal Line")
    begin
        TCSJournalLine.TestField("Document No.");
        TCSJournalLine.TestField("Posting Date");
        TCSJournalLine.TestField("Account No.");
        TCSJournalLine.TestField("Bal. Account No.");
        TCSJournalLine.TestField(Amount);
    end;

    procedure PostGenJnlLine(var TCSJournalLine: Record "TCS Journal Line")
    begin
        if (TCSJournalLine."Journal Batch Name" = '') and (TCSJournalLine."Journal Template Name" = '') then
            DocNo := TCSJournalLine."Document No."
        else
            DocNo := CheckDocumentNo(TCSJournalLine);

        InitGenJnlLine(TCSJournalLine);
    end;

    procedure InitGenJnlLine(var TCSJournalLine: Record "TCS Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine."Journal Batch Name" := TCSJournalLine."Journal Batch Name";
        GenJournalLine."Journal Template Name" := TCSJournalLine."Journal Template Name";
        GenJournalLine."Line No." := TCSJournalLine."Line No.";
        GenJournalLine."Account Type" := TCSJournalLine."Account Type";
        GenJournalLine."Account No." := TCSJournalLine."Account No.";
        GenJournalLine."Posting Date" := TCSJournalLine."Posting Date";
        GenJournalLine."Document Type" := TCSJournalLine."Document Type";
        GenJournalLine."Document No." := DocNo;
        GenJournalLine."Posting No. Series" := TCSJournalLine."Posting No. Series";
        GenJournalLine.Description := TCSJournalLine.Description;
        GenJournalLine.Validate(Amount, TCSJournalLine.Amount);
        GenJournalLine."Bal. Account Type" := TCSJournalLine."Bal. Account Type";
        GenJournalLine."Bal. Account No." := TCSJournalLine."Bal. Account No.";
        GenJournalLine."Shortcut Dimension 1 Code" := TCSJournalLine."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TCSJournalLine."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TCSJournalLine."Dimension Set ID";
        GenJournalLine."Document Date" := TCSJournalLine."Document Date";
        GenJournalLine."External Document No." := TCSJournalLine."External Document No.";
        GenJournalLine."Location Code" := TCSJournalLine."Location Code";
        GenJournalLine."Source Code" := TCSJournalLine."Source Code";
        GenJournalLine."System-Created Entry" := true;
        if TCSJournalLine."TCS Base Amount" = 0 then
            GenJournalLine."Allow Zero-Amount Posting" := true;
        RunGenJnlPostLine(GenJournalLine);
    end;

    procedure CheckDocumentNo(TCSJournalLine: Record "TCS Journal Line"): Code[20]
    var
        TCSJournalBatch: Record "TCS Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        PostingNoSeriesNo: Integer;
    begin
        if (TCSJournalLine."Journal Template Name" = '') and (TCSJournalLine."Journal Batch Name" = '') and (TCSJournalLine."Document No." <> '') then
            exit(TCSJournalLine."Document No.");

        TCSJournalBatch.Get(TCSJournalLine."Journal Template Name", TCSJournalLine."Journal Batch Name");
        if TCSJournalLine."Posting No. Series" = '' then begin
            TCSJournalLine."Posting No. Series" := TCSJournalBatch."No. Series";
            TCSJournalLine."Document No." := NoSeriesManagement.GetNextNo(TCSJournalLine."Posting No. Series", TCSJournalLine."Posting Date", true);
        end else begin
            InsertNoSeries(TCSJournalLine);
            Evaluate(PostingNoSeriesNo, TempNoSeries.Description);
            TCSJournalLine."Document No." :=
              NoSeriesMgt2[PostingNoSeriesNo].GetNextNo(TCSJournalLine."Posting No. Series", TCSJournalLine."Posting Date", true);
        end;

        exit(TCSJournalLine."Document No.");
    end;

    local procedure RunGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line")
    begin
        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InsertNoSeries(TCSJournalLine: Record "TCS Journal Line")
    var
        NoOfPostingNoSeries: Integer;
    begin
        if not TempNoSeries.Get(TCSJournalLine."Posting No. Series") then begin
            NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
            if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
                Error(PostingNoSeriesErr, ArrayLen(NoSeriesMgt2));

            TempNoSeries.Init();
            TempNoSeries.Code := TCSJournalLine."Posting No. Series";
            TempNoSeries.Description := Format(NoOfPostingNoSeries);
            TempNoSeries.Insert();
        end;
    end;
}
