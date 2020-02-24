// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148021 "Payment Export Sunshine"
{
    // version Test,ERM,DK

    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPaymentExportDK: Codeunit "Library - Payment Export DK";
        LibraryRandom: Codeunit "Library - Random";
        EmptyPaymentDetailsErr: Label '%1, %2 or %3 must be used for payments.', Comment = '%1=Field;%2=Field;%3=Field', Locked = true;
        HasErrorsErr: Label 'The file export has one or more errors. For each of the lines to be exported, resolve any errors that are displayed in the File Export Errors FactBox.', Locked = true;
        RecipientBankAccMissingErr: Label '%1 for one or more %2 is not specified.', Comment = '%1=Field;%2=Table', Locked = true;

    trigger OnRun();
    begin
        // [FEATURE] [FIK]
    end;

    [Test]
    [HandlerFunctions('CustomerBankAccountListPageHandler')]
    procedure AddCustomerPreferredBankAcc();
    var
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        CustomerCard: TestPage "Customer Card";
        CustomerNo: Code[20];
    begin
        // 1.1
        // Setup
        LibraryPaymentExportDK.CreateCustWithMultipleBankAccounts(Customer);

        // Post-Setup
        CustomerNo := Customer."No.";

        // Pre-Exercise
        CustomerCard.OPENEDIT();
        CustomerCard.GOTOKEY(CustomerNo);

        // Exercise
        CustomerCard."Preferred Bank Account Code".LOOKUP();

        // Pre-Verify
        CustomerBankAccount.SETRANGE("Customer No.", CustomerNo);
        CustomerBankAccount.FINDLAST();

        // Verify
        CustomerCard."Preferred Bank Account Code".ASSERTEQUALS(CustomerBankAccount.Code);
        CustomerCard.OK().INVOKE();
    end;

    [Test]
    procedure AddRecipientBankAccToPmtJnlLine();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        Vendor: Record Vendor;
        LineNo: Integer;
    begin
        // 1.3
        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");

        // Exercise
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Post-Exercise
        LineNo := GenJournalLine."Line No.";

        // Pre-Verify
        GenJournalLine.GET(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, LineNo);
        Vendor.GET(GenJournalLine."Account No.");

        // Verify
        GenJournalLine.TESTFIELD("Recipient Bank Account", Vendor."Preferred Bank Account Code");
    end;

    [Test]
    [HandlerFunctions('VendorBankAccountListPageHandler')]
    procedure AddVendorPreferredBankAcc();
    var
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        VendorCard: TestPage "Vendor Card";
        VendorNo: Code[20];
    begin
        // 1.1
        // Setup
        LibraryPaymentExportDK.CreateVendorWithMultipleBankAccounts(Vendor);

        // Post-Setup
        VendorNo := Vendor."No.";

        // Pre-Exercise
        VendorCard.OPENEDIT();
        VendorCard.GOTOKEY(VendorNo);

        // Exercise
        VendorCard."Preferred Bank Account Code".LOOKUP();

        // Pre-Verify
        VendorBankAccount.SETRANGE("Vendor No.", VendorNo);
        VendorBankAccount.FINDLAST();

        // Verify
        VendorCard."Preferred Bank Account Code".ASSERTEQUALS(VendorBankAccount.Code);
        VendorCard.OK().INVOKE();
    end;

    [Test]
    procedure ClearRecipientBankAccOnPmtJnlLine();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentJournal: TestPage "Payment Journal";
        LineNo: Integer;
        RecipientBankAccount: Code[20];
    begin
        // 1.4
        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        COMMIT();

        // Post-Setup
        LineNo := GenJournalLine."Line No.";
        RecipientBankAccount := GenJournalLine."Recipient Bank Account";

        // Pre-Exercise
        PaymentJournal.OPENEDIT();
        PaymentJournal.CurrentJnlBatchName.SETVALUE(GenJournalBatch.Name);
        PaymentJournal."Recipient Bank Account".ACTIVATE();
        PaymentJournal."Recipient Bank Account".ASSERTEQUALS(RecipientBankAccount);

        // Exercise
        PaymentJournal."Recipient Bank Account".SETVALUE('');
        PaymentJournal.OK().INVOKE();

        // Verify
        GenJournalLine.GET(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, LineNo);
        GenJournalLine.TESTFIELD("Recipient Bank Account", '');
    end;

    [Test]
    procedure ClearCustomerPreferredBankAcc();
    var
        Customer: Record Customer;
        CustomerCard: TestPage "Customer Card";
        CustomerNo: Code[20];
    begin
        // 1.2
        // Pre-Setup
        LibraryPaymentExportDK.CreateCustWithBankAccount(Customer);
        CustomerNo := Customer."No.";

        // Setup
        CustomerCard.OPENEDIT();
        CustomerCard.GOTORECORD(Customer);

        // Exercise
        CustomerCard."Preferred Bank Account Code".SETVALUE('');
        CustomerCard.OK().INVOKE();

        // Pre-Verify
        Customer.GET(CustomerNo);

        // Verify
        Customer.TESTFIELD("Preferred Bank Account Code", '');
    end;

    [Test]
    procedure ClearVendorPreferredBankAcc();
    var
        Vendor: Record Vendor;
        VendorCard: TestPage "Vendor Card";
        VendorNo: Code[20];
    begin
        // 1.2
        // Pre-Setup
        LibraryPaymentExportDK.CreateVendorWithBankAccount(Vendor);
        VendorNo := Vendor."No.";

        // Setup
        VendorCard.OPENEDIT();
        VendorCard.GOTORECORD(Vendor);

        // Exercise
        VendorCard."Preferred Bank Account Code".SETVALUE('');
        VendorCard.OK().INVOKE();

        // Pre-Verify
        Vendor.GET(VendorNo);

        // Verify
        Vendor.TESTFIELD("Preferred Bank Account Code", '');
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerNo')]
    procedure ExportAgainCustLedgerEntryNo();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
        CustomerNo: Code[20];
        DocumentNo: Code[20];
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        CustomerNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";

        // Setup
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        FindOpenCustomerLedgerEntry(CustLedgerEntry, CustomerNo, DocumentNo);
        CustLedgerEntry."Exported to Payment File" := TRUE;
        CustLedgerEntry.MODIFY();

        // Pre-Exercise
        CustomerLedgerEntries.OPENVIEW();
        CustomerLedgerEntries.GOTORECORD(CustLedgerEntry);

        // Exercise
        CustomerLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        // No export occurs. The confirm handler will click 'No'.
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerYes')]
    procedure ExportAgainCustLedgerEntryYes();
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
        CustomerNo: Code[20];
        DocumentNo: Code[20];
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        CustomerNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";

        // Setup
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        FindOpenCustomerLedgerEntry(CustLedgerEntry, CustomerNo, DocumentNo);
        CustLedgerEntry."Recipient Bank Account" := '';
        CustLedgerEntry."Exported to Payment File" := TRUE;
        CustLedgerEntry.MODIFY();

        // Pre-Exercise
        CustomerLedgerEntries.OPENVIEW();
        CustomerLedgerEntries.GOTORECORD(CustLedgerEntry);

        // Exercis: Export fails. The Open-Save-Cancel dialog cannot be handled by Page Testability.
        ASSERTERROR CustomerLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(RecipientBankAccMissingErr, CustLedgerEntry.FIELDCAPTION("Recipient Bank Account"), CustLedgerEntry.TABLECAPTION()));
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerNo')]
    procedure ExportAgainGenJnlLineNo();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentJournal: TestPage "Payment Journal";
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Setup
        GenJournalLine."Exported to Payment File" := TRUE;
        GenJournalLine.MODIFY();

        // Pre-Exercise
        PaymentJournal.OPENEDIT();
        PaymentJournal.CurrentJnlBatchName.SETVALUE(GenJournalBatch.Name);
        PaymentJournal."Exported to Payment File".ACTIVATE();

        // Exercise
        PaymentJournal.ExportPaymentsToFile.INVOKE();

        // Verify
        // No export occurs. The confirm handler will click 'No'.
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerYes')]
    procedure ExportAgainGenJnlLineYes();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentJournal: TestPage "Payment Journal";
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Setup
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine."Exported to Payment File" := TRUE;
        GenJournalLine.MODIFY();

        // Pre-Exercise
        PaymentJournal.OPENEDIT();
        PaymentJournal.CurrentJnlBatchName.SETVALUE(GenJournalBatch.Name);
        PaymentJournal."Exported to Payment File".ACTIVATE();

        // Exercise:
        ASSERTERROR PaymentJournal.ExportPaymentsToFile.INVOKE();

        // Verify
        Assert.ExpectedError(HasErrorsErr);
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerNo')]
    procedure ExportAgainVendorLedgerEntryNo();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
        DocumentNo: Code[20];
        VendorNo: Code[20];
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        VendorNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";

        // Setup
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        FindOpenVendorLedgerEntry(VendorLedgerEntry, VendorNo, DocumentNo);
        VendorLedgerEntry."Exported to Payment File" := TRUE;
        VendorLedgerEntry.MODIFY();

        // Pre-Exercise
        VendorLedgerEntries.OPENVIEW();
        VendorLedgerEntries.GOTORECORD(VendorLedgerEntry);

        // Exercise
        VendorLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        // No export occurs. The confirm handler will click 'No'.
    end;

    [Test]
    [HandlerFunctions('ExportAgainConfirmHandlerYes')]
    procedure ExportAgainVendorLedgerEntryYes();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
        DocumentNo: Code[20];
        VendorNo: Code[20];
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);
        VendorNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";

        // Setup
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        FindOpenVendorLedgerEntry(VendorLedgerEntry, VendorNo, DocumentNo);
        VendorLedgerEntry."Recipient Bank Account" := '';
        VendorLedgerEntry."Exported to Payment File" := TRUE;
        VendorLedgerEntry.MODIFY();

        // Pre-Exercise
        VendorLedgerEntries.OPENVIEW();
        VendorLedgerEntries.GOTORECORD(VendorLedgerEntry);

        // Exercis: Export fails. The Open-Save-Cancel dialog cannot be handled by Page Testability.
        ASSERTERROR VendorLedgerEntries.ExportPaymentsToFile.INVOKE();

        // Verify
        Assert.ExpectedError(
          STRSUBSTNO(EmptyPaymentDetailsErr,
            VendorLedgerEntry.FIELDCAPTION("Recipient Bank Account"), VendorLedgerEntry.FIELDCAPTION("Creditor No."),
            VendorLedgerEntry.FIELDCAPTION(GiroAccNo)));
    end;

    [Test]
    procedure ExportMultiplePmtJnlLines();
    var
        Vendor: Record Vendor;
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalBatchExport: Record "Gen. Journal Batch";
        GenJnlLineExport: Record "Gen. Journal Line";
        GenJnlLineExport2: Record "Gen. Journal Line";
        VendorLedgerEntry1: Record "Vendor Ledger Entry";
        VendorLedgerEntry2: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        PmtGenJournalLine1: Record "Gen. Journal Line";
        PmtGenJournalLine2: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreateVendorWithBankAccount(Vendor);
        LibraryPaymentExportDK.AddPaymentTypeInfoToVendor(Vendor, PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        Vendor.VALIDATE("Creditor No.", '');
        Vendor.VALIDATE(GiroAccNo, '');
        Vendor.MODIFY(TRUE);
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);

        PostVendorInvoice(Vendor, GenJournalLine1, GenJournalBatch);
        PostVendorInvoice(Vendor, GenJournalLine2, GenJournalBatch);

        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatchExport, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine1, GenJournalBatchExport, Vendor."No.");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine2, GenJournalBatchExport, Vendor."No.");

        ApplyVendorInvoiceToPmt(VendorLedgerEntry1, GenJournalLine1, PmtGenJournalLine1);
        ApplyVendorInvoiceToPmt(VendorLedgerEntry2, GenJournalLine2, PmtGenJournalLine2);

        // Pre-Exercise
        GenJnlLineExport.SETRANGE("Journal Batch Name", GenJournalBatchExport.Name);
        GenJnlLineExport.SETRANGE("Journal Template Name", GenJournalBatchExport."Journal Template Name");
        GenJnlLineExport.SETRANGE("Line No.", PmtGenJournalLine1."Line No.", PmtGenJournalLine2."Line No.");
        GenJnlLineExport.SETRANGE("Account No.", Vendor."No.");
        GenJnlLineExport.FINDSET();

        GenJnlLineExport2.COPYFILTERS(GenJnlLineExport);
        IF GenJnlLineExport2.FINDSET() THEN
            REPEAT
                IF GenJnlLineExport2."Account Type" = GenJnlLineExport2."Account Type"::"Bank Account" THEN
                    GenJnlLineExport2."Bank Payment Type" := GenJnlLineExport2."Bank Payment Type"::"Electronic Payment";
                IF GenJnlLineExport2."Bal. Account Type" = GenJnlLineExport2."Bal. Account Type"::"Bank Account" THEN
                    GenJnlLineExport2."Bank Payment Type" := GenJnlLineExport2."Bank Payment Type"::"Electronic Payment";
                GenJnlLineExport2.MODIFY();
            UNTIL GenJnlLineExport2.NEXT() = 0;

        // Exercise
        PaymentExportMgt.EnableExportToServerTempFile(TRUE, 'csv');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFile(GenJnlLineExport);

        // Verify
        VendorLedgerEntry1.FIND();
        VendorLedgerEntry1.TESTFIELD("Exported to Payment File", TRUE);
        VendorLedgerEntry2.FIND();
        VendorLedgerEntry2.TESTFIELD("Exported to Payment File", TRUE);
    end;

    [Test]
    procedure SetExportFlagOnAppliedVendorLedgerEntry();
    var
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalBatchExport: Record "Gen. Journal Batch";
        GenJnlLineExport: Record "Gen. Journal Line";
        GenJnlLineExport2: Record "Gen. Journal Line";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PaymentMethod: Record "Payment Method";
        PmtGenJournalLine1: Record "Gen. Journal Line";
        PmtGenJournalLine2: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentExportMgt: Codeunit "Payment Export Mgt";
        PmtExportMgtGenJnlLine: Codeunit "Pmt Export Mgt Gen. Jnl Line";
        DocumentNo: Code[20];
    begin
        // Pre-Setup
        LibraryPaymentExportDK.CreateVendorWithBankAccount(Vendor);
        LibraryPaymentExportDK.AddPaymentTypeInfoToVendor(Vendor, PaymentMethod.PaymentTypeValidation::" ", 'BTD');
        Vendor.VALIDATE("Creditor No.", '');
        Vendor.VALIDATE(GiroAccNo, '');
        Vendor.MODIFY(TRUE);
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);

        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatchExport, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine1, GenJournalBatch, Vendor."No.");
        DocumentNo := PmtGenJournalLine1."Document No.";
        LibraryERM.PostGeneralJnlLine(PmtGenJournalLine1);
        FindOpenVendorLedgerEntry(VendorLedgerEntry, Vendor."No.", DocumentNo);
        VendorLedgerEntry.TESTFIELD("Exported to Payment File", FALSE);
        LibraryPaymentExportDK.CreateVendorPmtJnlLine(PmtGenJournalLine2, GenJournalBatchExport, Vendor."No.");

        // Pre-Exercise
        GenJnlLineExport.SETRANGE("Journal Batch Name", GenJournalBatchExport.Name);
        GenJnlLineExport.SETRANGE("Journal Template Name", GenJournalBatchExport."Journal Template Name");
        GenJnlLineExport.SETRANGE("Line No.", PmtGenJournalLine1."Line No.", PmtGenJournalLine2."Line No.");
        GenJnlLineExport.SETRANGE("Account No.", Vendor."No.");
        GenJnlLineExport.FINDSET();

        GenJnlLineExport2.COPYFILTERS(GenJnlLineExport);
        IF GenJnlLineExport2.FINDSET() THEN
            REPEAT
                IF GenJnlLineExport2."Account Type" = GenJnlLineExport2."Account Type"::"Bank Account" THEN
                    GenJnlLineExport2."Bank Payment Type" := GenJnlLineExport2."Bank Payment Type"::"Electronic Payment";
                IF GenJnlLineExport2."Bal. Account Type" = GenJnlLineExport2."Bal. Account Type"::"Bank Account" THEN
                    GenJnlLineExport2."Bank Payment Type" := GenJnlLineExport2."Bank Payment Type"::"Electronic Payment";
                GenJnlLineExport2.MODIFY();
            UNTIL GenJnlLineExport2.NEXT() = 0;

        // Exercise
        PaymentExportMgt.EnableExportToServerTempFile(TRUE, 'csv');
        PmtExportMgtGenJnlLine.ExportJournalPaymentFile(GenJnlLineExport);

        // Verify
        VendorLedgerEntry.FIND();
        VendorLedgerEntry.TESTFIELD("Exported to Payment File", FALSE);
    end;

    [Test]
    [HandlerFunctions('VendorBankAccountListPageHandler')]
    procedure LookupRecipientBankAccOnPmtJnlLine();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        PaymentJournal: TestPage "Payment Journal";
        LineNo: Integer;
    begin
        // 1.5
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
        GenJournalLine.TESTFIELD("Recipient Bank Account");
    end;

    [Test]
    procedure PostCustPmtJnlLineWithExportDisabled();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        Amount: Decimal;
        CustomerNo: Code[20];
        DocumentNo: Code[20];
    begin
        // 1.6
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        GenJournalBatch.VALIDATE("Allow Payment Export", FALSE);
        GenJournalBatch.MODIFY(TRUE);

        // Setup
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithoutPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Post-Setup
        CustomerNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";
        Amount := GenJournalLine.Amount;

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify
        VerifyCustomerLedgerEntry(CustomerNo, DocumentNo, Amount, '', '');
    end;

    [Test]
    procedure PostCustPmtJnlLineWithExportEnabled();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        Amount: Decimal;
        CustomerNo: Code[20];
        DocumentNo: Code[20];
        MessageToRecipient: Text[140];
        RecipientBankAccount: Code[20];
    begin
        // 1.7
        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateCustPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Post-Setup
        CustomerNo := GenJournalLine."Account No.";
        RecipientBankAccount := GenJournalLine."Recipient Bank Account";
        MessageToRecipient := GenJournalLine."Message to Recipient";
        DocumentNo := GenJournalLine."Document No.";
        Amount := GenJournalLine.Amount;

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify
        VerifyCustomerLedgerEntry(CustomerNo, DocumentNo, Amount, RecipientBankAccount, MessageToRecipient);
    end;

    [Test]
    procedure PostVendPmtJnlLineWithExportDisabled();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        Amount: Decimal;
        DocumentNo: Code[20];
        VendorNo: Code[20];
    begin
        // 1.6
        // Pre-Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        GenJournalBatch.VALIDATE("Allow Payment Export", FALSE);
        GenJournalBatch.MODIFY(TRUE);

        // Setup
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithoutPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Post-Setup
        VendorNo := GenJournalLine."Account No.";
        DocumentNo := GenJournalLine."Document No.";
        Amount := GenJournalLine.Amount;

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify
        VerifyVendorLedgerEntry(VendorNo, DocumentNo, Amount, '', '');
    end;

    [Test]
    procedure PostVendPmtJnlLineWithExportEnabled();
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DataExchDef: Record "Data Exch. Def";
        Amount: Decimal;
        DocumentNo: Code[20];
        MessageToRecipient: Text[140];
        RecipientBankAccount: Code[20];
        VendorNo: Code[20];
    begin
        // 1.7
        // Setup
        LibraryPaymentExportDK.CreatePaymentExportBatch(GenJournalBatch, DataExchDef, XMLPORT::"Export Generic CSV");
        LibraryPaymentExportDK.CreateVendorPmtJnlLineWithPreferredBankAcc(GenJournalLine, GenJournalBatch);

        // Post-Setup
        VendorNo := GenJournalLine."Account No.";
        RecipientBankAccount := GenJournalLine."Recipient Bank Account";
        MessageToRecipient := GenJournalLine."Message to Recipient";
        DocumentNo := GenJournalLine."Document No.";
        Amount := GenJournalLine.Amount;

        // Exercise
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // Verify
        VerifyVendorLedgerEntry(VendorNo, DocumentNo, Amount, RecipientBankAccount, MessageToRecipient);
    end;

    local procedure ApplyVendorInvoiceToPmt(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var GenJournalLine: Record "Gen. Journal Line"; var PmtGenJournalLine: Record "Gen. Journal Line");
    begin
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, GenJournalLine."Document No.");
        VendorLedgerEntry.VALIDATE("Applies-to ID", PmtGenJournalLine."Document No.");
        VendorLedgerEntry.MODIFY();
        PmtGenJournalLine.VALIDATE("Applies-to ID", PmtGenJournalLine."Document No.");
        PmtGenJournalLine.MODIFY();
    end;

    [ModalPageHandler]
    procedure CustomerBankAccountListPageHandler(var CustBankAccountList: TestPage "Customer Bank Account List");
    begin
        CustBankAccountList.LAST();
        CustBankAccountList.OK().INVOKE();
    end;

    [ConfirmHandler]
    procedure ExportAgainConfirmHandlerNo(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := FALSE;
    end;

    [ConfirmHandler]
    procedure ExportAgainConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := TRUE;
    end;

    local procedure FindOpenCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; CustomerNo: Code[20]; DocumentNo: Code[20]);
    begin
        WITH CustLedgerEntry DO BEGIN
            SETRANGE("Customer No.", CustomerNo);
            SETRANGE("Document Type", "Document Type"::Refund);
            SETRANGE("Document No.", DocumentNo);
            SETRANGE(Open, TRUE);
            FINDFIRST();
        END;
    end;

    local procedure FindOpenVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; VendorNo: Code[20]; DocumentNo: Code[20]);
    begin
        WITH VendorLedgerEntry DO BEGIN
            SETRANGE("Vendor No.", VendorNo);
            SETRANGE("Document Type", "Document Type"::Payment);
            SETRANGE("Document No.", DocumentNo);
            SETRANGE(Open, TRUE);
            FINDFIRST();
        END;
    end;

    local procedure PostVendorInvoice(Vendor: Record Vendor; var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch");
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::Invoice, GenJournalLine."Account Type"::Vendor, Vendor."No.", -LibraryRandom.RandDec(100, 2));
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    [ModalPageHandler]
    procedure VendorBankAccountListPageHandler(var VendorBankAccountList: TestPage "Vendor Bank Account List");
    begin
        VendorBankAccountList.LAST();
        VendorBankAccountList.OK().INVOKE();
    end;

    local procedure VerifyCustomerLedgerEntry(CustomerNo: Code[20]; DocumentNo: Code[20]; Amount: Decimal; RecipientBankAccount: Code[20]; MessageToRecipient: Text[140]);
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        FindOpenCustomerLedgerEntry(CustLedgerEntry, CustomerNo, DocumentNo);
        WITH CustLedgerEntry DO BEGIN
            CALCFIELDS(Amount);
            TESTFIELD(Amount, Amount);
            TESTFIELD("Recipient Bank Account", RecipientBankAccount);
            TESTFIELD("Message to Recipient", MessageToRecipient);
            TESTFIELD("Exported to Payment File", FALSE);
        END;
    end;

    local procedure VerifyVendorLedgerEntry(VendorNo: Code[20]; DocumentNo: Code[20]; Amount: Decimal; RecipientBankAccount: Code[20]; MessageToRecipient: Text[140]);
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        FindOpenVendorLedgerEntry(VendorLedgerEntry, VendorNo, DocumentNo);
        WITH VendorLedgerEntry DO BEGIN
            CALCFIELDS(Amount);
            TESTFIELD(Amount, Amount);
            TESTFIELD("Recipient Bank Account", RecipientBankAccount);
            TESTFIELD("Message to Recipient", MessageToRecipient);
            TESTFIELD("Exported to Payment File", FALSE);
        END;
    end;
}



