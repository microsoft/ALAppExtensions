codeunit 139905 "Serv. Decl. Suggest Lines"
{
    Subtype = Test;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [Suggest Lines]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryServiceDeclaration: Codeunit "Library - Service Declaration";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        LibraryLowerPermissions: Codeunit "Library - Lower Permissions";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;

    [Test]
    procedure ServDeclWithMixOfSalesAndPurchaseLines()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        SalesInvNo: Code[20];
        PurchInvNo: Code[20];
    begin
        // [FEATURE] [Sales] [Purchase]
        // [SCENARIO 437878] Stan can create a service declaration with posted sales and purcahse lines

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        LibraryLowerPermissions.AddPurchDocsPost();

        LibraryServiceDeclaration.CreateSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        LibraryServiceDeclaration.CreatePurchDocWithServTransTypeCode(PurchHeader, PurchLine);

        SalesInvNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        PurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true);

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", SalesHeader."Posting Date");

        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        Assert.RecordCount(ServDeclLine, 2);
        ServDeclLine.FindSet();
        ServDeclLine.TestField("Document Type", ServDeclLine."Document Type"::"Purchase Invoice");
        ServDeclLine.TestField("Document No.", PurchInvNo);
        ServDeclLine.TestField("Country/Region Code", PurchHeader."VAT Country/Region Code");
        ServDeclLine.TestField("Service Transaction Code", PurchLine."Service Transaction Type Code");
        ServDeclLine.TestField("Sales Amount", 0);
        ServDeclLine.TestField("Sales Amount (LCY)", 0);
        ServDeclLine.TestField("Purchase Amount", PurchLine.Amount);
        ServDeclLine.TestField("Purchase Amount (LCY)", PurchLine.Amount);
        ServDeclLine.Next();
        ServDeclLine.TestField("Document Type", ServDeclLine."Document Type"::"Sales Invoice");
        ServDeclLine.TestField("Document No.", SalesInvNo);
        ServDeclLine.TestField("Country/Region Code", SalesHeader."Bill-to Country/Region Code");
        ServDeclLine.TestField("Service Transaction Code", SalesLine."Service Transaction Type Code");
        ServDeclLine.TestField("Sales Amount", SalesLine.Amount);
        ServDeclLine.TestField("Sales Amount (LCY)", SalesLine.Amount);
        ServDeclLine.TestField("Purchase Amount", 0);
        ServDeclLine.TestField("Purchase Amount (LCY)", 0);
    end;

    [Test]
    procedure SalesFCYInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
    begin
        // [FEATURE] [FCY] [Sales]
        // [SCENARIO 437878] Stan can create a sales invoice in foreign currency and see the foreign currency amount in a service declaration

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();

        LibraryServiceDeclaration.CreateServDeclSalesHeader(SalesHeader);
        SalesHeader.Validate("Currency Code",
            LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), 1 / LibraryRandom.RandIntInRange(5, 10), 1 / LibraryRandom.RandIntInRange(5, 10)));
        SalesHeader.Modify(true);
        LibraryServiceDeclaration.CreateServDeclSalesLine(SalesLine, SalesHeader);
        SalesLine.Validate("Service Transaction Type Code", LibraryServiceDeclaration.CreateServTransTypeCode());
        SalesLine.Modify(true);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", SalesHeader."Posting Date");

        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        Assert.RecordCount(ServDeclLine, 1);
        ServDeclLine.FindFirst();
        ServDeclLine.TestField("Sales Amount", SalesLine.Amount);
    end;

    [Test]
    procedure PurchFCYInvoice()
    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
    begin
        // [FEATURE] [FCY] [Purchase]
        // [SCENARIO 437878] Stan can create a purchase invoice in foreign currency and see the foreign currency amount in a service declaration

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddPurchDocsPost();

        LibraryServiceDeclaration.CreateServDeclPurchHeader(PurchaseHeader);
        PurchaseHeader.Validate("Currency Code",
            LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), 1 / LibraryRandom.RandIntInRange(5, 10), 1 / LibraryRandom.RandIntInRange(5, 10)));
        PurchaseHeader.Modify(true);
        LibraryServiceDeclaration.CreateServDeclPurchLine(PurchaseLine, PurchaseHeader);
        PurchaseLine.Validate("Service Transaction Type Code", LibraryServiceDeclaration.CreateServTransTypeCode());
        PurchaseLine.Modify(true);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", PurchaseHeader."Posting Date");

        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        Assert.RecordCount(ServDeclLine, 1);
        ServDeclLine.FindFirst();
        ServDeclLine.TestField("Purchase Amount", PurchaseLine.Amount);
    end;

    [Test]
    procedure SuggestLinesWithOriginalVATRegNoOfCustAndVend()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        // [SCENARIO 437878] Original VAT registration number of customer/vendor is taken for the suggested lines in service declaration

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        LibraryLowerPermissions.AddPurchDocsPost();

        ServDeclSetup.Get();
        // [GIVEN] Set "Enable VAT Registration No." in the Service Declaration Setup
        ServDeclSetup.Validate("Enable VAT Registration No.", true);
        // [GIVEN] Set "VAT Reg. No." for "Cust. VAT Reg. No. Type" and "Vend. VAT Reg. No. Type" in Service Declaration Setup
        ServDeclSetup.Validate("Cust. VAT Reg. No. Type", ServDeclSetup."Cust. VAT Reg. No. Type"::"VAT Reg. No.");
        ServDeclSetup.Validate("Vend. VAT Reg. No. Type", ServDeclSetup."Vend. VAT Reg. No. Type"::"VAT Reg. No.");
        ServDeclSetup.Modify(true);

        // [GIVEN] Posted sales invoice with customer from country "ES" that has "VAT Reg. No." = "X"
        LibraryServiceDeclaration.CreateSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        // [GIVEN] Posted purchase invoice with customer from country "GB" that has "VAT Reg. No." = "Y"
        LibraryServiceDeclaration.CreatePurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true);

        // [GIVEN] Service declaration with same posting dates as posted sales and purchase invoices
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", SalesHeader."Posting Date");

        // [WHEN] Suggest lines for the service declaration
        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        // [THEN] "VAT Reg. No." in purchase service declaration line is "Y"
        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        ServDeclLine.FindSet();
        Vendor.Get(PurchHeader."Buy-from Vendor No.");
        ServDeclLine.TestField("VAT Reg. No.", Vendor."VAT Registration No.");
        // [THEN] "VAT Reg. No." in sales service declaration line is "X"
        ServDeclLine.Next();
        Customer.Get(SalesHeader."Sell-to Customer No.");
        ServDeclLine.TestField("VAT Reg. No.", Customer."VAT Registration No.");
    end;

    [Test]
    procedure SuggestLinesWithVATRegWithCountryNoOfCustAndVend()
    var
        ServDeclSetup: Record "Service Declaration Setup";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
        Customer: Record Customer;
        Vendor: Record Vendor;
    begin
        // [SCENARIO 437878] Combination of VAT registration number and country code of customer/vendor is taken for the suggested lines in service declaration

        Initialize();
        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        LibraryLowerPermissions.AddPurchDocsPost();

        ServDeclSetup.Get();
        // [GIVEN] Set "Enable VAT Registration No." in the Service Declaration Setup
        ServDeclSetup.Validate("Enable VAT Registration No.", true);
        // [GIVEN] Set "VAT Reg. No." for "Cust. VAT Reg. No. Type" and "Vend. VAT Reg. No. Type" in Service Declaration Setup
        ServDeclSetup.Validate("Cust. VAT Reg. No. Type", ServDeclSetup."Cust. VAT Reg. No. Type"::"Country Code + VAT Reg. No.");
        ServDeclSetup.Validate("Vend. VAT Reg. No. Type", ServDeclSetup."Vend. VAT Reg. No. Type"::"Country Code + VAT Reg. No.");
        ServDeclSetup.Modify(true);

        // [GIVEN] Posted sales invoice with customer from country "ES" that has "VAT Reg. No." = "X"
        LibraryServiceDeclaration.CreateSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        // [GIVEN] Posted purchase invoice with customer from country "GB" that has "VAT Reg. No." = "Y"
        LibraryServiceDeclaration.CreatePurchDocWithServTransTypeCode(PurchHeader, PurchLine);
        LibrarySales.PostSalesDocument(SalesHeader, true, true);
        LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true);

        // [GIVEN] Service declaration with same posting dates as posted sales and purchase invoices
        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", SalesHeader."Posting Date");

        // [WHEN] Suggest lines for the service declaration
        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        // [THEN] "VAT Reg. No." in purchase service declaration line is "GBY"
        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        ServDeclLine.FindSet();
        Vendor.Get(PurchHeader."Buy-from Vendor No.");
        ServDeclLine.TestField("VAT Reg. No.", Vendor."Country/Region Code" + Vendor."VAT Registration No.");
        // [THEN] "VAT Reg. No." in sales service declaration line is "ESX"
        ServDeclLine.Next();
        Customer.Get(SalesHeader."Sell-to Customer No.");
        ServDeclLine.TestField("VAT Reg. No.", Customer."Country/Region Code" + Customer."VAT Registration No.");
    end;

    [Test]
    procedure ServDeclWithMixOfSalesAndPurchaseLinesWithResource()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
        ServDeclHeader: Record "Service Declaration Header";
        ServDeclLine: Record "Service Declaration Line";
        VATReportsConfiguration: Record "VAT Reports Configuration";
        SalesInvNo: Code[20];
        PurchInvNo: Code[20];
    begin
        // [FEATURE] [Sales] [Purchase] [Resource]
        // [SCENARIO 456284] Stan can create a service declaration with posted sales and purcahse lines with resource

        Initialize();
        LibraryServiceDeclaration.CreateResSalesDocWithServTransTypeCode(SalesHeader, SalesLine);
        LibraryServiceDeclaration.CreateResPurchDocWithServTransTypeCode(PurchHeader, PurchLine);

        SalesInvNo := LibrarySales.PostSalesDocument(SalesHeader, true, true);
        PurchInvNo := LibraryPurchase.PostPurchaseDocument(PurchHeader, true, true);

        LibraryLowerPermissions.SetO365Setup();
        LibraryLowerPermissions.AddSalesDocsPost();
        LibraryLowerPermissions.AddPurchDocsPost();

        VATReportsConfiguration.SetRange("VAT Report Type", VATReportsConfiguration."VAT Report Type"::"Service Declaration");
        VATReportsConfiguration.FindFirst();
        CreateServDeclHeader(ServDeclHeader, VATReportsConfiguration."VAT Report Version", SalesHeader."Posting Date");

        codeunit.Run(VATReportsConfiguration."Suggest Lines Codeunit ID", ServDeclHeader);

        ServDeclLine.SetRange("Service Declaration No.", ServDeclHeader."No.");
        Assert.RecordCount(ServDeclLine, 2);
        ServDeclLine.FindSet();
        ServDeclLine.TestField("Document Type", 0);
        ServDeclLine.TestField("Document No.", SalesInvNo);
        ServDeclLine.TestField("Country/Region Code", SalesHeader."Bill-to Country/Region Code");
        ServDeclLine.TestField("Service Transaction Code", SalesLine."Service Transaction Type Code");
        ServDeclLine.TestField("Sales Amount", SalesLine.Amount);
        ServDeclLine.TestField("Sales Amount (LCY)", SalesLine.Amount);
        ServDeclLine.TestField("Purchase Amount", 0);
        ServDeclLine.TestField("Purchase Amount (LCY)", 0);
        ServDeclLine.Next();
        ServDeclLine.TestField("Document Type", 0);
        ServDeclLine.TestField("Document No.", PurchInvNo);
        ServDeclLine.TestField("Country/Region Code", PurchHeader."VAT Country/Region Code");
        ServDeclLine.TestField("Service Transaction Code", PurchLine."Service Transaction Type Code");
        ServDeclLine.TestField("Sales Amount", 0);
        ServDeclLine.TestField("Sales Amount (LCY)", 0);
        ServDeclLine.TestField("Purchase Amount", PurchLine.Amount);
        ServDeclLine.TestField("Purchase Amount (LCY)", PurchLine.Amount);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Serv. Decl. Suggest Lines");
        LibrarySetupStorage.Restore();
        LibraryServiceDeclaration.InitServDeclSetup();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Serv. Decl. Suggest Lines");
        LibrarySetupStorage.Save(Database::"Service Declaration Setup");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Serv. Decl. Suggest Lines");
    end;

    local procedure CreateServDeclHeader(var ServDeclHeader: Record "Service Declaration Header"; VATReportVersion: Code[10]; PostingDate: Date)
    begin
        ServDeclHeader.Validate("Config. Code", VATReportVersion);
        ServDeclHeader.Validate("Starting Date", PostingDate);
        ServDeclHeader.Validate("Ending Date", PostingDate);
        ServDeclHeader.Insert(true);
    end;
}