// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148051 "OIOUBL-ERM Sales/Service Docs"
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
        LibraryInventory: Codeunit "Library - Inventory";
        LibrarySales: Codeunit "Library - Sales";
        LibraryService: Codeunit "Library - Service";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryRandom: Codeunit "Library - Random";
        LibraryMarketing: Codeunit "Library - Marketing";
        BlankOrderDateErr: Label 'Order Date must have a value in Sales Header: Document Type=Invoice, No.=%1. It cannot be zero or empty.';
        CrMemoPathTxt: Label 'OIOUBL Service Cr. Memo Path';
        DescriptionErr: Label 'The %1 %2 contains lines in which the Type and the No. are specified, but the Description is empty.', Comment = '%1 = Field Caption, %2 = Field Value';
        ExternalDocumentNoErr: Label 'You must specify the External Document No.';
        InvoicePathTxt: Label 'OIOUBL Service Invoice Path';
        PaymentTermsCodeErr: Label 'Payment Terms Code must have a value in Service Header';
        SalesInvoiceFieldsErr: Label '%1 must have a value in Sales Header: Document Type=Invoice, No.=%2. It cannot be zero or empty';
        ServiceFieldsErr: Label '%1 must have a value in Service Header: Document Type=Credit Memo, No.=%2. It cannot be zero or empty.';
        UOMErr: Label 'The %1 %2 contains lines in which the Unit of Measure field is empty.', Comment = '%1 = Field Caption, %2 = Field Value';
        YourReferenceErr: Label 'Your Reference must have a value in Service Header';
        MissingOIOUBMInfoErr: Label 'The needed information to support OIOUBL is not provided in %1.';
        GLNNoTok: Label '3974567891234';

    [Test]
    procedure SalesCrMemoExtDocNoError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank External Document Number on Sales Credit Memo.
        SetupForExtDocNoError(SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    procedure SalesOrderExtDocNoError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank External Document Number on Sales Order.
        SetupForExtDocNoError(SalesHeader."Document Type"::Order);
    end;

    local procedure SetupForExtDocNoError(DocumentType: Option);
    var
        SalesLine: Record "Sales Line";
    begin
        // Setup: Create Sales Order and modify External Document No. to blank.
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, '', WORKDATE());  // Taken Blank value for External Document Number.

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify error using blank External Document Number on Sales Order Line.
        Assert.ExpectedError(ExternalDocumentNoErr);
    end;

    [Test]
    procedure SalesCrMemoBlankDescError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Description on Sales Credit Memo Line.
        SetupForBlankDescError(SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    procedure SalesOrderBlankDescError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Description on Sales Order Line.
        SetupForBlankDescError(SalesHeader."Document Type"::Order);
    end;

    local procedure SetupForBlankDescError(DocumentType: Option);
    var
        SalesLine: Record "Sales Line";
    begin
        // Setup: Create Sales Order and modify Description to blank.
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, LibraryUtility.GenerateGUID(), WORKDATE());
        ModifySalesLine(SalesLine, '', SalesLine."Unit of Measure");  // Using Random value for Description.

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify error using blank Description on Sales Order Line.
        Assert.ExpectedError(STRSUBSTNO(DescriptionErr, SalesLine."Document Type", SalesLine."Document No."));
    end;

    [Test]
    procedure SalesCrMemoBlankUOMError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Unit Of Measure on Sales Credit Memo Line.
        SetupForBlankUOMError(SalesHeader."Document Type"::"Credit Memo");
    end;

    [Test]
    procedure SalesCrMemoPaymentTermsCodeNotNeeded();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Setup: Create Sales Document and modify Sales Header.
        Initialize();
        CreateSalesDocument(SalesLine, SalesHeader."Document Type"::"Credit Memo", LibraryUtility.GenerateGUID(), WORKDATE());
        ModifySalesHeader(SalesHeader."Document Type"::"Credit Memo", SalesLine."Document No.", '', '');
        SalesHeader.Get(SalesHeader."Document Type"::"Credit Memo", SalesLine."Document No.");

        // Exercise.
        LibrarySales.PostSalesDocument(SalesHeader, true, false);

        // Verify: Not error.
    end;

    [Test]
    procedure SalesOrderBlankUOMError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Unit Of Measure on Sales Order Line.
        SetupForBlankUOMError(SalesHeader."Document Type"::Order);
    end;

    local procedure SetupForBlankUOMError(DocumentType: Option);
    var
        SalesLine: Record "Sales Line";
    begin
        // Setup: Create Sales Order and modify Unit of Measure to blank.
        Initialize();
        CreateSalesDocument(SalesLine, DocumentType, LibraryUtility.GenerateGUID(), WORKDATE());
        ModifySalesLine(SalesLine, SalesLine.Description, '');  // Using Random value for Unit of Measure.

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify error using blank Unit Of Measure on Sales Order Line.
        Assert.ExpectedError(STRSUBSTNO(UOMErr, SalesLine."Document Type", SalesLine."Document No."));
    end;


    [Test]
    procedure ServiceInvoiceYourReferenceError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Your Reference on Service Invoice.
        CreateAndPostModifiedServiceDocument(
          ServiceHeader."Document Type"::Invoice, '',
          FindPaymentTerms(), YourReferenceErr);
    end;

    [Test]
    procedure ServiceInvoiceBlankDescError();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify error using blank Description on Service Invoice.

        // Setup: Create Service Invoice and modify Description to blank.
        Initialize();
        CreateServiceDocument(ServiceLine, ServiceLine."Document Type"::Invoice);
        ModifyServiceLine(ServiceLine, '', ServiceLine."Unit of Measure");

        // Exercise: Post Service Invoice.
        asserterror PostServiceDocument(ServiceLine);

        // Verify: Verify error using blank Description on Service Invoice.
        Assert.ExpectedError(STRSUBSTNO(DescriptionErr, ServiceLine."Document Type"::Invoice, ServiceLine."Document No."));
    end;

    [Test]
    procedure ServiceInvoiceItemTypeBlankUOMError();
    var
        ServiceLine: Record "Service Line";
    begin
        // Verify error using blank Unit Of Measure on Service Invoice for Service Line Type = Item.

        // Setup: Create Service Invoice, Service Line with Type = Item. Modify Unit of Measure to blank.
        Initialize();
        CreateServiceDocument(ServiceLine, ServiceLine."Document Type"::Invoice);
        ModifyServiceLine(ServiceLine, ServiceLine.Description, '');

        // Exercise: Post Service Invoice.
        asserterror PostServiceDocument(ServiceLine);

        // Verify: Verify error using blank Unit Of Measure on Service Invoice.
        Assert.ExpectedError(STRSUBSTNO(UOMErr, ServiceLine."Document Type"::Invoice, ServiceLine."Document No."));
    end;

    [Test]
    procedure ServiceInvoiceGLAccountTypeBlankUOM()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceInvoiceHeader: Record "Service Invoice Header";
    begin
        // [SCENARIO 298260] Blank UoM is accepted for Service Line with Type = G/L Account.
        Initialize();

        // [GIVEN] Service Invoice, Sevice Line with Type = G/L Account and blank Unit of Measure.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Invoice);
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup());
        ServiceLine.TestField("Unit of Measure Code", '');

        // [WHEN] Post Service Invoice.
        PostServiceDocument(ServiceLine);

        // [THEN] Service Invoice is posted without any errors.
        LibraryService.FindServiceInvoiceHeader(ServiceInvoiceHeader, ServiceHeader."No.");
    end;

    [Test]
    procedure ServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        // Verify OIOUBL related fields exist and able to validate the values without error in Service Mgt. Setup.

        // Setup.
        Initialize();

        // Exercise.
        ModifyServiceSetup();

        // Verify.
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Service Mgt. Setup", InvoicePathTxt);
        LibraryUtility.CheckFieldExistenceInTable(DATABASE::"Service Mgt. Setup", CrMemoPathTxt);

        ServiceMgtSetup.GET();
        ServiceMgtSetup.TESTFIELD("OIOUBL-Service Invoice Path", TEMPORARYPATH());
        ServiceMgtSetup.TESTFIELD("OIOUBL-Service Cr. Memo Path", TEMPORARYPATH());
    end;

    [Test]
    procedure ServiceCrMemoBlankDescError();
    var
        UnitOfMeasure: Record "Unit of Measure";
    begin
        // Verify error using blank Description on Service Credit Memo Line.
        Initialize();
        LibraryInventory.CreateUnitOfMeasureCode(UnitOfMeasure);
        CreateAndPostModifiedServiceCrMemoLine('', UnitOfMeasure.Code, DescriptionErr);
    end;

    [Test]
    procedure ServiceCrMemoItemBlankUOMError();
    begin
        // Verify error using blank Unit Of Measure on Service Credit Memo Line with Type = Item.
        Initialize();
        CreateAndPostModifiedServiceCrMemoLine(LibraryUtility.GenerateGUID(), '', UOMErr);
    end;

    [Test]
    procedure ServiceCrMemoGLAccountBlankUOM()
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceCrMemoHeader: Record "Service Cr.Memo Header";
    begin
        // [SCENARIO 298260] Blank Unit of Measure is accepted for Service Credit Memo Line with Type = G/L Account.
        Initialize();

        // [GIVEN] Service Credit Memo, Service Line with Type = G/L Account and blank Unit of Measure.
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo");
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::"G/L Account", LibraryERM.CreateGLAccountWithSalesSetup());
        ServiceLine.TestField("Unit of Measure Code", '');

        // [WHEN] Post Service Credit Memo.
        PostServiceDocument(ServiceLine);

        // [THEN] Service Credit Memo is posted without any error.
        LibraryService.FindServiceCrMemoHeader(ServiceCrMemoHeader, ServiceHeader."No.");
    end;

    local procedure CreateAndPostModifiedServiceCrMemoLine(Description: Text[50]; UnitOfMeasure: Text[10]; ExpectedError: Text[1024]);
    var
        ServiceLine: Record "Service Line";
    begin
        // Setup: Create Service Credit Memo and modify Service Line.
        CreateServiceDocument(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        ModifyServiceLine(ServiceLine, Description, UnitOfMeasure);

        // Exercise: Post Service Credit Memo.
        asserterror PostServiceDocument(ServiceLine);

        // Verify: Verify error on Service Credit Memo.
        Assert.ExpectedError(STRSUBSTNO(ExpectedError, ServiceLine."Document Type"::"Credit Memo", ServiceLine."Document No."));
    end;

    [Test]
    procedure ServiceCrMemoBlankBillToNameError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Bill-to Name on Service Credit Memo.
        PostServiceCrMemoWithMandatoryFields('', '', '', '', ServiceHeader.FIELDCAPTION("Bill-to Name"));
    end;

    [Test]
    procedure ServiceCrMemoBlankBillToAddressError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Bill-to Address on Service Credit Memo.
        PostServiceCrMemoWithMandatoryFields(LibraryUtility.GenerateGUID(), '', '', '', ServiceHeader.FIELDCAPTION("Bill-to Address"));
    end;

    [Test]
    procedure ServiceCrMemoBlankBillToCityError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Bill-to City on Service Credit Memo.
        PostServiceCrMemoWithMandatoryFields(
          LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), '', '', ServiceHeader.FIELDCAPTION("Bill-to City"));
    end;

    [Test]
    procedure ServiceCrMemoBlankBillToPostCodeError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Bill-to Post Code on Service Credit Memo.
        PostServiceCrMemoWithMandatoryFields(
          LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), '',
          ServiceHeader.FIELDCAPTION("Bill-to Post Code"));
    end;

    local procedure PostServiceCrMemoWithMandatoryFields(BillToName: Text[50]; BillToAddress: Text[50]; BillToCity: Text[30]; BillToPostCode: Code[20]; FieldCaption: Text);
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        // Setup: Create Service Credit Memo and modify Service Header.
        Initialize();
        CreateServiceDocument(ServiceLine, ServiceLine."Document Type"::"Credit Memo");
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        ServiceHeader.VALIDATE("Bill-to Name", BillToName);
        ServiceHeader.VALIDATE("Bill-to Address", BillToAddress);
        ServiceHeader.VALIDATE("Bill-to City", BillToCity);
        ServiceHeader.VALIDATE("Bill-to Post Code", BillToPostCode);
        ServiceHeader.MODIFY(true);

        // Exercise.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // Verify: Verify expected error on Service Credit Memo.
        Assert.ExpectedError(STRSUBSTNO(ServiceFieldsErr, FieldCaption, ServiceHeader."No."));
    end;

    [Test]
    procedure ServiceCrMemoYourReferenceError();
    var
        ServiceHeader: Record "Service Header";
    begin
        // Verify error using blank Your Reference on Service Credit Memo.
        CreateAndPostModifiedServiceDocument(
          ServiceHeader."Document Type"::"Credit Memo", '',
          FindPaymentTerms(), YourReferenceErr);
    end;

    local procedure CreateAndPostModifiedServiceDocument(DocumentType: Option; YourReference: Text[35]; PaymentTermsCode: Code[10]; ExpectedError: Text[1024]);
    var
        ServiceHeader: Record "Service Header";
    begin
        // Setup: Create Service Document and modify Service Header.
        Initialize();
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, FindCustomer());
        ModifyServiceHeader(ServiceHeader, YourReference, PaymentTermsCode);

        // Exercise.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // Verify: Verify error on Service Document.
        Assert.ExpectedError(ExpectedError);
    end;

    [Test]
    procedure ServiceCrMemoPaymentTermsCodeNotNeeded();
    var
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
    begin
        // Setup: Create Service Document and modify Service Header.
        Initialize();
        CreateServiceDocument(ServiceLine, ServiceHeader."Document Type"::"Credit Memo");
        ServiceHeader.Get(ServiceHeader."Document Type"::"Credit Memo", ServiceLine."Document No.");
        ModifyServiceHeader(ServiceHeader, LibraryUtility.GenerateGUID(), '');

        // Exercise.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // Verify: Not error.
    end;


    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvoiceCompanyInfoBlankNameError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify error while posting Sales Invoice with blank Name on Company Information.
        Initialize();
        CompanyInformation.GET();
        PostSalesInvoiceWithDiffCompanyInfo(
          '', CompanyInformation."VAT Registration No.", '', '', '', CompanyInformation.FIELDCAPTION(Name));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvoiceCompanyInfoBlankVATRegNoError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify error while posting Sales Invoice with blank VAT Registration No. on Company Information.
        Initialize();
        CompanyInformation.GET();
        PostSalesInvoiceWithDiffCompanyInfo(
          CompanyInformation.Name, '', '', '', '', CompanyInformation.FIELDCAPTION("VAT Registration No."));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvoiceCompanyInfoBlankAddressError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify error while posting Sales Invoice with blank Address on Company Information.
        Initialize();
        CompanyInformation.GET();
        PostSalesInvoiceWithDiffCompanyInfo(
          CompanyInformation.Name, CompanyInformation."VAT Registration No.", '', '', '', CompanyInformation.FIELDCAPTION(Address));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvoiceCompanyInfoBlankCityError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify error while posting Sales Invoice with blank City on Company Information.
        Initialize();
        CompanyInformation.GET();
        PostSalesInvoiceWithDiffCompanyInfo(
          CompanyInformation.Name, CompanyInformation."VAT Registration No.", CompanyInformation.Address,
          '', '', CompanyInformation.FIELDCAPTION(City));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvoiceCompanyInfoBlankPostCodeError();
    var
        CompanyInformation: Record "Company Information";
    begin
        // Verify error while posting Sales Invoice with blank Post Code on Company Information.
        Initialize();
        CompanyInformation.GET();
        PostSalesInvoiceWithDiffCompanyInfo(
          CompanyInformation.Name, CompanyInformation."VAT Registration No.", CompanyInformation.Address,
          CompanyInformation.City, '', CompanyInformation.FIELDCAPTION("Post Code"));
    end;

    local procedure PostSalesInvoiceWithDiffCompanyInfo(Name: Text[100]; VATRegistrationNo: Code[20]; Address: Text[100]; City: Text[30]; PostCode: Code[20]; FieldCaption: Text);
    var
        SalesLine: Record "Sales Line";
        CompanyInformation: Record "Company Information";
    begin
        // Setup: Update Company Information and create Sales Invoice.
        CompanyInformation.GET();
        CompanyInformation.VALIDATE("VAT Registration No.", VATRegistrationNo);
        CompanyInformation.VALIDATE(Name, Name);
        CompanyInformation.VALIDATE(Address, Address);
        CompanyInformation.VALIDATE(City, City);
        CompanyInformation.VALIDATE("Post Code", PostCode);
        CompanyInformation.MODIFY(true);
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), WORKDATE());

        // Exercise.
        asserterror PostSalesDocument(SalesLine);
        // Verify: Verify error while posting Sales Invoice with different Company Information.
        Assert.ExpectedError(STRSUBSTNO(MissingOIOUBMInfoErr, CompanyInformation.TABLECAPTION()));
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PostSalesInvBlankCountryRegionCodeError();
    var
        CompanyInformation: Record "Company Information";
        SalesLine: Record "Sales Line";
    begin
        // Verify error while posting Sales Invoice with blank Country Region Code on Company Information.

        // Setup: Update Country Region Code on Company Information, and create Sales Invoice.
        CompanyInformation.GET();
        CompanyInformation."Country/Region Code" := '';
        CompanyInformation.MODIFY(true);
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), WORKDATE());

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify error with blank Country Region Code on Company Information.
        Assert.ExpectedError(STRSUBSTNO(MissingOIOUBMInfoErr, CompanyInformation.TABLECAPTION()));
    end;

    [Test]
    procedure PostSalesInvoiceWithTotalLineAmountPositive();
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        GeneralPostingSetup: Record "General Posting Setup";
        TotalLineAmount: Decimal;
        DocumentNo: Code[20];
    begin
        // Verify G/L Entries after posting Sales Invoice with Total Line Amount positive.

        // Setup: Create Sales Invoice.
        Initialize();
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), WORKDATE());
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        CreateSalesLine(
          SalesLine, SalesHeader, SalesLine."No.", SalesLine.Quantity, -SalesLine."Unit Price" / 2);  // Taken Unit Price less than the existing Sales Line Unit Price.
        TotalLineAmount := GetSalesLineAmount(SalesLine."Document No.");
        GeneralPostingSetup.GET(SalesLine."Gen. Bus. Posting Group", SalesLine."Gen. Prod. Posting Group");

        // Exercise.
        DocumentNo := PostSalesDocument(SalesLine);

        // Verify: Verify Amount and VAT Amount on G/L Entries after posting Sales Invoice.
        VerifyGLEntries(DocumentNo, GeneralPostingSetup."Sales Account", -TotalLineAmount);
    end;

    [Test]
    procedure PostSalesInvoiceWithBlankOrderDateError();
    var
        SalesLine: Record "Sales Line";
    begin
        // Verify error while posting Sales Invoice with blank Order Date on Sales Header.

        // Setup: Create Sales Invoice with blank Order Date.
        Initialize();
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), 0D);

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify error while posting Sales Invoice with blank Order Date on Sales Header.
        Assert.ExpectedError(STRSUBSTNO(BlankOrderDateErr, SalesLine."Document No."));
    end;

    [Test]
    procedure SalesInvoiceBlankBillToNameError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Bill-to Name on Sales Invoice.
        PostSalesInvoiceWithMandatoryFields('', '', '', '', SalesHeader.FIELDCAPTION("Bill-to Name"));
    end;

    [Test]
    procedure SalesInvoiceBlankBillToAddressError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Bill-to Address on Sales Invoice.
        PostSalesInvoiceWithMandatoryFields(LibraryUtility.GenerateGUID(), '', '', '', SalesHeader.FIELDCAPTION("Bill-to Address"));
    end;

    [Test]
    procedure SalesInvoiceBlankBillToCityError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Bill-to City on Service Credit Memo.
        PostSalesInvoiceWithMandatoryFields(
          LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), '', '', SalesHeader.FIELDCAPTION("Bill-to City"));
    end;

    [Test]
    procedure SalesInvoiceBlankBillToPostCodeError();
    var
        SalesHeader: Record "Sales Header";
    begin
        // Verify error using blank Bill-to Post Code on Sales Invoice.
        PostSalesInvoiceWithMandatoryFields(
          LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), LibraryUtility.GenerateGUID(), '',
          SalesHeader.FIELDCAPTION("Bill-to Post Code"));
    end;

    local procedure PostSalesInvoiceWithMandatoryFields(BillToName: Text[50]; BillToAddress: Text[50]; BillToCity: Text[30]; BillToPostCode: Code[20]; FieldCaption: Text);
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Setup: Create Sales Invoice and modify Sales Header.
        Initialize();
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), WORKDATE());
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        SalesHeader."Bill-to Name" := BillToName;
        SalesHeader.VALIDATE("Bill-to Address", BillToAddress);
        SalesHeader.VALIDATE("Bill-to City", BillToCity);
        SalesHeader.VALIDATE("Bill-to Post Code", BillToPostCode);
        SalesHeader.MODIFY(true);

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify expected error on Sales Invoice.
        Assert.ExpectedError(STRSUBSTNO(SalesInvoiceFieldsErr, FieldCaption, SalesHeader."No."));
    end;

    [Test]
    procedure SalesInvoiceBlankPaymentTermsCodeError();
    var
        PaymentMethod: Record "Payment Method";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // Verify error using blank Payment Terms Code on Sales Invoice.
        Initialize();
        CreateSalesDocument(SalesLine, SalesLine."Document Type"::Invoice, LibraryUtility.GenerateGUID(), WORKDATE());
        LibraryERM.FindPaymentMethod(PaymentMethod);
        ModifySalesHeader(SalesLine."Document Type", SalesLine."Document No.", PaymentMethod.Code, '');

        // Exercise.
        asserterror PostSalesDocument(SalesLine);

        // Verify: Verify expected error on Sales Invoice.
        Assert.ExpectedError(
          STRSUBSTNO(SalesInvoiceFieldsErr, SalesHeader.FIELDCAPTION("Payment Terms Code"), SalesLine."Document No."));
    end;

    [Test]
    procedure SalesHeaderValidateSellToCustomerNoOIOUBLContactInfo()
    var
        SalesHeader: Record "Sales Header";
        Customer: Record Customer;
        Contact: Record Contact;
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 366715] OIOUBL Contact Info fields are updated from Customer's Primary Contact when Stan creates Sales Document for Customer.
        Initialize();

        // [GIVEN] Customer "C1" with Primary Contact "CN1" of Person type.
        // [GIVEN] Contact "CN1" has nonempty Phone No., Fax No., E-Mail.
        CreateCustomerWithContactPerson(Customer, Contact);

        // [WHEN] Create Sales Invoice for Customer "C1".
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");

        // [THEN] Fields OIOUBL-Sell-to Contact Phone No./Fax No./E-Mail of Sales Invoice are set from the corresponding fields of Contact "CN1".
        SalesHeader.TestField("Sell-to Contact No.", Contact."No.");
        SalesHeader.TestField("Sell-to Contact", Contact.Name);
        SalesHeader.TestField("OIOUBL-Sell-to Contact Phone No.", Contact."Phone No.");
        SalesHeader.TestField("OIOUBL-Sell-to Contact Fax No.", Contact."Fax No.");
        SalesHeader.TestField("OIOUBL-Sell-to Contact E-Mail", Contact."E-Mail");
    end;

    local procedure Initialize();
    var
        SalesHeader: Record "Sales Header";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        SalesHeader.DontNotifyCurrentUserAgain(SalesHeader.GetModifyBillToCustomerAddressNotificationId());
        SalesHeader.DontNotifyCurrentUserAgain(SalesHeader.GetModifyCustomerAddressNotificationId());
        UpdateCountryRegion();  // Update Country/Region.

        DocumentSendingProfile.DELETEALL();
        DocumentSendingProfile.INIT();
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile."Electronic Format" := 'OIOUBL';
        DocumentSendingProfile.INSERT();
    end;

    local procedure CreateItem(): Code[20];
    var
        Item: Record Item;
    begin
        exit(LibraryInventory.CreateItem(Item));
    end;

    local procedure CreateSalesDocument(var SalesLine: Record "Sales Line"; DocumentType: Option; ExternalDocumentNo: Code[35]; OrderDate: Date);
    var
        SalesHeader: Record "Sales Header";
        PostCode: Record "Post Code";
    begin
        LibraryERM.FindPostCode(PostCode);
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, FindCustomer());
        SalesHeader.VALIDATE("Sell-to Contact", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to Address", SalesHeader."Sell-to Customer No.");
        SalesHeader.VALIDATE("Bill-to City", PostCode.City);
        SalesHeader.VALIDATE("External Document No.", ExternalDocumentNo);
        SalesHeader.VALIDATE("Order Date", OrderDate);
        SalesHeader.MODIFY(true);
        CreateSalesLine(
          SalesLine, SalesHeader, CreateItem(), LibraryRandom.RandDec(10, 2), LibraryRandom.RandDec(10, 2));  // Taken random value for Unit Price and Quantity.
    end;

    local procedure CreateSalesLine(var SalesLine: Record "Sales Line"; SalesHeader: Record "Sales Header"; No: Code[20]; Quantity: Decimal; UnitPrice: Decimal);
    begin
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, No, Quantity);
        SalesLine.VALIDATE("Unit Price", UnitPrice);
        SalesLine.MODIFY(true);
    end;

    local procedure CreateServiceHeader(var ServiceHeader: Record "Service Header"; DocumentType: Option)
    var
        PostCode: Record "Post Code";
    begin
        LibraryERM.FindPostCode(PostCode);
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, FindCustomer());
        ServiceHeader.VALIDATE("Contact Name", ServiceHeader."Bill-to Customer No.");
        ServiceHeader.VALIDATE("Bill-to Address", ServiceHeader."Bill-to Customer No.");
        ServiceHeader.VALIDATE("Bill-to City", PostCode.City);
        ServiceHeader.MODIFY(true);
    end;

    local procedure CreateServiceLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; LineType: Option; No: Code[20])
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, LineType, No);
        ServiceLine.Validate(Quantity, LibraryRandom.RandDecInRange(10, 20, 2));
        ServiceLine.Validate("Unit Price", LibraryRandom.RandDecInRange(100, 200, 2));
        ServiceLine.Modify(true);
    end;

    local procedure CreateServiceDocument(var ServiceLine: Record "Service Line"; DocumentType: Option);
    var
        ServiceHeader: Record "Service Header";
    begin
        CreateServiceHeader(ServiceHeader, DocumentType);
        CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, CreateItem());
    end;

    local procedure CreateCustomerWithContactPerson(var Customer: Record Customer; var Contact: Record Contact)
    var
        ContBusRel: Record "Contact Business Relation";
    begin
        LibrarySales.CreateCustomer(Customer);
        ContBusRel.SetRange("Link to Table", ContBusRel."Link to Table"::Customer);
        ContBusRel.SetRange("No.", Customer."No.");
        ContBusRel.FindFirst();

        LibraryMarketing.CreatePersonContact(Contact);
        Contact.Validate("Company No.", ContBusRel."Contact No.");
        Contact.Validate("Phone No.", LibraryUtility.GenerateRandomNumericText(MaxStrLen(Contact."Phone No.")));
        Contact.Validate("Fax No.", LibraryUtility.GenerateRandomNumericText(MaxStrLen(Contact."Phone No.")));
        Contact.Validate("E-Mail", LibraryUtility.GenerateRandomEmail());
        Contact.Modify(true);

        Customer.Validate("Primary Contact No.", Contact."No.");
        Customer.Modify(true);
    end;

    local procedure FindCustomer(): Code[20];
    var
        Customer: Record Customer;
        CompanyInformation: Record "Company Information";
    begin
        CompanyInformation.GET();
        LibrarySales.CreateCustomer(Customer);
        with Customer do begin
            VALIDATE(GLN, GLNNoTok);
            VALIDATE("Country/Region Code", CompanyInformation."Country/Region Code");
            "VAT Registration No." := LibraryERM.GenerateVATRegistrationNo("Country/Region Code");
            MODIFY(true);
        end;
        exit(Customer."No.");
    end;

    local procedure FindPaymentTerms(): Code[10];
    var
        PaymentTerms: Record "Payment Terms";
    begin
        LibraryERM.FindPaymentTerms(PaymentTerms);
        exit(PaymentTerms.Code);
    end;

    local procedure GetSalesLineAmount(DocumentNo: Code[20]): Decimal;
    var
        SalesLine: Record "Sales Line";
    begin
        SalesLine.SETRANGE("Document No.", DocumentNo);
        SalesLine.CALCSUMS(SalesLine."Line Amount");
        exit(SalesLine."Line Amount");
    end;

    local procedure ModifySalesHeader(DocumentType: Option; DocumentNo: Code[20]; PaymentMethodCode: Code[10]; PaymentTermsCode: Code[10]);
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.GET(DocumentType, DocumentNo);
        SalesHeader.VALIDATE("Payment Method Code", PaymentMethodCode);
        SalesHeader.VALIDATE("Payment Terms Code", PaymentTermsCode);
        SalesHeader.MODIFY(true);
    end;

    local procedure ModifyServiceHeader(var ServiceHeader: Record "Service Header"; YourReference: Text[35]; PaymentTermsCode: Code[10]);
    begin
        ServiceHeader.VALIDATE("Your Reference", YourReference);
        ServiceHeader.VALIDATE("Payment Terms Code", PaymentTermsCode);
        ServiceHeader.MODIFY(true);
    end;

    local procedure ModifySalesLine(SalesLine: Record "Sales Line"; Description: Code[100]; UnitOfMeasure: Code[50]);
    begin
        SalesLine.VALIDATE(Description, Description);
        SalesLine.VALIDATE("Unit of Measure", UnitOfMeasure);
        SalesLine.MODIFY(true);
    end;

    local procedure ModifyServiceLine(ServiceLine: Record "Service Line"; Description: Code[100]; UnitOfMeasure: Code[50]);
    begin
        ServiceLine.VALIDATE(Description, Description);
        ServiceLine.VALIDATE("Unit of Measure", UnitOfMeasure);
        ServiceLine.MODIFY(true);
    end;

    local procedure ModifyServiceSetup();
    var
        ServiceMgtSetup: Record "Service Mgt. Setup";
    begin
        ServiceMgtSetup.GET();
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Invoice Path", TEMPORARYPATH());
        ServiceMgtSetup.VALIDATE("OIOUBL-Service Cr. Memo Path", TEMPORARYPATH());
        ServiceMgtSetup.MODIFY(true);
    end;

    local procedure PostSalesDocument(SalesLine: Record "Sales Line"): Code[20];
    var
        SalesHeader: Record "Sales Header";
    begin
        SalesHeader.GET(SalesLine."Document Type", SalesLine."Document No.");
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure PostServiceDocument(ServiceLine: Record "Service Line");
    var
        ServiceHeader: Record "Service Header";
    begin
        ServiceHeader.GET(ServiceLine."Document Type", ServiceLine."Document No.");
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);
    end;

    local procedure UpdateCountryRegion();
    var
        CountryRegion: Record "Country/Region";
    begin
        CountryRegion.SETRANGE("OIOUBL-Country/Region Code", '');
        if CountryRegion.FINDSET() then
            repeat
                CountryRegion.VALIDATE("OIOUBL-Country/Region Code", CountryRegion.Code);
                CountryRegion.MODIFY(true);
            until CountryRegion.NEXT() = 0;
    end;

    local procedure VerifyGLEntries(DocumentNo: Code[20]; GLAccountNo: Code[20]; Amount: Decimal);
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SETRANGE("Document No.", DocumentNo);
        GLEntry.SETRANGE("G/L Account No.", GLAccountNo);
        GLEntry.FINDFIRST();
        GLEntry.TESTFIELD(Amount, Amount);
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        Reply := false;
    end;
}

