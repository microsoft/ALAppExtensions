// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.NoSeries;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Purchases.Vendor;

codeunit 18748 "TDS Adjustment Post"
{
    var
        TempNoSeries: Record "No. Series" temporary;
        NoSeriesMgt2: array[10] of Codeunit NoSeriesManagement;
        DocNo: Code[20];
        CheckLineLbl: Label 'Checking lines        #1######\', Comment = '#1=Line check';
        PostLineLbl: Label 'Posting lines         #2###### @3@@@@@@@@@@@@@\', Comment = '#2=Post Line';
        JnlLinePostMsg: Label 'Journal lines posted successfully.';
        JnlBatchNameLbl: Label 'Journal Batch Name    #4##########\\', Comment = '#4=Journal Batch Name';
        PostTDSAdjQst: Label 'Do you want to post the journal lines?';
        PostingNoSeriesErr: Label 'A maximum of %1 posting number series can be used in each journal.', Comment = '%1 Posting Number Series.,';

    procedure PostTaxJournal(var TDSJournalLine: Record "TDS Journal Line")
    var
        TDSJnlLine: Record "TDS Journal Line";
        LineCount: Integer;
        Dialog: Dialog;
    begin
        if not Confirm(PostTDSAdjQst) then
            Error('');

        ClearAll();
        TDSJnlLine.Copy(TDSJournalLine);
        if TDSJnlLine.FindFirst() then begin
            Dialog.Open(JnlBatchNameLbl + CheckLineLbl + PostLineLbl);
            LineCount := 0;
        end;

        repeat
            CheckLine(TDSJnlLine);
            LineCount := LineCount + 1;
            Dialog.Update(4, TDSJnlLine."Journal Batch Name");
            Dialog.Update(1, LineCount);
        until TDSJnlLine.Next() = 0;

        LineCount := 0;
        if TDSJnlLine.FindFirst() then
            repeat
                PostGenJnlLine(TDSJnlLine);
                LineCount := LineCount + 1;
                Dialog.Update(4, TDSJnlLine."Journal Batch Name");
                Dialog.Update(2, LineCount);
                Dialog.Update(3, Round(LineCount / TDSJnlLine.Count() * 10000, 1));
            until TDSJnlLine.Next() = 0;

        TDSJnlLine.DeleteAll(true);
        Dialog.Close();
        Message(JnlLinePostMsg);
        TDSJournalLine := TDSJnlLine;
    end;

    procedure CheckLine(var TDSJournalLine: Record "TDS Journal Line")
    begin
        TDSJournalLine.TestField("Document No.");
        TDSJournalLine.TestField("Posting Date");
        TDSJournalLine.TestField("Account No.");
        TDSJournalLine.TestField("Bal. Account No.");
        TDSJournalLine.TestField(Amount);
    end;

    procedure PostGenJnlLine(var TDSJournalLine: Record "TDS Journal Line")
    begin
        if (TDSJournalLine."Journal Batch Name" = '') and (TDSJournalLine."Journal Template Name" = '') then
            DocNo := TDSJournalLine."Document No."
        else
            DocNo := CheckDocumentNo(TDSJournalLine);
        InitGenJnlLine(TDSJournalLine);
    end;

    procedure InitGenJnlLine(var TDSJournalLine: Record "TDS Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine."Journal Batch Name" := TDSJournalLine."Journal Batch Name";
        GenJournalLine."Journal Template Name" := TDSJournalLine."Journal Template Name";
        GenJournalLine."Line No." := TDSJournalLine."Line No.";
        GenJournalLine."Account Type" := TDSJournalLine."Account Type";
        GenJournalLine."Account No." := TDSJournalLine."Account No.";
        GenJournalLine."Posting Date" := TDSJournalLine."Posting Date";
        GenJournalLine."Document Type" := TDSJournalLine."Document Type";
        GenJournalLine."TDS Section Code" := TDSJournalLine."TDS Section Code";
        GenJournalLine."T.A.N. No." := TDSJournalLine."T.A.N. No.";
        GenJournalLine."Document No." := DocNo;
        GenJournalLine."Posting No. Series" := TDSJournalLine."Posting No. Series";
        GenJournalLine.Description := TDSJournalLine.Description;
        GenJournalLine."TDS Adjustment" := true;
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine.Validate(Amount, TDSJournalLine.Amount);
        GenJournalLine."Bal. Account Type" := TDSJournalLine."Bal. Account Type";
        GenJournalLine."Bal. Account No." := TDSJournalLine."Bal. Account No.";
        GenJournalLine."Shortcut Dimension 1 Code" := TDSJournalLine."Shortcut Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := TDSJournalLine."Shortcut Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := TDSJournalLine."Dimension Set ID";
        GenJournalLine."Source Code" := TDSJournalLine."Source Code";
        GenJournalLine."Reason Code" := TDSJournalLine."Reason Code";
        GenJournalLine."Document Date" := TDSJournalLine."Document Date";
        GenJournalLine."External Document No." := TDSJournalLine."External Document No.";
        GenJournalLine."Location Code" := TDSJournalLine."Location Code";
        if TDSJournalLine."TDS Base Amount" = 0 then
            GenJournalLine."Allow Zero-Amount Posting" := true;
        RunGenJnlPostLine(GenJournalLine);
    end;

    procedure CheckDocumentNo(TDSJournalLine: Record "TDS Journal Line"): Code[20]
    var
        TDSJournalBatch: Record "TDS Journal Batch";
        NoSeriesManagement: Codeunit NoSeriesManagement;
        PostingNoSeriesNo: Integer;
    begin
        if (TDSJournalLine."Journal Template Name" = '') and (TDSJournalLine."Journal Batch Name" = '') and (TDSJournalLine."Document No." <> '') then
            exit(TDSJournalLine."Document No.");

        TDSJournalBatch.Get(TDSJournalLine."Journal Template Name", TDSJournalLine."Journal Batch Name");
        if TDSJournalLine."Posting No. Series" = '' then begin
            TDSJournalLine."Posting No. Series" := TDSJournalBatch."No. Series";
            TDSJournalLine."Document No." := NoSeriesManagement.GetNextNo(TDSJournalLine."Posting No. Series", TDSJournalLine."Posting Date", true);
        end else begin
            InsertNoSeries(TDSJournalLine);
            Evaluate(PostingNoSeriesNo, TempNoSeries.Description);
            TDSJournalLine."Document No." :=
              NoSeriesMgt2[PostingNoSeriesNo].GetNextNo(TDSJournalLine."Posting No. Series", TDSJournalLine."Posting Date", true);
        end;

        exit(TDSJournalLine."Document No.");
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnCodeOnBeforeFinishPosting', '', false, false)]
    local procedure InsertTDSEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        sender: Codeunit "Gen. Jnl.-Post Line")
    var
        TDSEntry: Record "TDS Entry";
        TDSConcessionalCode: Record "TDS Concessional Code";
        Vendor: Record Vendor;
        TDSJournalLine: Record "TDS Journal Line";
    begin
        TDSJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        TDSJournalLine.SetRange("Line No.", GenJournalLine."Line No.");
        TDSJournalLine.SetRange("TDS Adjusted", true);
        if TDSJournalLine.FindFirst() then
            if (GenJournalLine."TDS Section Code" <> '') and (GenJournalLine."TDS Adjustment") then begin
                TDSEntry.Init();
                TDSEntry."Document No." := GenJournalLine."Document No.";
                TDSEntry."Posting Date" := GenJournalLine."Posting Date";
                TDSEntry."Account Type" := TDSEntry."Account Type"::"G/L Account";
                TDSEntry."Account No." := TDSJournalLine."Bal. Account No.";
                TDSEntry."Vendor No." := TDSJournalLine."Account No.";
                TDSEntry."Party Type" := TDSEntry."Party Type"::Vendor;
                TDSEntry."Party Account No." := TDSJournalLine."Account No.";
                TDSEntry.Section := GenJournalLine."TDS Section Code";
                TDSEntry."TDS Adjustment" := TDSJournalLine."TDS Adjustment";
                TDSEntry."Transaction No." := sender.GetNextTransactionNo();
                TDSEntry."TDS %" := TDSJournalLine."TDS %";
                TDSEntry."Surcharge %" := TDSJournalLine."Surcharge %";
                TDSEntry."eCESS %" := TDSJournalLine."eCESS %";
                TDSEntry."SHE Cess %" := TDSJournalLine."SHE Cess %";
                TDSEntry."Assessee Code" := TDSJournalLine."Assessee Code";
                TDSEntry."Concessional Code" := TDSJournalLine."Concessional Code";
                TDSEntry."TDS Adjustment" := GenJournalLine."TDS Adjustment";

                if Vendor.Get(TDSJournalLine."Account No.") then
                    TDSEntry."Deductee PAN No." := Vendor."P.A.N. No.";

                TDSEntry."TDS Base Amount" := TDSJournalLine."TDS Base Amount";
                TDSEntry."Invoice Amount" := Abs(TDSJournalLine."TDS Base Amount");
                TDSEntry."Surcharge Base Amount" := Abs(TDSJournalLine."Surcharge Base Amount");
                TDSEntry."TDS Line Amount" := TDSJournalLine.Amount;
                TDSEntry."User ID" := CopyStr(UserId, 1, 50);
                TDSEntry."Concessional Code" := TDSJournalLine."Concessional Code";
                TDSConcessionalCode.SetRange(Section, GenJournalLine."TDS Section Code");
                TDSConcessionalCode.SetRange("Vendor No.", TDSJournalLine."Account No.");
                if TDSConcessionalCode.FindFirst() then
                    TDSEntry."Concessional Form No." := TDSConcessionalCode."Certificate No.";

                TDSEntry."T.A.N. No." := GenJournalLine."T.A.N. No.";
                TDSEntry.TestField("T.A.N. No.");
                TDSEntry."Per Contract" := TDSJournalLine."Per Contract";
                TDSEntry."Original TDS Base Amount" := TDSEntry."TDS Base Amount";
                TDSEntry.Insert(true);
            end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure UpdateTDSEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        TDSJournalLine: Record "TDS Journal Line";
        TDSEntry: Record "TDS Entry";
    begin
        TDSJournalLine.SetRange("Journal Template Name", GenJournalLine."Journal Template Name");
        TDSJournalLine.SetRange("Journal Batch Name", GenJournalLine."Journal Batch Name");
        TDSJournalLine.SetRange("Line No.", GenJournalLine."Line No.");
        TDSJournalLine.SetRange(Adjustment, true);
        if not TDSJournalLine.FindFirst() then
            exit;

        TDSEntry.SetRange("Entry No.", TDSJournalLine."TDS Transaction No.");
        TDSEntry.SetRange("Document No.", TDSJournalLine."TDS Invoice No.");
        if not TDSEntry.FindFirst() then
            exit;

        TDSEntry.TestField("TDS Paid", false);
        TDSEntry."Challan Date" := TDSJournalLine."Challan Date";
        TDSEntry."Challan No." := TDSJournalLine."Challan No.";

        UpdateTDSPercent(TDSEntry, TDSJournalLine);
        UpdateSurchargePercent(TDSEntry, TDSJournalLine);
        UpdateECessPercent(TDSEntry, TDSJournalLine);
        UpdateSHECessPercent(TDSEntry, TDSJournalLine);

        if (TDSJournalLine."Balance TDS Amount" <> 0) or TDSJournalLine."TDS Adjusted" then
            TDSEntry."TDS Amount" := TDSJournalLine."Balance TDS Amount";

        if (TDSJournalLine."Balance Surcharge Amount" <> 0) or TDSJournalLine."Surcharge Adjusted" then
            TDSEntry."Surcharge Amount" := TDSJournalLine."Balance Surcharge Amount";

        if (TDSJournalLine."Balance eCESS on TDS Amt" <> 0) or TDSJournalLine."TDS eCess Adjusted" then
            TDSEntry."eCESS Amount" := TDSJournalLine."Balance eCESS on TDS Amt";

        if (TDSJournalLine."Bal. SHE Cess on TDS Amt" <> 0) or TDSJournalLine."TDS SHE Cess Adjusted" then
            TDSEntry."SHE Cess Amount" := TDSJournalLine."Bal. SHE Cess on TDS Amt";

        TDSEntry."Remaining TDS Amount" := TDSEntry."TDS Amount";
        TDSEntry."Remaining Surcharge Amount" := TDSEntry."Surcharge Amount";
        TDSEntry."TDS Amount Including Surcharge" := TDSEntry."TDS Amount" + TDSEntry."Surcharge Amount";
        TDSEntry."Total TDS Including SHE CESS" := TDSJournalLine."Bal. TDS Including SHE CESS";
        TDSEntry."Bal. TDS Including SHE CESS" := TDSJournalLine."Bal. TDS Including SHE CESS";
        TDSEntry.Adjusted := TDSJournalLine.Adjustment;
        if TDSJournalLine."TDS Base Amount Adjusted" then begin
            TDSEntry."TDS Base Amount" := TDSJournalLine."TDS Base Amount Applied";
            TDSEntry."Invoice Amount" := TDSEntry."TDS Base Amount";
            TDSEntry."TDS Base Amount Adjusted" := TDSJournalLine."TDS Base Amount Adjusted";
            TDSEntry."Surcharge Base Amount" := TDSJournalLine."Surcharge Base Amount";
        end;

        if TDSJournalLine."TDS Adjusted" then
            TDSEntry."Surcharge Base Amount" := TDSJournalLine."Surcharge Base Amount";

        TDSEntry.Modify()
    end;

    local procedure UpdateTDSPercent(var TDSEntry: Record "TDS Entry"; TDSJournalLine: Record "TDS Journal Line")
    begin
        if TDSJournalLine."TDS % Applied" <> 0 then
            TDSEntry."Adjusted TDS %" := TDSJournalLine."TDS % Applied"
        else
            if (TDSJournalLine."TDS Adjusted") and (TDSJournalLine."TDS % Applied" = 0) then
                TDSEntry."Adjusted TDS %" := TDSJournalLine."TDS % Applied"
            else
                if (not TDSJournalLine."TDS Adjusted") and (TDSJournalLine."TDS % Applied" = 0) then
                    TDSEntry."Adjusted TDS %" := TDSEntry."TDS %";
    end;

    local procedure UpdateSurchargePercent(var TDSEntry: Record "TDS Entry"; TDSJournalLine: Record "TDS Journal Line")
    begin
        if TDSJournalLine."Surcharge % Applied" <> 0 then
            TDSEntry."Adjusted Surcharge %" := TDSJournalLine."Surcharge % Applied"
        else
            if (TDSJournalLine."Surcharge Adjusted") and (TDSJournalLine."Surcharge % Applied" = 0) then
                TDSEntry."Adjusted Surcharge %" := TDSJournalLine."Surcharge % Applied"
            else
                if (not TDSJournalLine."Surcharge Adjusted") and (TDSJournalLine."Surcharge % Applied" = 0) then
                    TDSEntry."Adjusted Surcharge %" := TDSEntry."Surcharge %";
    end;

    local procedure UpdateECessPercent(var TDSEntry: Record "TDS Entry"; TDSJournalLine: Record "TDS Journal Line")
    begin
        if TDSJournalLine."eCESS % Applied" <> 0 then
            TDSEntry."Adjusted eCESS %" := TDSJournalLine."eCESS % Applied"
        else
            if (TDSJournalLine."TDS eCess Adjusted") and (TDSJournalLine."eCESS % Applied" = 0) then
                TDSEntry."Adjusted eCESS %" := TDSJournalLine."eCESS % Applied"
            else
                if (not TDSJournalLine."TDS eCess Adjusted") and (TDSJournalLine."eCESS % Applied" = 0) then
                    TDSEntry."Adjusted eCESS %" := TDSEntry."eCESS %";
    end;

    local procedure UpdateSHECessPercent(var TDSEntry: Record "TDS Entry"; TDSJournalLine: Record "TDS Journal Line")
    begin
        if TDSJournalLine."SHE Cess % Applied" <> 0 then
            TDSEntry."Adjusted SHE CESS %" := TDSJournalLine."SHE Cess % Applied"
        else
            if (TDSJournalLine."TDS SHE Cess Adjusted") and (TDSJournalLine."SHE Cess % Applied" = 0) then
                TDSEntry."Adjusted SHE CESS %" := TDSJournalLine."SHE Cess % Applied"
            else
                if (not TDSJournalLine."TDS SHE Cess Adjusted") and (TDSJournalLine."SHE Cess % Applied" = 0) then
                    TDSEntry."Adjusted SHE CESS %" := TDSEntry."SHE Cess %";
    end;

    local procedure RunGenJnlPostLine(var GenJournalLine: Record "Gen. Journal Line")
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlPostLine.RunWithCheck(GenJournalLine);
    end;

    local procedure InsertNoSeries(TDSJournalLine: Record "TDS Journal Line")
    var
        NoOfPostingNoSeries: Integer;
    begin
        if TempNoSeries.Get(TDSJournalLine."Posting No. Series") then
            exit;

        NoOfPostingNoSeries := NoOfPostingNoSeries + 1;
        if NoOfPostingNoSeries > ArrayLen(NoSeriesMgt2) then
            Error(PostingNoSeriesErr, ArrayLen(NoSeriesMgt2));

        TempNoSeries.Init();
        TempNoSeries.Code := TDSJournalLine."Posting No. Series";
        TempNoSeries.Description := Format(NoOfPostingNoSeries);
        TempNoSeries.Insert();
    end;
}
