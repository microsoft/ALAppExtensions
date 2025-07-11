codeunit 18682 "TDS On Customer Tests"
{
    Subtype = Test;

    var
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryTDSOnCustomer: Codeunit "Library TDS On Customer";
        LibraryERM: Codeunit "Library - ERM";
        Assert: Codeunit Assert;
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        Storage: Dictionary of [Text, Code[20]];
        StorageEnum: Dictionary of [Text, Text];
        CertifcateValidationErr: Label 'TDS Certificate Receivable is false', Locked = true;
        RowDoesNotExistErr: Label 'The row does not exist on the TestPage.', Locked = true;
        EffectiveDateLbl: Label 'EffectiveDate', Locked = true;
        TDSPercentageLbl: Label 'TDSPercentage', Locked = true;
        NonPANTDSPercentageLbl: Label 'NonPANTDSPercentage', Locked = true;
        SurchargePercentageLbl: Label 'SurchargePercentage', Locked = true;
        ECessPercentageLbl: Label 'ECessPercentage', Locked = true;
        SHECessPercentageLbl: Label 'SHECessPercentage', Locked = true;
        TDSThresholdAmountLbl: Label 'TDSThresholdAmount', Locked = true;
        SectionCodeLbl: Label 'SectionCode', Locked = true;
        TDSAssesseeCodeLbl: Label 'TDSAssesseeCode', Locked = true;
        SurchargeThresholdAmountLbl: Label 'SurchargeThresholdAmount', Locked = true;
        TDSConcessionalCodeLbl: Label 'TDSConcessionalCode', Locked = true;
        AccountTypeLbl: Label 'AccountType', Locked = true;
        AccountNoLbl: Label 'AccountNo', Locked = true;

    // [SCENARIO] [357190] Check if the progrm is not considering any Threshold limit while calculating TDS amount in different journals
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure GeneralJournalWithTDSOnCustomer()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and Post General Journal
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357196] Check if the progrm is not considering any Threshold limit while calculating TDS amount in different journals
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure BankReceiptVoucherWithTDSOnCustomerAndWithThresholdOverlook()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        TDSPostingSetup: Record "TDS Posting Setup";
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Journal
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify entry TDS receivale account on G/L Entry
        LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 3);
    end;

    // [SCENARIO] [357197] Check if the program is calculating TDS while creating customer Receipt using the Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure BankReceiptVoucherWithTDSOnCustomer()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357215] Check if the program is not calculating TDS while creating Customer’s sales order - TDSC028
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesOrderWithTDSOnCustomer()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales order with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357203] Check if the program is calculating TDS while creating customer Receipt using the Cash Receipt Voucher - TDSC014/TDSC015
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CashReceiptVoucherWithTDSOnCustomer()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher",
            TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357216] Check if the program is not calculating TDS while creating Customer’s sales invoice
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesInvoiceWithTDSOnCustomer()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry    
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357217] Check if the program is not calculating TDS while creating Customer’s sales credit memo
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesCrMemoWithTDSOnCustomer()
    var
        Customer: Record customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales credit memo with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::"Credit Memo",
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357218] Check if the program is not calculating TDS while creating Customer’s sales return order
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesReturnOrderWithTDSOnCustomer()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        CustLedgEntry: Record "Cust. Ledger Entry";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales return order with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::"Return Order",
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357219] Check if the system is allowing to place check mark in TDS Certificate receivable field in Sales Order header
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesOrderWithTDSOnCustomerToCheckTDSCertificateReceivable()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create sales order with TDS Certificate Receivable
        LibraryTDSOnCustomer.CreateSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.");

        // [THEN] Check TDS Certificate Receivable  is marked true on sales order 
        Assert.Equal(true, SalesHeader."TDS Certificate Receivable");
    end;

    // [SCENARIO] [357220] Check if the system is allowing to place check mark in TDS Certificate receivable field in Sales invoice header
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure SalesInvoiceWithTDSOnCustomerToCheckTDSCertificateReceivable()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create sales invoice with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Check TDS Certificate Receivable  is marked true on sales invoice
        Assert.Equal(true, SalesHeader."TDS Certificate Receivable");
    end;

    // [SCENARIO] [357226] Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Sales Order header
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure SalesOrderWithTDSCertReceWithUpdateTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales order with TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357227] Check if the system is generating entry in Update TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Sales Order header
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure SalesOrderWithoutTDSCertReceWithUpdateTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales invoice without TDS Certificate receivable
        DocumentNo := LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithoutTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Invoice,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357246] Check if the program is calculating TDS with concessional code while creating customer Receipt using the General Journal
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure GeneralJournalWithTDSOnCustomerAndWithConcessionalCode()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());

        // [WHEN] Create and Post General Journal
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivable(GenJournalLine, Customer."No.", VoucherType::General, TDSPostingSetup."TDS Section");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357247] Check if the program is calculating TDS with concessional code while creating customer Receipt using the Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure BankReceiptVoucherWithTDSOnCustomerAndWithConcessionalCode()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post bank receipt voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357248] Check if the program is calculating TDS with concessional code while creating customer Receipt using the Cash Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CashReceiptVoucherWithTDSOnCustomerAndWithConcessionalCode()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        CustLedgEntry: Record "Cust. Ledger Entry";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post cash receipt voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify TDS Certificate Receivable on customer ledger entry
        CustLedgEntry.SetRange("Customer No.", Customer."No.");
        CustLedgEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgEntry.FindFirst();
        Assert.RecordIsNotEmpty(CustLedgEntry);
    end;

    // [SCENARIO] [357190] Check if the progrm is not considering any Threshold limit while calculating TDS amount in different journals
    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure JournalVoucherWithTDSOnCustomer()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Journal Voucher", GLAccount, Location);

        // [WHEN] Create Journal Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Journal Voucher", TDSPostingSetup."TDS Section", Location.Code);

        // [THEN] Check TDS Certificate Receivable  is marked true on journal voucher
        Assert.Equal(true, GenJournalLine."TDS Certificate Receivable");
    end;

    // [SCENARIO] [357228] Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Sales Order header
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnAssignTDSCertDetailsPage')]
    procedure SalesOrderWithTDSCertReceWithAssignTDSCertificate()
    var
        Customer: Record Customer;
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        SalesHeader: Record "Sales Header";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());

        // [WHEN] Create and post sales order with TDS Certificate receivable
        LibraryTDSOnCustomer.CreateAndPostSalesDocumentWithTDSCertificateReceivable(
            SalesHeader,
            SalesHeader."Document Type"::Order,
            Customer."No.");

        // [THEN] Verify TDS Certificate Receivable on Update TDS Certificate Page
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(Customer."No.");
        AssignTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357199] Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure BankReceiptVoucherWithTDSCertReceiAndUpdateTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357199] Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure BankReceiptVoucherWithoutTDSCertReceiAndUpdateTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", '', Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 2);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357205] Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Cash Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure CashReceiptVoucherWithTDSCertReceiAndUpdateTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357206] Check if the system is generating entry in Update TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage')]
    procedure CashReceiptVoucherWithoutTDSCertReceiAndUpdateTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        TDSPostingSetup: Record "TDS Posting Setup";
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher without TDS Certificate receivable
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher", '', Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 2);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        UpdateTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357201] Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnAssignTDSCertDetailsPage')]
    procedure BankReceiptVoucherWithTDSCertReceiAndAssignTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        AssignTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357202] Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Bank Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnAssignTDSCertDetailsPage')]
    procedure BankReceiptVoucherWithoutTDSCertReceiAndAssignTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [WHEN] Create and Post Bank Receipt Voucher without TDS Certificate Page
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", '', Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 2);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        AssignTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357207] Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is placed  in TDS Certificate receivable field in Cash Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnAssignTDSCertDetailsPage')]
    procedure CashReceiptVoucherWithTDSCertReceiAndAssignTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 3);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        AssignTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    // [SCENARIO] [357208] Check if the system is generating  entry in Assign TDS Cert. Details window when check mark is not placed  in TDS Certificate receivable field in Cash Receipt Voucher
    [Test]
    [HandlerFunctions('TaxRatePageHandler,CheckTDSCertRecOnAssignTDSCertDetailsPage')]
    procedure CashReceiptVoucherWithoutTDSCertReceiAndAssignTDSCertificate()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        ConcessionalCode: Record "Concessional Code";
        TDSPostingSetup: Record "TDS Posting Setup";
        GLAccount: Record "G/L Account";
        Location: Record Location;
        DocumentNo: Code[20];
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [GIVEN] Created Setup for TDS Section, Assessee Code, Customer, TDS Setup, TDS Accounting Period and TDS Rates
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", '', WorkDate());
        CreateGLAccWithVoucherAccount(AccountType::"G/L Account", VoucherType::"Cash Receipt Voucher", GLAccount, Location);

        // [WHEN] Create and Post Cash Receipt Voucher without TDS Certificate receivable
        LibraryTDSOnCustomer.CreateGenJournalLineWithoutTDSCertificateReceivableForGL(GenJournalLine, Customer."No.", GLAccount."No.", VoucherType::"Cash Receipt Voucher", '', Location.Code);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] Verify posted entry for TDS Certificate Receivable on Update TDS Certificate Page
        DocumentNo := LibraryTDSOnCustomer.VerifyGLEntryCount(GenJournalLine."Journal Batch Name", 2);
        LibraryVariableStorage.Clear();
        LibraryVariableStorage.Enqueue(DocumentNo);
        AssignTDSCertifcateDetails(Customer."No.", TDSPostingSetup."TDS Section");
    end;

    [Test]
    [HandlerFunctions('TaxRatePageHandler')]
    procedure CreateBankReceiptVoucherWithTDSReceivable()
    var
        Customer: Record Customer;
        GenJournalLine: Record "Gen. Journal Line";
        TDSPostingSetup: Record "TDS Posting Setup";
        ConcessionalCode: Record "Concessional Code";
        BankAccount: Record "Bank Account";
        Location: Record Location;
        VoucherType: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
    begin
        // [SCENARIO] [357198] [Check if the system is allowing to place check mark in TDS Certificate receivable field in Bank Receipt Voucher-TDSC009.]
        // [Given] Customer Setup &  G/L Account Setups & Bank Receipt Voucher.
        LibraryTDSOnCustomer.CreateTDSonCustomerSetup(Customer, TDSPostingSetup, ConcessionalCode);
        CreateTaxRateSetup(TDSPostingSetup."TDS Section", Customer."Assessee Code", ConcessionalCode.Code, WorkDate());
        CreateBankAccWithVoucherAccount(AccountType::"Bank Account", VoucherType::"Bank Receipt Voucher", BankAccount, Location);

        // [When] Creation of GenjnlLine and Marking TDS Certificate True.
        LibraryTDSOnCustomer.CreateGenJournalLineWithTDSCertificateReceivableForBank(GenJournalLine, Customer."No.", BankAccount."No.", VoucherType::"Bank Receipt Voucher", TDSPostingSetup."TDS Section", Location.Code);

        // [Then] Verification of Feild value.
        Assert.IsTrue(GenJournalLine."TDS Certificate Receivable", CertifcateValidationErr);
    end;

    local procedure UpdateTDSCertifcateDetails(CustomerNo: Code[20]; TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue(CustomerNo);
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Update TDS Cert. Details".Invoke();
    end;

    local procedure AssignTDSCertifcateDetails(CustomerNo: Code[20]; TDSSection: Code[10])
    var
        UpdateCertifcate: TestPage "Update TDS Certificate Details";
        Year: Integer;
    begin
        UpdateCertifcate.OpenEdit();
        UpdateCertifcate.CustomerNo.SetValue(CustomerNo);
        UpdateCertifcate.CertificateNo.SetValue(LibraryUtility.GenerateRandomText(20));
        UpdateCertifcate.CertificateDate.SetValue(LibraryUtility.GenerateRandomDate(WorkDate(), CalcDate('<1Y>', Today)));
        UpdateCertifcate.CertificateAmount.SetValue(LibraryRandom.RandDec(100, 2));
        Year := Date2DMY(WorkDate(), 3);
        UpdateCertifcate.FinancialYear.SetValue(Year);
        UpdateCertifcate.TDSSection.SetValue(TDSSection);
        UpdateCertifcate."Assign TDS Cert. Details".Invoke();
    end;

    local procedure CreateTaxRateSetup(
        TDSSection: Code[10];
        AssesseeCode: Code[10];
        ConcessionlCode: Code[10];
        EffectiveDate: Date)
    var
        Section: Code[10];
        TDSAssesseeCode: Code[10];
        TDSConcessionlCode: Code[10];
    begin
        Section := TDSSection;
        Storage.Set(SectionCodeLbl, Section);
        TDSAssesseeCode := AssesseeCode;
        Storage.Set(TDSAssesseeCodeLbl, TDSAssesseeCode);
        TDSConcessionlCode := ConcessionlCode;
        Storage.Set(TDSConcessionalCodeLbl, TDSConcessionlCode);
        Storage.Set(EffectiveDateLbl, Format(EffectiveDate, 0, 9));
        CreateTaxRate();
    end;

    local procedure GenerateTaxComponentsPercentage()
    begin
        Storage.Set(TDSPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(NonPANTDSPercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(SurchargePercentageLbl, Format(LibraryRandom.RandIntInRange(6, 10)));
        Storage.Set(ECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(SHECessPercentageLbl, Format(LibraryRandom.RandIntInRange(2, 4)));
        Storage.Set(TDSThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
        Storage.Set(SurchargeThresholdAmountLbl, Format(LibraryRandom.RandIntInRange(4000, 6000)));
    end;

    local procedure CreateTaxRate()
    var
        TDSSetup: Record "TDS Setup";
        PageTaxtype: TestPage "Tax Types";
    begin
        if not TDSSetup.Get() then
            exit;
        PageTaxtype.OpenEdit();
        PageTaxtype.Filter.SetFilter(Code, TDSSetup."Tax Type");
        PageTaxtype.TaxRates.Invoke();
    end;

    local procedure CreateBankAccWithVoucherAccount(
        AccountType: Enum "Gen. Journal Account Type";
        VoucherType: Enum "Gen. Journal Template Type";
        var BankAccount: Record "Bank Account";
        var Location: Record Location): Code[20]
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        LibraryTDSOnCustomer.CreateLocationWithTANNo(Location);
        StorageEnum.Set(AccountTypeLbl, Format(AccountType));
        Storage.Set(AccountNoLbl, BankAccount."No.");
        CreateVoucherAccountSetup(VoucherType, Location.Code);
        exit(BankAccount."No.");
    end;

    local procedure CreateGLAccWithVoucherAccount(
        AccountType: Enum "Gen. Journal Account Type";
        VoucherType: Enum "Gen. Journal Template Type";
        var GLAccount: Record "G/L Account";
        var Location: Record Location): Code[20]
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryTDSOnCustomer.CreateLocationWithTANNo(Location);
        StorageEnum.Set(AccountTypeLbl, Format(AccountType));
        Storage.Set(AccountNoLbl, GLAccount."No.");
        CreateVoucherAccountSetup(VoucherType, Location.Code);
        exit(GLAccount."No.");
    end;

    local procedure CreateVoucherAccountSetup(SubType: Enum "Gen. Journal Template Type"; LocationCode: Code[10])
    var
        TaxBasePublishers: Codeunit "Tax Base Test Publishers";
        TransactionDirection: Option " ",Debit,Credit,Both;
        AccountNo: Code[20];
    begin
        AccountNo := Storage.Get(AccountNoLbl);
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    TaxBasePublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Credit);
                    TaxBasePublishers.InsertVoucherCreditAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher", SubType::"Journal Voucher":
                begin
                    TaxBasePublishers.InsertJournalVoucherPostingSetupWithLocationCode(SubType, LocationCode, TransactionDirection::Debit);
                    TaxBasePublishers.InsertVoucherDebitAccountNoWithLocationCode(SubType, LocationCode, AccountNo);
                end;
        end;
    end;

    [PageHandler]
    procedure TaxRatePageHandler(var TaxRates: TestPage "Tax Rates")
    var
        EffectiveDate: Date;
        TDSPercentage: Decimal;
        NonPANTDSPercentage: Decimal;
        SurchargePercentage: Decimal;
        eCessPercentage: Decimal;
        SHECessPercentage: Decimal;
        TDSThresholdAmount: Decimal;
        SurchargeThresholdAmount: Decimal;
    begin
        GenerateTaxComponentsPercentage();
        Evaluate(EffectiveDate, Storage.Get(EffectiveDateLbl), 9);
        Evaluate(TDSPercentage, Storage.Get(TDSPercentageLbl));
        Evaluate(NonPANTDSPercentage, Storage.Get(NonPANTDSPercentageLbl));
        Evaluate(SurchargePercentage, Storage.Get(SurchargePercentageLbl));
        Evaluate(eCessPercentage, Storage.Get(ECessPercentageLbl));
        Evaluate(SHECessPercentage, Storage.Get(SHECessPercentageLbl));
        Evaluate(TDSThresholdAmount, Storage.Get(TDSThresholdAmountLbl));
        Evaluate(SurchargeThresholdAmount, Storage.Get(SurchargeThresholdAmountLbl));

        TaxRates.New();
        TaxRates.AttributeValue1.SetValue(Storage.Get(SectionCodeLbl));
        TaxRates.AttributeValue2.SetValue(Storage.Get(TDSAssesseeCodeLbl));
        TaxRates.AttributeValue3.SetValue(EffectiveDate);
        TaxRates.AttributeValue4.SetValue(Storage.Get(TDSConcessionalCodeLbl));
        TaxRates.AttributeValue5.SetValue('');
        TaxRates.AttributeValue6.SetValue('');
        TaxRates.AttributeValue7.SetValue('');
        TaxRates.AttributeValue8.SetValue(TDSPercentage);
        TaxRates.AttributeValue9.SetValue(NonPANTDSPercentage);
        TaxRates.AttributeValue10.SetValue(SurchargePercentage);
        TaxRates.AttributeValue11.SetValue(eCessPercentage);
        TaxRates.AttributeValue12.SetValue(SHECessPercentage);
        TaxRates.AttributeValue13.SetValue(TDSThresholdAmount);
        TaxRates.AttributeValue14.SetValue(SurchargeThresholdAmount);
        TaxRates.AttributeValue15.SetValue(0);
        TaxRates.OK().Invoke();
    end;

    [PageHandler]
    procedure CheckTDSCertRecOnUpdateTDSCertDetailsPage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentNo: Code[20];
        Value: Variant;
    begin
        LibraryVariableStorage.Dequeue(Value);
        DocumentNo := Value;
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange("TDS Certificate Receivable", true);
        CustLedgerEntry.FindFirst();
        UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
        Assert.Equal(true, UpdateTDSCertDetails."TDS Certificate Receivable".AsBoolean());
    end;

    [PageHandler]
    procedure CheckWithoutTDSCertRecOnUpdateTDSCertDetailsPage(var UpdateTDSCertDetails: TestPage "Update TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        DocumentNo: Code[20];
        Value: Variant;
    begin
        LibraryVariableStorage.Dequeue(Value);
        DocumentNo := Value;
        CustLedgerEntry.SetRange("Document No.", DocumentNo);
        CustLedgerEntry.SetRange("TDS Certificate Receivable", false);
        CustLedgerEntry.FindFirst();
        asserterror UpdateTDSCertDetails.GoToRecord(CustLedgerEntry);
        Assert.ExpectedError(RowDoesNotExistErr);
    end;

    [PageHandler]
    procedure CheckTDSCertRecOnAssignTDSCertDetailsPage(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerNo: Code[20];
        Value: Variant;
    begin
        LibraryVariableStorage.Dequeue(Value);
        CustomerNo := Value;
        CustLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustLedgerEntry.SetRange("TDS Certificate Receivable", false);
        if not CustLedgerEntry.FindFirst() then;
        asserterror AssignTDSCertDetails.GoToRecord(CustLedgerEntry);
        Assert.ExpectedError(RowDoesNotExistErr);
    end;

    [PageHandler]
    procedure CheckWithoutTDSCertRecOnAssignTDSCertDetailsPage(var AssignTDSCertDetails: TestPage "Assign TDS Cert. Details")
    var
        CustomerLedgerEntry: Record "Cust. Ledger Entry";
        CustomerNo: Code[20];
        Value: Variant;
    begin
        LibraryVariableStorage.Dequeue(Value);
        CustomerNo := Value;
        CustomerLedgerEntry.SetRange("Customer No.", CustomerNo);
        CustomerLedgerEntry.SetRange("TDS Certificate Receivable", false);
        CustomerLedgerEntry.FindFirst();
        AssignTDSCertDetails.GoToRecord(CustomerLedgerEntry);
        Assert.RecordIsnotEmpty(CustomerLedgerEntry);
    end;
}