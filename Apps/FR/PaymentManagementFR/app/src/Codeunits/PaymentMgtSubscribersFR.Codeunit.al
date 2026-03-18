// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.Payment;
#pragma warning disable AA0228

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.DirectDebit;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.ReceivablesPayables;
using Microsoft.Finance.VAT.Ledger;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 10838 "PaymentMgt Subscribers FR"
{
    InherentEntitlements = X;
    InherentPermissions = X;
    Access = Internal;

    var
        UnrealCVLedgEntryBuffer: Record "Unreal. CV Ledg. Entry Buffer";
        PaymentToleranceMgt: Codeunit "Payment Tolerance Management";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA CT-Prepare Source", 'OnBeforeCreateTempJnlLines', '', false, false)]
    local procedure OnBeforeCreateTempJnlLines(var FromGenJnlLine: Record "Gen. Journal Line"; var TempGenJnlLine: Record "Gen. Journal Line" temporary; var IsHandled: Boolean)
    var
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
#if not CLEAN28
        Payment: Codeunit "Payment Management Feature FR";
#endif
        PaymentDocNo: Code[20];
        AppliedDocNoList: Text;
        DescriptionLen: Integer;
    begin
#if not CLEAN28
        if not Payment.IsEnabled() then
            exit;
#endif
        IsHandled := true;

        PaymentDocNo := CopyStr(FromGenJnlLine.GetFilter("Document No."), 1, MaxStrLen(PaymentDocNo));
        PaymentHeader.Get(PaymentDocNo);
        PaymentLine.Reset();
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        if PaymentLine.FindSet() then
            repeat
                TempGenJnlLine.Init();
                TempGenJnlLine."Journal Template Name" := '';
                TempGenJnlLine."Journal Batch Name" := Format(DATABASE::"Payment Header FR");
                TempGenJnlLine."Document No." := PaymentHeader."No.";
                TempGenJnlLine."Line No." := PaymentLine."Line No.";
                TempGenJnlLine."Account No." := PaymentLine."Account No.";
                TempGenJnlLine."Account Type" := PaymentLine."Account Type";
                case PaymentLine."Account Type" of
                    PaymentLine."Account Type"::Vendor:
                        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Payment;
                    PaymentLine."Account Type"::Customer:
                        TempGenJnlLine."Document Type" := TempGenJnlLine."Document Type"::Refund;
                end;
                TempGenJnlLine.Amount := PaymentLine.Amount;
                TempGenJnlLine."Applies-to Doc. Type" := PaymentLine."Applies-to Doc. Type";
                TempGenJnlLine."Applies-to Doc. No." := PaymentLine."Applies-to Doc. No.";
                TempGenJnlLine."Applies-to ID" := PaymentLine."Applies-to ID";
                TempGenJnlLine."Bal. Account Type" := PaymentHeader."Account Type";
                TempGenJnlLine."Bal. Account No." := PaymentHeader."Account No.";
                TempGenJnlLine."Currency Code" := PaymentLine."Currency Code";
                TempGenJnlLine."Posting Date" := PaymentLine."Posting Date";
                TempGenJnlLine."Recipient Bank Account" := PaymentLine."Bank Account Code";

                DescriptionLen := MaxStrLen(TempGenJnlLine.Description);
                AppliedDocNoList := PaymentLine.GetAppliedDocNoList(DescriptionLen);
                TempGenJnlLine.Description := CopyStr(AppliedDocNoList, 1, MaxStrLen(TempGenJnlLine.Description));
                if StrLen(AppliedDocNoList) > DescriptionLen then
                    TempGenJnlLine."Message to Recipient" :=
                      CopyStr(AppliedDocNoList, DescriptionLen + 1, MaxStrLen(TempGenJnlLine."Message to Recipient"));
                OnCreateTempJnlLinesOnBeforeInsertTempGenJnlLine(TempGenJnlLine, PaymentLine);
                TempGenJnlLine.Insert();
            until PaymentLine.Next() = 0;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"SEPA DD-Prepare Source", 'OnBeforeCreateTempCollectionEntries', '', false, false)]
    local procedure OnBeforeCreateTempCollectionEntries(var FromDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var isHandled: Boolean)
    var
        DirectDebitCollection: Record "Direct Debit Collection";
        PaymentHeader: Record "Payment Header FR";
        PaymentLine: Record "Payment Line FR";
