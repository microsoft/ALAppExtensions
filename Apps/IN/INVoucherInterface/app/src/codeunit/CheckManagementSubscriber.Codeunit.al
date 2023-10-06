// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Bank.VoucherInterface;

using Microsoft.Bank.BankAccount;
using Microsoft.Bank.Check;
using Microsoft.Bank.Ledger;
using Microsoft.Finance.Currency;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Ledger;
using Microsoft.Finance.GeneralLedger.Posting;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Finance.TaxBase;
using Microsoft.Finance.VAT.Setup;
using Microsoft.FixedAssets.Ledger;
using Microsoft.Foundation.AuditCodes;
using Microsoft.Foundation.Reporting;
using Microsoft.Purchases.Payables;
using Microsoft.Sales.Receivables;

codeunit 18970 "Check Management Subscriber"
{
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        CannotVoidNonBalanceTransErr: Label 'You cannot Financially Void checks posted in a non-balancing transaction.';
        VoidingCheckLbl: Label 'Voiding check %1.', Comment = '%1 = CheckLedgEntry."Check No."';
        NoAppliedEntryErr: Label 'Cannot find an applied entry within the specified filter.';
        StaleCheckExpiryDateErr: Label 'Cheque Ledger entry can be marked as Stale only after %1. ', Comment = '%1= Stale Check Expiry Date';
        CheckMarkedStaleErr: Label 'The cheque has already been marked stale.';
        VoidCheckConfirmationLbl: Label 'Void Check %1?', Comment = '%1 = Check No';
        VoidAllCheckLbl: Label 'Void all printed checks?';

    procedure FinancialStaleCheck(var CheckLedgerEntry: Record "Check Ledger Entry")
    var
        SourceCodeSetup: Record "Source Code Setup";
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GLEntry: Record "G/L Entry";
        TaxBaseLibrary: Codeunit "Tax Base Library";
        ConfirmFinancialStale: Page "Confirm Financial Stale";
        TransactionBalance: Decimal;
        TotalTDSEncludingSheCess: Decimal;
        TDSEntryNo: Integer;
        TDSAccountNo: Code[20];
    begin
        TotalTDSEncludingSheCess := 0;
        TDSAccountNo := '';
        TDSEntryNo := 0;

        if CheckLedgerEntry."Stale Cheque" = true then
            Error(CheckMarkedStaleErr);

        CheckLedgerEntry.TestField("Entry Status", CheckLedgerEntry."Entry Status"::Posted);
        CheckLedgerEntry.TestField("Statement Status", CheckLedgerEntry."Statement Status"::Open);
        CheckLedgerEntry.TestField("Bal. Account No.");
        BankAccount.Get(CheckLedgerEntry."Bank Account No.");
        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        SourceCodeSetup.Get();

        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        GLEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        if GLEntry.FindSet() then begin
            GLEntry.CalcSums(Amount);
            TransactionBalance := GLEntry.Amount;
        end;

        if TransactionBalance <> 0 then
            Error(CannotVoidNonBalanceTransErr);

        Clear(ConfirmFinancialStale);
        ConfirmFinancialStale.SetCheckLedgerEntry(CheckLedgerEntry);
        if ConfirmFinancialStale.RunModal() <> Action::Yes then
            exit;

        if CheckLedgerEntry."Stale Cheque Expiry Date" >= WorkDate() then
            Error(StaleCheckExpiryDateErr, CheckLedgerEntry."Stale Cheque Expiry Date");

        GenJournalLine.Init();
        GenJournalLine."Document No." := CheckLedgerEntry."Document No.";
        GenJournalLine."Stale Cheque" := true;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
        GenJournalLine."Posting Date" := CheckLedgerEntry."Posting Date";
        GenJournalLine.Validate("Account No.", CheckLedgerEntry."Bank Account No.");
        GenJournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");
        GenJournalLine.Validate(Amount, CheckLedgerEntry.Amount);
        GenJournalLine."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJournalLine."Shortcut Dimension 1 Code" := BankAccountLedgerEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := BankAccountLedgerEntry."Global Dimension 2 Code";
        GenJournalLine."Dimension Set ID" := BankAccountLedgerEntry."Dimension Set ID";
        GenJournalLine."Allow Zero-Amount Posting" := true;
        GenJournalLine."Cheque No." := BankAccountLedgerEntry."Cheque No.";
        GenJournalLine."Cheque Date" := BankAccountLedgerEntry."Cheque Date";
        GenJnlPostLine.Run(GenJournalLine);

        TaxBaseLibrary.GetTotalTDSIncludingSheCess(CheckLedgerEntry."Document No.", TotalTDSEncludingSheCess, TDSAccountNo, TDSEntryNo);
        if TDSEntryNo <> 0 then begin
            GenJournalLine.Init();
            GenJournalLine."Document No." := CheckLedgerEntry."Document No.";
            GenJournalLine."Stale Cheque" := true;
            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"G/L Account";
            GenJournalLine."Posting Date" := CheckLedgerEntry."Posting Date";
            GenJournalLine.Validate("Account No.", TDSAccountNo);
            GenJournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");
            GenJournalLine.Validate(Amount, TotalTDSEncludingSheCess);
            GenJournalLine."Source Code" := SourceCodeSetup."Financially Voided Check";
            GenJournalLine."Shortcut Dimension 1 Code" := BankAccountLedgerEntry."Global Dimension 1 Code";
            GenJournalLine."Shortcut Dimension 2 Code" := BankAccountLedgerEntry."Global Dimension 2 Code";
            GenJournalLine."Dimension Set ID" := BankAccountLedgerEntry."Dimension Set ID";
            GenJournalLine."Allow Zero-Amount Posting" := true;
            GenJnlPostLine.Run(GenJournalLine);

            TaxBaseLibrary.ReverseTDSEntry(TDSEntryNo, GenJnlPostLine.GetNextTransactionNo());
        end;

        GenJournalLine.Init();
        GenJournalLine."Document No." := CheckLedgerEntry."Document No.";
        GenJournalLine."Stale Cheque" := true;
        GenJournalLine."Account Type" := CheckLedgerEntry."Bal. Account Type";
        GenJournalLine."Posting Date" := CheckLedgerEntry."Posting Date";
        GenJournalLine.Validate("Account No.", CheckLedgerEntry."Bal. Account No.");
        GenJournalLine.Validate("Currency Code", BankAccount."Currency Code");
        GenJournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");
        GenJournalLine."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJournalLine."Allow Zero-Amount Posting" := true;
        case CheckLedgerEntry."Bal. Account Type" of
            CheckLedgerEntry."Bal. Account Type"::"G/L Account":
                PostGLAccEntry(GenJournalLine, CheckLedgerEntry);

            CheckLedgerEntry."Bal. Account Type"::Customer:
                PostCustomerEntry(GenJournalLine, CheckLedgerEntry, ConfirmFinancialStale);

            CheckLedgerEntry."Bal. Account Type"::Vendor:
                PostVendorEntry(GenJournalLine, CheckLedgerEntry, ConfirmFinancialStale);

            CheckLedgerEntry."Bal. Account Type"::"Bank Account":
                PostBankAccEntry(GenJournalLine, BankAccountLedgerEntry);

            CheckLedgerEntry."Bal. Account Type"::"Fixed Asset":
                PostFAEntry(GenJournalLine, CheckLedgerEntry);
            else begin
                GenJournalLine."Bal. Account Type" := CheckLedgerEntry."Bal. Account Type";
                GenJournalLine.Validate("Bal. Account No.", CheckLedgerEntry."Bal. Account No.");
                GenJournalLine."Shortcut Dimension 1 Code" := '';
                GenJournalLine."Shortcut Dimension 2 Code" := '';
                GenJnlPostLine.RunWithoutCheck(GenJournalLine);
            end;
        end;

        CheckLedgerEntry."Original Entry Status" := CheckLedgerEntry."Entry Status";
        CheckLedgerEntry."Entry Status" := CheckLedgerEntry."Entry Status"::"Financially Voided";
        CheckLedgerEntry."Stale Cheque" := true;
        CheckLedgerEntry."Cheque Stale Date" := WorkDate();
        CheckLedgerEntry.Modify();

        BankAccountLedgerEntry."Stale Cheque" := true;
        BankAccountLedgerEntry."Cheque Stale Date" := WorkDate();
        BankAccountLedgerEntry.Modify();
    end;

    procedure UnApplyCustInvoicesNew(var CheckLedgerEntry: Record "Check Ledger Entry"; VoidDate: Date): Boolean
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        OrigPaymentCustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentDetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        AppliesID: Code[50];
    begin
        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        if CheckLedgerEntry."Bal. Account Type" <> CheckLedgerEntry."Bal. Account Type"::Customer then
            exit(false);

        OrigPaymentCustLedgerEntry.SetCurrentKey("Transaction No.");
        OrigPaymentCustLedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        OrigPaymentCustLedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        OrigPaymentCustLedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        if not OrigPaymentCustLedgerEntry.FindFirst() then
            exit(false);

        AppliesID := CheckLedgerEntry."Document No.";
        PaymentDetailedCustLedgEntry.SetCurrentKey("Cust. Ledger Entry No.", "Entry Type", "Posting Date");
        PaymentDetailedCustLedgEntry.SetRange("Cust. Ledger Entry No.", OrigPaymentCustLedgerEntry."Entry No.");
        PaymentDetailedCustLedgEntry.SetRange(Unapplied, false);
        PaymentDetailedCustLedgEntry.SetFilter("Applied Cust. Ledger Entry No.", '<>%1', 0);
        PaymentDetailedCustLedgEntry.SetRange("Entry Type", PaymentDetailedCustLedgEntry."Entry Type"::Application);
        if not PaymentDetailedCustLedgEntry.FindFirst() then
            Error(NoAppliedEntryErr);

        GenJournalLine."Document No." := OrigPaymentCustLedgerEntry."Document No.";
        GenJournalLine."Posting Date" := VoidDate;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Customer;
        GenJournalLine."Account No." := OrigPaymentCustLedgerEntry."Customer No.";
        GenJournalLine.Correction := true;
        GenJournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");
        GenJournalLine."Shortcut Dimension 1 Code" := OrigPaymentCustLedgerEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := OrigPaymentCustLedgerEntry."Global Dimension 2 Code";
        GenJournalLine."Posting Group" := OrigPaymentCustLedgerEntry."Customer Posting Group";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Customer;
        GenJournalLine."Source No." := OrigPaymentCustLedgerEntry."Customer No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJournalLine."Source Currency Code" := OrigPaymentCustLedgerEntry."Currency Code";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Financial Void" := true;
        GenJnlPostLine.UnapplyCustLedgEntry(GenJournalLine, PaymentDetailedCustLedgEntry);

        if OrigPaymentCustLedgerEntry.FindSet(true, false) then
            repeat
                MakeAppliesID(AppliesID, CheckLedgerEntry."Document No.");
                OrigPaymentCustLedgerEntry."Applies-to ID" := AppliesID;
                OrigPaymentCustLedgerEntry.CalcFields("Remaining Amount");
                OrigPaymentCustLedgerEntry."Amount to Apply" := OrigPaymentCustLedgerEntry."Remaining Amount";
                OrigPaymentCustLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
                OrigPaymentCustLedgerEntry."Accepted Payment Tolerance" := 0;
                OrigPaymentCustLedgerEntry.Modify();
            until OrigPaymentCustLedgerEntry.Next() = 0;
        exit(true);
    end;

    procedure MakeAppliesID(var AppliesID: Code[50]; CheckDocNo: Code[20])
    var
        AppliesIDCounter: Integer;
    begin
        if AppliesID = '' then
            exit;
        if AppliesID = CheckDocNo then
            AppliesIDCounter := 0;
        AppliesIDCounter := AppliesIDCounter + 1;
        AppliesID :=
          CopyStr(Format(AppliesIDCounter) + CheckDocNo, 1, MaxStrLen(AppliesID));
    end;

    procedure PrintCheck(var NewGenJnlLine: Record "Gen. Journal Line")
    var
        GenJnlLine: Record "Gen. Journal Line";
        ReportSelection: Record "Report Selections";
    begin
        GenJnlLine.Copy(NewGenJnlLine);
        ReportSelection.SetRange(Usage, ReportSelection.Usage::"B.Check");
        ReportSelection.SetFilter("Report ID", '<>%1', 0);
        ReportSelection.Find('-');
        repeat
            Report.RunModal(ReportSelection."Report ID", true, false, GenJnlLine);
        until ReportSelection.Next() = 0;
    end;

    procedure VoidCheckVoucher(var GenJnlLine: Record "Gen. Journal Line")
    var
        Currency: Record Currency;
        GenJournalLine: Record "Gen. Journal Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        CheckLedgerEntry: Record "Check Ledger Entry";
        CheckAmountLCY: Decimal;
    begin
        GenJnlLine.TestField("Bank Payment Type", GenJournalLine."Bank Payment Type"::"Computer Check");
        GenJnlLine.TestField("Check Printed", true);
        GenJnlLine.TestField("Document No.");

        if GenJnlLine."Bal. Account No." = '' then begin
            GenJnlLine."Check Printed" := false;
            GenJnlLine.Delete(true);
        end;
        CheckAmountLCY := GenJnlLine."Amount (LCY)";
        if GenJnlLine."Currency Code" <> '' then
            Currency.Get(GenJnlLine."Currency Code");
        GenJournalLine.Reset();
        GenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name", "Posting Date", "Document No.");
        GenJournalLine.SetRange("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJnlLine."Journal Batch Name");
        GenJournalLine.SetRange("Posting Date", GenJnlLine."Posting Date");
        GenJournalLine.SetRange("Document No.", GenJnlLine."Document No.");
        if GenJournalLine.FindSet() then
            repeat
                if (GenJournalLine."Line No." > GenJnlLine."Line No.") and
                   (CheckAmountLCY = -GenJournalLine."Amount (LCY)") and
                   (GenJournalLine."Currency Code" = '') and (GenJnlLine."Currency Code" <> '') and
                   (GenJournalLine."Account Type" = GenJournalLine."Account Type"::"G/L Account") and
                   (GenJournalLine."Account No." in
                    [Currency."Conv. LCY Rndg. Debit Acc.", Currency."Conv. LCY Rndg. Credit Acc."]) and
                   (GenJournalLine."Bal. Account No." = '') and not GenJournalLine."Check Printed"
                then
                    GenJournalLine.Delete()
                else begin
                    if GenJnlLine."Bal. Account No." = '' then begin
                        if GenJournalLine."Account No." = '' then begin
                            GenJournalLine."Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Account No." := GenJnlLine."Account No.";
                        end else begin
                            GenJournalLine."Bal. Account Type" := GenJournalLine."Account Type"::"Bank Account";
                            GenJournalLine."Bal. Account No." := GenJnlLine."Account No.";
                        end;
                        GenJournalLine.Validate(Amount);
                        GenJournalLine."Bank Payment Type" := GenJnlLine."Bank Payment Type";
                    end;
                    GeneralLedgerSetup.Get();
                    if not GeneralLedgerSetup."Activate Cheque No." then
                        GenJournalLine."Document No." := ''
                    else begin
                        GenJournalLine."Cheque No." := '';
                        GenJournalLine."Cheque Date" := 0D;
                    end;
                    GenJournalLine."Check Printed" := false;
                    GenJournalLine.UpdateSource();
                    GenJournalLine.Modify();
                end;
            until GenJournalLine.Next() = 0;

        CheckLedgerEntry.Reset();
        CheckLedgerEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        if GenJnlLine.Amount <= 0 then
            CheckLedgerEntry.SetRange("Bank Account No.", GenJnlLine."Account No.")
        else
            CheckLedgerEntry.SetRange("Bank Account No.", GenJnlLine."Bal. Account No.");
        CheckLedgerEntry.SetRange("Entry Status", CheckLedgerEntry."Entry Status"::Printed);
        if not GeneralLedgerSetup."Activate Cheque No." then
            CheckLedgerEntry.SetRange("Check No.", GenJnlLine."Document No.")
        else
            CheckLedgerEntry.SetRange("Check No.", GenJnlLine."Cheque No.");
        CheckLedgerEntry.FindFirst();
        CheckLedgerEntry."Original Entry Status" := CheckLedgerEntry."Entry Status";
        CheckLedgerEntry."Entry Status" := CheckLedgerEntry."Entry Status"::Voided;
        CheckLedgerEntry."Positive Pay Exported" := false;
        CheckLedgerEntry.Open := false;
        CheckLedgerEntry.Modify();
    end;

    local procedure PostGLAccEntry(GenjournalLine: Record "Gen. Journal Line"; CheckLedgerEntry: Record "Check Ledger Entry")
    var
        GLEntry: Record "G/L Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TaxBaseLibrary: Codeunit "Tax Base Library";
        TotalTDSEncludingSheCess: Decimal;
        TDSEntryNo: Integer;
        TDSAccountNo: Code[20];
    begin
        TotalTDSEncludingSheCess := 0;
        TDSAccountNo := '';
        TDSEntryNo := 0;

        BankAccount.Get(CheckLedgerEntry."Bank Account No.");
        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        GLEntry.SetCurrentKey("Transaction No.");
        GLEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        GLEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        GLEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        GLEntry.SetFilter("Entry No.", '<>%1', BankAccountLedgerEntry."Entry No.");
        GLEntry.SetRange("G/L Account No.", CheckLedgerEntry."Bal. Account No.");
        if GLEntry.FindFirst() then begin
            GenjournalLine.Validate("Account No.", GLEntry."G/L Account No.");
            GenjournalLine.Validate("Currency Code", BankAccount."Currency Code");
            GenjournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");

            TaxBaseLibrary.GetTotalTDSIncludingSheCess(CheckLedgerEntry."Document No.", TotalTDSEncludingSheCess, TDSAccountNo, TDSEntryNo);
            if TDSEntryNo <> 0 then
                GenjournalLine.Validate(Amount, -(CheckLedgerEntry.Amount + TotalTDSEncludingSheCess))
            else
                GenjournalLine.Validate(Amount, -CheckLedgerEntry.Amount);
            GenjournalLine."Shortcut Dimension 1 Code" := GLEntry."Global Dimension 1 Code";
            GenjournalLine."Shortcut Dimension 2 Code" := GLEntry."Global Dimension 2 Code";
            GenjournalLine."Dimension Set ID" := GLEntry."Dimension Set ID";
            GenjournalLine."Gen. Posting Type" := GLEntry."Gen. Posting Type";
            GenjournalLine."Gen. Bus. Posting Group" := GLEntry."Gen. Bus. Posting Group";
            GenjournalLine."Gen. Prod. Posting Group" := GLEntry."Gen. Prod. Posting Group";
            GenjournalLine."VAT Bus. Posting Group" := GLEntry."VAT Bus. Posting Group";
            GenjournalLine."VAT Prod. Posting Group" := GLEntry."VAT Prod. Posting Group";
            if VATPostingSetup.Get(GLEntry."VAT Bus. Posting Group", GLEntry."VAT Prod. Posting Group") then
                GenjournalLine."VAT Calculation Type" := VATPostingSetup."VAT Calculation Type";
            GenJnlPostLine.Run(GenjournalLine);
        end;
    end;

    local procedure PostCustomerEntry(GenJournalLine: Record "Gen. Journal Line"; CheckLedgerEntry: Record "Check Ledger Entry"; ConfirmFinancialStale: Page "Confirm Financial Stale")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        if ConfirmFinancialStale.GetVoidType() = 0 then
            if UnApplyCustInvoicesNew(CheckLedgerEntry, ConfirmFinancialStale.GetVoidDate()) then
                GenJournalLine."Applies-to ID" := CheckLedgerEntry."Document No.";

        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        CustLedgerEntry.SetCurrentKey("Transaction No.");
        CustLedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        CustLedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        CustLedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        if CustLedgerEntry.FindSet() then
            repeat
                CustLedgerEntry.CalcFields("Original Amount");
                GenJournalLine.Validate(Amount, -CustLedgerEntry."Original Amount");
                GenJournalLine."Shortcut Dimension 1 Code" := CustLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := CustLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := CustLedgerEntry."Dimension Set ID";
                GenJnlPostLine.Run(GenJournalLine);
            until CustLedgerEntry.Next() = 0;
    end;

    local procedure PostVendorEntry(
        GenJournalLine: Record "Gen. Journal Line";
        CheckLedgerEntry: Record "Check Ledger Entry";
        ConfirmFinancialStale: Page "Confirm Financial Stale")
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        TaxBaseLibrary: Codeunit "Tax Base Library";
        TotalTDSEncludingSheCess: Decimal;
        TDSEntryNo: Integer;
        TDSAccountNo: Code[20];
    begin
        TotalTDSEncludingSheCess := 0;
        TDSAccountNo := '';
        TDSEntryNo := 0;

        if ConfirmFinancialStale.GetVoidType() = 0 then
            if UnApplyVendInvoices(CheckLedgerEntry, ConfirmFinancialStale.GetVoidDate()) then
                GenJournalLine."Applies-to ID" := CheckLedgerEntry."Document No.";

        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        VendorLedgerEntry.SetCurrentKey("Transaction No.");
        VendorLedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        VendorLedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        VendorLedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        if VendorLedgerEntry.FindSet() then
            repeat
                VendorLedgerEntry.CalcFields("Original Amount");
                TaxBaseLibrary.GetTotalTDSIncludingSheCess(CheckLedgerEntry."Document No.", TotalTDSEncludingSheCess, TDSAccountNo, TDSEntryNo);
                if TDSEntryNo <> 0 then
                    GenJournalLine.Validate(Amount, -VendorLedgerEntry."Original Amount")
                else
                    GenJournalLine.Validate(Amount, -(VendorLedgerEntry."Original Amount" - VendorLedgerEntry."Total TDS Including SHE CESS"));
                MakeAppliesID(GenJournalLine."Applies-to ID", CheckLedgerEntry."Document No.");
                GenJournalLine."Shortcut Dimension 1 Code" := VendorLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := VendorLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Source Currency Code" := VendorLedgerEntry."Currency Code";
                GenJournalLine."Dimension Set ID" := BankAccountLedgerEntry."Dimension Set ID";
                GenJnlPostLine.Run(GenJournalLine);
            until VendorLedgerEntry.Next() = 0;
    end;

    local procedure PostBankAccEntry(GenJournalLine: Record "Gen. Journal Line"; BankAccountLedgerEntry: Record "Bank Account Ledger Entry")
    var
        NewBankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        NewBankAccountLedgerEntry.SetCurrentKey("Transaction No.");
        NewBankAccountLedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        NewBankAccountLedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        NewBankAccountLedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        NewBankAccountLedgerEntry.SetFilter("Entry No.", '<>%1', BankAccountLedgerEntry."Entry No.");
        if NewBankAccountLedgerEntry.FindSet() then
            repeat
                GenJournalLine.Validate(Amount, -NewBankAccountLedgerEntry.Amount);
                GenJournalLine."Shortcut Dimension 1 Code" := NewBankAccountLedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := NewBankAccountLedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := NewBankAccountLedgerEntry."Dimension Set ID";
                GenJnlPostLine.Run(GenJournalLine);
            until NewBankAccountLedgerEntry.Next() = 0;
    end;

    local procedure PostFAEntry(GenJournalLine: Record "Gen. Journal Line"; CheckLedgerEntry: Record "Check Ledger Entry")
    var
        FALedgerEntry: Record "FA Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        FALedgerEntry.SetCurrentKey("Transaction No.");
        FALedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
        FALedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
        FALedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
        if FALedgerEntry.FindSet() then
            repeat
                GenJournalLine.Validate(Amount, -FALedgerEntry.Amount);
                GenJournalLine."Shortcut Dimension 1 Code" := FALedgerEntry."Global Dimension 1 Code";
                GenJournalLine."Shortcut Dimension 2 Code" := FALedgerEntry."Global Dimension 2 Code";
                GenJournalLine."Dimension Set ID" := FALedgerEntry."Dimension Set ID";
                GenJnlPostLine.Run(GenJournalLine);
            until FALedgerEntry.Next() = 0;
    end;

    local procedure UnApplyVendInvoices(CheckLedgerEntry: Record "Check Ledger Entry"; VoidDate: Date): Boolean
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        OrigPaymentVendorLedgerEntry: Record "Vendor Ledger Entry";
        PayDetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        SourceCodeSetup: Record "Source Code Setup";
        GenJournalLine: Record "Gen. Journal Line";
        AppliesID: Code[50];
    begin
        BankAccountLedgerEntry.Get(CheckLedgerEntry."Bank Account Ledger Entry No.");
        SourceCodeSetup.Get();
        if CheckLedgerEntry."Bal. Account Type" = CheckLedgerEntry."Bal. Account Type"::Vendor then begin
            OrigPaymentVendorLedgerEntry.SetCurrentKey("Transaction No.");
            OrigPaymentVendorLedgerEntry.SetRange("Transaction No.", BankAccountLedgerEntry."Transaction No.");
            OrigPaymentVendorLedgerEntry.SetRange("Document No.", BankAccountLedgerEntry."Document No.");
            OrigPaymentVendorLedgerEntry.SetRange("Posting Date", BankAccountLedgerEntry."Posting Date");
            if not OrigPaymentVendorLedgerEntry.FindFirst() then
                exit(false);
        end else
            exit(false);

        AppliesID := CheckLedgerEntry."Document No.";
        PayDetailedVendorLedgEntry.SetCurrentKey("Vendor Ledger Entry No.", "Entry Type", "Posting Date");
        PayDetailedVendorLedgEntry.SetRange("Vendor Ledger Entry No.", OrigPaymentVendorLedgerEntry."Entry No.");
        PayDetailedVendorLedgEntry.SetRange(Unapplied, false);
        PayDetailedVendorLedgEntry.SetFilter("Applied Vend. Ledger Entry No.", '<>%1', 0);
        PayDetailedVendorLedgEntry.SetRange("Entry Type", PayDetailedVendorLedgEntry."Entry Type"::Application);
        if not PayDetailedVendorLedgEntry.FindSet() then
            Error(NoAppliedEntryErr);

        GenJournalLine."Document No." := OrigPaymentVendorLedgerEntry."Document No.";
        GenJournalLine."Posting Date" := VoidDate;
        GenJournalLine."Account Type" := GenJournalLine."Account Type"::Vendor;
        GenJournalLine."Account No." := OrigPaymentVendorLedgerEntry."Vendor No.";
        GenJournalLine.Correction := true;
        GenJournalLine.Description := StrSubstNo(VoidingCheckLbl, CheckLedgerEntry."Check No.");
        GenJournalLine."Shortcut Dimension 1 Code" := OrigPaymentVendorLedgerEntry."Global Dimension 1 Code";
        GenJournalLine."Shortcut Dimension 2 Code" := OrigPaymentVendorLedgerEntry."Global Dimension 2 Code";
        GenJournalLine."Posting Group" := OrigPaymentVendorLedgerEntry."Vendor Posting Group";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::Vendor;
        GenJournalLine."Source No." := OrigPaymentVendorLedgerEntry."Vendor No.";
        GenJournalLine."Source Code" := SourceCodeSetup."Financially Voided Check";
        GenJournalLine."Source Currency Code" := OrigPaymentVendorLedgerEntry."Currency Code";
        GenJournalLine."System-Created Entry" := true;
        GenJournalLine."Financial Void" := true;
        GenJnlPostLine.UnapplyVendLedgEntry(GenJournalLine, PayDetailedVendorLedgEntry);

        OrigPaymentVendorLedgerEntry.FindSet(true, false);
        repeat
            MakeAppliesID(AppliesID, CheckLedgerEntry."Document No.");
            OrigPaymentVendorLedgerEntry."Applies-to ID" := AppliesID;
            OrigPaymentVendorLedgerEntry.CalcFields("Remaining Amount");
            OrigPaymentVendorLedgerEntry."Amount to Apply" := OrigPaymentVendorLedgerEntry."Remaining Amount";
            OrigPaymentVendorLedgerEntry."Accepted Pmt. Disc. Tolerance" := false;
            OrigPaymentVendorLedgerEntry."Accepted Payment Tolerance" := 0;
            OrigPaymentVendorLedgerEntry.Modify();
        until OrigPaymentVendorLedgerEntry.Next() = 0;

        exit(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::CheckManagement, 'OnBeforeVoidCheckGenJnlLine2Modify', '', false, false)]
    local procedure OnBeforeVoidCheckGenJnlLine2Modify(GenJournalLine: Record "Gen. Journal Line"; var GenJournalLine2: Record "Gen. Journal Line")
    var
        CheckLedgerEntry: Record "Check Ledger Entry";
        GLSetup: Record "General Ledger Setup";
    begin
        GLSetup.Get();
        if not GLSetup."Activate Cheque No." then
            GenJournalLine2."Document No." := ''
        else begin
            GenJournalLine2."Cheque No." := '';
            GenJournalLine2."Cheque Date" := 0D;
        end;

        CheckLedgerEntry.Reset();
        CheckLedgerEntry.SetCurrentKey("Bank Account No.", "Entry Status", "Check No.");
        if GenJournalLine2.Amount <= 0 then
            CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine2."Account No.")
        else
            CheckLedgerEntry.SetRange("Bank Account No.", GenJournalLine2."Bal. Account No.");
        CheckLedgerEntry.SetRange("Entry Status", CheckLedgerEntry."Entry Status"::Printed);
        if not GLSetup."Activate Cheque No." then
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine2."Document No.")
        else
            CheckLedgerEntry.SetRange("Check No.", GenJournalLine2."Cheque No.");
        if CheckLedgerEntry.FindFirst() then begin
            CheckLedgerEntry."Original Entry Status" := CheckLedgerEntry."Entry Status";
            CheckLedgerEntry."Entry Status" := CheckLedgerEntry."Entry Status"::Voided;
            CheckLedgerEntry."Positive Pay Exported" := false;
            CheckLedgerEntry.Open := false;
            CheckLedgerEntry.Modify(true);
        end;
    end;

    [EventSubscriber(ObjectType::Report, Report::Check, 'OnAfterAssignGenJnlLineDocumentNo', '', false, false)]
    local procedure OnAfterAssignGenJnlLineDocumentNo(var GenJnlLine: Record "Gen. Journal Line"; PreviousDocumentNo: Code[20])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        ChequeNo: Code[20];
    begin
        if not GeneralLedgerSetup.Get() then
            exit;

        if not GeneralLedgerSetup."Activate Cheque No." then
            exit;

        ChequeNo := GenJnlLine."Document No.";
        GenJnlLine."Document No." := PreviousDocumentNo;
        GenJnlLine."Cheque No." := CopyStr(ChequeNo, 1, 10);
        GenJnlLine."Cheque Date" := GenJnlLine."Posting Date";
    end;

    procedure OnActionPrintCheckforContravoucher(GenJourLine: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentPrint: Codeunit "Document-Print";
    begin
        GenJournalLine.Reset();
        GenJournalLine.Copy(GenJourLine);
        DocumentPrint.PrintCheck(GenJournalLine);
        Codeunit.Run(Codeunit::"Adjust Gen. Journal Balance", GenJournalLine);
    end;

    procedure OnActionVoidCheckforContravoucher(GenJourLine: Record "Gen. Journal Line")
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        if not GeneralLedgerSetup."Activate Cheque No." then begin
            if Confirm(VoidCheckConfirmationLbl, false, GenJourLine."Document No.") then
                VoidCheckVoucher(GenJourLine);
        end else
            if Confirm(VoidCheckConfirmationLbl, false, GenJourLine."Cheque No.") then
                VoidCheckVoucher(GenJourLine);
    end;

    procedure OnActionVoidAllChecksforContravoucher(GenJourLine: Record "Gen. Journal Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        if Confirm(VoidAllCheckLbl, false) then begin
            GenJournalLine.Reset();
            GenJournalLine.Copy(GenJourLine);
            GenJournalLine.SetRange("Bank Payment Type", GenJourLine."Bank Payment Type"::"Computer Check");
            GenJournalLine.SetRange("Check Printed", true);
            if GenJournalLine.FindSet() then
                repeat
                    VoidCheckVoucher(GenJourLine);
                until GenJournalLine.Next() = 0;
        end;
    end;

}
