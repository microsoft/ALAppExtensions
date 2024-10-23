// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Bank.Payment;

using Microsoft.Bank.Reconciliation;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Sales.Receivables;

Codeunit 13652 FIK_MatchGenJournalLines
{
    TableNo = "Gen. Journal Line";

    VAR

        MatchGeneralJournalLines: Codeunit "Match General Journal Lines";
        MatchLengthTreshold: Integer;
        NormalizingFactor: Integer;
        MatchStatus: Option NoMatch,Duplicate,IsPaid,Partial,Extra,Fully;
        MatchSummaryMsg: Label '%1 payment lines out of %2 have been applied.\\', Comment = '%1 = Number of matched General Journal Lines; %2 = Total number of General Journal Lines';
        ProgressBarMsg: Label 'Please wait while the operation is being completed.';
        FIKDescriptionPartialTxt: Label 'Partial Amount';
        FIKDescriptionExtraTxt: Label 'Excess Amount';
        FIKDescriptionDuplicateTxt: Label 'Duplicate FIK Number';
        FIKDescriptionNoMatchTxt: Label 'No Matching FIK Number';
        FIKDescriptionFullMatchTxt: Label 'Matching Amount';
        FIKDescriptionIsPaidTxt: Label 'Invoice Already Paid';
        MatchPartialTxt: Label '%1 payment lines are partially paid.\', Comment = '%1 = Number of matched General Journal Lines that has been partially paid';
        MatchExtraTxt: Label '%1 payment lines have excess amounts.\', Comment = '%1 = Number of matched General Journal Lines that has excess amounts';
        MatchFullyTxt: Label '%1 payment lines are fully applied.\', Comment = '%1 = Number of matched General Journal Lines that has been fully paid';
        MatchDetailsTxt: Label 'Details:\';


    trigger OnRun();
    var
        GenJnlLine: Record "Gen. Journal Line";
    begin
        GenJnlLine.COPY(Rec);
        Code(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");
        Rec := GenJnlLine;
    end;

    PROCEDURE Code(TemplateName: Code[10]; BatchName: Code[10]);
    VAR
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        GenJournalBatch: Record "Gen. Journal Batch";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        Window: Dialog;
    BEGIN
        GenJournalBatch.GET(TemplateName, BatchName);
        Window.OPEN(ProgressBarMsg);
        SetMatchLengthThreshold(4);
        SetNormalizingFactor(10);
        MatchGeneralJournalLines.FillTempGenJournalLine(GenJournalBatch, TempGenJournalLine);
        FindMatchingCustEntries(TempBankStatementMatchingBuffer, TempGenJournalLine);
        SaveOneToOneMatching(TempBankStatementMatchingBuffer, GenJournalBatch);

        Window.CLOSE();
        ShowMatchSummary(TempBankStatementMatchingBuffer, GenJournalBatch);
    END;

    LOCAL PROCEDURE FindMatchingCustEntries(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR TempGenJournalLine: Record "Gen. Journal Line" temporary);
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
    BEGIN
        TempGenJournalLine.SETFILTER("Payment Reference", '<>%1', '');
        TempGenJournalLine.SETRANGE("Applied Automatically", FALSE);

        IF TempGenJournalLine.FINDSET() THEN
            REPEAT
                CustLedgerEntry.RESET();
                CustLedgerEntry.SETRANGE("Applies-to ID", '');
                CustLedgerEntry.SETRANGE("Document No.", TempGenJournalLine."Payment Reference");
                OnAfterFilterCustLedgerEntries(CustLedgerEntry, TempBankStatementMatchingBuffer, TempGenJournalLine);
                CustLedgerEntry.SETAUTOCALCFIELDS("Remaining Amt. (LCY)");
                IF CustLedgerEntry.FINDFIRST() AND
                   (CustLedgerEntry.COUNT() = 1) AND (TempGenJournalLine."Posting Date" >= CustLedgerEntry."Posting Date")
                THEN
                    CASE TRUE OF
                        CustLedgerEntry."Remaining Amt. (LCY)" = 0:
                            AddMatchCandidate(TempBankStatementMatchingBuffer, TempGenJournalLine, CustLedgerEntry, MatchStatus::IsPaid);
                        -TempGenJournalLine."Amount (LCY)" > CustLedgerEntry."Remaining Amt. (LCY)":
                            AddMatchCandidate(TempBankStatementMatchingBuffer, TempGenJournalLine, CustLedgerEntry, MatchStatus::Extra);
                        -TempGenJournalLine."Amount (LCY)" < CustLedgerEntry."Remaining Amt. (LCY)":
                            AddMatchCandidate(TempBankStatementMatchingBuffer, TempGenJournalLine, CustLedgerEntry, MatchStatus::Partial);
                        -TempGenJournalLine."Amount (LCY)" = CustLedgerEntry."Remaining Amt. (LCY)":
                            AddMatchCandidate(TempBankStatementMatchingBuffer, TempGenJournalLine, CustLedgerEntry, MatchStatus::Fully);
                    END
                ELSE
                    AddMatchCandidate(TempBankStatementMatchingBuffer, TempGenJournalLine, CustLedgerEntry, MatchStatus::NoMatch);
            UNTIL TempGenJournalLine.NEXT() = 0;

        TempGenJournalLine.RESET();
    END;

    LOCAL PROCEDURE SaveOneToOneMatching(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR GenJournalBatch: Record "Gen. Journal Batch");
    VAR
        GenJournalLine: Record "Gen. Journal Line";
    BEGIN
        TempBankStatementMatchingBuffer.RESET();
        TempBankStatementMatchingBuffer.SETCURRENTKEY(Quality);
        TempBankStatementMatchingBuffer.ASCENDING(FALSE);

        IF TempBankStatementMatchingBuffer.FINDSET() THEN
            REPEAT
                GenJournalLine.GET(GenJournalBatch."Journal Template Name",
                  GenJournalBatch.Name, TempBankStatementMatchingBuffer."Line No.");
                ApplyRecords(GenJournalLine, TempBankStatementMatchingBuffer);
                GenJournalLine.Description := GetUpdatedFIKDescription(TempBankStatementMatchingBuffer);
                GenJournalLine."Payment Reference" := '';
                GenJournalLine.MODIFY();
            UNTIL TempBankStatementMatchingBuffer.NEXT() = 0;
    END;

    LOCAL PROCEDURE ApplyRecords(VAR GenJournalLine: Record "Gen. Journal Line"; VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary);
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        OrigCurrencyCode: Code[10];
    BEGIN
        IF TempBankStatementMatchingBuffer."Account Type" = TempBankStatementMatchingBuffer."Account Type"::Customer THEN
            IF CustLedgerEntry.GET(TempBankStatementMatchingBuffer."Entry No.") THEN
                IF NOT GenJournalLine.IsApplied() THEN BEGIN
                    OrigCurrencyCode := GenJournalLine."Currency Code";
                    GenJournalLine.VALIDATE("Document Type", GenJournalLine."Document Type"::Payment);
                    GenJournalLine.VALIDATE("Account Type", GenJournalLine."Account Type"::Customer);
                    GenJournalLine.VALIDATE("Account No.", CustLedgerEntry."Customer No.");
                    IF TempBankStatementMatchingBuffer.Quality > MatchStatus::IsPaid THEN
                        GenJournalLine.VALIDATE("Applies-to ID", GenJournalLine."Document No.");
                    IF OrigCurrencyCode <> GenJournalLine."Currency Code" THEN
                        GenJournalLine.VALIDATE("Currency Code", OrigCurrencyCode);
                    GenJournalLine.VALIDATE("Applied Automatically", TempBankStatementMatchingBuffer.Quality > MatchStatus::IsPaid);
                    GenJournalLine.MODIFY(TRUE);

                    IF TempBankStatementMatchingBuffer.Quality > MatchStatus::IsPaid THEN
                        MatchGeneralJournalLines.PrepareCustLedgerEntryForApplication(CustLedgerEntry, GenJournalLine);
                END;
    END;

    LOCAL PROCEDURE AddMatchCandidate(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR TempGenJournalLine: Record "Gen. Journal Line" temporary; CustLedgerEntry: Record "Cust. Ledger Entry"; MatchOption: Option);
    var
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        CASE TRUE OF
            IsDuplicate(TempBankStatementMatchingBuffer, TempGenJournalLine):
                FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer,
                  TempGenJournalLine."Line No.", CustLedgerEntry."Entry No.", MatchStatus::Duplicate,
                  TempBankStatementMatchingBuffer."Account Type"::Customer, CustLedgerEntry."Customer No.", TempGenJournalLine.Description,
                  MatchOption);
            MatchOption = MatchStatus::NoMatch:
                FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer,
                  TempGenJournalLine."Line No.", CustLedgerEntry."Entry No.", MatchOption,
                  TempBankStatementMatchingBuffer."Account Type"::"G/L Account", '', TempGenJournalLine.Description, MatchOption);
            MatchOption = MatchStatus::IsPaid:
                FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer,
                  TempGenJournalLine."Line No.", CustLedgerEntry."Entry No.", MatchOption,
                  TempBankStatementMatchingBuffer."Account Type"::Customer, CustLedgerEntry."Customer No.", TempGenJournalLine.Description,
                  MatchOption)
            ELSE
                FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer,
                  TempGenJournalLine."Line No.", CustLedgerEntry."Entry No.", MatchOption,
                  TempBankStatementMatchingBuffer."Account Type"::Customer, CustLedgerEntry."Customer No.", TempGenJournalLine.Description,
                  MatchOption);
        END;
    END;

    LOCAL PROCEDURE IsDuplicate(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR TempGenJournalLine: Record "Gen. Journal Line" temporary): Boolean;
    BEGIN
        TempBankStatementMatchingBuffer.RESET();
        TempBankStatementMatchingBuffer.SETFILTER(DescriptionBankStatment, TempGenJournalLine.Description);
        IF TempBankStatementMatchingBuffer.FINDSET() THEN BEGIN
            REPEAT
                TempBankStatementMatchingBuffer.Quality := MatchStatus::Duplicate;
                TempBankStatementMatchingBuffer.MODIFY();
            UNTIL TempBankStatementMatchingBuffer.NEXT() = 0;

            EXIT(TRUE);
        END;

        EXIT(FALSE);
    END;

    LOCAL PROCEDURE ShowMatchSummary(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; GenJournalBatch: Record "Gen. Journal Batch");
    VAR
        GenJournalLine: Record "Gen. Journal Line";
        FinalText: Text;
        MatchStatisticText: Text;
        TotalCount: Integer;
        MatchedCount: Integer;
        MatchStatistic: ARRAY[6] OF Integer;
    BEGIN
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.SETFILTER("Document Type", '%1', GenJournalLine."Document Type"::Payment);
        TotalCount := GenJournalLine.COUNT();

        GenJournalLine.SETRANGE("Applied Automatically", TRUE);
        MatchedCount := GenJournalLine.COUNT();
        GetMatchDetails(TempBankStatementMatchingBuffer, MatchStatistic);

        IF MatchStatistic[MatchStatus::Fully] > 0 THEN
            MatchStatisticText := MatchStatisticText +
              STRSUBSTNO(MatchFullyTxt, MatchStatistic[MatchStatus::Fully]);
        IF MatchStatistic[MatchStatus::Partial] > 0 THEN
            MatchStatisticText := MatchStatisticText +
              STRSUBSTNO(MatchPartialTxt, MatchStatistic[MatchStatus::Partial]);
        IF MatchStatistic[MatchStatus::Extra] > 0 THEN
            MatchStatisticText := MatchStatisticText +
              STRSUBSTNO(MatchExtraTxt, MatchStatistic[MatchStatus::Extra]);

        IF MatchStatisticText <> '' THEN
            MatchStatisticText := MatchDetailsTxt + MatchStatisticText;

        FinalText := STRSUBSTNO(MatchSummaryMsg, MatchedCount, TotalCount) + MatchStatisticText;
        MESSAGE(FinalText);
    END;

    PROCEDURE SetMatchLengthThreshold(NewMatchLengthThreshold: Integer);
    BEGIN
        MatchLengthTreshold := NewMatchLengthThreshold;
    END;

    PROCEDURE SetNormalizingFactor(NewNormalizingFactor: Integer);
    BEGIN
        NormalizingFactor := NewNormalizingFactor;
    END;

    PROCEDURE GetMatchLengthTreshold(): Integer;
    BEGIN
        EXIT(MatchLengthTreshold);
    END;

    PROCEDURE GetNormalizingFactor(): Integer;
    BEGIN
        EXIT(NormalizingFactor);
    END;

    LOCAL PROCEDURE GetUpdatedFIKDescription(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Text[50];
    VAR
        FIKDescription: Text[50];
        UpdatedFIKDescriptionTxt: Label '%1 - %2', Locked = true;
    BEGIN
        CASE TempBankStatementMatchingBuffer.Quality OF
            MatchStatus::Fully:
                FIKDescription := FIKDescriptionFullMatchTxt;
            MatchStatus::Partial:
                FIKDescription := FIKDescriptionPartialTxt;
            MatchStatus::Extra:
                FIKDescription := FIKDescriptionExtraTxt;
            MatchStatus::NoMatch:
                FIKDescription := FIKDescriptionNoMatchTxt;
            MatchStatus::IsPaid:
                FIKDescription := FIKDescriptionIsPaidTxt;
            MatchStatus::Duplicate:
                FIKDescription := FIKDescriptionDuplicateTxt;
        END;
        if FIKDescription <> '' THEN
            exit(CopyStr(STRSUBSTNO(UpdatedFIKDescriptionTxt, FIKDescription, TempBankStatementMatchingBuffer.DescriptionBankStatment), 1, 50))
        else
            exit(CopyStr(TempBankStatementMatchingBuffer.DescriptionBankStatment, 1, 50));
    END;

    LOCAL PROCEDURE GetMatchDetails(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR MatchStatistic: ARRAY[6] OF Integer);
    BEGIN
        TempBankStatementMatchingBuffer.RESET();
        IF TempBankStatementMatchingBuffer.FINDSET(TRUE) THEN
            REPEAT
                IF TempBankStatementMatchingBuffer.Quality > MatchStatus::IsPaid THEN
                    MatchStatistic[TempBankStatementMatchingBuffer.Quality] += 1;
            UNTIL TempBankStatementMatchingBuffer.NEXT() = 0;
    END;

    [IntegrationEvent(false, false)]
    local procedure OnAfterFilterCustLedgerEntries(var CustLedgerEntry: Record "Cust. Ledger Entry"; VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR TempGenJournalLine: Record "Gen. Journal Line" temporary)
    begin
    end;
}

