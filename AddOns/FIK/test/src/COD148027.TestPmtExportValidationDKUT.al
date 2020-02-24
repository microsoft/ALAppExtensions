// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148027 "TestPmtExport Validation DK UT"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        EmptyPaymentDetailsErr: Label '%1, %2 or %3 must be used for payments.', Comment = '%1=Field;%2=Field;%3=Field', Locked = true;
        FieldMustBeEqualErr: Label '%1 must be equal to ''%2''', Comment = '%1=Field;%2=Value', Locked = true;
        FieldMustNotBeEqualErr: Label '%1 must not be %2', Comment = '%1=Field;%2=Value', Locked = true;
        FieldIsNotEmptyErr: Label '%1 cannot be used while %2 has a value.', Comment = '%1=Field;%2=Field', Locked = true;
        FieldMustHaveValueErr: Label '%1 must have a value';
        SimultaneousPaymentDetailsErr: Label '%1 and %2 cannot be used simultaneously for payments.', Comment = '%1=Field;%2=Field', Locked = true;
        WrongBankInfoLengthErr: Label 'The value in the %1 field does not have the length that is required by the export format.';
        WrongCreditorCurrencyErr: Label '%1 for one or more %2 is incorrect. You can only use %3.', Comment = '%1=Field;%2=Table;%3=Value', Locked = true;
        WrongTransferCurrencyErr: Label '%1 for one or more %2 is incorrect. You can only use %3 or %4.', Comment = '%1=Field;%2=Table;%3=Value;%4=Value', Locked = true;
        PmtTypeValidationErr: Label 'The %1 in %2, %3 must be %4 or %5.', Comment = 'The Payment Type Validation in Payment Method, Code must be Domestic or International.', Locked = true;
        FieldBlankErr: Label '%1 must have a value in %2.', Comment = '%1=table name, %2=field name. Example: Customer must have a value in Name.', Locked = true;
        PaymentTypeShouldBeErr: Label '%1 should be %2 in %3.';
        PaymentTypeShouldNotBeErr: Label '%1 should not be %2 in %3.';
        VendorPmtErr: Label 'The selected export format only supports vendor payments.';
        GiroAccValueErr: Label 'Field GiroAccNo has wrong value.';
        WrongGiroAccLengthErr: Label 'Field GiroAccNo has wrong length in table %1.', Comment = '%1 stands for name of the table, where error occures.', Locked = true;
        TypeNotSupportedErr: Label 'The payment format %1 is not supported.', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK] [Payment Export]
        IsInitialized := FALSE;
    end;

    [Test]
    procedure CustLedgEntryTransferCurrencyIsLCY();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, '');

        // Setup
        GenJnlLine.VALIDATE("Currency Code", '');
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise & Verify
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry), '');
    end;

    [Test]
    procedure CustLedgEntryTransferCurrencyIsEuro();
    var
        Currency: Record Currency;
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, '');

        // Setup
        Currency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise & Verify
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry), '');
    end;

    [Test]
    procedure CustLedgEntryTransferCurrencyIsNotSupported();
    var
        Currency: Record Currency;
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, '');

        // Setup
        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        Currency.SETRANGE("EMU Currency", FALSE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry);

        // Pre-Verify
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(EuroCurrency);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongTransferCurrencyErr,
            CustLedgEntry.FIELDCAPTION("Currency Code"), CustLedgEntry.TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code));
    end;

    [Test]
    procedure CustLedgEntryTransferIsDomesticPmtMethodIsInt();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        SetCustomerBankCountryToDomestic(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetBankAccCountryToDomestic(GenJnlLine."Bal. Account No.");
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldMustNotBeEqualErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure CustLedgEntryTransferIsIntPmtMethodIsDomestic();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        SetCustomerBankCountryToInternational(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldMustBeEqualErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure CustLedgEntryPmtTypeValidationNotSupported();
    var
        CustLedgEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Setup
        CreateCustomerWithBankAccount(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 01", '');
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise & Verify
        Assert.IsFalse(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Cust. Ledger Check", CustLedgEntry), '');
    end;

    [Test]
    procedure CustLedgEntryPmtTypeValidationNotSupportedOnValidate();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", '');

        // Pre-Exercise
        CustLedgEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgEntry.SETRANGE("Document Type", CustLedgEntry."Document Type"::Refund);
        CustLedgEntry.FINDLAST();

        // Exercise.
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        ASSERTERROR CustLedgEntry.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify.
        Assert.ExpectedError(STRSUBSTNO(PmtTypeValidationErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.TABLECAPTION(), PaymentMethod.Code, PaymentMethod.PaymentTypeValidation::Domestic,
            PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure CustLedgEntryBankInfoExceedsRequiredForSender();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
    begin
        Initialize();

        // Setup
        CreateCustomerWithBankAccount(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        BankAccount."Bank Account No." += '1';
        BankAccount."Bank Branch No." += '1';
        BankAccount.MODIFY();
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine."Recipient Bank Account" := Customer."Preferred Bank Account Code";
        GenJnlLine.MODIFY();
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-exercise
        CustLedgerEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Refund);
        CustLedgerEntry.SETRANGE("Recipient Bank Account", Customer."Preferred Bank Account Code");
        CustLedgerEntry.FINDLAST();

        // Exercise
        ASSERTERROR PmtExportMgtCustLedgEntry.ExportCustLedgerEntry(CustLedgerEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongBankInfoLengthErr, PaymentExportData.FIELDCAPTION("Sender Bank Account No.")));
    end;

    [Test]
    procedure GenJnlLineBankInfoExceedsRequiredForCustomer();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        PaymentMethod: Record "Payment Method";
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        CustomerBankAccount.GET(Customer."No.", Customer."Preferred Bank Account Code");
        CustomerBankAccount."Bank Branch No." += CustomerBankAccount."Bank Branch No.";
        CustomerBankAccount."Bank Account No." += CustomerBankAccount."Bank Account No.";
        CustomerBankAccount.MODIFY();

        // Setup
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Customer, Customer."No.", -LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        LibraryERM.PostGeneralJnlLine(GenJnlLine);
        CustLedgerEntry.SETRANGE("Customer No.", Customer."No.");
        CustLedgerEntry.SETRANGE("Document Type", CustLedgerEntry."Document Type"::Payment);
        CustLedgerEntry.FINDLAST();

        // Exercise
        ASSERTERROR PmtExportMgtCustLedgEntry.ExportCustLedgerEntry(CustLedgerEntry);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(WrongBankInfoLengthErr, PaymentExportData.FIELDCAPTION("Recipient Reg. No.")));
    end;

    [Test]
    procedure GenJnlLineBankInfoExceedsRequiredForVendor();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        VendorBankAccount.GET(Vendor."No.", Vendor."Preferred Bank Account Code");
        VendorBankAccount."Bank Account No." += VendorBankAccount."Bank Account No.";
        VendorBankAccount.MODIFY();

        // Setup
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Exercise
        ASSERTERROR PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(GenJnlLine);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(WrongBankInfoLengthErr, PaymentExportData.FIELDCAPTION("Recipient Acc. No.")));
    end;

    [Test]
    procedure GenJnlLineInfoExceedsRequiredForSender();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        BankAccount."Bank Account No." += '1';
        BankAccount."Bank Branch No." += '1';
        BankAccount.MODIFY();
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Exercise
        ASSERTERROR PmtExportMgtGenJnlLine.ExportJournalPaymentFileYN(GenJnlLine);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongBankInfoLengthErr, PaymentExportData.FIELDCAPTION("Sender Bank Account No.")));
    end;

    [Test]
    procedure GenJnlLineCorrectCreditorDataOnly();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);

        // Setup
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        GenJnlLine.VALIDATE("Recipient Bank Account", VendorBankAcc.Code);

        // Verify
        GenJnlLine.TESTFIELD("Recipient Bank Account", '');
        GenJnlLine.TESTFIELD("Creditor No.");
    end;

    [Test]
    procedure GenJnlLineCorrectTransferDataOnly();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);

        // Setup
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 01", '');

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Creditor No.", GetRandomCreditorNo());

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldIsNotEmptyErr, GenJnlLine.FIELDCAPTION("Creditor No."), GenJnlLine.FIELDCAPTION("Recipient Bank Account")));
    end;

    [Test]
    procedure GenJnlLineCreditorCurrencyIsLCY();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        GenJnlLine.VALIDATE("Currency Code", '');
        GenJnlLine.MODIFY(TRUE);

        // Exercise & Verify
        COMMIT();
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine), '');
    end;

    [Test]
    procedure GenJnlLineCreditorCurrencyIsNotSupported();
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(WrongCreditorCurrencyErr,
            GenJnlLine.FIELDCAPTION("Currency Code"), GenJnlLine.TABLECAPTION(), GeneralLedgerSetup."LCY Code"), 1, 250));
    end;

    [Test]
    procedure GenJnlLineCreditorMissingPaymentReference();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(FieldBlankErr, GenJnlLine.TABLECAPTION(), GenJnlLine.FIELDCAPTION("Payment Reference")), 1, 250));
    end;

    [Test]
    procedure GenJnlLineGiroAccMissingPaymentReference();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine."Creditor No." := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(FieldBlankErr, GenJnlLine.TABLECAPTION(), GenJnlLine.FIELDCAPTION("Payment Reference")), 1, 250));
    end;

    [Test]
    procedure GenJnlLineGiroAccMissingPaymentReferenceFilterTest();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine.TESTFIELD(GiroAccNo);
        GenJnlLine."Creditor No." := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();

        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine.TESTFIELD(GiroAccNo);
        GenJnlLine."Payment Reference" := GetRandomPaymentReference(Vendor."Payment Method Code");
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify: No errors.
    end;

    [Test]
    procedure GenJnlLineCreditorMissingPaymentReferenceFilterTest();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.TESTFIELD("Creditor No.");
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();

        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.TESTFIELD("Creditor No.");
        GenJnlLine."Payment Reference" :=
          LibraryUtility.GenerateRandomCode(GenJnlLine.FIELDNO("Payment Reference"), DATABASE::"Gen. Journal Line");
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify: No errors.
    end;

    [Test]
    procedure GenJnlLineErrorCreditorWithTransferData();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        GenJnlLine."Recipient Bank Account" := VendorBankAcc.Code;
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(SimultaneousPaymentDetailsErr,
            GenJnlLine.FIELDCAPTION("Recipient Bank Account"), GenJnlLine.FIELDCAPTION("Creditor No.")), 1, 250));
    end;

    [Test]
    procedure GenJnlLineErrorTransferWithCreditorData();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GenJnlLine."Creditor No." := GetRandomCreditorNo();
        GenJnlLine."Payment Reference" := GetRandomPaymentReference(Vendor."Payment Method Code");
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(SimultaneousPaymentDetailsErr,
            GenJnlLine.FIELDCAPTION("Recipient Bank Account"), GenJnlLine.FIELDCAPTION("Creditor No.")), 1, 250));
    end;

    [Test]
    procedure GenJnlLineErrorGiroAccWithTransferData();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        GenJnlLine."Recipient Bank Account" := VendorBankAcc.Code;
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(SimultaneousPaymentDetailsErr,
            GenJnlLine.FIELDCAPTION("Recipient Bank Account"), GenJnlLine.FIELDCAPTION(GiroAccNo)), 1, 250));
    end;

    [Test]
    procedure GenJnlLineNoPaymentInfo();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        LibraryPurchase.CreateVendor(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GenJnlLine."Recipient Bank Account" := '';
        GenJnlLine."Creditor No." := '';
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(EmptyPaymentDetailsErr, GenJnlLine.FIELDCAPTION("Recipient Bank Account"), GenJnlLine.FIELDCAPTION("Creditor No."),
            GenJnlLine.FIELDCAPTION(GiroAccNo)), 1, 250));
    end;

    [Test]
    procedure GenJnlLineTransferCurrencyIsLCY();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToInternational(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Setup
        GenJnlLine.VALIDATE("Currency Code", '');
        GenJnlLine.MODIFY(TRUE);

        // Exercise & Verify
        COMMIT();
        GenJnlLine.SETRANGE("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine.SETRANGE("Journal Batch Name", GenJnlLine."Journal Batch Name");
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJnlLine), '');
    end;

    [Test]
    procedure GenJnlLineTransferCurrencyIsEuro();
    var
        Currency: Record Currency;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToInternational(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, '');
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Setup
        Currency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);

        // Exercise & Verify
        COMMIT();
        GenJnlLine.SETRANGE("Journal Template Name", GenJnlLine."Journal Template Name");
        GenJnlLine.SETRANGE("Journal Batch Name", GenJnlLine."Journal Batch Name");
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJnlLine), '');
    end;

    [Test]
    procedure GenJnlLineTransferCurrencyIsNotSupported();
    var
        Currency: Record Currency;
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        Currency.SETRANGE("EMU Currency", FALSE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJnlLine);

        // Pre-Verify
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(EuroCurrency);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(WrongTransferCurrencyErr,
            GenJnlLine.FIELDCAPTION("Currency Code"), GenJnlLine.TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code), 1, 250));
    end;

    [Test]
    procedure GenJnlLineCustRefund();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        SetCustomerBankCountryToDomestic(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(PaymentTypeShouldNotBeErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International, PaymentMethod.TABLECAPTION()), 1, 250));
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine, VendorPmtErr);
    end;

    [Test]
    procedure GenJnlLineTransferIsDomesticPmtMethodIsInt();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToDomestic(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(PaymentTypeShouldNotBeErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International, PaymentMethod.TABLECAPTION()), 1, 250));
    end;

    [Test]
    procedure GenJnlLineTransferIsDomesticPmtMethodIsDomestic();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToDomestic(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        Assert.IsFalse(GenJnlLine.HasPaymentFileErrors(), '');
    end;

    [Test]
    procedure GenJnlLineTransferIsIntPmtMethodIsDomestic();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToInternational(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        LibraryPaymentExport.VerifyGenJnlLineErr(GenJnlLine,
          CopyStr(STRSUBSTNO(PaymentTypeShouldBeErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International, PaymentMethod.TABLECAPTION()), 1, 250));
    end;

    [Test]
    procedure GenJnlLineTransferIsIntPmtMethodIsInternational();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        PaymentTypeValidation: Text;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToInternational(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine."Bank Payment Type" := GenJnlLine."Bank Payment Type"::"Electronic Payment";
        GenJnlLine.MODIFY();

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentTypeValidation := FORMAT(PaymentMethod.PaymentTypeValidation);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Payment Export Gen. Jnl Check", GenJnlLine);

        // Verify
        Assert.IsFalse(GenJnlLine.HasPaymentFileErrors(), '');
    end;

    [Test]
    procedure GenJnlLinePmtTypeValidationNotSupportedOnValidate();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Customer: Record Customer;
    begin
        Initialize();

        // Pre-Setup
        CreateCustomerWithBankAccount(Customer);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Refund,
          GenJnlLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 01", '');
        PaymentMethod.GET(GenJnlLine."Payment Method Code");

        // Exercise
        ASSERTERROR GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(PmtTypeValidationErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.TABLECAPTION(),
            PaymentMethod.Code, PaymentMethod.PaymentTypeValidation::Domestic, PaymentMethod.PaymentTypeValidation::International));
    end;

    local procedure GenJnlLineAccNoPopulatePaymentAccFields(PaymentTypeValidation: Option);
    var
        PaymentMethod: Record "Payment Method";
        VendorBankAcc: Record "Vendor Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Setup
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.MODIFY(TRUE);

        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        Vendor.VALIDATE("Preferred Bank Account Code", VendorBankAcc.Code);
        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE("Creditor No.", GetRandomCreditorNo());
        Vendor.VALIDATE(GiroAccNo, GetRandomGiroAccNo());
        Vendor.MODIFY(TRUE);
        SetVendorBankCountryToDomestic(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        GenJnlLine.INIT();
        GenJnlLine.VALIDATE("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Vendor);

        // Exercise
        GenJnlLine.VALIDATE("Account No.", Vendor."No.");

        // Verify
        VerifyPaymentDetails(GenJnlLine, PaymentTypeValidation,
          Vendor."Preferred Bank Account Code", Vendor."Creditor No.", Vendor.GiroAccNo);
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsFIK01();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 01");
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsFIK04();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 04");
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsFIK71();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 71");
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsFIK73();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 73");
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsDomestic();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::Domestic);
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePaymentDetailsBlank();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLineAccNoPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::" ");
    end;

    [Test]
    procedure GenJnlLineAccNoPopulatePmtDetailsNoPmtMethod();
    var
        PaymentMethod: Record "Payment Method";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Setup
        CreateVendorWithBankAccount(Vendor);
        Vendor.VALIDATE("Creditor No.", GetRandomCreditorNo());
        Vendor.VALIDATE(GiroAccNo, GetRandomGiroAccNo());
        Vendor.VALIDATE("Payment Method Code", '');
        Vendor.MODIFY(TRUE);
        SetVendorBankCountryToDomestic(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        GenJnlLine.INIT();
        GenJnlLine.VALIDATE("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine.VALIDATE("Account Type", GenJnlLine."Account Type"::Vendor);

        // Exercise
        GenJnlLine.VALIDATE("Account No.", Vendor."No.");

        // Verify
        VerifyPaymentDetails(GenJnlLine, PaymentMethod.PaymentTypeValidation::" ",
          Vendor."Preferred Bank Account Code", Vendor."Creditor No.", Vendor.GiroAccNo);
    end;

    local procedure GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentTypeValidation: Option);
    var
        PaymentMethod: Record "Payment Method";
        VendorBankAcc: Record "Vendor Bank Account";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        CreditorNo: Code[8];
        GiroNo: Code[8];
    begin
        Initialize();

        // Pre-setup
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.MODIFY(TRUE);

        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        Vendor."Preferred Bank Account Code" := VendorBankAcc.Code;
        Vendor.MODIFY();
        SetVendorBankCountryToDomestic(Vendor);
        CreditorNo := GetRandomCreditorNo();
        GiroNo := GetRandomGiroAccNo();
        CreateBankAccount(BankAccount);
        SetBankAccCountryToDomestic(BankAccount."No.");

        // Setup
        GenJnlLine.INIT();
        GenJnlLine."Account Type" := GenJnlLine."Account Type"::Vendor;
        GenJnlLine."Account No." := Vendor."No.";
        IF PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::Domestic THEN
            GenJnlLine."Recipient Bank Account" := VendorBankAcc.Code;
        GenJnlLine."Creditor No." := CreditorNo;
        GenJnlLine.GiroAccNo := GiroNo;
        GenJnlLine."Bal. Account Type" := GenJnlLine."Bal. Account Type"::"Bank Account";
        GenJnlLine."Bal. Account No." := BankAccount."No.";

        // Exercise
        GenJnlLine.VALIDATE("Payment Method Code", PaymentMethod.Code);

        // Verify
        VerifyPaymentDetails(GenJnlLine, PaymentTypeValidation,
          VendorBankAcc.Code, CreditorNo, GiroNo);
    end;

    [Test]
    procedure GenJnlLinePmtMethodPopulatePaymentDetailsFIK01();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 01");
    end;

    [Test]
    procedure GenJnlLinePmtMethodPopulatePaymentDetailsFIK04();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 04");
    end;

    [Test]
    procedure GenJnlLinePmtMethodPopulatePaymentDetailsFIK71();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 71");
    end;

    [Test]
    procedure GenJnlLinePmtMethodPopulatePaymentDetailsFIK73();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 73");
    end;

    [Test]
    procedure GenJnlLinePmtMethodPopulatePaymentDetailsDomestic();
    var
        PaymentMethod: Record "Payment Method";
    begin
        GenJnlLinePmtMethodPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::Domestic);
    end;

    local procedure SuggestPaymentsPopulatePaymentAccFields(PaymentTypeValidation: Option);
    var
        PaymentMethod: Record "Payment Method";
        VendorBankAcc: Record "Vendor Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Setup
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.MODIFY(TRUE);

        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        Vendor.VALIDATE("Preferred Bank Account Code", VendorBankAcc.Code);
        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE("Creditor No.", GetRandomCreditorNo());
        Vendor.VALIDATE(GiroAccNo, GetRandomGiroAccNo());
        Vendor.MODIFY(TRUE);
        SetVendorBankCountryToDomestic(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        SetBankAccCountryToDomestic(GenJnlBatch."Bal. Account No.");
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Invoice,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", -LibraryRandom.RandDec(1000, 2));

        if PaymentTypeValidation = PaymentMethod.PaymentTypeValidation::International then
            GenJnlLine."Recipient Bank Account" := Vendor."Preferred Bank Account Code";
        GenJnlLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Exercise
        CreatePaymentExportBatch(GenJnlBatch);
        SuggestVendorPayments(GenJnlBatch, Vendor."No.", GenJnlLine."Due Date");

        // Pre-Verify
        GenJnlLine.SETRANGE("Journal Template Name", GenJnlBatch."Journal Template Name");
        GenJnlLine.SETRANGE("Journal Batch Name", GenJnlBatch.Name);
        GenJnlLine.SETRANGE("Document Type", GenJnlLine."Document Type"::Payment);
        GenJnlLine.SETRANGE("Account Type", GenJnlLine."Account Type"::Vendor);
        GenJnlLine.SETRANGE("Account No.", Vendor."No.");
        GenJnlLine.FINDFIRST();

        // Verify.
        VerifyPaymentDetails(GenJnlLine, PaymentTypeValidation,
          Vendor."Preferred Bank Account Code", Vendor."Creditor No.", Vendor.GiroAccNo);
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsFIK01();
    var
        PaymentMethod: Record "Payment Method";
    begin
        SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 01");
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsFIK04();
    var
        PaymentMethod: Record "Payment Method";
    begin
        SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 04");
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsFIK71();
    var
        PaymentMethod: Record "Payment Method";
    begin
        SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 71");
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsFIK73();
    var
        PaymentMethod: Record "Payment Method";
    begin
        SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::"FIK 73");
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsDomestic();
    var
        PaymentMethod: Record "Payment Method";
    begin
        SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::Domestic);
    end;

    [Test]
    procedure SuggestPaymentsPopulatePaymentDetailsInternational();
    var
        PaymentMethod: Record "Payment Method";
    begin
        asserterror SuggestPaymentsPopulatePaymentAccFields(PaymentMethod.PaymentTypeValidation::International);
        Assert.ExpectedError(STRSUBSTNO(FieldMustNotBeEqualErr, PaymentMethod.FIELDCAPTION(PaymentTypeValidation),
            PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure SuggestVendorPaymentWithGiroAccNo();
    var
        PurchaseHeader: Record "Purchase Header";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [FEATURE] [Suggest Vendor Payments] [Purchase]
        // [SCENARIO 363448] GiroAccNo is transferring to journal line after Suggesting Vendor Payments.
        Initialize();

        // [GIVEN] Posted Purchase Invoice with "Giro Acc No." = "X"
        CreateAndPostPurchaseInvoice(PurchaseHeader);

        // [WHEN] Suggest Vendor Payments
        CreateGeneralJournalBatch(GenJournalBatch);
        SuggestVendorPayments(GenJournalBatch, PurchaseHeader."Buy-from Vendor No.", WORKDATE());

        // [THEN] Suggested Journal Line has GiroAccNo = "X"
        VerifyJournalLinesGiroAccNo(
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, PurchaseHeader.GiroAccNo);
    end;

    [Test]
    procedure VendLedgEntryCorrectCreditorDataOnly();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        ASSERTERROR VendLedgEntry.VALIDATE("Recipient Bank Account", VendorBankAcc.Code);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldIsNotEmptyErr, VendLedgEntry.FIELDCAPTION("Recipient Bank Account"), VendLedgEntry.FIELDCAPTION("Creditor No.")));
    end;

    [Test]
    procedure VendLedgEntryCreditorCurrencyIsLCY();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        GenJnlLine.VALIDATE("Currency Code", '');
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry), '');
    end;

    [Test]
    procedure VendLedgEntryCreditorCurrencyIsNotSupported();
    var
        Currency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongCreditorCurrencyErr,
            VendLedgEntry.FIELDCAPTION("Currency Code"), VendLedgEntry.TABLECAPTION(), GeneralLedgerSetup."LCY Code"));
    end;

    [Test]
    procedure VendLedgEntryCreditorMissingPaymentReference();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldMustHaveValueErr, VendLedgEntry.FIELDCAPTION("Payment Reference")));
    end;

    [Test]
    procedure VendLedgEntryCreditorMissingPaymentReferenceFilterTest();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.TESTFIELD("Creditor No.");
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 71", 'FIK71');
        GenJnlLine.TESTFIELD("Creditor No.");
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := GetRandomPaymentReference(Vendor."Payment Method Code");
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.SETRANGE("Document No.", GenJnlLine."Document No.");
        VendLedgEntry.FINDFIRST();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify: No errors.
    end;

    [Test]
    procedure VendLedgEntryGiroAccMissingPaymentReference();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine."Creditor No." := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(STRSUBSTNO(FieldMustHaveValueErr, GenJnlLine.FIELDCAPTION("Payment Reference")));
    end;

    [Test]
    procedure VendLedgEntryGiroAccMissingPaymentReferenceFilterTest();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        PaymentMethod: Record "Payment Method";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine.TESTFIELD(GiroAccNo);
        GenJnlLine."Creditor No." := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::"FIK 04", 'FIK04');
        GenJnlLine.TESTFIELD(GiroAccNo);
        GenJnlLine."Creditor No." := '';
        GenJnlLine."Payment Reference" := GetRandomPaymentReference(Vendor."Payment Method Code");
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.SETRANGE("Document No.", GenJnlLine."Document No.");
        VendLedgEntry.FINDFIRST();

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify: No errors.
    end;

    [Test]
    procedure VendLedgEntryErrorCreditorWithTransferData();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithCreditorInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        GenJnlLine."Recipient Bank Account" := VendorBankAcc.Code;
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(SimultaneousPaymentDetailsErr,
            VendLedgEntry.FIELDCAPTION("Recipient Bank Account"), VendLedgEntry.FIELDCAPTION("Creditor No.")));
    end;

    [Test]
    procedure VendLedgEntryErrorTransferWithCreditorData();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentMethod.PaymentTypeValidation := PaymentMethod.PaymentTypeValidation::"FIK 71";
        PaymentMethod.MODIFY();
        GenJnlLine."Creditor No." := GetRandomCreditorNo();
        GenJnlLine."Payment Reference" := GetRandomPaymentReference(GenJnlLine."Payment Method Code");
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(SimultaneousPaymentDetailsErr,
            VendLedgEntry.FIELDCAPTION("Recipient Bank Account"), VendLedgEntry.FIELDCAPTION("Creditor No.")));

        // // Clean up
        PaymentMethod.PaymentTypeValidation := PaymentMethod.PaymentTypeValidation::" ";
        PaymentMethod.MODIFY();

    end;

    [Test]
    procedure VendLedgEntryErrorGiroAccWithTransferData();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
        VendorBankAcc: Record "Vendor Bank Account";
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithGiroAccInfo(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJnlLine.VALIDATE("Payment Reference", GetRandomPaymentReference(Vendor."Payment Method Code"));
        GenJnlLine.MODIFY(TRUE);

        // Setup
        CreateVendorBankAccount(VendorBankAcc, Vendor."No.");
        GenJnlLine."Recipient Bank Account" := VendorBankAcc.Code;
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(SimultaneousPaymentDetailsErr,
            VendLedgEntry.FIELDCAPTION("Recipient Bank Account"), VendLedgEntry.FIELDCAPTION(GiroAccNo)));
    end;

    [Test]
    procedure VendLedgEntryNoPaymentInfo();
    var
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        LibraryPurchase.CreateVendor(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GenJnlLine."Recipient Bank Account" := '';
        GenJnlLine."Creditor No." := '';
        GenJnlLine.GiroAccNo := '';
        GenJnlLine."Payment Reference" := '';
        GenJnlLine.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDFIRST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(EmptyPaymentDetailsErr, GenJnlLine.FIELDCAPTION("Recipient Bank Account"), GenJnlLine.FIELDCAPTION("Creditor No."),
            GenJnlLine.FIELDCAPTION(GiroAccNo)));
    end;

    [Test]
    procedure VendLedgEntryTransferCurrencyIsLCY();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GenJnlLine.VALIDATE("Currency Code", '');
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise & Verify
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry), '');
    end;

    [Test]
    procedure VendLedgEntryTransferCurrencyIsEuro();
    var
        Currency: Record Currency;
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        Currency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise & Verify
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry), '');
    end;

    [Test]
    procedure VendLedgEntryTransferCurrencyIsNotSupported();
    var
        Currency: Record Currency;
        EuroCurrency: Record Currency;
        GeneralLedgerSetup: Record "General Ledger Setup";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        VendLedgEntry: Record "Vendor Ledger Entry";
        Vendor: Record Vendor;
    begin
        Initialize();

        // Pre-Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", '');

        // Setup
        GeneralLedgerSetup.GET();
        Currency.SETFILTER(Code, '<>%1', GeneralLedgerSetup."LCY Code");
        Currency.SETRANGE("EMU Currency", FALSE);
        LibraryERM.FindCurrency(Currency);
        GenJnlLine.VALIDATE("Currency Code", Currency.Code);
        GenJnlLine.MODIFY(TRUE);
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);
        // Pre-Verify
        EuroCurrency.SETRANGE("EMU Currency", TRUE);
        LibraryERM.FindCurrency(EuroCurrency);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongTransferCurrencyErr,
            VendLedgEntry.FIELDCAPTION("Currency Code"), VendLedgEntry.TABLECAPTION(), GeneralLedgerSetup."LCY Code", EuroCurrency.Code));
    end;

    [Test]
    procedure VendLedgEntryTransferIsDomesticPmtMethodIsInt();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetVendorBankCountryToDomestic(Vendor);
        SetBankAccCountryToDomestic(GenJnlLine."Bal. Account No.");
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentMethod.PaymentTypeValidation := PaymentMethod.PaymentTypeValidation::International;
        PaymentMethod.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldMustNotBeEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure VendLedgEntryTransferIsIntPmtMethodIsDomestic();
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
        CreatePaymentExportBatch(GenJnlBatch);
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));

        // Setup
        SetVendorBankCountryToInternational(Vendor);
        PaymentMethod.GET(GenJnlLine."Payment Method Code");
        PaymentMethod.PaymentTypeValidation := PaymentMethod.PaymentTypeValidation::Domestic;
        PaymentMethod.MODIFY();
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-Exercise
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR CODEUNIT.RUN(CODEUNIT::"Pmt. Export Vend. Ledger Check", VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(FieldMustBeEqualErr,
            PaymentMethod.FIELDCAPTION(PaymentTypeValidation), PaymentMethod.PaymentTypeValidation::International));
    end;

    [Test]
    procedure VendLedgEntryBankInfoExceedsRequiredForSender();
    var
        VendLedgEntry: Record "Vendor Ledger Entry";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        Vendor: Record Vendor;
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
    begin
        Initialize();

        // Setup
        CreateVendorWithBankAccount(Vendor);
        CreatePaymentExportBatch(GenJnlBatch);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        BankAccount."Bank Account No." += '1';
        BankAccount."Bank Branch No." += '1';
        BankAccount.MODIFY();
        LibraryERM.CreateGeneralJnlLine(GenJnlLine,
          GenJnlBatch."Journal Template Name", GenJnlBatch.Name, GenJnlLine."Document Type"::Payment,
          GenJnlLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetPmtMethodTypeValidation(GenJnlLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        LibraryERM.PostGeneralJnlLine(GenJnlLine);

        // Pre-exercise.
        VendLedgEntry.SETRANGE("Vendor No.", Vendor."No.");
        VendLedgEntry.SETRANGE("Document Type", VendLedgEntry."Document Type"::Payment);
        VendLedgEntry.FINDLAST();

        // Exercise
        ASSERTERROR PmtExportMgtVendLedgEntry.ExportVendLedgerEntry(VendLedgEntry);

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(WrongBankInfoLengthErr, PaymentExportData.FIELDCAPTION("Sender Bank Account No.")));
    end;

    [Test]
    procedure GiroAccNoLength();
    var
        GenJournalLine: Record "Gen. Journal Line";
        PaymentBuffer: Record "Payment Buffer";
        PaymentExportData: Record "Payment Export Data";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
        Vendor: Record Vendor;
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GiroAccNoLength: Integer;
    begin
        // [FEATURE] [Giro Account] [UT]
        // [SCENARIO 375475] GiroAccNo field is 8 chars length in all tables.

        GiroAccNoLength := 8;

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::Vendor, Vendor.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, Vendor.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Vendor Ledger Entry", VendorLedgerEntry.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, VendorLedgerEntry.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Purchase Header", PurchaseHeader.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, PurchaseHeader.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Line", GenJournalLine.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, GenJournalLine.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Purch. Inv. Header", PurchInvHeader.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, PurchInvHeader.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Payment Buffer", PaymentBuffer.FIELDNO(GiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, PaymentBuffer.TABLECAPTION()));

        Assert.AreEqual(
          GiroAccNoLength,
          LibraryUtility.GetFieldLength(DATABASE::"Payment Export Data", PaymentExportData.FIELDNO(RecipientGiroAccNo)),
          STRSUBSTNO(WrongGiroAccLengthErr, PaymentExportData.TABLECAPTION()));
    end;

    [Test]
    procedure ExportPaymentFilePerformance();
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        PmtExportValidationDKUT: Codeunit "TestPmtExport Validation DK UT";
        GenJnlTemplateName: Code[10];
        GenJnlBatchName: Code[10];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 379332] Codeunit 1211 must call batch validation once per batch
        Initialize();

        // [GIVEN] Payment Journal with 3 lines
        CreateGenJnlBatchWithLines(GenJnlTemplateName, GenJnlBatchName);
        COMMIT();
        BINDSUBSCRIPTION(PmtExportValidationDKUT);
        PmtExportValidationDKUT.InitializeEventHitsCounter();

        // [WHEN] Call codeunit "Exp. Flat File Validation"
        GenJournalLine.SETRANGE("Journal Template Name", GenJnlTemplateName);
        GenJournalLine.SETRANGE("Journal Batch Name", GenJnlBatchName);
        GenJournalLine2.COPYFILTERS(GenJournalLine);
        IF GenJournalLine2.FINDSET() THEN
            REPEAT
                IF GenJournalLine2."Account Type" = GenJournalLine2."Account Type"::"Bank Account" THEN
                    GenJournalLine2."Bank Payment Type" := GenJournalLine2."Bank Payment Type"::"Electronic Payment";
                IF GenJournalLine2."Bal. Account Type" = GenJournalLine2."Bal. Account Type"::"Bank Account" THEN
                    GenJournalLine2."Bank Payment Type" := GenJournalLine2."Bank Payment Type"::"Electronic Payment";
                GenJournalLine2.MODIFY();
            UNTIL GenJournalLine2.NEXT() = 0;
        COMMIT();
        Assert.IsTrue(CODEUNIT.RUN(CODEUNIT::"Exp. Flat File Validation", GenJournalLine), GETLASTERRORTEXT());

        // [THEN] The only single batch validation event fired
        PmtExportValidationDKUT.VerifyEventHitsCounter(1);
    end;

    [Test]
    procedure ApplyFIKCustomerPaymentToInvoice();
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        InvoiceNo: Code[20];
        PaymentNo: Code[20];
    begin
        // [FEATURE] [Apply]
        // [SCENARIO 201739] Customer Payment with Bank Bal. Account should be applied to Invoice regardless of Payment Validation Type
        Initialize();

        // [GIVEN] Posted Customer Invoice and Payment with Bank Account as Balance Account with "Payment Validation Type" = FIK71
        PostCustomerInvoiceAndPaymentWithBalanceBankAcc(InvoiceNo, PaymentNo, CreateCustomerWithFIKPaymentMethod());

        // [WHEN] Apply Payment to Invoice
        LibraryERM.ApplyCustomerLedgerEntries(
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Document Type"::Payment, InvoiceNo, PaymentNo);

        // [THEN] Payment is successfully applied
        LibraryERM.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Payment, PaymentNo);
        CustLedgerEntry.TESTFIELD(Open, FALSE);
    end;

    [Test]
    procedure ApplyFIKCustomerInvoiceToPayment();
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        InvoiceNo: Code[20];
        PaymentNo: Code[20];
    begin
        // [FEATURE] [Apply]
        // [SCENARIO 201739] Customer Invoice should be applied to Payment with Bank Bal. Account regardless of Payment Validation Type
        Initialize();

        // [GIVEN] Posted Customer Invoice and Payment with Bank Account as Balance Account with "Payment Validation Type" = FIK71
        PostCustomerInvoiceAndPaymentWithBalanceBankAcc(InvoiceNo, PaymentNo, CreateCustomerWithFIKPaymentMethod());

        // [WHEN] Apply Invoice to Payment
        LibraryERM.ApplyCustomerLedgerEntries(
          GenJournalLine."Document Type"::Payment, GenJournalLine."Document Type"::Invoice, PaymentNo, InvoiceNo);

        // [THEN] Payment is successfully applied
        LibraryERM.FindCustomerLedgerEntry(CustLedgerEntry, CustLedgerEntry."Document Type"::Payment, PaymentNo);
        CustLedgerEntry.TESTFIELD(Open, FALSE);
    end;

    local procedure Initialize();
    begin
        IF IsInitialized THEN
            EXIT;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        IsInitialized := TRUE;
    end;

    procedure InitializeEventHitsCounter();
    begin
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(0);
    end;

    local procedure CreateBankAccount(var BankAcc: Record "Bank Account");
    begin
        LibraryERM.CreateBankAccount(BankAcc);
        BankAcc."Bank Branch No." := FORMAT(LibraryRandom.RandIntInRange(1111, 9999));
        BankAcc.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
        BankAcc."Payment Export Format" := CreateExportImportSetup();
        BankAcc.MODIFY();
    end;

    local procedure CreatePaymentExportBatch(var GenJnlBatch: Record "Gen. Journal Batch");
    var
        BankAcc: Record "Bank Account";
    begin
        CreateBankAccount(BankAcc);
        LibraryERM.CreateGenJournalBatch(GenJnlBatch, LibraryPaymentExport.SelectPaymentJournalTemplate());
        GenJnlBatch.VALIDATE("Bal. Account Type", GenJnlBatch."Bal. Account Type"::"Bank Account");
        GenJnlBatch.VALIDATE("Bal. Account No.", BankAcc."No.");
        GenJnlBatch.VALIDATE("Allow Payment Export", TRUE);
        GenJnlBatch.MODIFY(TRUE);
    end;

    local procedure CreateGeneralJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch");
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAcc: Record "Customer Bank Account"; CustomerNo: Code[20]);
    begin
        LibrarySales.CreateCustomerBankAccount(CustomerBankAcc, CustomerNo);
        CustomerBankAcc.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        CustomerBankAcc.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
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

    local procedure CreateCustomerWithFIKPaymentMethod(): Code[20];
    var
        Customer: Record Customer;
        PaymentMethod: Record "Payment Method";
    begin
        LibrarySales.CreateCustomer(Customer);
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::"FIK 71");
        PaymentMethod.MODIFY(TRUE);
        Customer.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Customer.MODIFY(TRUE);
        EXIT(Customer."No.");
    end;

    local procedure CreateVendorBankAccount(var VendorBankAcc: Record "Vendor Bank Account"; VendorNo: Code[20]);
    begin
        LibraryPurchase.CreateVendorBankAccount(VendorBankAcc, VendorNo);
        VendorBankAcc.VALIDATE("Bank Branch No.", FORMAT(LibraryRandom.RandIntInRange(1111, 9999)));
        VendorBankAcc.VALIDATE("Bank Account No.", FORMAT(LibraryRandom.RandIntInRange(111111111, 999999999)));
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

    local procedure CreateVendorWithCreditorInfo(var Vendor: Record Vendor);
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::"FIK 71");
        PaymentMethod.MODIFY(TRUE);

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.VALIDATE("Preferred Bank Account Code", '');
        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE("Creditor No.", GetRandomCreditorNo());
        Vendor.MODIFY(TRUE);
    end;

    local procedure CreateVendorWithGiroAccInfo(var Vendor: Record Vendor);
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentMethod.PaymentTypeValidation::"FIK 04");
        PaymentMethod.MODIFY(TRUE);

        LibraryPurchase.CreateVendor(Vendor);
        Vendor.VALIDATE("Preferred Bank Account Code", '');
        Vendor.VALIDATE("Payment Method Code", PaymentMethod.Code);
        Vendor.VALIDATE(GiroAccNo, GetRandomGiroAccNo());
        Vendor.MODIFY(TRUE);
    end;

    local procedure CreateExportImportSetup(): Code[20];
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        BankExportImportSetup.Code :=
          LibraryUtility.GenerateRandomCode(BankExportImportSetup.FIELDNO(Code), DATABASE::"Bank Export/Import Setup");
        BankExportImportSetup."Data Exch. Def. Code" := 'BANKDATA';
        BankExportImportSetup.INSERT();
        EXIT(BankExportImportSetup.Code);
    end;

    local procedure CreateAndPostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header");
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
    begin
        CreateVendorWithGiroAccInfo(Vendor);
        LibraryPurchase.CreatePurchHeader(
          PurchaseHeader, PurchaseHeader."Document Type"::Invoice, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(
          PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item,
          LibraryInventory.CreateItemNo(), LibraryRandom.RandDec(10, 2));
        PurchaseLine.VALIDATE("Direct Unit Cost", LibraryRandom.RandIntInRange(100, 1000));
        PurchaseLine.MODIFY(TRUE);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, TRUE, TRUE);
    end;

    local procedure CreateGenJnlBatchWithLines(var GenJnlTemplateName: Code[10]; var GenJnlBatchName: Code[10]);
    var
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
        RecCount: Integer;
        Index: Integer;
    begin
        CreateVendorWithBankAccount(Vendor);
        SetVendorBankCountryToInternational(Vendor);
        CreatePaymentExportBatch(GenJournalBatch);
        SetBankAccCountryToDomestic(GenJournalBatch."Bal. Account No.");
        RecCount := LibraryRandom.RandIntInRange(2, 5);
        FOR Index := 1 TO RecCount DO BEGIN
            LibraryERM.CreateGeneralJnlLine(GenJournalLine,
              GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
              GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
            SetPmtMethodTypeValidation(GenJournalLine."Payment Method Code", PaymentMethod.PaymentTypeValidation::International, 'BTI');
        END;
        GenJnlBatchName := GenJournalBatch.Name;
        GenJnlTemplateName := GenJournalBatch."Journal Template Name";
        GenJournalLine.VALIDATE("Currency Code", '');
        GenJournalLine.MODIFY(TRUE);
    end;

    local procedure PostCustomerInvoiceAndPaymentWithBalanceBankAcc(var InvoiceNo: Code[20]; var PaymentNo: Code[20]; CustomerNo: Code[20]);
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::Customer, CustomerNo, LibraryRandom.RandDec(100, 2));
        InvoiceNo := GenJournalLine."Document No.";
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name",
          GenJournalLine."Document Type"::Payment, GenJournalLine."Account Type"::Customer, CustomerNo,
          GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), -GenJournalLine.Amount);
        PaymentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure SetCustomerBankCountryToDomestic(var Customer: Record Customer);
    var
        CompanyInfo: Record "Company Information";
        CustBankAcc: Record "Customer Bank Account";
    begin
        CompanyInfo.GET();
        CustBankAcc.GET(Customer."No.", Customer."Preferred Bank Account Code");
        CustBankAcc.VALIDATE("Country/Region Code", CompanyInfo."Country/Region Code");
        CustBankAcc.MODIFY(TRUE);
    end;

    local procedure SetCustomerBankCountryToInternational(var Customer: Record Customer);
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

    local procedure SetPmtMethodTypeValidation("Code": Code[10]; PaymentTypeValidation: Integer; PaymentType: Text);
    var
        PaymentMethod: Record "Payment Method";
    begin
        PaymentMethod.GET(Code);
        PaymentMethod.VALIDATE(PaymentTypeValidation, PaymentTypeValidation);
        PaymentMethod.VALIDATE("Pmt. Export Line Definition", PaymentType);
        PaymentMethod.MODIFY(TRUE);
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

    local procedure SetVendorBankCountryToDomestic(var Vendor: Record Vendor);
    var
        CompanyInfo: Record "Company Information";
        VendBankAcc: Record "Vendor Bank Account";
    begin
        CompanyInfo.GET();
        VendBankAcc.GET(Vendor."No.", Vendor."Preferred Bank Account Code");
        VendBankAcc.VALIDATE("Country/Region Code", CompanyInfo."Country/Region Code");
        VendBankAcc.MODIFY(TRUE);
    end;

    local procedure SetVendorBankCountryToInternational(var Vendor: Record Vendor);
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

    local procedure SuggestVendorPayments(GenJournalBatch: Record "Gen. Journal Batch"; VendorNo: Code[20]; LastPaymentDate: Date);
    var
        Vendor: Record Vendor;
        GenJournalLine: Record "Gen. Journal Line";
        SuggestVendorPayments: Report "Suggest Vendor Payments";
    begin
        GenJournalLine.INIT();
        GenJournalLine.VALIDATE("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.VALIDATE("Journal Batch Name", GenJournalBatch.Name);
        SuggestVendorPayments.SetGenJnlLine(GenJournalLine);

        Vendor.SETRANGE("No.", VendorNo);
        SuggestVendorPayments.SETTABLEVIEW(Vendor);
        SuggestVendorPayments.InitializeRequest(
          LastPaymentDate, TRUE, 0, FALSE, LastPaymentDate, FORMAT(LibraryRandom.RandInt(100)), TRUE,
          GenJournalLine."Bal. Account Type"::"Bank Account", '', GenJournalLine."Bank Payment Type"::" ");
        SuggestVendorPayments.USEREQUESTPAGE(FALSE);
        SuggestVendorPayments.RUNMODAL();
    end;

    [EventSubscriber(ObjectType::Table, DATABASE::"Gen. Journal Batch", 'OnCheckGenJournalLineExportRestrictions', '', false, false)]
    local procedure CountEventHitsOnCheckGenJournalLineExportRestrictions(var Sender: Record "Gen. Journal Batch");
    begin
        LibraryVariableStorage.Enqueue(LibraryVariableStorage.DequeueInteger() + 1);
    end;

    procedure VerifyEventHitsCounter(ExpectedCount: Integer);
    begin
        Assert.AreEqual(ExpectedCount, LibraryVariableStorage.DequeueInteger(), 'Incorrect no. of batch validation')
    end;

    local procedure VerifyPaymentDetails(GenJnlLine: Record "Gen. Journal Line"; PaymentTypeValidation: Option; ExpBankAccNo: Code[20]; ExpCreditorNo: Code[20]; ExpGiroAccNo: Code[8]);
    var
        PaymentMethod: Record "Payment Method";
    begin
        CASE PaymentTypeValidation OF
            PaymentMethod.PaymentTypeValidation::"FIK 01", PaymentMethod.PaymentTypeValidation::"FIK 04":
                BEGIN
                    GenJnlLine.TESTFIELD("Recipient Bank Account", '');
                    GenJnlLine.TESTFIELD("Creditor No.", '');
                    GenJnlLine.TESTFIELD(GiroAccNo, ExpGiroAccNo);
                END;
            PaymentMethod.PaymentTypeValidation::"FIK 71", PaymentMethod.PaymentTypeValidation::"FIK 73":
                BEGIN
                    GenJnlLine.TESTFIELD("Recipient Bank Account", '');
                    GenJnlLine.TESTFIELD("Creditor No.", ExpCreditorNo);
                    GenJnlLine.TESTFIELD(GiroAccNo, '');
                END;
            PaymentMethod.PaymentTypeValidation::Domestic, PaymentMethod.PaymentTypeValidation::International:
                BEGIN
                    GenJnlLine.TESTFIELD("Recipient Bank Account", ExpBankAccNo);
                    GenJnlLine.TESTFIELD("Creditor No.", '');
                    GenJnlLine.TESTFIELD(GiroAccNo, '');
                END;
            PaymentMethod.PaymentTypeValidation::" ":
                BEGIN
                    GenJnlLine.TESTFIELD("Recipient Bank Account", ExpBankAccNo);
                    GenJnlLine.TESTFIELD("Creditor No.", ExpCreditorNo);
                    GenJnlLine.TESTFIELD(GiroAccNo, ExpGiroAccNo);
                END;
        END;
    end;

    local procedure VerifyJournalLinesGiroAccNo(JournalTemplateName: Code[10]; JournalBatchName: Code[10]; GiroAccNo: Code[8]);
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SETRANGE("Journal Template Name", JournalTemplateName);
        GenJournalLine.SETRANGE("Journal Batch Name", JournalBatchName);
        GenJournalLine.SETRANGE(GiroAccNo, GiroAccNo);
        Assert.IsFalse(GenJournalLine.ISEMPTY(), GiroAccValueErr);
    end;

    local procedure GetRandomPaymentReference(PaymentMethodCode: Code[10]) PaymentRef: Code[16];
    VAR
        PaymentMethod: Record "Payment Method";
        RandomValue: Code[10];
    BEGIN
        PaymentMethod.GET(PaymentMethodCode);

        CASE PaymentMethod.PaymentTypeValidation OF
            PaymentMethod.PaymentTypeValidation::" ":
                BEGIN
                    RandomValue := FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999));
                    PaymentRef := CopyStr(RandomValue + RandomValue, 1, MaxStrLen(PaymentRef));
                END;
            PaymentMethod.PaymentTypeValidation::"FIK 71":
                PaymentRef := '000100017156728';
            PaymentMethod.PaymentTypeValidation::"FIK 04":
                PaymentRef := '2150263480000023';
            PaymentMethod.PaymentTypeValidation::"FIK 73",
          PaymentMethod.PaymentTypeValidation::"FIK 01":
                PaymentRef := '';
            ELSE
                ERROR(TypeNotSupportedErr, PaymentMethod.PaymentTypeValidation);
        END;
    END;

    local procedure GetRandomGiroAccNo(): Code[8];
    BEGIN
        EXIT(FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
    END;

    local procedure GetRandomCreditorNo(): Code[8];
    BEGIN
        EXIT(FORMAT(LibraryRandom.RandIntInRange(11111111, 99999999)));
    END;
}



