codeunit 139903 "Service Declaration UT"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Service Declaration] [UI]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryServiceDeclaration: Codeunit "Library - Service Declaration";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryResource: Codeunit "Library - Resource";
        LibraryUtility: Codeunit "Library - Utility";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        DoYouWantToChangeQst: Label 'Do you want to change';
        CannotEnterNumbersManuallyErr: Label 'You may not enter numbers manually';

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SalesHeaderNotApplicableForServDeclWhenSellCustomerCountrySameAsCompany()
    var
        CompanyInformation: Record "Company Information";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SellToBillTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales header when the country code of Sell-To Customer matches the country in company information

        Initialize();
        SetCustomerSellToBillToOption(SellToBillTo::"Sell-to/Buy-from No.");
        CompanyInformation.Get();
        LibrarySales.CreateCustomer(SellToCustomer);
        SellToCustomer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        SellToCustomer.Modify(true);

        LibrarySales.CreateCustomerWithVATRegNo(BillToCustomer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomer."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.TestField("Applicable For Serv. Decl.", false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SalesHeaderApplicableForServDeclWhenSellCustomerCountryCodeDiff()
    var
        CompanyInformation: Record "Company Information";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SellToBillTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in sales header when the country code of Sell-To Customer does not match the country in company information

        Initialize();
        SetCustomerSellToBillToOption(SellToBillTo::"Sell-to/Buy-from No.");
        LibrarySales.CreateCustomerWithVATRegNo(SellToCustomer);

        LibrarySales.CreateCustomer(BillToCustomer);
        CompanyInformation.Get();
        BillToCustomer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        BillToCustomer.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomer."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.TestField("Applicable For Serv. Decl.");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SalesHeaderNotApplicableForServDeclWhenBillCustomerCountrySameAsCompany()
    var
        CompanyInformation: Record "Company Information";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SellToBillTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales header when the country code of Bill-To Customer matches the country in company information

        Initialize();
        SetCustomerSellToBillToOption(SellToBillTo::"Bill-to/Pay-to No.");
        LibrarySales.CreateCustomerWithVATRegNo(SellToCustomer);

        CompanyInformation.Get();
        LibrarySales.CreateCustomer(BillToCustomer);
        BillToCustomer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        BillToCustomer.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomer."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.TestField("Applicable For Serv. Decl.", false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure SalesHeaderApplicableForServDeclWhenBillCustomerCountryCodeDiff()
    var
        CompanyInformation: Record "Company Information";
        SellToCustomer: Record Customer;
        BillToCustomer: Record Customer;
        SalesHeader: Record "Sales Header";
        SellToBillTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in sales header when the country code of Bill-To Customer does not match the country in company information

        Initialize();
        SetCustomerSellToBillToOption(SellToBillTo::"Bill-to/Pay-to No.");
        LibrarySales.CreateCustomer(SellToCustomer);
        CompanyInformation.Get();
        SellToCustomer.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        SellToCustomer.Modify(true);

        LibrarySales.CreateCustomerWithVATRegNo(BillToCustomer);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, SellToCustomer."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        SalesHeader.Validate("Bill-to Customer No.", BillToCustomer."No.");
        SalesHeader.TestField("Applicable For Serv. Decl.");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure SalesLineApplicableForServDeclWhenHeaderItemApplicable()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in sales line when both "Applicable For Serv. Decl." is enabled in sales header and item is applicable for service declaration
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenItemApplicableAndHeaderNot()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is disabled in sales header and item is applicable for service declaration
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := false;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenHeaderApplicableItemNotService()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is enabled in sales header and item is not the service
        Initialize();
        LibraryInventory.CreateItem(Item);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenHeaderApplicableItemServiceIsExcluded()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is enabled in sales header and item service is excluded
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        Item.Validate("Exclude From Service Decl.", true);
        Item.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Item);
        SalesLine.Validate("No.", Item."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineApplicableForServDeclWhenHeaderResourceApplicable()
    var
        Resource: Record Resource;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in sales line when both "Applicable For Serv. Decl." is enabled in sales header and resource is applicable for service declaration
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Resource);
        SalesLine.Validate("No.", Resource."No.");
        SalesLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenResourceApplicableHeaderNot()
    var
        Resource: Record Resource;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is disabled in sales header and resource is applicable for service declaration
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := false;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Resource);
        SalesLine.Validate("No.", Resource."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenHeaderApplicableResourceServiceIsExcluded()
    var
        Resource: Record Resource;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is enabled in sales header and resource is excluded
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        Resource.Validate("Exclude From Service Decl.", true);
        Resource.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::Resource);
        SalesLine.Validate("No.", Resource."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineApplicableForServDeclWhenReportItemChargesHeaderItemItemApplicable()
    var
        ItemCharge: Record "Item Charge";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in sales line when both "Applicable For Serv. Decl." is enabled in sales header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", ItemCharge."No.");
        SalesLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenReportItemChargesEnabledItemChargeApplicableHeaderNot()
    var
        ItemCharge: Record "Item Charge";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is disabled in sales header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := false;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", ItemCharge."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineNotApplicableForServDeclWhenReportItemChargesDisabledItemChargeAndHeaderApplicable()
    var
        ItemCharge: Record "Item Charge";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is enabled in sales header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is disabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(false);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", ItemCharge."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SalesLineNotApplicableWhenReportItemChargesEnabledHeaderApplicableItemChargeExcluded()
    var
        ItemCharge: Record "Item Charge";
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in sales line when "Applicable For Serv. Decl." is enabled in sales header, item charge is excluded
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("Exclude From Service Decl.", true);
        ItemCharge.Modify(true);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, LibrarySales.CreateCustomerNo());
        SalesHeader."Applicable For Serv. Decl." := true;
        SalesHeader.Modify(true);
        SalesLine.Validate("Document Type", SalesHeader."Document Type");
        SalesLine.Validate("Document No.", SalesHeader."No.");
        SalesLine.Validate(Type, SalesLine.Type::"Charge (Item)");
        SalesLine.Validate("No.", ItemCharge."No.");
        SalesLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchaseLineApplicableForServDeclWhenHeaderItemApplicable()
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Sales]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in purchase line when both "Applicable For Serv. Decl." is enabled in purchase header and item is applicable for service declaration
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", Item."No.");
        PurchLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PurchHeaderNotApplicableForServDeclWhenBuyFromVendorCountrySameAsCompany()
    var
        CompanyInformation: Record "Company Information";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        BuyFromPayTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase header when the country code of Buy-From Vendor matches the country in company information

        Initialize();
        SetVendorBuyFromPayToOption(BuyFromPayTo::"Sell-to/Buy-from No.");
        CompanyInformation.Get();
        LibraryPurchase.CreateVendor(BuyFromVendor);
        BuyFromVendor.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        BuyFromVendor.Modify(true);

        LibraryPurchase.CreateVendorWithVATRegNo(PayToVendor);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, BuyFromVendor."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        PurchHeader.Validate("Pay-to Vendor No.", PayToVendor."No.");
        PurchHeader.TestField("Applicable For Serv. Decl.", false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PurchHeaderApplicableForServDeclWhenBuyFromVendorCountryCodeDiff()
    var
        CompanyInformation: Record "Company Information";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        BuyFromPayTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in purchase header when the country code of Buy-From does not match the country in company information

        Initialize();
        SetVendorBuyFromPayToOption(BuyFromPayTo::"Sell-to/Buy-from No.");
        LibraryPurchase.CreateVendorWithVATRegNo(BuyFromVendor);

        LibraryPurchase.CreateVendor(PayToVendor);
        CompanyInformation.Get();
        PayToVendor.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        PayToVendor.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, BuyFromVendor."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        PurchHeader.Validate("Pay-to Vendor No.", PayToVendor."No.");
        PurchHeader.TestField("Applicable For Serv. Decl.");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PurchHeaderNotApplicableForServDeclWhenPayToVendorCountrySameAsCompany()
    var
        CompanyInformation: Record "Company Information";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        BuyFromPayTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase header when the country code of Pay-To Vendor matches the country in company information

        Initialize();
        SetVendorBuyFromPayToOption(BuyFromPayTo::"Bill-to/Pay-to No.");
        LibraryPurchase.CreateVendorWithVATRegNo(BuyFromVendor);

        CompanyInformation.Get();
        LibraryPurchase.CreateVendor(PayToVendor);
        PayToVendor.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        PayToVendor.Modify(true);

        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, BuyFromVendor."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        PurchHeader.Validate("Pay-to Vendor No.", PayToVendor."No.");
        PurchHeader.TestField("Applicable For Serv. Decl.", false);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandler')]
    procedure PurchHeaderApplicableForServDeclWhenPayToVendorCountryCodeDiff()
    var
        CompanyInformation: Record "Company Information";
        BuyFromVendor: Record Vendor;
        PayToVendor: Record Vendor;
        PurchHeader: Record "Purchase Header";
        BuyFromPayTo: Enum "G/L Setup VAT Calculation";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in purchase header when the country code of Pay-To Vendor does not match the country in company information

        Initialize();
        SetVendorBuyFromPayToOption(BuyFromPayTo::"Bill-to/Pay-to No.");
        LibraryPurchase.CreateVendor(BuyFromVendor);
        CompanyInformation.Get();
        BuyFromVendor.Validate("Country/Region Code", CompanyInformation."Country/Region Code");
        BuyFromVendor.Modify(true);

        LibraryPurchase.CreateVendorWithVATRegNo(PayToVendor);

        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, BuyFromVendor."No.");
        LibraryVariableStorage.Enqueue(DoYouWantToChangeQst);
        PurchHeader.Validate("Pay-to Vendor No.", PayToVendor."No.");
        PurchHeader.TestField("Applicable For Serv. Decl.");
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenItemApplicableAndHeaderNot()
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is disabled in purchase header and item is applicable for service declaration
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := false;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", Item."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenHeaderApplicableItemNotService()
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is enabled in purchase header and item is not the service
        Initialize();
        LibraryInventory.CreateItem(Item);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", Item."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenHeaderApplicableItemServiceIsExcluded()
    var
        Item: Record Item;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is enabled in purchase header and item service is excluded
        Initialize();
        LibraryInventory.CreateServiceTypeItem(Item);
        Item.Validate("Exclude From Service Decl.", true);
        Item.Modify(true);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Item);
        PurchLine.Validate("No.", Item."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineApplicableForServDeclWhenHeaderResourceApplicable()
    var
        Resource: Record Resource;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in purchase line when both "Applicable For Serv. Decl." is enabled in purchase header and resource is applicable for service declaration
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Resource);
        PurchLine.Validate("No.", Resource."No.");
        PurchLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenResourceApplicableHeaderNot()
    var
        Resource: Record Resource;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is disabled in purchase header and resource is applicable for service declaration
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := false;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Resource);
        PurchLine.Validate("No.", Resource."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenHeaderApplicableResourceServiceIsExcluded()
    var
        Resource: Record Resource;
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is enabled in purchase header and resource is excluded
        Initialize();
        LibraryResource.CreateResourceNew(Resource);
        Resource.Validate("Exclude From Service Decl.", true);
        Resource.Modify(true);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::Resource);
        PurchLine.Validate("No.", Resource."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineApplicableForServDeclWhenReportItemChargesHeaderItemItemApplicable()
    var
        ItemCharge: Record "Item Charge";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is enabled in purchase line when both "Applicable For Serv. Decl." is enabled in purchase header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::"Charge (Item)");
        PurchLine.Validate("No.", ItemCharge."No.");
        PurchLine.TestField("Applicable For Serv. Decl.");
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenReportItemChargesEnabledItemChargeApplicableHeaderNot()
    var
        ItemCharge: Record "Item Charge";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is disabled in purchase header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := false;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::"Charge (Item)");
        PurchLine.Validate("No.", ItemCharge."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineNotApplicableForServDeclWhenReportItemChargesDisabledItemChargeAndHeaderApplicable()
    var
        ItemCharge: Record "Item Charge";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is enabled in purchase header and item charge is applicable for service declaration
        // [SCENARIO 437878] and "Report Item Charges" is disabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(false);
        LibraryInventory.CreateItemCharge(ItemCharge);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::"Charge (Item)");
        PurchLine.Validate("No.", ItemCharge."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure PurchLineNotApplicableWhenReportItemChargesEnabledHeaderApplicableItemChargeExcluded()
    var
        ItemCharge: Record "Item Charge";
        PurchHeader: Record "Purchase Header";
        PurchLine: Record "Purchase Line";
    begin
        // [FEATURE] [Purchase]
        // [SCENARIO 437878] "Applicable For Serv. Decl." is disabled in purchase line when "Applicable For Serv. Decl." is enabled in purchase header, item charge is excluded
        // [SCENARIO 437878] and "Report Item Charges" is enabled in Service Declaration Setup
        Initialize();
        LibraryServiceDeclaration.SetReportItemCharges(true);
        LibraryInventory.CreateItemCharge(ItemCharge);
        ItemCharge.Validate("Exclude From Service Decl.", true);
        ItemCharge.Modify(true);
        LibraryPurchase.CreatePurchHeader(PurchHeader, PurchHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchHeader."Applicable For Serv. Decl." := true;
        PurchHeader.Modify(true);
        PurchLine.Validate("Document Type", PurchHeader."Document Type");
        PurchLine.Validate("Document No.", PurchHeader."No.");
        PurchLine.Validate(Type, PurchLine.Type::"Charge (Item)");
        PurchLine.Validate("No.", ItemCharge."No.");
        PurchLine.TestField("Applicable For Serv. Decl.", false);
    end;

    [Test]
    procedure SetServDeclNoManuallyIfAllowedByNoSeries()
    var
        NoSeries: Record "No. Series";
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclHeader: Record "Service Declaration Header";
    begin
        // [SCENARIO 457814] Stan can set service declaration number manually if it is allowed by the "No. Series" setup

        Initialize();
        // [GIVEN] No. Series "X" with the "Manual Nos." option is enabled
        LibraryUtility.CreateNoSeries(NoSeries, true, true, false);
        NoSeries.Validate("Manual Nos.", true);
        NoSeries.Modify(true);
        LibraryVariableStorage.Enqueue(NoSeries.Code);
        // [GIVEN] "Declaration No. Series" is "X" in "Service Declaration Setup"
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Declaration No. Series", NoSeries.Code);
        ServDeclSetup.Modify(true);
        // [WHEN] Set "Y" to the number of the service declaration header 
        ServDeclHeader.Validate("No.", LibraryUtility.GenerateGUID());
        ServDeclHeader.Insert(true);
        // [THE] The number of the service declaration header is "Y"
        ServDeclHeader.TestField("No.");
    end;

    [Test]
    procedure CannotSetServDeclNoManuallyIfNotAllowedByNoSeries()
    var
        NoSeries: Record "No. Series";
        ServDeclSetup: Record "Service Declaration Setup";
        ServDeclHeader: Record "Service Declaration Header";
    begin
        // [SCENARIO 457814] Stan cannot set service declaration number manually if it is not allowed by the "No. Series" setup
        Initialize();
        // [GIVEN] No. Series "X" with the "Manual Nos." option is disabled
        LibraryUtility.CreateNoSeries(NoSeries, true, false, false);
        LibraryVariableStorage.Enqueue(NoSeries.Code);
        // [GIVEN] "Declaration No. Series" is "X" in "Service Declaration Setup"
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Declaration No. Series", NoSeries.Code);
        ServDeclSetup.Modify(true);
        // [WHEN] Set "Y" to the number of the service declaration header 
        Asserterror ServDeclHeader.Validate("No.", LibraryUtility.GenerateGUID());
        // [THE] The error message "You cannot enter numbers manually" is thrown
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(CannotEnterNumbersManuallyErr);
    end;

    [Test]
    procedure RemoveServTransTypeCodeInNonServiceItem()
    var
        Item: Record Item;
    begin
        // [SCENARIO 455289] Stan can remove the "Service Transaction Type Code" in non-service item

        Initialize();
        // [GIVEN] Item of type "Inventory" with "Service Transaction Type Code" = "X"
        Item.Type := Item.Type::Inventory;
        Item."Service Transaction Type Code" := LibraryServiceDeclaration.CreateServTransTypeCode();
        // [WHEN] Remove value from "Service Transaction Type Code"
        Item.Validate("Service Transaction Type Code", '');
        // [THEN] "Service Transaction Type Code" is blank
        Item.TestField("Service Transaction Type Code", '');

    end;

    [Test]
    procedure SetServTransTypeCodeInServiceItem()
    var
        Item: Record Item;
    begin
        // [SCENARIO 455289] Stan cannot set the "Service Transaction Type Code" in non-service item

        Initialize();
        // [GIVEN] Item of type "Inventory"
        Item.Type := Item.Type::Inventory;
        // [WHEN] Set value to "Service Transaction Type Code"
        asserterror Item.Validate("Service Transaction Type Code", LibraryServiceDeclaration.CreateServTransTypeCode());
        // [THEN] An error message "Type must be equal to Service" is thrown
        Assert.ExpectedErrorCode('TestField');
        Assert.ExpectedError('Type must be equal to ''Service''');
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Service Declaration UT");
        LibrarySetupStorage.Restore();
        LibraryServiceDeclaration.InitServDeclSetup();
        if IsInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Service Declaration UT");
        LibrarySetupStorage.Save(Database::"Service Declaration Setup");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Service Declaration UT");
    end;

    local procedure SetCustomerSellToBillToOption(SellToBillTo: Enum "G/L Setup VAT Calculation")
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Sell-To/Bill-To Customer No.", SellToBillTo);
        ServDeclSetup.Modify(true);
    end;

    local procedure SetVendorBuyFromPayToOption(BuyFromPayTo: Enum "G/L Setup VAT Calculation")
    var
        ServDeclSetup: Record "Service Declaration Setup";
    begin
        ServDeclSetup.Get();
        ServDeclSetup.Validate("Buy-From/Pay-To Vendor No.", BuyFromPayTo);
        ServDeclSetup.Modify(true);
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandler(Message: Text[1024]; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
        Reply := true;
    end;
}