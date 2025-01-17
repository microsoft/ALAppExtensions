codeunit 148017 "FEC Audit File Export Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [FEC]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        IsInitialized: Boolean;
        MissingStartingDateErr: Label 'Starting Date must have a value in Audit File Export Header';
        MissingEndingDateErr: Label 'Ending Date must have a value in Audit File Export Header';
        NoEntriestoExportErr: Label 'There are no entries to export within the defined filter. The file was not created.';
        UnknownFieldErr: Label 'Unknown field No! Fld #%1.', Comment = '%1 - Field No.';
        WrongFieldErr: Label 'Wrong %1. Fld #%2.', Comment = '%1 - Field Name, %2 - Field No.';
        FilterErr: Label 'Filter function does not work.';
        TwoDocumentNosTxt: Label '%1;%2', Comment = '%1, %2 - Document No.';

    [Test]
    procedure CustOneTransMultiplLedgEntries()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        InsertCustLedgerEntryWithDetail(
            CustLedgerEntry, DetailedCustLedgEntry, CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);
        InsertCustLedgerEntryWithDetail(
            CustLedgerEntry, DetailedCustLedgEntry, CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure CustOneTransMultGLOneLedgEntry()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        GLEntry: Record "G/L Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure CustOneTransOneGLOneLedgEntry()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        GLEntry: Record "G/L Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure CustOneTransMultipleDetailLE()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        GLEntry: Record "G/L Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure MultipleCustOneTransMultipleLE()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);
        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);

        CustLedgerEntry."Customer No." := LibrarySales.CreateCustomerNo();
        CustLedgerEntry.Modify();

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure NoDataToExportErr()
    var
        AuditFileExportHeaderID: Integer;
        StartingDate: Date;
    begin
        Initialize();
        StartingDate := GetStartingDate();
        AuditFileExportHeaderID := RunFECExport('', StartingDate, StartingDate, false);
        VerifyError(AuditFileExportHeaderID, NoEntriestoExportErr);
    end;

    [Test]
    procedure MissingStartingDateErrTest()
    var
        EndingDate: Date;
    begin
        Initialize();
        EndingDate := GetStartingDate();
        asserterror RunFECExport('', 0D, EndingDate, false);
        Assert.ExpectedError(MissingStartingDateErr);
    end;

    [Test]
    procedure MissingEndingDateErrTest()
    var
        StartingDate: Date;
    begin
        Initialize();
        StartingDate := GetStartingDate();
        asserterror RunFECExport('', StartingDate, 0D, false);
        Assert.ExpectedError(MissingEndingDateErr);
    end;

    [Test]
    procedure BlankCustomerInLedgEntry()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        CustomerPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());

        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);
        CustLedgerEntry.Validate("Customer No.", '');
        CustLedgerEntry.Validate("Customer Name", '');
        CustLedgerEntry.Modify(true);

        VerifyGetLedgerEntryDataForCustVend_Customer(GLEntry."Transaction No.", CustLedgerEntry);

        // teardown
        DeleteCustomerEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure VendOneTransMultiplLedgEntries()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");

        InsertVendorLedgerEntryWithDetail(
            VendorLedgerEntry, DetailedVendorLedgEntry, VendorPostingGroup.Code, GLEntry."Transaction No.", 0);
        InsertVendorLedgerEntryWithDetail(
            VendorLedgerEntry, DetailedVendorLedgEntry, VendorPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure VendOneTransMultGLOneLedgEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLEntry: Record "G/L Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");
        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");

        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure VendOneTransOneGLOneLedgEntry()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLEntry: Record "G/L Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");

        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure VendOneTransMultipleDetailLE()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        GLEntry: Record "G/L Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        PayRecAccount: Code[20];
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();
        PayRecAccount := VendorPostingGroup."Payables Account";

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, PayRecAccount);

        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure BankGLEntryFieldsMapping()
    var
        BankAccount: Record "Bank Account";
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 360632] Export G/L Entries - Tax Audit for document related to bank account
        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Gen. Journal Line is posted for Bank Account
        CreateAndPostBankGenJnlLine(BankAccount, "Gen. Journal Account Type"::"Bank Account", StartingDate);

        // [WHEN] Export Tax Audit report
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Fields 7 CompAuxNume and 8 CompAuxLib are exported as Bank Account's number and name respectively for Bank Account Posting G/L Account
        // [THEN] All non-posting accounts have fields 7 CompAuxNume and 8 CompAuxLib with blank values
        GLRegister.FindLast();
        VerifyExportGLEntriesReport(GLRegister, AuditFile, '', BankAccount."No.", BankAccount.Name);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure CustomerGLEntryFieldsMapping()
    var
        Customer: Record Customer;
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 360632] Export G/L Entries - Tax Audit for document related to customer
        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Gen. Journal Line is posted for Customer
        CreateAndPostCustomGenJnlLine(Customer, "Gen. Journal Account Type"::Customer, StartingDate);

        // [WHEN] Export Tax Audit report
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Fields 7 CompAuxNume and 8 CompAuxLib are exported as Customer's number and name respectively for Customer Receivables Account
        // [THEN] All non-posting accounts have fields 7 CompAuxNume and 8 CompAuxLib with blank values
        GLRegister.FindLast();
        VerifyExportGLEntriesReport(GLRegister, AuditFile, '', Customer."No.", Customer.Name);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VendorGLEntryFieldsMapping()
    var
        Vendor: Record Vendor;
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 360632] Export G/L Entries - Tax Audit for document related to vendor
        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Gen. Journal Line is posted for Vendor
        CreateAndPostVendorGenJnlLine(Vendor, "Gen. Journal Document Type"::Invoice, StartingDate);

        // [WHEN] Export Tax Audit report
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Fields 7 CompAuxNume and 8 CompAuxLib are exported as Vendor's number and name respectively for Vendor Payables Account
        // [THEN] All non-posting accounts have fields 7 CompAuxNume and 8 CompAuxLib with blank values
        GLRegister.FindLast();
        VerifyExportGLEntriesReport(GLRegister, AuditFile, '', Vendor."No.", Vendor.Name);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure FilterAccountOnTaxAuditReport()
    var
        AuditFile: Record "Audit File";
        GLAccountNo: array[2] of Code[20];
    begin
        // Verify Filter Account Function On Tax Audit Report
        Initialize();

        // [GIVEN] Create and post General Journl Line.
        GLAccountNo[1] := CreateAndPostGLGenJnlLine("Gen. Journal Account Type"::"G/L Account", WorkDate());
        GLAccountNo[2] := CreateAndPostGLGenJnlLine("Gen. Journal Account Type"::"G/L Account", WorkDate());

        // [WHEN] Generate Tax Audit Report.
        RunFECExport(AuditFile, GLAccountNo[2], WorkDate(), WorkDate(), false);

        // [THEN] Verify G/L Account No. Filter work correctly for G/L Entry on Tax Audit Report.
        VerifyExportGLEntriesReportWithGLAccNoFilter(AuditFile, GLAccountNo[2]);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VerifyDebitCredit2DecimalSymbolsVendor()
    var
        Vendor: Record Vendor;
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // Verify Debit/Credit in exported file have always 2 decimal symbols (Vendor)
        Initialize();
        LibraryPurchase.CreateVendor(Vendor);
        VerifyExportGLEntriesReport2DecimalSymbols(
          GenJnlLine."Account Type"::Vendor, Vendor."No.", Vendor.Name, -1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VerifyDebitCredit2DecimalSymbolsCustomer()
    var
        Customer: Record Customer;
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // Verify Debit/Credit in exported file have always 2 decimal symbols (Customer)
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        VerifyExportGLEntriesReport2DecimalSymbols(
          GenJnlLine."Account Type"::Customer, Customer."No.", Customer.Name, 1);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VerifyDebitCredit2DecimalSymbolsBankAccount()
    var
        BankAccount: Record "Bank Account";
        GenJnlLine: Record "Gen. Journal Line";
    begin
        // Verify Debit/Credit in exported file have always 2 decimal symbols (Bank Account)
        Initialize();
        CreateBankAccount(BankAccount);
        VerifyExportGLEntriesReport2DecimalSymbols(
          GenJnlLine."Account Type"::"Bank Account", BankAccount."No.", BankAccount.Name, 1);
    end;

    [Test]
    procedure BlankVendorInLedgerEntry()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();
        InsertGLentry(GLEntry, GetNonRecPayAccountNo());

        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);
        VendorLedgerEntry.Validate("Vendor No.", '');
        VendorLedgerEntry.Validate("Vendor Name", '');
        VendorLedgerEntry.Modify(true);

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure MultipleVendOneTransMultiplLE()
    var
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        GLEntry: Record "G/L Entry";
    begin
        // [FEATURE] [UT]
        Initialize();
        VendorPostingGroup.FindFirst();

        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");
        InsertGLentry(GLEntry, GetNonRecPayAccountNo());

        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);
        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", 0);

        VendorLedgerEntry."Vendor No." := LibraryPurchase.CreateVendorNo();
        VendorLedgerEntry.Modify();

        VerifyGetLedgerEntryDataForCustVend_Vendor(GLEntry."Transaction No.", VendorLedgerEntry);

        // teardown
        DeleteVendorEntries(GLEntry."Transaction No.");
    end;

    [Test]
    procedure VerifySIRENCode()
    var
        CompanyInformation: Record "Company Information";
        SIREN: Integer;
    begin
        // [SCENARIO 362572] "Company Information".GetSIREN returns first 9 digits from CompanyInformation."Registration No."
        // [FEATURE] [UT] [SIREN]
        SIREN := LibraryRandom.RandIntInRange(100000000, 999999999);
        CompanyInformation."Registration No." :=
          CopyStr(
            Format(SIREN) + LibraryUtility.GenerateRandomText(MaxStrLen(CompanyInformation."Registration No.") - 9),
            1,
            MaxStrLen(CompanyInformation."Registration No."));
        Assert.AreEqual(SIREN, CompanyInformation.GetSIREN(), CompanyInformation.FieldCaption("Registration No."));
    end;

    [Test]
    procedure TestCompanyInfoGetPartyID()
    var
        CompanyInformation: Record "Company Information";
    begin
        // [SCENARIO 362572] "Company Information".GetPartyID returns 'AB0598765432109876' in case of "Country/Region Code" = 'AB' and "Registration No." = '98765432109876'
        // [FEATURE] [UT] [SIREN]
        CompanyInformation."Country/Region Code" := 'AB';
        CompanyInformation."Registration No." := '98765432109876';
        Assert.AreEqual(
          CompanyInformation."Country/Region Code" + '05' + CompanyInformation."Registration No.", CompanyInformation.GetPartyID(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure SalesInvoiceAppliedPayment()
    var
        Customer: Record Customer;
        GenJournalBatch: Record "Gen. Journal Batch";
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
        InvoiceDocNo: Code[20];
        PaymentDocNo: Code[20];
        Amount: Decimal;
    begin
        // [Scenario] Report exports one customer payment applied to one customer invoice
        // [GIVEN] A posted Sales Invoice and Payment applied to that Invoice
        Initialize();
        StartingDate := GetStartingDate();
        LibrarySales.CreateCustomer(Customer);
        CreateGenJournalBatch(GenJournalBatch);
        Amount := LibraryRandom.RandDec(100, 2);

        // invoice
        InvoiceDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::Customer,
            Customer."No.", StartingDate, Amount);
        // payment
        PaymentDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Customer,
            Customer."No.", StartingDate, -Amount);
        ApplyAndPostGenJournalLine(PaymentDocNo, "Gen. Journal Document Type"::Invoice, InvoiceDocNo);
        GLRegister.FindLast();

        // [WHEN] Export report Export G/L Entries
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Report contains applied entries and Applied/Closed Date as per spec (fields PieceData, EcritureLib )
        VerifyAppliedEntriesReport(GLRegister, AuditFile, '', PaymentDocNo, "Gen. Journal Document Type"::Invoice, StartingDate);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure PurchaseInvoiceAppliedPayment()
    var
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
        InvoiceDocNo: Code[20];
        PaymentDocNo: Code[20];
        Amount: Decimal;
    begin
        // [Scenario] Report exports one payment applied to one purchase invoice
        // [GIVEN] A posted Purchase Invoice and Payment applied to that Invoice
        Initialize();
        StartingDate := GetStartingDate();
        LibraryPurchase.CreateVendor(Vendor);
        CreateGenJournalBatch(GenJournalBatch);
        Amount := LibraryRandom.RandDec(100, 2);

        // invoice
        InvoiceDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::Vendor,
            Vendor."No.", StartingDate, -Amount);
        // payment
        PaymentDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Vendor,
            Vendor."No.", StartingDate, Amount);
        ApplyAndPostGenJournalLine(PaymentDocNo, "Gen. Journal Document Type"::Invoice, InvoiceDocNo);
        GLRegister.FindLast();

        // [WHEN] Export report Export G/L Entries
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Report contains applied entries and Applied/Closed Date as per spec (fields PieceData, EcritureLib )
        VerifyAppliedEntriesReport(GLRegister, AuditFile, '', PaymentDocNo, "Gen. Journal Document Type"::Invoice, StartingDate);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure BankInvoiceAppliedPayment()
    var
        BankAccount: Record "Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
        InvoiceDocNo: Code[20];
        PaymentDocNo: Code[20];
        Amount: Decimal;
    begin
        // [Scenario] Report exports one bank payment applied to one bank invoice
        // [GIVEN] A Bank Account Ledger Entry and Payment applied to that Bank Account Ledger Entry
        Initialize();
        StartingDate := GetStartingDate();

        CreateBankAccount(BankAccount);
        CreateGenJournalBatch(GenJournalBatch);
        Amount := LibraryRandom.RandDec(100, 2);

        // invoice
        InvoiceDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::"Bank Account",
            BankAccount."No.", StartingDate, -Amount);
        // payment
        PaymentDocNo :=
          CreateGenJournalLine(GenJournalBatch, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::"Bank Account",
            BankAccount."No.", StartingDate, Amount);
        ApplyAndPostGenJournalLine(PaymentDocNo, "Gen. Journal Document Type"::Invoice, InvoiceDocNo);
        GLRegister.FindLast();

        // [WHEN] Export report Export G/L Entries
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] Report contains applied entries and Applied/Closed Date as per spec (fields PieceData, EcritureLib )
        VerifyAppliedEntriesReport(GLRegister, AuditFile, '', PaymentDocNo, "Gen. Journal Document Type"::Invoice, StartingDate);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure CustOneTransMultiplLedgEntriesEscritureLetField()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GLEntry: Record "G/L Entry";
        InvoiceCustLedgerEntry: array[2] of Record "Cust. Ledger Entry";
        FCYAmount: Text[250];
        PartyNo: Code[20];
        PartyName: Text[100];
        CurrencyCode: Code[10];
        AppliedDocNo: Text;
        AppliedDate: Date;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 201283] Apply several sales invoices in the same Payment Slip in the French version
        SetupFEC();
        CustomerPostingGroup.FindFirst();

        InsertCustLedgerEntry(InvoiceCustLedgerEntry[1], '', GetTransactionNo(), LibraryUtility.GenerateGUID());
        InsertCustLedgerEntry(InvoiceCustLedgerEntry[2], '', GetTransactionNo(), LibraryUtility.GenerateGUID());

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, CustomerPostingGroup."Receivables Account");

        // [GIVEN] Two payments applied to two sales different invoices in one transaction
        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", InvoiceCustLedgerEntry[1]."Entry No.");
        InsertCustLedgerEntryWithDetail(CustLedgerEntry, DetailedCustLedgEntry,
          CustomerPostingGroup.Code, GLEntry."Transaction No.", InvoiceCustLedgerEntry[2]."Entry No.");

        // [WHEN] Run GetLedgerEntryDataForCustVend() of "Generate File FEC" codeunit.
        RunGetLedgerEntryDataForCustVend(
            GLEntry."Posting Date", GLEntry."Posting Date" + 1, GLEntry."Transaction No.", "Gen. Journal Source Type"::Customer,
            PartyNo, PartyName, FCYAmount, CurrencyCode, AppliedDocNo, AppliedDate);

        // [THEN] Two invoices are joined by ";" are in output
        Assert.AreEqual(
          StrSubstNo(TwoDocumentNosTxt, InvoiceCustLedgerEntry[1]."Document No.", InvoiceCustLedgerEntry[2]."Document No."), AppliedDocNo, '');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure VendOneTransMultiplLedgEntriesEscritureLetField()
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        GLEntry: Record "G/L Entry";
        InvoiceVendorLedgerEntry: array[2] of Record "Vendor Ledger Entry";
        FCYAmount: Text[250];
        PartyNo: Code[20];
        PartyName: Text[100];
        CurrencyCode: Code[10];
        AppliedDocNo: Text;
        AppliedDate: Date;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 201283] Apply several purchase invoices in the same Payment Slip in the French version
        SetupFEC();
        VendorPostingGroup.FindFirst();

        InsertVendorLedgerEntry(InvoiceVendorLedgerEntry[1], '', GetTransactionNo(), LibraryUtility.GenerateGUID());
        InsertVendorLedgerEntry(InvoiceVendorLedgerEntry[2], '', GetTransactionNo(), LibraryUtility.GenerateGUID());

        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        InsertGLentry(GLEntry, VendorPostingGroup."Payables Account");

        // [GIVEN] Two payments applied to two different purchase invoices in one transaction
        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", InvoiceVendorLedgerEntry[1]."Entry No.");
        InsertVendorLedgerEntryWithDetail(VendorLedgerEntry, DetailedVendorLedgEntry,
          VendorPostingGroup.Code, GLEntry."Transaction No.", InvoiceVendorLedgerEntry[2]."Entry No.");

        // [WHEN] Run GetLedgerEntryDataForCustVend() of "Generate File FEC" codeunit.
        RunGetLedgerEntryDataForCustVend(
            GLEntry."Posting Date", GLEntry."Posting Date" + 1, GLEntry."Transaction No.", "Gen. Journal Source Type"::Vendor,
            PartyNo, PartyName, FCYAmount, CurrencyCode, AppliedDocNo, AppliedDate);

        // [THEN] Two invoices are joined by ";" are in output
        Assert.AreEqual(
          StrSubstNo(TwoDocumentNosTxt, InvoiceVendorLedgerEntry[1]."Document No.", InvoiceVendorLedgerEntry[2]."Document No."), AppliedDocNo, '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ErrorOnExportGLEntriesWithOnlyZeroAmounts()
    var
        GLEntry: Record "G/L Entry";
        AuditFileExportHeaderID: Integer;
    begin
        // [SCENARIO 206886] "There are no entries to export within the defined filter. The file was not created." error appears when export Audit File in FEC format if there are only zero amount G/L Entries
        Initialize();

        // [GIVEN] G/L Entry with zero Amount and "G/L Account" = "Acc"
        InsertGLentry(GLEntry, GetNonRecPayAccountNo());
        GLEntry.Amount := 0;
        GlEntry.Modify();
        Commit();

        // [WHEN] Export Audit File in FEC format for G/L Account = "Acc".
        AuditFileExportHeaderID := RunFECExport(GLEntry."G/L Account No.", GLEntry."Posting Date", GLEntry."Posting Date", false);

        // [THEN] "There are no entries to export within the defined filter. The file was not created." error appears.
        VerifyError(AuditFileExportHeaderID, NoEntriestoExportErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExcludeZeroAmountsFromTestExportGLEntries()
    var
        AuditFile: Record "Audit File";
        GLAccountNo: array[2] of Code[20];
    begin
        // [SCENARIO 206886] The General Ledger Entries with zero amount should be excluded from the Audit File in FEC format.
        Initialize();

        // [GIVEN] G/L Entry with zero Amount and "G/L Account" = "Acc1"
        GLAccountNo[1] := CreateAndPostGLGenJnlLine("Gen. Journal Account Type"::"G/L Account", WorkDate());
        SetZeroAmountToGLEntry(GLAccountNo[1]);

        // [GIVEN] G/L Entry with non-zero Amount and "G/L Account" = "Acc2";
        GLAccountNo[2] := CreateAndPostGLGenJnlLine("Gen. Journal Account Type"::"G/L Account", WorkDate());

        // [WHEN] Export Audit File in FEC format for G/L Accounts "Acc1" and "Acc2".
        RunFECExport(AuditFile, GLAccountNo[1] + '..' + GLAccountNo[2], WorkDate(), WorkDate(), false);

        // [THEN] Then only line with non-zero Amount is exported
        VerifyExportGLEntriesReportWithGLAccNoFilter(AuditFile, GLAccountNo[2]);
    end;

    [Test]
    procedure CustomerAndVendorInOneTransaction()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        TransactionNo: Integer;
    begin
        // [FEATURE] [UT]
        // [SCENARIO 263234] GenerateFileFEC.GetLedgerEntryDataForCustVend() returns Customer\Vendor information
        // [SCENARIO 263234] using Customer\Vendor SoruceType for the same Transaction No.
        Initialize();
        TransactionNo := GetTransactionNo();

        // [GIVEN] Customer and Vendor ledger entries having the same Transaction No.
        CreateSingleCustomerEntry(CustLedgerEntry, TransactionNo);
        CreateSingleVendorEntry(VendorLedgerEntry, TransactionNo);

        // [WHEN] Run function GenerateFileFEC.GetLedgerEntryDataForCustVend() using SourceType = Customer
        // [THEN] Customer information has been returned
        VerifyGetLedgerEntryDataForCustVend_Customer(TransactionNo, CustLedgerEntry);
        VerifyGetLedgerEntryDataForCustVend_Vendor(TransactionNo, VendorLedgerEntry);

        // Teardown
        DeleteCustomerEntries(TransactionNo);
        DeleteVendorEntries(TransactionNo);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerAndVendorInOneTransaction()
    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        AuditFile: Record "Audit File";
        InStream: InStream;
        PostingDate: Date;
        LineToRead: Text;
        TransactionNo: Integer;
    begin
        // [FEATURE] [Customer] [Vendor]
        // [SCENARIO 263234] Export Audit File in FEC format in case of Customer and Vendor entries for the same Transaction No.
        Initialize();
        TransactionNo := GetTransactionNo();
        PostingDate := LibraryRandom.RandDateFromInRange(WorkDate(), 10, 20);

        // [GIVEN] Customer and Vendor ledger entries having the same Transaction No.
        CreatePostCustVendOneTransactionGenJnlLine(Customer, Vendor, PostingDate);

        // [WHEN] Export Audit File in FEC format.
        RunFECExport(AuditFile, '', PostingDate, PostingDate, false);

        // [THEN] The first line has customer information
        // [THEN] The second line has vendor information
        CreateReadStream(InStream, AuditFile);
        InStream.ReadText(LineToRead); // skip header line
        VerifyFilePartyNoAndName(InStream, Customer."No.", Customer.Name);
        VerifyFilePartyNoAndName(InStream, Vendor."No.", Vendor.Name);

        // Teardown
        DeleteCustomerEntries(TransactionNo);
        DeleteVendorEntries(TransactionNo);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportMultiClientsTransaction()
    var
        Customer: array[2] of Record Customer;
        AuditFile: Record "Audit File";
        InStream: InStream;
        PostingDate: Date;
        LineToRead: Text;
        TransactionNo: Integer;
    begin
        // [FEATURE] [Customer]
        // [SCENARIO 263234] Export REP 10885 ExportGLEntriesTaxAudit in case of two Customer entries for the same Transaction No.
        Initialize();
        TransactionNo := GetTransactionNo();
        PostingDate := LibraryRandom.RandDateFromInRange(WorkDate(), 10, 20);

        // [GIVEN] Two customers "C1" and "C2" ledger entries having the same Transaction No.
        CreatePostCustCustOneTransactionGenJnlLine(Customer, PostingDate);

        // [WHEN] Export Audit File in FEC format.
        RunFECExport(AuditFile, '', PostingDate, PostingDate, false);

        // [THEN] The first line has "C1" customer information
        // [THEN] The second line has "C2" customer information
        CreateReadStream(InStream, AuditFile);
        InStream.ReadText(LineToRead); // skip header line
        VerifyFilePartyNoAndName(InStream, Customer[1]."No.", Customer[1].Name);
        VerifyFilePartyNoAndName(InStream, Customer[2]."No.", Customer[2].Name);

        // Teardown
        DeleteCustomerEntries(TransactionNo);
        DeleteVendorEntries(TransactionNo);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportMultiVendorsTransaction()
    var
        Vendor: array[2] of Record Vendor;
        AuditFile: Record "Audit File";
        InStream: InStream;
        PostingDate: Date;
        LineToRead: Text;
        TransactionNo: Integer;
    begin
        // [FEATURE] [Vendor]
        // [SCENARIO 263234] Export REP 10885 ExportGLEntriesTaxAudit in case of two Vendor entries for the same Transaction No.
        Initialize();
        TransactionNo := GetTransactionNo();
        PostingDate := LibraryRandom.RandDateFromInRange(WorkDate(), 10, 20);

        // [GIVEN] Two vendors "V1" and "V2" ledger entries having the same Transaction No.
        CreatePostVendVendOneTransactionGenJnlLine(Vendor, PostingDate);

        // [WHEN] Export Audit File in FEC format.
        RunFECExport(AuditFile, '', PostingDate, PostingDate, false);

        // [THEN] The first line has "V1" vendor information
        // [THEN] The second line has "V2" vendor information
        CreateReadStream(InStream, AuditFile);
        InStream.ReadText(LineToRead); // skip header line
        VerifyFilePartyNoAndName(InStream, Vendor[1]."No.", Vendor[1].Name);
        VerifyFilePartyNoAndName(InStream, Vendor[2]."No.", Vendor[2].Name);

        // Teardown
        DeleteCustomerEntries(TransactionNo);
        DeleteVendorEntries(TransactionNo);
    end;

    [Test]
    procedure DetailedBalanceOnGLAccountCard()
    var
        GLAccount: Record "G/L Account";
        GLAccountCard: TestPage "G/L Account Card";
    begin
        // [FEATURE] [UI] [UT] [Detailed Balance]
        // [SCENARIO 288107] 'Detailed Balance' field on G/L Account card is accessible and editable
        LibraryApplicationArea.EnableFoundationSetup();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccountCard.OpenEdit();
        GLAccountCard.Filter.SetFilter("No.", GLAccount."No.");
        Assert.IsTrue(GLAccountCard."Detailed Balance".Enabled(), '');
        Assert.IsTrue(GLAccountCard."Detailed Balance".Editable(), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedAndTotalBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        CustomerNo: array[4] of Code[20];
        LineToRead: Text;
        Amount: array[4] of Decimal;
        i: Integer;
    begin
        // [FEATURE] [Detailed Balance] [Sales]
        // [SCENARIO 288107] Export customer opening balance for G/L accounts with detailed balance and total balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust1" of Customer Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2018
        // [GIVEN] Customer "Cust2" of Customer Posting Group with "GLAcc1" has entry of amount 200 on 31.12.2018
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        CustomerNo[1] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo1));
        CustomerNo[2] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo1));

        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = No
        // [GIVEN] Customer "Cust3" of Customer Posting Group with "GLAcc2" has entry of amount 100 on 31.12.2018
        // [GIVEN] Customer "Cust4" of Customer Posting Group with "GLAcc2" has entry of amount 300 on 31.12.2018
        GLAccountNo2 := LibraryERM.CreateGLAccountNo();
        CustomerNo[3] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo2));
        CustomerNo[4] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo2));

        for i := 1 to ArrayLen(CustomerNo) do
            Amount[i] := CreatePostCustGenJnlLineOnDate(CustomerNo[i], '', WorkDate() - 1);

        // [GIVEN] An entry for "Cust4" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo[4], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Cust1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, CustomerNo[1], Amount[1], 0);
        // [THEN] Opening balance entry for "GLAcc1" and "Cust2" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, CustomerNo[2], Amount[2], 0);
        // [THEN] Opening balance entry for "GLAcc2" has Amount = 400 (100 + 300)
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, '', Amount[3] + Amount[4], 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceInvoicesLCYAndFCY()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: array[2] of Code[20];
        LineToRead: Text;
        Amount: array[2] of Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Sales] [FCY]
        // [SCENARIO 288107] Export customer opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for entries in local and foreign currency4
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust1" of Customer Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018, local currency
        // [GIVEN] Customer "Cust2" of Customer Posting Group with "GLAcc" has entry of amount 200 USD on 31.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustomerNo[1] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        CustomerNo[2] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        Amount[1] := CreatePostCustGenJnlLineOnDate(CustomerNo[1], '', WorkDate() - 1);
        Amount[2] := CreatePostCustGenJnlLineOnDate(CustomerNo[2], CreateCurrency(), WorkDate() - 1);

        // [GIVEN] An entry for "Cust2" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Cust1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo[1], Amount[1], 0);
        // [THEN] Opening balance entry for "GLAcc1" and "Cust2" has Amount = 300
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo[2], Amount[2], 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceAppliedInvoiceFCY()
    var
        AuditFile: Record "Audit File";
        GenJournalLine: Record "Gen. Journal Line";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
        Amount: Decimal;
        AmountLCY: Decimal;
        ApplnPart: Decimal;
        ExchRate1: Decimal;
        ExchRate2: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Sales] [FCY]
        // [SCENARIO 288107] Export customer opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for applied invoice in foreign currency
        Initialize();
        Amount := 1000; // to avoid rounding errors
        ExchRate1 := 2;
        ExchRate2 := 4;

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust" of Customer Posting Group with "GLAcc" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustomerNo := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(CalcDate('<-CM>', WorkDate()), ExchRate1, ExchRate1);
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, "Gen. Journal Document Type"::Invoice,
            "Gen. Journal Account Type"::Customer, CustomerNo, Amount);
        GenJournalLine.Validate("Posting Date", WorkDate() - 2);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Modify(true);
        AmountLCY := GenJournalLine."Amount (LCY)";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Payment of amount 100 USD is posted on 31.12.2018 with updated exchange rate, 400 in local currency
        LibraryERM.CreateExchangeRate(CurrencyCode, WorkDate() - 1, ExchRate2, ExchRate2);
        ApplnPart := 1 / 2;
        CreateApplyCustomerPayment(CustomerNo, WorkDate() - 1, ApplnPart);

        // [GIVEN] An entry for "Cust" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Cust" has Amount = 200 (300lcy / 2 = 150; + (400 - 300)/2 = 50 realized loss)
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo, AmountLCY - Round(AmountLCY * ApplnPart), 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceTwoAdjustedInvoicesFCYSameAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: array[2] of Code[20];
        CustPostGroup: Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Sales] [FCY]
        // [SCENARIO 288107] Export customer opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 customer invoices with the same receivables account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust1" of Customer Posting Group with "GLAcc" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Customer "Cust2" of Customer Posting Group with "GLAcc" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustPostGroup := CreateCustomerPostingGroup(GLAccountNo);
        CustomerNo[1] := CreateCustomerWithPostingGroup(CustPostGroup);
        CustomerNo[2] := CreateCustomerWithPostingGroup(CustPostGroup);
        CurrencyCode := CreateCurrency();
        CreatePostCustGenJnlLineOnDate(CustomerNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostCustGenJnlLineOnDate(CustomerNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);
        // [GIVEN] An entry for "Cust2" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Cust1" has Amount = 160 (150lcy + 10 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, CustomerNo[1],
          Round(LibraryERM.ConvertCurrency(GetCustInvoiceAmount(CustomerNo[1]), CurrencyCode, '', WorkDate() - 1)), 0);
        // [THEN] Opening balance entry for "GLAcc" and "Cust2" has Amount = 320  (300lcy + 20 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, CustomerNo[2],
          Round(LibraryERM.ConvertCurrency(GetCustInvoiceAmount(CustomerNo[2]), CurrencyCode, '', WorkDate() - 1)), 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceTwoAdjustedInvoicesFCYDiffAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: array[2] of Code[20];
        CustomerNo: array[2] of Code[20];
        CurrencyCode: Code[10];

        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Sales] [FCY]
        // [SCENARIO 288107] Export customer opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 customer invoices with different receivables account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust1" of Customer Posting Group with "GLAcc1" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Customer "Cust2" of Customer Posting Group with "GLAcc2" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo[1] := CreateGLAccountWithDetailedBalance();
        GLAccountNo[2] := CreateGLAccountWithDetailedBalance();
        CustomerNo[1] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo[1]));
        CustomerNo[2] := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo[2]));
        CurrencyCode := CreateCurrency();
        CreatePostCustGenJnlLineOnDate(CustomerNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostCustGenJnlLineOnDate(CustomerNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);

        // [GIVEN] An entry for "Cust2" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo[1] + '|' + GLAccountNo[2], WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Cust1" has Amount = 160 (150lcy + 10 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[1], CustomerNo[1],
          Round(LibraryERM.ConvertCurrency(GetCustInvoiceAmount(CustomerNo[1]), CurrencyCode, '', WorkDate() - 1)), 0);
        // [THEN] Opening balance entry for "GLAcc2" and "Cust2" has Amount = 320  (300lcy + 20 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[2], CustomerNo[2],
          Round(LibraryERM.ConvertCurrency(GetCustInvoiceAmount(CustomerNo[2]), CurrencyCode, '', WorkDate() - 1)), 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceWithSameBalAccount()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: Code[20];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Sales]
        // [SCENARIO 288107] Export customer opening balance for G/L account when entry has the same balance account
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust" of Customer Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        // [GIVEN] Balance account is "GLAcc"
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustomerNo := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        CreateGenJnlLineWithBalAccOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::Customer, CustomerNo,
          GenJournalLine."Bal. Account Type"::"G/L Account", GLAccountNo, WorkDate() - 1, 1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] An entry for "Cust" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Cust" has debit Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo, GenJournalLine."Amount (LCY)", 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceWithBalAccountBankAcc()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: Code[20];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Sales]
        // [SCENARIO 288107] Export customer opening balance for G/L account when entry has the balance account = bank account
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust" of Customer Posting Group with "GLAcc" has payment entry of amount 100 on 31.12.2018
        // [GIVEN] Balance account is Bank Account
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustomerNo := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        CreateGenJnlLineWithBalAccOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Customer, CustomerNo,
          GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), WorkDate() - 1, -1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] An entry for "Cust" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Cust" has credit Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo, 0, -GenJournalLine."Amount (LCY)");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedBalanceWithChangedPostingAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        CustomerNo: Code[20];
        LineToRead: Text;
        Amount1: Decimal;
        Amount2: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Sales]
        // [SCENARIO 288107] Export customer opening balance for G/L account when posting account is changed
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust" of Customer Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2017
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        CustomerNo := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo1));
        Amount1 := CreatePostCustGenJnlLineOnDate(CustomerNo, '', CalcDate('<-1Y>', WorkDate() - 1));

        // [GIVEN] Customer Posting Group has changed posting account to "GLAcc2" with detailed balance in next period
        // [GIVEN] Customer "Cust" has entry of amount 200 on 31.12.2018
        GLAccountNo2 := CreateGLAccountWithDetailedBalance();
        UpdateCustomerPostingAccount(CustomerNo, GLAccountNo2);
        Amount2 := CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate() - 1);

        // [GIVEN] An entry for "Cust" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Cust" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, CustomerNo, Amount1, 0);

        // [THEN] Opening balance entry for "GLAcc2" and "Cust" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, CustomerNo, Amount2, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportCustomerDetailedAndRemainingBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        CustomerNo: Code[20];
        LineToRead: Text;
        Amount: Decimal;
        AmountRem: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Sales]
        // [SCENARIO 288107] Export customer opening balance for G/L accounts with detailed balance and remaining balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Customer "Cust" of Customer Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        CustomerNo := CreateCustomerWithPostingGroup(CreateCustomerPostingGroup(GLAccountNo));
        Amount := CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate() - 1);

        // [GIVEN] Amount 200 is posted for "GLAcc" on 31.12.2018
        AmountRem := LibraryRandom.RandDecInRange(100, 200, 2);
        CreateAndPostGenJnlLine(
            "Gen. Journal Account Type"::"G/L Account", GLAccountNo, "Gen. Journal Document Type"::" ",
            WorkDate() - 1, AmountRem);

        // [GIVEN] An entry for "Cust" on 01.01.2019
        CreatePostCustGenJnlLineOnDate(CustomerNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Cust" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, CustomerNo, Amount, 0);
        // [THEN] Remaining opening balance entry for "GLAcc" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, '', AmountRem, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedAndTotalBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        VendorNo: array[4] of Code[20];
        LineToRead: Text;
        Amount: array[4] of Decimal;
        i: Integer;
    begin
        // [FEATURE] [Detailed Balance] [Purchase]
        // [SCENARIO 288107] Export vendor opening balance for G/L accounts with detailed balance and total balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend1" of Vendor Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2018
        // [GIVEN] Vendor "Vend2" of Vendor Posting Group with "GLAcc1" has entry of amount 200 on 31.12.2018
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        VendorNo[1] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo1));
        VendorNo[2] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo1));

        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = No
        // [GIVEN] Vendor "Vend3" of Vendor Posting Group with "GLAcc2" has entry of amount 100 on 31.12.2018
        // [GIVEN] Vendor "Vend4" of Vendor Posting Group with "GLAcc2" has entry of amount 300 on 31.12.2018
        GLAccountNo2 := LibraryERM.CreateGLAccountNo();
        VendorNo[3] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo2));
        VendorNo[4] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo2));

        for i := 1 to ArrayLen(VendorNo) do
            Amount[i] := CreatePostVendGenJnlLineOnDate(VendorNo[i], '', WorkDate() - 1);

        // [GIVEN] An entry for "Vend4" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo[4], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Vend1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, VendorNo[1], 0, Amount[1]);
        // [THEN] Opening balance entry for "GLAcc1" and "Vend2" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, VendorNo[2], 0, Amount[2]);
        // [THEN] Opening balance entry for "GLAcc2" has Amount = 400 (100 + 300)
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, '', 0, Amount[3] + Amount[4]);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceInvoicesLCYAndFCY()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: array[2] of Code[20];
        LineToRead: Text;
        Amount: array[2] of Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Purchase] [FCY]
        // [SCENARIO 288107] Export vendor opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for entries in local and foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend1" of Vendor Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018, local currency
        // [GIVEN] Vendor "Vend2" of Vendor Posting Group with "GLAcc" has entry of amount 200 USD on 31.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendorNo[1] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        VendorNo[2] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        Amount[1] := CreatePostVendGenJnlLineOnDate(VendorNo[1], '', WorkDate() - 1);
        Amount[2] := CreatePostVendGenJnlLineOnDate(VendorNo[2], CreateCurrency(), WorkDate() - 1);

        // [GIVEN] An entry for "Vend2" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Vend1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo[1], 0, Amount[1]);
        // [THEN] Opening balance entry for "GLAcc1" and "Vend2" has Amount = 300
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo[2], 0, Amount[2]);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceAppliedInvoiceFCY()
    var
        AuditFile: Record "Audit File";
        GenJournalLine: Record "Gen. Journal Line";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
        Amount: Decimal;
        AmountLCY: Decimal;
        ApplnPart: Decimal;
        ExchRate1: Decimal;
        ExchRate2: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Purchase] [FCY]
        // [SCENARIO 288107] Export vendor opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for applied invoice in foreign currency
        Initialize();
        Amount := 1000;     // to avoid rounding errors
        ExchRate1 := 2;
        ExchRate2 := 4;

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend" of Vendor Posting Group with "GLAcc" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendorNo := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(CalcDate('<-CM>', WorkDate()), ExchRate1, ExchRate1);
        LibraryJournals.CreateGenJournalLineWithBatch(
            GenJournalLine, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::Vendor, VendorNo, -Amount);
        GenJournalLine.Validate("Posting Date", WorkDate() - 2);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Modify(true);
        AmountLCY := GenJournalLine."Amount (LCY)";
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] Payment of amount 100 USD is posted on 31.12.2018 with updated exchange rate, 400 in local currency
        LibraryERM.CreateExchangeRate(CurrencyCode, WorkDate() - 1, ExchRate2, ExchRate2);
        ApplnPart := 1 / 2;
        CreateApplyVendorPayment(VendorNo, WorkDate() - 1, ApplnPart);

        // [GIVEN] An entry for "Vend" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Vend" has Amount = 200 (300lcy / 2 = 150; + (400 - 300)/2 = 50 realized loss)
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo, 0, -(AmountLCY - Round(AmountLCY * ApplnPart)));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceTwoAdjustedInvoicesFCYSameAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: array[2] of Code[20];
        VendPostGroup: Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Purchase] [FCY]
        // [SCENARIO 288107] Export vendor opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 vendor invoices with the same payables account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend1" of Vendor Posting Group with "GLAcc" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Vendor "Vend2" of Vendor Posting Group with "GLAcc" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendPostGroup := CreateVendorPostingGroup(GLAccountNo);
        VendorNo[1] := CreateVendorWithPostingGroup(VendPostGroup);
        VendorNo[2] := CreateVendorWithPostingGroup(VendPostGroup);
        CurrencyCode := CreateCurrency();
        CreatePostVendGenJnlLineOnDate(VendorNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostVendGenJnlLineOnDate(VendorNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);
        // [GIVEN] An entry for "Vend2" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Vend1" has Amount = 160 (150lcy + 10 unrealized gains)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, VendorNo[1],
          0, Round(LibraryERM.ConvertCurrency(-GetVendInvoiceAmount(VendorNo[1]), CurrencyCode, '', WorkDate() - 1)));
        // [THEN] Opening balance entry for "GLAcc" and "Vend2" has Amount = 320  (300lcy + 20 unrealized gains)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, VendorNo[2],
          0, Round(LibraryERM.ConvertCurrency(-GetVendInvoiceAmount(VendorNo[2]), CurrencyCode, '', WorkDate() - 1)));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceTwoAdjustedInvoicesFCYDiffAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: array[2] of Code[20];
        VendorNo: array[2] of Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Purchase] [FCY]
        // [SCENARIO 288107] Export vendor opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 vendor invoices with different payables account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend1" of Vendor Posting Group with "GLAcc1" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Vendor "Vend2" of Vendor Posting Group with "GLAcc2" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo[1] := CreateGLAccountWithDetailedBalance();
        GLAccountNo[2] := CreateGLAccountWithDetailedBalance();
        VendorNo[1] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo[1]));
        VendorNo[2] := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo[2]));
        CurrencyCode := CreateCurrency();
        CreatePostVendGenJnlLineOnDate(VendorNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostVendGenJnlLineOnDate(VendorNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);
        // [GIVEN] An entry for "Vend2" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo[1] + '|' + GLAccountNo[2], WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Vend1" has Amount = 160 (150lcy + 10 unrealized gains)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[1], VendorNo[1],
          0, Round(LibraryERM.ConvertCurrency(-GetVendInvoiceAmount(VendorNo[1]), CurrencyCode, '', WorkDate() - 1)));
        // [THEN] Opening balance entry for "GLAcc2" and "Vend2" has Amount = 320  (300lcy + 20 unrealized gains)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[2], VendorNo[2],
          0, Round(LibraryERM.ConvertCurrency(-GetVendInvoiceAmount(VendorNo[2]), CurrencyCode, '', WorkDate() - 1)));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceWithSameBalAccount()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: Code[20];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Purchase]
        // [SCENARIO 288107] Export vendor opening balance for G/L account when entry has the same balance account
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend" of Vendor Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        // [GIVEN] Balance account is "GLAcc"
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendorNo := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        CreateGenJnlLineWithBalAccOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::Vendor, VendorNo,
          GenJournalLine."Bal. Account Type"::"G/L Account", GLAccountNo, WorkDate() - 1, -1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] An entry for "Vend" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Vend" has credit Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo, 0, -GenJournalLine."Amount (LCY)");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceWithBalAccountBankAcc()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: Code[20];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Purchase]
        // [SCENARIO 288107] Export vendor opening balance for G/L account when entry has the balance account = bank account
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend" of Vendor Posting Group with "GLAcc" has payment entry of amount 100 on 31.12.2018
        // [GIVEN] Balance account is Bank Account
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendorNo := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        CreateGenJnlLineWithBalAccOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Payment, "Gen. Journal Account Type"::Vendor, VendorNo,
          GenJournalLine."Bal. Account Type"::"Bank Account", LibraryERM.CreateBankAccountNo(), WorkDate() - 1, 1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] An entry for "Vend" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Vend" has debit Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo, GenJournalLine."Amount (LCY)", 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedBalanceWithChangedPostingAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        VendorNo: Code[20];
        LineToRead: Text;
        Amount1: Decimal;
        Amount2: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Purchase]
        // [SCENARIO 288107] Export vendor opening balance for G/L account when posting account is changed
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend" of Vendor Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2017
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        VendorNo := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo1));
        Amount1 := CreatePostVendGenJnlLineOnDate(VendorNo, '', CalcDate('<-1Y>', WorkDate() - 1));

        // [GIVEN] Vendor Posting Group has changed posting account to "GLAcc2" with detailed balance in next period
        // [GIVEN] Vendor "Vendor" has entry of amount 200 on 31.12.2018
        GLAccountNo2 := CreateGLAccountWithDetailedBalance();
        UpdateVendorPostingAccount(VendorNo, GLAccountNo2);
        Amount2 := CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate() - 1);

        // [GIVEN] An entry for "Vendor" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Vend" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, VendorNo, 0, Amount1);

        // [THEN] Opening balance entry for "GLAcc2" and "Vend" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, VendorNo, 0, Amount2);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportVendorDetailedAndRemainingBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        VendorNo: Code[20];
        LineToRead: Text;
        Amount: Decimal;
        AmountRem: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Purchase]
        // [SCENARIO 288107] Export vendor opening balance for G/L accounts with detailed balance and remaining balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Vendor "Vend" of Vendor Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        VendorNo := CreateVendorWithPostingGroup(CreateVendorPostingGroup(GLAccountNo));
        Amount := CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate() - 1);

        // [GIVEN] Amount 200 is posted for "GLAcc" on 31.12.2018
        AmountRem := LibraryRandom.RandDecInRange(100, 200, 2);
        CreateAndPostGenJnlLine(
            "Gen. Journal Account Type"::"G/L Account", GLAccountNo, "Gen. Journal Document Type"::" ", WorkDate() - 1, AmountRem);

        // [GIVEN] An entry for "Vend" on 01.01.2019
        CreatePostVendGenJnlLineOnDate(VendorNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Vend" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, VendorNo, 0, Amount);
        // [THEN] Remaining opening balance entry for "GLAcc" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, '', AmountRem, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedAndTotalBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        BankAccountNo: array[4] of Code[20];
        LineToRead: Text;
        Amount: array[4] of Decimal;
        i: Integer;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account]
        // [SCENARIO 288107] Export bank account opening balance for G/L accounts with detailed balance and total balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "Bank1" of Bank Account Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2018
        // [GIVEN] Bank Account "Bank2" of Bank Account Posting Group with "GLAcc1" has entry of amount 200 on 31.12.2018
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        BankAccountNo[1] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo1), '');
        BankAccountNo[2] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo1), '');

        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = No
        // [GIVEN] Bank Account "Bank3" of Bank Account Posting Group with "GLAcc2" has entry of amount 100 on 31.12.2018
        // [GIVEN] Bank Account "Bank4" of Bank Account Posting Group with "GLAcc2" has entry of amount 300 on 31.12.2018
        GLAccountNo2 := LibraryERM.CreateGLAccountNo();
        BankAccountNo[3] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo2), '');
        BankAccountNo[4] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo2), '');

        for i := 1 to ArrayLen(BankAccountNo) do
            Amount[i] := CreatePostBankAccGenJnlLineOnDate(BankAccountNo[i], '', WorkDate() - 1);

        // [GIVEN] An entry for "Bank4" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[4], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Bank1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, BankAccountNo[1], Amount[1], 0);
        // [THEN] Opening balance entry for "GLAcc1" and "Bank2" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, BankAccountNo[2], Amount[2], 0);
        // [THEN] Opening balance entry for "GLAcc1" has Amount = 400 (100 + 300)
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, '', Amount[3] + Amount[4], 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedBalanceInvoicesLCYAndFCY()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        BankAccountNo: array[2] of Code[20];
        LineToRead: Text;
        Amount: array[2] of Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account] [FCY]
        // [SCENARIO 288107] Export bank account opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for entries in local and foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "Bank1" of Bank Account Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018, local currency
        // [GIVEN] Bank Account "Bank2" of Bank Account Posting Group with "GLAcc" has entry of amount 200 USD on 31.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        BankAccountNo[1] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo), '');
        BankAccountNo[2] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo), '');
        Amount[1] := CreatePostBankAccGenJnlLineOnDate(BankAccountNo[1], '', WorkDate() - 1);
        Amount[2] := CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], CreateCurrency(), WorkDate() - 1);

        // [GIVEN] An entry for "Bank2" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Bank1" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, BankAccountNo[1], Amount[1], 0);
        // [THEN] Opening balance entry for "GLAcc1" and "Bank2" has Amount = 300
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, BankAccountNo[2], Amount[2], 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedBalanceTwoAdjustedEntriesFCYSameAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        BankAccountNo: array[2] of Code[20];
        BankPostGroup: Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account] [FCY]
        // [SCENARIO 288107] Export bank account opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 bank account entries with the same posting account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "Bank1" of Bank Account Posting Group with "GLAcc" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Bank Account "Bank2" of Bank Account Posting Group with "GLAcc" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        BankPostGroup := CreateBankAccPostingGroup(GLAccountNo);
        CurrencyCode := CreateCurrency();
        BankAccountNo[1] := CreateBankAccWithPostingGroup(BankPostGroup, CurrencyCode);
        BankAccountNo[2] := CreateBankAccWithPostingGroup(BankPostGroup, CurrencyCode);

        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);

        // [GIVEN] An entry for "Bank2" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], CurrencyCode, WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "Bank1" has Amount = 160 (150lcy + 10 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, BankAccountNo[1],
          Round(LibraryERM.ConvertCurrency(GetBankAccInvoiceAmount(BankAccountNo[1]), CurrencyCode, '', WorkDate() - 1)), 0);
        // [THEN] Opening balance entry for "GLAcc" and "Bank2" has Amount = 320  (300lcy + 20 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo, BankAccountNo[2],
          Round(LibraryERM.ConvertCurrency(GetBankAccInvoiceAmount(BankAccountNo[2]), CurrencyCode, '', WorkDate() - 1)), 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedBalanceTwoAdjustedEntriesFCYDiffAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: array[2] of Code[20];
        BankAccountNo: array[2] of Code[20];
        CurrencyCode: Code[10];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account] [FCY]
        // [SCENARIO 288107] Export bank account opening balance for G/L account with detailed balance
        // [SCENARIO 288107] for 2 bank account entries with different posting account in foreign currency
        Initialize();

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] G/L Account "GLAcc2" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "Bank1" of Bank Account Posting Group with "GLAcc1" has entry of amount 100 USD on 30.12.2018, 150 in local currency
        // [GIVEN] Bank Account "Bank2" of Bank Account Posting Group with "GLAcc2" has entry of amount 200 USD on 30.12.2018, 300 in local currency
        GLAccountNo[1] := CreateGLAccountWithDetailedBalance();
        GLAccountNo[2] := CreateGLAccountWithDetailedBalance();
        CurrencyCode := CreateCurrency();
        BankAccountNo[1] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo[1]), CurrencyCode);
        BankAccountNo[2] := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo[2]), CurrencyCode);

        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[1], CurrencyCode, WorkDate() - 2);
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], CurrencyCode, WorkDate() - 2);

        // [GIVEN] Adjusted currency exchange rate on 31.12.2018 with updated exchange rate
        CreateCurrencyExchRate(CurrencyCode, WorkDate() - 1);
        LibraryERM.RunExchRateAdjustmentSimple(CurrencyCode, WorkDate() - 1, WorkDate() - 1);

        // [GIVEN] An entry for "Bank2" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo[2], CurrencyCode, WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo[1] + '|' + GLAccountNo[2], WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "Bank1" has Amount = 160 (150lcy + 10 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[1], BankAccountNo[1],
          Round(LibraryERM.ConvertCurrency(GetBankAccInvoiceAmount(BankAccountNo[1]), CurrencyCode, '', WorkDate() - 1)), 0);
        // [THEN] Opening balance entry for "GLAcc2" and "Bank2" has Amount = 320  (300lcy + 20 unrealized losses)
        VerifyOpeningBalanceEntry(
          iStream, GLAccountNo[2], BankAccountNo[2],
          Round(LibraryERM.ConvertCurrency(GetBankAccInvoiceAmount(BankAccountNo[2]), CurrencyCode, '', WorkDate() - 1)), 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedBalanceWithSameBalAccount()
    var
        GenJournalLine: Record "Gen. Journal Line";
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        BankAccountNo: Code[20];
        LineToRead: Text;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account]
        // [SCENARIO 288107] Export bank account opening balance for G/L account when entry has the same balance account
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "BankAcc" of Bank Account Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        // [GIVEN] Balance account is "GLAcc"
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        BankAccountNo := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo), '');
        CreateGenJnlLineWithBalAccOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice, "Gen. Journal Account Type"::"Bank Account", BankAccountNo,
          GenJournalLine."Bal. Account Type"::"G/L Account", GLAccountNo, WorkDate() - 1, 1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] An entry for "BankAcc" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "BankAcc" has debit Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, BankAccountNo, GenJournalLine."Amount (LCY)", 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedBalanceWithChangedPostingAccount()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo1: Code[20];
        GLAccountNo2: Code[20];
        BankAccountNo: Code[20];
        LineToRead: Text;
        Amount1: Decimal;
        Amount2: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account]
        // [SCENARIO 288107] Export bank account opening balance for G/L account when posting account is changed

        // [GIVEN] G/L Account "GLAcc1" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "BankAcc" of Bank Account Posting Group with "GLAcc1" has entry of amount 100 on 31.12.2017
        GLAccountNo1 := CreateGLAccountWithDetailedBalance();
        BankAccountNo := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo1), '');
        Amount1 := CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', CalcDate('<-1Y>', WorkDate() - 1));

        // [GIVEN] Bank Account Posting Group has changed posting account to "GLAcc2" with detailed balance in next period
        // [GIVEN] Bank Account "Bank Acc" has entry of amount 200 on 31.12.2018
        GLAccountNo2 := CreateGLAccountWithDetailedBalance();
        UpdateBankAccountPostingAccount(BankAccountNo, GLAccountNo2);
        Amount2 := CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', WorkDate() - 1);

        // [GIVEN] An entry for "BankAcc" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc1" and "GLAcc2"
        RunFECExport(AuditFile, GLAccountNo1 + '|' + GLAccountNo2, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc1" and "BankAcc" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo1, BankAccountNo, Amount1, 0);

        // [THEN] Opening balance entry for "GLAcc2" and "BankAcc" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo2, BankAccountNo, Amount2, 0);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure ExportBankAccountDetailedAndRemainingBalance()
    var
        AuditFile: Record "Audit File";
        iStream: InStream;
        GLAccountNo: Code[20];
        BankAccountNo: Code[20];
        LineToRead: Text;
        Amount: Decimal;
        AmountRem: Decimal;
    begin
        // [FEATURE] [Detailed Balance] [Bank Account]
        // [SCENARIO 288107] Export bank account opening balance for G/L accounts with detailed balance and remaining balance
        Initialize();

        // [GIVEN] G/L Account "GLAcc" with "Detailed Balance" = Yes
        // [GIVEN] Bank Account "BankAcc" of Bank Account Posting Group with "GLAcc" has entry of amount 100 on 31.12.2018
        GLAccountNo := CreateGLAccountWithDetailedBalance();
        BankAccountNo := CreateBankAccWithPostingGroup(CreateBankAccPostingGroup(GLAccountNo), '');
        Amount := CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', WorkDate() - 1);

        // [GIVEN] Amount 200 is posted for "GLAcc" on 31.12.2018
        AmountRem := LibraryRandom.RandDecInRange(100, 200, 2);
        CreateAndPostGenJnlLine("Gen. Journal Account Type"::"G/L Account", GLAccountNo, "Gen. Journal Document Type"::" ", WorkDate() - 1, AmountRem);

        // [GIVEN] An entry for "BankAcc" on 01.01.2019
        CreatePostBankAccGenJnlLineOnDate(BankAccountNo, '', WorkDate());

        // [WHEN] Export Audit File in FEC format on 01.01.2019..31.12.2019 for "GLAcc"
        RunFECExport(AuditFile, GLAccountNo, WorkDate(), WorkDate() + 1, true);

        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // read header

        // [THEN] Opening balance entry for "GLAcc" and "BankAcc" has Amount = 100
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, BankAccountNo, Amount, 0);
        // [THEN] Remaining opening balance entry for "GLAcc" has Amount = 200
        VerifyOpeningBalanceEntry(iStream, GLAccountNo, '', AmountRem, 0);
    end;

    [Test]
    procedure ExportGLEntriesEmptyCompanyRegistrationNo()
    var
        AuditFile: Record "Audit File";
        BankAccount: Record "Bank Account";
        CompanyInformation: Record "Company Information";
        StartingDate: Date;
    begin
        // [FEATURE] [Company Information]
        // [SCENARIO 344474] Running "Export G/L Entries - Tax Audit" report with empty Registration No. in Company Information raises error
        Initialize();

        // [GIVEN] Created and posted Bank Gen. Jnl. Entry
        StartingDate := GetStartingDate();
        CreateAndPostBankGenJnlLine(
          BankAccount,
          "Gen. Journal Account Type"::"Bank Account",
          StartingDate);

        // [GIVEN] Set "Registration No." = '' in Company Information
        CompanyInformation.Get();
        CompanyInformation.Validate("Registration No.", '');
        CompanyInformation.Modify();

        // [WHEN] Run export Audit File in FEC format.
        asserterror RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] An error is thrown: "Registration No. must have a value in Company Information: Primary Key=. It cannot be zero or empty."
        Assert.ExpectedTestFieldError(CompanyInformation.FieldCaption("Registration No."), '');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure DefaultSourceCodeUsedToExportGLEntryWithBlankSourceCode()
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        CompanyInformation: Record "Company Information";
        GLAccount: Record "G/L Account";
        SourceCode: Record "Source Code";
        GLEntry: Record "G/L Entry";
        AuditFile: Record "Audit File";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        // [SCENARIO 394832] Stan can specify a "Default Source Code" on the Audit File Export Document page with FEC format selected to use when a G/L Entry has blank source code
        Initialize();

        CompanyInformation.Get();
        CompanyInformation.Validate("Registration No.", Format(LibraryRandom.RandIntInRange(100000000, 999999999)));
        CompanyInformation.Modify();

        // [GIVEN] G/L Entry with blank source code
        LibraryERM.CreateGLAccount(GLAccount);
        CreateAndPostGenJnlLine(
          "Gen. Journal Account Type"::"G/L Account", GLAccount."No.", "Gen. Journal Document Type"::" ", WorkDate(), -LibraryRandom.RandDecInRange(100, 200, 2));
        GLEntry.SetRange("G/L Account No.", GLAccount."No.");
        GLEntry.FindFirst();
        GLEntry."Source Code" := '';
        GLEntry.Modify();

        // [GIVEN] Source Code "X"
        CreateSourceCodeAndDesc(SourceCode);

        // [WHEN] Generate Tax Audit Report.
        GLAccount.SetRecFilter();
        CreateAuditFileExportDoc(
            AuditFileExportHeader, WorkDate(), WorkDate(), false, SourceCode.Code, CopyStr(GLAccount.GetView(), 1, 2048));
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        AuditFile.FindFirst();

        // [THEN] Verify G/L Account No. Filter work correctly for G/L Entry on Tax Audit Report.
        VerifySourceCodeOfExportedGLEntriesReport(AuditFile, SourceCode.Code);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure BankGLEntriesFieldsMappingTransactionNo()
    var
        BankAccount: Record "Bank Account";
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 475846] Export G/L Entries - Tax Audit by transaction number for multiple documents related to bank account

        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Multiple general journal lines are posted for the bank account
        CreateAndPostBankGenJnlLines(BankAccount, "Gen. Journal Account Type"::"Bank Account", StartingDate);

        // [WHEN] Export Tax Audit report with "Use Transaction No." = true
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] "Transaction No." of the G/L entry is used in the exported file
        GLRegister.FindLast();
        VerifyExportGLEntriesByTransNoReport(GLRegister, AuditFile, '', BankAccount."No.", BankAccount.Name);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure CustomerGLEntriesFieldsMapping()
    var
        Customer: Record Customer;
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 475846] Export G/L Entries - Tax Audit by transaction number for multiple documents related to customer

        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Multiple general journal lines are posted for the customer
        CreateAndPostCustomGenJnlLines(Customer, "Gen. Journal Account Type"::Customer, StartingDate);

        // [WHEN] Export Tax Audit report with "Use Transaction No." = true
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] "Transaction No." of the G/L entry is used in the exported file
        GLRegister.FindLast();
        VerifyExportGLEntriesByTransNoReport(GLRegister, AuditFile, '', Customer."No.", Customer.Name);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    procedure VendorGLEntriesFieldsMapping()
    var
        Vendor: Record Vendor;
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        // [SCENARIO 475846] Export G/L Entries - Tax Audit by transaction number for multiple documents related to vendor

        Initialize();
        StartingDate := GetStartingDate();

        // [GIVEN] Multiple general journal lines are posted for the vendor
        CreateAndPostVendorGenJnlLines(Vendor, "Gen. Journal Document Type"::Invoice, StartingDate);

        // [WHEN] Export Tax Audit report with "Use Transaction No." = true
        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // [THEN] "Transaction No." of the G/L entry is used in the exported file
        GLRegister.FindLast();
        VerifyExportGLEntriesByTransNoReport(GLRegister, AuditFile, '', Vendor."No.", Vendor.Name);
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();

        if IsInitialized then
            exit;

        SetupFEC();
        LibrarySetupStorage.Save(Database::"Company Information");
        Commit();

        IsInitialized := true;
    end;

    procedure SetupFEC()
    var
        AuditFileExportSetup: Record "Audit File Export Setup";
        AuditFileExportFormatSetup: Record "Audit File Export Format Setup";
    begin
        AuditFileExportSetup.InitSetup("Audit File Export Format"::FEC);
        AuditFileExportFormatSetup.InitSetup("Audit File Export Format"::FEC, '', false);
    end;

    local procedure CreateAuditFileExportDoc(var AuditFileExportHeader: Record "Audit File Export Header"; StartingDate: Date; EndingDate: Date; IncludeOpeningBalances: Boolean; DefaultSourceCode: Code[10]; GLAccountViewString: Text[2048])
    begin
        AuditFileExportHeader.Init();
        AuditFileExportHeader.Validate("Audit File Export Format", "Audit File Export Format"::FEC);
        AuditFileExportHeader.Validate("Starting Date", StartingDate);
        AuditFileExportHeader.Validate("Ending Date", EndingDate);
        AuditFileExportHeader.Validate("Include Opening Balances", IncludeOpeningBalances);
        AuditFileExportHeader.Validate("Default Source Code", DefaultSourceCode);
        AuditFileExportHeader.Validate("G/L Account View String", GLAccountViewString);
        AuditFileExportHeader.Validate("Parallel Processing", false);
        AuditFileExportHeader.Insert(true);
    end;

    local procedure CreateReadStream(var FileInStream: InStream; var AuditFile: Record "Audit File")
    begin
        AuditFile.CalcFields("File Content");
        AuditFile."File Content".CreateInStream(FileInStream);
    end;

    local procedure RunFECExport(var AuditFile: Record "Audit File"; GLAccountNoFilter: Text; StartDate: Date; EndDate: Date; IncludeOpeningBalances: Boolean)
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        GLAccount: Record "G/L Account";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        GLAccount.SetFilter("No.", GLAccountNoFilter);
        CreateAuditFileExportDoc(
            AuditFileExportHeader, StartDate, EndDate, IncludeOpeningBalances, '', CopyStr(GLAccount.GetView(), 1, 2048));
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
        AuditFile.SetRange("Export ID", AuditFileExportHeader.ID);
        AuditFile.FindFirst();
    end;

    local procedure RunFECExport(GLAccountNoFilter: Text; StartDate: Date; EndDate: Date; IncludeOpeningBalances: Boolean) AuditFileExportHeaderID: Integer
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        GLAccount: Record "G/L Account";
        AuditFileExportMgt: Codeunit "Audit File Export Mgt.";
    begin
        GLAccount.SetFilter("No.", GLAccountNoFilter);
        CreateAuditFileExportDoc(
            AuditFileExportHeader, StartDate, EndDate, IncludeOpeningBalances, '', CopyStr(GLAccount.GetView(), 1, 2048));
        AuditFileExportMgt.StartExport(AuditFileExportHeader);
        AuditFileExportHeaderID := AuditFileExportHeader.ID;
    end;

    local procedure RunGetLedgerEntryDataForCustVend(StartingDate: Date; EndingDate: Date; TransactionNo: Integer; SourceType: Enum "Gen. Journal Source Type"; var PartyNo: Code[20]; var PartyName: Text[100]; var FCYAmount: Text[250]; var CurrencyCode: Code[10]; var AppliedDocNo: Text; var AppliedDate: Date)
    var
        AuditFileExportHeader: Record "Audit File Export Header";
        LibraryTestFEC: Codeunit "Library - Test FEC";
    begin
        CreateAuditFileExportDoc(AuditFileExportHeader, StartingDate, EndingDate, false, '', '');
        LibraryTestFEC.InitGlobalVariables(AuditFileExportHeader);
        LibraryTestFEC.GetLedgerEntryDataForCustVend(
            TransactionNo, SourceType, PartyNo, PartyName, FCYAmount, CurrencyCode, AppliedDocNo, AppliedDate);
    end;

    local procedure ApplyAndPostGenJournalLine(DocNoToApplyTo: Code[20]; DocTypeToApply: Enum "Gen. Journal Document Type"; DocNoToApply: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Document No.", DocNoToApplyTo);
        GenJournalLine.FindFirst();
        GenJournalLine.Validate("Applies-to Doc. Type", DocTypeToApply);
        GenJournalLine.Validate("Applies-to Doc. No.", DocNoToApply);
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GLAccount.SetRange("Direct Posting", true);
        GLAccount.FindFirst();
        GenJournalBatch.Validate("Bal. Account No.", GLAccount."No.");
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateGenJournalLine(GenJournalBatch: Record "Gen. Journal Batch"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; PostingDate: Date; Amount: Decimal): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, DocumentType,
          AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        if GenJournalLine."Document No." <> '' then
            GenJournalLine.Validate("Document No.", IncStr(GenJournalLine."Document No."));
        GenJournalLine.Modify(true);
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateGLAccountWithDetailedBalance(): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Detailed Balance", true);
        GLAccount.Modify(true);
        exit(GLAccount."No.");
    end;

    local procedure ConvertFldNo2FldName(FldNo: Integer): Text[20]
    begin
        case Format(FldNo) of
            '1':
                exit('JournalCode');
            '2':
                exit('JournalLib');
            '3':
                exit('EcritureNum');
            '4':
                exit('EcritureDate');
            '5':
                exit('CompteNum');
            '6':
                exit('CompteLib');
            '7':
                exit('CompAuxNum');
            '8':
                exit('CompAuxLib');
            '9':
                exit('PieceRef');
            '10':
                exit('PieceDate');
            '11':
                exit('EcritureLib');
            '12':
                exit('Debit');
            '13':
                exit('Credit');
            '14':
                exit('EcritureLet');
            '15':
                exit('DateLet');
            '16':
                exit('ValidDate');
            '17':
                exit('Montantdevise');
            '18':
                exit('Idevise');
            else
                Error(UnknownFieldErr, FldNo);
        end;
    end;

    local procedure CreateBankAccount(var BankAccount: Record "Bank Account")
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.FindLast();
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccountPostingGroup.Code);
        BankAccount.Validate(Name, LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(Name), DATABASE::"Bank Account"));
        BankAccount.Modify(true);
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.GetDiscountPaymentTerm(PaymentTerms);
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Payment Terms Code", PaymentTerms.Code);
        Customer.Modify(true);
    end;

    local procedure CreateCustomerWithPostingGroup(CustomerPostGroupCode: Code[20]): Code[20]
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Customer Posting Group", CustomerPostGroupCode);
        Customer.Modify(true);
        exit(Customer."No.");
    end;

    local procedure CreateCustomerPostingGroup(GLAccountNo: Code[20]): Code[20]
    var
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        LibrarySales.CreateCustomerPostingGroup(CustomerPostingGroup);
        CustomerPostingGroup.Validate("Receivables Account", GLAccountNo);
        CustomerPostingGroup.Modify(true);
        exit(CustomerPostingGroup.Code);
    end;

    local procedure CreateVendorWithPostingGroup(VendorPostGroupCode: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("Vendor Posting Group", VendorPostGroupCode);
        Vendor.Modify(true);
        exit(Vendor."No.");
    end;

    local procedure CreateVendorPostingGroup(GLAccountNo: Code[20]): Code[20]
    var
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        LibraryPurchase.CreateVendorPostingGroup(VendorPostingGroup);
        VendorPostingGroup.Validate("Payables Account", GLAccountNo);
        VendorPostingGroup.Modify(true);
        exit(VendorPostingGroup.Code);
    end;

    local procedure CreateBankAccWithPostingGroup(BankAccPostGroupCode: Code[20]; CurrencyCode: Code[10]): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Bank Acc. Posting Group", BankAccPostGroupCode);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Modify(true);
        exit(BankAccount."No.");
    end;

    local procedure CreateBankAccPostingGroup(GLAccountNo: Code[20]): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        LibraryERM.CreateBankAccountPostingGroup(BankAccountPostingGroup);
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
        BankAccountPostingGroup.Modify(true);
        exit(BankAccountPostingGroup.Code);
    end;

    local procedure CreateAndPostGenJnlLine(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCode: Record "Source Code";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(GenJournalLine, DocumentType, AccountType, AccountNo, Amount);
        CreateSourceCodeAndDesc(SourceCode);
        GenJournalLine.Validate("Source Code", SourceCode.Code);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostMultipleGenJnlLines(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date; Amount: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SourceCode: Record "Source Code";
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(GenJournalLine, DocumentType, AccountType, AccountNo, Amount);
        CreateSourceCodeAndDesc(SourceCode);
        GenJournalLine.Validate("Source Code", SourceCode.Code);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        LibraryJournals.CreateGenJournalLine(
            GenJournalLine, GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", DocumentType, AccountType, AccountNo,
            GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), Amount);
        GenJournalLine.Validate("Source Code", SourceCode.Code);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostBankGenJnlLine(var BankAccount: Record "Bank Account"; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        CreateBankAccount(BankAccount);
        CreateAndPostGenJnlLine(
            "Gen. Journal Account Type"::"Bank Account", BankAccount."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreateAndPostBankGenJnlLines(var BankAccount: Record "Bank Account"; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        CreateBankAccount(BankAccount);
        CreateAndPostMultipleGenJnlLines(
            "Gen. Journal Account Type"::"Bank Account", BankAccount."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreateAndPostCustomGenJnlLine(var Customer: Record Customer; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        CreateCustomer(Customer);
        CreateAndPostGenJnlLine(
            "Gen. Journal Account Type"::Customer, Customer."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreateAndPostCustomGenJnlLines(var Customer: Record Customer; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        CreateCustomer(Customer);
        CreateAndPostMultipleGenJnlLines(
            "Gen. Journal Account Type"::Customer, Customer."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreateAndPostVendorGenJnlLine(var Vendor: Record Vendor; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateAndPostGenJnlLine(
          "Gen. Journal Account Type"::Vendor, Vendor."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreateAndPostVendorGenJnlLines(var Vendor: Record Vendor; DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date)
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateAndPostMultipleGenJnlLines(
          "Gen. Journal Account Type"::Vendor, Vendor."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
    end;

    local procedure CreatePostCustVendOneTransactionGenJnlLine(var Customer: Record Customer; var Vendor: Record Vendor; PostingDate: Date)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineAmount: Decimal;
        DocumentNo: Code[20];
    begin
        CreateCustomer(Customer);
        LibraryPurchase.CreateVendor(Vendor);
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        LineAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);

        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::Payment,
          "Gen. Journal Account Type"::Customer, Customer."No.", "Gen. Journal Account Type"::"G/L Account", '', -LineAmount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        DocumentNo := GenJournalLine."Document No.";

        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::Payment,
          "Gen. Journal Account Type"::Vendor, Vendor."No.", "Gen. Journal Account Type"::"G/L Account", '', LineAmount);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePostCustCustOneTransactionGenJnlLine(var Customer: array[2] of Record Customer; PostingDate: Date)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineAmount: Decimal;
        DocumentNo: Code[20];
    begin
        LibrarySales.CreateCustomer(Customer[1]);
        LibrarySales.CreateCustomer(Customer[2]);
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        LineAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          "Gen. Journal Account Type"::Customer, Customer[1]."No.", "Gen. Journal Account Type"::"G/L Account", '', 0);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Debit Amount", LineAmount);
        GenJournalLine.Modify(true);
        DocumentNo := GenJournalLine."Document No.";
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          "Gen. Journal Account Type"::Customer, Customer[2]."No.", "Gen. Journal Account Type"::"G/L Account", '', 0);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Credit Amount", LineAmount);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePostVendVendOneTransactionGenJnlLine(var Vendor: array[2] of Record Vendor; PostingDate: Date)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        LineAmount: Decimal;
        DocumentNo: Code[20];
    begin
        LibraryPurchase.CreateVendor(Vendor[1]);
        LibraryPurchase.CreateVendor(Vendor[2]);
        LibraryJournals.CreateGenJournalBatch(GenJournalBatch);
        LineAmount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          "Gen. Journal Account Type"::Vendor, Vendor[1]."No.", "Gen. Journal Account Type"::"G/L Account", '', 0);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Debit Amount", LineAmount);
        GenJournalLine.Modify(true);
        DocumentNo := GenJournalLine."Document No.";
        LibraryJournals.CreateGenJournalLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, "Gen. Journal Document Type"::" ",
          "Gen. Journal Account Type"::Vendor, Vendor[2]."No.", "Gen. Journal Account Type"::"G/L Account", '', 0);
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Credit Amount", LineAmount);
        GenJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreatePostCustGenJnlLineOnDate(CustomerNo: Code[20]; CurrencyCode: Code[10]; PostingDate: Date): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateGenJnlLineOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice,
          "Gen. Journal Account Type"::Customer, CustomerNo, CurrencyCode, PostingDate, 1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;

    local procedure CreatePostVendGenJnlLineOnDate(VendorNo: Code[20]; CurrencyCode: Code[10]; PostingDate: Date): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateGenJnlLineOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice,
          "Gen. Journal Account Type"::Vendor, VendorNo, CurrencyCode, PostingDate, -1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(-GenJournalLine."Amount (LCY)");
    end;

    local procedure CreatePostBankAccGenJnlLineOnDate(BankAccountNo: Code[20]; CurrencyCode: Code[10]; PostingDate: Date): Decimal
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateGenJnlLineOnDate(
          GenJournalLine, "Gen. Journal Document Type"::Invoice,
          "Gen. Journal Account Type"::"Bank Account", BankAccountNo, CurrencyCode, PostingDate, 1);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(GenJournalLine."Amount (LCY)");
    end;

    local procedure CreateGenJnlLineWithBalAccOnDate(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; BalAccountNo: Code[20]; PostingDate: Date; Sign: Integer)
    begin
        CreateGenJnlLineOnDate(
          GenJournalLine, DocumentType, AccountType, AccountNo, '', PostingDate, Sign);
        GenJournalLine.Validate("Bal. Account Type", BalAccountType);
        GenJournalLine.Validate("Bal. Account No.", BalAccountNo);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateGenJnlLineOnDate(var GenJournalLine: Record "Gen. Journal Line"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; CurrencyCode: Code[10]; PostingDate: Date; Sign: Integer)
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, DocumentType,
          AccountType, AccountNo, Sign * LibraryRandom.RandDecInRange(100, 200, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Modify(true);
    end;

    procedure CreateAndPostGLGenJnlLine(DocumentType: Enum "Gen. Journal Document Type"; PostingDate: Date): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        CreateAndPostGenJnlLine(
          "Gen. Journal Account Type"::"G/L Account", GLAccount."No.", DocumentType, PostingDate, -LibraryRandom.RandDecInRange(100, 200, 2));
        exit(GLAccount."No.");
    end;

    local procedure CreateApplyCustomerPayment(CustomerNo: Code[20]; PostingDate: Date; "Part": Decimal)
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustLedgerEntryPmt: Record "Cust. Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount, "Remaining Amount");

        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, "Gen. Journal Document Type"::Payment,
          "Gen. Journal Account Type"::Customer, CustomerNo, -CustLedgerEntry.Amount * Part);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Currency Code", CustLedgerEntry."Currency Code");
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        LibraryERM.SetApplyCustomerEntry(CustLedgerEntry, CustLedgerEntry."Remaining Amount" * Part);
        LibraryERM.FindCustomerLedgerEntry(
          CustLedgerEntryPmt, "Gen. Journal Document Type"::Payment, GenJournalLine."Document No.");
        LibraryERM.SetAppliestoIdCustomer(CustLedgerEntryPmt);
        LibraryERM.PostCustLedgerApplication(CustLedgerEntry);
    end;

    local procedure CreateApplyVendorPayment(VendorNo: Code[20]; PostingDate: Date; "Part": Decimal)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntryPmt: Record "Vendor Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntry.FindFirst();
        VendorLedgerEntry.CalcFields(Amount, "Remaining Amount");

        LibraryJournals.CreateGenJournalLineWithBatch(
          GenJournalLine, "Gen. Journal Document Type"::Payment,
          "Gen. Journal Account Type"::Vendor, VendorNo, -VendorLedgerEntry.Amount * Part);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Currency Code", VendorLedgerEntry."Currency Code");
        GenJournalLine.Modify(true);

        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        LibraryERM.SetApplyVendorEntry(VendorLedgerEntry, VendorLedgerEntry."Remaining Amount" * Part);
        LibraryERM.FindVendorLedgerEntry(
          VendorLedgerEntryPmt, "Gen. Journal Document Type"::Payment, GenJournalLine."Document No.");
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntryPmt);
        LibraryERM.PostVendLedgerApplication(VendorLedgerEntry);
    end;

    local procedure CreateSourceCodeAndDesc(var SourceCode: Record "Source Code")
    begin
        LibraryERM.CreateSourceCode(SourceCode);
        SourceCode.Validate(
            Description, LibraryUtility.GenerateRandomCode(SourceCode.FieldNo(Description), Database::"Source Code"));
    end;

    local procedure CreateSingleCustomerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; TransactionNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        CustomerPostingGroup: Record "Customer Posting Group";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        CustomerPostingGroup.FindFirst();
        InsertGLentryWithGivenTransactionNo(GLEntry, CustomerPostingGroup."Receivables Account", TransactionNo);
        InsertCustLedgerEntryWithDetail(
          CustLedgerEntry, DetailedCustLedgEntry, CustomerPostingGroup.Code, GLEntry."Transaction No.", 0);
    end;

    local procedure CreateSingleVendorEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; TransactionNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        VendorPostingGroup.FindFirst();
        InsertGLentryWithGivenTransactionNo(GLEntry, VendorPostingGroup."Payables Account", TransactionNo);
        InsertVendorLedgerEntryWithDetail(
          VendorLedgerEntry, DetailedVendorLedgEntry, VendorPostingGroup.Code, GLEntry."Transaction No.", 0);
    end;

    local procedure CreateCurrency(): Code[10]
    var
        ExchRate: Decimal;
    begin
        ExchRate := LibraryRandom.RandIntInRange(2, 10);
        exit(LibraryERM.CreateCurrencyWithExchangeRate(CalcDate('<-CM>', WorkDate()), ExchRate, ExchRate));
    end;

    local procedure CreateCurrencyExchRate(CurrencyCode: Code[10]; StartingDate: Date)
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        ExchRate: Decimal;
    begin
        CurrencyExchangeRate.SetRange("Currency Code", CurrencyCode);
        CurrencyExchangeRate.FindFirst();
        ExchRate := CurrencyExchangeRate."Exchange Rate Amount" + LibraryRandom.RandIntInRange(1, 5);
        LibraryERM.CreateExchangeRate(CurrencyCode, StartingDate, ExchRate, ExchRate);
    end;

    local procedure DeleteCustomerEntries(TransactionNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
    begin
        GLEntry.SetRange("Transaction No.", TransactionNo);
        if GLEntry.FindFirst() then
            GLEntry.DeleteAll();

        CustLedgerEntry.SetRange("Transaction No.", TransactionNo);
        if CustLedgerEntry.FindFirst() then
            CustLedgerEntry.DeleteAll();

        DetailedCustLedgEntry.SetRange("Transaction No.", TransactionNo);
        if DetailedCustLedgEntry.FindFirst() then
            DetailedCustLedgEntry.DeleteAll();
    end;

    local procedure DeleteVendorEntries(TransactionNo: Integer)
    var
        GLEntry: Record "G/L Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
    begin
        GLEntry.SetRange("Transaction No.", TransactionNo);
        if GLEntry.FindFirst() then
            GLEntry.DeleteAll();

        VendorLedgerEntry.SetRange("Transaction No.", TransactionNo);
        if VendorLedgerEntry.FindFirst() then
            VendorLedgerEntry.DeleteAll();

        DetailedVendorLedgEntry.SetRange("Transaction No.", TransactionNo);
        if DetailedVendorLedgEntry.FindFirst() then
            DetailedVendorLedgEntry.DeleteAll();
    end;

    local procedure GetErrorTextForAssertStmnt(FieldNo: Integer): Text[250]
    begin
        exit(StrSubstNo(WrongFieldErr, ConvertFldNo2FldName(FieldNo), FieldNo));
    end;

    local procedure FormatAmount(Amount: Decimal): Text[250]
    begin
        exit(Format(Amount, 0, '<Precision,2:2><Sign><Integer><Decimals><comma,,>'));
    end;

    local procedure GetFormattedDate(GLEntryDate: Date): Text[8]
    begin
        if GLEntryDate <> 0D then
            exit(Format(GLEntryDate, 8, '<Year4><Month,2><Day,2>'));
        exit('')
    end;

    local procedure GetFieldTextValue(FieldNo: Integer; LineToRead: Text): Text[50]
    var
        FieldValue: Text[50];
    begin
        FieldValue := CopyStr(SelectStr(FieldNo, LineToRead), 1, MaxStrLen(FieldValue));
        FieldValue := ConvertStr(FieldValue, '_', ',');
        exit(FieldValue);
    end;

    local procedure GetNonRecPayAccountNo(): Code[20]
    begin
        exit(LibraryUtility.GenerateGUID())
    end;

    local procedure GetStartingDate(): Date
    var
        GLEntry: Record "G/L Entry";
        StartingDate: Date;
    begin
        StartingDate := WorkDate();
        repeat
            StartingDate := CalcDate('<+1D>', StartingDate);
            GLEntry.SetRange("Posting Date", StartingDate);
        until not GLEntry.FindFirst();
        exit(StartingDate)
    end;

    local procedure GetSourceCodeDesc("Code": Code[10]): Text[100]
    var
        SourceCode: Record "Source Code";
    begin
        SourceCode.Get(Code);
        exit(SourceCode.Description);
    end;

    local procedure GetTransactionNo() TransactionNo: Integer
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.FindLast();
        TransactionNo := GLEntry."Transaction No.";
        repeat
            TransactionNo += 1;
            GLEntry.SetRange("Transaction No.", TransactionNo);
        until not GLEntry.FindFirst();
    end;

    local procedure GetCustInvoiceAmount(CustomerNo: Code[20]): Decimal
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.CalcFields(Amount);
        exit(CustLedgerEntry.Amount);
    end;

    local procedure GetVendInvoiceAmount(VendorNo: Code[20]): Decimal
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        VendorLedgerEntry.SetRange("Vendor No.", VendorNo);
        VendorLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        VendorLedgerEntry.FindFirst();
        VendorLedgerEntry.CalcFields(Amount);
        exit(VendorLedgerEntry.Amount);
    end;

    local procedure GetBankAccInvoiceAmount(BankAccountNo: Code[20]): Decimal
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
    begin
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        BankAccountLedgerEntry.SetRange("Document Type", "Gen. Journal Document Type"::Invoice);
        BankAccountLedgerEntry.FindFirst();
        exit(BankAccountLedgerEntry.Amount);
    end;

    local procedure GetPostingGLAccount(GLEntry: Record "G/L Entry"): Code[20]
    begin
        case GLEntry."Source Type" of
            "Gen. Journal Source Type"::Customer:
                exit(GetCustReceivablesAccount(GLEntry."Source No."));
            "Gen. Journal Source Type"::Vendor:
                exit(GetVendPayablesAccount(GLEntry."Source No."));
            "Gen. Journal Source Type"::"Bank Account":
                exit(GetBankPostingGLAccount(GLEntry."Source No."));
        end;
        exit('');
    end;

    local procedure GetCustReceivablesAccount(CustomerNo: Code[20]): Code[20]
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        exit(CustomerPostingGroup."Receivables Account");
    end;

    local procedure GetVendPayablesAccount(VendorNo: Code[20]): Code[20]
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        Vendor.Get(VendorNo);
        VendorPostingGroup.Get(Vendor."Vendor Posting Group");
        exit(VendorPostingGroup."Payables Account");
    end;

    local procedure GetBankPostingGLAccount(BankAccountNo: Code[20]): Code[20]
    var
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccount.Get(BankAccountNo);
        BankAccountPostingGroup.Get(BankAccount."Bank Acc. Posting Group");
        exit(BankAccountPostingGroup."G/L Account No.");
    end;

    local procedure InsertCustLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; CustomerPostingGroupCode: Code[20]; TransactionNo: Integer; DocumentNo: Code[20])
    var
        Customer: Record Customer;
        Currency: Record Currency;
        EntryNo: Integer;
    begin
        Customer.FindFirst();
        CustLedgerEntry.FindLast();
        EntryNo := CustLedgerEntry."Entry No." + 1;

        CustLedgerEntry.Init();
        CustLedgerEntry."Entry No." := EntryNo;
        CustLedgerEntry."Transaction No." := TransactionNo;
        CustLedgerEntry."Document No." := DocumentNo;
        CustLedgerEntry."Customer No." := Customer."No.";
        CustLedgerEntry."Customer Name" := Customer.Name;
        CustLedgerEntry."Customer Posting Group" := CustomerPostingGroupCode;
        CustLedgerEntry."Posting Date" := WorkDate();
        Currency.FindFirst();
        CustLedgerEntry."Currency Code" := Currency.Code;
        CustLedgerEntry.Insert();
    end;

    local procedure InsertCustLedgerEntryWithDetail(var CustLedgerEntry: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; CustomerPostingGroupCode: Code[20]; TransactionNo: Integer; AppliedEntryNo: Integer): Text[250]
    var
        FCYAmount: Text[250];
    begin
        InsertCustLedgerEntry(CustLedgerEntry, CustomerPostingGroupCode, TransactionNo, '');

        InsertDetailCustLedgerEntry(CustLedgerEntry, DetailedCustLedgEntry, "Detailed CV Ledger Entry Type"::"Initial Entry", TransactionNo, 0);
        FCYAmount := Format(DetailedCustLedgEntry.Amount);
        InsertDetailCustLedgerEntry(CustLedgerEntry, DetailedCustLedgEntry, "Detailed CV Ledger Entry Type"::Application, TransactionNo, AppliedEntryNo);
        exit(FCYAmount)
    end;

    local procedure InsertDetailCustLedgerEntry(CustLedgerEntry: Record "Cust. Ledger Entry"; var DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry"; EntryType: Enum "Detailed CV Ledger Entry Type"; TransactionNo: Integer;
                                                                                                                                                                             AppliedEntryNo: Integer)
    var
        EntryNo: Integer;
    begin
        DetailedCustLedgEntry.FindLast();
        EntryNo := DetailedCustLedgEntry."Entry No." + 1;
        DetailedCustLedgEntry.Init();
        DetailedCustLedgEntry."Transaction No." := TransactionNo;
        DetailedCustLedgEntry."Entry No." := EntryNo;
        DetailedCustLedgEntry."Cust. Ledger Entry No." := CustLedgerEntry."Entry No.";
        DetailedCustLedgEntry."Entry Type" := EntryType;
        DetailedCustLedgEntry."Posting Date" := WorkDate();
        DetailedCustLedgEntry.Amount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        DetailedCustLedgEntry."Applied Cust. Ledger Entry No." := AppliedEntryNo;
        DetailedCustLedgEntry.Insert();
    end;

    local procedure InsertDetailedVendorLedgEntry(VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; EntryType: Enum "Detailed CV Ledger Entry Type"; TransactionNo: Integer;
                                                                                                                                                                                     AppliedEntryNo: Integer)
    var
        EntryNo: Integer;
    begin
        DetailedVendorLedgEntry.FindLast();
        EntryNo := DetailedVendorLedgEntry."Entry No." + 1;

        DetailedVendorLedgEntry.Init();
        DetailedVendorLedgEntry."Transaction No." := TransactionNo;
        DetailedVendorLedgEntry."Entry No." := EntryNo;
        DetailedVendorLedgEntry."Vendor Ledger Entry No." := VendorLedgerEntry."Entry No.";
        DetailedVendorLedgEntry."Entry Type" := EntryType;
        DetailedVendorLedgEntry."Posting Date" := WorkDate();
        DetailedVendorLedgEntry.Amount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        DetailedVendorLedgEntry."Applied Vend. Ledger Entry No." := AppliedEntryNo;
        DetailedVendorLedgEntry.Insert();
    end;

    local procedure InsertVendorLedgerEntry(var VendorLedgerEntry: Record "Vendor Ledger Entry"; VendorPostingGroupCode: Code[20]; TransactionNo: Integer; DocumentNo: Code[20])
    var
        Vendor: Record Vendor;
        Currency: Record Currency;
        EntryNo: Integer;
    begin
        VendorLedgerEntry.FindLast();
        EntryNo := VendorLedgerEntry."Entry No." + 1;

        VendorLedgerEntry.Init();
        VendorLedgerEntry."Transaction No." := TransactionNo;
        VendorLedgerEntry."Document No." := DocumentNo;
        VendorLedgerEntry."Entry No." := EntryNo;
        Vendor.FindFirst();
        VendorLedgerEntry."Vendor No." := Vendor."No.";
        VendorLedgerEntry."Vendor Name" := Vendor.Name;
        VendorLedgerEntry."Vendor Posting Group" := VendorPostingGroupCode;
        VendorLedgerEntry."Posting Date" := WorkDate();
        Currency.FindFirst();
        VendorLedgerEntry."Currency Code" := Currency.Code;
        VendorLedgerEntry.Insert();
    end;

    local procedure InsertVendorLedgerEntryWithDetail(var VendorLedgerEntry: Record "Vendor Ledger Entry"; var DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry"; VendorPostingGroupCode: Code[20]; TransactionNo: Integer; AppliedEntryNo: Integer): Text[250]
    var
        FCYAmount: Text[250];
    begin
        InsertVendorLedgerEntry(VendorLedgerEntry, VendorPostingGroupCode, TransactionNo, '');

        InsertDetailedVendorLedgEntry(
            VendorLedgerEntry, DetailedVendorLedgEntry, "Detailed CV Ledger Entry Type"::"Initial Entry", TransactionNo, 0);
        FCYAmount := Format(DetailedVendorLedgEntry.Amount);
        InsertDetailedVendorLedgEntry(
            VendorLedgerEntry, DetailedVendorLedgEntry, "Detailed CV Ledger Entry Type"::Application, TransactionNo, AppliedEntryNo);
        exit(FCYAmount)
    end;

    local procedure InsertGLentry(var GLEntry: Record "G/L Entry"; GLAccountNo: Code[20])
    begin
        InsertGLentryWithGivenTransactionNo(GLEntry, GLAccountNo, GetTransactionNo());
    end;

    local procedure InsertGLentryWithGivenTransactionNo(var GLEntry: Record "G/L Entry"; GLAccountNo: Code[20]; TransactionNo: Integer)
    var
        EntryNo: Integer;
    begin
        GLEntry.FindLast();
        EntryNo := GLEntry."Entry No." + 1;
        GLEntry.Init();
        GLEntry."Entry No." := EntryNo;
        GLEntry."Transaction No." := TransactionNo;
        GLEntry."G/L Account No." := GLAccountNo;
        GLEntry."Posting Date" := WorkDate();
        GLEntry.Amount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        GLEntry.Insert();
    end;

    local procedure PopulateFieldsArray(var iStream: InStream; var FieldsArray: array[18] of Text[50])
    var
        LineToRead: Text;
        Counter: Integer;
    begin
        iStream.ReadText(LineToRead);
        LineToRead := ConvertStr(LineToRead, ',', '_');
        LineToRead := ConvertStr(LineToRead, '|', ',');

        for Counter := 1 to 18 do
            FieldsArray[Counter] := GetFieldTextValue(Counter, LineToRead);
    end;

    local procedure SetZeroAmountToGLEntry(GLAccountNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
        TransactionNo: Integer;
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.FindLast();
        TransactionNo := GLEntry."Transaction No.";
        GLEntry.Reset();
        GLEntry.SetRange("Transaction No.", TransactionNo);
        GLEntry.ModifyAll(Amount, 0);
    end;

    local procedure UpdateCustomerPostingAccount(CustomerNo: Code[20]; GLAccountNo: Code[20])
    var
        Customer: Record Customer;
        CustomerPostingGroup: Record "Customer Posting Group";
    begin
        Customer.Get(CustomerNo);
        CustomerPostingGroup.Get(Customer."Customer Posting Group");
        CustomerPostingGroup.Validate("Receivables Account", GLAccountNo);
        CustomerPostingGroup.Modify(true);
    end;

    local procedure UpdateVendorPostingAccount(VendorNo: Code[20]; GLAccountNo: Code[20])
    var
        Vendor: Record Vendor;
        VendorPostingGroup: Record "Vendor Posting Group";
    begin
        Vendor.Get(VendorNo);
        VendorPostingGroup.Get(Vendor."Vendor Posting Group");
        VendorPostingGroup.Validate("Payables Account", GLAccountNo);
        VendorPostingGroup.Modify(true);
    end;

    local procedure UpdateBankAccountPostingAccount(BankAccountNo: Code[20]; GLAccountNo: Code[20])
    var
        BankAccount: Record "Bank Account";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccount.Get(BankAccountNo);
        BankAccountPostingGroup.Get(BankAccount."Bank Acc. Posting Group");
        BankAccountPostingGroup.Validate("G/L Account No.", GLAccountNo);
        BankAccountPostingGroup.Modify(true);
    end;

    local procedure VerifyVendorLedgerEntryData(VendorLedgerEntry: Record "Vendor Ledger Entry"; PartyNoActual: Code[20]; PartyNameActual: Text[100]; FCYAmountActual: Text[250]; CurrencyCodeActual: Code[10])
    var
        Vendor: Record Vendor;
        PartyNoExpected: Code[20];
        PartyNameExpected: Text[100];
        FCYAmountExpected: Text[250];
        CurrencyCodeExpected: Code[10];
        LedgerAmount: Decimal;
    begin
        VendorLedgerEntry.SetRange("Transaction No.", VendorLedgerEntry."Transaction No.");
        VendorLedgerEntry.SetFilter("Vendor No.", '<>%1', VendorLedgerEntry."Vendor No.");
        if VendorLedgerEntry.FindFirst() then begin
            PartyNameExpected := 'multi-fournisseurs';
            PartyNoExpected := '*';
            FCYAmountExpected := '';
        end else
            if Vendor.Get(VendorLedgerEntry."Vendor No.") then begin
                PartyNoExpected := VendorLedgerEntry."Vendor No.";
                PartyNameExpected := Vendor.Name;
                VendorLedgerEntry.SetRange("Transaction No.", VendorLedgerEntry."Transaction No.");
                VendorLedgerEntry.SetRange("Vendor No.", VendorLedgerEntry."Vendor No.");
                if VendorLedgerEntry.FindSet() then begin
                    repeat
                        VendorLedgerEntry.CalcFields("Original Amount");
                        LedgerAmount += VendorLedgerEntry."Original Amount";
                    until VendorLedgerEntry.Next() = 0;
                    FCYAmountExpected := FormatAmount(LedgerAmount);
                end;
                CurrencyCodeExpected := VendorLedgerEntry."Currency Code";
            end;

        Assert.AreEqual(PartyNoExpected, PartyNoActual, 'PartyNo');
        Assert.AreEqual(PartyNameExpected, PartyNameActual, 'PartyName');
        Assert.AreEqual(FCYAmountExpected, FCYAmountActual, 'FCYAmount');
        Assert.AreEqual(CurrencyCodeExpected, CurrencyCodeActual, 'CurrencyCode');
    end;

    local procedure VerifyCustomerLedgerEntryData(CustLedgerEntry: Record "Cust. Ledger Entry"; PartyNoActual: Code[20]; PartyNameActual: Text[100]; FCYAmountActual: Text[250]; CurrencyCodeActual: Code[10])
    var
        Customer: Record Customer;
        PartyNoExpected: Code[20];
        PartyNameExpected: Text[100];
        FCYAmountExpected: Text[250];
        CurrencyCodeExpected: Code[10];
        LedgerAmount: Decimal;
    begin
        CustLedgerEntry.SetRange("Transaction No.", CustLedgerEntry."Transaction No.");
        CustLedgerEntry.SetFilter("Customer No.", '<>%1', CustLedgerEntry."Customer No.");
        if CustLedgerEntry.FindFirst() then begin
            PartyNameExpected := 'multi-clients';
            PartyNoExpected := '*';
            FCYAmountExpected := '';
        end else
            if Customer.Get(CustLedgerEntry."Customer No.") then begin
                PartyNoExpected := CustLedgerEntry."Customer No.";
                PartyNameExpected := Customer.Name;
                CustLedgerEntry.SetRange("Transaction No.", CustLedgerEntry."Transaction No.");
                CustLedgerEntry.SetRange("Customer No.", CustLedgerEntry."Customer No.");
                if CustLedgerEntry.FindSet() then begin
                    repeat
                        CustLedgerEntry.CalcFields("Original Amount");
                        LedgerAmount += CustLedgerEntry."Original Amount";
                    until CustLedgerEntry.Next() = 0;
                    FCYAmountExpected := FormatAmount(LedgerAmount);
                end;
                CurrencyCodeExpected := CustLedgerEntry."Currency Code";
            end;

        Assert.AreEqual(PartyNoExpected, PartyNoActual, 'PartyNo');
        Assert.AreEqual(PartyNameExpected, PartyNameActual, 'PartyName');
        Assert.AreEqual(FCYAmountExpected, FCYAmountActual, 'FCYAmount');
        Assert.AreEqual(CurrencyCodeExpected, CurrencyCodeActual, 'CurrencyCode');
    end;

    local procedure VerifyExportGLEntriesReport(GLRegister: Record "G/L Register"; AuditFile: Record "Audit File"; GLAccountNo: Code[250]; PartyNo: Code[20]; PartyName: Text[100])
    var
        GLEntry: Record "G/L Entry";
        iStream: InStream;
        LineToRead: Text;
        FieldsValueArray: array[18] of Text[50];
    begin
        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // headers

        GLEntry.SetFilter("Entry No.", '%1..%2', GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetFilter("G/L Account No.", GLAccountNo);
        GLEntry.FindSet();
        repeat
            PopulateFieldsArray(iStream, FieldsValueArray);
            VerifyGLEntryFieldValues(FieldsValueArray, GLEntry, GLRegister."No.", GLRegister.SystemCreatedAt);
            if GLEntry."G/L Account No." = GetPostingGLAccount(GLEntry) then
                VerifyLedgerFieldValues(FieldsValueArray, PartyNo, PartyName)
            else
                VerifyLedgerFieldValues(FieldsValueArray, '', '');
        until GLEntry.Next() = 0;
    end;

    local procedure VerifyExportGLEntriesByTransNoReport(GLRegister: Record "G/L Register"; AuditFile: Record "Audit File"; GLAccountNo: Code[250]; PartyNo: Code[20]; PartyName: Text[100])
    var
        GLEntry: Record "G/L Entry";
        iStream: InStream;
        LineToRead: Text;
        FieldsValueArray: array[18] of Text[50];
    begin
        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // headers

        GLEntry.SetFilter("Entry No.", '%1..%2', GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetFilter("G/L Account No.", GLAccountNo);
        GLEntry.FindSet();
        repeat
            PopulateFieldsArray(iStream, FieldsValueArray);
            VerifyGLEntryFieldValues(FieldsValueArray, GLEntry, GLEntry."Transaction No.", GLRegister.SystemCreatedAt);
            if GLEntry."G/L Account No." = GetPostingGLAccount(GLEntry) then
                VerifyLedgerFieldValues(FieldsValueArray, PartyNo, PartyName)
            else
                VerifyLedgerFieldValues(FieldsValueArray, '', '');
        until GLEntry.Next() = 0;
    end;

    local procedure VerifyExportGLEntriesReportWithGLAccNoFilter(AuditFile: Record "Audit File"; GLAccountNo: Code[20])
    var
        GLRegister: Record "G/L Register";
        GLEntry: Record "G/L Entry";
        iStream: InStream;
        LineToRead: Text;
        FieldsValueArray: array[18] of Text[50];
    begin
        GLRegister.FindLast();
        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // Read Headers
        GLEntry.SetFilter("G/L Account No.", GLAccountNo);
        GLEntry.FindFirst();
        PopulateFieldsArray(iStream, FieldsValueArray);
        VerifyGLEntryFieldValues(FieldsValueArray, GLEntry, GLRegister."No.", GLRegister.SystemCreatedAt);
        iStream.ReadText(LineToRead);
        Assert.AreEqual('', LineToRead, FilterErr); // Read the next line, empty string means there are no other entries and filter function work correctly.
    end;

    local procedure VerifySourceCodeOfExportedGLEntriesReport(AuditFile: Record "Audit File"; SourceCode: Code[10])
    var
        iStream: InStream;
        LineToRead: Text;
        FieldsValueArray: array[18] of Text[50];
    begin
        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // Read Headers
        PopulateFieldsArray(iStream, FieldsValueArray);
        Assert.AreEqual(SourceCode, FieldsValueArray[1], GetErrorTextForAssertStmnt(1));
    end;

    local procedure VerifyLedgerFieldValues(FieldsValueArray: array[18] of Text[50]; PartyNo: Code[20]; PartyName: Text[100])
    begin
        Assert.AreEqual(PartyNo, FieldsValueArray[7], GetErrorTextForAssertStmnt(7));
        Assert.AreEqual(PartyName, FieldsValueArray[8], GetErrorTextForAssertStmnt(8));
    end;

    local procedure VerifyAppliedEntriesReport(GLRegister: Record "G/L Register"; AuditFile: Record "Audit File"; GLAccountNo: Code[250]; AppliedEntries: Text; DocumentType: Enum "Gen. Journal Document Type"; AppliedDate: Date)
    var
        GLEntry: Record "G/L Entry";
        iStream: InStream;
        LineToRead: Text;
        FieldsValueArray: array[18] of Text[50];
    begin
        CreateReadStream(iStream, AuditFile);
        iStream.ReadText(LineToRead); // headers

        GLEntry.SetFilter("Entry No.", '%1..%2', GLRegister."From Entry No.", GLRegister."To Entry No.");
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Document Type", DocumentType);
        if GLEntry.FindSet() then
            repeat
                PopulateFieldsArray(iStream, FieldsValueArray);
                VerifyGLEntryFieldValues(FieldsValueArray, GLEntry, GLRegister."No.", GLRegister.SystemCreatedAt);
                Assert.AreEqual(AppliedEntries, FieldsValueArray[14], GetErrorTextForAssertStmnt(14));
                Assert.AreEqual(GetFormattedDate(AppliedDate), FieldsValueArray[15], GetErrorTextForAssertStmnt(15));
            until GLEntry.Next() = 0;
    end;

    local procedure VerifyGLEntryFieldValues(FieldsValueArray: array[18] of Text[50]; GLEntry: Record "G/L Entry"; GLRegisterNo: Integer; GLRegisterCreationDate: DateTime)
    begin
        GLEntry.CalcFields("G/L Account Name");
        Assert.AreEqual(GLEntry."Source Code", FieldsValueArray[1], GetErrorTextForAssertStmnt(1));
        Assert.AreEqual(GetSourceCodeDesc(GLEntry."Source Code"), FieldsValueArray[2], GetErrorTextForAssertStmnt(2));
        Assert.AreEqual(Format(GLRegisterNo), FieldsValueArray[3], GetErrorTextForAssertStmnt(3));
        Assert.AreEqual(GetFormattedDate(GLEntry."Posting Date"), FieldsValueArray[4], GetErrorTextForAssertStmnt(4));
        Assert.AreEqual(GLEntry."G/L Account No.", FieldsValueArray[5], GetErrorTextForAssertStmnt(5));
        Assert.AreEqual(GLEntry."G/L Account Name", FieldsValueArray[6], GetErrorTextForAssertStmnt(6));
        Assert.AreEqual(GLEntry."Document No.", FieldsValueArray[9], GetErrorTextForAssertStmnt(9));
        Assert.AreEqual(GetFormattedDate(GLEntry."Document Date"), FieldsValueArray[10], GetErrorTextForAssertStmnt(10));
        Assert.AreEqual(GLEntry.Description, FieldsValueArray[11], GetErrorTextForAssertStmnt(11));
        Assert.AreEqual(FormatAmount(GLEntry."Debit Amount"), FieldsValueArray[12], GetErrorTextForAssertStmnt(12));
        Assert.AreEqual(FormatAmount(GLEntry."Credit Amount"), FieldsValueArray[13], GetErrorTextForAssertStmnt(13));
        Assert.AreEqual(GetFormattedDate(DT2Date(GLRegisterCreationDate)), FieldsValueArray[16], GetErrorTextForAssertStmnt(16));
    end;

    local procedure VerifyExportGLEntriesReport2DecimalSymbols(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20];
                                                                                AccountName: Text[100];
                                                                                Sign: Integer)
    var
        GLRegister: Record "G/L Register";
        AuditFile: Record "Audit File";
        StartingDate: Date;
    begin
        StartingDate := GetStartingDate();

        CreateAndPostGenJnlLine(
            AccountType, AccountNo, "Gen. Journal Document Type"::Invoice, StartingDate, Sign * LibraryRandom.RandInt(1000));

        RunFECExport(AuditFile, '', StartingDate, StartingDate, false);

        // verify
        GLRegister.FindLast();
        VerifyExportGLEntriesReport(GLRegister, AuditFile, '', AccountNo, AccountName);
    end;

    local procedure VerifyGetLedgerEntryDataForCustVend_Customer(TransactionNo: Integer; CustLedgerEntry: Record "Cust. Ledger Entry")
    var
        FCYAmount: Text[250];
        PartyNo: Code[20];
        PartyName: Text[100];
        CurrencyCode: Code[10];
        AppliedDocNo: Text;
        AppliedDate: Date;
    begin
        RunGetLedgerEntryDataForCustVend(
            CustLedgerEntry."Posting Date", CustLedgerEntry."Posting Date", TransactionNo, "Gen. Journal Source Type"::Customer,
            PartyNo, PartyName, FCYAmount, CurrencyCode, AppliedDocNo, AppliedDate);

        VerifyCustomerLedgerEntryData(CustLedgerEntry, PartyNo, PartyName, FCYAmount, CurrencyCode);
    end;

    local procedure VerifyGetLedgerEntryDataForCustVend_Vendor(TransactionNo: Integer; VendorLedgerEntry: Record "Vendor Ledger Entry")
    var
        FCYAmount: Text[250];
        PartyNo: Code[20];
        PartyName: Text[100];
        CurrencyCode: Code[10];
        AppliedDocNo: Text;
        AppliedDate: Date;
    begin
        RunGetLedgerEntryDataForCustVend(
            VendorLedgerEntry."Posting Date", VendorLedgerEntry."Posting Date", TransactionNo, "Gen. Journal Source Type"::Vendor,
            PartyNo, PartyName, FCYAmount, CurrencyCode, AppliedDocNo, AppliedDate);

        VerifyVendorLedgerEntryData(VendorLedgerEntry, PartyNo, PartyName, FCYAmount, CurrencyCode);
    end;

    local procedure VerifyFilePartyNoAndName(InStream: InStream; ExpectedNo: Text; ExpectedName: Text)
    var
        FieldsValueArray: array[18] of Text[50];
    begin
        PopulateFieldsArray(InStream, FieldsValueArray);
        Assert.AreEqual(ExpectedNo, FieldsValueArray[7], '');
        Assert.AreEqual(ExpectedName, FieldsValueArray[8], '');
    end;

    local procedure VerifyOpeningBalanceEntry(var iStream: InStream; GLAccountNo: Code[20]; PartyNo: Code[20]; DebitAmount: Decimal; CreditAmount: Decimal)
    var
        FieldsValueArray: array[18] of Text[50];
    begin
        PopulateFieldsArray(iStream, FieldsValueArray);
        Assert.AreEqual('00000', FieldsValueArray[1], GetErrorTextForAssertStmnt(1));
        Assert.AreEqual(GLAccountNo, FieldsValueArray[5], GetErrorTextForAssertStmnt(5));
        Assert.AreEqual(PartyNo, FieldsValueArray[7], GetErrorTextForAssertStmnt(7));
        Assert.AreEqual(FormatAmount(DebitAmount), FieldsValueArray[12], GetErrorTextForAssertStmnt(12));
        Assert.AreEqual(FormatAmount(CreditAmount), FieldsValueArray[13], GetErrorTextForAssertStmnt(13));
    end;

    local procedure VerifyError(AuditFileExportHeaderID: Integer; ExpectedError: Text)
    var
        AuditFileExportLine: Record "Audit File Export Line";
        ActivityLog: Record "Activity Log";
        ErrorTextInStream: InStream;
        ErrorText: Text;
    begin
        AuditFileExportLine.SetRange(ID, AuditFileExportHeaderID);
        AuditFileExportLine.FindFirst();
        ActivityLog.SetRange("Record ID", AuditFileExportLine.RecordId());
        ActivityLog.FindLast();
        ActivityLog.CalcFields("Detailed Info");
        ActivityLog."Detailed Info".CreateInStream(ErrorTextInStream);
        ErrorTextInStream.ReadText(ErrorText);
        Assert.AreEqual(ExpectedError, ErrorText, '');
    end;

    [ConfirmHandler]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}