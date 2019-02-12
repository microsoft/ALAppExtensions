// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148022 "Payment Export Negative"
{
    // version Test,ERM,DK

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryPaymentExportDK: Codeunit "Library - Payment Export DK";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        EmptyPaymentDetailsErr: Label '%1, %2 or %3 must be used for payments.', Locked = true;
        LedgerEntryNotOpenErr: Label 'Open must be equal to ''%1''  in %2', Locked = true;
        RecipientBankAccMissingErr: Label '%1 for one or more %2 is not specified.', Locked = true;
        ValueEqualErr: Label '%1 must be equal to ''%2''  in %3', Locked = true;
        ValueNotSetErr: Label '%1 must have a value in %2', Locked = true;
        WrongBalAccountErr: Label '%1 for the %2 is different from %3 on %4: %5.', Locked = true;
        ValueNotEqualErr: Label '%1 must not be %2 in %3', Locked = true;
        MustBeVendorOrCustomerErr: Label 'The account must be a vendor or customer account.', Locked = true;
        HasErrorsErr: Label 'The file export has one or more errors.\\For each line to be exported, resolve the errors displayed to the right and then try to export again.', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    [HandlerFunctions('VendorBankAccountListPageHandler')]
    procedure CancelLookupOfPmtJnlLineBeneficiaryBankAcc();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentJournal: TestPage "Payment Journal";
        LineNo: Integer;
    begin
        // 2.2
        Initialize();

        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithoutPreferredBankAcc(GenJournalLine, GenJournalBatch);
        COMMIT();

        // Post-Setup
        LineNo := GenJournalLine."Line No.";

        // Pre-Exercise
        PaymentJournal.OPENEDIT();
        PaymentJournal.CurrentJnlBatchName.SETVALUE(GenJournalBatch.Name);
        PaymentJournal."Recipient Bank Account".ACTIVATE();
        PaymentJournal."Recipient Bank Account".ASSERTEQUALS('');

        // Exercise
        PaymentJournal."Recipient Bank Account".LOOKUP();
        PaymentJournal.OK().INVOKE();

        // Verify
        GenJournalLine.GET(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, LineNo);
        GenJournalLine.TESTFIELD("Recipient Bank Account", '');
    end;

    [Test]
    [HandlerFunctions('VendorBankAccountListPageHandler')]
    procedure CancelLookupOfVendorPreferredBankAcc();
    var
        Vendor: Record Vendor;
        VendorCard: TestPage "Vendor Card";
        VendorNo: Code[20];
    begin
        // 2.1
        Initialize();

        // Setup
        LibraryPaymentExportDK.CreateVendorWithMultipleBankAccounts(Vendor);

        // Post-Setup
        VendorNo := Vendor."No.";

        // Pre-Exercise
        VendorCard.OPENEDIT();
        VendorCard.GOTORECORD(Vendor);

        // Exercise
        VendorCard."Preferred Bank Account Code".LOOKUP();

        // Post-Exercise
        VendorCard.CLOSE();

        // Verify
        Vendor.GET(VendorNo);
        Vendor.TESTFIELD("Preferred Bank Account Code", '');
    end;

    [Test]
    procedure EditCustLedgEntryDomesticToInternational();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        SetCustomerCountryToDomestic(Customer);
        SetPmtMethodTypeValidation(Customer."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::International);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CustLedgEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueNotEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure EditCustLedgEntryInternationalToDomestic();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        SetCustomerCountryToInternational(Customer);
        SetPmtMethodTypeValidation(Customer."Payment Method Code", PaymentMethod.PaymentTypeValidation::International);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::Domestic);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CustLedgEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure EditPmtJnlLineDomesticToInternational();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorCountryToDomestic(Vendor);
        SetPmtMethodTypeValidation(Vendor."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::International);

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueNotEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure EditPmtJnlLineInternationalToDomestic();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorCountryToInternational(Vendor);
        SetPmtMethodTypeValidation(Vendor."Payment Method Code", PaymentMethod.PaymentTypeValidation::International);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::Domestic);

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify

        Assert.ExpectedError(
          STRSUBSTNO(ValueEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure EditVendLedgEntryDomesticToInternational();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorCountryToDomestic(Vendor);
        SetPmtMethodTypeValidation(Vendor."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::International);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR VendLedgEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueNotEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure EditVendLedgEntryInternationalToDomestic();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorCountryToInternational(Vendor);
        SetPmtMethodTypeValidation(Vendor."Payment Method Code", PaymentMethod.PaymentTypeValidation::International);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Setup
        CreatePaymentMethod(PaymentMethod, PaymentMethod.PaymentTypeValidation::Domestic);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR VendLedgEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International,
            PaymentMethod.TABLECAPTION()));
    end;

    [Test]
    procedure ExportCustLedgerEntryMissingExportXMLPort();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DataExchDef: Record "Data Exch. Def";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocNo: Code[20];
    begin
        // 2.7
        Initialize();

        // Pre-Setup
        DocNo := CreatePmtCustLedgerEntryWithRecipientBankAcc(DataExchDef, XMLPORT::"Export Generic CSV");
        CustLedgerEntry.SETRANGE("Document No.", DocNo);
        CustLedgerEntry.FINDLAST();

        // Setup
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchDef.GET(BankAccount."Payment Export Format");
        DataExchDef."Reading/Writing XMLport" := 0;
        DataExchDef.MODIFY();

        // Exercise
        ASSERTERROR PmtExportMgtCustLedgEntry.ExportCustPaymentFile(CustLedgerEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueNotSetErr, DataExchDef.FIELDCAPTION("Reading/Writing XMLport"), DataExchDef.TABLECAPTION()));
    end;

    [Test]
    procedure ExportCustLedgerEntryMissingRecipientBankAcc();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
    begin
        // 2.12
        Initialize();

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", CreatePmtCustLedgerEntryMissingRecipientBankAcc());
        CustLedgerEntry.FINDLAST();

        // Exercise
        ASSERTERROR PmtExportMgtCustLedgEntry.ExportCustPaymentFile(CustLedgerEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(RecipientBankAccMissingErr, CustLedgerEntry.FIELDCAPTION("Recipient Bank Account"), CustLedgerEntry.TABLECAPTION()));
    end;

    [Test]
    procedure ExportMultiplePmtJnlLineDifferentBalAccType();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        DataExchDef: Record "Data Exch. Def";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // 2.10
        Initialize();

        // Pre-Setup
        CreatePaymentExportBatchWithTwoLines(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");

        // Setup
        LibraryERM.CreateGLAccount(GLAccount);
        UpdateLastPmtJnlLineBalAccTypeAndNo(GenJournalBatch, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.");

        // Pre-Exercise
        FindPaymentJournalLines(GenJournalLine, GenJournalBatch);

        // Exercise
        ASSERTERROR PmtExportMgtGenJnlLine.ExportJournalPaymentFile(GenJournalLine);

        // Post-Exercise
        Assert.ExpectedError(HasErrorsErr);

        // Pre-Verify
        GenJournalLine.NEXT();

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJournalLine,
          CopyStr(STRSUBSTNO(WrongBalAccountErr, GenJournalLine.FIELDCAPTION("Bal. Account Type"),
            GenJournalLine.TABLECAPTION(), GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalBatch.TABLECAPTION(), GenJournalBatch.Name), 1, 250));
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJournalLine,
          CopyStr(STRSUBSTNO(WrongBalAccountErr, GenJournalLine.FIELDCAPTION("Bal. Account No."),
            GenJournalLine.TABLECAPTION(), GenJournalBatch."Bal. Account No.",
            GenJournalBatch.TABLECAPTION(), GenJournalBatch.Name), 1, 250));
    end;

    [Test]
    procedure ExportMultiplePmtJnlLineDifferentBalBankAcc();
    var
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // 2.8
        Initialize();

        // Pre-Setup
        CreatePaymentExportBatchWithTwoLines(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");

        // Setup
        LibraryERM.CreateBankAccount(BankAccount);
        UpdateLastPmtJnlLineBalAccTypeAndNo(GenJournalBatch, GenJournalLine."Bal. Account Type"::"Bank Account", BankAccount."No.");

        // Pre-Exercise
        FindPaymentJournalLines(GenJournalLine, GenJournalBatch);

        // Exercise
        ASSERTERROR PmtExportMgtGenJnlLine.ExportJournalPaymentFile(GenJournalLine);

        // Post-Exercise
        Assert.ExpectedError(HasErrorsErr);

        // Pre-Verify
        GenJournalLine.NEXT();

        // Verify
        // Bal. Account No. for the Gen. Journal Line is different from GU00000000 on Gen. Journal Batch: GU00000001.
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJournalLine,
          CopyStr(STRSUBSTNO(WrongBalAccountErr, GenJournalLine.FIELDCAPTION("Bal. Account No."),
            GenJournalLine.TABLECAPTION(), GenJournalBatch."Bal. Account No.",
            GenJournalBatch.TABLECAPTION(), GenJournalBatch.Name), 1, 250));
    end;

    [Test]
    procedure ExportPmtJnlLineMissingExportXMLPort();
    var
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        DataExchDef: Record "Data Exch. Def";
        Vendor: Record Vendor;
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // 2.5
        Initialize();

        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        SetBankAccCountryToDomestic(GenJournalBatch."Bal. Account No.");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJournalLine, GenJournalBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        Vendor.GET(GenJournalLine."Account No.");
        SetVendorCountryToDomestic(Vendor);
        GenJournalLine.VALIDATE("Creditor No.", '');
        GenJournalLine.VALIDATE(GiroAccNo, '');
        GenJournalLine.MODIFY(TRUE);

        // Setup
        BankAccount.GET(GenJournalBatch."Bal. Account No.");
        DataExchDef.GET(BankAccount."Payment Export Format");
        DataExchDef."Reading/Writing XMLport" := 0;
        DataExchDef.MODIFY();

        // Pre-Exercise
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        IF GenJournalLine."Account Type" = GenJournalLine."Account Type"::"Bank Account" THEN
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        IF GenJournalLine."Bal. Account Type" = GenJournalLine."Bal. Account Type"::"Bank Account" THEN
            GenJournalLine."Bank Payment Type" := GenJournalLine."Bank Payment Type"::"Electronic Payment";
        GenJournalLine.MODIFY();

        // Exercise
        ASSERTERROR PmtExportMgtGenJnlLine.ExportJournalPaymentFile(GenJournalLine);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(ValueNotSetErr, DataExchDef.FIELDCAPTION("Reading/Writing XMLport"), DataExchDef.TABLECAPTION()));
    end;

    [Test]
    procedure ExportPmtJnlLineNonBankBalAcc();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
    begin
        // 2.9
        Initialize();

        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Setup
        SetBalAccountToGLAccount(GenJournalLine);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJournalLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJournalLine,
          CopyStr(STRSUBSTNO(WrongBalAccountErr, GenJournalLine.FIELDCAPTION("Bal. Account Type"),
            GenJournalLine.TABLECAPTION(), GenJournalLine."Bal. Account Type"::"Bank Account",
            GenJournalBatch.TABLECAPTION(), GenJournalBatch.Name), 1, 250));
    end;

    [Test]
    procedure ExportPmtJnlLineNonVendorAcc();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        DataExchDef: Record "Data Exch. Def";
    begin
        // 2.11
        Initialize();

        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine.VALIDATE("Creditor No.", FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
        GenJournalLine.MODIFY(TRUE);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJournalLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJournalLine, MustBeVendorOrCustomerErr);
    end;

    [Test]
    procedure ExportVendLedgerEntryMissingRecipientBankAcc();
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
    begin
        // 2.12
        Initialize();

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", CreatePmtVendorLedgerEntryMissingRecipientBankAcc());
        VendorLedgerEntry.FINDLAST();

        // Exercise
        ASSERTERROR PmtExportMgtVendLedgEntry.ExportVendorPaymentFile(VendorLedgerEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(EmptyPaymentDetailsErr,
            VendorLedgerEntry.FIELDCAPTION("Recipient Bank Account"), VendorLedgerEntry.FIELDCAPTION("Creditor No."),
            VendorLedgerEntry.FIELDCAPTION(GiroAccNo)));
    end;

    [Test]
    procedure PostPmtJnlLineMissingBeneficiaryBankAcc();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        VendLedgerEntry: Record "Vendor Ledger Entry";
        VendorNo: Code[20];
    begin
        // 2.3
        Initialize();

        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        VendorNo := GenJournalLine."Account No.";

        // Setup
        GenJournalLine.VALIDATE("Recipient Bank Account", '');
        GenJournalLine.MODIFY(TRUE);

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify
        VendLedgerEntry.SETRANGE("Vendor No.", VendorNo);
        VendLedgerEntry.SETRANGE("Document Type", VendLedgerEntry."Document Type"::Payment);
        VendLedgerEntry.FINDLAST();
        VendLedgerEntry.TESTFIELD("Recipient Bank Account", '');
    end;

    [Test]
    procedure UpdateClosedCustLedgerEntryMsgToRecipient();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DataExchDef: Record "Data Exch. Def";
    begin
        // 2.13
        Initialize();

        // Pre-Setup
        CustLedgerEntry.SETRANGE("Document No.",
          CreatePmtCustLedgerEntryWithRecipientBankAcc(DataExchDef, XMLPORT::"Export Generic CSV"));
        CustLedgerEntry.FINDLAST();

        // Setup
        CustLedgerEntry.Open := FALSE;
        CustLedgerEntry."Message to Recipient" := '';
        CustLedgerEntry.MODIFY();

        // Exercise
        ASSERTERROR CustLedgerEntry.VALIDATE("Message to Recipient");

        // Verify
        Assert.ExpectedError(STRSUBSTNO(LedgerEntryNotOpenErr, TRUE, CustLedgerEntry.TABLECAPTION()));
    end;

    [Test]
    procedure UpdateClosedVendLedgerEntryMsgToRecipient();
    var
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        // 2.13
        Initialize();

        // Pre-Setup
        VendorLedgerEntry.SETRANGE("Document No.",
          CreatePmtVendorLedgerEntryWithRecipientBankAcc(DataExchDef, XMLPORT::"Export Generic CSV"));
        VendorLedgerEntry.FINDLAST();

        // Setup
        VendorLedgerEntry.Open := FALSE;
        VendorLedgerEntry."Message to Recipient" := '';
        VendorLedgerEntry.MODIFY();

        // Exercise
        ASSERTERROR VendorLedgerEntry.VALIDATE("Message to Recipient");

        // Verify
        Assert.ExpectedError(STRSUBSTNO(LedgerEntryNotOpenErr, TRUE, VendorLedgerEntry.TABLECAPTION()));
    end;

    local procedure Initialize();
    begin
        IF IsInitialized THEN
            EXIT;

        IsInitialized := TRUE;
        COMMIT();
    end;

    local procedure CreateBankAccount(var BankAcc: Record "Bank Account");
    begin
        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc."Bank Branch No." := FORMAT(LibraryRandom.RandIntInRange(1111, 9999));
        BankAcc."Bank Account No." := FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999));
        BankAcc.MODIFY();
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAcc: Record "Customer Bank Account"; CustomerNo: Code[20]);
    begin
        LibrarySales.CreateCustomerBankAccount(CustomerBankAcc, CustomerNo);
        CustomerBankAcc."Bank Branch No." := FORMAT(LibraryRandom.RandIntInRange(1111, 9999));
        CustomerBankAcc."Bank Account No." := FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999));
        CustomerBankAcc.MODIFY();
    end;

    local procedure CreateCustomerWithBankAccount(var Customer: Record Customer);
    var
        CustomerBankAcc: Record "Customer Bank Account";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCustomerBankAccount(CustomerBankAcc, Customer."No.");
        Customer.VALIDATE("Preferred Bank Account Code", CustomerBankAcc.Code);
        Customer.MODIFY(TRUE);
    end;

    local procedure CreatePaymentExportBatch(var GenJnlBatch: Record "Gen. Journal Batch");
    var
        BankAcc: Record "Bank Account";
    begin
        CreateBankAccount(BankAcc);
        LibraryPurchase.SelectPmtJnlBatch(GenJnlBatch);
        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", BankAcc."No.");
        GenJnlBatch.VALIDATE("Allow Payment Export", TRUE);
        GenJnlBatch.MODIFY(TRUE);
    end;

    local procedure CreatePaymentExportBatchWithTwoLines(var GenJournalBatch: Record "Gen. Journal Batch"; var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer);
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
    begin
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPortID);
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine2,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine2."Account Type"::Vendor, GenJournalLine."Account No.", LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreatePaymentMethod(var PaymentMethod: Record "Payment Method"; PaymentTypeValidation: Option);
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.MODIFY(TRUE);
    end;

    local procedure CreatePmtCustLedgerEntryMissingRecipientBankAcc() DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPaymentExportDK.CreateNonPaymentExportBatch(GenJournalBatch);
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithoutPreferredBankAcc(GenJournalLine, GenJournalBatch);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePmtCustLedgerEntryWithRecipientBankAcc(var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer) DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
    begin
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPortID);
        SetBankAccCountryToDomestic(GenJournalBatch."Bal. Account No.");
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithPaymentTypeInfo(GenJournalLine,
          GenJournalBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        Customer.GET(GenJournalLine."Account No.");
        SetCustomerCountryToDomestic(Customer);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePmtVendorLedgerEntryMissingRecipientBankAcc() DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPaymentExportDK.CreateNonPaymentExportBatch(GenJournalBatch);
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithoutPreferredBankAcc(GenJournalLine, GenJournalBatch);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePmtVendorLedgerEntryWithRecipientBankAcc(var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer) DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPortID);
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateVendorBankAccount(var VendorBankAcc: Record "Vendor Bank Account"; VendorNo: Code[20]);
    begin
        LibraryPurchase.CreateVendorBankAccount(VendorBankAcc, VendorNo);
        VendorBankAcc."Bank Branch No." := FORMAT(LibraryRandom.RandIntInRange(1111, 9999));
        VendorBankAcc."Bank Account No." := FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999));
        VendorBankAcc.MODIFY();
    end;

    local procedure CreateVendorWithBankAccount(var Vendor: Record Vendor);
    var
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        Vendor.VALIDATE("Preferred Bank Account Code", VendorBankAcc.Code);
        Vendor.VALIDATE("Creditor No.", '');
        Vendor.MODIFY(TRUE);
    end;

    local procedure FindPaymentJournalLines(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    begin
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FINDSET();
    end;

    local procedure SetBalAccountToGLAccount(var GenJournalLine: Record "Gen. Journal Line");
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        SetGenJournalLineBalAccount(GenJournalLine, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.");
    end;

    local procedure SetCustomerCountryToDomestic(var Customer: Record Customer);
    var
        CompanyInfo: Record "Company Information";
        CustBankAcc: Record "Customer Bank Account";
    begin
        CompanyInfo.GET();
        CustBankAcc.GET(Customer."No.", Customer."Preferred Bank Account Code");
        CustBankAcc.VALIDATE("Country/Region Code", CompanyInfo."Country/Region Code");
        CustBankAcc.MODIFY(TRUE);
    end;

    local procedure SetCustomerCountryToInternational(var Customer: Record Customer);
    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
        CustBankAcc: Record "Customer Bank Account";
    begin
        CompanyInfo.GET();
        CountryRegion.SETFILTER(Code, '<>%1', CompanyInfo."Country/Region Code");
        LibraryERM.FindCountryRegion(CountryRegion);
        CustBankAcc.GET(Customer."No.", Customer."Preferred Bank Account Code");
        CustBankAcc.VALIDATE("Country/Region Code", CountryRegion.Code);
        CustBankAcc.MODIFY(TRUE);
    end;

    local procedure SetBankAccCountryToDomestic(BankAccCode: Code[20]);
    var
        CompanyInfo: Record "Company Information";
        BankAccount: Record "Bank Account";
    begin
        CompanyInfo.GET();
        BankAccount.GET(BankAccCode);
        BankAccount.VALIDATE("Country/Region Code", CompanyInfo."Country/Region Code");
        BankAccount.MODIFY(TRUE);
    end;

    local procedure SetGenJournalLineBalAccount(var GenJournalLine: Record "Gen. Journal Line"; BalAccountType: Option; BalAccountNo: Code[20]);
    begin
        GenJournalLine.VALIDATE("Bal. Account Type", BalAccountType);
        GenJournalLine.VALIDATE("Bal. Account No.", BalAccountNo);
        GenJournalLine.MODIFY(TRUE);
    end;

    local procedure SetPmtMethodTypeValidation("Code": Code[10]; PaymentTypeValidation: Integer);
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.GET(Code);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.MODIFY(TRUE);
    end;

    local procedure SetVendorCountryToDomestic(var Vendor: Record Vendor);
    var
        CompanyInfo: Record "Company Information";
        VendBankAcc: Record "Vendor Bank Account";
    begin
        CompanyInfo.GET();
        VendBankAcc.GET(Vendor."No.", Vendor."Preferred Bank Account Code");
        VendBankAcc.VALIDATE("Country/Region Code", CompanyInfo."Country/Region Code");
        VendBankAcc.MODIFY(TRUE);
    end;

    local procedure SetVendorCountryToInternational(var Vendor: Record Vendor);
    var
        CompanyInfo: Record "Company Information";
        CountryRegion: Record "Country/Region";
        VendBankAcc: Record "Vendor Bank Account";
    begin
        CompanyInfo.GET();
        CountryRegion.SETFILTER(Code, '<>%1', CompanyInfo."Country/Region Code");
        LibraryERM.FindCountryRegion(CountryRegion);
        VendBankAcc.GET(Vendor."No.", Vendor."Preferred Bank Account Code");
        VendBankAcc.VALIDATE("Country/Region Code", CountryRegion.Code);
        VendBankAcc.MODIFY(TRUE);
    end;

    local procedure UpdateLastPmtJnlLineBalAccTypeAndNo(GenJournalBatch: Record "Gen. Journal Batch"; BalAccountType: Option; BalAccountNo: Code[20]);
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SETRANGE("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FINDLAST();
        SetGenJournalLineBalAccount(GenJournalLine, BalAccountType, BalAccountNo);
    end;

    [ModalPageHandler]
    procedure VendorBankAccountListPageHandler(var VendorBankAccountList: TestPage "Vendor Bank Account List");
    begin
        VendorBankAccountList.LAST();
        VendorBankAccountList.Cancel().INVOKE();
    end;
}



