codeunit 139647 "Shpfy Company Import Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        InitializeTest: Codeunit "Shpfy Initialize Test";
        IsInitialized: Boolean;

    [Test]
    procedure UnitTestFindMappingBetweenCompanyAndCustomer()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        CompanyMapping: Codeunit "Shpfy Company Mapping";
        Result: Boolean;
    begin
        // [SCENARIO] Importing a company record that is already mapped to a customer record via email.
        Initialize();
        Shop."B2B Enabled" := true;

        // [GIVEN] Shop, Shopify company and Shopify customer
        CompanyMapping.SetShop(Shop);
        ShopifyCompany.Insert();
        Customer.SetFilter("E-Mail", '<>%1', '');
        Customer.FindFirst();
        ShopifyCustomer.Email := Customer."E-Mail";


        // [WHEN] Invoke CompanyMapping.FindMapping(ShopifyCompany, ShopifyCustomer)
        Result := CompanyMapping.FindMapping(ShopifyCompany, ShopifyCustomer);

        // [THEN] The result is true and Shopify company has the correct customer id.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(ShopifyCompany."Customer SystemId", Customer.SystemId, 'Customer SystemId');
    end;

    [Test]
    procedure UnitTestImportCompanyWithLocation()
    var
        ShopifyCompany: Record "Shpfy Company";
    begin
        // [SCENARIO] Importing a company with location with defined payment term.
        Initialize();

        // [GIVEN] Shopify company
        ShopifyCompany.Init();
        ShopifyCompany.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCompany."Shop Id" := Shop."Shop Id";
        ShopifyCompany."Created At" := CurrentDateTime() - 1;
        ShopifyCompany.Insert(false);

        // [WHEN] Invoke CompanyImport
        InvokeCompanyImport(ShopifyCompany);

        // [THEN] Location is created with the correct payment term and all other .
        AssertShopifyCompanyLocationValues(ShopifyCompany);
    end;

    [Test]
    procedure UnitTestUpdateCustomerFromCompanyWithPaymentTerms()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Update a customer from a company with location with defined payment term and existing payment terms in BC.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        ShopifyPaymentTermsId := CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Customer record with payment terms
        CreateCustomer(Customer, PaymentTermsCode);
        // [GIVEN] Shopify Company
        CreateCompany(ShopifyCompany, Customer.SystemId);
        // [GIVEN] Company Location
        CreateCompanyLocation(CompanyLocation, ShopifyCompany, ShopifyPaymentTermsId);

        // [WHEN] Invoke UpdateCustomerFromCompany
        UpdateCustomer.UpdateCustomerFromCompany(ShopifyCompany);

        // [THEN] Customer record is updated with the correct payment terms.
        Customer.GetBySystemId(Customer.SystemId);
        LibraryAssert.AreEqual(Customer."Payment Terms Code", PaymentTermsCode, 'Payment Terms Code');
    end;

    [Test]
    procedure UnitTestCreateCustomerFromCompanyWithPaymentTerms()
    var
        Customer: Record Customer;
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Create a customer from a company with location with defined payment term.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        ShopifyPaymentTermsId := CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Shopify Company
        CreateCompany(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company Location
        CreateCompanyLocation(CompanyLocation, ShopifyCompany, ShopifyPaymentTermsId);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer);

        // [WHEN] Invoke CreateCustomerFromCompany
        CreateCustomer.SetShop(Shop);
        CreateCustomer.SetTemplateCode(Shop."Customer Templ. Code");
        CreateCustomer.CreateCustomerFromCompany(ShopifyCompany, TempShopifyCustomer);

        // [THEN] Customer record is created with the correct payment terms.
        Customer.GetBySystemId(ShopifyCompany."Customer SystemId");
        LibraryAssert.AreEqual(Customer."Payment Terms Code", PaymentTermsCode, 'Payment Terms Code');
    end;

    local procedure Initialize()
    begin
        Any.SetDefaultSeed();
        if IsInitialized then
            exit;
        Shop := InitializeTest.CreateShop();
        IsInitialized := true;

        Commit();
    end;

    local procedure CreatePaymentTerms(): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
    begin
        PaymentTerms.Init();
        PaymentTerms.Code := Any.AlphanumericText(10);
        PaymentTerms.Insert(false);
        exit(PaymentTerms.Code);
    end;

    local procedure CreateShopifyPaymentTerms(var PaymentTermsCode: Code[10]): BigInteger
    var
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShopifyPaymentTerms.Init();
        ShopifyPaymentTerms.Id := Any.IntegerInRange(10000, 99999);
        ShopifyPaymentTerms."Payment Terms Code" := PaymentTermsCode;
        ShopifyPaymentTerms.Insert(false);
        exit(ShopifyPaymentTerms.Id);
    end;

    local procedure CreateCustomer(var Customer: Record Customer; PaymentTermsCode: Code[10])
    begin
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."Payment Terms Code" := PaymentTermsCode;
        Customer.Insert(false);
    end;

    local procedure CreateCompany(var ShopifyCompany: Record "Shpfy Company"; CustomerSystemId: Guid)
    begin
        ShopifyCompany.Init();
        ShopifyCompany.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCompany."Customer SystemId" := CustomerSystemId;
        ShopifyCompany.Insert(false);
    end;

    local procedure CreateCompanyLocation(var CompanyLocation: Record "Shpfy Company Location"; var ShopifyCompany: Record "Shpfy Company"; PaymentTermsId: BigInteger)
    begin
        CompanyLocation.Init();
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Shpfy Payment Terms Id" := PaymentTermsId;
        CompanyLocation.Insert(false);

        ShopifyCompany."Location Id" := CompanyLocation.Id;
        ShopifyCompany.Modify(false);
    end;

    local procedure CreateTempShopifyCustomer(var TempShopifyCustomer: Record "Shpfy Customer" temporary)
    begin
        TempShopifyCustomer.Init();
        TempShopifyCustomer.Id := Any.IntegerInRange(10000, 99999);
        TempShopifyCustomer.Insert(false);
    end;

    local procedure InvokeCompanyImport(var ShopifyCompany: Record "Shpfy Company")
    var
        CompanyImport: Codeunit "Shpfy Company Import";
        CompanyImportSubs: Codeunit "Shpfy Company Import Subs.";
    begin
        BindSubscription(CompanyImportSubs);
        CompanyImport.SetShop(Shop);
        ShopifyCompany.SetRange("Id", ShopifyCompany.Id);
        CompanyImport.Run(ShopifyCompany);
        UnbindSubscription(CompanyImportSubs);
    end;

    local procedure AssertShopifyCompanyLocationValues(var ShopifyCompany: Record "Shpfy Company")
    var
        CompanyLocation: Record "Shpfy Company Location";
    begin
        CompanyLocation.SetRange("Company SystemId", ShopifyCompany.SystemId);
        LibraryAssert.IsTrue(CompanyLocation.FindFirst(), 'Company location does not exist');
        LibraryAssert.IsTrue(CompanyLocation."Shpfy Payment Terms Id" <> 0, 'Payment Terms Id not imported');
        LibraryAssert.AreEqual('XYZ1234', CompanyLocation."Tax Registration Id", 'Tax Registration id not imported');
        LibraryAssert.AreEqual('Address', CompanyLocation.Address, 'Address not imported');
        LibraryAssert.AreEqual('Address 2', CompanyLocation."Address 2", 'Address 2 not imported');
        LibraryAssert.AreEqual('111', CompanyLocation."Phone No.", 'Phone No. not imported');
        LibraryAssert.AreEqual('1111', CompanyLocation.Zip, 'Zip not imported');
        LibraryAssert.AreEqual('City', CompanyLocation.City, 'City not imported');
        LibraryAssert.AreEqual('US', CompanyLocation."Country/Region Code", 'Country/Region Code not imported');
        LibraryAssert.AreEqual('CA', CompanyLocation."Province Code", 'Province Code not imported');
        LibraryAssert.AreEqual('California', CompanyLocation."Province Name", 'Province Name not imported');
    end;
}