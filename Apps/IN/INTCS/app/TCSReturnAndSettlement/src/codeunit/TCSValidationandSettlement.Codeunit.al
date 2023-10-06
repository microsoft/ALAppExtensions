// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TCS.TCSReturnAndSettlement;

using Microsoft.Finance.TCS.TCSBase;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Reversal;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Posting;

codeunit 18869 "TCS Validation and Settlement"
{
    [EventSubscriber(ObjectType::Table, database::"Reversal Entry", 'OnBeforeReverseEntries', '', false, false)]
    local procedure OnBeforeReverseEntries(Number: Integer; RevType: Integer; var IsHandled: Boolean)
    var
        TCSEntry: Record "TCS Entry";
        ClosedErr: Label 'You cannot reverse %1 No. %2 because the entry is closed.', Comment = '%1= Table Caption, %2= Entry No.';
        AlreadyReversedErr: Label 'You cannot reverse %1 No. %2 because the entry has already been involved in a reversal.', Comment = '%1 = TCS Entry Table Caption, %2 = Entry No.';
    begin
        TCSEntry.SetRange("Transaction No.", Number);
        if not TCSEntry.FindFirst() then
            exit;

        CheckPostingDate(TCSEntry."Posting Date", TCSEntry.TableCaption, TCSEntry."Entry No.");

        if TCSEntry."TCS Paid" then
            Error(ClosedErr, TCSEntry.TableCaption, TCSEntry."Entry No.");

        if TCSEntry.Reversed then
            Error(AlreadyReversedErr, TCSEntry.TableCaption, TCSEntry."Entry No.");
    end;

    [EventSubscriber(ObjectType::Table, database::"Reversal Entry", 'OnAfterInsertReversalEntry', '', false, false)]
    local procedure InsertFromTCSEntry(
        var TempRevertTransactionNo: Record Integer;
        Number: Integer;
        RevType: Option Transaction,Register;
        var NextLineNo: Integer)
    var
        TCSEntry: Record "TCS Entry";
        TempReversalEntry: Record "Reversal Entry" temporary;
    begin
        TempRevertTransactionNo.FindSet();
        repeat
            if RevType = RevType::Transaction then
                TCSEntry.SetRange("Transaction No.", TempRevertTransactionNo.Number);
            if TCSEntry.FindSet() then
                repeat
                    Clear(TempReversalEntry);
                    if RevType = RevType::Register then
                        TempReversalEntry."G/L Register No." := Number;
                    TempReversalEntry."Reversal Type" := RevType;
                    TempReversalEntry."Entry No." := TCSEntry."Entry No.";
                    TempReversalEntry."Posting Date" := TCSEntry."Posting Date";
                    TempReversalEntry."Source Code" := TCSEntry."Source Code";
                    TempReversalEntry."Transaction No." := TCSEntry."Transaction No.";
                    TempReversalEntry.Amount := TCSEntry."Total TCS Including SHE CESS";
                    TempReversalEntry."Amount (LCY)" := TCSEntry."Total TCS Including SHE CESS";
                    TempReversalEntry."Document Type" := TCSEntry."Document Type";
                    TempReversalEntry."Document No." := TCSEntry."Document No.";
                    TempReversalEntry."Line No." := NextLineNo;
                    NextLineNo := NextLineNo + 1;
                    TempReversalEntry.Insert();
                until TCSEntry.Next() = 0;
        until TempRevertTransactionNo.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Check Line", 'OnAfterCheckGenJnlLine', '', false, false)]
    local procedure PayTCSEntry(var GenJournalLine: Record "Gen. Journal Line")
    var
        TCSEntry: Record "TCS Entry";
    begin
        if GenJournalLine."Pay TCS" = false then
            exit;

        TCSEntry.SetCurrentKey("Pay TCS Document No.");
        TCSEntry.SetRange("Pay TCS Document No.", GenJournalLine."Document No.");
        if TCSEntry.FindSet() then
            repeat
                TCSEntry."TCS Payment Date" := GenJournalLine."Posting Date";
                TCSEntry."TCS Paid" := true;
                TCSEntry.Modify();
            until TCSEntry.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Reverse", 'OnReverseOnBeforeStartPosting', '', false, false)]
    local procedure ReverseTCSEntry(
        var GenJournalLine: Record "Gen. Journal Line";
        var ReversalEntry: Record "Reversal Entry")
    var
        TCSEntry: Record "TCS Entry";
        NewTCSEntry: Record "TCS Entry";
        ReversedTCSEntry: Record "TCS Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        TCSEntry.SetRange("Transaction No.", ReversalEntry."Transaction No.");
        if TCSEntry.FindSet() then
            repeat
                if TCSEntry."Reversed by Entry No." <> 0 then
                    Error(CannotReverseErr);
                NewTCSEntry := TCSEntry;
                NewTCSEntry."Entry No." := 0;
                NewTCSEntry."TCS Base Amount" := -NewTCSEntry."TCS Base Amount";
                NewTCSEntry."TCS Amount" := -NewTCSEntry."TCS Amount";
                NewTCSEntry."Surcharge Base Amount" := -NewTCSEntry."Surcharge Base Amount";
                NewTCSEntry."Surcharge Amount" := -NewTCSEntry."Surcharge Amount";
                NewTCSEntry."TCS Amount Including Surcharge" := -NewTCSEntry."TCS Amount Including Surcharge";
                NewTCSEntry."eCESS Amount" := -NewTCSEntry."eCESS Amount";
                NewTCSEntry."SHE Cess Amount" := -NewTCSEntry."SHE Cess Amount";
                NewTCSEntry."Total TCS Including SHE CESS" := -NewTCSEntry."Total TCS Including SHE CESS";
                NewTCSEntry."Bal. TCS Including SHE CESS" := -NewTCSEntry."Bal. TCS Including SHE CESS";
                NewTCSEntry."Invoice Amount" := -NewTCSEntry."Invoice Amount";
                NewTCSEntry."Rem. Total TCS Incl. SHE CESS" := -NewTCSEntry."Rem. Total TCS Incl. SHE CESS";
                NewTCSEntry."Remaining TCS Amount" := -NewTCSEntry."Remaining TCS Amount";
                NewTCSEntry."Remaining Surcharge Amount" := -NewTCSEntry."Remaining Surcharge Amount";
                NewTCSEntry."Transaction No." := GenJnlPostLine.GetNextTransactionNo();
                NewTCSEntry."Reversed Entry No." := TCSEntry."Entry No.";
                NewTCSEntry.Reversed := true;
                if TCSEntry."Reversed Entry No." <> 0 then begin
                    ReversedTCSEntry.Get(TCSEntry."Reversed Entry No.");
                    ReversedTCSEntry."Reversed by Entry No." := 0;
                    ReversedTCSEntry.Reversed := false;
                    ReversedTCSEntry.Modify();
                    TCSEntry."Reversed Entry No." := NewTCSEntry."Entry No.";
                    NewTCSEntry."Reversed by Entry No." := TCSEntry."Entry No.";
                end;
                TCSEntry."Reversed by Entry No." := NewTCSEntry."Entry No.";
                TCSEntry.Reversed := true;
                TCSEntry.Modify();

                NewTCSEntry.Insert();
            until TCSEntry.Next() = 0;
    end;

    local procedure CheckPostingDate(PostingDate: Date; Caption: Text; EntryNo: Integer)
    var
        GenJnlCheckLine: Codeunit "Gen. Jnl.-Check Line";
    begin
        if GenJnlCheckLine.DateNotAllowed(PostingDate) then
            Error(PostingDateErr, Caption, EntryNo);
    end;

    var
        PostingDateErr: Label 'You cannot reverse %1 No. %2 because the posting date is not within the allowed posting period.', Comment = '%1= Table Caption, %2= Entry No.';
        CannotReverseErr: Label 'You cannot reverse the transaction, because it has already been reversed.';
}
