codeunit 134411 "Pmt. Export AMC - Extract Data"
{
    Permissions = TableData "Data Exch." = i,
                  TableData "Payment Export Data" = d;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [AMC Banking Fundamentals] [Payment Export Data] [UT]
    end;

    var
        CompanyInformation: Record "Company Information";
        GeneralLedgerSetup: Record "General Ledger Setup";
        AMCBankingMgt: Codeunit "AMC Banking Mgt.";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryPaymentExport: Codeunit "Library - Payment Export";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryHumanResource: Codeunit "Library - Human Resource";
        LibraryAmcWebService: Codeunit "Library - Amc Web Service";
        isInitialised: Boolean;
        CompanyInfoChanged: Boolean;
        MissingBankNameDataConvErr: Label '%1 must have a value', Comment = '%1=Bank Name';

    local procedure Initialize()
    var
        PaymentExportData: Record "Payment Export Data";
        AMCBankingSetup: Record "AMC Banking Setup";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Pmt. Export AMC - Extract Data");
        PaymentExportData.DeleteAll();
        if AMCBankingSetup.Get() then
            AMCBankingSetup.Delete();
        GeneralLedgerSetup.Get();
        CompanyInformation.Get();
        if CompanyInformation."Country/Region Code" = 'FI' then begin
            CompanyInformation."Country/Region Code" := 'GB';
            CompanyInfoChanged := CompanyInformation.Modify();
        end;

        if isInitialised then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Pmt. Export AMC - Extract Data");

        isInitialised := true;
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERMCountryData.UpdateGeneralLedgerSetup();
        LibraryERMCountryData.CreateVATData();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Pmt. Export AMC - Extract Data");
    end;

    local procedure Cleanup()
    begin
        if not CompanyInfoChanged then exit;
        CompanyInformation."Country/Region Code" := 'FI';
        CompanyInformation.Modify();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForAppliedPaymentsDomestic()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [SCENARIO 1] Export a number of payments applied to an existing vendor invoices.
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully or partially).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostVendorInvoice(Vendor."No.");

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        SuggestVendorPayments(Vendor, GenJournalBatch);
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(GenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(GenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForUnappliedPaymentsDomestic()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 2] Export a number of standalone not applied payments.
        // [GIVEN] A number of payment lines unapplied to any domestic vendor invoices.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        // Information regarding applied invoices is not filled in, as per the linked mapping document.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(GenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(GenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForDiffAccTypesDomestic()
    var
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        PmtGenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        CrMemoGenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
        Employee: Record Employee;
    begin
        // [SCENARIO 3] Export a number of payments, both customer and vendor, applied to invoices/credit memos.
        // [GIVEN] A number of domestic vendor invoices and domestic customer credit memos.
        // [GIVEN] A number of payment/refund lines applied to them.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        SetupCustomerDetails(Customer, CustomerBankAccount);
        LibraryHumanResource.CreateEmployee(Employee);
        Employee."Bank Account No." := LibraryUtility.GenerateGUID();
        Employee.IBAN := LibraryUtility.GenerateGUID();
        Employee.Modify();

        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        LibraryPaymentExport.SetRefundToDomestic(BankAccount, CustomerBankAccount);

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(CrMemoGenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::"Credit Memo",
          CrMemoGenJournalLine."Account Type"::Customer, Customer."No.", GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        LibraryERM.PostGeneralJnlLine(CrMemoGenJournalLine);

        LibraryERM.CreateGenJournalBatch(PmtGenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        PmtGenJournalBatch.Validate("Bal. Account Type", PmtGenJournalBatch."Bal. Account Type"::"Bank Account");
        PmtGenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        PmtGenJournalBatch.Modify(true);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          PmtGenJournalBatch."Journal Template Name", PmtGenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          PmtGenJournalBatch."Journal Template Name", PmtGenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, Customer."No.", -LibraryRandom.RandDec(1000, 2));
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::"Credit Memo");
        GenJournalLine.Validate("Applies-to Doc. No.", CrMemoGenJournalLine."Document No.");
        GenJournalLine.Modify(true);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          PmtGenJournalBatch."Journal Template Name", PmtGenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Employee, Employee."No.", LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Payment Method Code" := Vendor."Payment Method Code";
        GenJournalLine."Message to Recipient" := LibraryUtility.GenerateGUID();
        GenJournalLine.Modify();
        SetupPmtDetails(PmtGenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(PmtGenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(PmtGenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        VerifyCustomerPaymentExportData(PmtGenJournalBatch, Customer, CustomerBankAccount, BankAccount);
        VerifyEmployeePaymentExportData(PmtGenJournalBatch, Employee, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForAppliedPaymentsInternational()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [SCENARIO 4] Export a number of payments applied to non-domestic vendor invoices.
        // [GIVEN] A number of non-domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully or partially).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);
        PostVendorInvoice(Vendor."No.");
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        SuggestVendorPayments(Vendor, GenJournalBatch);
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(GenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(GenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForUnappliedPaymentsInternational()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 5] Export a number of payments unapplied to non-domestic vendor invoices.
        // [GIVEN] A number of payment lines unapplied to any non-domestic vendor invoices.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        // Information regarding applied invoices is not filled in, as per the linked mapping document.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(GenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(GenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    [Scope('OnPrem')]
    procedure CheckBufferForDiffAccTypesInternational()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        Customer: Record Customer;
        CustomerBankAccount: Record "Customer Bank Account";
    begin
        // [SCENARIO 6] Export a number of payments applied to both non-domestic customer and vendor.
        // [GIVEN] A number of non-domestic vendor invoices and non-domestic customer credit memos.
        // [GIVEN] A number of payment/refund lines applied to them.
        // [GIVEN] A bank account set up to export to AMC format, used by the payments.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] The Payment Export Data buffer table is populated with information regarding
        // - sender identification (creditor no., company name, template and batch name, unique message id, VAT no.,
        // own reference, own address info, sender bank account info, etc.
        // - transaction information (amount details, transaction specification, costs, payment type)
        // - receiver identification: receiver's address, receiver's bank account (including address)
        // More details in the linked document in the deliverable.
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        SetupCustomerDetails(Customer, CustomerBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        LibraryPaymentExport.SetPmtToInternational(BankAccount, VendorBankAccount);
        LibraryPaymentExport.SetRefundToInternational(BankAccount, CustomerBankAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Payment,
          GenJournalLine."Account Type"::Vendor, Vendor."No.", LibraryRandom.RandDec(1000, 2));
        LibraryERM.CreateGeneralJnlLine(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Refund,
          GenJournalLine."Account Type"::Customer, Customer."No.", -LibraryRandom.RandDec(1000, 2));
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping.
        ExtractAMCData(GenJournalBatch);

        // Verify. Payment Export Data.
        VerifyVendorPaymentExportData(GenJournalBatch, Vendor, VendorBankAccount, BankAccount);
        VerifyCustomerPaymentExportData(GenJournalBatch, Customer, CustomerBankAccount, BankAccount);
        Cleanup();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    [Scope('OnPrem')]
    procedure ExportFailsIfBankNameDataConvNotSpecified()
    var
        BankAccount: Record "Bank Account";
        VendorBankAccount: Record "Vendor Bank Account";
        Vendor: Record Vendor;
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [SCENARIO 7] If the "AMC Bank Name" is not set, payment export throws an error in the premapping.
        // [GIVEN] A number of domestic vendor invoices.
        // [GIVEN] A number of suggested payments applied to those invoices (fully or partially).
        // [GIVEN] A bank account set up to export to AMC format, used by the payments but missing "AMC Bank Name" field value.
        // [WHEN] Invoking the Export to Payment file from the Payment Journal.
        // [THEN] It throws an error that the "AMC Bank Name" field cannot be empty
        Initialize();
        LibraryAmcWebService.SetupAMCBankingDataExch(AMCBankingMgt.GetDataExchDef_CT());

        // Setup.
        SetupVendorDetails(Vendor, VendorBankAccount);
        CreateBankAccountWithDetails(BankAccount);
        BankAccount."AMC Bank Name" := '';

        LibraryPaymentExport.SetPmtToDomestic(BankAccount, VendorBankAccount);
        PostVendorInvoice(Vendor."No.");

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        GenJournalBatch.Validate("Bal. Account Type", GenJournalBatch."Bal. Account Type"::"Bank Account");
        GenJournalBatch.Validate("Bal. Account No.", BankAccount."No.");
        GenJournalBatch.Modify(true);
        SuggestVendorPayments(Vendor, GenJournalBatch);
        SetupPmtDetails(GenJournalBatch);

        // Exercise. Run the pre-mapping. & Verify the error returned
        asserterror ExtractAMCData(GenJournalBatch);
        Assert.ExpectedError(StrSubstNo(MissingBankNameDataConvErr, BankAccount.FieldCaption("AMC Bank Name")));
        Cleanup();
    end;

    local procedure SuggestVendorPayments(var Vendor: Record Vendor; GenJournalBatch: Record "Gen. Journal Batch")
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
            InitializeRequest(WorkDate(), false, 0, false, WorkDate(), LibraryUtility.GenerateGUID(), false,
              GenJournalBatch."Bal. Account Type", GenJournalBatch."Bal. Account No.", 0);
            UseRequestPage(false);
            RunModal();
        end;
    end;

    local procedure SetupVendorDetails(var Vendor: Record Vendor; var VendorBankAccount: Record "Vendor Bank Account")
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibraryPurchase.CreateVendor(Vendor);
        CreateVendorBankAccountWithDetails(VendorBankAccount, Vendor."No.");
        LibraryERM.CreatePaymentMethod(PaymentMethod);

        Vendor.Validate("Payment Method Code", PaymentMethod.Code);
        Vendor.Validate("Preferred Bank Account Code", VendorBankAccount.Code);
        Vendor.Validate(Name,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(Name), DATABASE::Vendor));
        Vendor.Validate(Address,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(Address), DATABASE::Vendor));
        Vendor.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo("Address 2"), DATABASE::Vendor));
        Vendor.Validate(City,
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo(City), DATABASE::Vendor));
        Vendor.Validate("Post Code",
          LibraryUtility.GenerateRandomCode(Vendor.FieldNo("Post Code"), DATABASE::Vendor));
        Vendor.Modify(true);
        Vendor.SetRange("No.", Vendor."No.");
    end;

    local procedure SetupCustomerDetails(var Customer: Record Customer; var CustomerBankAccount: Record "Customer Bank Account")
    var
        PaymentMethod: Record "Payment Method";
    begin
        LibrarySales.CreateCustomer(Customer);
        CreateCustomerBankAccountWithDetails(CustomerBankAccount, Customer."No.");
        LibraryERM.CreatePaymentMethod(PaymentMethod);
        Customer.Validate("Payment Method Code", PaymentMethod.Code);
        Customer.Validate("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.Validate(Name,
          LibraryUtility.GenerateRandomCode(Customer.FieldNo(Name), DATABASE::Customer));
        Customer.Validate(Address,
          LibraryUtility.GenerateRandomCode(Customer.FieldNo(Address), DATABASE::Customer));
        Customer.Validate("Address 2",
          LibraryUtility.GenerateRandomCode(Customer.FieldNo("Address 2"), DATABASE::Customer));
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
            GenJournalLine."Creditor No." :=
              LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Creditor No."), DATABASE::"Gen. Journal Line");
            GenJournalLine."Payment Reference" := LibraryUtility.GenerateGUID();
            GenJournalLine.Validate("Applies-to Ext. Doc. No.",
              LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Applies-to Ext. Doc. No."), DATABASE::"Gen. Journal Line"));
            GenJournalLine.Modify(true);
        until GenJournalLine.Next() = 0;
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

    local procedure VerifyVendorPaymentExportData(GenJournalBatch: Record "Gen. Journal Batch"; Vendor: Record Vendor; VendorBankAccount: Record "Vendor Bank Account"; BankAccount: Record "Bank Account")
    var
        PaymentExportData: Record "Payment Export Data";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Vendor);
        GenJournalLine.FindSet();
        repeat
            PaymentExportData.SetRange("General Journal Template", GenJournalLine."Journal Template Name");
            PaymentExportData.SetRange("General Journal Batch Name", GenJournalLine."Journal Batch Name");
            PaymentExportData.SetRange("General Journal Line No.", GenJournalLine."Line No.");
            Assert.AreEqual(1, PaymentExportData.Count(), 'Unexpected buffer entries for ' + PaymentExportData.GetFilters());
            PaymentExportData.FindFirst();
            PaymentMethod.Get(GenJournalLine."Payment Method Code");
            PaymentExportData.TestField("Data Exch. Line Def Code", PaymentMethod."Pmt. Export Line Definition");
            PaymentExportData.TestField("Payment Type", PaymentMethod."AMC Bank Pmt. Type");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Sender Bank Account Currency",
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"));
            PaymentExportData.TestField("Sender Bank Account No.", BankAccount.GetBankAccountNo());
            PaymentExportData.TestField("Sender Bank Country/Region",
              CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code"));
            PaymentExportData.TestField("Sender Bank BIC", BankAccount."SWIFT Code");
            PaymentExportData.TestField("Sender Bank Address", BankAccount.Address);
            PaymentExportData.TestField("Sender Bank City", BankAccount.City);
            PaymentExportData.TestField("Sender Bank Post Code", BankAccount."Post Code");
            PaymentExportData.TestField("Recipient Name", Vendor.Name);
            PaymentExportData.TestField("Recipient Address", Vendor.Address);
            PaymentExportData.TestField("Recipient City", Vendor.City);
            PaymentExportData.TestField("Recipient Post Code", Vendor."Post Code");
            PaymentExportData.TestField("Recipient Country/Region Code", Vendor."Country/Region Code");
            PaymentExportData.TestField("Recipient Email Address", Vendor."E-Mail");
            PaymentExportData.TestField("Recipient Bank Acc. No.", VendorBankAccount.GetBankAccountNo());
            PaymentExportData.TestField("Recipient Bank BIC", VendorBankAccount."SWIFT Code");
            PaymentExportData.TestField("Recipient Bank Name", VendorBankAccount.Name);
            PaymentExportData.TestField("Recipient Bank Address", VendorBankAccount.Address);
            PaymentExportData.TestField("Recipient Bank City", VendorBankAccount.City);
            PaymentExportData.TestField("Recipient Bank Country/Region", VendorBankAccount."Country/Region Code");
            PaymentExportData.TestField("Recipient Bank Post Code", VendorBankAccount."Post Code");
            PaymentExportData.TestField("Short Advice", GenJournalLine."Document No.");
            // TfsId 234269: The "Message to Recipient" string is cropped the same way it assigned in COD1206,COD1273,COD1283
            PaymentExportData.TestField("Message to Recipient 1", CopyStr(GenJournalLine."Message to Recipient", 1, 35));
            PaymentExportData.TestField("Message to Recipient 2", CopyStr(GenJournalLine."Message to Recipient", 36, 70));
            PaymentExportData.TestField(Amount, GenJournalLine.Amount);
            PaymentExportData.TestField("Currency Code", GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code"));
            PaymentExportData.TestField("Transfer Date", GenJournalLine."Posting Date");
            PaymentExportData.TestField("Document No.", GenJournalLine."Document No.");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Applies-to Ext. Doc. No.", GenJournalLine."Applies-to Ext. Doc. No.");
            PaymentExportData.TestField("Costs Distribution", 'Shared');
            PaymentExportData.TestField("Message Structure", 'auto');
            PaymentExportData.TestField("Own Address Info.", 'frombank');
            PaymentExportData.TestField("Creditor No.", BankAccount."Creditor No.");
            PaymentExportData.TestField("Recipient ID", GenJournalLine."Account No.");
            PaymentExportData.TestField("Sender Bank Name - Data Conv.", BankAccount."AMC Bank Name");
        until GenJournalLine.Next() = 0;
    end;

    local procedure VerifyCustomerPaymentExportData(GenJournalBatch: Record "Gen. Journal Batch"; Customer: Record Customer; CustomerBankAccount: Record "Customer Bank Account"; BankAccount: Record "Bank Account")
    var
        PaymentExportData: Record "Payment Export Data";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Customer);
        GenJournalLine.FindSet();
        repeat
            PaymentExportData.SetRange("General Journal Template", GenJournalLine."Journal Template Name");
            PaymentExportData.SetRange("General Journal Batch Name", GenJournalLine."Journal Batch Name");
            PaymentExportData.SetRange("General Journal Line No.", GenJournalLine."Line No.");
            Assert.AreEqual(1, PaymentExportData.Count(), 'Unexpected buffer entries for ' + PaymentExportData.GetFilters());
            PaymentExportData.FindFirst();
            PaymentMethod.Get(GenJournalLine."Payment Method Code");
            PaymentExportData.TestField("Data Exch. Line Def Code", PaymentMethod."Pmt. Export Line Definition");
            PaymentExportData.TestField("Payment Type", PaymentMethod."AMC Bank Pmt. Type");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Sender Bank Account Currency",
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"));
            PaymentExportData.TestField("Sender Bank Account No.", BankAccount.GetBankAccountNo());
            PaymentExportData.TestField("Sender Bank Country/Region",
              CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code"));
            PaymentExportData.TestField("Sender Bank BIC", BankAccount."SWIFT Code");
            PaymentExportData.TestField("Sender Bank Address", BankAccount.Address);
            PaymentExportData.TestField("Sender Bank City", BankAccount.City);
            PaymentExportData.TestField("Sender Bank Post Code", BankAccount."Post Code");
            PaymentExportData.TestField("Recipient Name", Customer.Name);
            PaymentExportData.TestField("Recipient Address", Customer.Address);
            PaymentExportData.TestField("Recipient City", Customer.City);
            PaymentExportData.TestField("Recipient Post Code", Customer."Post Code");
            PaymentExportData.TestField("Recipient Country/Region Code", Customer."Country/Region Code");
            PaymentExportData.TestField("Recipient Email Address", Customer."E-Mail");
            PaymentExportData.TestField("Recipient Bank Acc. No.", CustomerBankAccount.GetBankAccountNo());
            PaymentExportData.TestField("Recipient Bank BIC", CustomerBankAccount."SWIFT Code");
            PaymentExportData.TestField("Recipient Bank Name", CustomerBankAccount.Name);
            PaymentExportData.TestField("Recipient Bank Address", CustomerBankAccount.Address);
            PaymentExportData.TestField("Recipient Bank City", CustomerBankAccount.City);
            PaymentExportData.TestField("Recipient Bank Country/Region", CustomerBankAccount."Country/Region Code");
            PaymentExportData.TestField("Recipient Bank Post Code", CustomerBankAccount."Post Code");
            PaymentExportData.TestField("Short Advice", GenJournalLine."Document No.");
            PaymentExportData.TestField("Message to Recipient 1", CopyStr(GenJournalLine."Message to Recipient", 1,
                MaxStrLen(PaymentExportData."Message to Recipient 1")));
            PaymentExportData.TestField("Message to Recipient 1", CopyStr(GenJournalLine."Message to Recipient",
                MaxStrLen(PaymentExportData."Message to Recipient 1"), MaxStrLen(GenJournalLine."Message to Recipient")));
            PaymentExportData.TestField(Amount, GenJournalLine.Amount);
            PaymentExportData.TestField("Currency Code", GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code"));
            PaymentExportData.TestField("Transfer Date", GenJournalLine."Posting Date");
            PaymentExportData.TestField("Document No.", GenJournalLine."Document No.");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Applies-to Ext. Doc. No.", GenJournalLine."Applies-to Ext. Doc. No.");
            PaymentExportData.TestField("Costs Distribution", 'Shared');
            PaymentExportData.TestField("Message Structure", 'auto');
            PaymentExportData.TestField("Own Address Info.", 'frombank');
            PaymentExportData.TestField("Creditor No.", BankAccount."Creditor No.");
            PaymentExportData.TestField("Transit No.", BankAccount."Transit No.");
            PaymentExportData.TestField("Recipient ID", GenJournalLine."Account No.");
            PaymentExportData.TestField("Sender Bank Name - Data Conv.", BankAccount."AMC Bank Name");
        until GenJournalLine.Next() = 0;
    end;

    local procedure VerifyEmployeePaymentExportData(GenJournalBatch: Record "Gen. Journal Batch"; Employee: Record Employee; BankAccount: Record "Bank Account")
    var
        PaymentExportData: Record "Payment Export Data";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentMethod: Record "Payment Method";
    begin
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.SetRange("Account Type", GenJournalLine."Account Type"::Employee);
        GenJournalLine.FindSet();
        repeat
            PaymentExportData.SetRange("General Journal Template", GenJournalLine."Journal Template Name");
            PaymentExportData.SetRange("General Journal Line No.", GenJournalLine."Line No.");
            PaymentExportData.SetRange("General Journal Batch Name", GenJournalLine."Journal Batch Name");
            Assert.AreEqual(1, PaymentExportData.Count(), 'Unexpected buffer entries for ' + PaymentExportData.GetFilters());
            PaymentExportData.FindFirst();
            PaymentMethod.Get(GenJournalLine."Payment Method Code");
            PaymentExportData.TestField("Data Exch. Line Def Code", PaymentMethod."Pmt. Export Line Definition");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Payment Type", PaymentMethod."AMC Bank Pmt. Type");
            PaymentExportData.TestField("Recipient Name", Employee.FullName());
            PaymentExportData.TestField("Recipient Address", Employee.Address);
            PaymentExportData.TestField("Recipient City", Employee.City);
            PaymentExportData.TestField("Recipient Post Code", Employee."Post Code");
            PaymentExportData.TestField("Recipient Country/Region Code", Employee."Country/Region Code");
            PaymentExportData.TestField("Recipient Email Address", Employee."E-Mail");
            PaymentExportData.TestField("Recipient Bank Acc. No.", Employee.GetBankAccountNo());
            PaymentExportData.TestField("Short Advice", GenJournalLine."Document No.");
            PaymentExportData.TestField("Message to Recipient 1", CopyStr(GenJournalLine."Message to Recipient", 1,
                MaxStrLen(PaymentExportData."Message to Recipient 1")));
            PaymentExportData.TestField("Message to Recipient 2", CopyStr(GenJournalLine."Message to Recipient",
                MaxStrLen(PaymentExportData."Message to Recipient 1"), MaxStrLen(GenJournalLine."Message to Recipient")));
            PaymentExportData.TestField("Sender Bank Account Currency",
              GeneralLedgerSetup.GetCurrencyCode(BankAccount."Currency Code"));
            PaymentExportData.TestField("Sender Bank Account No.", BankAccount.GetBankAccountNo());
            PaymentExportData.TestField("Sender Bank Country/Region",
              CompanyInformation.GetCountryRegionCode(BankAccount."Country/Region Code"));
            PaymentExportData.TestField("Sender Bank Address", BankAccount.Address);
            PaymentExportData.TestField("Sender Bank BIC", BankAccount."SWIFT Code");
            PaymentExportData.TestField("Sender Bank City", BankAccount.City);
            PaymentExportData.TestField("Sender Bank Post Code", BankAccount."Post Code");
            PaymentExportData.TestField(Amount, GenJournalLine.Amount);
            PaymentExportData.TestField("Currency Code", GeneralLedgerSetup.GetCurrencyCode(GenJournalLine."Currency Code"));
            PaymentExportData.TestField("Transfer Date", GenJournalLine."Posting Date");
            PaymentExportData.TestField("Document No.", GenJournalLine."Document No.");
            PaymentExportData.TestField("Payment Reference", GenJournalLine."Payment Reference");
            PaymentExportData.TestField("Costs Distribution", 'Shared');
            PaymentExportData.TestField("Message Structure", 'auto');
            PaymentExportData.TestField("Own Address Info.", 'frombank');
            PaymentExportData.TestField("Creditor No.", BankAccount."Creditor No.");
            PaymentExportData.TestField("Recipient ID", GenJournalLine."Account No.");
            PaymentExportData.TestField("Sender Bank Name - Data Conv.", BankAccount."AMC Bank Name");
        until GenJournalLine.Next() = 0;
    end;

    local procedure PostVendorInvoice(VendorNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, LibraryERM.SelectGenJnlTemplate());
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine,
          GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::Invoice,
          GenJournalLine."Account Type"::Vendor, VendorNo, GenJournalLine."Bal. Account Type"::"G/L Account", GLAccount."No.",
          -LibraryRandom.RandDec(1000, 2));
        GenJournalLine."Recipient Bank Account" := '';
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
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

    local procedure UpdateAMCCreditTransferFormat(var DataExchDef: Record "Data Exch. Def")
    begin
        DataExchDef."Ext. Data Handling Codeunit" := CODEUNIT::"Save Data Exch. Blob Sample";
        DataExchDef."User Feedback Codeunit" := CODEUNIT::"Exp. User Feedback Gen. Jnl.";
        DataExchDef."Validation Codeunit" := 0;
        DataExchDef.Modify(true);
    end;

    local procedure ExtractAMCData(GenJournalBatch: Record "Gen. Journal Batch")
    var
        DataExch: Record "Data Exch.";
        DataExchDef: Record "Data Exch. Def";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccount: Record "Bank Account";
        CreditTransferRegister: Record "Credit Transfer Register";
    begin
        DataExch.Init();
        DataExch.Insert();
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.ModifyAll("Data Exch. Entry No.", DataExch."Entry No.");

        BankAccount.Get(GenJournalBatch."Bal. Account No.");
        BankAccount.GetDataExchDefPaymentExport(DataExchDef);
        CreditTransferRegister.CreateNew(DataExchDef.Code, GenJournalBatch."Bal. Account No.");
        CreditTransferRegister."Data Exch. Entry No." := DataExch."Entry No.";
        CreditTransferRegister.Modify();
        Commit();
        CODEUNIT.Run(CODEUNIT::"AMC Bank Exp. CT Pre-Map", DataExch);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    begin
    end;
}