#if not CLEAN28
        Payment: Codeunit "Payment Management Feature FR";
#endif
        SEPADDCheckLine: Codeunit "SEPA DD-Check Line";
        AppliesToEntryNo: Integer;
        HasErrorsErr: Label 'The file export has one or more errors. For each of the lines to be exported, resolve any errors that are displayed in the File Export Errors FactBox.';
    begin
#if not CLEAN28
        if not Payment.IsEnabled() then
            exit;
#endif
        IsHandled := true;

        ToDirectDebitCollectionEntry.Reset();
        DirectDebitCollection.Get(FromDirectDebitCollectionEntry.GetRangeMin("Direct Debit Collection No."));
        PaymentHeader.Get(DirectDebitCollection.Identifier);
        PaymentLine.SetRange("No.", PaymentHeader."No.");
        if PaymentLine.FindSet() then
            repeat
                ToDirectDebitCollectionEntry.Init();
                ToDirectDebitCollectionEntry."Entry No." := PaymentLine."Line No.";
                ToDirectDebitCollectionEntry."Direct Debit Collection No." := DirectDebitCollection."No.";
                ToDirectDebitCollectionEntry.DeletePaymentFileErrors();
                if CheckPaymentLine(ToDirectDebitCollectionEntry, PaymentLine, AppliesToEntryNo) then begin
                    ToDirectDebitCollectionEntry.Validate("Customer No.", PaymentLine."Account No.");
                    ToDirectDebitCollectionEntry.Validate("Applies-to Entry No.", AppliesToEntryNo);
                    ToDirectDebitCollectionEntry."Transfer Date" := PaymentHeader."Posting Date";
                    ToDirectDebitCollectionEntry."Currency Code" := PaymentLine."Currency Code";
                    ToDirectDebitCollectionEntry.Validate("Transfer Amount", PaymentLine."Credit Amount");
                    ToDirectDebitCollectionEntry.Validate("Mandate ID", PaymentLine."Direct Debit Mandate ID");
                    OnCreateTempCollectionEntriesOnBeforeInsert(ToDirectDebitCollectionEntry, PaymentHeader, PaymentLine);
                    ToDirectDebitCollectionEntry.Insert();
                    SEPADDCheckLine.CheckCollectionEntry(ToDirectDebitCollectionEntry);
                end;
            until PaymentLine.Next() = 0;

        if DirectDebitCollection.HasPaymentFileErrors() then begin
            Commit();
            Error(HasErrorsErr);
        end;
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnBeforeInitGLEntryForGLAcc', '', false, false)]
    local procedure OnPostGLAccOnBeforeInitGLEntry(GenJnlLine: Record "Gen. Journal Line"; var GLEntry: Record "G/L Entry"; var TaxAmount: Decimal; var TaxAmountLCY: Decimal; var IsHandled: Boolean)
    var
#if not CLEAN28
        Payment: Codeunit "Payment Management Feature FR";
#endif
    begin
#if not CLEAN28
        if not Payment.IsEnabled() then
            exit;
#endif

        RealizeDelayedUnrealizedVAT(GenJnlLine);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Gen. Jnl.-Post Line", 'OnPostBankAccOnBeforeCheckCurrencyCode', '', false, false)]
    local procedure OnPostBankAccOnBeforeCheckCurrencyCode(var GenJournalLine: Record "Gen. Journal Line"; BankAccount: Record "Bank Account"; var IsHandled: Boolean)
#if not CLEAN28
    var
        Payment: Codeunit "Payment Management Feature FR";
#endif
    begin
#if not CLEAN28
        if not Payment.IsEnabled() then
            exit;
