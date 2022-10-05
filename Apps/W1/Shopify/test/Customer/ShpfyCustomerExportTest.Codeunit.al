codeunit 139568 "Shpfy Customer Export Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";

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
        ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::FirstAndLastName);

        // [THEN] FirstName = 'Firstname' and LastName = 'Last name'
        LibraryAssert.AreEqual('Firstname', FirstName, 'NameSource::FirstAndLastName');
        LibraryAssert.AreEqual('Last name', LastName, 'NameSource::FirstAndLastName');

        // [GIVEN] Name := 'Last name Firstname'
        Name := 'Last name Firstname';
        // [GIVEN] NameSource::LastAndFirstName

        // [WHEN] Invoke ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName)
        ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName);

        // [THEN] FirstName = 'Firstname' and LastName = 'Last name'
        LibraryAssert.AreEqual('Firstname', FirstName, 'NameSource::LastAndFirstName');
        LibraryAssert.AreEqual('Last name', LastName, 'NameSource::LastAndFirstName');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        Result: boolean;
    begin
        // [SCENARION] Convert an existing customer record to a "Shpfy Customer" and "Shpfy Customer Address" record.

        if not Customer.FindFirst() then
            exit;
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        ShpfyShop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        ShpfyShop."Contact Source" := Enum::"Shpfy Name Source"::None;
        ShpfyShop."County Source" := Enum::"Shpfy County Source"::Name;
        ShpfyCustomer.Init();
        ShpfyCustomerAddress.Init();

        // [GIVEN] Shop
        ShpfyCustomerExport.SetShop(ShpfyShop);

        // [GIVEN] Customer record
        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddres)
        Result := ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddress);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual('', ShpfyCustomer."First Name", 'Firstname');
        LibraryAssert.AreEqual('', ShpfyCustomer."Last Name", 'Last name');
        LibraryAssert.IsTrue(Customer."E-Mail".StartsWith(ShpfyCustomer.Email), 'E-Mail');
        LibraryAssert.AreEqual(Customer."Phone No.", ShpfyCustomer."Phone No.", 'Phone No.');
        LibraryAssert.AreEqual(Customer.Name, ShpfyCustomerAddress.Company, 'Company');
        LibraryAssert.AreEqual(Customer.Address, ShpfyCustomerAddress."Address 1", 'Address 1');
        LibraryAssert.AreEqual(Customer."Address 2", ShpfyCustomerAddress."Address 2", 'Address 2');
        LibraryAssert.AreEqual(Customer."Post Code", ShpfyCustomerAddress.Zip, 'Post Code');
    end;
}
