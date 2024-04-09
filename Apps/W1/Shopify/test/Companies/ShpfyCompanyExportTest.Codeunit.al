codeunit 139636 "Shpfy Company Export Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        CompanyExport: Codeunit "Shpfy Company Export";

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Result: Boolean;
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
    end;
}
