// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 148052 "OIOUBL-ERM Misc Elec. Invoice"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryFinanceChargeMemo: Codeunit "Library - Finance Charge Memo";
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryXMLReadOnServer: Codeunit "Library - XML Read OnServer";
        OIOUBLNewFileMock: Codeunit "OIOUBL-File Events Mock";
        PayeeFinAccCapTxt: Label 'cac:PayeeFinancialAccount';
        FinInstitutionBranchCapTxt: Label 'cac:FinancialInstitutionBranch';
        ElecDocumentType: Option "Fin. Charge Memo","Reminder","Sales Invoice","Service Invoice";
        ContactEmptyErr: Label 'Contact must have a value';
        AccountCodeTxt: Label 'Account Code';
        BlankLCYCodeErr: Label 'LCY Code must have a value in General Ledger Setup: Primary Key=. It cannot be zero or empty.';
        cbcNameCapTxt: Label 'cbc:Name';
        cbcPercentCapTxt: Label 'cbc:Percent';
        cbcAmountInclTaxCapTxt: Label 'cbc:TaxInclusiveAmount';
        CrMemoPathTxt: Label 'OIOUBL Cr. Memo Path';
        CurrencyCodeTxt: Label 'OIOUBL Currency Code';
        CustomerReferenceCapTxt: Label 'cbc:CustomerReference';
        DescriptionTxt: Label 'Test line with text value more than 50 characters.';
        GLNNoTok: Label 'GLN No.';
        GLNNoErr: Label 'The GLN %1 is not valid.', Comment = '%1 = GLN No.';
        GLNNoTxt: Label '5790000510146';
        EndpointIDCapTxt: Label 'cbc:EndpointID';
        FinChrgMemoPathTxt: Label 'OIOUBL Fin. Chrg. Memo Path';
        IBANNoTxt: Label 'DK 12 CPBK 08929965044991';
        IDCapTxt: Label 'cbc:ID';
        InvoicePathTxt: Label 'OIOUBL Invoice Path';
        LCYCodeLenghtErr: Label 'LCY Code should be 3 characters long in General Ledger Setup Primary Key=''''.';
        OIOUBLCodeTxt: Label 'OIOUBL Code';
        PaymentChannelCodeCapTxt: Label 'cbc:PaymentChannelCode';
        PaymentChannelCodeTxt: Label '%1:BANK', Comment = '%1 = Country or Region Code';
        PaymentMeansCodeCapTxt: Label 'cbc:PaymentMeansCode';
        ReminderPathTxt: Label 'OIOUBL Reminder Path';
        SalesOrderIDCapTxt: Label 'cbc:SalesOrderID';
        ValidationErr: Label '%1 must be %2', Comment = '%1 = Field Caption; %2 = Expected Value';

    [Test]
    procedure ContactDetailsForSalesQuote();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Verify Contact details on Posted document for Sales Quote.

        // Setup: Create Customer and update Contact. Make Order from Sales Quote.
        Initialize();
        CreateCustomerAndModifyContact(Customer);
        CreateSalesDocument(SalesHeader, Customer."No.", SalesHeader."Document Type"::Quote, false, 0);  // False for PricesIncludingVAT, 0 for Line Discount %.
        LibrarySales.QuoteMakeOrder(SalesHeader);
        FindSalesOrder(SalesHeader, Customer."No.");

        // Exercise.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Contact details on posted document.
        VerifyPostedSalesInvoice(Customer."Primary Contact No.", PostedDocumentNo);
    end;

    [Test]
    procedure ContactDetailsForSalesBlanketOrder();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Verify Contact details on Posted document for Sales Blanket Order.

        // Setup: Create Customer and update Contact. Make Order from Sales Blanket Order.
        Initialize();
        CreateCustomerAndModifyContact(Customer);
        CreateSalesDocument(
          SalesHeader, Customer."No.", SalesHeader."Document Type"::"Blanket Order", false, 0);  // False for PricesIncludingVAT, 0 for Line Discount %.
        LibrarySales.BlanketSalesOrderMakeOrder(SalesHeader);
        FindSalesOrder(SalesHeader, Customer."No.");

        // Exercise.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Contact details on posted document.
        VerifyPostedSalesInvoice(Customer."Primary Contact No.", PostedDocumentNo);
    end;

    [Test]
    procedure ContactDetailsForSalesInvoice();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Verify Contact details on Posted document for Sales Invoice.

        // Setup: Create Customer and update Contact. Create Sales Invoice.
        Initialize();
        CreateCustomerAndModifyContact(Customer);
        CreateSalesDocument(SalesHeader, Customer."No.", SalesHeader."Document Type"::Invoice, false, 0);  // False for PricesIncludingVAT, 0 for Line Discount %.

        // Exercise.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Contact details on posted document.
        VerifyPostedSalesInvoice(Customer."Primary Contact No.", PostedDocumentNo);
    end;

    [Test]
    procedure ContactDetailsForSalesReturnOrder();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify Contact details on Posted document for Sales Return Order.
        ContactDetailsForSalesDocument(SalesHeader."Document Type"::"Return Order");
    end;

    [Test]
    procedure ContactDetailsForSalesCreditMemo();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify Contact details on Posted document for Sales Credit Memo.
        ContactDetailsForSalesDocument(SalesHeader."Document Type"::"Credit Memo");
    end;

    local procedure ContactDetailsForSalesDocument(DocumentType: Option);
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Create Customer and update Contact. Create Sales Document.
        Initialize();
        CreateCustomerAndModifyContact(Customer);
        CreateSalesDocument(SalesHeader, Customer."No.", DocumentType, false, 0);  // False for PricesIncludingVAT, 0 for Line Discount %.

        // Exercise.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Contact details on posted document.
        VerifyPostedSalesCrMemoHeader(Customer."Primary Contact No.", PostedDocumentNo);
    end;


    [Test]
    procedure SetupCompanyInformation();
    var
        CompanyInformation: Record "Company Information";
        VATRegistrationNo: Text[20];
    begin
        // Verify that VAT Registration No is updated on Company Information without any error.

        // Setup.
        Initialize();

        // Exercise.
        VATRegistrationNo := ModifyCompanyInformation('');

        // Verify.
        CompanyInformation.GET();
        CompanyInformation.TESTFIELD("VAT Registration No.", VATRegistrationNo);
    end;

    [Test]
    procedure SetupCountryRegion();
    var
        CountryRegion: Record "Country/Region";
        OIOUBLCountryRegionCode: Code[20];
    begin
        // Verify that "OIOUBL-Country/Regions" field is updated on Country/Regions without any error.

        // Setup.
        Initialize();

        // Exercise.
        OIOUBLCountryRegionCode := CreateAndModifyCountryRegion();

        // Verify.
        CountryRegion.SETRANGE(Code, OIOUBLCountryRegionCode);
        CountryRegion.FINDFIRST();
        CountryRegion.TESTFIELD("OIOUBL-Country/Region Code", OIOUBLCountryRegionCode);
    end;

    [Test]
    procedure SetupPaymentTerms();
    var
        PaymentTerms: Record "Payment Terms";
    begin
        // Verify OIOUBL Code field exists in Payment Terms and able to validate the value with no error.

        // Setup.
        Initialize();
        LibraryERM.CreatePaymentTerms(PaymentTerms);
        PaymentTerms.VALIDATE("OIOUBL-Code", PaymentTerms."OIOUBL-Code"::Specific);

        // Exercise.
        PaymentTerms.MODIFY(true);

        // Verify.
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Payment Terms", OIOUBLCodeTxt);
        PaymentTerms.GET(PaymentTerms.Code);
        PaymentTerms.TESTFIELD("OIOUBL-Code", PaymentTerms."OIOUBL-Code"::Specific);
    end;

    [Test]
    procedure SetupCustomerDiscount();
    var
        Customer: Record Customer;
        CustInvoiceDisc: Record "Cust. Invoice Disc.";
        MinimumuAmount: Decimal;
        DiscountPct: Decimal;
    begin
        // Verify Minimum Amount and Discount% values populate with no errors on Customer Invoice Discount.

        // Setup: Create Customer and Invoice Discount with Random values for Minimum Amount and Discount%.
        Initialize();
        MinimumuAmount := LibraryRandom.RandDec(100, 2);
        DiscountPct := LibraryRandom.RandDec(10, 2);
        LibrarySales.CreateCustomer(Customer);
        LibraryERM.CreateInvDiscForCustomer(CustInvoiceDisc, Customer."No.", '', MinimumuAmount);
        CustInvoiceDisc.VALIDATE("Discount %", DiscountPct);

        // Exercise.
        CustInvoiceDisc.MODIFY(true);

        // Verify.
        CustInvoiceDisc.SETRANGE(Code, CustInvoiceDisc.Code);
        CustInvoiceDisc.FINDFIRST();
        CustInvoiceDisc.TESTFIELD("Minimum Amount", MinimumuAmount);
        CustInvoiceDisc.TESTFIELD("Discount %", DiscountPct);
    end;

    [Test]
    procedure CustomerGLNNumberError();
    var
        Customer: Record Customer;
    begin
        // Verify error message for incorrect GLN No. on Customer.

        // Setup.
        Initialize();
        LibrarySales.CreateCustomer(Customer);

        // Exercise.
        asserterror Customer.VALIDATE(GLN, '1234567890123');

        // Verify.
        Assert.ExpectedError(STRSUBSTNO(GLNNoErr, '1234567890123'));
    end;

    [Test]
    procedure SetupItem();
    var
        Item: Record Item;
        VATProductPostingGroup: Record "VAT Product Posting Group";
    begin
        // Verify VAT Prod. Posting Group values populates with no errors on Item.

        // Setup.
        Initialize();
        LibraryInventory.CreateItem(Item);
        LibraryERM.FindVATProductPostingGroup(VATProductPostingGroup);
        Item.VALIDATE("VAT Prod. Posting Group", VATProductPostingGroup.Code);

        // Exercise.
        Item.MODIFY(true);

        // Verify.
        Item.GET(Item."No.");
        Item.TESTFIELD("VAT Prod. Posting Group", VATProductPostingGroup.Code);
    end;

    [Test]
    procedure SetupSalesReceivables();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // Verify OIOUBL related fields exist and able to validate the values with no error.

        // Setup and Exercise: Update various OIOUBL fields in Sales And Receivables Setup.
        Initialize();

        // Verify.
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Sales & Receivables Setup", InvoicePathTxt);
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Sales & Receivables Setup", CrMemoPathTxt);
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Sales & Receivables Setup", ReminderPathTxt);
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Sales & Receivables Setup", FinChrgMemoPathTxt);

        SalesReceivablesSetup.GET();
        SalesReceivablesSetup.TESTFIELD("OIOUBL-Invoice Path", TEMPORARYPATH());
        SalesReceivablesSetup.TESTFIELD("OIOUBL-Cr. Memo Path", TEMPORARYPATH());
        SalesReceivablesSetup.TESTFIELD("OIOUBL-Reminder Path", TEMPORARYPATH());
        SalesReceivablesSetup.TESTFIELD("OIOUBL-Fin. Chrg. Memo Path", TEMPORARYPATH());
    end;

    [Test]
    procedure SetupCurrencyCode();
    var
        Currency: Record Currency;
    begin
        // Verify OIOUBL Currency Code field exists in Currency table and Code and OIOUBL Currency Code have same value.

        // Setup.
        Initialize();
        LibraryERM.CreateCurrency(Currency);
        Currency.VALIDATE("OIOUBL-Currency Code", Currency.Code);

        // Exercise.
        Currency.MODIFY(true);

        // Verify.
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::Currency, CurrencyCodeTxt);
        Currency.GET(Currency.Code);
        Currency.TESTFIELD("OIOUBL-Currency Code", Currency.Code);
    end;

    [Test]
    procedure SetupCustomer();
    var
        Customer: Record Customer;
        Customer2: Record Customer;
        CustomerNo: Code[20];
    begin
        // Verify GLN No. and Account Code fields exist in Customer and able to validate the values with no error.

        // Setup.
        Initialize();
        CreateCustomerWithGLNNo(Customer);

        // Exercise.
        CustomerNo := CreateAndModifyCustomer(Customer.GLN, Customer."OIOUBL-Account Code");

        // Verify.
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::Customer, GLNNoTok);
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::Customer, AccountCodeTxt);
        Customer2.GET(CustomerNo);
        Customer2.TESTFIELD(GLN, Customer.GLN);
        Customer2.TESTFIELD("OIOUBL-Account Code", Customer."OIOUBL-Account Code");
    end;

    [Test]
    procedure ElecServiceInvoicesWithBlankLCYCodeError();
    begin
        // Verify error while creating Electronic Service Invoice with blank LCY Code on G/L Setup.
        Initialize();
        PostServiceOrderAndCreateElecServiceInvoice('', BlankLCYCodeErr);
    end;

    [Test]
    procedure ElecServiceInvoicesWithLCYCodeLenghtError();
    begin
        // Verify error while creating Electronic Service Invoice with LCY Code greater than 3 characters on G/L Setup.
        Initialize();
        PostServiceOrderAndCreateElecServiceInvoice(LibraryUtility.GenerateGUID(), LCYCodeLenghtErr);
    end;

    local procedure PostServiceOrderAndCreateElecServiceInvoice(LCYCode: Code[10]; ExpectedError: Text[1024]);
    var
        DocumentNo: Code[20];
    begin
        // Setup: Update LCY Code on G/L Setup, create and post Serive Order.
        DocumentNo := CreateAndPostServiceOrder();
        UpdateGLSetupLCYCode(LCYCode);

        // Exercise.
        asserterror CreateElecServiceInvoicesDocument(DocumentNo);

        // Verify: Verify LCY Code error while creating Electronic Service Invoice.
        Assert.ExpectedError(ExpectedError);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithCurrencyAndMultipleItems();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify XML Data after creating Electronic Invoice Document for Customer with Currency.
        Initialize();
        ElectronicDocumentsWithCurrency(SalesLine."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicCreditMemoWithCurrencyAndMultipleItems();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify XML Data after creating Electronic Credit Memo Document for Customer with Currency.
        Initialize();
        ElectronicDocumentsWithCurrency(SalesLine."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    local procedure ElectronicDocumentsWithCurrency(DocumentType: Option; ReportID: Integer);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Setup: Create and Post Sales Document with multiple Items and Customer having Currency attached.
        CreateSalesDocument(
          SalesHeader, CreateCustomer(FindCurrency()), DocumentType, false, 0);  // False for PricesIncludingVAT, 0 for Line Discount %.
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), 0);  // 0 for Line Discount %.
        SalesHeader.CALCFIELDS("Amount Including VAT");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise: Create Electronic Document.
        RunReport(ReportID, DocumentNo);

        // Verify: Verify XML Data generated after creating Electronic Document for Customer with Currency.
        VerifyDocumentNoAndCurrencyAmount(DocumentNo, SalesHeader."Amount Including VAT", SalesHeader."Posting Date");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithChargeItemAndCurrency();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Verify XML Data after creating Electronic Invoice Document for Customer with Currency and Item Charge.

        // Setup: Create and Post Sales Invoice with Item, Charge (Item) and Customer with Currency attached.
        Initialize();
        CreateSalesDocument(
          SalesHeader, CreateCustomer(FindCurrency()), SalesLine."Document Type"::Invoice,
          false, 0);
        CreateItemChargeSalesLineAndAssignItemCharge(SalesHeader, LibraryInventory.CreateItemChargeNo());
        SalesHeader.CALCFIELDS("Amount Including VAT");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise.
        CreateElectronicInvoiceDocument(DocumentNo);

        // Verify: Verify XML Data generated after creating Electronic Invoice for Customer with Currency.
        VerifyDocumentNoAndCurrencyAmount(DocumentNo, SalesHeader."Amount Including VAT", SalesHeader."Posting Date");
    end;


    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicFinChargeMemoWithoutContactShouldFailIssue();
    var
        SalesHeader: Record "Sales Header";
        FinChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        // Verify that issuing a Finance Charge Memo Header is running the check codeunit.

        // Setup: Create and post Sales Invoice.
        // and make Finance Charge Memo Header with missing contact from sales order.
        Initialize();
        CreateSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false, 0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        FinChargeMemoHeader.GET(CreateFinanceChargeMemo(SalesHeader."Sell-to Customer No."));
        FinChargeMemoHeader.Validate(Contact, '');
        FinChargeMemoHeader.Modify(true);

        // Exercise: Issue Finance Charge Memo Header and check that we get an error
        asserterror IssueFinanceChargeMemo(FinChargeMemoHeader."No.");

        // Verify: Check th error.
        Assert.ExpectedError(ContactEmptyErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicFinChargeMemoWithoutAccountCode();
    var
        SalesHeader: Record "Sales Header";
        IssuedFinChargeMemoNo: Code[20];
        FinChargeMemoNo: Code[20];
    begin
        // Verify XML data after creating Electronic Finance Charge Memo without Account Code on Finance Charge Memo.

        // Setup: Create and post Sales Invoice, create and Issue Finance Charge Memo for the same Customer. Using Blank for Currency, False for PricesIncludingVAT, 0 for Line Discount %.
        Initialize();
        CreateSalesDocument(
          SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false,
          0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        FinChargeMemoNo := CreateAndIssueFinanceChargeMemo(SalesHeader."Sell-to Customer No.");

        // Exercise.
        IssuedFinChargeMemoNo := CreateElectronicFinanceChargeMemoDocument(FinChargeMemoNo);

        // Verify: Verify Issued Finance Charge Memo No., Document Date on generated XML file.
        VerifyElectronicDocumentData(IssuedFinChargeMemoNo, SalesHeader."Document Date");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicFinChargeMemoWithoutAdditionalFee();
    var
        SalesHeader: Record "Sales Header";
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        FinanceChargeMemoLine: Record "Finance Charge Memo Line";
        IssuedFinChargeMemoNo: Code[20];
        FinChargeMemoNo: Code[20];
    begin
        // [SCENARIO 467348] Electronic fin.charge memo is created successfully if no additional fee line in the issued fin.charge memo.
        Initialize();

        // [GIVEN] Issued fin.charge memo has only 'Customer Ledger Entry' line without additional fee.
        CreateSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false, 0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] Amount = 1000 in 'Customer Ledger Entry' fin.charge memo line
        FinChargeMemoNo := CreateFinanceChargeMemo(SalesHeader."Sell-to Customer No.");
        FinanceChargeMemoLine.SetRange("Finance Charge Memo No.", FinChargeMemoNo);
        FinanceChargeMemoLine.SetFilter(Type, '<>%1', FinanceChargeMemoLine.Type::"Customer Ledger Entry");
        FinanceChargeMemoLine.DeleteAll();
        FinanceChargeMemoLine.SetRange(Type);
        FinanceChargeMemoLine.FindFirst();
        FinanceChargeMemoHeader.Get(FinChargeMemoNo);
        IssueFinanceChargeMemo(FinanceChargeMemoHeader."No.");

        // [WHEN] Create electronic fin.charge memo
        IssuedFinChargeMemoNo := CreateElectronicFinanceChargeMemoDocument(FinChargeMemoNo);

        // [THEN] Electronic fin.charge memo is created
        // [THEN] 'cac:ReminderLine' has 'cbc:DebitLineAmount' = 1000
        VerifyElectronicDocumentData(IssuedFinChargeMemoNo, SalesHeader."Document Date");
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:ReminderLine', 'cbc:DebitLineAmount', FinanceChargeMemoLine.Amount);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicReminderWithoutContactShouldFailIssue();
    var
        SalesHeader: Record "Sales Header";
        ReminderHeader: Record "Reminder Header";
    begin
        // Verify that issuing a reminder is running the check codeunit.

        // Setup: Create and post Sales Invoice.
        // and make Reminder with missing contact from sales order.
        Initialize();
        CreateSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false, 0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        ReminderHeader.GET(CreateReminder(SalesHeader."Sell-to Customer No."));
        ReminderHeader.Validate(Contact, '');
        ReminderHeader.Modify(true);

        // Exercise: Issue reminder and check that we get an error
        asserterror IssueReminder(ReminderHeader);

        // Verify: Check th error.
        Assert.ExpectedError(ContactEmptyErr);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElectronicReminderWithoutAccountCode();
    var
        SalesHeader: Record "Sales Header";
        ReminderNo: Code[20];
        IssuedReminderNo: Code[20];
    begin
        // Verify XML data after creating Electronic Reminder without Account Code on Reminder.

        // Setup: Create and post Sales Invoice, create and issue Reminder for the same Customer. Using Blank for Currency, False for PricesIncludingVAT, 0 for Line Discount %.
        Initialize();
        CreateSalesDocument(
          SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false,
          0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ReminderNo := CreateAndIssueReminder(SalesHeader."Sell-to Customer No.");

        // Exercise.
        IssuedReminderNo := CreateElectronicReminderDocument(ReminderNo);

        // Verify: Verify ID and Issue Date for Create Electronic Reminder Report.
        VerifyElectronicDocumentData(IssuedReminderNo, SalesHeader."Document Date");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicReminderWithoutAdditionalFee();
    var
        SalesHeader: Record "Sales Header";
        ReminderHeader: Record "Reminder Header";
        ReminderLine: Record "Reminder Line";
        ReminderNo: Code[20];
        IssuedReminderNo: Code[20];
    begin
        // [SCENARIO 467348] Electronic reminder is created successfully if no additional fee line in the issued reminder.
        Initialize();

        // [GIVEN] Issued reminder has only 'Customer Ledger Entry' line without additional fee.
        CreateSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false, 0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        // [GIVEN] Amount = 1000 in 'Customer Ledger Entry' reminder line
        ReminderNo := CreateReminder(SalesHeader."Sell-to Customer No.");
        ReminderLine.SetRange("Reminder No.", ReminderNo);
        ReminderLine.SetFilter(Type, '<>%1', ReminderLine.Type::"Customer Ledger Entry");
        ReminderLine.DeleteAll();
        ReminderLine.SetRange(Type);
        ReminderLine.FindFirst();
        ReminderLine.Validate(Amount, LibraryRandom.RandIntInRange(1000, 2000));
        ReminderLine.Modify(true);
        ReminderHeader.Get(ReminderNo);
        IssueReminder(ReminderHeader);

        // [WHEN] Create electronic reminder
        IssuedReminderNo := CreateElectronicReminderDocument(ReminderNo);

        // [THEN] Electronic reminder is created
        // [THEN] 'cac:ReminderLine' has 'cbc:DebitLineAmount' = 1000
        VerifyElectronicDocumentData(IssuedReminderNo, SalesHeader."Document Date");
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:ReminderLine', 'cbc:DebitLineAmount', ReminderLine.Amount);
        // [THEN] No conformation message when issueing the reminder
    end;


    [Test]
    [HandlerFunctions('ConfirmTextHandler,MessageHandler')]
    procedure ElectronicReminderWithoutAdditionalFeeAndBlankGLAccLine();
    var
        SalesHeader: Record "Sales Header";
        ReminderHeader: Record "Reminder Header";
        ReminderLine: Record "Reminder Line";
        ReminderNo: Code[20];
        IssuedReminderNo: Code[20];
    begin
        // [SCENARIO 467348] Confirmation message appeared when issuing reminder having line with blank 'No.', only valid line is exported.
        Initialize();

        // [GIVEN] Issued reminder has 'Customer Ledger Entry' line with Amount = 1000
        // [GIVEN] 'No.' is blank in 'G/L Account' reminder line
        CreateSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false, 0);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        ReminderNo := CreateReminder(SalesHeader."Sell-to Customer No.");
        UpdateReminderHaveCLELine(ReminderLine, ReminderNo);
        UpdateReminderAddGLAccLine(ReminderNo);
        ReminderHeader.Get(ReminderNo);
        IssueReminder(ReminderHeader);

        // [WHEN] Create electronic reminder
        IssuedReminderNo := CreateElectronicReminderDocument(ReminderNo);

        // [THEN] Electronic reminder is created
        // [THEN] 'cac:ReminderLine' has 'cbc:DebitLineAmount' = 1000
        VerifyElectronicDocumentData(IssuedReminderNo, SalesHeader."Document Date");
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:ReminderLine', 'cbc:DebitLineAmount', ReminderLine.Amount);

        // [THEN] Confirmation message appeared about reminder contains line with blank 'No.'
        Assert.ExpectedMessage(
           'The Reminder %1 contains lines in which either the Type or the No. is empty', LibraryVariableStorage.DequeueText());
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithUnitPriceMoreThanTwoDecimal();
    var
        SalesHeader: Record "Sales Header";
        SalesInvLine: Record "Sales Invoice Line";
        Currency: Record Currency;
        DocumentNo: Code[20];
        UnitPrice: Decimal;
    begin
        // Verify XML data after Create Electronic Invoices for Item with more than two decimal digits in Unit Price.

        // Setup:  Create and Post Sales Invoice.
        Initialize();
        DocumentNo :=
          CreateAndPostSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice,
            CreateItemWithUnitPrice(), LibraryRandom.RandDec(10, 2), false);  // Using Random value for VAT%.
        SalesInvLine.SetRange("Document No.", DocumentNo);
        SalesInvLine.FindFirst();

        // Exercise.
        CreateElectronicInvoiceDocument(DocumentNo);

        // Verify: Verify ID and Issue Date for Create Electronic Invoice Report.
        VerifyElectronicDocumentData(DocumentNo, SalesHeader."Document Date");

        // Verify: Verify Unit Price on document matches Unit Price on Electronic Document
        Currency.InitRoundingPrecision();
        UnitPrice := Round(SalesInvLine.Amount / SalesInvLine.Quantity, Currency."Unit-Amount Rounding Precision");
        VerifyNodeDecimalValue('cbc:PriceAmount', UnitPrice);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicCrMemoWithUnitPriceMoreThanTwoDecimal();
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        DocumentNo: Code[20];
    begin
        // Verify XML data after Create Electronic Credit Memos for Item with more than two decimal digits in Unit Price.

        // Setup:  Create and Post Sales Credit Memo.
        Initialize();
        DocumentNo :=
          CreateAndPostSalesDocument(SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::"Credit Memo",
            CreateItemWithUnitPrice(), LibraryRandom.RandDec(10, 2), false);  // Using Random value for VAT%.
        SalesCrMemoLine.SetRange("Document No.", DocumentNo);
        SalesCrMemoLine.FindFirst();

        // Exercise: Run Create Electronic Credit Memo Report.
        CreateElectronicCreditMemoDocument(DocumentNo);

        // Verify: Verify ID and Issue Date for Create Electronic Credit Memos Report.
        VerifyElectronicDocumentData(DocumentNo, SalesHeader."Document Date");
        // Verify: Verify Unit Price on document matches Unit Price on Electronic Document
        VerifyNodeDecimalValue('cbc:PriceAmount', SalesCrMemoLine."Unit Price");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithNormalVAT();
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        // Verify details in the Electronic Invoice generated from Posted Sales Invoice when VAT Calculation Type is Normal VAT.
        Initialize();
        CreateCustomerWithGLNNo(Customer);
        PostSalesOrderAndCreateElecSalesInvoice(
          Customer."No.", LibraryInventory.CreateItem(Item), 'StandardRated', LibraryRandom.RandDec(10, 2));  // Using Random value for VAT%.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithReverseChargeVAT();
    begin
        // Verify details in the Electronic Invoice generated from Posted Sales Invoice when VAT Calculation Type is Reverse Charge VAT.
        Initialize();
        PostSalesOrderAndCreateElecSalesInvoice(
          CreateCustomerWithReverseChargeVAT(), CreateItemWithReverseChargeVAT(), 'ReverseCharge', LibraryRandom.RandDec(10, 2));  // Using Random value for VAT%.
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithZeroVAT();
    var
        Customer: Record Customer;
        Item: Record Item;
    begin
        // Verify details in the Electronic Invoice generated from Posted Sales Invoice when VAT Calculation Type is Normal VAT and VAT% is Zero.
        Initialize();
        CreateCustomerWithGLNNo(Customer);
        PostSalesOrderAndCreateElecSalesInvoice(Customer."No.", LibraryInventory.CreateItem(Item), 'ZeroRated', 0.0);  // Taken 0 for VAT%.
    end;


    local procedure PostSalesOrderAndCreateElecSalesInvoice(CustomerNo: Code[20]; ItemNo: Code[20]; RowValue: Text; VATPercent: Decimal);
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Post Sales order and generate Electronic Invoice from Posted Sales Invoice.
        PostedDocumentNo :=
          CreateAndPostSalesDocument(SalesHeader, CustomerNo, SalesHeader."Document Type"::Order, ItemNo, VATPercent, false);
        SalesInvoiceLine.SETRANGE("Document No.", PostedDocumentNo);
        SalesInvoiceLine.FINDFIRST();
        CompanyInformation.GET();

        // Exercise.
        CreateElectronicInvoiceDocument(PostedDocumentNo);

        // Verify:
        VerifyElectronicDocumentDetails(PostedDocumentNo, SalesHeader."No.", SalesInvoiceLine."VAT %", CompanyInformation.Name);
        LibraryXMLReadOnServer.VerifyNodeValueInSubtree('cac:TaxCategory', IDCapTxt, RowValue);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicCrMemoWithPriceIncVATFalse();
    begin
        // Verify details in the Electronic Credit Memo generated from Posted Sales Credit Memo with Price Incl. VAT as False.
        PostSalesCreditMemoAndCreateElecSalesCreditMemo(false);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicCrMemoWithPriceIncVATTrue();
    begin
        // Verify details in the Electronic Credit Memo generated from Posted Sales Credit Memo with Price Incl. VAT as True.
        PostSalesCreditMemoAndCreateElecSalesCreditMemo(true);
    end;

    local procedure PostSalesCreditMemoAndCreateElecSalesCreditMemo(PriceInclVAT: Boolean);
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
        Item: Record Item;
        SalesCrMemoLine: Record "Sales Cr.Memo Line";
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Post Sales Credit Memo and generate Electronic Invoice from Posted Credit Memo.
        Initialize();
        CreateCustomerWithGLNNo(Customer);
        PostedDocumentNo :=
          CreateAndPostSalesDocument(SalesHeader, Customer."No.", SalesHeader."Document Type"::"Credit Memo",
            LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2), PriceInclVAT);  // Using Random value for VAT%.
        SalesCrMemoLine.SETRANGE("Document No.", PostedDocumentNo);
        SalesCrMemoLine.FINDFIRST();
        CompanyInformation.GET();

        // Exercise.
        CreateElectronicCreditMemoDocument(PostedDocumentNo);

        // Verify:
        VerifyElectronicDocumentDetails(PostedDocumentNo, '', SalesCrMemoLine."VAT %", CompanyInformation.Name);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithBlankIBANNo();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify Payment Means code and Payment Terms code on generated XML from Electronic Invoice when IBAN No. is blank on Company Information.
        Initialize();
        CompanyInformation.GET();
        CreateElecInvAndVerifyPaymentMeansAndChannelCode(
          '', '42', STRSUBSTNO(PaymentChannelCodeTxt, CompanyInformation."Country/Region Code"));  // Taken 42 for Payment Means Code as specified in base object codeunit OIOUBL Export Sales Invoice.
    end;

    local procedure CreateElecInvAndVerifyPaymentMeansAndChannelCode(IBAN: Code[50]; PaymentMeansCode: Text; PaymentChannelCode: Text);
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // Setup and Exercise.
        CreateElecInvoiceWithIBAN(SalesInvoiceHeader, IBAN, SalesHeader."Document Type"::Order);

        // Verify: Verify Payment Means and Payment Channel Code.
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice Document.
        LibraryXMLReadOnServer.VerifyNodeValue(PaymentMeansCodeCapTxt, PaymentMeansCode);
        LibraryXMLReadOnServer.VerifyNodeValue(PaymentChannelCodeCapTxt, PaymentChannelCode);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithBlankSalesOrderNo();
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        // Verify Sales Order ID on generated XML from Electronic Invoice when Order No. is blank on Posted Sales Invoice.

        // Setup and Exercise.
        Initialize();
        CreateElecInvoiceWithIBAN(SalesInvoiceHeader, '', SalesHeader."Document Type"::Invoice);  // '' for IBAN No.

        // Verify: Verify Sales Order ID.
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());  // Initialize generated Electronic Invoice Document.
        LibraryXMLReadOnServer.VerifyNodeValue(SalesOrderIDCapTxt, SalesInvoiceHeader."Pre-Assigned No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithBlankServiceOrderNo();
    var
        ServiceHeader: Record "Service Header";
        ServiceInvoiceNo: Code[20];
        PostedInvoiceNo: Code[20];
    begin
        // Verify Customer Reference on generated XML from Electronic Invoice when Order No. is blank on Posted Service Invoice.
        Initialize();
        ServiceInvoiceNo := CreateAndPostServiceDocumentWithDescription(PostedInvoiceNo, ServiceHeader."Document Type"::Invoice, 'Test');  // Test Value for Description Value.

        // Exercise.
        CreateElecServiceInvoicesDocument(PostedInvoiceNo);

        // Verify: Verify Customer Reference No on generated XML.
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());  // Initialize generated Electronic Invoice Document.
        LibraryXMLReadOnServer.VerifyNodeValue(CustomerReferenceCapTxt, ServiceInvoiceNo);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithVATRegistrationNo();
    var
        CompanyInformation: Record "Company Information";
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ElementValue: Text;
    begin
        // Verify VAT Registration No on generated XML from Electronic Invoice contains Company Information Country/Region code.

        // Setup and Exercise.
        CreateElecInvoiceWithIBAN(SalesInvoiceHeader, '', SalesHeader."Document Type"::Order);  // '' for IBAN No.
        CompanyInformation.GET();

        // Verify:
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());  // Initialize generated Electronic Invoice Document.
        ElementValue := LibraryXMLReadOnServer.GetElementValue(EndpointIDCapTxt);
        Assert.AreEqual(
          COPYSTR(ElementValue, 1, 2), CompanyInformation."Country/Region Code",
          STRSUBSTNO(ValidationErr, ElementValue, CompanyInformation."Country/Region Code"));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithLongDescription();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify that Name is of only 40 Characters while Description is of 50 Characters on Electronic Invoice XML Report.
        Initialize();
        ElectronicDocumentWithLongDescription(SalesHeader."Document Type"::Invoice, REPORT::"OIOUBL-Create Elec. Invoices");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicCreditMemoWithLongDescription();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify that Name is of only 40 Characters while Description is of 50 Characters on Electronic Credit Memo XML Report.
        Initialize();
        ElectronicDocumentWithLongDescription(SalesHeader."Document Type"::"Credit Memo", REPORT::"OIOUBL-Create Elec. Cr. Memos");
    end;

    local procedure ElectronicDocumentWithLongDescription(DocumentType: Option; ReportID: Integer);
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        DocumentNo: Code[20];
    begin
        // Setup: Create and Post Sales Document with more than 50 characters long Description.
        CreateSalesHeader(SalesHeader, CreateCustomer(''), DocumentType, false);  // False for Prices Including VAT.
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), 0);  // 0 for Line Discount %.
        SalesLine.VALIDATE(Description, DescriptionTxt);
        SalesLine.MODIFY(true);
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise: Create Electronic Document.
        RunReport(ReportID, DocumentNo);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceInvoiceWithLongDescription();
    var
        ServiceHeader: Record "Service Header";
        DocumentNo: Code[20];
    begin
        // Verify that Name is of only 40 Characters while Description is of 50 Characters on Electronic Service Invoice XML Report.
        Initialize();
        CreateAndPostServiceDocumentWithDescription(DocumentNo, ServiceHeader."Document Type"::Invoice, DescriptionTxt);

        // Exercise.
        CreateElecServiceInvoicesDocument(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicServiceCreditMemoWithLongDescription();
    var
        ServiceHeader: Record "Service Header";
        DocumentNo: Code[20];
    begin
        // Verify that Name is of only 40 Characters while Description is of 50 Characters on Electronic Service Credit Memo XML Report.
        Initialize();
        CreateAndPostServiceDocumentWithDescription(DocumentNo, ServiceHeader."Document Type"::"Credit Memo", DescriptionTxt);

        // Exercise.
        RunReportCreateElecServiceCrMemos(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithPartialLineDiscount();
    var
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // Verify Amount on Electronic Invoice XML Document when Prices Including VAT TRUE and Partial Line Discount % is used.

        // Setup: Create and Post Sales Document.
        Initialize();
        CreateSalesDocument(
          SalesHeader, CreateCustomer(FindCurrency()), SalesHeader."Document Type"::Invoice,

          true, LibraryRandom.RandIntInRange(10, 50));  // TRUE for PricesIncludingVAT, Random Line Discount %.
        SalesHeader.CALCFIELDS("Amount Including VAT");
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise: Create Electronic Invoice Document.
        CreateElectronicInvoiceDocument(DocumentNo);

        // Verify: Verify Amount after posting Sales Invoice with Prices Incl. VAT and Random Line Discount in generated XML.
        VerifyValuesOnElectronicDocument(cbcAmountInclTaxCapTxt, SalesHeader."Amount Including VAT");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElectronicInvoiceWithFullLineDiscount();
    var
        SalesHeader: Record "Sales Header";
        DocumentNo: Code[20];
    begin
        // Verify Amount on Electronic Invoice XML Document when Prices Including VAT FALSE and Full Line Discount % is used.

        // Setup: Create and Post Sales Document.
        Initialize();
        CreateSalesDocument(
          SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice, false,
          100);  // False for PricesIncludingVAT, 100 for Line Discount %.
        DocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Exercise: Create Electronic Invoice Document.
        CreateElectronicInvoiceDocument(DocumentNo);

        // Verify: Verify that Amount is Zero when Full Line Discount % is updated on Posted Sales Invoice.
        VerifyValuesOnElectronicDocument(cbcAmountInclTaxCapTxt, 0.0);
    end;

    [Test]
    procedure CheckOIOUBLProfileCodeOnSalesHeader();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        CustomerWithBillTo: Record Customer;
    begin
        // Verify Profile code on Sales Header as per the Bill-to Customer No..

        // Setup: Create customer with OIOUBL Profile codes and update Bill -to Customer No.
        CreateCustomerWithOIOUBLProfileCode(Customer);
        CreateCustomerWithOIOUBLProfileCode(CustomerWithBillTo);
        CustomerWithBillTo.VALIDATE("Bill-to Customer No.", Customer."No.");
        CustomerWithBillTo.MODIFY(true);

        // Exercise: Create Sales header.
        CreateSalesHeader(
          SalesHeader, CustomerWithBillTo."No.", SalesHeader."Document Type"::Invoice,
          false);

        // Verify: Verify the OIOUBL profile code in the Sales Header.
        SalesHeader.TESTFIELD("OIOUBL-Profile Code", Customer."OIOUBL-Profile Code");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElecSalesInvoiceWithIBAN();
    begin
        // Verify Bank Branch No. and Bank Account No. exist in Electronic Sales Invoice when IBAN is not blank in Company Information.
        ElecDocumentWithIBAN(ElecDocumentType::"Sales Invoice");
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure ElecServiceInvoiceWithIBAN();
    begin
        // Verify Bank Branch No. and Bank Account No. exist in Electronic Service Invoice when IBAN is not blank in Company Information.
        ElecDocumentWithIBAN(ElecDocumentType::"Service Invoice");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElecReminderWithIBAN();
    begin
        // Verify Bank Branch No. and Bank Account No. exist in Electronic Reminder when IBAN is not blank in Company Information.
        ElecDocumentWithIBAN(ElecDocumentType::Reminder);
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler,MessageHandler')]
    procedure ElecFinanceChargeMemoWithIBAN();
    begin
        // Verify Bank Branch No. and Bank Account No. exist in Electronic Financial Charge Memo when IBAN is not blank in Company Information.
        ElecDocumentWithIBAN(ElecDocumentType::"Fin. Charge Memo");
    end;

    local procedure Initialize();
    var
        SalesHeader: Record "Sales Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        SalesHeader.DontNotifyCurrentUserAgain(SalesHeader.GetModifyBillToCustomerAddressNotificationId());
        SalesHeader.DontNotifyCurrentUserAgain(SalesHeader.GetModifyCustomerAddressNotificationId());
        LibrarySales.SetStockoutWarning(false);
        ModifySalesReceivablesSetup();
        UpdateOIOUBLCountryRegion();  // Update Country/Region.
        UpdateOIOUBLCurrency();  // Update Currency.
        UpdateServiceMgtSetup();

        DocumentSendingProfile.DELETEALL();
        DocumentSendingProfile.INIT();
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile."Electronic Format" := 'OIOUBL';
        DocumentSendingProfile.INSERT();

        OIOUBLNewFileMock.Setup(OIOUBLNewFileMock);
    end;

    local procedure ComputeFinChargeMemoDate("Code": Code[10]): Date;
    var
        FinanceChargeTerms: Record "Finance Charge Terms";
    begin
        // Calculate Date using Random value.
        FinanceChargeTerms.GET(Code);
        exit(
          CALCDATE('<' + FORMAT(LibraryRandom.RandInt(5)) + 'D>', CALCDATE(FinanceChargeTerms."Due Date Calculation", WORKDATE())));
    end;

    local procedure ComputeReminderDate(ReminderTermsCode: Code[10]): Date;
    var
        ReminderLevel: Record "Reminder Level";
    begin
        ReminderLevel.SETRANGE("Reminder Terms Code", ReminderTermsCode);
        ReminderLevel.FINDFIRST();
        exit(CALCDATE('<' + FORMAT(LibraryRandom.RandInt(10)) + 'D>', CALCDATE(ReminderLevel."Grace Period", WORKDATE())));
    end;

    local procedure CreateFinanceChargeMemo(CustomerNo: Code[20]): Code[20];
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        LibraryERM.CreateFinanceChargeMemoHeader(FinanceChargeMemoHeader, CustomerNo);
        FinanceChargeMemoHeader.VALIDATE("Document Date", ComputeFinChargeMemoDate(FinanceChargeMemoHeader."Fin. Charge Terms Code"));
        FinanceChargeMemoHeader.VALIDATE(Address, FinanceChargeMemoHeader."No.");
        FinanceChargeMemoHeader.VALIDATE(City, FindCity());
        FinanceChargeMemoHeader.VALIDATE(Contact, CustomerNo);  // Value not important for Test.
        FinanceChargeMemoHeader.MODIFY(true);
        SuggestFinanceChargeMemoLines(FinanceChargeMemoHeader."No.");
        exit(FinanceChargeMemoHeader."No.");
    end;

    local procedure CreateAndIssueFinanceChargeMemo(CustomerNo: Code[20]): Code[20];
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
    begin
        FinanceChargeMemoHeader.GET(CreateFinanceChargeMemo(CustomerNo));
        IssueFinanceChargeMemo(FinanceChargeMemoHeader."No.");
        exit(FinanceChargeMemoHeader."No.");
    end;

    local procedure CreateReminder(CustomerNo: Code[20]): Code[20];
    var
        ReminderHeader: Record "Reminder Header";
    begin
        LibraryERM.CreateReminderHeader(ReminderHeader);
        ReminderHeader.VALIDATE("Customer No.", CustomerNo);
        ReminderHeader.VALIDATE("Document Date", ComputeReminderDate(ReminderHeader."Reminder Terms Code"));
        ReminderHeader.VALIDATE(Address, ReminderHeader."No.");
        ReminderHeader.VALIDATE(Contact, CustomerNo);  // Value not important for Test.
        ReminderHeader.VALIDATE(City, FindCity());
        ReminderHeader.MODIFY(true);
        SuggestReminderLines(ReminderHeader."No.");
        exit(ReminderHeader."No.");
    end;

    local procedure CreateAndIssueReminder(CustomerNo: Code[20]): Code[20];
    var
        ReminderHeader: Record "Reminder Header";
    begin
        ReminderHeader.GET(CreateReminder(CustomerNo));
        IssueReminder(ReminderHeader);
        exit(ReminderHeader."No.");
    end;

    local procedure CreateAndModifyCountryRegion(): Code[10];
    var
        CountryRegion: Record "Country/Region";
    begin
        LibraryERM.CreateCountryRegion(CountryRegion);
        CountryRegion.VALIDATE("OIOUBL-Country/Region Code", CountryRegion.Code);
        CountryRegion.MODIFY(true);
        exit(CountryRegion.Code);
    end;

    local procedure CreateAndModifyCustomer(GLN: Code[13]; AccountCode: Text[30]): Code[20];
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE(GLN, GLN);
        Customer.VALIDATE("OIOUBL-Account Code", AccountCode);
        Customer.MODIFY(true);
        exit(Customer."No.");
    end;

    local procedure CreateAndPostSalesDocument(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Option; ItemNo: Code[20]; VATPct: Decimal; PriceIncludingVAT: Boolean): Code[20];
    var
        SalesLine: Record "Sales Line";
    begin
        CreateSalesHeader(SalesHeader, CustomerNo, DocumentType, PriceIncludingVAT);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, ItemNo, LibraryRandom.RandDec(10, 2));  // Taken Random Quantity.
        SalesLine.VALIDATE("VAT %", VATPct);
        SalesLine.MODIFY(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));  // Post as Ship And Invoice.
    end;

    local procedure CreateAndPostSalesInvoice(var CustomerNo: Code[20]): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        CreateSalesDocument(
          SalesHeader, CreateCustomer(''), SalesHeader."Document Type"::Invoice,
          false, 0);
        CustomerNo := SalesHeader."Sell-to Customer No.";
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostServiceDocumentWithDescription(var PostedInvoiceNo: Code[20]; DocumentType: Option; Description: Text[50]) DocumentNo: Code[20];
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        CreateServiceHeader(ServiceHeader, DocumentType);
        CreateServiceLine(ServiceLine, ServiceHeader);
        ServiceLine.VALIDATE(Description, Description);
        ServiceLine.MODIFY(true);
        DocumentNo := ServiceHeader."No.";
        PostedInvoiceNo := NoSeriesManagement.GetNextNo(ServiceHeader."Posting No. Series", WORKDATE(), false);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
    end;

    local procedure CreateAndPostServiceOrder() PostedInvoiceNo: Code[20];
    var
        ServiceHeader: Record "Service Header";
        ServiceItemLine: Record "Service Item Line";
        ServiceLine: Record "Service Line";
        NoSeriesManagement: Codeunit NoSeriesManagement;
    begin
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order);
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, '');  // Blank for Service Item No.
        CreateServiceLine(ServiceLine, ServiceHeader);
        ServiceLine.VALIDATE("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.MODIFY(true);
        PostedInvoiceNo := NoSeriesManagement.GetNextNo(ServiceHeader."Posting No. Series", WORKDATE(), false);
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
    end;

    local procedure CreateCustomer(CurrencyCode: Code[10]): Code[20];
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
        FinanceChargeTerms: Record "Finance Charge Terms";
    begin
        CompanyInformation.GET();
        LibraryFinanceChargeMemo.CreateFinanceChargeTermAndText(FinanceChargeTerms);
        LibrarySales.CreateCustomer(Customer);
        Customer.VALIDATE("Fin. Charge Terms Code", FinanceChargeTerms.Code);
        Customer.VALIDATE("Reminder Terms Code", CreateReminderTerms());
        Customer.VALIDATE(Address, CompanyInformation.Address);
        Customer.VALIDATE(City, CompanyInformation.City);
        Customer.VALIDATE("Country/Region Code", CompanyInformation."Country/Region Code");
        Customer.VALIDATE("VAT Registration No.", CompanyInformation."VAT Registration No.");
        Customer.VALIDATE(GLN, GLNNoTxt);
        Customer.VALIDATE("OIOUBL-Account Code", Customer."No.");
        Customer.VALIDATE("Currency Code", CurrencyCode);
        Customer.MODIFY(true);
        SetCustomerOIOUBLProfileCode(Customer);
        exit(Customer."No.")
    end;

    local procedure CreateCustomerAndModifyContact(var Customer: Record Customer);
    var
        Contact: Record Contact;
        ContactNo: Code[20];
    begin
        // Find and update Contact page.
        LibrarySales.CreateCustomer(Customer);
        ContactNo := FindContactLinkedToCustomer(Customer."No.");
        ModifyContactPage();
        Contact.GET(ContactNo);

        // Update Customer with Contact.
        Customer.GET(Customer."No.");
        Customer.VALIDATE("Primary Contact No.", ContactNo);
        Customer.MODIFY(true);
    end;

    local procedure CreateCustomerWithOIOUBLProfileCode(var Customer: Record Customer);
    begin
        LibrarySales.CreateCustomer(Customer);
        SetCustomerOIOUBLProfileCode(Customer);
    end;

    local procedure CreateCustomerWithReverseChargeVAT(): Code[20];
    var
        Customer: Record Customer;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        Customer.GET(CreateCustomer(''));
        Customer.VALIDATE("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
        Customer.MODIFY(true);
        exit(Customer."No.")
    end;

    local procedure CreateElectronicCreditMemoDocument(No: Code[20]);
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CreateElectronicCreditMemos: Report "OIOUBL-Create Elec. Cr. Memos";
    begin
        SalesCrMemoHeader.SETRANGE("No.", No);
        CreateElectronicCreditMemos.SETTABLEVIEW(SalesCrMemoHeader);
        CreateElectronicCreditMemos.USEREQUESTPAGE(false);
        CreateElectronicCreditMemos.RUN();
    end;

    local procedure CreateElectronicFinanceChargeMemoDocument(PreAssignedNo: Code[20]): Code[20];
    var
        IssuedFinChargeMemoHeader: Record "Issued Fin. Charge Memo Header";
        CreateElecFinChrgMemos: Report "OIOUBL-Create E-Fin Chrg Memos";
    begin
        IssuedFinChargeMemoHeader.SETRANGE("Pre-Assigned No.", PreAssignedNo);
        CreateElecFinChrgMemos.SETTABLEVIEW(IssuedFinChargeMemoHeader);
        CreateElecFinChrgMemos.USEREQUESTPAGE(false);
        CreateElecFinChrgMemos.RUN();
        IssuedFinChargeMemoHeader.FINDFIRST();
        exit(IssuedFinChargeMemoHeader."No.");
    end;

    local procedure CreateElectronicInvoiceDocument(No: Code[20]);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreateElectronicInvoices: Report "OIOUBL-Create Elec. Invoices";
    begin
        SalesInvoiceHeader.SETRANGE("No.", No);
        CreateElectronicInvoices.SETTABLEVIEW(SalesInvoiceHeader);
        CreateElectronicInvoices.USEREQUESTPAGE(false);
        CreateElectronicInvoices.RUN();
    end;

    local procedure CreateElectronicReminderDocument(PreAssignedNo: Code[20]): Code[20];
    var
        IssuedReminderHeader: Record "Issued Reminder Header";
        CreateElectronicReminders: Report "OIOUBL-Create Elec. Reminders";
    begin
        IssuedReminderHeader.SETRANGE("Pre-Assigned No.", PreAssignedNo);
        CreateElectronicReminders.SETTABLEVIEW(IssuedReminderHeader);
        CreateElectronicReminders.USEREQUESTPAGE(false);
        CreateElectronicReminders.RUN();
        IssuedReminderHeader.FINDFIRST();
        exit(IssuedReminderHeader."No.");
    end;

    local procedure CreateElecInvoiceWithIBAN(var SalesInvoiceHeader: Record "Sales Invoice Header"; IBAN: Code[50]; DocumentType: Option);
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Update Company Information, Create and post Sales Document.
        ModifyCompanyInformation(IBAN);
        CreateCustomerWithGLNNo(Customer);
        PostedDocumentNo :=
          CreateAndPostSalesDocument(
            SalesHeader, Customer."No.", DocumentType, LibraryInventory.CreateItem(Item), LibraryRandom.RandDec(10, 2), false);  // Using Random value for VAT%.
        SalesInvoiceHeader.GET(PostedDocumentNo);

        // Exercise.
        CreateElectronicInvoiceDocument(PostedDocumentNo);
    end;

    local procedure CreateElecServiceInvoicesDocument(No: Code[20]);
    var
        ServiceInvoiceHeader: Record "Service Invoice Header";
        CreateElecServiceInvoices: Report "OIOUBL-Create Elec. Srv. Inv.";
    begin
        ServiceInvoiceHeader.SETRANGE("No.", No);
        CreateElecServiceInvoices.SETTABLEVIEW(ServiceInvoiceHeader);
        CreateElecServiceInvoices.USEREQUESTPAGE(false);
        CreateElecServiceInvoices.RUN();
    end;

    local procedure CreateItemChargeSalesLineAndAssignItemCharge(SalesHeader: Record "Sales Header"; ItemChargeNo: Code[20]);
    var
        ItemChargeAssignmentSales: Record "Item Charge Assignment (Sales)";
        SalesLine: Record "Sales Line";
        UnitOfMeasure: Record "Unit of Measure";
    begin
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::"Charge (Item)", ItemChargeNo, 0);  // Zero for Line Discount %.
        SalesLine.VALIDATE("Unit of Measure", UnitOfMeasure.Code);
        SalesLine.MODIFY(true);
        LibraryInventory.CreateItemChargeAssignment(
          ItemChargeAssignmentSales, SalesLine, SalesHeader."Document Type", SalesHeader."No.", SalesLine."Line No.", ItemChargeNo);
    end;

    local procedure CreateItemWithUnitPrice(): Code[20];
    var
        Item: Record Item;
    begin
        LibraryInventory.CreateItem(Item);
        Item.VALIDATE("Unit Price", LibraryRandom.RandDec(10, 3));  // Take Random Unit Price with more than two decimal.
        Item.MODIFY(true);
        exit(Item."No.");
    end;

    local procedure CreateItemWithReverseChargeVAT(): Code[20];
    var
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Reverse Charge VAT");
        LibraryInventory.CreateItem(Item);
        Item.VALIDATE("VAT Prod. Posting Group", VATPostingSetup."VAT Prod. Posting Group");
        Item.MODIFY(true);
        exit(Item."No.");
    end;

    local procedure CreateReminderLevel(ReminderTermsCode: Code[10]);
    var
        ReminderLevel: Record "Reminder Level";
    begin
        LibraryERM.CreateReminderLevel(ReminderLevel, ReminderTermsCode);
        EVALUATE(ReminderLevel."Grace Period", '<' + FORMAT(LibraryRandom.RandInt(10)) + 'D>');  // Take Random value for Grace Period.
        ReminderLevel.VALIDATE("Additional Fee (LCY)", LibraryRandom.RandInt(10));  // Take Random Additional Fee.
        ReminderLevel.MODIFY(true);
    end;

    local procedure CreateReminderTerms(): Code[10];
    var
        ReminderTerms: Record "Reminder Terms";
    begin
        LibraryERM.CreateReminderTerms(ReminderTerms);
        ReminderTerms.VALIDATE("Minimum Amount (LCY)", LibraryRandom.RandInt(10));  // Take Random Minimum Amount.
        ReminderTerms.MODIFY(true);
        CreateReminderLevel(ReminderTerms.Code);
        exit(ReminderTerms.Code);
    end;

    local procedure CreateSalesDocument(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Option; PricesIncludingVAT: Boolean; LineDiscountPct: Decimal);
    var
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        CreateSalesHeader(SalesHeader, CustomerNo, DocumentType, PricesIncludingVAT);
        CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, LibraryInventory.CreateItem(Item), LineDiscountPct);
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; CustomerNo: Code[20]; DocumentType: Option; PriceIncludingVAT: Boolean);
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        SalesHeader.VALIDATE("Bill-to City", CompanyInformation.City);
        SalesHeader.VALIDATE("Bill-to Address", SalesHeader."Bill-to City");
        SalesHeader.VALIDATE("Sell-to Contact", SalesHeader."Bill-to City");
        SalesHeader.VALIDATE("Prices Including VAT", PriceIncludingVAT);
        SalesHeader.MODIFY(true);
    end;

    local procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; Type: Option; No: Code[20]; LineDiscountPct: Decimal);
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, LibraryRandom.RandDec(10, 2));  // Random Quantity.
        SalesLine.VALIDATE("Unit Price", LibraryRandom.RandDecInRange(10, 100, 2));  // Random Unit Price.
        SalesLine.VALIDATE("Line Discount %", LineDiscountPct);
        SalesLine.MODIFY(true);
    end;

    local procedure CreateServiceHeader(var ServiceHeader: Record "Service Header"; DocumentType: Option);
    var
        Customer: Record Customer;
        PostCode: Record "Post Code";
    begin
        CreateCustomerWithGLNNo(Customer);
        LibraryERM.FindPostCode(PostCode);
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, Customer."No.");
        ServiceHeader.VALIDATE("Contact Name", ServiceHeader."Bill-to Customer No.");
        ServiceHeader.VALIDATE("Bill-to Address", ServiceHeader."Bill-to Customer No.");
        ServiceHeader.VALIDATE("Bill-to City", PostCode.City);
        ServiceHeader.MODIFY(true);
    end;

    local procedure CreateServiceLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header");
    var
        Item: Record Item;
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, LibraryInventory.CreateItem(Item));
        ServiceLine.VALIDATE(Quantity, LibraryRandom.RandDec(10, 2));  // Taken Random value for Quantity.
        ServiceLine.VALIDATE("Unit Price", LibraryRandom.RandDec(10, 2));  // Taken Random value for Unit Price.
        ServiceLine.MODIFY(true);
    end;

    local procedure CreateElectronicSalesInvoice() DocumentNo: Code[20];
    var
        CustomerNo: Code[20];
    begin
        DocumentNo := CreateAndPostSalesInvoice(CustomerNo);
        CreateElectronicInvoiceDocument(DocumentNo);
    end;

    local procedure CreateElectronicReminder() IssuedReminderNo: Code[20];
    var
        CustomerNo: Code[20];
    begin
        CreateAndPostSalesInvoice(CustomerNo);
        IssuedReminderNo := CreateElectronicReminderDocument(CreateAndIssueReminder(CustomerNo));
    end;

    local procedure CreateElectronicFinanceChargeMemo() IssuedFinChargeMemoNo: Code[20];
    var
        CustomerNo: Code[20];
    begin
        CreateAndPostSalesInvoice(CustomerNo);
        IssuedFinChargeMemoNo := CreateElectronicFinanceChargeMemoDocument(CreateAndIssueFinanceChargeMemo(CustomerNo));
    end;

    local procedure CreateElectronicServiceInvoice() DocumentNo: Code[20];
    begin
        DocumentNo := CreateAndPostServiceOrder();
        CreateElecServiceInvoicesDocument(DocumentNo);
    end;

    local procedure ElecDocumentWithIBAN(DocumentType: Option);
    var
        CompanyInfo: Record "Company Information";
        DocumentNo: Code[20];
    begin
        // Setup: Modify Bank Account No. and IBAN in Company Information.
        Initialize();
        CompanyInfo.GET();
        ModifyCompanyBankInfo(LibraryUtility.GenerateGUID(), IBANNoTxt);

        // Exercise: Create Electronic Document.
        case DocumentType of
            ElecDocumentType::"Fin. Charge Memo":
                DocumentNo := CreateElectronicFinanceChargeMemo();
            ElecDocumentType::Reminder:
                DocumentNo := CreateElectronicReminder();
            ElecDocumentType::"Sales Invoice":
                DocumentNo := CreateElectronicSalesInvoice();
            ElecDocumentType::"Service Invoice":
                DocumentNo := CreateElectronicServiceInvoice();
        end;

        // Verify: Verify Payment Means Code, Payment Channel Code, Bank Branch No. and Bank Account No. in generated XML.
        VerifyBankAccInfo();

        // Tear Down.
        ModifyCompanyBankInfo(CompanyInfo."Bank Branch No.", CompanyInfo.IBAN);
    end;

    local procedure FindCity(): Text[30];
    var
        CompanyInformation: Record "Company Information";
        PostCode: Record "Post Code";
    begin
        CompanyInformation.GET();
        PostCode.SETRANGE("Country/Region Code", CompanyInformation."Country/Region Code");
        PostCode.FINDFIRST();
        exit(PostCode.City);
    end;

    local procedure FindContactLinkedToCustomer(CustomerNo: Code[20]): Code[20];
    var
        ContactBusinessRelation: Record "Contact Business Relation";
    begin
        ContactBusinessRelation.SETRANGE("No.", CustomerNo);
        ContactBusinessRelation.FINDFIRST();
        exit(ContactBusinessRelation."Contact No.");
    end;

    local procedure FindCurrency(): Code[10];
    var
        Currency: Record Currency;
    begin
        LibraryERM.FindCurrency(Currency);
        exit(Currency.Code);
    end;

    local procedure CreateCustomerWithGLNNo(var Customer: Record Customer);
    var
        VATPostingSetup: Record "VAT Posting Setup";
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        LibrarySales.CreateCustomer(Customer);
        with Customer do begin
            VALIDATE("Country/Region Code", CompanyInformation."Country/Region Code");
            VALIDATE(GLN, GLNNoTxt);
            "VAT Registration No." := LibraryERM.GenerateVATRegistrationNo("Country/Region Code");
            VALIDATE("VAT Bus. Posting Group", VATPostingSetup."VAT Bus. Posting Group");
            MODIFY(true);
        end;
        SetCustomerOIOUBLProfileCode(Customer);
    end;

    local procedure FindSalesOrder(var SalesHeader: Record "Sales Header"; SellToCustomerNo: Code[20]);
    begin
        SalesHeader.SETRANGE("Document Type", SalesHeader."Document Type"::Order);
        SalesHeader.SETRANGE("Sell-to Customer No.", SellToCustomerNo);
        SalesHeader.FINDFIRST();
    end;

    local procedure IssueFinanceChargeMemo(No: Code[20]);
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        IssueFinanceChargeMemos: Report "Issue Finance Charge Memos";
    begin
        FinanceChargeMemoHeader.SETRANGE("No.", No);
        IssueFinanceChargeMemos.SETTABLEVIEW(FinanceChargeMemoHeader);
        IssueFinanceChargeMemos.USEREQUESTPAGE(false);
        IssueFinanceChargeMemos.RUN();
    end;

    local procedure IssueReminder(var ReminderHeader: Record "Reminder Header");
    var
        IssueReminders: Report "Issue Reminders";
    begin
        IssueReminders.SETTABLEVIEW(ReminderHeader);
        IssueReminders.USEREQUESTPAGE(false);
        IssueReminders.RUN();
    end;

    local procedure ModifyCompanyInformation(IBAN: Code[50]) VATRegistrationNo: Text[20];
    var
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        VATRegistrationNo := LibraryERM.GenerateVATRegistrationNo(CompanyInformation."Country/Region Code");
        CompanyInformation.VALIDATE("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.VALIDATE(IBAN, IBAN);
        CompanyInformation.MODIFY(true);
    end;

    local procedure ModifyCompanyBankInfo(BankAccNo: Text[30]; IBANCode: Code[50]);
    var
        CompanyInformation: Record "Company Information";
    begin
        with CompanyInformation do begin
            GET();
            VALIDATE("Bank Account No.", BankAccNo);
            VALIDATE(IBAN, IBANCode);
            MODIFY(true);
        end;
    end;

    local procedure ModifyContactPage();
    var
        ContactCard: TestPage "Contact Card";
    begin
        // Updating Phone No., Fax No. and E-mail using page so that these get updated on Customer.
        ContactCard.OPENEDIT();
        // TODO
        // ContactCard.FILTER.SETFILTER("No.",ContactNo);
        ContactCard."Phone No.".SETVALUE(LibraryUtility.GenerateRandomPhoneNo());
        ContactCard."Fax No.".SETVALUE(LibraryUtility.GenerateGUID());
        ContactCard."E-Mail".SETVALUE(LibraryUtility.GenerateRandomEmail());
        ContactCard.OK().INVOKE();
    end;

    local procedure ModifySalesReceivablesSetup();
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        // Use TEMPORARYPATH to save the generated xml to avoid hardcoding for path.
        SalesReceivablesSetup.GET();
        SalesReceivablesSetup.VALIDATE("Invoice Rounding", false);
        SalesReceivablesSetup.VALIDATE("OIOUBL-Invoice Path", TEMPORARYPATH());
        SalesReceivablesSetup.VALIDATE("OIOUBL-Cr. Memo Path", TEMPORARYPATH());
        SalesReceivablesSetup.VALIDATE("OIOUBL-Reminder Path", TEMPORARYPATH());
        SalesReceivablesSetup.VALIDATE("OIOUBL-Fin. Chrg. Memo Path", TEMPORARYPATH());
        SalesReceivablesSetup.MODIFY(true);
    end;

    local procedure SuggestFinanceChargeMemoLines(No: Code[20]);
    var
        FinanceChargeMemoHeader: Record "Finance Charge Memo Header";
        SuggestFinChargeMemoLines: Report "Suggest Fin. Charge Memo Lines";
    begin
        FinanceChargeMemoHeader.SETRANGE("No.", No);
        SuggestFinChargeMemoLines.SETTABLEVIEW(FinanceChargeMemoHeader);
        SuggestFinChargeMemoLines.USEREQUESTPAGE(false);
        SuggestFinChargeMemoLines.RUN();
    end;

    local procedure SuggestReminderLines(No: Code[20]);
    var
        ReminderHeader: Record "Reminder Header";
        SuggestReminderLinesRep: Report "Suggest Reminder Lines";
    begin
        ReminderHeader.SETRANGE("No.", No);
        SuggestReminderLinesRep.SETTABLEVIEW(ReminderHeader);
        SuggestReminderLinesRep.USEREQUESTPAGE(false);
        SuggestReminderLinesRep.RUN();
    end;

    local procedure UpdateOIOUBLCurrency();
    var
        Currency: Record Currency;
    begin
        Currency.SETRANGE("OIOUBL-Currency Code", '');
        if Currency.FINDFIRST() then
            Currency.MODIFYALL("OIOUBL-Currency Code", Currency.Code);
    end;

    local procedure UpdateOIOUBLCountryRegion();
    var
        CountryRegion: Record "Country/Region";
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.GET();
        CountryRegion.SETRANGE("OIOUBL-Country/Region Code", '');
        CountryRegion.MODIFYALL("OIOUBL-Country/Region Code", CompanyInfo."Country/Region Code");
    end;

    local procedure UpdateGLSetupLCYCode(LCYCode: Code[10]);
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.GET();
        GeneralLedgerSetup.VALIDATE("LCY Code", LCYCode);
        GeneralLedgerSetup.MODIFY(true);
    end;

    local procedure UpdateReminderHaveCLELine(var ReminderLine: Record "Reminder Line"; ReminderNo: Code[20]);
    begin
        ReminderLine.SetRange("Reminder No.", ReminderNo);
        ReminderLine.SetFilter(Type, '<>%1', ReminderLine.Type::"Customer Ledger Entry");
        ReminderLine.DeleteAll();
        ReminderLine.SetRange(Type);
        ReminderLine.FindFirst();
        ReminderLine.Validate(Amount, LibraryRandom.RandIntInRange(1000, 2000));
        ReminderLine.Modify(true);
    end;

    local procedure UpdateReminderAddGLAccLine(ReminderNo: Code[20]);
    var
        ReminderLine: Record "Reminder Line";
    begin
        ReminderLine.Init();
        ReminderLine."Reminder No." := ReminderNo;
        ReminderLine."Line No." := LibraryUtility.GetNewRecNo(ReminderLine, ReminderLine.FieldNo("Line No."));
        ReminderLine.Validate(Type, ReminderLine.Type::"G/L Account");
        ReminderLine.Validate(Description, LibraryUtility.GenerateGUID());
        ReminderLine.Insert(true);
    end;

    local procedure UpdateServiceMgtSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.GET();
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Invoice Path", TEMPORARYPATH());
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Cr. Memo Path", TEMPORARYPATH());
        ServiceMgtSetup.MODIFY(true);
    end;

    local procedure SetCustomerOIOUBLProfileCode(var Customer: Record Customer);
    begin
        Customer."OIOUBL-Profile Code Required" := true;
        Customer."OIOUBL-Profile Code" := CreateOIOUBLProfile();
        Customer.MODIFY();
    end;

    local procedure CreateOIOUBLProfile(): Code[10];
    var
        "Profile": Record "OIOUBL-Profile";
    begin
        Profile."OIOUBL-Code" := LibraryUtility.GenerateRandomCode(Profile.FIELDNO("OIOUBL-Code"), DATABASE::"OIOUBL-Profile");
        Profile."OIOUBL-Profile ID" := Profile."OIOUBL-Code";
        Profile.INSERT();

        exit(Profile."OIOUBL-Code");
    end;

    local procedure VerifyDocumentNoAndCurrencyAmount(DocumentNo: Code[20]; PayableAmount: Decimal; IssueDate: Date);
    begin
        VerifyElectronicDocumentData(DocumentNo, IssueDate);
        //    LibraryXMLRead.VerifyNodeValue('cbc:PayableAmount',FORMAT(PayableAmount,0,PrecisionTxt));
        VerifyNodeDecimalValue('cbc:PayableAmount', PayableAmount);
    end;

    local procedure VerifyElectronicDocumentData(DocumentNo: Code[20]; DocumentDate: Date);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice, Electronic Credit Memos.
        LibraryXMLReadOnServer.VerifyNodeValue(IDCapTxt, DocumentNo);
        LibraryXMLReadOnServer.VerifyNodeValue('cbc:IssueDate', DocumentDate);
    end;

    local procedure VerifyPostedSalesCrMemoHeader(ContactNo: Code[20]; DocumentNo: Code[20]);
    var
        Contact: Record Contact;
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
    begin
        Contact.GET(ContactNo);
        SalesCrMemoHeader.GET(DocumentNo);
        Assert.AreEqual(
          Contact."Phone No.", SalesCrMemoHeader."OIOUBL-Sell-to Contact Phone No.",
          STRSUBSTNO(ValidationErr, SalesCrMemoHeader.FIELDCAPTION("OIOUBL-Sell-to Contact Phone No."), Contact."Phone No."));
        Assert.AreEqual(
          Contact."Fax No.", SalesCrMemoHeader."OIOUBL-Sell-to Contact Fax No.",
          STRSUBSTNO(ValidationErr, SalesCrMemoHeader.FIELDCAPTION("OIOUBL-Sell-to Contact Fax No."), Contact."Fax No."));
        Assert.AreEqual(
          Contact."E-Mail", SalesCrMemoHeader."OIOUBL-Sell-to Contact E-Mail",
          STRSUBSTNO(ValidationErr, SalesCrMemoHeader.FIELDCAPTION("OIOUBL-Sell-to Contact E-Mail"), Contact."E-Mail"));
    end;

    local procedure VerifyPostedSalesInvoice(ContactNo: Code[20]; DocumentNo: Code[20]);
    var
        Contact: Record Contact;
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        Contact.GET(ContactNo);
        SalesInvoiceHeader.GET(DocumentNo);
        Assert.AreEqual(
          Contact."Phone No.", SalesInvoiceHeader."OIOUBL-Sell-to Contact Phone No.",
          STRSUBSTNO(ValidationErr, SalesInvoiceHeader.FIELDCAPTION("OIOUBL-Sell-to Contact Phone No."), Contact."Phone No."));
        Assert.AreEqual(
          Contact."Fax No.", SalesInvoiceHeader."OIOUBL-Sell-to Contact Fax No.",
          STRSUBSTNO(ValidationErr, SalesInvoiceHeader.FIELDCAPTION("OIOUBL-Sell-to Contact Fax No."), Contact."Fax No."));
        Assert.AreEqual(
          Contact."E-Mail", SalesInvoiceHeader."OIOUBL-Sell-to Contact E-Mail",
          STRSUBSTNO(ValidationErr, SalesInvoiceHeader.FIELDCAPTION("OIOUBL-Sell-to Contact E-Mail"), Contact."E-Mail"));
    end;

    local procedure VerifyElectronicDocumentDetails(PostedDocumentNo: Code[20]; OrderNo: Code[20]; VATPercent: Decimal; CompanyName: Text[100]);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice Document.
        LibraryXMLReadOnServer.VerifyNodeValue(IDCapTxt, PostedDocumentNo);
        // Credit Note should not have a SalesOrderID
        if OrderNo <> '' then
            LibraryXMLReadOnServer.VerifyNodeValue('cbc:SalesOrderID', OrderNo);
        LibraryXMLReadOnServer.VerifyNodeValue(cbcNameCapTxt, CompanyName);
        VerifyNodeDecimalValue(cbcPercentCapTxt, VATPercent);
    end;

    local procedure VerifyValuesOnElectronicDocument(ElementName: Text[30]; ExpectedValue: Variant);
    begin
        LibraryXMLReadOnServer.Initialize(OIOUBLNewFileMock.PopFilePath());
        VerifyNodeDecimalValue(ElementName, ExpectedValue);
    end;

    local procedure VerifyBankAccInfo();
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.GET();
        with LibraryXMLReadOnServer do begin
            Initialize(OIOUBLNewFileMock.PopFilePath()); // Initialize generated Electronic Invoice Document.
            VerifyNodeValue(PaymentMeansCodeCapTxt, '42'); // 42 indicates domestic bank transfer
            VerifyNodeValue(PaymentChannelCodeCapTxt, STRSUBSTNO(PaymentChannelCodeTxt, CompanyInfo."Country/Region Code"));
            VerifyNodeValueInSubtree(PayeeFinAccCapTxt, IDCapTxt, CompanyInfo."Bank Account No.");
            VerifyNodeValueInSubtree(FinInstitutionBranchCapTxt, IDCapTxt, CompanyInfo."Bank Branch No.");
        end;
    end;

    local procedure VerifyNodeDecimalValue(ElementName: text[1024]; ExpectedDecimalValue: Decimal)
    var
        ActualDecimal: Decimal;
    begin
        Evaluate(ActualDecimal, LibraryXMLReadOnServer.GetElementValue(ElementName), 9);
        Assert.AreEqual(ExpectedDecimalValue, ActualDecimal, STRSUBSTNO('Unexpected decimal value in xml file for Element <%1>.', ElementName));
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
    end;

    [ConfirmHandler]
    procedure ConfirmTextHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := true;
        LibraryVariableStorage.Enqueue(Question);
    end;

    local procedure RunReport(ReportID: Integer; No: Code[20]);
    begin
        case ReportID of
            REPORT::"OIOUBL-Create Elec Srv Cr Memo":
                RunReportCreateElecServiceCrMemos(No);
            REPORT::"OIOUBL-Create Elec. Cr. Memos":
                RunReportCreateElecSalesCrMemos(No);
            REPORT::"OIOUBL-Create Elec. Invoices":
                RunReportCreateElecSalesInvoices(No);
        end;
    end;

    local procedure RunReportCreateElecServiceCrMemos(No: Code[20]);
    var
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
        CreateElecSalesCrMemos: Report "OIOUBL-Create Elec Srv Cr Memo";
    begin
        CLEAR(CreateElecSalesCrMemos);
        ServiceCrMemoHeader.SETRANGE("No.", No);
        CreateElecSalesCrMemos.SETTABLEVIEW(ServiceCrMemoHeader);
        CreateElecSalesCrMemos.USEREQUESTPAGE(false);
        CreateElecSalesCrMemos.RUN();
    end;

    local procedure RunReportCreateElecSalesCrMemos(No: Code[20]);
    var
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        CreateElecSalesCrMemos: Report "OIOUBL-Create Elec. Cr. Memos";
    begin
        CLEAR(CreateElecSalesCrMemos);
        SalesCrMemoHeader.SETRANGE("No.", No);
        CreateElecSalesCrMemos.SETTABLEVIEW(SalesCrMemoHeader);
        CreateElecSalesCrMemos.USEREQUESTPAGE(false);
        CreateElecSalesCrMemos.RUN();
    end;

    local procedure RunReportCreateElecSalesInvoices(No: Code[20]);
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        CreateElecSalesInvoice: Report "OIOUBL-Create Elec. Invoices";
    begin
        CLEAR(CreateElecSalesInvoice);
        SalesInvoiceHeader.SETRANGE("No.", No);
        SalesInvoiceHeader.FindFirst();
        CreateElecSalesInvoice.SETTABLEVIEW(SalesInvoiceHeader);
        CreateElecSalesInvoice.USEREQUESTPAGE(false);
        CreateElecSalesInvoice.RUN();
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024]);
    begin
    end;
}