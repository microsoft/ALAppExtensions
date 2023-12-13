// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 148033 TestMatchFIKBankPmtApp
{

    Subtype = Test;
    TestPermissions = Disabled;

    VAR
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        FIKManagement: Codeunit FIKManagement;
        Assert: Codeunit Assert;
        isInitialized: Boolean;
        FIKDescriptionPartialTxt: Label 'Partial Amount', Locked = true;
        FIKDescriptionExtraTxt: Label 'Excess Amount', Locked = true;
        FIKDescriptionDuplicateTxt: Label 'Duplicate FIK Number', Locked = true;
        FIKDescriptionNoMatchTxt: Label 'No Matching FIK Number', Locked = true;
        FIKDescriptionFullMatchTxt: Label 'Matching Amount', Locked = true;
        FIKDescriptionIsPaidTxt: Label 'Invoice Already Paid', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryMatchingAmount();
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Amount: Decimal;
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        FIKStatusDescriptionExpected: Text;
    BEGIN
        Initialize();

        // Setup
        Amount := LibraryRandom.RandDec(10000, 2);
        CustomerNo := CreateCustomer();
        DocumentNo := CreateCustLedgerEntry(CustomerNo, Amount);

        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, Amount, DocumentNo);

        // Expected FIK Description after Auto Apply - Matching Amount
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionFullMatchTxt, DocumentNo);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Verify
        CustLedgerEntry.FINDLAST();
        VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, CustLedgerEntry."Entry No.");
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryPartialPayment();
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        GenLedgerAmount: Decimal;
        PaymentAmount: Decimal;
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        FIKStatusDescriptionExpected: Text;

    BEGIN
        Initialize();

        // Setup
        GenLedgerAmount := LibraryRandom.RandDecInRange(5000, 10000, 2);
        PaymentAmount := LibraryRandom.RandDecInRange(100, 4500, 2);
        CustomerNo := CreateCustomer();
        DocumentNo := CreateCustLedgerEntry(CustomerNo, GenLedgerAmount);

        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Partial Amount
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionPartialTxt, DocumentNo);

        // Exercise

        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Verify
        CustLedgerEntry.FINDLAST();
        VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, CustLedgerEntry."Entry No.");
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryExcessAmount();
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        GenLedgerAmount: Decimal;
        PaymentAmount: Decimal;
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        FIKStatusDescriptionExpected: Text;
    BEGIN
        Initialize();
        // Setup
        GenLedgerAmount := LibraryRandom.RandDecInRange(5000, 10000, 2);
        PaymentAmount := LibraryRandom.RandDecInRange(10100, 11000, 2);
        CustomerNo := CreateCustomer();
        DocumentNo := CreateCustLedgerEntry(CustomerNo, GenLedgerAmount);

        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Excess Amount
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionExtraTxt, DocumentNo);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);
        // Verify
        CustLedgerEntry.FINDLAST();
        VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, CustLedgerEntry."Entry No.");
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryDublicateFIK();
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        GenLedgerAmount: Decimal;
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        FIKStatusDescriptionExpected: Text;
    BEGIN
        Initialize();

        // Setup
        GenLedgerAmount := LibraryRandom.RandDecInRange(5000, 10000, 2);
        CustomerNo := CreateCustomer();
        DocumentNo := CreateCustLedgerEntry(CustomerNo, GenLedgerAmount);

        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, GenLedgerAmount, DocumentNo);
        InsertBankPaymentAppLine(BankAccReconciliation, GenLedgerAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Duplicate FIK numbers
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionDuplicateTxt, DocumentNo);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Verify
        CustLedgerEntry.FINDLAST();
        VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, CustLedgerEntry."Entry No.");
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryNoMatch();
    VAR
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        GenLedgerAmount: Decimal;
        PaymentAmount: Decimal;
        FIKStatusDescriptionExpected: Text;
        CustomerNo: Code[20];
        DocumentNo: Code[20];
    BEGIN
        Initialize();

        // Setup
        GenLedgerAmount := LibraryRandom.RandDecInRange(5000, 10000, 2);
        PaymentAmount := LibraryRandom.RandDecInRange(10100, 11000, 2);
        CustomerNo := CreateCustomer();
        CreateCustLedgerEntry(CustomerNo, GenLedgerAmount);

        DocumentNo := GenerateInvoiceDocumentNo();
        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - No Match
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionNoMatchTxt, DocumentNo);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Verify
        ASSERTERROR
          VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, 0);
        Assert.ExpectedError('The Applied Payment Entry does not exist.');
    END;

    [Test]
    [HandlerFunctions('MessageHandler,PostAndReconcilePageHandler,PostAndReconcilePageStatementDateHandler')]
    PROCEDURE TestMatchFIKEntryIsPaid();
    VAR
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        Amount: Decimal;
        DocumentNo: Code[20];
        CustomerNo: Code[20];
        FIKStatusDescriptionExpected: Text;
    BEGIN
        Initialize();

        // Setup
        Amount := LibraryRandom.RandDec(10000, 2);
        CustomerNo := CreateCustomer();
        DocumentNo := CreateCustLedgerEntry(CustomerNo, Amount);

        // Create an Invoice and make a Payment to it
        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, Amount, DocumentNo);
        GetLinesAndUpdateBankAccRecStmEndingBalance(BankAccReconciliation);
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Post the Bank Account Reconciliation
        CODEUNIT.RUN(CODEUNIT::"Bank Acc. Reconciliation Post", BankAccReconciliation);

        CreateNewBankPaymentApp(BankAccReconciliation);
        InsertBankPaymentAppLine(BankAccReconciliation, Amount, DocumentNo);

        // Expected FIK Description after Auto Apply - Is Paid
        FIKStatusDescriptionExpected := CreateExpectedFIKStatus(FIKDescriptionIsPaidTxt, DocumentNo);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchBankRecLines, BankAccReconciliation);

        // Verify
        VerifyBankAccReconciliationLines(BankAccReconciliation, FIKStatusDescriptionExpected, 0);
    END;

    LOCAL PROCEDURE Initialize();
    BEGIN
        CloseExistingEntries();
        IF isInitialized THEN
            EXIT;

        LibraryERMCountryData.UpdateLocalData();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        isInitialized := TRUE;
    END;

    LOCAL PROCEDURE CreateCustomer(): Code[20];
    VAR
        Customer: Record Customer;
    BEGIN
        LibrarySales.CreateCustomer(Customer);
        EXIT(Customer."No.");
    END;

    LOCAL PROCEDURE CreateNewBankPaymentApp(VAR BankAccReconciliation: Record "Bank Acc. Reconciliation");
    VAR
        BankAccount: Record "Bank Account";
    BEGIN
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccReconciliation.INIT();
        BankAccReconciliation.VALIDATE("Statement Type", BankAccReconciliation."Statement Type"::"Payment Application");
        BankAccReconciliation.VALIDATE("Bank Account No.", BankAccount."No.");
        BankAccReconciliation.VALIDATE("Statement No.",
          LibraryUtility.GenerateRandomCode(BankAccReconciliation.FIELDNO("Statement No."), DATABASE::"Bank Acc. Reconciliation"));
        BankAccReconciliation.INSERT(TRUE);
    END;

    LOCAL PROCEDURE InsertBankPaymentAppLine(VAR BankAccReconciliation: Record "Bank Acc. Reconciliation"; Amount: Decimal; InvoiceNo: Code[20]);
    VAR
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        RecRef: RecordRef;
    BEGIN
        BankAccReconciliationLine.INIT();
        BankAccReconciliationLine.VALIDATE("Bank Account No.", BankAccReconciliation."Bank Account No.");
        BankAccReconciliationLine.VALIDATE("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.VALIDATE("Transaction Text", CreateFIKDescription(InvoiceNo));
        BankAccReconciliationLine.VALIDATE(PaymentReference, InvoiceNo);
        BankAccReconciliationLine.VALIDATE("Statement Amount", Amount);
        BankAccReconciliationLine.VALIDATE("Statement Type", BankAccReconciliationLine."Statement Type"::"Payment Application");
        BankAccReconciliationLine.VALIDATE("Transaction Date", WORKDATE());
        RecRef.GETTABLE(BankAccReconciliationLine);
        BankAccReconciliationLine.VALIDATE(
          "Statement Line No.", LibraryUtility.GetNewLineNo(RecRef, BankAccReconciliationLine.FIELDNO("Statement Line No.")));
        BankAccReconciliationLine.INSERT(TRUE);
    END;

    LOCAL PROCEDURE CreateGeneralJournalBatch(VAR GenJnlBatch: Record "Gen. Journal Batch");
    VAR
        GLAccount: Record "G/L Account";
        GenJournalTemplate: Record "Gen. Journal Template";
    BEGIN
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGLAccount(GLAccount);
        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"G/L Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", GLAccount."No.");
        GenJnlBatch.MODIFY(TRUE);
    END;

    LOCAL PROCEDURE CloseExistingEntries();
    VAR
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    BEGIN
        CustLedgerEntry.SETRANGE(Open, TRUE);
        CustLedgerEntry.MODIFYALL(Open, FALSE);
        VendorLedgerEntry.SETRANGE(Open, TRUE);
        VendorLedgerEntry.MODIFYALL(Open, FALSE);
    END;

    LOCAL PROCEDURE CreateFIKDescription(DocumentNo: Code[20]): Text;
    VAR
        StringLen: Integer;
        Total: Integer;
        CheckSum: Integer;
        Weight: Text;
        String: Text;
    BEGIN
        StringLen := 15;
        String := PADSTR('', StringLen - 1 - STRLEN(DocumentNo), '0') + DocumentNo;
        Weight := '12121212121212';
        FIKManagement.CreateFIKCheckSum(String, Weight, Total, CheckSum);
        EXIT('FIK - ' + String + FORMAT(CheckSum));
    END;

    LOCAL PROCEDURE VerifyBankAccReconciliationLines(VAR BankAccReconciliation: Record "Bank Acc. Reconciliation"; FIKDescription: Text; CustLedgerEntryNo: Integer);
    VAR
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        AppliedPaymentEntry: Record "Applied Payment Entry";
        CustLedgerEntries: ARRAY[2] OF Integer;
        Index: Integer;
    BEGIN
        Index := 1;
        CustLedgerEntries[1] := CustLedgerEntryNo;

        WITH BankAccReconciliationLine DO BEGIN
            SETRANGE("Statement Type", BankAccReconciliation."Statement Type");
            SETRANGE("Bank Account No.", BankAccReconciliation."Bank Account No.");
            SETRANGE("Statement No.", BankAccReconciliation."Statement No.");
            FINDSET();
            REPEAT
                TESTFIELD("Transaction Text", FIKDescription);

                AppliedPaymentEntry.GET(
                  "Statement Type",
                  "Bank Account No.",
                  "Statement No.",
                  "Statement Line No.",
                  "Account Type",
                  "Account No.",
                  CustLedgerEntries[Index]);
                Index += 1;
            UNTIL NEXT() = 0;
        END;
    END;

    LOCAL PROCEDURE GenerateInvoiceDocumentNo(): Code[10];
    BEGIN
        EXIT(COPYSTR(LibraryUtility.GenerateGUID(), 3, 10)); // Returns numeric string
    END;

    LOCAL PROCEDURE CreateCustLedgerEntry(AccountNo: Code[20]; Amount: Decimal): Code[10];
    VAR
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[10];
    BEGIN
        CreateGeneralJournalBatch(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Customer, AccountNo, Amount);
        DocumentNo := GenerateInvoiceDocumentNo();
        GenJournalLine.VALIDATE("Document No.", DocumentNo);
        GenJournalLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        EXIT(DocumentNo);
    END;

    LOCAL PROCEDURE CreateExpectedFIKStatus(StatusText: Text; DocumentNo: Code[20]): Text;
    BEGIN
        EXIT(StatusText + ' - ' + CreateFIKDescription(DocumentNo));
    END;

    local procedure GetLinesAndUpdateBankAccRecStmEndingBalance(var BankAccRecon: Record "Bank Acc. Reconciliation")
    var
        BankAccRecLine: Record "Bank Acc. Reconciliation Line";
        TotalLinesAmount: Decimal;
    begin
        BankAccRecLine.LinesExist(BankAccRecon);
        repeat
            TotalLinesAmount += BankAccRecLine."Statement Amount";
        until BankAccRecLine.Next() = 0;
        UpdateBankAccRecStmEndingBalance(BankAccRecon, BankAccRecon."Balance Last Statement" + TotalLinesAmount);
    end;

    local procedure UpdateBankAccRecStmEndingBalance(var BankAccRecon: Record "Bank Acc. Reconciliation"; NewStmEndingBalance: Decimal)
    begin
        BankAccRecon.Validate("Statement Ending Balance", NewStmEndingBalance);
        BankAccRecon.Modify();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure PostAndReconcilePageHandler(var PostPmtsAndRecBankAcc: TestPage "Post Pmts and Rec. Bank Acc.")
    begin
        PostPmtsAndRecBankAcc.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure PostAndReconcilePageStatementDateHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    PROCEDURE MessageHandler(Msg: Text[1024]);
    BEGIN
    END;

}

