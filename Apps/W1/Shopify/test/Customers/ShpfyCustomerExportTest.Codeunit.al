codeunit 139568 "Shpfy Customer Export Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        CustomerExport: Codeunit "Shpfy Customer Export";

    [Test]
    procedure UnitTestSpiltNameIntoFirstAndLastName()
    var
        Name: Text;
        FirstName: Text;
        LastName: Text;
        NameSource: Enum "Shpfy Name Source";
    begin
        // [SCENARIO] Splitting a full name into first name and last name.
        // [GIVEN] Name := 'Firstname Last name'
        Name := 'Firstname Last name';
        // [GIVEN] NameSource::FirstAndLastName

        // [WHEN] Invoke ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::FirstAndLastName)
        CustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::FirstAndLastName);

        // [THEN] FirstName = 'Firstname' and LastName = 'Last name'
        LibraryAssert.AreEqual('Firstname', FirstName, 'NameSource::FirstAndLastName');
        LibraryAssert.AreEqual('Last name', LastName, 'NameSource::FirstAndLastName');

        // [GIVEN] Name := 'Last name Firstname'
        Name := 'Last name Firstname';
        // [GIVEN] NameSource::LastAndFirstName

        // [WHEN] Invoke ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName)
        CustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName);

        // [THEN] FirstName = 'Firstname' and LastName = 'Last name'
        LibraryAssert.AreEqual('Firstname', FirstName, 'NameSource::LastAndFirstName');
        LibraryAssert.AreEqual('Last name', LastName, 'NameSource::LastAndFirstName');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Result: boolean;
    begin
        // [SCENARION] Convert an existing customer record to a "Shpfy Customer" and "Shpfy Customer Address" record.

        Customer.FindFirst();
        Shop := InitializeTest.CreateShop();
        Shop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        Shop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        Shop."Contact Source" := Enum::"Shpfy Name Source"::None;
        Shop."County Source" := Enum::"Shpfy County Source"::Name;
        ShopifyCustomer.Init();
        CustomerAddress.Init();

        // [GIVEN] Shop
        CustomerExport.SetShop(Shop);

        // [GIVEN] Customer record
        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddres)
        Result := CustomerExport.FillInShopifyCustomerData(Customer, ShopifyCustomer, CustomerAddress);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual('', ShopifyCustomer."First Name", 'Firstname');
        LibraryAssert.AreEqual('', ShopifyCustomer."Last Name", 'Last name');
        LibraryAssert.IsTrue(Customer."E-Mail".StartsWith(ShopifyCustomer.Email), 'E-Mail');
        LibraryAssert.AreEqual(Customer."Phone No.", ShopifyCustomer."Phone No.", 'Phone No.');
        LibraryAssert.AreEqual(Customer.Name, CustomerAddress.Company, 'Company');
        LibraryAssert.AreEqual(Customer.Address, CustomerAddress."Address 1", 'Address 1');
        LibraryAssert.AreEqual(Customer."Address 2", CustomerAddress."Address 2", 'Address 2');
        LibraryAssert.AreEqual(Customer."Post Code", CustomerAddress.Zip, 'Post Code');
    end;
}
