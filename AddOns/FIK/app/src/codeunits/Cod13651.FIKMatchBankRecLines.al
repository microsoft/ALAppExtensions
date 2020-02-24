// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 13651 FIK_MatchBankRecLines
{
    TableNo = 273;

    VAR
        MatchSummaryMsg: Label '%1 payment lines out of %2 have been applied.\\';
        ProgressBarMsg: Label 'Please wait while the operation is being completed.';
        FIKDescriptionPartialTxt: Label 'Partial Amount';
        FIKDescriptionExtraTxt: Label 'Excess Amount';
        FIKDescriptionDuplicateTxt: Label 'Duplicate FIK Number';
        FIKDescriptionNoMatchTxt: Label 'No Matching FIK Number';
        FIKDescriptionFullMatchTxt: Label 'Matching Amount';
        FIKDescriptionIsPaidTxt: Label 'Invoice Already Paid';
        MatchPartialTxt: Label '%1 payment lines are partially paid.\';
        MatchExtraTxt: Label '%1 payment lines have excess amounts.\';
        MatchFullyTxt: Label '%1 payment lines are fully applied.\';
        MatchDuplicateTxt: Label '%1 payment lines are duplicates.\';
        MatchIsPaidTxt: Label '%1 payment lines are already paid.\';
        MatchDetailsTxt: Label 'Details:\';


    trigger OnRun();
    var
        TempBankAccReconciliation: Record "Bank Acc. Reconciliation" temporary;
    begin
        TempBankAccReconciliation.COPY(Rec);
        Code(TempBankAccReconciliation);
        Rec := TempBankAccReconciliation;
    end;

    PROCEDURE Code(VAR TempBankAccReconciliation: Record "Bank Acc. Reconciliation" temporary);
    VAR
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        AppliedPaymentEntry: Record "Applied Payment Entry";
        Window: Dialog;
    BEGIN

        BankAccReconciliationLine.SETRANGE("Statement No.", TempBankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SETRANGE("Bank Account No.", TempBankAccReconciliation."Bank Account No.");
        IF BankAccReconciliationLine.ISEMPTY() THEN
            EXIT;

        Window.OPEN(ProgressBarMsg);
        FindMatchingCustEntries(TempBankStatementMatchingBuffer, BankAccReconciliationLine);
        UpdateReconciliationLines(BankAccReconciliationLine, TempBankStatementMatchingBuffer);
        SaveOneToOneMatching(TempBankStatementMatchingBuffer, AppliedPaymentEntry, TempBankAccReconciliation);

        Window.CLOSE();
        ShowMatchSummary(TempBankStatementMatchingBuffer);
    END;

    LOCAL PROCEDURE FindMatchingCustEntries(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        MatchStatusValue: Option;
    BEGIN
        BankAccReconciliationLine.SETFILTER(PaymentReference, '<>%1', '');

        IF BankAccReconciliationLine.FINDSET() THEN
            REPEAT
                CustLedgerEntry.RESET();
                CustLedgerEntry.SETRANGE("Applies-to ID", '');
                CustLedgerEntry.SETRANGE("Document No.", BankAccReconciliationLine.PaymentReference);
                CustLedgerEntry.SETAUTOCALCFIELDS("Remaining Amt. (LCY)");
                WITH TempBankStatementMatchingBuffer DO
                    IF CustLedgerEntry.FINDFIRST() AND
                        (CustLedgerEntry.COUNT() = 1) AND (BankAccReconciliationLine."Transaction Date" >= CustLedgerEntry."Posting Date")
                    THEN
                        CASE TRUE OF
                            CustLedgerEntry."Remaining Amt. (LCY)" = 0:
                                MatchStatusValue := MatchStatus::IsPaid;
                            BankAccReconciliationLine."Statement Amount" > CustLedgerEntry."Remaining Amt. (LCY)":
                                MatchStatusValue := MatchStatus::Extra;
                            BankAccReconciliationLine."Statement Amount" < CustLedgerEntry."Remaining Amt. (LCY)":
                                MatchStatusValue := MatchStatus::Partial;
                            BankAccReconciliationLine."Statement Amount" = CustLedgerEntry."Remaining Amt. (LCY)":
                                MatchStatusValue := MatchStatus::Fully;
                        END
                    ELSE
                        MatchStatusValue := MatchStatus::NoMatch;

                AddMatchCandidate(TempBankStatementMatchingBuffer, BankAccReconciliationLine, CustLedgerEntry, MatchStatusValue);
            UNTIL BankAccReconciliationLine.NEXT() = 0;

        BankAccReconciliationLine.RESET();
    END;

    LOCAL PROCEDURE AddMatchCandidate(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; CustLedgerEntry: Record "Cust. Ledger Entry"; MatchOption: Option);
    var
        FIKManagement: Codeunit FIKManagement;
    BEGIN
        WITH TempBankStatementMatchingBuffer DO
            CASE TRUE OF
                MatchOption = MatchStatus::NoMatch:
                    FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Statement Line No.", 0, 0,
                      "Account Type"::"G/L Account", '', BankAccReconciliationLine.Description, MatchOption);
                MatchOption = MatchStatus::IsPaid:
                    FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Statement Line No.", 0, 0,
                      "Account Type"::Customer, CustLedgerEntry."Customer No.", BankAccReconciliationLine.Description, MatchOption);
                IsDuplicate(TempBankStatementMatchingBuffer, BankAccReconciliationLine.Description):
                    FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Statement Line No.", CustLedgerEntry."Entry No.", 50,
                      "Account Type"::Customer, CustLedgerEntry."Customer No.", BankAccReconciliationLine.Description, MatchStatus::Duplicate)
                ELSE
                    FIKManagement.AddMatchCandidateWithDescription(TempBankStatementMatchingBuffer, BankAccReconciliationLine."Statement Line No.", CustLedgerEntry."Entry No.", 50,
                      "Account Type"::Customer, CustLedgerEntry."Customer No.", BankAccReconciliationLine.Description, MatchOption);
            END;
    END;

    LOCAL PROCEDURE IsDuplicate(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; DupDescription: Text): Boolean;
    BEGIN
        WITH TempBankStatementMatchingBuffer DO BEGIN
            RESET();
            SETFILTER(DescriptionBankStatment, DupDescription);
            IF FINDSET() THEN BEGIN
                REPEAT
                    MatchStatus := MatchStatus::Duplicate;
                    MODIFY();
                UNTIL NEXT() = 0;
                RESET();
                EXIT(TRUE);
            END;
            RESET();
        END;

        EXIT(FALSE);
    END;

    LOCAL PROCEDURE ShowMatchSummary(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary);
    VAR
        FinalText: Text;
        MatchStatisticText: Text;
        TotalCount: Integer;
        MatchedCount: Integer;
        MatchStatistic: ARRAY[6] OF Integer;
    BEGIN
        WITH TempBankStatementMatchingBuffer DO BEGIN
            TotalCount := COUNT();

            GetMatchDetails(TempBankStatementMatchingBuffer, MatchStatistic);
            MatchedCount :=
              MatchStatistic[MatchStatus::Fully] +
              MatchStatistic[MatchStatus::Partial] +
              MatchStatistic[MatchStatus::Extra] +
              MatchStatistic[MatchStatus::Duplicate] +
              MatchStatistic[MatchStatus::IsPaid];

            IF MatchStatistic[MatchStatus::Fully] > 0 THEN
                MatchStatisticText := MatchStatisticText +
                  STRSUBSTNO(MatchFullyTxt, MatchStatistic[MatchStatus::Fully]);
            IF MatchStatistic[MatchStatus::Partial] > 0 THEN
                MatchStatisticText := MatchStatisticText +
                  STRSUBSTNO(MatchPartialTxt, MatchStatistic[MatchStatus::Partial]);
            IF MatchStatistic[MatchStatus::Extra] > 0 THEN
                MatchStatisticText := MatchStatisticText +
                  STRSUBSTNO(MatchExtraTxt, MatchStatistic[MatchStatus::Extra]);
            IF MatchStatistic[MatchStatus::Duplicate] > 0 THEN
                MatchStatisticText := MatchStatisticText +
                  STRSUBSTNO(MatchDuplicateTxt, MatchStatistic[MatchStatus::Duplicate]);
            IF MatchStatistic[MatchStatus::IsPaid] > 0 THEN
                MatchStatisticText := MatchStatisticText +
                  STRSUBSTNO(MatchIsPaidTxt, MatchStatistic[MatchStatus::IsPaid]);

            IF MatchStatisticText <> '' THEN
                MatchStatisticText := MatchDetailsTxt + MatchStatisticText;

            FinalText := STRSUBSTNO(MatchSummaryMsg, MatchedCount, TotalCount) + MatchStatisticText;
            MESSAGE(FinalText);
        END;
    END;

    LOCAL PROCEDURE UpdateReconciliationLines(VAR BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary);
    VAR
        PaymentMatchingDetails: Record "Payment Matching Details";
    BEGIN
        BankAccReconciliationLine.RESET();
        BankAccReconciliationLine.SETFILTER(PaymentReference, '<>%1', '');
        IF BankAccReconciliationLine.FINDSET(TRUE) THEN
            REPEAT
                TempBankStatementMatchingBuffer.SETFILTER(DescriptionBankStatment, BankAccReconciliationLine.Description);
                IF TempBankStatementMatchingBuffer.FINDFIRST() THEN BEGIN
                    BankAccReconciliationLine."Transaction Text" := GetUpdatedFIKDescription(TempBankStatementMatchingBuffer);
                    PaymentMatchingDetails.CreatePaymentMatchingDetail(BankAccReconciliationLine, BankAccReconciliationLine."Transaction Text");
                    BankAccReconciliationLine.MODIFY();
                END;
            UNTIL BankAccReconciliationLine.NEXT() = 0;
    END;

    LOCAL PROCEDURE GetMatchConfidence(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Integer;
    VAR
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    BEGIN
        WITH TempBankStatementMatchingBuffer DO
            CASE MatchStatus OF
                MatchStatus::Fully:
                    EXIT(BankAccReconciliationLine."Match Confidence"::High);
                MatchStatus::Partial,
              MatchStatus::Duplicate,
              MatchStatus::Extra:
                    EXIT(BankAccReconciliationLine."Match Confidence"::Medium);
                MatchStatus::IsPaid:
                    EXIT(BankAccReconciliationLine."Match Confidence"::Low);
                ELSE
                    EXIT(BankAccReconciliationLine."Match Confidence"::None);
            END;
    END;

    LOCAL PROCEDURE GetUpdatedFIKDescription(TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary): Text[140];
    VAR
        StatusText: Text;
    BEGIN
        WITH TempBankStatementMatchingBuffer DO BEGIN
            CASE MatchStatus OF
                MatchStatus::Fully:
                    StatusText := FIKDescriptionFullMatchTxt;
                MatchStatus::Partial:
                    StatusText := FIKDescriptionPartialTxt;
                MatchStatus::Extra:
                    StatusText := FIKDescriptionExtraTxt;
                MatchStatus::NoMatch:
                    StatusText := FIKDescriptionNoMatchTxt;
                MatchStatus::IsPaid:
                    StatusText := FIKDescriptionIsPaidTxt;
                MatchStatus::Duplicate:
                    StatusText := FIKDescriptionDuplicateTxt;
                ELSE
                    EXIT(COPYSTR(DescriptionBankStatment, 1, 140));
            END;

            EXIT(CopyStr(STRSUBSTNO('%1 - %2', StatusText, DescriptionBankStatment), 1, 50));
        END;
    END;

    LOCAL PROCEDURE GetMatchDetails(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR MatchStatistic: ARRAY[6] OF Integer);
    BEGIN
        WITH TempBankStatementMatchingBuffer DO BEGIN
            RESET();
            IF FINDSET(TRUE) THEN
                REPEAT
                    IF MatchStatus <> MatchStatus::NoMatch THEN
                        MatchStatistic[MatchStatus] += 1;
                UNTIL NEXT() = 0;
        END;
    END;

    LOCAL PROCEDURE SaveOneToOneMatching(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR AppliedPaymentEntry: Record "Applied Payment Entry"; VAR BankAccReconciliation: Record "Bank Acc. Reconciliation");
    BEGIN
        WITH TempBankStatementMatchingBuffer DO BEGIN
            RESET();
            SETCURRENTKEY(Quality);

            IF FINDSET() THEN
                REPEAT
                    IF MatchStatus <> MatchStatus::NoMatch THEN
                        ApplyRecord(AppliedPaymentEntry, TempBankStatementMatchingBuffer, BankAccReconciliation);
                UNTIL NEXT() = 0;
        END;
    END;

    LOCAL PROCEDURE ApplyRecord(VAR AppliedPaymentEntry: Record "Applied Payment Entry"; VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; VAR BankAccReconciliation: Record "Bank Acc. Reconciliation");
    VAR
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        StatementAmount: Decimal;
    BEGIN
        IF StatementLineAlreadyApplied(AppliedPaymentEntry, TempBankStatementMatchingBuffer, BankAccReconciliation) THEN
            EXIT;

        BankAccReconciliationLine.GET(
          BankAccReconciliation."Statement Type",
          BankAccReconciliation."Bank Account No.",
          BankAccReconciliation."Statement No.",
          TempBankStatementMatchingBuffer."Line No.");
        StatementAmount := BankAccReconciliationLine."Statement Amount";

        AppliedPaymentEntry.INIT();
        AppliedPaymentEntry.VALIDATE("Statement Type", AppliedPaymentEntry."Statement Type"::"Payment Application");
        AppliedPaymentEntry.VALIDATE("Bank Account No.", BankAccReconciliation."Bank Account No.");
        AppliedPaymentEntry.VALIDATE("Statement No.", BankAccReconciliation."Statement No.");
        AppliedPaymentEntry.VALIDATE("Statement Line No.", TempBankStatementMatchingBuffer."Line No.");
        AppliedPaymentEntry.VALIDATE("Account Type", TempBankStatementMatchingBuffer."Account Type");
        AppliedPaymentEntry.VALIDATE("Account No.", TempBankStatementMatchingBuffer."Account No.");
        AppliedPaymentEntry.VALIDATE("Match Confidence", GetMatchConfidence(TempBankStatementMatchingBuffer));
        AppliedPaymentEntry."Applies-to Entry No." := TempBankStatementMatchingBuffer."Entry No.";
        IF (AppliedPaymentEntry.SuggestAmtToApply() <> 0) AND (TempBankStatementMatchingBuffer."Entry No." <> 0) THEN
            AppliedPaymentEntry.VALIDATE("Applies-to Entry No.")
        ELSE BEGIN
            AppliedPaymentEntry."Applies-to Entry No." := 0;
            AppliedPaymentEntry.VALIDATE("Applied Amount", StatementAmount);
        END;
        AppliedPaymentEntry.INSERT(TRUE);
    END;

    LOCAL PROCEDURE StatementLineAlreadyApplied(AppliedPaymentEntry: Record "Applied Payment Entry"; TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; TempBankAccReconciliation: Record "Bank Acc. Reconciliation" temporary): Boolean;
    BEGIN
        SetFilterToBankAccReconciliation(AppliedPaymentEntry, TempBankAccReconciliation);
        AppliedPaymentEntry.SETRANGE("Statement Line No.", TempBankStatementMatchingBuffer."Line No.");
        IF NOT AppliedPaymentEntry.ISEMPTY() THEN
            EXIT(TRUE);
        EXIT(FALSE);
    END;

    LOCAL PROCEDURE SetFilterToBankAccReconciliation(VAR AppliedPaymentEntry: Record "Applied Payment Entry"; TempBankAccReconciliation: Record "Bank Acc. Reconciliation" temporary);
    BEGIN
        AppliedPaymentEntry.RESET();
        AppliedPaymentEntry.SETRANGE("Statement No.", TempBankAccReconciliation."Statement No.");
        AppliedPaymentEntry.SETRANGE("Statement Type", AppliedPaymentEntry."Statement Type"::"Payment Application");
        AppliedPaymentEntry.SETRANGE("Bank Account No.", TempBankAccReconciliation."Bank Account No.");
    END;

    PROCEDURE GetBankStatementMatchingBuffer(VAR TempBankStatementMatchingBuffer2: Record "Bank Statement Matching Buffer" temporary; StatementLineNo: Integer);
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
    BEGIN
        CustLedgerEntry.SETAUTOCALCFIELDS("Remaining Amt. (LCY)");
        IF CustLedgerEntry.FINDSET() THEN
            REPEAT
                IF (CustLedgerEntry."Document Type" = CustLedgerEntry."Document Type"::Invoice) AND
                   (CustLedgerEntry."Remaining Amt. (LCY)" > 0)
                THEN
                    TempBankStatementMatchingBuffer2.AddMatchCandidate(StatementLineNo, CustLedgerEntry."Entry No.", 5,
                      TempBankStatementMatchingBuffer2."Account Type"::Customer, CustLedgerEntry."Customer No.");
            UNTIL CustLedgerEntry.NEXT() = 0;
    END;
}

