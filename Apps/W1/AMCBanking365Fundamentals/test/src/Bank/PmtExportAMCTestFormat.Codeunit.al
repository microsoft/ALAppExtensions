codeunit 134412 "Pmt. Export AMC - Test Format"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [Payment Export Data] [XML] [Credit Transfer Entry]
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryXPathXMLReader: Codeunit "Library - XPath XML Reader";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryAmcWebService: Codeunit "Library - Amc Web Service";
        Assert: Codeunit Assert;
        isInitialised: Boolean;
        CompanyInfoChanged: Boolean;

    local procedure Initialize()
    var
        PaymentExportData: Record "Payment Export Data";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        PaymentExportData.DeleteAll();
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        if AMCBankingSetup.Get() then
            AMCBankingSetup.Delete();
        if CompanyInformation."Country/Region Code" = 'FI' then begin
            CompanyInformation."Country/Region Code" := 'GB';
            CompanyInfoChanged := CompanyInformation.Modify();
        end;

        if isInitialised then
            exit;

        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.CreateVATData();
        isInitialised := true;
    end;

    local procedure Cleanup()
    begin
        if not CompanyInfoChanged then exit;
        CompanyInformation."Country/Region Code" := 'FI';
        CompanyInformation.Modify();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckFileWithAppliedPaymentsDomestic()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 1] Export payments applied to existing invoices.
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully or partially).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SuggestVendorPayments(Vendor, GenJournalBatch, false);
        SetupPmtDetails(GenJournalBatch);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure CheckFileWithUnappliedPaymentsDomestic()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 2] Export standalone payments (domestic).
        // [GIVEN] A number of payment lines unapplied to any domestic vendor invoices.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        // Information regarding applied invoices is not filled in, as per the linked mapping document.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SetupVendorPayments(DataExchDef, VendorBankAccount, BankAccount, GenJournalBatch);
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);

        // Exercise. Run the pre-mapping.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify. Payment Export Data.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure CheckFileWithUnappliedPaymentsDiffVendors()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 2] Export standalone payments belonging to different vendors.
        // [GIVEN] A number of payment lines unapplied to any domestic vendor invoices, but belonging to different vendors.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        // Information regarding applied invoices is not filled in, as per the linked mapping document.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SetupVendorPayments(DataExchDef, VendorBankAccount, BankAccount, GenJournalBatch);
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        SetupVendorPayments(DataExchDef, VendorBankAccount, BankAccount, GenJournalBatch);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);

        // Exercise. Run the pre-mapping.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify. Payment Export Data.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckFileWithDiffAccTypesDomestic()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        CrMemoGenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        Employee: Record Employee;
    begin
        // [SCENARIO 3] Export payments, both customer and vendor (domestic).
        // [GIVEN] A number of domestic vendor invoices and domestic customer credit memos.
        // [GIVEN] A number of payment/refund lines applied to them.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SuggestVendorPayments(Vendor, GenJournalBatch, false);

        SetupCustomerDetails(Customer, CustomerBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetRefundToDomestic(BankAccount, CustomerBankAccount);
        PostCustomerCreditMemo(CrMemoGenJournalLine, Customer."No.");

        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::"Credit Memo");
        GenJournalLine.Validate("Applies-to Doc. No.", CrMemoGenJournalLine."Document No.");
        GenJournalLine.Modify(true);

        LibraryHumanResource.CreateEmployeeWithBankAccount(Employee);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Employee, Employee."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Payment Method Code" := Vendor."Payment Method Code";
        GenJournalLine.Modify(true);
        SetupPmtDetails(GenJournalBatch);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckFileWithAppliedPaymentsInternational()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 4] Export payments applied to existing invoices.
        // [GIVEN] A number of non-domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully or partially).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");

        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SuggestVendorPayments(Vendor, GenJournalBatch, false);
        SetupPmtDetails(GenJournalBatch);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure CheckFileWithUnappliedPaymentsInternational()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 5] Export standalone payments (non-domestic).
        // [GIVEN] A number of payment lines unapplied to any non-domestic vendor invoices.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        // Information regarding applied invoices is not filled in, as per the linked mapping document.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SetupVendorPayments(DataExchDef, VendorBankAccount, BankAccount, GenJournalBatch);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure CheckFileWithDiffAccTypesInternational()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        // [SCENARIO 6] Export payments, both customer and vendor (non-domestic).
        // [GIVEN] A number of non-domestic vendor invoices and non-domestic customer credit memos.
        // [GIVEN] A number of payment/refund lines applied to them.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SetupVendorPayments(DataExchDef, VendorBankAccount, BankAccount, GenJournalBatch);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);

        SetupCustomerDetails(Customer, CustomerBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetRefundToInternational(BankAccount, CustomerBankAccount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        SetupPmtDetails(GenJournalBatch);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure CheckFileWithEntriesAppliedToJnlLine()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // [SCENARIO 6] Export payments (with "Applies-to ID"), both customer and vendor.
        // [GIVEN] A number of non-domestic vendor invoices and non-domestic customer credit memos applied to journal lines.
        // [GIVEN] A number of payment/refund lines.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The resulting file is populated with the payment information for:
        // - sender identification (creditor no., transit no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");

        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Applies-to ID", UserId());
        GenJournalLine.Modify(true);

        VendorLedgerEntry.SetRange("Vendor No.", Vendor."No.");
        VendorLedgerEntry.SetRange("Document Type", VendorLedgerEntry."Document Type"::Invoice);
        VendorLedgerEntry.FindLast();
        LibraryERM.SetAppliestoIdVendor(VendorLedgerEntry);

        SetupCustomerDetails(Customer, CustomerBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetRefundToDomestic(BankAccount, CustomerBankAccount);
        PostCustomerCreditMemo(GenJournalLine, Customer."No.");

        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, Customer."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Applies-to ID", UserId());
        GenJournalLine.Modify(true);

        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::"Credit Memo");
        LibraryERM.SetAppliestoIdCustomer(CustLedgerEntry);
        SetupPmtDetails(GenJournalBatch);

        // Exercise.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Verify.
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    local procedure SuggestVendorPaymentsSkipParameter(SkipExportedPayments: Boolean)
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());
        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SuggestVendorPayments(Vendor, GenJournalBatch, false);
        SetupPmtDetails(GenJournalBatch);

        // Export payments
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Exercise
        GenJournalLine.DeleteAll();
        SuggestVendorPayments(Vendor, GenJournalBatch, SkipExportedPayments);

        // Verify - no payments
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        if SkipExportedPayments then
            Assert.IsTrue(GenJournalLine.IsEmpty(), 'Payments were already exported so they should not be suggested again.')
        else
            Assert.IsFalse(GenJournalLine.IsEmpty(), 'Payments already exported should be suggested again as skip param is FALSE.');
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure TestSuggestVendorPaymentsSkipsExportedPayments()
    begin
        // [FEATURE] [Suggest Vendor Payments]
        // [SCENARIO] Export payments applied to existing invoices and exported payments are not suggested again
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [GIVEN] Payments are exported
        // [WHEN] Suggest vendor payments is called with skip param TRUE
        // [THEN] Suggest vendor payments will not suggest already exported payments
        // More details in the linked document in the deliverable.

        SuggestVendorPaymentsSkipParameter(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure TestSuggestVendorPaymentsSkipExportedPaymentsIsFalse()
    begin
        // [FEATURE] [Suggest Vendor Payments]
        // [SCENARIO] Export payments applied to existing invoices and exported payments are suggested again if skip param is FALSE
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [GIVEN] Payments are exported
        // [WHEN] Suggest vendor payments is called with skip param FALSE
        // [THEN] Suggest vendor payments will suggest already exported payments
        // More details in the linked document in the deliverable.

        SuggestVendorPaymentsSkipParameter(false);
    end;

    local procedure SuggestVendorPaymentsCancelledExports(ReExport: Boolean)
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostMultipleInvoices(Vendor."No.");
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), BankAccount."No.");
        SuggestVendorPayments(Vendor, GenJournalBatch, false);
        SetupPmtDetails(GenJournalBatch);

        // Export payments
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.ExportPaymentFile();

        // Exercise
        CancelExportEntriesForVendor(Vendor."No.");
        if ReExport then
            GenJournalLine.ExportPaymentFile();
        GenJournalLine.DeleteAll();
        SuggestVendorPayments(Vendor, GenJournalBatch, true);

        // Verify
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        Assert.IsTrue(GenJournalLine.IsEmpty(),
          'Payments already exported should not be suggested again even if they are "canceled".');
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckSuggestVendorPaymentsCancelledExports()
    begin
        // [FEATURE] [Suggest Vendor Payments]
        // [SCENARIO] Export payments applied to existing invoices and exported payments and canceled are suggested again
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [GIVEN] Payments are exported and then cancelled
        // [WHEN] Suggest vendor payments is called with skip param TRUE
        // [THEN] Suggest vendor payments will suggest already exported payments and cancelled
        // More details in the linked document in the deliverable.
        SuggestVendorPaymentsCancelledExports(false);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckSuggestVendorPaymentsCancelledExportsReExport()
    begin
        // [FEATURE] [Suggest Vendor Payments]
        // [SCENARIO] Export payments applied to existing invoices and exported payments, canceled and re-exported are not suggested again
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [GIVEN] Payments are exported and then cancelled and re-exported
        // [WHEN] Suggest vendor payments is called with skip param TRUE
        // [THEN] Suggest vendor payments will not suggest already exported payments
        // More details in the linked document in the deliverable.
        SuggestVendorPaymentsCancelledExports(true);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerYes')]
    [Scope('OnPrem')]
    procedure BalAccountNoTakenFromGenJnlLine()
    var
        DataExchDef: Record "Data Exch. Def";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [FEATURE] [Export Payment File]
        // [SCENARIO 287640] ExportPaymentFile when "Bal. Account No." is not set in GenJournalBatch but set in GenJournalLine
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // [GIVEN] Vendor with an invoice posted
        CreateBankAccountWithDetails(BankAccount);
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostPurchaseInvoice(Vendor."No.");

        // [GIVEN] Payment GenJournalBatch without "Bal. Account No." set
        CreatePmtJnlBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate(), '');

        // [GIVEN] Suggested Vendor payments for GenJournalBatch and Vendor
        SuggestVendorPayments(Vendor, GenJournalBatch, false);
        SetupPmtDetails(GenJournalBatch);

        // [GIVEN] "Bal. Account No." validated in GenJournalLine
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindFirst();
        GenJournalLine.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalLine.Modify(true);

        // [WHEN] Run ExportPaymentFile on generated Vendor Payments
        GenJournalLine.ExportPaymentFile();

        // [THEN] Verify Export
        VerifyXmlFile(DataExchDef, GenJournalLine);
        VerifyGenJnlLineCleanup(GenJournalBatch);
        Cleanup();
    end;

    local procedure SuggestVendorPayments(var Vendor: Record Vendor; GenJournalBatch: Record "Gen. Journal Batch"; SkipExportedPayments: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        SuggestVendorPaymentsReport: Report "Suggest Vendor Payments";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.Validate("Journal Batch Name", GenJournalBatch.Name);
        with SuggestVendorPaymentsReport do begin
            SetGenJnlLine(GenJournalLine);
            SetTableView(Vendor);
            InitializeRequest(WorkDate(), false, 0, SkipExportedPayments, WorkDate(), LibraryUtility.GenerateGUID(), false,
              GenJournalBatch."Bal. Account Type", GenJournalBatch."Bal. Account No.", 0);
            UseRequestPage(false);
            RunModal();
        end;
    end;

    local procedure SetupVendorDetails(var Vendor: Record Vendor; var VendorBankAccount: Record "Vendor Bank Account"; DataExchLineDef: Code[20])
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccountWithDetails(VendorBankAccount, Vendor."No.");
        CreatePaymentMethodWithDetails(PaymentMethod, DataExchLineDef);
        Vendor.Validate("Payment Method Code", PaymentMethod.Code);
        Vendor.Validate("Preferred Bank Account Code", VendorBankAccount.Code);
        Vendor.Validate(Name,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(Name), DATABASE::Vendor));
        Vendor.Validate(Address,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(Address), DATABASE::Vendor));
        Vendor.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo("Address 2"), DATABASE::Vendor));
        Vendor.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        Vendor.Validate(City,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(City), DATABASE::Vendor));
        Vendor.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo("Post Code"), DATABASE::Vendor));
        Vendor.Modify(true);
        Vendor.SetRange("No.", Vendor."No.");
    end;

    local procedure SetupCustomerDetails(var Customer: Record Customer; var CustomerBankAccount: Record "Customer Bank Account"; DataExchLineDef: Code[20])
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCustomerBankAccountWithDetails(CustomerBankAccount, Customer."No.");
        CreatePaymentMethodWithDetails(PaymentMethod, DataExchLineDef);
        Customer.Validate("Payment Method Code", PaymentMethod.Code);
        Customer.Validate("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.Validate(Name,
          LibraryUtility.GenerateRandomCode(Customer.FieldNo(Name), DATABASE::Customer));
        Customer.Validate(Address,
          LibraryUtility.GenerateRandomCode(Customer.FieldNo(Address), DATABASE::Customer));
        Customer.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(Customer.FieldNo("Address 2"), DATABASE::Customer));
        Customer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.Validate(City,
          LibraryUtility.GenerateRandomCode(Customer.FieldNo(City), DATABASE::Customer));
        Customer.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(Customer.FieldNo("Post Code"), DATABASE::Customer));
        Customer.Modify(true);
        Customer.SetRange("No.", Customer."No.");
    end;

    local procedure SetupPmtDetails(GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindSet();
        repeat
            GenJournalLine."Payment Reference" := LibraryUtility.GenerateGUID();
            GenJournalLine.Validate("Applies-to Ext. Doc. No.",
              LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Applies-to Ext. Doc. No."), DATABASE::"Gen. Journal Line"));
            GenJournalLine.Modify(true);
        until GenJournalLine.Next() = 0;
    end;

    local procedure SelectAMCCreditTransferFormat(): Code[20]
    var
        DataExchDef: Record "Data Exch. Def";
        DataExchMapping: Record "Data Exch. Mapping";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        DataExchDef.SetRange("File Type", DataExchDef."File Type"::Xml);
        DataExchDef.SetRange(Type, DataExchDef.Type::"Payment Export");
        DataExchDef.FindSet();
        repeat
            DataExchMapping.SetRange("Data Exch. Def Code", DataExchDef.Code);
            DataExchMapping.SetRange("Table ID", DATABASE::"Payment Export Data");
            DataExchMapping.SetRange("Mapping Codeunit", CODEUNIT::"AMC Bank Exp. CT Pre-Map");
            if not DataExchMapping.IsEmpty() then begin
                BankExportImportSetup.SetRange("Data Exch. Def. Code", DataExchDef.Code);
                if BankExportImportSetup.FindFirst() then begin
                    UpdateAMCCreditTransferFormat(DataExchDef);
                    exit(BankExportImportSetup.Code);
                end;
            end;
        until DataExchDef.Next() = 0;
        exit('');
    end;

    local procedure GetDataExchLineDef(var DataExchDef: Record "Data Exch. Def"; BankAccount: Record "Bank Account"): Code[20]
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        DataExchLineDef: Record "Data Exch. Line Def";
    begin
        BankExportImportSetup.Get(BankAccount."Payment Export Format");
        DataExchDef.Get(BankExportImportSetup."Data Exch. Def. Code");
        DataExchLineDef.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExchLineDef.FindFirst();
        exit(DataExchLineDef.Code);
    end;

    local procedure UpdateAMCCreditTransferFormat(var DataExchDef: Record "Data Exch. Def")
    begin
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"Save Data Exch. Blob Sample";
        DataExchDef."User Feedback Codeunit" := CODEUNIT::"Exp. User Feedback Gen. Jnl.";
        DataExchDef."Validation Codeunit" := 0;
        DataExchDef.Modify(true);
    end;

    local procedure CreatePmtJnlBatch(var GenJournalBatch: Record "Gen. Journal Batch"; GenJnlTemplateName: Code[10]; BankAccountNo: Code[20])
    begin
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJnlTemplateName);
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccountNo);
        GenJournalBatch.Validate("Allow Payment Export", true);
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateVendorBankAccountWithDetails(var VendorBankAccount: Record "Vendor Bank Account"; VendorNo: Code[20])
    var
        BankClearingStandard: Record "Bank Clearing Standard";
    begin
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, VendorNo);
        VendorBankAccount.Validate(Name,
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo(Name), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate(Address,
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo(Address), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo("Address 2"), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate(City,
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo(City), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo("Post Code"), DATABASE::"Vendor Bank Account"));
        VendorBankAccount."Bank Account No." :=
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo("Bank Account No."), DATABASE::"Vendor Bank Account");
        VendorBankAccount.Validate(IBAN,
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo(IBAN), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate("SWIFT Code",
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo("SWIFT Code"), DATABASE::"Vendor Bank Account"));
        VendorBankAccount.Validate("Bank Clearing Code",
          LibraryUtility.GenerateRandomCode(VendorBankAccount.FieldNo("Bank Clearing Code"), DATABASE::"Vendor Bank Account"));
        BankClearingStandard.FindFirst();
        VendorBankAccount.Validate("Bank Clearing Standard", BankClearingStandard.Code);
        VendorBankAccount.Modify(true);
    end;

    local procedure CreateCustomerBankAccountWithDetails(var CustomerBankAccount: Record "Customer Bank Account"; CustomerNo: Code[20])
    var
        BankClearingStandard: Record "Bank Clearing Standard";
    begin
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, CustomerNo);
        CustomerBankAccount.Validate(Name,
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo(Name), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate(Address,
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo(Address), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo("Address 2"), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate(City,
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo(City), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo("Post Code"), DATABASE::"Customer Bank Account"));
        CustomerBankAccount."Bank Account No." :=
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo("Bank Account No."), DATABASE::"Customer Bank Account");
        CustomerBankAccount.Validate(IBAN,
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo(IBAN), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate("SWIFT Code",
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo("SWIFT Code"), DATABASE::"Customer Bank Account"));
        CustomerBankAccount.Validate("Bank Clearing Code",
          LibraryUtility.GenerateRandomCode(CustomerBankAccount.FieldNo("Bank Clearing Code"), DATABASE::"Customer Bank Account"));
        BankClearingStandard.FindFirst();
        CustomerBankAccount.Validate("Bank Clearing Standard", BankClearingStandard.Code);
        CustomerBankAccount.Modify(true);
    end;

    local procedure CreateBankAccountWithDetails(var BankAccount: Record "Bank Account")
    var
        BankClearingStandard: Record "Bank Clearing Standard";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate(Name,
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(Name), DATABASE::"Bank Account"));
        BankAccount.Validate(Address,
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(Address), DATABASE::"Bank Account"));
        BankAccount.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Address 2"), DATABASE::"Bank Account"));
        BankAccount.Validate(City,
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(City), DATABASE::"Bank Account"));
        BankAccount.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Post Code"), DATABASE::"Bank Account"));
        BankAccount."Bank Account No." :=
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Bank Account No."), DATABASE::"Bank Account");
        BankAccount.Validate(IBAN,
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo(IBAN), DATABASE::"Bank Account"));
        BankAccount.Validate("SWIFT Code",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("SWIFT Code"), DATABASE::"Bank Account"));
        BankAccount.Validate("Bank Clearing Code",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Bank Clearing Code"), DATABASE::"Bank Account"));
        BankClearingStandard.FindFirst();
        BankAccount.Validate("Bank Clearing Standard", BankClearingStandard.Code);
        BankAccount.Validate("AMC Bank Name",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("AMC Bank Name"), DATABASE::"Bank Account"));
        BankAccount.Validate("Creditor No.",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Creditor No."), DATABASE::"Bank Account"));
        BankAccount.Validate("Transit No.",
          LibraryUtility.GenerateRandomCode(BankAccount.FieldNo("Transit No."), DATABASE::"Bank Account"));
        BankAccount.Validate("Credit Transfer Msg. Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        BankAccount.Validate("Payment Export Format", SelectAMCCreditTransferFormat());
        BankAccount.Modify(true);
    end;

    local procedure CreatePaymentMethodWithDetails(var PaymentMethod: Record "Payment Method"; DataExchLineDef: Code[20])
    var
        AMCBankPmtType: Record "AMC Bank Pmt. Type";
    begin
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        CreateAMCBankPmtType(AMCBankPmtType);
        PaymentMethod.Validate("Pmt. Export Line Definition", DataExchLineDef);
        PaymentMethod.Validate("AMC Bank Pmt. Type", AMCBankPmtType.Code);
        PaymentMethod.Modify(true);
    end;

    local procedure CreateAMCBankPmtType(var AMCBankPmtType: Record "AMC Bank Pmt. Type")
    begin
        AMCBankPmtType.Init();
        AMCBankPmtType.Validate(Code,
          LibraryUtility.GenerateRandomCode(AMCBankPmtType.FieldNo(Code), DATABASE::"AMC Bank Pmt. Type"));
        AMCBankPmtType.Insert();
    end;

    local procedure CancelExportEntriesForVendor(VendorNo: Code[20])
    var
        CreditTransferRegister: Record "Credit Transfer Register";
        CreditTransferEntry: Record "Credit Transfer Entry";
    begin
        CreditTransferEntry.SetRange("Account Type", CreditTransferEntry."Account Type"::Vendor);
        CreditTransferEntry.SetRange("Account No.", VendorNo);
        if CreditTransferEntry.FindSet() then
            repeat
                CreditTransferRegister.Get(CreditTransferEntry."Credit Transfer Register No.");
                CreditTransferRegister.Validate(Status, CreditTransferRegister.Status::Canceled);
                CreditTransferRegister.Modify(true);
            until CreditTransferEntry.Next() = 0;
    end;

    local procedure PostMultipleInvoices(VendorNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::Vendor, VendorNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine.Modify();
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::Vendor, VendorNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure PostCustomerCreditMemo(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::"Credit Memo",
          GenJournalLine."Account Type"::Customer, CustomerNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure PostPurchaseInvoice(VendorNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GLAccount: Record "G/L Account";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::Vendor, VendorNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure SetupVendorPayments(var DataExchDef: Record "Data Exch. Def"; var VendorBankAccount: Record "Vendor Bank Account"; BankAccount: Record "Bank Account"; GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
        Vendor: Record Vendor;
    begin
        SetupVendorDetails(Vendor, VendorBankAccount, GetDataExchLineDef(DataExchDef, BankAccount));
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetupPmtDetails(GenJournalBatch);
    end;

    local procedure GetAppliedCustEntry(GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        if GenJournalLine."Applies-to ID" <> '' then begin
            CustLedgerEntry.SetRange("Customer No.", GenJournalLine."Account No.");
            CustLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            if CustLedgerEntry.FindFirst() then
                exit(CustLedgerEntry."Entry No.");
        end;
        CustLedgerEntry.SetRange("Applies-to ID");
        CustLedgerEntry.SetRange("Applies-to Doc. Type", GenJournalLine."Document Type");
        CustLedgerEntry.SetRange("Applies-to Doc. No.", GenJournalLine."Document No.");
        if CustLedgerEntry.FindFirst() then
            exit(CustLedgerEntry."Entry No.");
    end;

    local procedure GetAppliedVendorEntry(GenJournalLine: Record "Gen. Journal Line"): Integer
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        if GenJournalLine."Applies-to ID" <> '' then begin
            VendorLedgerEntry.SetRange("Vendor No.", GenJournalLine."Account No.");
            VendorLedgerEntry.SetRange("Applies-to ID", GenJournalLine."Applies-to ID");
            if VendorLedgerEntry.FindFirst() then
                exit(VendorLedgerEntry."Entry No.");
        end;
        VendorLedgerEntry.SetRange("Applies-to ID");
        VendorLedgerEntry.SetRange("Applies-to Doc. Type", GenJournalLine."Document Type");
        VendorLedgerEntry.SetRange("Applies-to Doc. No.", GenJournalLine."Document No.");
        if VendorLedgerEntry.FindFirst() then
            exit(VendorLedgerEntry."Entry No.");
    end;

    local procedure PrefixXPath(SourceText: Text; FindText: Text; ReplaceText: Text): Text
    var
        pos: Integer;
    begin
        if ((StrPos(SourceText, FindText) > 0) and (StrPos(SourceText, ReplaceText) = 0)) then begin
            pos := StrPos(SourceText, FindText);
            SourceText := DelStr(SourceText, pos, STRLEN(FindText));
            SourceText := InsStr(SourceText, ReplaceText, pos);
        END;
        exit(SourceText);
    end;

    local procedure VerifyXmlFile(DataExchDef: Record "Data Exch. Def"; var GenJournalLine: Record "Gen. Journal Line")
    var
        DataExch: Record "Data Exch.";
        BankAccount: Record "Bank Account";
        PaymentMethod: Record "Payment Method";
        TypeHelper: Codeunit "Type Helper";
        LineNo: Integer;
        Amount: Decimal;
        SpecIndex: integer;
    begin
        DataExch.SetRange("Data Exch. Def Code", DataExchDef.Code);
        DataExch.FindLast();
        DataExch.CalcFields("File Content");
        LibraryXPathXMLReader.Initialize(DataExch."File Name", AMCBankingMgt.GetNamespace());
        LibraryXPathXMLReader.SetDefaultNamespaceUsage(false);
        GenJournalLine.FindSet();
        repeat
            LineNo += 1;
            BankAccount.Get(GenJournalLine."Bal. Account No.");
            PaymentMethod.Get(GenJournalLine."Payment Method Code");
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/journalname', '/', '/ns:'),
              GenJournalLine."Journal Template Name", 0);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(PrefixXPath('/paymentExportBank/bank', '/', '/ns:'),
              BankAccount."AMC Bank Name", 0);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccount', '/', '/ns:'),
              BankAccount.GetBankAccountNo(), LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/intregno', '/', '/ns:'),
              BankAccount."Bank Clearing Code", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/intregnotype', '/', '/ns:'),
              BankAccount."Bank Clearing Standard", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/swiftcode', '/', '/ns:'),
              BankAccount."SWIFT Code", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/address1', '/', '/ns:'),
              BankAccount.Address, LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/city', '/', '/ns:'),
              BankAccount.City, LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/name', '/', '/ns:'),
              BankAccount.Name, LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/countryiso', '/', '/ns:'),
              BankAccount."Country/Region Code", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownbankaccount/bankaccountaddress/zipcode', '/', '/ns:'),
              BankAccount."Post Code", LineNo - 1);
            /* Does not exist in API04
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/bankaccountcurrency', '/', '/ns:'),
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"), LineNo - 1); 
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/countryoforigin', '/', '/ns:'),
              BankAccount."Country/Region Code", 0); 
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/messagetoownbank', '/', '/ns:'),
              Format(GenJournalLine."Line No."), LineNo - 1); */
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/shortadvice', '/', '/ns:'),
              GenJournalLine."Applies-to Ext. Doc. No.", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/customerid', '/', '/ns:'),
              GenJournalLine."Account No.", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/costs', '/', '/ns:'),
              'Shared', LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/paymenttype', '/', '/ns:'),
              PaymentMethod."AMC Bank Pmt. Type", LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/reference', '/', '/ns:'),
              GenJournalLine."Payment Reference", LineNo - 1);
            Amount := GenJournalLine.Amount; // to avoid DecimalPaces property affects the FORMAT
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/payamount', '/', '/ns:'),
              FORMAT(Amount, 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/paycurrency', '/', '/ns:'),
              GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code"), LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/amountdetails/paydate', '/', '/ns:'),
              GetDateTime(GenJournalLine."Posting Date"), LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/messagestructure', '/', '/ns:'),
              'auto', LineNo - 1);
            LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownaddressinfo', '/', '/ns:'),
              'frombank', LineNo - 1);

            case GenJournalLine."Account Type" of
                GenJournalLine."Account Type"::Vendor:
                    VerifyVendorDetails(GenJournalLine, LineNo, SpecIndex);
                GenJournalLine."Account Type"::Customer:
                    VerifyCustomerDetails(GenJournalLine, LineNo, SpecIndex);
            end;

        until GenJournalLine.Next() = 0;
    end;

    local procedure VerifyVendorDetails(GenJournalLine: Record "Gen. Journal Line"; LineNo: Integer; var SpecIndex: Integer)
    var
        CreditTransferEntry: record "Credit Transfer Entry";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        Vendor: Record Vendor;
        VendorBankAccount: Record "Vendor Bank Account";
        TypeHelper: Codeunit "Type Helper";
        transthemuniqueid: Text;
    begin
        Vendor.Get(GenJournalLine."Account No.");
        VendorBankAccount.Get(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account");

        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
              PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/ownreference', '/', '/ns:'),
              Vendor.Name, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/address1', '/', '/ns:'),
          Vendor.Address, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/city', '/', '/ns:'),
          Vendor.City, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/name', '/', '/ns:'),
          Vendor.Name, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/countryiso', '/', '/ns:'),
          Vendor."Country/Region Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/zipcode', '/', '/ns:'),
          Vendor."Post Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccount', '/', '/ns:'),
          VendorBankAccount.GetBankAccountNo(), LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregno', '/', '/ns:'),
          VendorBankAccount."Bank Clearing Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregnotype', '/', '/ns:'),
          VendorBankAccount."Bank Clearing Standard", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/swiftcode', '/', '/ns:'),
          VendorBankAccount."SWIFT Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/address1', '/', '/ns:'),
          VendorBankAccount.Address, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/city', '/', '/ns:'),
          VendorBankAccount.City, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/name', '/', '/ns:'),
          VendorBankAccount.Name, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/' +
          'bankaccountaddress/countryiso', '/', '/ns:'), VendorBankAccount."Country/Region Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/zipcode', '/', '/ns:'),
          VendorBankAccount."Post Code", LineNo - 1);

        //Fetch Payment Information Id - to use in test of banktransspec
        transthemuniqueid := LibraryXPathXMLReader.GetNodeInnerTextByXPathWithIndex(PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/uniqueid', '/', '/ns:'), Lineno - 1);
        if (transthemuniqueid <> '') then begin
            CreditTransferEntry.SETRANGE(CreditTransferEntry."Data Exch. Entry No.", GenJournalLine."Data Exch. Entry No.");
            CreditTransferEntry.SETRANGE(CreditTransferEntry."Transaction ID", transthemuniqueid);
            if (CreditTransferEntry.FindSet()) then
                repeat
                    GetCVLedgerEntryBuffer(CVLedgerEntryBuffer, CreditTransferEntry);
                    LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                      PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/discountused', '/', '/ns:'),
                      FORMAT(CreditTransferEntry."Pmt. Disc. Possible", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    if (CVLedgerEntryBuffer."Entry No." <> 0) then begin
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/invoiceref', '/', '/ns:'),
                          CVLedgerEntryBuffer.Description, SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origdate', '/', '/ns:'),
                          GetDateTime(CVLedgerEntryBuffer."Document Date"), SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origamount', '/', '/ns:'),
                          FORMAT(-CVLedgerEntryBuffer."Original Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    end
                    else begin
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                            PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/invoiceref', '/', '/ns:'),
                            CreditTransferEntry."Message to Recipient", SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origdate', '/', '/ns:'),
                          GetDateTime(CreditTransferEntry."Transfer Date"), SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origamount', '/', '/ns:'),
                          FORMAT(CreditTransferEntry."Transfer Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    end;
                    SpecIndex += 1;
                until CreditTransferEntry.Next() = 0;
        end;
    end;

    local procedure GetDateTime(DateVariant: Variant): Text;
    var
        DateTimeValue: DateTime;
    begin
        EVALUATE(DateTimeValue, FORMAT(DateVariant, 0, 9), 9);
        DateVariant := DateTimeValue;
        exit(FORMAT(DateVariant, 0, 9));
    end;

    local procedure GetCVLedgerEntryBuffer(var CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer" temporary; CreditTransferEntry: Record "Credit Transfer Entry");
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        EmployeeLedgerEntry: Record "Employee Ledger Entry";
    begin
        Clear(CVLedgerEntryBuffer);
        if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Vendor) then begin
            VendorLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
            if (VendorLedgerEntry.get(CreditTransferEntry."Applies-to Entry No.")) then begin
                CVLedgerEntryBuffer.CopyFromVendLedgEntry(VendorLedgerEntry);
                if (VendorLedgerEntry."External Document No." <> '') then
                    CVLedgerEntryBuffer.Description := VendorLedgerEntry."External Document No." //1. Prio
                else
                    CVLedgerEntryBuffer.Description := VendorLedgerEntry.Description; //2. Prio
            end;
        end
        else
            if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Customer) then begin
                CustLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                if (CustLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then begin
                    CVLedgerEntryBuffer.CopyFromCustLedgEntry(CustLedgerEntry);
                    if (CustLedgerEntry."Document Date" <> 0D) then
                        CVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Document Date"
                    else
                        CVLedgerEntryBuffer."Document Date" := CustLedgerEntry."Posting Date";
                end;
            end
            else
                if (CreditTransferEntry."Account Type" = CreditTransferEntry."Account Type"::Employee) then begin
                    EmployeeLedgerEntry.SetAutoCalcFields("Remaining Amount", "Original Amount");
                    if (EmployeeLedgerEntry.Get(CreditTransferEntry."Applies-to Entry No.")) then
                        CVLedgerEntryBuffer.CopyFromEmplLedgEntry(EmployeeLedgerEntry);
                    CVLedgerEntryBuffer."Document Date" := EmployeeLedgerEntry."Posting Date";
                end;
    end;

    local procedure VerifyCustomerDetails(GenJournalLine: Record "Gen. Journal Line"; LineNo: Integer; var SpecIndex: Integer)
    var
        CreditTransferEntry: record "Credit Transfer Entry";
        CVLedgerEntryBuffer: Record "CV Ledger Entry Buffer";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        TypeHelper: Codeunit "Type Helper";
        transthemuniqueid: Text;
    begin
        Customer.Get(GenJournalLine."Account No.");
        CustomerBankAccount.Get(GenJournalLine."Account No.", GenJournalLine."Recipient Bank Account");
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/address1', '/', '/ns:'),
          Customer.Address, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/city', '/', '/ns:'),
          Customer.City, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/name', '/', '/ns:'),
          Customer.Name, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/countryiso', '/', '/ns:'),
          Customer."Country/Region Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversaddress/zipcode', '/', '/ns:'),
          Customer."Post Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccount', '/', '/ns:'),
          CustomerBankAccount.GetBankAccountNo(), LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregno', '/', '/ns:'),
          CustomerBankAccount."Bank Clearing Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/intregnotype', '/', '/ns:'),
          CustomerBankAccount."Bank Clearing Standard", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/swiftcode', '/', '/ns:'),
          CustomerBankAccount."SWIFT Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/address1', '/', '/ns:'),
          CustomerBankAccount.Address, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/city', '/', '/ns:'),
          CustomerBankAccount.City, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/name', '/', '/ns:'),
          CustomerBankAccount.Name, LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/' +
          'bankaccountaddress/countryiso', '/', '/ns:'), CustomerBankAccount."Country/Region Code", LineNo - 1);
        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/receiversbankaccount/bankaccountaddress/zipcode', '/', '/ns:'),
          CustomerBankAccount."Post Code", LineNo - 1);
        //Fetch Payment Information Id - to use in test of banktransspec
        transthemuniqueid := LibraryXPathXMLReader.GetNodeInnerTextByXPathWithIndex(PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/uniqueid', '/', '/ns:'), Lineno - 1);
        if (transthemuniqueid <> '') then begin
            CreditTransferEntry.SETRANGE(CreditTransferEntry."Data Exch. Entry No.", GenJournalLine."Data Exch. Entry No.");
            CreditTransferEntry.SETRANGE(CreditTransferEntry."Transaction ID", transthemuniqueid);
            if (CreditTransferEntry.FindSet()) then
                repeat
                    GetCVLedgerEntryBuffer(CVLedgerEntryBuffer, CreditTransferEntry);
                    LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                      PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/discountused', '/', '/ns:'),
                      FORMAT(CreditTransferEntry."Pmt. Disc. Possible", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    if (CVLedgerEntryBuffer."Entry No." <> 0) then begin
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/invoiceref', '/', '/ns:'),
                          CVLedgerEntryBuffer.Description, SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origdate', '/', '/ns:'),
                          GetDateTime(CVLedgerEntryBuffer."Document Date"), SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origamount', '/', '/ns:'),
                          FORMAT(-CVLedgerEntryBuffer."Original Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    end
                    else begin
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                            PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/invoiceref', '/', '/ns:'),
                            CreditTransferEntry."Message to Recipient", SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origdate', '/', '/ns:'),
                          GetDateTime(CreditTransferEntry."Transfer Date"), SpecIndex);
                        LibraryXPathXMLReader.VerifyNodeValueByXPathWithIndex(
                          PrefixXPath('/paymentExportBank/amcpaymentreq/banktransjournal/banktransus/banktransthem/banktransspec/origamount', '/', '/ns:'),
                          FORMAT(CreditTransferEntry."Transfer Amount", 0, TypeHelper.GetXMLAmountFormatWithTwoDecimalPlaces()), SpecIndex);
                    end;
                    SpecIndex += 1;
                until CreditTransferEntry.Next() = 0;
        end;
    end;

    local procedure VerifyGenJnlLineCleanup(GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.FindSet();
        repeat
            case GenJournalLine."Account Type" of
                GenJournalLine."Account Type"::Customer:
                    if CustLedgerEntry.Get(GenJournalLine.GetAppliesToDocEntryNo()) or
                       CustLedgerEntry.Get(GetAppliedCustEntry(GenJournalLine))
                    then
                        CustLedgerEntry.TestField("Exported to Payment File", true);
                GenJournalLine."Account Type"::Vendor:
                    if VendorLedgerEntry.Get(GenJournalLine.GetAppliesToDocEntryNo()) or
                       VendorLedgerEntry.Get(GetAppliedVendorEntry(GenJournalLine))
                    then
                        VendorLedgerEntry.TestField("Exported to Payment File", true);
            end;
            GenJournalLine.TestField("Exported to Payment File", true);
        until GenJournalLine.Next() = 0;
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerYes(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}