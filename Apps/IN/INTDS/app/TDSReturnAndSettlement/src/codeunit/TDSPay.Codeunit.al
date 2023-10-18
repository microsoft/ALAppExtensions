// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TDS.TDSReturnAndSettlement;

using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.TDS.TDSBase;
using Microsoft.Finance.GeneralLedger.Ledger;
using System.Utilities;
using Microsoft.Finance.TDS.TDSOnPayments;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 18746 "TDS Pay"
{
    procedure PayTDS(var GenJnlLine: Record "Gen. Journal Line")
    var
        TDSEntry: Record "TDS Entry";
        PagePayTDS: Page "Pay TDS";
        AccountNoErr: Label 'There are no TDS entries for Account No. %1.', Comment = '%1 = G/L Account No.';
    begin
        GenJnlLine.TestField("Document No.");
        GenJnlLine.TestField("Account No.");
        GenJnlLine.TestField("T.A.N. No.");

        GenJnlLine."Pay TDS" := true;
        GenJnlLine.Modify();

        Clear(PagePayTDS);
        TDSEntry.Reset();
        TDSEntry.SetRange("Account No.", GenJnlLine."Account No.");
        TDSEntry.SetRange("T.A.N. No.", GenJnlLine."T.A.N. No.");
        TDSEntry.SetFilter("Total TDS Including SHE CESS", '<>%1', 0);
        TDSEntry.SetRange("TDS Paid", false);
        TDSEntry.SetRange(Reversed, false);
        if TDSEntry.IsEmpty then
            Error(AccountNoErr, GenJnlLine."Account No.");

        PagePayTDS.SetProperties(GenJnlLine."Journal Batch Name", GenJnlLine."Journal Template Name", GenJnlLine."Line No.");
        PagePayTDS.SetTableView(TDSEntry);
        PagePayTDS.Run();
    end;

    [EventSubscriber(ObjectType::Table, database::"Reversal Entry", 'OnBeforeReverseEntries', '', false, false)]
    local procedure OnBeforeReverseEntries(Number: Integer; RevType: Integer; var IsHandled: Boolean)
    var
        TDSEntry: Record "TDS Entry";
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
        TransactionNo: Integer;
        ClosedErr: Label 'You cannot reverse %1 No. %2 because the entry is closed.', Comment = '%1= Table Caption, %2= Entry No.';
        AlreadyReversedErr: Label 'You cannot reverse %1 No. %2 because the entry has already been involved in a reversal.', Comment = '%1 = TDS Entry Table Caption, %2 = Entry No.';
    begin
        if RevType = 0 then
            TransactionNo := Number
        else
            if GLRegister.Get(Number) then begin
                GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
                if not GLEntry.FindFirst() then
                    exit
                else
                    TransactionNo := GLEntry."Transaction No.";
            end;

        TDSEntry.SetRange("Transaction No.", TransactionNo);
        if not TDSEntry.FindFirst() then
            exit;

        CheckPostingDate(
          TDSEntry."Posting Date", TDSEntry.TableCaption, TDSEntry."Entry No.");

        if TDSEntry."TDS Paid" then
            Error(
              ClosedErr, TDSEntry.TableCaption, TDSEntry."Entry No.");

        if TDSEntry.Reversed then
            Error(AlreadyReversedErr, TDSEntry.TableCaption, TDSEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Table, database::"Reversal Entry", 'OnAfterInsertReversalEntry', '', false, false)]
    local procedure InsertFromTDSEntry(
        var TempRevertTransactionNo: Record Integer;
        Number: Integer;
        RevType: Option Transaction,Register;
        var NextLineNo: Integer;
        var TempReversalEntry: Record "Reversal Entry")
    var
        TDSEntry: Record "TDS Entry";
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
        ProvEntReversalMgt: Codeunit "Provisional Entry Reversal Mgt";
        TransactionNo: Integer;
    begin
        TempRevertTransactionNo.FindSet();
        repeat
            if RevType = RevType::Transaction then
                TransactionNo := TempRevertTransactionNo.Number
            else
                if GLRegister.Get(TempRevertTransactionNo.Number) then begin
                    GLEntry.SetRange("Entry No.", GLRegister."From Entry No.", GLRegister."To Entry No.");
                    if not GLEntry.FindFirst() then
                        exit
                    else
                        TransactionNo := GLEntry."Transaction No.";
                end;

            if RevType <> RevType::Transaction then
                exit;

            TDSEntry.SetRange("Transaction No.", TransactionNo);
            if TDSEntry.FindSet() then
                repeat
                    Clear(TempReversalEntry);
                    if RevType = RevType::Register then
                        TempReversalEntry."G/L Register No." := Number;
                    TempReversalEntry."Reversal Type" := RevType;
                    TempReversalEntry."Posting Date" := TDSEntry."Posting Date";
                    TempReversalEntry."Source Code" := TDSEntry."Source Code";
                    TempReversalEntry."Transaction No." := TDSEntry."Transaction No.";
                    TempReversalEntry.Amount := TDSEntry."Total TDS Including SHE CESS";
                    TempReversalEntry."Amount (LCY)" := TDSEntry."Total TDS Including SHE CESS";
                    TempReversalEntry."Document Type" := TDSEntry."Document Type";
                    TempReversalEntry."Document No." := TDSEntry."Document No.";
                    TempReversalEntry."Entry No." := TDSEntry."Entry No.";
                    TempReversalEntry.Description := CopyStr(TDSEntry.TableCaption, 1, 50);
                    TempReversalEntry."Line No." := NextLineNo;
                    NextLineNo := NextLineNo + 1;
                    TempReversalEntry.Insert();
                until TDSEntry.Next() = 0;
        until TempRevertTransactionNo.Next() = 0;

        if ProvEntReversalMgt.GetReverseProvEntWithoutTDS() then begin
            TempReversalEntry.SetRange("Bal. Account No.", '');
            TempReversalEntry.DeleteAll();
            TempReversalEntry.SetRange("Bal. Account No.");
            if TempReversalEntry.FindSet() then;
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseOnBeforeFinishPosting', '', false, false)]
    local procedure ReverseTDS(var ReversalEntry: Record "Reversal Entry"; var GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line")
    var
        TDSEntry: Record "TDS Entry";
        NewTDSEntry: Record "TDS Entry";
        ReversedTDSEntry: Record "TDS Entry";
        ProvEntReversalMgt: Codeunit "Provisional Entry Reversal Mgt";
        CannotReverseErr: Label 'You cannot reverse the transaction, because it has already been reversed.';
    begin
        if ProvEntReversalMgt.GetReverseProvEntWithoutTDS() then
            exit;

        TDSEntry.SetRange("Transaction No.", ReversalEntry."Transaction No.");
        if TDSEntry.FindSet() then
            repeat
                if TDSEntry."Reversed by Entry No." <> 0 then
                    Error(CannotReverseErr);

                NewTDSEntry := TDSEntry;
                NewTDSEntry."Entry No." := 0;
                NewTDSEntry."TDS Base Amount" := -NewTDSEntry."TDS Base Amount";
                NewTDSEntry."TDS Amount" := -NewTDSEntry."TDS Amount";
                NewTDSEntry."Surcharge Base Amount" := -NewTDSEntry."Surcharge Base Amount";
                NewTDSEntry."Surcharge Amount" := -NewTDSEntry."Surcharge Amount";
                NewTDSEntry."TDS Amount Including Surcharge" := -NewTDSEntry."TDS Amount Including Surcharge";
                NewTDSEntry."eCESS Amount" := -NewTDSEntry."eCESS Amount";
                NewTDSEntry."SHE Cess Amount" := -NewTDSEntry."SHE Cess Amount";
                NewTDSEntry."Total TDS Including SHE CESS" := -NewTDSEntry."Total TDS Including SHE CESS";
                NewTDSEntry."Bal. TDS Including SHE CESS" := -NewTDSEntry."Bal. TDS Including SHE CESS";
                NewTDSEntry."Invoice Amount" := -NewTDSEntry."Invoice Amount";
                NewTDSEntry."Remaining TDS Amount" := -NewTDSEntry."Remaining TDS Amount";
                NewTDSEntry."Remaining Surcharge Amount" := -NewTDSEntry."Remaining Surcharge Amount";
                NewTDSEntry."TDS Line Amount" := -NewTDSEntry."TDS Line Amount";
                NewTDSEntry."Transaction No." := GenJnlPostLine.GetNextTransactionNo();
                NewTDSEntry."Source Code" := NewTDSEntry."Source Code";
                NewTDSEntry."User ID" := CopyStr(UserId, 1, 50);
                NewTDSEntry."Reversed Entry No." := TDSEntry."Entry No.";
                NewTDSEntry.Reversed := true;
                if TDSEntry."Reversed Entry No." <> 0 then begin
                    ReversedTDSEntry.Get(TDSEntry."Reversed Entry No.");
                    ReversedTDSEntry."Reversed by Entry No." := 0;
                    ReversedTDSEntry.Reversed := false;
                    ReversedTDSEntry.Modify();
                    TDSEntry."Reversed Entry No." := NewTDSEntry."Entry No.";
                    NewTDSEntry."Reversed by Entry No." := TDSEntry."Entry No.";
                end;
                NewTDSEntry.Insert();
                TDSEntry."Reversed by Entry No." := NewTDSEntry."Entry No.";
                TDSEntry.Reversed := true;
                TDSEntry.Modify();
            until TDSEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure PayTDSEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        TDSEntry: Record "TDS Entry";
    begin
        if GenJournalLine."Pay TDS" then begin
            TDSEntry.SetCurrentKey("Pay TDS Document No.");
            TDSEntry.SetRange("Pay TDS Document No.", GenJournalLine."Document No.");
            if TDSEntry.FindSet() then
                repeat
                    TDSEntry."TDS Payment Date" := GenJournalLine."Posting Date";
                    TDSEntry."TDS Paid" := true;
                    TDSEntry.Modify();
                until TDSEntry.Next() = 0;
        end;
    end;

    local procedure CheckPostingDate(PostingDate: Date; Caption: Text; EntryNo: Integer)
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
        PostingDateErr: Label 'You cannot reverse %1 No. %2 because the posting date is not within the allowed posting period.', Comment = '%1= Table Caption, %2= Entry No.';
    begin
        if GenJnlCheckLine.DateNotAllowed(PostingDate) then
            Error(PostingDateErr, Caption, EntryNo);
    end;
}