#endif
        RealizeDelayedUnrealizedVAT(GenJournalLine);
    end;

    local procedure SetTransactionNo(GenJnlLine: Record "Gen. Journal Line")
    var
        AppliedCustLedgEntry: Record "Cust. Ledger Entry";
        AppliedVendLedgEntry: Record "Vendor Ledger Entry";
    begin
        case GenJnlLine."Source Type" of
            GenJnlLine."Source Type"::Customer:
                begin
                    AppliedCustLedgEntry.Reset();
                    AppliedCustLedgEntry.SetCurrentKey("Document No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        AppliedCustLedgEntry.SetRange("Document No.", GenJnlLine."Created from No.")
                    else
                        AppliedCustLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    AppliedCustLedgEntry.SetRange("Document Type", AppliedCustLedgEntry."Document Type"::" ");
                    AppliedCustLedgEntry.SetRange("Customer No.", GenJnlLine."Source No.");
                end;
            GenJnlLine."Source Type"::Vendor:
                begin
                    AppliedVendLedgEntry.Reset();
                    AppliedVendLedgEntry.SetCurrentKey("Document No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        AppliedVendLedgEntry.SetRange("Document No.", GenJnlLine."Created from No.")
                    else
                        AppliedVendLedgEntry.SetRange("Document No.", GenJnlLine."Document No.");
                    AppliedVendLedgEntry.SetRange("Document Type", AppliedVendLedgEntry."Document Type"::" ");
                    AppliedVendLedgEntry.SetRange("Vendor No.", GenJnlLine."Source No.");
                end;
        end;
    end;

    local procedure CheckHeaderNo(DocNo: Code[20]): Boolean
    var
        PaymentLine: Record "Payment Line FR";
    begin
        PaymentLine.SetRange("No.", DocNo);
        exit(not PaymentLine.IsEmpty());
    end;

    procedure PmtTolPaymentLine(var NewPaymentLine: Record "Payment Line FR"): Boolean
    var
        GLSetup: Record "General Ledger Setup";
        TempPaymentLine: Record "Payment Line FR" temporary;
        NewCustLedgEntry: Record "Cust. Ledger Entry";
        NewVendLedgEntry: Record "Vendor Ledger Entry";
        AppliedAmount: Decimal;
        ApplyingAmount: Decimal;
        AmounttoApply: Decimal;
        PmtDiscAmount: Decimal;
        MaxPmtTolAmount: Decimal;
        GenJnlLineApplID: Code[50];
        ApplnRoundingPrecision: Decimal;
    begin
        MaxPmtTolAmount := 0;
        PmtDiscAmount := 0;
        AppliedAmount := 0;
        ApplyingAmount := 0;
        AmounttoApply := 0;
        TempPaymentLine := NewPaymentLine;

        GLSetup.Get();
        if TempPaymentLine."Applies-to Doc. No." = '' then
            if TempPaymentLine."Applies-to ID" <> '' then
                GenJnlLineApplID := TempPaymentLine."Applies-to ID";

        if (TempPaymentLine."Account Type" = TempPaymentLine."Account Type"::Customer) then begin
            NewCustLedgEntry."Posting Date" := TempPaymentLine."Posting Date";
            NewCustLedgEntry."Document No." := TempPaymentLine."Document No.";
            NewCustLedgEntry."Customer No." := TempPaymentLine."Account No.";
            NewCustLedgEntry."Currency Code" := TempPaymentLine."Currency Code";
            if TempPaymentLine."Applies-to Doc. No." <> '' then
                NewCustLedgEntry."Applies-to Doc. No." := TempPaymentLine."Applies-to Doc. No.";
            PaymentToleranceMgt.DelCustPmtTolAcc(NewCustLedgEntry, GenJnlLineApplID);
            NewCustLedgEntry.Amount := TempPaymentLine.Amount;
            NewCustLedgEntry."Remaining Amount" := TempPaymentLine.Amount;
            NewCustLedgEntry."Document Type" := TempPaymentLine."Applies-to Doc. Type"::Payment;
            PaymentToleranceMgt.CalcCustApplnAmount(
              NewCustLedgEntry, GLSetup, AppliedAmount, ApplyingAmount, AmounttoApply, PmtDiscAmount,
              MaxPmtTolAmount, GenJnlLineApplID, ApplnRoundingPrecision);
        end else begin
            NewVendLedgEntry."Posting Date" := TempPaymentLine."Posting Date";
            NewVendLedgEntry."Document No." := TempPaymentLine."Document No.";
            NewVendLedgEntry."Vendor No." := TempPaymentLine."Account No.";
            NewVendLedgEntry."Currency Code" := TempPaymentLine."Currency Code";
            if TempPaymentLine."Applies-to Doc. No." <> '' then
                NewVendLedgEntry."Applies-to Doc. No." := TempPaymentLine."Applies-to Doc. No.";
            PaymentToleranceMgt.DelVendPmtTolAcc(NewVendLedgEntry, GenJnlLineApplID);
            NewVendLedgEntry.Amount := TempPaymentLine.Amount;
            NewVendLedgEntry."Remaining Amount" := TempPaymentLine.Amount;
            NewVendLedgEntry."Document Type" := TempPaymentLine."Applies-to Doc. Type"::Payment;
            PaymentToleranceMgt.CalcVendApplnAmount(
              NewVendLedgEntry, GLSetup, AppliedAmount, ApplyingAmount, AmounttoApply, PmtDiscAmount,
              MaxPmtTolAmount, GenJnlLineApplID,
              ApplnRoundingPrecision);
        end;

        if GLSetup."Pmt. Disc. Tolerance Warning" then
            case TempPaymentLine."Account Type" of
                TempPaymentLine."Account Type"::Customer:
                    if not PaymentToleranceMgt.ManagePaymentDiscToleranceWarningCustomer(
                         NewCustLedgEntry, GenJnlLineApplID, AppliedAmount, AmounttoApply, TempPaymentLine."Applies-to Doc. No.")
                    then
                        exit(false);
                TempPaymentLine."Account Type"::Vendor:
                    if not PaymentToleranceMgt.ManagePaymentDiscToleranceWarningVendor(
                         NewVendLedgEntry, GenJnlLineApplID, AppliedAmount, AmounttoApply, TempPaymentLine."Applies-to Doc. No.")
                    then
                        exit(false);
            end;

        if Abs(AmounttoApply) >= Abs(AppliedAmount - PmtDiscAmount - MaxPmtTolAmount) then begin
            AppliedAmount := AppliedAmount - PmtDiscAmount;
            if Abs(AppliedAmount) > Abs(AmounttoApply) then
                AppliedAmount := AmounttoApply;

            if ((Abs(AppliedAmount + ApplyingAmount) - ApplnRoundingPrecision) <= Abs(MaxPmtTolAmount)) and
              (MaxPmtTolAmount <> 0) and ((Abs(AppliedAmount + ApplyingAmount) - ApplnRoundingPrecision) <> 0) and
              ((Abs(AppliedAmount + ApplyingAmount) > ApplnRoundingPrecision))
            then
                if TempPaymentLine."Account Type" = TempPaymentLine."Account Type"::Customer then begin
                    if GLSetup."Payment Tolerance Warning" then begin
                        if PaymentToleranceMgt.CallPmtTolWarning(
                             TempPaymentLine."Posting Date", TempPaymentLine."Account No.", TempPaymentLine."Document No.",
                             TempPaymentLine."Currency Code", ApplyingAmount, AppliedAmount, "Payment Tolerance Account Type"::Customer)
                        then begin
                            if (AppliedAmount <> 0) and (ApplyingAmount <> 0) then
                                PaymentToleranceMgt.PutCustPmtTolAmount(NewCustLedgEntry, ApplyingAmount, AppliedAmount, GenJnlLineApplID)
                            else
                                PaymentToleranceMgt.DelCustPmtTolAcc(NewCustLedgEntry, GenJnlLineApplID);
                        end else
                            exit(false);
                    end else
                        PaymentToleranceMgt.PutCustPmtTolAmount(NewCustLedgEntry, ApplyingAmount, AppliedAmount, GenJnlLineApplID);
                end else
                    if GLSetup."Payment Tolerance Warning" then begin
                        if PaymentToleranceMgt.CallPmtTolWarning(
                             TempPaymentLine."Posting Date", TempPaymentLine."Account No.", TempPaymentLine."Document No.",
                             TempPaymentLine."Currency Code", ApplyingAmount, AppliedAmount, "Payment Tolerance Account Type"::Vendor)
                        then begin
                            if (AppliedAmount <> 0) and (ApplyingAmount <> 0) then
                                PaymentToleranceMgt.PutVendPmtTolAmount(NewVendLedgEntry, ApplyingAmount, AppliedAmount, GenJnlLineApplID)
                            else
                                PaymentToleranceMgt.DelVendPmtTolAcc(NewVendLedgEntry, GenJnlLineApplID);
                        end else begin
                            PaymentToleranceMgt.DelVendPmtTolAcc(NewVendLedgEntry, GenJnlLineApplID);
                            exit(false);
                        end;
                    end else
                        PaymentToleranceMgt.PutVendPmtTolAmount(NewVendLedgEntry, ApplyingAmount, AppliedAmount, GenJnlLineApplID);

        end;
        exit(true);
    end;

    local procedure CheckPaymentLine(DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; PaymentLine: Record "Payment Line FR"; var AppliesToEntryNo: Integer) Result: Boolean
    var
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        SummarizeNotAllowedErr: Label 'You cannot export a SEPA customer payment that is applied to multiple documents. Make sure that the Summarize per field in the Suggest Customer Payments window is blank.';
        UnappliedLinesNotAllowedErr: Label 'Payment slip line %1 must be applied to a customer invoice.', Comment = '%1 = No.';
        AccTypeErr: Label 'Only customer transactions are allowed.';
        BankAccErr: Label 'You must use customer bank account, %1, which you specified in the selected direct debit mandate.', Comment = '%1 = code';
        IsHandled: Boolean;
    begin
        IsHandled := false;
        OnBeforeCheckPaymentLine(DirectDebitCollectionEntry, PaymentLine, Result, IsHandled);
        if IsHandled then
            exit(Result);

        if PaymentLine."Account Type" <> PaymentLine."Account Type"::Customer then
            DirectDebitCollectionEntry.InsertPaymentFileError(AccTypeErr);

        if SEPADirectDebitMandate.Get(PaymentLine."Direct Debit Mandate ID") then
            if SEPADirectDebitMandate."Customer Bank Account Code" <> PaymentLine."Bank Account Code" then
                DirectDebitCollectionEntry.InsertPaymentFileError(StrSubstNo(BankAccErr, SEPADirectDebitMandate."Customer Bank Account Code"));

        if (PaymentLine."Applies-to Doc. No." = '') and (PaymentLine."Applies-to ID" = '') then
            DirectDebitCollectionEntry.InsertPaymentFileError(StrSubstNo(UnappliedLinesNotAllowedErr, PaymentLine."Line No."))
        else begin
            PaymentLine.GetAppliesToDocCustLedgEntry(CustLedgerEntry);
            if CustLedgerEntry.Count > 1 then
                DirectDebitCollectionEntry.InsertPaymentFileError(SummarizeNotAllowedErr);
            CustLedgerEntry.FindFirst();
            if CustLedgerEntry."Document Type" <> CustLedgerEntry."Document Type"::Invoice then
                DirectDebitCollectionEntry.InsertPaymentFileError(StrSubstNo(UnappliedLinesNotAllowedErr, PaymentLine."Line No."));
            AppliesToEntryNo := CustLedgerEntry."Entry No.";
        end;

        exit(not DirectDebitCollectionEntry.HasPaymentFileErrors());
    end;

    local procedure PostDelayedUnrealizedVAT(GenJnlLine: Record "Gen. Journal Line")
    var
        OldCustLedgEntry: Record "Cust. Ledger Entry";
        OldVendLedgEntry: Record "Vendor Ledger Entry";
    begin
        case GenJnlLine."Source Type" of
            GenJnlLine."Source Type"::Customer:
                if GenJnlLine."Applies-to Doc. No." <> '' then begin
                    // Find original entry based on Applies-to Doc. No.
                    OldCustLedgEntry.Reset();
                    OldCustLedgEntry.SetCurrentKey("Document No.");
                    OldCustLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                    OldCustLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                    OldCustLedgEntry.SetRange("Customer No.", GenJnlLine."Source No.");
                    OldCustLedgEntry.FindFirst();
                    OldCustLedgEntry.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");
                    SetTransactionNo(GenJnlLine);
                    UnrealCVLedgEntryBuffer.Reset();
                    UnrealCVLedgEntryBuffer.SetRange("Account Type", UnrealCVLedgEntryBuffer."Account Type"::Customer);
                    UnrealCVLedgEntryBuffer.SetRange("Account No.", GenJnlLine."Source No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Created from No.")
                    else
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Document No.");
                    UnrealCVLedgEntryBuffer.FindFirst();
                    GenJnlPostLine.CustUnrealizedVAT(GenJnlLine, OldCustLedgEntry, GenJnlLine.Amount);
                    UnrealCVLedgEntryBuffer.Realized := true;
                    UnrealCVLedgEntryBuffer.Modify();
                    UpdateUnrealCVLedgEntryBuffer(GenJnlLine, OldCustLedgEntry."Transaction No.");
                end else begin
                    // Find original entry from buffer table
                    UnrealCVLedgEntryBuffer.Reset();
                    UnrealCVLedgEntryBuffer.SetRange("Account Type", UnrealCVLedgEntryBuffer."Account Type"::Customer);
                    UnrealCVLedgEntryBuffer.SetRange("Account No.", GenJnlLine."Source No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Created from No.")
                    else
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Document No.");
                    UnrealCVLedgEntryBuffer.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
#pragma warning disable AL0667                    
                    if UnrealCVLedgEntryBuffer.FindSet(true, false) then
#pragma warning restore AL0667                    
                        repeat
                            OldCustLedgEntry.Get(UnrealCVLedgEntryBuffer."Entry No.");
                            OldCustLedgEntry.CalcFields(
                              Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                              "Original Amount", "Original Amt. (LCY)");
                            SetTransactionNo(GenJnlLine);
                            GenJnlPostLine.CustUnrealizedVAT(GenJnlLine, OldCustLedgEntry, UnrealCVLedgEntryBuffer."Applied Amount");
                            UnrealCVLedgEntryBuffer.Realized := true;
                            UnrealCVLedgEntryBuffer.Modify();
                            UpdateUnrealCVLedgEntryBuffer(GenJnlLine, OldCustLedgEntry."Transaction No.");
                        until UnrealCVLedgEntryBuffer.Next() = 0;
                end;
            GenJnlLine."Source Type"::Vendor:
                if GenJnlLine."Applies-to Doc. No." <> '' then begin
                    // Find original entry based on Applies-to Doc. No.
                    OldVendLedgEntry.Reset();
                    OldVendLedgEntry.SetCurrentKey("Document No.");
                    OldVendLedgEntry.SetRange("Document No.", GenJnlLine."Applies-to Doc. No.");
                    OldVendLedgEntry.SetRange("Document Type", GenJnlLine."Applies-to Doc. Type");
                    OldVendLedgEntry.SetRange("Vendor No.", GenJnlLine."Source No.");
                    OldVendLedgEntry.FindFirst();
                    OldVendLedgEntry.CalcFields(
                      Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                      "Original Amount", "Original Amt. (LCY)");
                    SetTransactionNo(GenJnlLine);
                    UnrealCVLedgEntryBuffer.Reset();
                    UnrealCVLedgEntryBuffer.SetRange("Account Type", UnrealCVLedgEntryBuffer."Account Type"::Vendor);
                    UnrealCVLedgEntryBuffer.SetRange("Account No.", GenJnlLine."Source No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Created from No.")
                    else
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Document No.");
                    UnrealCVLedgEntryBuffer.FindFirst();
                    GenJnlPostLine.VendUnrealizedVAT(GenJnlLine, OldVendLedgEntry, GenJnlLine.Amount);
                    UnrealCVLedgEntryBuffer.Realized := true;
                    UnrealCVLedgEntryBuffer.Modify();
                    UpdateUnrealCVLedgEntryBuffer(GenJnlLine, OldVendLedgEntry."Transaction No.");
                end else begin
                    // Find original entry from buffer table
                    UnrealCVLedgEntryBuffer.Reset();
                    UnrealCVLedgEntryBuffer.SetRange("Account Type", UnrealCVLedgEntryBuffer."Account Type"::Vendor);
                    UnrealCVLedgEntryBuffer.SetRange("Account No.", GenJnlLine."Source No.");
                    if CheckHeaderNo(GenJnlLine."Document No.") then
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Created from No.")
                    else
                        UnrealCVLedgEntryBuffer.SetRange("Payment Slip No.", GenJnlLine."Document No.");
                    UnrealCVLedgEntryBuffer.SetRange("Applies-to ID", GenJnlLine."Applies-to ID");
#pragma warning disable AL0667                    
                    if UnrealCVLedgEntryBuffer.FindSet(true, false) then
#pragma warning restore AL0667                    
                        repeat
                            OldVendLedgEntry.Get(UnrealCVLedgEntryBuffer."Entry No.");
                            OldVendLedgEntry.CalcFields(
                              Amount, "Amount (LCY)", "Remaining Amount", "Remaining Amt. (LCY)",
                              "Original Amount", "Original Amt. (LCY)");
                            SetTransactionNo(GenJnlLine);
                            GenJnlPostLine.VendUnrealizedVAT(GenJnlLine, OldVendLedgEntry, UnrealCVLedgEntryBuffer."Applied Amount");
                            UnrealCVLedgEntryBuffer.Realized := true;
                            UnrealCVLedgEntryBuffer.Modify();
                            UpdateUnrealCVLedgEntryBuffer(GenJnlLine, OldVendLedgEntry."Transaction No.");
                        until UnrealCVLedgEntryBuffer.Next() = 0;
                end;
        end;
    end;

    local procedure UpdateUnrealCVLedgEntryBuffer(GenJnlLine: Record "Gen. Journal Line"; TransactionNo: Integer)
    var
        VATEntry2: Record "VAT Entry";
        UnrealCVLedgEntryBuffer2: Record "Unreal. CV Ledg. Entry Buffer";
        TotalUnrealVATAmount: Decimal;
    begin
        VATEntry2.Reset();
        VATEntry2.SetCurrentKey("Transaction No.");
        VATEntry2.SetRange("Transaction No.", TransactionNo);
        if VATEntry2.FindSet() then
            repeat
                TotalUnrealVATAmount := TotalUnrealVATAmount - VATEntry2."Remaining Unrealized Amount";
            until VATEntry2.Next() = 0;
        if TotalUnrealVATAmount = 0 then begin
            UnrealCVLedgEntryBuffer2.Reset();
            if GenJnlLine."Source Type" = GenJnlLine."Source Type"::Customer then
                UnrealCVLedgEntryBuffer2.SetRange("Account Type", UnrealCVLedgEntryBuffer2."Account Type"::Customer)
            else
                UnrealCVLedgEntryBuffer2.SetRange("Account Type", UnrealCVLedgEntryBuffer2."Account Type"::Vendor);
            UnrealCVLedgEntryBuffer2.SetRange("Entry No.", UnrealCVLedgEntryBuffer."Entry No.");
            UnrealCVLedgEntryBuffer2.SetRange(Realized, true);
            UnrealCVLedgEntryBuffer2.DeleteAll();
        end;
    end;

    procedure CalcPaidAmount(GenJnlLine: Record "Gen. Journal Line"): Decimal
    var
        UnrealCVLedgEntryBuffer2: Record "Unreal. CV Ledg. Entry Buffer";
        PaidAmount: Decimal;
    begin
        UnrealCVLedgEntryBuffer2.Reset();
        if GenJnlLine."Source Type" = GenJnlLine."Source Type"::Customer then
            UnrealCVLedgEntryBuffer2.SetRange("Account Type", UnrealCVLedgEntryBuffer2."Account Type"::Customer)
        else
            UnrealCVLedgEntryBuffer2.SetRange("Account Type", UnrealCVLedgEntryBuffer2."Account Type"::Vendor);
        UnrealCVLedgEntryBuffer2.SetRange("Entry No.", UnrealCVLedgEntryBuffer."Entry No.");
        UnrealCVLedgEntryBuffer2.SetRange(Realized, true);
        if UnrealCVLedgEntryBuffer2.FindSet() then
            repeat
                PaidAmount := PaidAmount - UnrealCVLedgEntryBuffer2."Applied Amount";
            until UnrealCVLedgEntryBuffer2.Next() = 0;
        exit(Abs(PaidAmount));
    end;

    local procedure RealizeDelayedUnrealizedVAT(GenJnlLine: Record "Gen. Journal Line")
    begin
        if GenJnlLine."Delayed Unrealized VAT" and GenJnlLine."Realize VAT" then
            if (GenJnlLine."Applies-to Doc. No." <> '') or (GenJnlLine."Applies-to ID" <> '') then
                PostDelayedUnrealizedVAT(GenJnlLine);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateTempJnlLinesOnBeforeInsertTempGenJnlLine(var TempGenJnlLine: Record "Gen. Journal Line" temporary; var PaymentLine: Record "Payment Line FR")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnCreateTempCollectionEntriesOnBeforeInsert(var ToDirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; PaymentHeader: Record "Payment Header FR"; PaymentLine: Record "Payment Line FR")
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeCheckPaymentLine(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var PaymentLine: Record "Payment Line FR"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}

