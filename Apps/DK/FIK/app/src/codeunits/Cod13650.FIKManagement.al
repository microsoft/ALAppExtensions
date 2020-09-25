// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 13650 FIKManagement
{
    VAR
        FIKLengthErr: Label 'Payment Reference for %1 cannot be longer than %2.', Comment = '%1=Field,%2=Value';
        WrongCheckCypherErr: Label 'The Payment Reference that you entered does not have the correct control cipher.';
        FIKPmtErr: Label 'The selected payment method is not a FIK payment.';
        PmtReferenceErr: Label 'Payment Reference should be blank for payment method %1.', Comment = '%1=Name of selected payment method';
        ProgressWindowMsg: Label 'Please wait while the operation is being completed.';
        FIKPrefixTxt: Label 'FIK', Locked = true;
        BankAccountCurrencyNotLCYErr: Label 'You cannot use bank account %1 for importing a FIK statement because the bank account currency is %2. The bank account currency must be DKK.', Comment = '%1: Bank Account No., %2: Currency Code';
        PmtTypeValidationErr: Label 'The %1 in %2, %3 must be %4 or %5.', Comment = 'The Payment Type Validation in Payment Method, Code must be Domestic or International.';
        CreditorNumberLengthErr: Label 'The Creditor Number field must not exceed %1 digits.';

    PROCEDURE CreateFIKCheckSum(String: Text; Weight: Text; VAR Total: Integer; VAR CheckSum: Integer): Integer;
    VAR
        StringDigit: Integer;
        WeightDigit: Integer;
        ProductDigit: Integer;
    BEGIN
        EVALUATE(StringDigit, COPYSTR(String, 1, 1));
        EVALUATE(WeightDigit, COPYSTR(Weight, 1, 1));
        ProductDigit := StringDigit * WeightDigit;
        IF ProductDigit >= 10 THEN
            Total += 1 + (ProductDigit MOD 10)
        ELSE
            Total += ProductDigit;

        IF STRLEN(String) > 1 THEN BEGIN
            String := COPYSTR(String, 2, STRLEN(String) - 1);
            Weight := COPYSTR(Weight, 2, STRLEN(Weight) - 1);
            CreateFIKCheckSum(String, Weight, Total, CheckSum);
        END ELSE BEGIN
            CheckSum := 10 - (Total MOD 10);
            IF CheckSum = 10 THEN
                CheckSum := 0;
        END;
        EXIT(CheckSum);
    END;

    LOCAL PROCEDURE ValidateFIKCheckSum(FikString: Text; Weight: Text): Boolean;
    VAR
        ActualCheckSum: Text;
        Total: Integer;
        ExpectedCheckSum: Integer;
    BEGIN
        ActualCheckSum := COPYSTR(FikString, STRLEN(FikString), 1);
        FikString := COPYSTR(FikString, 1, STRLEN(FikString) - 1);
        CreateFIKCheckSum(FikString, Weight, Total, ExpectedCheckSum);
        EXIT(ActualCheckSum = FORMAT(ExpectedCheckSum));
    END;

    PROCEDURE EvaluateFIK(PaymentReference: Text[50]; PaymentMethodCode: Code[10]): Text[50];
    VAR
        PaymentMethod: Record "Payment Method";
        Result: Boolean;
        IsHandled: Boolean;
    BEGIN
        IF PaymentReference = '' THEN
            EXIT;
        Result := FALSE;
        PaymentMethod.GET(PaymentMethodCode);
        CASE PaymentMethod.PaymentTypeValidation OF
            PaymentMethod.PaymentTypeValidation::"FIK 71":
                BEGIN
                    IF STRLEN(PaymentReference) > 15 THEN
                        ERROR(FIKLengthErr, PaymentMethod.PaymentTypeValidation::"FIK 71", 15);
                    PaymentReference := PADSTR('', 15 - STRLEN(PaymentReference), '0') + PaymentReference;
                    Result := ValidateFIKCheckSum(PaymentReference, '12121212121212');
                END;
            PaymentMethod.PaymentTypeValidation::"FIK 04":
                BEGIN
                    PaymentReference := PADSTR('', 16 - STRLEN(PaymentReference), '0') + PaymentReference;
                    Result := ValidateFIKCheckSum(PaymentReference, '212121212121212');
                END;
            PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 73":
                ERROR(PmtReferenceErr, PaymentMethod.PaymentTypeValidation);
            ELSE begin
                    OnEvaluateFIKCasePaymentTypeValidationElse(PaymentReference, PaymentMethod, Result, IsHandled);
                    if not IsHandled then
                        ERROR(FIKPmtErr);
                end;
        END;
        IF NOT Result THEN
            ERROR(WrongCheckCypherErr);
        EXIT(PaymentReference);
    END;

    procedure GetFIK71String(SalesInvoiceHeaderNo: Code[20]): Text
    var
        CompanyInformation: Record "Company Information";
        FikManagement: Codeunit FIKManagement;
        StringLen: Integer;
        CheckSum: Integer;
        Total: Integer;
        Weight: Text;
        StringText: Text;

    BEGIN
        StringLen := 15;

        IF STRLEN(SalesInvoiceHeaderNo) > (StringLen - 1) THEN
            EXIT;

        IF DELCHR(SalesInvoiceHeaderNo, '=', '0123456789') <> '' THEN
            EXIT;

        CompanyInformation.GET();
        IF CompanyInformation.BankCreditorNo = '' THEN
            EXIT;

        StringText := PADSTR('', (StringLen - 1 - STRLEN(SalesInvoiceHeaderNo)), '0') + SalesInvoiceHeaderNo;
        Weight := '12121212121212';
        FikManagement.CreateFIKCheckSum(StringText, Weight, Total, CheckSum);

        EXIT('+71<' + StringText + FORMAT(CheckSum) + '+' + CompanyInformation.BankCreditorNo);
    END;

    procedure ImportFIKToBankAccRecLine(var BankAccRecon: Record "Bank Acc. Reconciliation"): Boolean;
    var
        BankAcc: Record "Bank Account";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExch: Record "Data Exch.";
        BankAccReconLine: Record "Bank Acc. Reconciliation Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ProcessBankAccRecLines: Codeunit "Process Bank Acc. Rec Lines";
        ProgressWindow: Dialog;
    begin
        BankAcc.GET(BankAccRecon."Bank Account No.");

        IF NOT BankAcc.IsInLocalCurrency() THEN
            ERROR(STRSUBSTNO(BankAccountCurrencyNotLCYErr, BankAcc."No.", BankAcc."Currency Code"));

        GeneralLedgerSetup.Get();
        DataExchDef.Get(GeneralLedgerSetup."FIK Import Format");

        IF NOT DataExch.ImportToDataExch(DataExchDef) THEN
            EXIT(FALSE);

        ProgressWindow.OPEN(ProgressWindowMsg);
        ProcessBankAccRecLines.CreateBankAccRecLineTemplate(BankAccReconLine, BankAccRecon, DataExch);
        BankAccReconLine."Transaction Text" := FIKPrefixTxt;

        DataExchLineDef.SETRANGE("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FINDFIRST();

        DataExchMapping.GET(DataExchDef.Code, DataExchLineDef.Code, DATABASE::"Bank Acc. Reconciliation Line");
        DataExchMapping.TESTFIELD("Mapping Codeunit");
        CODEUNIT.RUN(DataExchMapping."Mapping Codeunit", BankAccReconLine);

        UpdateFIKBankAccReconciliation(BankAccRecon);

        BankAccRecon.FIKPaymentReconciliation := TRUE;
        BankAccRecon.MODIFY();

        ProgressWindow.CLOSE();
        EXIT(TRUE);
    end;

    local procedure UpdateFIKBankAccReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation");
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
    begin
        BankAccReconciliationLine.SETRANGE("Statement No.", BankAccReconciliation."Statement No.");
        IF BankAccReconciliationLine.FINDSET() THEN
            REPEAT
                UpdateFIKPaymentReferenceBankRecLines(BankAccReconciliationLine);
                BankAccReconciliationLine.MODIFY(TRUE);
            UNTIL BankAccReconciliationLine.NEXT() = 0;
    end;

    local procedure UpdateFIKPaymentReferenceBankRecLines(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line");
    var
        FIKPmtReference: Text[14];
        ReferenceNumber: Integer;
    begin
        WITH BankAccReconciliationLine DO
            IF STRPOS("Transaction Text", FIKPrefixTxt + ' ') = 1 THEN BEGIN
                FIKPmtReference := COPYSTR(Description, STRLEN(FIKPrefixTxt) + 2, MAXSTRLEN(FIKPmtReference));
                IF EVALUATE(ReferenceNumber, FIKPmtReference) THEN
                    VALIDATE(PaymentReference, FORMAT(ReferenceNumber));
            END;
    end;

    procedure ImportFIKGenJournalLine(GenJnlLine: Record "Gen. Journal Line");
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        DataExchLineDef: Record "Data Exch. Line Def";
        DataExch: Record "Data Exch.";
        GenJnlLineTemplate: Record "Gen. Journal Line";
        GeneralLedgerSetup: Record "General Ledger Setup";
        ProcessGenJnlLine: Codeunit "Process Gen. Journal  Lines";
        ProgressWindow: Dialog;
    begin
        GenJnlBatch.GET(GenJnlLine."Journal Template Name", GenJnlLine."Journal Batch Name");

        GeneralLedgerSetup.Get();
        DataExchDef.Get(GeneralLedgerSetup."FIK Import Format");

        ProcessGenJnlLine.CreateGeneralJournalLineTemplate(GenJnlLineTemplate, GenJnlLine);
        GenJnlLineTemplate."Document Type" := GenJnlLineTemplate."Document Type"::Payment;
        GenJnlLineTemplate.Description := FIKPrefixTxt;

        IF NOT DataExch.ImportToDataExch(DataExchDef) THEN
            EXIT;

        GenJnlLineTemplate."Data Exch. Entry No." := DataExch."Entry No.";

        ProgressWindow.OPEN(ProgressWindowMsg);

        DataExchLineDef.SETRANGE("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FINDFIRST();

        DataExchMapping.GET(DataExchDef.Code, DataExchLineDef.Code, DATABASE::"Gen. Journal Line");
        DataExchMapping.TESTFIELD("Mapping Codeunit");
        CODEUNIT.RUN(DataExchMapping."Mapping Codeunit", GenJnlLineTemplate);


        ProcessGenJnlLine.UpdateGenJournalLines(GenJnlLineTemplate);
        UpdateGenJournalLines(GenJnlLineTemplate);

        ProgressWindow.CLOSE();
    end;

    procedure UpdateGenJournalLines(var GenJournalLineTemplate: Record "Gen. Journal Line");
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalLineTemplate."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalLineTemplate."Journal Batch Name");
        GenJournalLine.SETFILTER("Line No.", '>%1', GenJournalLineTemplate."Line No.");
        IF GenJournalLine.FINDSET() THEN
            REPEAT
                UpdateFIKPaymentReference(GenJournalLine);
                GenJournalLine.Modify(TRUE);
            UNTIL GenJournalLine.NEXT() = 0;
    end;

    local procedure UpdateFIKPaymentReference(var GenJournalLine: Record "Gen. Journal Line");
    var
        TempString: Text;
        TempValue: Integer;
    begin
        WITH GenJournalLine DO
            IF STRPOS(Description, FIKPrefixTxt + ' ') = 1 THEN BEGIN
                TempString := COPYSTR(Description, 5, 14);
                IF EVALUATE(TempValue, TempString) THEN
                    VALIDATE("Payment Reference", FORMAT(TempValue));
            END;
    end;

    procedure AddMatchCandidateWithDescription(VAR TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary; LineNo: Integer; EntryNo: Integer; Quality: Integer; Type: Option; AccountNo: Code[20]; NewDescription: Text[100]; Status: Option);
    BEGIN
        TempBankStatementMatchingBuffer.AddMatchCandidate(LineNo, EntryNo, Quality, Type, AccountNo);
        TempBankStatementMatchingBuffer.DescriptionBankStatment := NewDescription;
        TempBankStatementMatchingBuffer.MatchStatus := Status;
        TempBankStatementMatchingBuffer.MODIFY();
    END;

    //cod1210
    PROCEDURE CheckBankTransferCountryRegion(BankAccCountryRegionCode: Code[10]; RecipientBankAccCountryRegionCode: Code[10]; PaymentMethod: Record "Payment Method");
    var
        CompanyInformation: Record "Company Information";
    BEGIN
        CompanyInformation.GET();

        IF (CompanyInformation.GetCountryRegionCode(RecipientBankAccCountryRegionCode) <>
           CompanyInformation.GetCountryRegionCode(BankAccCountryRegionCode)) THEN
            PaymentMethod.TESTFIELD(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::International)
        ELSE
            IF PaymentMethod.PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::International THEN
                PaymentMethod.FIELDERROR(PaymentTypeValidation);
    END;

    PROCEDURE CheckCustRefundPaymentTypeValidation(PaymentMethod: Record "Payment Method");
    BEGIN
        IF NOT (PaymentMethod.PaymentTypeValidation IN
          [PaymentMethod.PaymentTypeValidation::Domestic, PaymentMethod.PaymentTypeValidation::International]) THEN
            ERROR(PmtTypeValidationErr, PaymentMethod.FIELDCAPTION(PaymentMethod.PaymentTypeValidation), PaymentMethod.TABLECAPTION(), PaymentMethod.Code,
              PaymentMethod.PaymentTypeValidation::Domestic, PaymentMethod.PaymentTypeValidation::International);
    END;

    procedure GetCreditorNoLength(): Integer
    begin
        exit(8);
    end;

    procedure FormValidCreditorNo(CreditorNo: Code[20]): Code[20]
    begin
        IF CreditorNo = '' THEN
            EXIT('');
        IF STRLEN(CreditorNo) > GetCreditorNoLength() THEN
            ERROR(STRSUBSTNO(CreditorNumberLengthErr, GetCreditorNoLength()));
        EXIT(PADSTR('', GetCreditorNoLength() - STRLEN(CreditorNo), '0') + CreditorNo);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnEvaluateFIKCasePaymentTypeValidationElse(var PaymentReference: Text[50]; PaymentMethod: Record "Payment Method"; var Result: Boolean; var IsHandled: Boolean)
    begin
    end;
}

