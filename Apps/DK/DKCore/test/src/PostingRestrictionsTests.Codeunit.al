codeunit 148017 "Posting Restrictions Tests"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        EnvironmentInfoTestLibrary: Codeunit "Environment Info Test Library";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryJournals: Codeunit "Library - Journals";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryXMLRead: Codeunit "Library - XML Read";
        Assert: Codeunit "Assert";
        isInitialized: Boolean;
        ServerFileName: Text;
        CannotPostWithoutCVRNumberErr: Label 'You cannot post without a valid CVR number filled in. Open the Company Information page and enter a CVR number in the Registration No. field.';

    trigger OnRun()
    begin
        // [FEATURE] [Posting]
    end;

    [Test]
    procedure CannotPostToGLInProductionSaaSWhenCVRNumberIsBlank()
    begin
        // [SCENARIO 493941] Stan cannot post to general ledger in the Production Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetJournalsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan tries to post to general ledger        
        asserterror PostGeneralJournal();
        // [THEN] Stan gets an error 'You cannot post without a CVR number. Open the Company Information window and enter a CVR number.'
        Assert.ExpectedError(CannotPostWithoutCVRNumberErr);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostToGLInProductionSaaSWhenCVRNumberIsSpecified()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 493941] Stan can post to general ledger in the Production Saas environment when the CVR number is specified

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is specified
        SetCVRNumberInCompanyInformation('12345678');

        LibraryLowerPermissions.SetJournalsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts to general ledger
        PostGeneralJournal(GeneralJournalLine);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(GeneralJournalLine."Posting Date", GeneralJournalLine."Document No.");

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostToGLInSandboxSaaSWhenCVRNumberIsBlank()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 493941] Stan can post to general ledger in the Sandbox Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Sandbox environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(true);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetJournalsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts to general ledger
        PostGeneralJournal(GeneralJournalLine);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(GeneralJournalLine."Posting Date", GeneralJournalLine."Document No.");

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostToGLInProductionOnPremWhenCVRNumberIsBlank()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 493941] Stan can post to general ledger in the Production OnPrem environment when the CVR number is blank

        Initialize();
        // [GIVEN] OnPrem environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetJournalsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts to general ledger
        PostGeneralJournal(GeneralJournalLine);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(GeneralJournalLine."Posting Date", GeneralJournalLine."Document No.");

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure CannotPostSalesInvoiceInProductionSaaSWhenCVRNumberIsBlank()
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 493941] Stan cannot post a sales invoice in the Production Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetSalesDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan tries to post a sales invoice      
        asserterror PostSalesInvoice();
        // [THEN] Stan gets an error 'You cannot post without a CVR number. Open the Company Information window and enter a CVR number.'
        Assert.ExpectedError(CannotPostWithoutCVRNumberErr);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostSalesInvoiceInProductionSaaSWhenCVRNumberIsSpecified()
    var
        SalesHeader: Record "Sales Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 493941] Stan can post a sales invoice in the Production Saas environment when the CVR number is specified

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is specified
        SetCVRNumberInCompanyInformation('12345678');

        LibraryLowerPermissions.SetSalesDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts to general ledger
        InvNo := PostSalesInvoice(SalesHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(SalesHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostSalesInvoiceInSandboxSaaSWhenCVRNumberIsBlank()
    var
        SalesHeader: Record "Sales Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 493941] Stan can post a sales invoice in the Sandbox Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Sandbox environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(true);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetSalesDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts to general ledger
        InvNo := PostSalesInvoice(SalesHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(SalesHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostSalesInvoiceInProductionOnPremWhenCVRNumberIsBlank()
    var
        SalesHeader: Record "Sales Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 493941] Stan can post a sales invoice in the Production OnPrem environment when the CVR number is blank

        Initialize();
        // [GIVEN] OnPrem environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetSalesDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts a purchase invoice
        InvNo := PostSalesInvoice(SalesHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(SalesHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure CannotPostPurchaseInvoiceInProductionSaaSWhenCVRNumberIsBlank()
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 493941] Stan cannot post a purchase invoice in the Production Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetPurchDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan tries to post a sales invoice      
        asserterror PostPurchaseInvoice();
        // [THEN] Stan gets an error 'You cannot post without a CVR number. Open the Company Information window and enter a CVR number.'
        Assert.ExpectedError(CannotPostWithoutCVRNumberErr);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostPurchaseInvoiceInProductionSaaSWhenCVRNumberIsSpecified()
    var
        PurchaseHeader: Record "Purchase Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 493941] Stan can post a purchase invoice in the Production Saas environment when the CVR number is specified

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is specified
        SetCVRNumberInCompanyInformation('12345678');

        LibraryLowerPermissions.SetPurchDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts a purchase invoice
        InvNo := PostPurchaseInvoice(PurchaseHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(PurchaseHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostPurchaseInvoiceInSandboxSaaSWhenCVRNumberIsBlank()
    var
        PurchaseHeader: Record "Purchase Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 493941] Stan can post a purchase invoice in the Sandbox Saas environment when the CVR number is blank

        Initialize();
        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);
        // [GIVEN] Sandbox environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(true);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetPurchDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts a purchase invoice
        InvNo := PostPurchaseInvoice(PurchaseHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(PurchaseHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostPurchaseInvoiceInProductionOnPremWhenCVRNumberIsBlank()
    var
        PurchaseHeader: Record "Purchase Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 493941] Stan can post a purchase invoice in the Production OnPrem environment when the CVR number is blank

        Initialize();
        // [GIVEN] OnPrem environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        // [GIVEN] CVR number is blank
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetPurchDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts a purchase invoice
        InvNo := PostPurchaseInvoice(PurchaseHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(PurchaseHeader."Posting Date", InvNo);

        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
    end;

    [Test]
    procedure PostToGLInProdSaaSWhenEvaluationCompanyCVRNotSpecified()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO 504365] Stan can post to general ledger in production SaaS environment in Evaluation company when CVR number is not specified.
        Initialize();

        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);

        // [GIVEN] Current company is evaluation company
        UpdateEvaluationOnCompany(true);

        // [GIVEN] CVR number is not specified
        SetCVRNumberInCompanyInformation('');

        LibraryLowerPermissions.SetJournalsPost();
        LibraryLowerPermissions.AddO365Setup();

        // [WHEN] Stan posts to general ledger
        PostGeneralJournal(GeneralJournalLine);

        // [THEN] General ledger entries have been created
        VerifyGLEntry(GeneralJournalLine."Posting Date", GeneralJournalLine."Document No.");

        // restore environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        UpdateEvaluationOnCompany(false);
    end;

    [Test]
    procedure PostSalesInvInProdSaaSWhenEvaluationCompanyCVRNotSpecified()
    var
        SalesHeader: Record "Sales Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 504365] Stan can post sales invoice in production SaaS environment in Evaluation company when CVR number is not specified.
        Initialize();

        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);

        // [GIVEN] CVR number is not specified
        SetCVRNumberInCompanyInformation('');

        // [GIVEN] Current company is evaluation company
        UpdateEvaluationOnCompany(true);

        LibraryLowerPermissions.SetSalesDocsPost();
        LibraryLowerPermissions.AddO365Setup();

        // [WHEN] Stan posts to general ledger
        InvNo := PostSalesInvoice(SalesHeader);

        // [THEN] General ledger entries have been created
        VerifyGLEntry(SalesHeader."Posting Date", InvNo);

        // restore environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        UpdateEvaluationOnCompany(false);
    end;

    [Test]
    procedure PostPurchInvInProdSaaSWhenEvaluationCompanyCVRNotSpecified()
    var
        PurchaseHeader: Record "Purchase Header";
        InvNo: Code[20];
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 504365] Stan can post purchase invoice in Production SaaS environment in Evaluation company when the CVR number is not specified.
        Initialize();

        // [GIVEN] SaaS environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(true);

        // [GIVEN] Production environment
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);

        // [GIVEN] CVR number is not specified
        SetCVRNumberInCompanyInformation('');

        // [GIVEN] Current company is evaluation company
        UpdateEvaluationOnCompany(true);

        LibraryLowerPermissions.SetPurchDocsPost();
        LibraryLowerPermissions.AddO365Setup();
        // [WHEN] Stan posts a purchase invoice
        InvNo := PostPurchaseInvoice(PurchaseHeader);
        // [THEN] General ledger entries have been created
        VerifyGLEntry(PurchaseHeader."Posting Date", InvNo);

        // restore environment
        EnvironmentInfoTestLibrary.SetTestabilitySoftwareAsAService(false);
        EnvironmentInfoTestLibrary.SetTestabilitySandbox(false);
        UpdateEvaluationOnCompany(false);
    end;

    [Test]
    procedure VerifyIBANNoWhenBranchNoAndBankAccountNotEmpty()
    var
        BankAccount: Record "Bank Account";
        CustomerBankAccount: Record "Customer Bank Account";
        DirectDebitCollectionEntry: Record "Direct Debit Collection Entry";
    begin
        // [SCENARIO 59770] Verify the IBAN number when the Bank Branch number, Bank Account number, and IBAN are not empty.
        Initialize();

        // [GIVEN] Create Customer and Customer Bank Account.
        CreateCustomerWithCustomerBankAccount(CustomerBankAccount);

        // [GIVEN] Create Direct Debit Collection Entry and Customer Ledger Entry.
        CreateDirectDebitCollectionEntryWithBank(CustomerBankAccount, DirectDebitCollectionEntry, BankAccount);

        // [WHEN] Export the SEPA file.
        ExportToServerTempFile(DirectDebitCollectionEntry);

        // [THEN] Verify IBAN No.
        LibraryXMLRead.Initialize(ServerFileName);
        LibraryXMLRead.VerifyNodeValueInSubtree('CdtrAcct', 'IBAN', BankAccount.IBAN);
        LibraryXMLRead.VerifyNodeValueInSubtree('DbtrAcct', 'IBAN', CustomerBankAccount.IBAN);
    end;

    local procedure Initialize()
    begin
        LibrarySetupStorage.Restore();
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Posting Restrictions Tests");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Posting Restrictions Tests");
        LibrarySetupStorage.SaveCompanyInformation();
        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Posting Restrictions Tests");
        Commit();
    end;

    local procedure SetCVRNumberInCompanyInformation(CVRNumber: Text[20])
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.Get();
        CompanyInformation."Registration No." := CVRNumber;
        CompanyInformation.Modify();
    end;

    local procedure UpdateEvaluationOnCompany(IsEvaluation: Boolean)
    var
        Company: Record Company;
    begin
        Company.Get(CompanyName());
        Company."Evaluation Company" := IsEvaluation;
        Company.Modify();
    end;

    local procedure PostGeneralJournal()
    var
        GeneralJournalLine: Record "Gen. Journal Line";
    begin
        PostGeneralJournal(GeneralJournalLine);
    end;

    local procedure PostGeneralJournal(var GeneralJournalLine: Record "Gen. Journal Line")
    begin
        LibraryJournals.CreateGenJournalLineWithBatch(
            GeneralJournalLine, GeneralJournalLine."Document Type"::" ", GeneralJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(100, 2));
        GeneralJournalLine.Validate("Bal. Account Type", GeneralJournalLine."Bal. Account Type"::"G/L Account");
        GeneralJournalLine.Validate("Bal. Account No.", LibraryERM.CreateGLAccountNo());
        GeneralJournalLine.Modify(true);
        LibraryERM.PostGeneralJnlLine(GeneralJournalLine);
    end;

    local procedure PostSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
    begin
        PostSalesInvoice(SalesHeader);
    end;

    local procedure PostSalesInvoice(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        SalesHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(SalesHeader."Posting Date", SalesHeader."No."));
        SalesHeader.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PostPurchaseInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        PostPurchaseInvoice(PurchaseHeader);
    end;

    local procedure PostPurchaseInvoice(var PurchaseHeader: Record "Purchase Header"): Code[20]
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        PurchaseHeader.Validate("Incoming Document Entry No.", MockIncomingDocument(PurchaseHeader."Posting Date", PurchaseHeader."No."));
        PurchaseHeader.Modify(true);
        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure MockIncomingDocument(PostingDate: Date; DocNo: Code[20]): Integer
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IncomingDocument."Entry No." :=
            LibraryUtility.GetNewRecNo(IncomingDocument, IncomingDocument.FieldNo("Entry No."));
        IncomingDocument."Posting Date" := PostingDate;
        IncomingDocument."Document No." := DocNo;
        IncomingDocument.Insert();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment.Insert();
        exit(IncomingDocument."Entry No.");
    end;

    local procedure VerifyGLEntry(PostingDate: Date; DocNo: Code[20])
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Posting Date", PostingDate);
        GLEntry.SetRange("Document No.", DocNo);
        Assert.IsTrue(not GLEntry.IsEmpty(), 'No G/L Entry found after posting');
    end;

    local procedure CreateCustomerWithCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account")
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomerWithAddress(Customer);
        Customer.Validate("Currency Code", LibraryERM.GetCurrencyCode('EUR'));
        Customer.Modify(true);
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, Customer."No.");
        CustomerBankAccount."Bank Account No." := Format(LibraryRandom.RandIntInRange(111111111, 999999999)); // avoid local values validation
        CustomerBankAccount."Bank Branch No." := Format(LibraryRandom.RandIntInRange(100, 200));
        CustomerBankAccount.IBAN := Format(LibraryRandom.RandIntInRange(11111111, 99999999));
        CustomerBankAccount."SWIFT Code" := Format(LibraryRandom.RandIntInRange(1111, 9999));
        CustomerBankAccount.Modify(true);

        Customer.Validate("Preferred Bank Account Code", CustomerBankAccount.Code);
        Customer.Validate("Partner Type", Customer."Partner Type"::Company);
        Customer.Modify(true);
    end;

    local procedure CreateDirectDebitCollectionEntryWithBank(CustomerBankAccount: Record "Customer Bank Account"; var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry"; var BankAccount: Record "Bank Account")
    var
        BankExportImportSetup: Record "Bank Export/Import Setup";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        Customer: Record Customer;
        DirectDebitCollection: Record "Direct Debit Collection";
        SEPADirectDebitMandate: Record "SEPA Direct Debit Mandate";
    begin
        Customer.Get(CustomerBankAccount."Customer No.");
        LibrarySales.CreateCustomerMandate(SEPADirectDebitMandate, CustomerBankAccount."Customer No.", CustomerBankAccount.Code, Today(), WorkDate());
        PostSalesInvoice(Customer, SEPADirectDebitMandate.ID, LibraryERM.GetCurrencyCode('EUR'));

        CreateSEPABankAccount(BankAccount);
        BankAccount.Validate("Bank Branch No.", Format(LibraryRandom.RandIntInRange(5000, 9000)));
        BankAccount.Validate("Direct Debit Msg. Nos.", CreateNoSeries());
        BankExportImportSetup.SetRange("Processing XMLport ID", Xmlport::"SEPA DD pain.008.001.02");
        BankExportImportSetup.FindFirst();
        BankAccount.Validate("Payment Export Format", BankExportImportSetup.Code);
        BankAccount.Modify(true);

        if DirectDebitCollection."No." = 0 then
            DirectDebitCollection.CreateRecord(BankAccount.GetDirectDebitMessageNo(), BankAccount."No.", Customer."Partner Type");
        DirectDebitCollectionEntry.SetRange("Direct Debit Collection No.", DirectDebitCollection."No.");
        CustLedgerEntry.FindLast();
        DirectDebitCollectionEntry.CreateNew(DirectDebitCollection."No.", CustLedgerEntry);
        DirectDebitCollectionEntry.Modify(true);
    end;

    local procedure CreateSEPABankAccount(var BankAccount: Record "Bank Account")
    var
        NoSeries: Record "No. Series";
        BankExportImportSetup: Record "Bank Export/Import Setup";
    begin
        NoSeries.FindFirst();
        BankExportImportSetup.SetRange("Processing Codeunit ID", CODEUNIT::"SEPA DD-Export File");
        BankExportImportSetup.FindFirst();

        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount."Bank Account No." := Format(LibraryRandom.RandIntInRange(111, 999));
        BankAccount."Bank Branch No." := Format(LibraryRandom.RandIntInRange(1000, 2000));
        BankAccount.IBAN := Format(LibraryRandom.RandIntInRange(11111111, 99999999));
        BankAccount."SWIFT Code" := Format(LibraryRandom.RandIntInRange(1111, 9999));
        BankAccount."Creditor No." := Format(LibraryRandom.RandIntInRange(11111111, 99999999));
        BankAccount."SEPA Direct Debit Exp. Format" := BankExportImportSetup.Code;
        BankAccount.Validate("Direct Debit Msg. Nos.", NoSeries.Code);
        BankAccount.Modify();
    end;

    local procedure PostSalesInvoice(var Customer: Record Customer; DirectDebitMandateID: Code[35]; CurrencyCode: Code[10])
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");
        SalesHeader.Validate("Currency Code", CurrencyCode);
        SalesHeader.Validate("Direct Debit Mandate ID", DirectDebitMandateID);
        SalesHeader.Modify(true);

        LibrarySales.PostSalesDocument(SalesHeader, false, true);
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        NoSeries: Record "No. Series";
        NoSeriesLine: Record "No. Series Line";
    begin
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryUtility.CreateNoSeriesLine(NoSeriesLine, NoSeries.Code, '', '');

        exit(NoSeries.Code);
    end;

    local procedure ExportToServerTempFile(var DirectDebitCollectionEntry: Record "Direct Debit Collection Entry")
    var
        FileManagement: Codeunit "File Management";
        ExportFile: File;
        OutStream: OutStream;
    begin
        ServerFileName := FileManagement.ServerTempFileName('.xml');
        ExportFile.WriteMode := true;
        ExportFile.TextMode := true;
        ExportFile.Create(ServerFileName);
        ExportFile.CreateOutStream(OutStream);
        XMLPORT.Export(XMLPORT::"SEPA DD pain.008.001.02", OutStream, DirectDebitCollectionEntry);
        ExportFile.Close();
    end;
}
