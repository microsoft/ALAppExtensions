codeunit 139636 "Shpfy Company Export Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        CompanyExport: Codeunit "Shpfy Company Export";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        Result: Boolean;
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Convert an existing company record to a "Shpfy Company" and "Shpfy Company Location" record.

        Customer.FindFirst();
        Shop := InitializeTest.CreateShop();
        Shop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        Shop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        Shop."Contact Source" := Enum::"Shpfy Name Source"::None;
        Shop."County Source" := Enum::"Shpfy County Source"::Name;
        Shop."B2B Enabled" := true;
        ShopifyCompany.Init();
        CompanyLocation.Init();

        // [GIVEN] Shop
        CompanyExport.SetShop(Shop);

        // [GIVEN] Customer record
        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCompany(Customer, ShopifyCompany, CompanyLocation)
        Result := CompanyExport.FillInShopifyCompany(Customer, ShopifyCompany, CompanyLocation);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(Customer.Name, ShopifyCompany.Name, 'Name');
        LibraryAssert.AreEqual(Customer."Phone No.", CompanyLocation."Phone No.", 'Phone No.');
        LibraryAssert.AreEqual(Customer.Address, CompanyLocation.Address, 'Address 1');
        LibraryAssert.AreEqual(Customer."Address 2", CompanyLocation."Address 2", 'Address 2');
        LibraryAssert.AreEqual(Customer."Post Code", CompanyLocation.Zip, 'Post Code');
        LibraryAssert.AreEqual(Customer.City, CompanyLocation.City, 'City');
        LibraryAssert.AreEqual(Customer."Country/Region Code", CompanyLocation."Country/Region Code", 'Country');
        LibraryAssert.AreEqual(ShopifyPaymentTermsId, CompanyLocation."Shpfy Payment Terms Id", 'Payment Terms Id should be 0');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerDataWithLocationPaymentTerm()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Export company with payment terms.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Customer record with payment terms
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."Payment Terms Code" := PaymentTermsCode;
        Customer.Insert(false);
        // [GIVEN] Shopify Company 
        ShopifyCompany.Init();
        ShopifyCompany.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCompany."Customer SystemId" := Customer.SystemId;
        ShopifyCompany.Insert(false);
        // [GIVEN] Company Location
        CompanyLocation.Init();
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation.Insert(false);

        // [WHEN] Invoke FillInShopifyCompany
        CompanyExport.FillInShopifyCompany(Customer, ShopifyCompany, CompanyLocation);

        // [THEN] The payment terms id is set in the company location record.
        LibraryAssert.AreEqual(ShopifyPaymentTermsId, CompanyLocation."Shpfy Payment Terms Id", 'Payment Terms Id');
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
}
