// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 148050 "OIOUBL-Check Sales and Service"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun();
    begin
        // [FEATURE] [OIOUBL]
    end;

    var
        LibrarySales: Codeunit "Library - Sales";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryService: Codeunit "Library - Service";
        LibraryRandom: Codeunit "Library - Random";
        Assert: Codeunit Assert;
        NoSeriesManagement: Codeunit NoSeriesManagement;
        NegSalesLineDiscountErr: Label 'Line Discount % cannot be negative in Sales Line Document Type=''%1'',Document No.=''%2'',Line No.=''%3''.';
        NegServiceLineDiscountErr: Label 'Line Discount % cannot be negative in Service Line Document Type=''%1'',Document No.=''%2'',Line No.=''%3''.';
        NegativeDiscountAmountErr: Label 'The total Line Discount Amount cannot be negative.';
        NegativeAmountErr: Label 'The total Line Amount cannot be negative.';
        GLEntryVerifyErr: Label 'The GLEntry does not exist.';
        NotFoundOnPageErr: Label 'is not found on the page';
        TestFieldNotFoundErr: Label 'TestFieldNotFound';
        GLNNoTok: Label '5790000510146';

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostSalesInvoiceWithNegativeLineDiscPct();
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        Item: Record Item;
    begin
        // Setup: Create customer, Item, Sales Invoice with negative Line discount.
        Initialize();
        CreateOIOUBLCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", LibraryRandom.RandInt(10));
        SalesLine.VALIDATE("Unit Price", LibraryRandom.RandInt(100));
        SalesLine."Line Amount" := SalesLine."Unit Price" * SalesLine.Quantity + LibraryRandom.RandInt(100);
        SalesLine."Line Discount %" := -10;
        SalesLine.MODIFY(true);

        // Exercise: Post the Sales Invoice.
        // Verify: Verify error message pops up when posting.
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, false);
        Assert.ExpectedError(
          STRSUBSTNO(NegSalesLineDiscountErr, SalesLine."Document Type", SalesLine."Document No.", SalesLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostSalesCreditMemoWithNegativeLineDiscAmount();
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        // Setup: Create customer, Item, Sales Credit Memo with negative Line discount Amount.
        Initialize();
        CreateOIOUBLCustomer(Customer);
        LibraryInventory.CreateItem(Item);

        // This Credit Memo has negative Unit Price and Line Discount Amount but postive Line Discount %,
        // they make the total of Line Discount Amount be negative, which cannot be posted.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine1, SalesHeader, SalesLine1.Type::Item, Item."No.", LibraryRandom.RandInt(10));
        SalesLine1.VALIDATE("Unit Price", LibraryRandom.RandInt(100));
        SalesLine1.MODIFY(true);

        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::Item, Item."No.", SalesLine1.Quantity);
        SalesLine2.VALIDATE("Unit Price", -SalesLine1."Unit Price");
        SalesLine2.VALIDATE("Line Discount %", LibraryRandom.RandInt(100));
        SalesLine2.MODIFY(true);

        // Exercise: Post the Sales Document.
        // Verify: Verify error message pops up when posting.
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, false);
        Assert.ExpectedError(NegativeDiscountAmountErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostSalesInvoiceWithNegativeLineAmount();
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        SalesHeader: Record "Sales Header";
    begin
        // Setup: Create customer, Item, Sales Invoice with negative Line Amount
        Initialize();
        CreateOIOUBLCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");

        LibrarySales.CreateSalesLine(SalesLine1, SalesHeader, SalesLine1.Type::Item, Item."No.", LibraryRandom.RandInt(10));
        SalesLine1.VALIDATE("Unit Price", LibraryRandom.RandInt(100));
        SalesLine1.VALIDATE("Line Discount %", LibraryRandom.RandIntInRange(50, 100));
        SalesLine1.MODIFY(true);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::Item, Item."No.", SalesLine1.Quantity);
        SalesLine2.VALIDATE("Unit Price", -SalesLine1."Unit Price");
        SalesLine2.VALIDATE("Line Discount %", LibraryRandom.RandInt(50));
        SalesLine2.MODIFY(true);

        // Exercise: Post the Sales Invoice.
        // Verify: Verify error message pops up when posting.
        asserterror LibrarySales.PostSalesDocument(SalesHeader, false, false);
        Assert.ExpectedError(NegativeAmountErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostSalesInvoiceWithOneNegativeLineButPositiveTotal();
    var
        Customer: Record Customer;
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine1: Record "Sales Line";
        SalesLine2: Record "Sales Line";
        GLEntry: Record "G/L Entry";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Create Customer, Item, Sales Invoice with one negative Line Amount & Line Discount Amount but total is positive.
        Initialize();
        CreateOIOUBLCustomer(Customer);
        LibraryInventory.CreateItem(Item);

        // This Invoice has one line with negative Line Amount and Line Discount Amount but postive Line Discount %,
        // they make the total of Line Amount & Line Discount Amount be positive, which can be posted.
        CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        LibrarySales.CreateSalesLine(SalesLine1, SalesHeader, SalesLine1.Type::Item, Item."No.", LibraryRandom.RandInt(10));
        SalesLine1.VALIDATE("Unit Price", LibraryRandom.RandInt(100));
        SalesLine1.VALIDATE("Line Discount %", LibraryRandom.RandInt(50));
        SalesLine1.MODIFY(true);
        LibrarySales.CreateSalesLine(SalesLine2, SalesHeader, SalesLine2.Type::Item, Item."No.", SalesLine1.Quantity);
        SalesLine2.VALIDATE("Unit Price", -(SalesLine1."Unit Price" - LibraryRandom.RandInt(10)));
        SalesLine2.VALIDATE("Line Discount %", SalesLine1."Line Discount %");
        SalesLine2.MODIFY(true);

        // Exercise: Post the Sales Invoice.
        PostedDocumentNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // Verify: Verify Sales Invoice posted successfully.
        GLEntry.SETRANGE("Document No.", PostedDocumentNo);
        Assert.IsTrue(not GLEntry.ISEMPTY(), GLEntryVerifyErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostServiceOrderWithNegativeLineDiscPct();
    var
        Customer: Record Customer;
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine: Record "Service Line";
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        // Setup: Create customer, Item and Service Order with negative Line Discount.
        Initialize();
        CreateOIOUBLCustomer(Customer);
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        LibraryInventory.CreateItem(Item);

        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, ServiceLine.Type::Item, Item."No.");
        ServiceLine.VALIDATE("Service Item Line No.", ServiceItemLine."Line No.");
        ServiceLine.VALIDATE(Quantity, LibraryRandom.RandInt(10));
        ServiceLine.VALIDATE("Unit Price", LibraryRandom.RandInt(100));
        ServiceLine."Line Amount" := ServiceLine."Unit Price" * ServiceLine.Quantity + LibraryRandom.RandInt(100);
        ServiceLine."Line Discount %" := -10;
        ServiceLine.MODIFY(true);

        // Exercise: Post the Service Order
        // Verify: Verify error message pops up when posting.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, false, false, false);
        Assert.ExpectedError(
          STRSUBSTNO(NegServiceLineDiscountErr, ServiceLine."Document Type", ServiceLine."Document No.", ServiceLine."Line No."));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostServiceOrderWithNegativeLineAmount();
    var
        Customer: Record Customer;
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine1: Record "Service Line";
        ServiceLine2: Record "Service Line";
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        // Setup: Create customer, Item, Service Order with negative line Amount.
        Initialize();
        CreateOIOUBLCustomer(Customer);
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        LibraryInventory.CreateItem(Item);

        CreateAndUpdateServiceLine(ServiceLine1, ServiceHeader, ServiceLine1.Type::Item, Item."No.", ServiceItemLine."Line No.",
          LibraryRandom.RandInt(10), LibraryRandom.RandInt(100), LibraryRandom.RandIntInRange(50, 100));
        CreateAndUpdateServiceLine(ServiceLine2, ServiceHeader, ServiceLine2.Type::Item, Item."No.", ServiceItemLine."Line No.",
          ServiceLine1.Quantity, -ServiceLine1."Unit Price", LibraryRandom.RandInt(50));

        // Exercise: Post the Service Document.
        // Verify: Verify error message pops up when posting.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, false, false, false);
        Assert.ExpectedError(NegativeAmountErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostServiceOrderWithNegativeLineDiscAmount();
    var
        Customer: Record Customer;
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine1: Record "Service Line";
        ServiceLine2: Record "Service Line";
        ServiceItemLine: Record "Service Item Line";
        ServiceItem: Record "Service Item";
    begin
        // Setup: Create customer, Item and Service Order with negative Line Discount Amount.
        CreateOIOUBLCustomer(Customer);
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::Order, Customer."No.");
        LibraryService.CreateServiceItem(ServiceItem, ServiceHeader."Customer No.");
        LibraryService.CreateServiceItemLine(ServiceItemLine, ServiceHeader, ServiceItem."No.");
        LibraryInventory.CreateItem(Item);

        CreateAndUpdateServiceLine(ServiceLine1, ServiceHeader, ServiceLine1.Type::Item, Item."No.", ServiceItemLine."Line No.",
          LibraryRandom.RandInt(10), LibraryRandom.RandInt(100), 0);
        CreateAndUpdateServiceLine(ServiceLine2, ServiceHeader, ServiceLine2.Type::Item, Item."No.", ServiceItemLine."Line No.",
          ServiceLine1.Quantity, -ServiceLine1."Unit Price", LibraryRandom.RandInt(100));

        // Exercise: Post the Service Document.
        // Verify: Verify error message pops up when posting.
        asserterror LibraryService.PostServiceOrder(ServiceHeader, false, false, false);
        Assert.ExpectedError(NegativeDiscountAmountErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PostServiceCreditMemoWithOneNegativeLineButPositiveTotal();
    var
        Customer: Record Customer;
        Item: Record Item;
        ServiceHeader: Record "Service Header";
        ServiceLine1: Record "Service Line";
        ServiceLine2: Record "Service Line";
        GLEntry: Record "G/L Entry";
        PostedDocumentNo: Code[20];
    begin
        // Setup: Create customer, Item and Service Credit Memo with one negative line but total amount is positive.
        CreateOIOUBLCustomer(Customer);
        CreateServiceHeader(ServiceHeader, ServiceHeader."Document Type"::"Credit Memo", Customer."No.");
        PostedDocumentNo := NoSeriesManagement.GetNextNo(ServiceHeader."Posting No. Series", WORKDATE(), false);
        LibraryInventory.CreateItem(Item);

        // This Credit Memo has one line with negative Line Amount and Line Discount Amount but postive Line Discount %,
        // they make the total of Line Amount & Line Discount Amount be positive, which can be posted.
        LibraryService.CreateServiceLine(ServiceLine1, ServiceHeader, ServiceLine1.Type::Item, Item."No.");
        UpdateServiceLine(ServiceLine1, LibraryRandom.RandInt(10),
          LibraryRandom.RandInt(100), LibraryRandom.RandInt(50));
        LibraryService.CreateServiceLine(ServiceLine2, ServiceHeader, ServiceLine2.Type::Item, Item."No.");
        UpdateServiceLine(ServiceLine2, ServiceLine1.Quantity,
          -(ServiceLine1."Unit Price" - LibraryRandom.RandInt(10)), ServiceLine1."Line Discount %");

        // Exercise: Post the Service Document.
        LibraryService.PostServiceOrder(ServiceHeader, true, false, true);

        // Verify: Verify Service Credit Memo posted successfully.
        GLEntry.SETRANGE("Document No.", PostedDocumentNo);
        Assert.IsTrue(not GLEntry.ISEMPTY(), GLEntryVerifyErr);
    end;

    [Test]
    procedure SalesSetupOIOUBLPathsAreHidden()
    var
        SalesSetup: TestPage "Sales & Receivables Setup";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 345034] Default paths for saving OIOUBL documents are not shown on Sales & Receivables Setup page.

        // [WHEN] Open Sales & Receivables Setup page.
        SalesSetup.OpenView();

        // [THEN] Fields Invoice Path, Cr. Memo Path, Reminder Path, Fin. Chrg. Memo Path are not shown on OIOUBL fasttab of Sales Setup page.
        asserterror Assert.IsFalse(SalesSetup."OIOUBL-Invoice Path".Visible(), '');
        Assert.ExpectedError(NotFoundOnPageErr);
        Assert.ExpectedErrorCode(TestFieldNotFoundErr);

        asserterror Assert.IsFalse(SalesSetup."OIOUBL-Cr. Memo Path".Visible(), '');
        Assert.ExpectedError(NotFoundOnPageErr);
        Assert.ExpectedErrorCode(TestFieldNotFoundErr);

        asserterror Assert.IsFalse(SalesSetup."OIOUBL-Reminder Path".Visible(), '');
        Assert.ExpectedError(NotFoundOnPageErr);
        Assert.ExpectedErrorCode(TestFieldNotFoundErr);

        asserterror Assert.IsFalse(SalesSetup."OIOUBL-Fin. Chrg. Memo Path".Visible(), '');
        Assert.ExpectedError(NotFoundOnPageErr);
        Assert.ExpectedErrorCode(TestFieldNotFoundErr);

        SalesSetup.Close();
    end;

    local procedure CreateAndUpdateServiceLine(var ServiceLine: Record "Service Line"; ServiceHeader: Record "Service Header"; Type: Option; ItemNo: Code[20]; ServiceItemLineNo: Integer; Qty: Integer; UnitPrice: Decimal; LineDiscount: Decimal);
    begin
        LibraryService.CreateServiceLine(ServiceLine, ServiceHeader, Type, ItemNo);
        ServiceLine.VALIDATE("Service Item Line No.", ServiceItemLineNo);
        UpdateServiceLine(ServiceLine, Qty, UnitPrice, LineDiscount);
    end;

    local procedure CreateOIOUBLCustomer(var NewCustomer: Record Customer);
    var
        Customer: Record Customer;
        CountryRegionCode: Code[10];
    begin
        CountryRegionCode := GetCountryRegionCode();
        Customer.SETFILTER("VAT Registration No.", '<>%1', '');
        Customer.SETFILTER("Country/Region Code", CountryRegionCode);
        Customer.FINDFIRST();
        LibrarySales.CreateCustomer(NewCustomer);
        NewCustomer.VALIDATE(Contact, FORMAT(LibraryRandom.RandInt(10000)));
        NewCustomer.VALIDATE("Country/Region Code", CountryRegionCode);
        NewCustomer.VALIDATE(GLN, GLNNoTok);
        NewCustomer.VALIDATE("VAT Registration No.", Customer."VAT Registration No.");
        NewCustomer.MODIFY(true);
    end;

    local procedure CreateSalesHeader(var SalesHeader: Record "Sales Header"; DocumentType: Option; SellToCustomerNo: Code[20]);
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, SellToCustomerNo);
        SalesHeader.VALIDATE("External Document No.", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to Address", SalesHeader."No.");
        SalesHeader.VALIDATE("Bill-to City", FindCity());
        SalesHeader.MODIFY(true);
    end;

    local procedure CreateServiceHeader(var ServiceHeader: Record "Service Header"; DocumentType: Option; CustomerNo: Code[20]);
    begin
        LibraryService.CreateServiceHeader(ServiceHeader, DocumentType, CustomerNo);
        ServiceHeader.VALIDATE("Bill-to Address", ServiceHeader."No.");
        ServiceHeader.VALIDATE("Bill-to City", FindCity());
        ServiceHeader.MODIFY(true);
    end;

    local procedure UpdateOIOUBLCountryRegion();
    var
        CountryRegion: Record "Country/Region";
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.GET();
        CountryRegion.GET(CompanyInfo."Country/Region Code");
        CountryRegion.VALIDATE("OIOUBL-Country/Region Code", CompanyInfo."Country/Region Code");
        CountryRegion.Modify();
    end;

    local procedure GetCountryRegionCode(): Code[10];
    var
        CompanyInfo: Record "Company Information";
    begin
        CompanyInfo.GET();
        exit(CompanyInfo."Country/Region Code");
    end;

    local procedure UpdateServiceLine(var ServiceLine: Record "Service Line"; Qty: Decimal; UnitPrice: Decimal; LineDiscount: Decimal);
    begin
        ServiceLine.VALIDATE(Quantity, Qty);
        ServiceLine.VALIDATE("Unit Price", UnitPrice);
        ServiceLine.VALIDATE("Line Discount %", LineDiscount);
        ServiceLine.MODIFY(true);
    end;

    local procedure FindCity(): Text[30];
    var
        PostCode: Record "Post Code";
        CountryCode: Code[10];
    begin
        CountryCode := GetCountryRegionCode();
        PostCode.SETFILTER("Country/Region Code", CountryCode);
        PostCode.FINDFIRST();
        exit(PostCode.City);
    end;

    [MessageHandler]
    procedure MessageHandler(MSG: Text[1024]);
    begin
        // Handle VAT Registration No. message.
    end;

    local procedure Initialize();
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        UpdateOIOUBLCountryRegion();

        DocumentSendingProfile.DELETEALL();

        DocumentSendingProfile.INIT();
        DocumentSendingProfile.Default := true;
        DocumentSendingProfile."Electronic Format" := 'OIOUBL';
        DocumentSendingProfile.INSERT();
    end;
}

