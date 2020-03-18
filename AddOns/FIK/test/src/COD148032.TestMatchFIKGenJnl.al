// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

Codeunit 148032 TestMatchFIKGenJnl
{

    Subtype = Test;
    TestPermissions = Disabled;

    VAR
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryUtility: Codeunit "Library - Utility";
        FIKManagement: Codeunit FIKManagement;
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
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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

        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -Amount, DocumentNo);

        // Expected FIK Description after Auto Apply - Matching Amount
        FIKStatusDescriptionExpected := FIKDescriptionFullMatchTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchGenJournalLines, GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, GenJnlLine."Document No.", GenJnlLine."Account Type"::Customer,
          CustomerNo, TRUE, FIKStatusDescriptionExpected);
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryPartialPayment();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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

        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Partial Amount
        FIKStatusDescriptionExpected := FIKDescriptionPartialTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"FIK_MatchGenJournalLines", GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, GenJnlLine."Document No.", GenJnlLine."Account Type"::Customer,
          CustomerNo, TRUE, FIKStatusDescriptionExpected);
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryExcessAmount();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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

        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Excess Amount
        FIKStatusDescriptionExpected := FIKDescriptionExtraTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"FIK_MatchGenJournalLines", GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, GenJnlLine."Document No.", GenJnlLine."Account Type"::Customer,
          CustomerNo, TRUE, FIKStatusDescriptionExpected);
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryDublicateFIK();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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

        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -GenLedgerAmount, DocumentNo);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -GenLedgerAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - Duplicate FIK numbers
        FIKStatusDescriptionExpected := FIKDescriptionDuplicateTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchGenJournalLines, GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, '', GenJnlLine."Account Type"::Customer,
          CustomerNo, FALSE, FIKStatusDescriptionExpected);
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryNoMatch();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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

        CreateGeneralJournalBatch(GenJnlBatch);
        DocumentNo := GenerateInvoiceDocumentNo();
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -PaymentAmount, DocumentNo);

        // Expected General Journal FIK Description after Auto Apply - No Match
        FIKStatusDescriptionExpected := FIKDescriptionNoMatchTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchGenJournalLines, GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, '', GenJnlLine."Account Type"::"G/L Account",
          '', FALSE, FIKStatusDescriptionExpected);
    END;

    [Test]
    [HandlerFunctions('MessageHandler')]
    PROCEDURE TestMatchFIKEntryIsPaid();
    VAR
        GenJnlLine: Record "Gen. Journal Line";
        GenJnlBatch: Record "Gen. Journal Batch";
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
        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -Amount, DocumentNo);
        CODEUNIT.RUN(CODEUNIT::FIK_MatchGenJournalLines, GenJnlLine);
        GenJnlLine.FIND();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        CreateGeneralJournalBatch(GenJnlBatch);
        InsertGenJnlLineWithFIKDescription(GenJnlLine, GenJnlBatch, -Amount, DocumentNo);

        // Expected FIK Description after Auto Apply - Is Paid
        FIKStatusDescriptionExpected := FIKDescriptionIsPaidTxt + ' - ' + GenJnlLine.Description;

        // Exercise
        CODEUNIT.RUN(CODEUNIT::FIK_MatchGenJournalLines, GenJnlLine);

        // Verify
        VerifyGenJnlLine(GenJnlLine, '', GenJnlLine."Account Type"::Customer,
          CustomerNo, FALSE, FIKStatusDescriptionExpected);
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

    LOCAL PROCEDURE InsertGenJnlLineWithFIKDescription(VAR GenJnlLine: Record "Gen. Journal Line"; GenJnlBatch: Record "Gen. Journal Batch"; Amount: Decimal; InvoiceNo: Code[20]);
    BEGIN
        LibraryERM.CreateGeneralJnlLine(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name,
          GenJnlLine."Document Type"::Payment, 0, '', Amount);
        GenJnlLine.VALIDATE(Description, InsertFIKDescription(InvoiceNo));
        GenJnlLine.VALIDATE("Payment Reference", InvoiceNo);
        GenJnlLine.MODIFY(TRUE);
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

    [Normal]
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

    LOCAL PROCEDURE InsertFIKDescription(DocumentNo: Code[20]): Text;
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

    LOCAL PROCEDURE VerifyGenJnlLine(VAR GenJnlLine: Record "Gen. Journal Line"; DocNo: Code[50]; AccountType: Option; AccountNo: Code[20]; Applied: Boolean; FIKDescription: Text);
    BEGIN
        GenJnlLine.SETFILTER(Description, FIKDescription);
        GenJnlLine.FINDSET();
        REPEAT
            GenJnlLine.TESTFIELD("Applies-to ID", DocNo);
            GenJnlLine.TESTFIELD("Account Type", AccountType);
            GenJnlLine.TESTFIELD("Account No.", AccountNo);
            GenJnlLine.TESTFIELD("Applied Automatically", Applied);
        UNTIL GenJnlLine.NEXT() = 0;
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

    [MessageHandler]
    PROCEDURE MessageHandler(Msg: Text[1024]);
    BEGIN
    END;

}

