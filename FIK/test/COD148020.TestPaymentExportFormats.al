// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148020 "Payment Export Formats"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExport: Codeunit "Library - Payment Export DK";
        Assert: Codeunit Assert;
        UnexpectedNoOfRecordsErr: Label 'An incorrect number of lines was created in the %1 Field table', Locked = true;
        ValueNotEqualErr: Label '%1 must be equal to ''%2''  in %3', Comment = '%1=Field;%2=Value;%3=Record', Locked = true;
        CorrectFIK04: Text;
        CorrectFIK71: Text;
        IsInitialized: Boolean;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    procedure CheckBECForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');
        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(PaymentExportData."Data Exch Entry No.", 'ERH356', PaymentExportData."Recipient Bank Acc. No.",
          PaymentExportData."Applies-to Ext. Doc. No.", PaymentExportData."Message to Recipient 1",
          PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckBECForVendorLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');
        DocumentNo :=
          CreateVendPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, VendorLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(VendorLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');
        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(PaymentExportData."Data Exch Entry No.", 'ERH356', PaymentExportData."Recipient Bank Acc. No.",
          PaymentExportData."Applies-to Ext. Doc. No.", PaymentExportData."Message to Recipient 1",
          PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckBECForCustomerLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');
        DocumentNo :=
          CreateCustPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        CustLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, CustLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtCustLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(PaymentExportData."Data Exch Entry No.", 'ERH356', PaymentExportData."Recipient Bank Acc. No.",
          PaymentExportData."Applies-to Ext. Doc. No.", PaymentExportData."Message to Recipient 1",
          PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckBECFIK71ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 71", '71');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CODEUNIT.RUN(CODEUNIT::"Exp. Pre-Mapping Gen. Jnl.", DataExch);
        PaymentExportData.SETRANGE("Data Exch Entry No.", DataExch."Entry No.");
        PaymentExportData.FINDFIRST();
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '71');

        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(PaymentExportData."Data Exch Entry No.", 'ERH351', 'FI' + PaymentExportData."Recipient Creditor No.",
          '71' + PaymentExportData."Payment Reference", '', '');
    end;

    [Test]
    procedure CheckBECFIK73ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 73", '73');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '73');

        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(
          PaymentExportData."Data Exch Entry No.", 'ERH357', 'FI' + PaymentExportData."Recipient Creditor No.", '73',
          PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckBECFIK01ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 01", '01');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(
          PaymentExportData."Data Exch Entry No.", 'ERH354', 'GIRO' + PaymentExportData.RecipientGiroAccNo, '01',
          PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckBECFIK04ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');
        DataExchDef.SETFILTER(Code, '%1', '*BEC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 04", '04');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise.
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '04');

        // Verify
        VerifyFormatBEC(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBEC(PaymentExportData."Data Exch Entry No.", 'ERH352', 'GIRO' + PaymentExportData.RecipientGiroAccNo,
          '04' + PaymentExportData."Payment Reference", '', '');
    end;

    [Test]
    procedure CheckDanskeBankForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", PaymentExportData."Recipient Bank Acc. No.",
          'U', '', '', PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckDanskeBankForVendorLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');
        DocumentNo :=
          CreateVendPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::International, 'BTI');

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, VendorLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(VendorLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTI');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", PaymentExportData."Recipient Bank Acc. No.",
          'M', '', '', '', '');
    end;

    [Test]
    procedure CheckDanskeBankForCustomerLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentMethod: Record "Payment Method";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');
        DocumentNo :=
          CreateCustPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::International, 'BTI');

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        CustLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, CustLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtCustLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTI');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", PaymentExportData."Recipient Bank Acc. No.",
          'M', '', '', '', '');
    end;

    [Test]
    procedure CheckDanskeBankFIK71ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 71", '71');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '71');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", 'IK' + PaymentExportData."Recipient Creditor No.",
          '', '71', PaymentExportData."Payment Reference", '', '');
    end;

    [Test]
    procedure CheckDanskeBankFIK73ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 73", '73');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '73');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", 'IK' + PaymentExportData."Recipient Creditor No.",
          'J', '73', '', PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckDanskeBankFIK01ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 01", '01');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", 'IK' + PaymentExportData.RecipientGiroAccNo,
          'J', '01', '', PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2");
    end;

    [Test]
    procedure CheckDanskeBankFIK04ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*DANSKE*BANK*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 04", '04');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatDanskeBank(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedDanskeBank(PaymentExportData."Data Exch Entry No.", 'IK' + PaymentExportData.RecipientGiroAccNo
          , '', '04', PaymentExportData."Payment Reference", '', '');
    end;

    [Test]
    procedure CheckNordeaForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentExportData: Record "Payment Export Data";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Exercise
        WITH GenJnlLine DO BEGIN
            PaymentExportMgt.CreateDataExch(DataExch, "Bal. Account No.");
            "Data Exch. Entry No." := DataExch."Entry No.";
            MODIFY();
        END;
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatNordeaBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaBankTransfer(
          PaymentExportData."Data Exch Entry No.", '45', PaymentExportData."Recipient Bank Acc. No.",
          PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2", '', '', '100',
          PaymentExportData."Applies-to Ext. Doc. No.", '');
    end;

    [Test]
    procedure CheckNordeaForVendorLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentExportData: Record "Payment Export Data";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');
        DocumentNo :=
          CreateVendPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::International, 'BTI');

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, VendorLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(VendorLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTI');

        // Verify
        VerifyFormatNordeaBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaBankTransfer(
          PaymentExportData."Data Exch Entry No.", '49', PaymentExportData."Recipient Bank Acc. No.", '', '', '', '', '', '', 'N');
    end;

    [Test]
    procedure CheckNordeaForCustomerLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentExportData: Record "Payment Export Data";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');
        DocumentNo :=
          CreateCustPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic CSV", PaymentMethod.PaymentTypeValidation::International, 'BTI');

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        CustLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, CustLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtCustLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTI');

        // Verify
        VerifyFormatNordeaBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaBankTransfer(
          PaymentExportData."Data Exch Entry No.", '49', PaymentExportData."Recipient Bank Acc. No.", '', '', '', '', '', '', 'N');
    end;

    [Test]
    procedure CheckNordeaFIK71ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 71", '71');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '71');

        // Verify
        VerifyFormatNordeaFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaFIK(
          PaymentExportData."Data Exch Entry No.", '46', PaymentExportData."Recipient Creditor No.", '', '', '71');
    end;

    [Test]
    procedure CheckNordeaFIK73ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 73", '73');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '73');

        // Verify
        VerifyFormatNordeaFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaFIK(PaymentExportData."Data Exch Entry No.", '46', PaymentExportData."Recipient Creditor No.",
          PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2", '73');
    end;

    [Test]
    procedure CheckNordeaFIK01ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 01", '01');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatNordeaFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaFIK(PaymentExportData."Data Exch Entry No.", '46', PaymentExportData.RecipientGiroAccNo,
          PaymentExportData."Message to Recipient 1", PaymentExportData."Message to Recipient 2", '01');
    end;

    [Test]
    procedure CheckNordeaFIK04ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*NORDEA*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 04", '04');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '04');

        // Verify
        VerifyFormatNordeaFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedNordeaFIK(
          PaymentExportData."Data Exch Entry No.", '46', PaymentExportData.RecipientGiroAccNo, '', '', '04');
    end;

    [Test]
    procedure CheckSDCForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '%1', '*SDC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatSDCBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCForVendorLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');
        DocumentNo :=
          CreateVendPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic Fixed Width", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, VendorLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(VendorLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatSDCBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCForCustomerLedgerEntries();
    var
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');
        DocumentNo :=
          CreateCustPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic Fixed Width", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        CustLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, CustLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtCustLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatSDCBankTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCFIK71ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 71", '71');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '71');

        // Verify
        VerifyFormatSDCFIK71(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCFIK73ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 73", '73');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '73');

        // Verify
        VerifyFormatSDCFIK73(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCFIK01ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 01", '01');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY();

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatSDCFIK01(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckSDCFIK04ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*SDC*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 04", '04');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine."Data Exch. Entry No." := DataExch."Entry No.";
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        CreateDataExchFieldRecords(PaymentExportData, DataExch);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatSDCFIK04(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckBankDataForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentMethod: Record "Payment Method";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Setup
        DataExchDef.SETFILTER(Code, '*BankData*');
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");

        // Exercise
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(PaymentExportData, GenJnlLine, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatBankDataTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckBankDataForVendorLedgerEntries();
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        BankAccount: Record "Bank Account";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtVendLedgEntry: Codeunit "Pmt Export Mgt Vend Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');
        DocumentNo :=
          CreateVendPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic Fixed Width", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        VendorLedgerEntry.SETRANGE("Document No.", DocumentNo);
        VendorLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, VendorLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtVendLedgEntry.PreparePaymentExportDataVLE(PaymentExportData, VendorLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(VendorLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatBankDataTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckBankDataForCustomerLedgerEntries();
    var
        DataExchLineDef: Record "Data Exch. Line Def";
        BankAccount: Record "Bank Account";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtCustLedgEntry: Codeunit "Pmt Export Mgt Cust Ledg Entry";
        DocumentNo: Code[20];
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');
        DocumentNo :=
          CreateCustPmtLedgerEntryWithRecipientBankAcc(
            DataExchDef, XMLPORT::"Export Generic Fixed Width", PaymentMethod.PaymentTypeValidation::Domestic, 'BTD');

        // Setup
        CustLedgerEntry.SETRANGE("Document No.", DocumentNo);
        CustLedgerEntry.FINDLAST();

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, CustLedgerEntry."Bal. Account No.");

        // Exercise
        PmtExportMgtCustLedgEntry.PreparePaymentExportDataCLE(PaymentExportData, CustLedgerEntry, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        BankAccount.GET(CustLedgerEntry."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", 'BTD');

        // Verify
        VerifyFormatBankDataTransfer(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
    end;

    [Test]
    procedure CheckBankDataFIK71ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 71", '71');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK71);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(PaymentExportData, GenJnlLine, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '71');

        // Verify
        VerifyFormatBankDataFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBankData(PaymentExportData."Data Exch Entry No.", '71',
          PADSTR('', 19 - STRLEN(PaymentExportData."Payment Reference"), '0') + PaymentExportData."Payment Reference",
          PADSTR('', 10),
          PADSTR('', 8 - STRLEN(PaymentExportData."Recipient Creditor No."), '0') + PaymentExportData."Recipient Creditor No.");
    end;

    [Test]
    procedure CheckBankDataFIK73ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 73", '73');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");

        // Exercise
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(PaymentExportData, GenJnlLine, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '73');

        // Verify
        VerifyFormatBankDataFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBankData(PaymentExportData."Data Exch Entry No.", '73',
          PADSTR('', 19),
          PADSTR('', 10),
          PADSTR('', 8 - STRLEN(PaymentExportData."Recipient Creditor No."), '0') + PaymentExportData."Recipient Creditor No.");
    end;

    [Test]
    procedure CheckBankDataFIK01ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 01", '01');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");

        // Exercise
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(PaymentExportData, GenJnlLine, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '01');

        // Verify
        VerifyFormatBankDataFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBankData(PaymentExportData."Data Exch Entry No.", '01',
          PADSTR('', 19),
          PADSTR('', 10 - STRLEN(PaymentExportData.RecipientGiroAccNo), '0') + PaymentExportData.RecipientGiroAccNo,
          PADSTR('', 8));
    end;

    [Test]
    procedure CheckBankDataFIK04ForPmtJournalLine();
    var
        BankAccount: Record "Bank Account";
        GenJnlBatch: Record "Gen. Journal Batch";
        GenJnlLine: Record "Gen. Journal Line";
        PaymentExportData: Record "Payment Export Data";
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        PaymentMethod: Record "Payment Method";
        DataExchLineDef: Record "Data Exch. Line Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        Initialize();

        // Pre-Setup
        DataExchDef.SETFILTER(Code, '*BankData*');

        // Setup
        LibraryPaymentExport.CreatePaymentExportBatch(GenJnlBatch, DataExchDef, XMLPORT::"Export Generic Fixed Width");
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(
          GenJnlLine, GenJnlBatch, PaymentMethod.PaymentTypeValidation::"FIK 04", '04');

        // Pre-Exercise
        PaymentExportMgt.CreateDataExch(DataExch, GenJnlLine."Bal. Account No.");
        GenJnlLine.VALIDATE("Payment Reference", CorrectFIK04);
        GenJnlLine.MODIFY(TRUE);

        // Exercise
        PmtExportMgtGenJnlLine.PreparePaymentExportDataJnl(PaymentExportData, GenJnlLine, DataExch."Entry No.", 1);
        PaymentExportMgt.CreatePaymentLines(PaymentExportData);

        // Pre-Verify
        FindPaymentJournalLines(GenJnlLine, GenJnlBatch."Journal Template Name", GenJnlBatch.Name);
        BankAccount.GET(GenJnlBatch."Bal. Account No.");
        DataExchLineDef.GET(DataExch."Data Exch. Def Code", '04');

        // Verify
        VerifyFormatBankDataFIK(BankAccount."Payment Export Format", PaymentExportData, DataExchLineDef."Column Count");
        VerifyDistinguishedBankData(PaymentExportData."Data Exch Entry No.", '04',
          PADSTR('', 19 - STRLEN(PaymentExportData."Payment Reference"), '0') + PaymentExportData."Payment Reference",
          PADSTR('', 10 - STRLEN(PaymentExportData.RecipientGiroAccNo), '0') + PaymentExportData.RecipientGiroAccNo,
          PADSTR('', 8));
    end;

    local procedure CheckColumnValue(DataExchEntryNo: Integer; LineNo: Integer; ColumnNo: Integer; ExpectedValue: Text);
    var
        DataExchField: Record "Data Exch. Field";
    begin
        DataExchField.GET(DataExchEntryNo, LineNo, ColumnNo);
        Assert.AreEqual(ExpectedValue, DataExchField.Value,
          STRSUBSTNO(ValueNotEqualErr, DataExchField.FIELDCAPTION(Value), ExpectedValue, DataExchField.TABLECAPTION()));
    end;

    local procedure CreateCustPmtLedgerEntryWithRecipientBankAcc(var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer; PaymentTypeValidation: Option; PaymentType: Code[10]) DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPortID);
        LibraryPaymentExport.CreateCustPmtJnlLineWithPaymentTypeInfo(GenJournalLine, GenJournalBatch, PaymentTypeValidation, PaymentType);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateVendPmtLedgerEntryWithRecipientBankAcc(var DataExchDef: Record "Data Exch. Def"; XMLPortID: Integer; PaymentTypeValidation: Option; PaymentType: Code[10]) DocumentNo: Code[20];
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryPaymentExport.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPortID);
        LibraryPaymentExport.CreateVendorPmtJnlLineWithPaymentTypeInfo(GenJournalLine, GenJournalBatch, PaymentTypeValidation, PaymentType);
        DocumentNo := GenJournalLine."Document No.";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateDataExchFieldRecords(var PaymentExportData: Record "Payment Export Data"; DataExch: Record "Data Exch.");
    begin
        CODEUNIT.RUN(CODEUNIT::"Exp. Pre-Mapping Gen. Jnl.", DataExch);
        PaymentExportData.SETRANGE("Data Exch Entry No.", DataExch."Entry No.");
        PaymentExportData.FINDFIRST();
        CODEUNIT.RUN(CODEUNIT::"Exp. Mapping Gen. Jnl.", DataExch);
    end;

    local procedure FindPaymentJournalLines(var GenJnlLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]);
    begin
        GenJnlLine.SETRANGE("Journal Template Name", JournalTemplateName);
        GenJnlLine.SETRANGE("Journal Batch Name", JournalBatchName);
        GenJnlLine.FINDSET();
    end;

    local procedure Initialize();
    begin
        IF IsInitialized THEN
            EXIT;

        CorrectFIK71 := '000100017156728';
        CorrectFIK04 := '2150263480000023';

        IsInitialized := TRUE;
    end;

    local procedure VerifyAllColumnValuesBEC(PaymentExportData: Record "Payment Export Data");
    var
        i: Integer;
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 2, "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, "Document No."); // Column 3 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 5, "Recipient Name"); // Column 5 - Name of recipient
            FOR i := 6 TO 8 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 5 to 8 - Not used;
            CheckColumnValue("Data Exch Entry No.", 1, 9, FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,,>')); // Column 9 - Amount, 2 decimals
            CheckColumnValue("Data Exch Entry No.", 1, 10, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 10 - Date ddmmyyyy
            FOR i := 12 TO 19 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 12 to 19 - Not used;
            CheckColumnValue("Data Exch Entry No.", 1, 20, 'J'); // Column 20 - Notification (J,N) -> J
            FOR i := 21 TO 32 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 21 to 32 - Not used;
            FOR i := 35 TO 73 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 35 to 73 - Not used;
        END;
    end;

    local procedure VerifyAllColumnValuesDanskeBank(PaymentExportData: Record "Payment Export Data");
    var
        i: Integer;
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'CMBO'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2, "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 4, FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,.>')); // Column 4 - Amount, 2 decimals
            CheckColumnValue("Data Exch Entry No.", 1, 5, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 5 - Date ddmmyyyy
            CheckColumnValue("Data Exch Entry No.", 1, 6, "Currency Code"); // Column 6 - Currency Code
            CheckColumnValue("Data Exch Entry No.", 1, 7, ''); // Column 7 to 12 - Not used;
            FOR i := 9 TO 12 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 7 to 12 - Not used
            CheckColumnValue("Data Exch Entry No.", 1, 13, 'N'); // Column 13 - Letter to Sender (J or N) -> N
            FOR i := 14 TO 19 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 14 to 19 - Not used;
            CheckColumnValue("Data Exch Entry No.", 1, 20, "Document No."); // Column 20 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 21, ''); // Column 21 - Not used;
            CheckColumnValue("Data Exch Entry No.", 1, 22, "Applies-to Ext. Doc. No."); // Column 22 - Text to Recipient
            FOR i := 25 TO 26 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, ''); // Column 25 to 26 - Not used;
        END;
    end;

    local procedure VerifyAllColumnValuesNordeaBankTransfer(PaymentExportData: Record "Payment Export Data");
    var
        i: Integer;
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, ''); // Column 1 - hard coded
            FOR i := 3 TO 10 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 11, "Recipient Bank Country/Region");
            CheckColumnValue("Data Exch Entry No.", 1, 12, "Recipient Name");
            CheckColumnValue("Data Exch Entry No.", 1, 13, "Recipient Address");
            CheckColumnValue("Data Exch Entry No.", 1, 14, "Recipient City");
            CheckColumnValue("Data Exch Entry No.", 1, 15, ''); // Column 15 - Not used
            CheckColumnValue("Data Exch Entry No.", 1, 16, ''); // Column 16 - Not used
            CheckColumnValue("Data Exch Entry No.", 1, 17, "Recipient Bank Acc. No."); // Column 17 - Receipient Bank Account
            CheckColumnValue("Data Exch Entry No.", 1, 18, "Recipient Bank Name"); // Column 18 - Receipient Bank Name
            CheckColumnValue("Data Exch Entry No.", 1, 19, "Recipient Bank Address"); // Column 19 - Receipient Bank Address
            CheckColumnValue("Data Exch Entry No.", 1, 20, "Recipient Bank City"); // Column 20 - Receipient Bank City
            CheckColumnValue("Data Exch Entry No.", 1, 21, ''); // Column 21 - Not used
            CheckColumnValue("Data Exch Entry No.", 1, 22, "Recipient Bank BIC"); // Column 22 - Receipient Bank Account SWIFT
            FOR i := 25 TO 30 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 31, "Currency Code"); // Column 31 - Currency
            CheckColumnValue("Data Exch Entry No.", 1, 32, '');
            CheckColumnValue("Data Exch Entry No.", 1, 33, FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,.>')); // Column 4 - Amount, 2 decimals
            CheckColumnValue("Data Exch Entry No.", 1, 34, FORMAT("Transfer Date", 0, '<Year4><Month,2><Day,2>')); // Column 5 - Date yyyymmdd
            CheckColumnValue("Data Exch Entry No.", 1, 35, '');
            CheckColumnValue("Data Exch Entry No.", 1, 36, '');
            CheckColumnValue("Data Exch Entry No.", 1, 37, "Sender Bank Account No."); // Column 37 - Bank Account No. of the sender
            CheckColumnValue("Data Exch Entry No.", 1, 38, "Document No.");
            FOR i := 39 TO 44 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            FOR i := 47 TO 50 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 53, "Short Advice");
            FOR i := 54 TO 92 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
        END;
    end;

    local procedure VerifyAllColumnValuesNordeaFIK(PaymentExportData: Record "Payment Export Data");
    var
        i: Integer;
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, ''); // Column 1 - hard coded
            FOR i := 3 TO 11 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 12, "Recipient Name");
            FOR i := 13 TO 16 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            FOR i := 18 TO 22 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            FOR i := 24 TO 30 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 31, "Currency Code"); // Column 31 - Currency
            CheckColumnValue("Data Exch Entry No.", 1, 32, '');
            CheckColumnValue("Data Exch Entry No.", 1, 33, FORMAT(Amount, 0, '<Precision,2><sign><Integer><Decimals><Comma,.>')); // Column 33 - Amount, 2 decimals
            CheckColumnValue("Data Exch Entry No.", 1, 34, FORMAT("Transfer Date", 0, '<Year4><Month,2><Day,2>')); // Column 34 - Date yyyymmdd
            CheckColumnValue("Data Exch Entry No.", 1, 35, '');
            CheckColumnValue("Data Exch Entry No.", 1, 36, '');
            CheckColumnValue("Data Exch Entry No.", 1, 37, "Sender Bank Account No."); // Column 37 - Bank Account No. of the sender
            CheckColumnValue("Data Exch Entry No.", 1, 38, "Document No.");
            FOR i := 39 TO 44 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
            CheckColumnValue("Data Exch Entry No.", 1, 46, "Payment Reference"); // Column 46 - Payment reference
            FOR i := 47 TO 90 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, '');
        END;
    end;

    local procedure VerifyDistinguishedNordeaBankTransfer(DataExchEntryNo: Integer; Column2: Text; Column17: Text; Column23: Text; Column24: Text; Column45: Text; Column46: Text; Column51: Text; Column93: Text; Column94: Text);
    begin
        CheckColumnValue(DataExchEntryNo, 1, 2, Column2); // Column 2 Format Type : 45,46,49
        CheckColumnValue(DataExchEntryNo, 1, 17, Column17); // Column 17 - Recipient Info
        CheckColumnValue(DataExchEntryNo, 1, 23, Column23); // Column 23 - Message to Recipient 1
        CheckColumnValue(DataExchEntryNo, 1, 24, Column24); // Column 24 - Message to Recipient 2
        CheckColumnValue(DataExchEntryNo, 1, 51, Column51); // Column 51 - Tekstkode
        CheckColumnValue(DataExchEntryNo, 1, 93, Column93); // Column 93 - External Document Number
        CheckColumnValue(DataExchEntryNo, 1, 94, Column94); // Column 94 - Format Expense Code
    end;

    local procedure VerifyDistinguishedNordeaFIK(DataExchEntryNo: Integer; Column2: Text; Column17: Text; Column23: Text; Column24: Text; Column45: Text);
    begin
        CheckColumnValue(DataExchEntryNo, 1, 2, Column2); // Column 2 Format Type : 45,46,49
        CheckColumnValue(DataExchEntryNo, 1, 17, Column17); // Column 17 - Creditor or Giro number
        CheckColumnValue(DataExchEntryNo, 1, 23, Column23); // Column 23 - Message to Recipient 1
        CheckColumnValue(DataExchEntryNo, 1, 24, Column24); // Column 24 - Message to Recipient 2
        CheckColumnValue(DataExchEntryNo, 1, 45, Column45); // Column 45 - Kortart kode
    end;

    local procedure VerifyAllColumnValuesSDCBankTransfer(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, '3'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2,
              PADSTR('', 14 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year>')); // Column 3 - Transfer Date
            CheckColumnValue("Data Exch Entry No.", 1, 4,
              FORMAT(Amount, 0, '<Precision,2><Sign,1><Filler Character,0><Integer,11><Filler Character,0><Decimals><Comma,,>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, 'J'); // Column 5 - Notification (J,N) -> J
            CheckColumnValue("Data Exch Entry No.", 1, 6, PADSTR("Document No.", 20)); // Column 6 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 7,
              PADSTR('', 4 - STRLEN("Recipient Reg. No."), '0') + "Recipient Reg. No."); // Column 7 - Recipient Bank Branch Number
            CheckColumnValue("Data Exch Entry No.", 1, 8,
              PADSTR('', 10 - STRLEN("Recipient Acc. No."), '0') + "Recipient Acc. No."); // Column 8 - Recipient Bank Account Number
            CheckColumnValue("Data Exch Entry No.", 1, 9, PADSTR('', 4)); // Column 9 - Not used
            CheckColumnValue("Data Exch Entry No.", 1, 10, PADSTR("Applies-to Ext. Doc. No.", 20)); // Column 11 - Text to Recipient
        END;
    end;

    local procedure VerifyAllColumnValuesSDCFIK71(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'K020'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2,
              PADSTR('', 14 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 3 - Transfer Date
            CheckColumnValue("Data Exch Entry No.", 1, 4,
              FORMAT(Amount, 0, '<Precision,2><Sign,1><Filler Character,0><Integer,11><Filler Character,0><Decimals><Comma,,>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, 'J'); // Column 5 - Notification (J,N) -> J
            CheckColumnValue("Data Exch Entry No.", 1, 6, PADSTR("Document No.", 20)); // Column 6 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 7, FORMAT("Recipient Creditor No.", 0, '<Text,8><Filler Character,0>')); // Column 7 - Recipient Creditor Number
            CheckColumnValue("Data Exch Entry No.", 1, 8, '71'); // Column 8 - 71 hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 9,
              PADSTR('', 15 - STRLEN("Payment Reference"), '0') + "Payment Reference"); // Column 9 - Payment Reference
        END;
    end;

    local procedure VerifyAllColumnValuesSDCFIK73(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'K073'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2,
              PADSTR('', 14 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 3 - Transfer Date
            CheckColumnValue("Data Exch Entry No.", 1, 4,
              FORMAT(Amount, 0, '<Precision,2><Sign,1><Filler Character,0><Integer,11><Filler Character,0><Decimals><Comma,,>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, 'J'); // Column 5 - Notification (J,N) -> J
            CheckColumnValue("Data Exch Entry No.", 1, 6, PADSTR("Document No.", 20)); // Column 6 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 7, FORMAT("Recipient Creditor No.", 0, '<Text,8><Filler Character,0>')); // Column 7 - Recipient Creditor Number
            CheckColumnValue("Data Exch Entry No.", 1, 8, '73'); // Column 8 - 71 hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 9, 'N'); // Column 9 - Alternative sender info J/N
            CheckColumnValue("Data Exch Entry No.", 1, 10, PADSTR('', 18)); // Column 10 - Alternative sender identification
            CheckColumnValue("Data Exch Entry No.", 1, 11, PADSTR('', 32)); // Column 11 - Alternative sender name
            CheckColumnValue("Data Exch Entry No.", 1, 12, PADSTR('', 32)); // Column 12 - Alternative sender address
            CheckColumnValue("Data Exch Entry No.", 1, 13, PADSTR('', 4)); // Column 13 - Alternative sender post number
            CheckColumnValue("Data Exch Entry No.", 1, 14, '002'); // Column 14 - Number of Message to Recipient lines
            CheckColumnValue("Data Exch Entry No.", 1, 15, PADSTR("Message to Recipient 1", 35)); // Column 15 - Message to Recipient 1
            CheckColumnValue("Data Exch Entry No.", 1, 16, PADSTR("Message to Recipient 2", 35)); // Column 16 - Message to Recipient 2
        END;
    end;

    local procedure VerifyAllColumnValuesSDCFIK01(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'K006'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2,
              PADSTR('', 14 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 3 - Transfer Date
            CheckColumnValue("Data Exch Entry No.", 1, 4,
              FORMAT(Amount, 0, '<Precision,2><Sign,1><Filler Character,0><Integer,11><Filler Character,0><Decimals><Comma,,>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, 'J'); // Column 5 - Notification (J,N) -> J
            CheckColumnValue("Data Exch Entry No.", 1, 6, PADSTR("Document No.", 20)); // Column 6 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 7, 'N'); // Column 7 - Alternative sender info J/N
            CheckColumnValue("Data Exch Entry No.", 1, 8, PADSTR('', 18)); // Column 8 - Alternative sender identification
            CheckColumnValue("Data Exch Entry No.", 1, 9, PADSTR('', 32)); // Column 9 - Alternative sender name
            CheckColumnValue("Data Exch Entry No.", 1, 10, PADSTR('', 32)); // Column 10 - Alternative sender address
            CheckColumnValue("Data Exch Entry No.", 1, 11, PADSTR('', 4)); // Column 11 - Alternative sender post number
            CheckColumnValue("Data Exch Entry No.", 1, 12, FORMAT(RecipientGiroAccNo, 0, '<Text,10><Filler Character,0>')); // Column 12 - Gironummer
            CheckColumnValue("Data Exch Entry No.", 1, 13, '01'); // Column 13 - 01 hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 14, PADSTR('', 19)); // Column 14 - Payment Reference
            CheckColumnValue("Data Exch Entry No.", 1, 15, '002'); // Column 15 - Number of Message to Recipient lines
            CheckColumnValue("Data Exch Entry No.", 1, 16, PADSTR("Message to Recipient 1", 35)); // Column 16 - Message to Recipient 1
            CheckColumnValue("Data Exch Entry No.", 1, 17, PADSTR("Message to Recipient 2", 35)); // Column 16 - Message to Recipient 2
        END;
    end;

    local procedure VerifyAllColumnValuesSDCFIK04(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'K006'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2,
              PADSTR('', 14 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Day,2><Month,2><Year4>')); // Column 3 - Transfer Date
            CheckColumnValue("Data Exch Entry No.", 1, 4,
              FORMAT(Amount, 0, '<Precision,2><Sign,1><Filler Character,0><Integer,11><Filler Character,0><Decimals><Comma,,>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, 'J'); // Column 5 - Notification (J,N) -> J
            CheckColumnValue("Data Exch Entry No.", 1, 6, PADSTR("Document No.", 20)); // Column 6 - Text to Sender
            CheckColumnValue("Data Exch Entry No.", 1, 7, 'N'); // Column 7 - Alternative sender info J/N
            CheckColumnValue("Data Exch Entry No.", 1, 8, PADSTR('', 18)); // Column 8 - Alternative sender identification
            CheckColumnValue("Data Exch Entry No.", 1, 9, PADSTR('', 32)); // Column 9 - Alternative sender name
            CheckColumnValue("Data Exch Entry No.", 1, 10, PADSTR('', 32)); // Column 10 - Alternative sender address
            CheckColumnValue("Data Exch Entry No.", 1, 11, PADSTR('', 4)); // Column 11 - Alternative sender post number
            CheckColumnValue("Data Exch Entry No.", 1, 12, FORMAT(RecipientGiroAccNo, 0, '<Text,10><Filler Character,0>')); // Column 12 - Gironummer
            CheckColumnValue("Data Exch Entry No.", 1, 13, '04'); // Column 13 - 01 hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 14,
              PADSTR('', 19 - STRLEN("Payment Reference"), '0') + "Payment Reference"); // Column 14 - Payment Reference
            CheckColumnValue("Data Exch Entry No.", 1, 15, '002'); // Column 15 - Number of Message to Recipient lines
            CheckColumnValue("Data Exch Entry No.", 1, 16, PADSTR("Message to Recipient 1", 35)); // Column 16 - Message to Recipient 1
            CheckColumnValue("Data Exch Entry No.", 1, 17, PADSTR("Message to Recipient 2", 35)); // Column 16 - Message to Recipient 2
        END;
    end;

    local procedure VerifyAllColumnValuesBankDataTransfer(PaymentExportData: Record "Payment Export Data");
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'IB030202000005'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2, '0001'); // Column 2 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Year4><Month,2><Day,2>')); // Column 3 - Transfer Date
            CheckColumnValue(
              "Data Exch Entry No.", 1, 4, FORMAT(100 * Amount, 0, '<Integer,13><Filler Character,0><Sign,1><Filler Character,+>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, "Currency Code"); // Column 5 - Currency Code
            CheckColumnValue("Data Exch Entry No.", 1, 6, '2'); // Column 6 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 7,
              PADSTR('', 15 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 2 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 8, '2'); // Column 8 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 9,
              PADSTR('', 4 - STRLEN("Recipient Reg. No."), '0') + "Recipient Reg. No."); // Column 9 - Recipient Reg. Nr.
            CheckColumnValue("Data Exch Entry No.", 1, 10,
              PADSTR('', 10 - STRLEN("Recipient Acc. No."), '0') + "Recipient Acc. No."); // Column 10 - Recipient Acc. Nr.
            CheckColumnValue("Data Exch Entry No.", 1, 11, '0'); // Column 11 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 12, PADSTR("Message to Recipient 1", 35)); // Column 12 - Short Advice
            CheckColumnValue("Data Exch Entry No.", 1, 13, PADSTR("Recipient Name", 32)); // Column 13 - Name
            CheckColumnValue("Data Exch Entry No.", 1, 14, PADSTR("Recipient Address", 32)); // Column 13 - Address
            CheckColumnValue("Data Exch Entry No.", 1, 17, PADSTR("Recipient City", 32)); // Column 17 - City
            CheckColumnValue("Data Exch Entry No.", 1, 18, PADSTR("Applies-to Ext. Doc. No.", 35)); // Column 18 - Rec. Doc No.
            CheckColumnValue("Data Exch Entry No.", 1, 19, PADSTR("Message to Recipient 1", 35)); // Column 19 - Message to Recipient 1
            CheckColumnValue("Data Exch Entry No.", 1, 20, PADSTR("Message to Recipient 2", 35)); // Column 20 - Message to Recipient 2
        END;
    end;

    local procedure VerifyCommonColumnValuesBankDataFIK(PaymentExportData: Record "Payment Export Data");
    var
        i: Integer;
    begin
        WITH PaymentExportData DO BEGIN
            CheckColumnValue("Data Exch Entry No.", 1, 1, 'IB030207000002'); // Column 1 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 2, '0001'); // Column 2 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 3, FORMAT("Transfer Date", 0, '<Year4><Month,2><Day,2>')); // Column 3 - Transfer Date
            CheckColumnValue(
              "Data Exch Entry No.", 1, 4, FORMAT(100 * Amount, 0, '<Integer,13><Filler Character,0><Sign,1><Filler Character,+>')); // Column 4 - Amount
            CheckColumnValue("Data Exch Entry No.", 1, 5, '2'); // Column 5 - hard coded
            CheckColumnValue("Data Exch Entry No.", 1, 6,
              PADSTR('', 15 - STRLEN("Sender Bank Account No."), '0') + "Sender Bank Account No."); // Column 6 - Bank Account No. of the Sender
            CheckColumnValue("Data Exch Entry No.", 1, 9, PADSTR('', 4)); // Column 9 - blank
            CheckColumnValue("Data Exch Entry No.", 1, 12, PADSTR("Recipient Name", 32)); // Column 12 - Recipient Name
            CheckColumnValue("Data Exch Entry No.", 1, 13, PADSTR('', 32)); // Column 13 - blank
            CheckColumnValue("Data Exch Entry No.", 1, 14, PADSTR("Applies-to Ext. Doc. No.", 35)); // Column 14 - Rec. Doc No.
            FOR i := 15 TO 19 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, PADSTR('', 35)); // Column 15-19 - blank
            CheckColumnValue("Data Exch Entry No.", 1, 20, PADSTR("Message to Recipient 1", 35)); // Column 20 - Message to recipient part 1
            CheckColumnValue("Data Exch Entry No.", 1, 21, PADSTR("Message to Recipient 2", 35)); // Column 21 - Message to recipient part 2
            FOR i := 22 TO 25 DO
                CheckColumnValue("Data Exch Entry No.", 1, i, PADSTR('', 35)); // Column 22-25 - blank
            CheckColumnValue("Data Exch Entry No.", 1, 26, PADSTR('', 16)); // Column 26 - 16 spaces
            CheckColumnValue("Data Exch Entry No.", 1, 27, PADSTR('', 215)); // Column 27 - 215 spaces
        END;
    end;

    local procedure VerifyDistinguishedBankData(DataExchEntryNo: Integer; Column7: Text; Column8: Text; Column10: Text; Column11: Text);
    begin
        CheckColumnValue(DataExchEntryNo, 1, 7, Column7); // Column 7 - FIK Payment Type
        CheckColumnValue(DataExchEntryNo, 1, 8, Column8);  // Column 8 - Payment reference
        CheckColumnValue(DataExchEntryNo, 1, 10, Column10); // Column 10 - Recipient Giro. Kontonummer.
        CheckColumnValue(DataExchEntryNo, 1, 11, Column11); // Column 11 - Recipient Kreditor. Nr.
    end;

    local procedure VerifyFormatBEC(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesBEC(PaymentExportData);
    end;

    local procedure VerifyDistinguishedBEC(DataExchEntryNo: Integer; Column1: Text; Column4: Text; Column11: Text; Column33: Text; Column34: Text);
    begin
        CheckColumnValue(DataExchEntryNo, 1, 1, Column1); // Column 1 - Payment Type
        CheckColumnValue(DataExchEntryNo, 1, 4, Column4); // Column 4 - To Account
        CheckColumnValue(DataExchEntryNo, 1, 11, Column11); // Column 11 - Text to Recipient
        CheckColumnValue(DataExchEntryNo, 1, 33, Column33); // Column 33 - Message to Recipient 1
        CheckColumnValue(DataExchEntryNo, 1, 34, Column34); // Column 34 - Message to Recipient 2
    end;

    local procedure VerifyFormatDanskeBank(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesDanskeBank(PaymentExportData);
    end;

    local procedure VerifyDistinguishedDanskeBank(DataExchEntryNo: Integer; Column3: Text; Column8: Text; Column23: Text; Column24: Text; Column27: Text; Column28: Text);
    begin
        CheckColumnValue(DataExchEntryNo, 1, 3, Column3); // Column 3 Bank Account No. or CreditorNo.
        CheckColumnValue(DataExchEntryNo, 1, 8, Column8); // Column 8 - Notification (U,M,J,S,N or '') -> U
        CheckColumnValue(DataExchEntryNo, 1, 23, Column23); // Column 23 - FormType
        CheckColumnValue(DataExchEntryNo, 1, 24, Column24); // Column 24 Payment Reference
        CheckColumnValue(DataExchEntryNo, 1, 27, Column27); // Column 27 Message 1
        CheckColumnValue(DataExchEntryNo, 1, 28, Column28); // Column 28 Message 2
    end;

    local procedure VerifyFormatNordeaBankTransfer(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesNordeaBankTransfer(PaymentExportData);
    end;

    local procedure VerifyFormatNordeaFIK(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesNordeaFIK(PaymentExportData);
    end;

    local procedure VerifyFormatSDCBankTransfer(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesSDCBankTransfer(PaymentExportData);
    end;

    local procedure VerifyFormatSDCFIK71(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesSDCFIK71(PaymentExportData);
    end;

    local procedure VerifyFormatSDCFIK73(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesSDCFIK73(PaymentExportData);
    end;

    local procedure VerifyFormatSDCFIK01(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesSDCFIK01(PaymentExportData);
    end;

    local procedure VerifyFormatSDCFIK04(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesSDCFIK04(PaymentExportData);
    end;

    local procedure VerifyFormatBankDataTransfer(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyAllColumnValuesBankDataTransfer(PaymentExportData);
    end;

    local procedure VerifyFormatBankDataFIK(DataExchDefCode: Code[20]; PaymentExportData: Record "Payment Export Data"; ColumnCount: Integer);
    begin
        VerifyDataExchDetails(PaymentExportData."Data Exch Entry No.", DataExchDefCode, ColumnCount);
        VerifyCommonColumnValuesBankDataFIK(PaymentExportData);
    end;

    local procedure VerifyDataExchDetails(DataExchEntryNo: Integer; DataExchDefCode: Code[20]; ColumnCount: Integer);
    var
        DataExch: Record "Data Exch.";
        DataExchField: Record "Data Exch. Field";
    begin
        DataExch.GET(DataExchEntryNo);
        DataExch.TESTFIELD("Data Exch. Def Code", DataExchDefCode);
        DataExchField.SETRANGE("Data Exch. No.", DataExch."Entry No.");
        Assert.AreEqual(ColumnCount, DataExchField.COUNT(), STRSUBSTNO(UnexpectedNoOfRecordsErr, DataExchField.TABLECAPTION()));
    end;
}



