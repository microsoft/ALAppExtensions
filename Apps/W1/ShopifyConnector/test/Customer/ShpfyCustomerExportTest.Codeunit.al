codeunit 30512 "Shpfy Customer Export Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";
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
        Assert.AreEqual('Firstname', FirstName, 'NameSource::FirstAndLastName');
        Assert.AreEqual('Last name', LastName, 'NameSource::FirstAndLastName');

        // [GIVEN] Name := 'Last name Firstname'
        Name := 'Last name Firstname';
        // [GIVEN] NameSource::LastAndFirstName

        // [WHEN] Invoke ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName)
        ShpfyCustomerExport.SpiltNameIntoFirstAndLastName(Name, FirstName, LastName, NameSource::LastAndFirstName);

        // [THEN] FirstName = 'Firstname' and LastName = 'Last name'
        Assert.AreEqual('Firstname', FirstName, 'NameSource::LastAndFirstName');
        Assert.AreEqual('Last name', LastName, 'NameSource::LastAndFirstName');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        CountryRegion: Record "Country/Region";
        Shop: Record "Shpfy Shop";
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyCustomerAddres: Record "Shpfy Customer Address";
        Result: boolean;
        InitTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARION] Convert an existing customer record to a "Shpfy Customer" and "Shpfy Customer Address" record.

        if not Customer.FindFirst() then
            exit;
        Shop := InitTest.CreateShop();
        Shop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        Shop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        Shop."Contact Source" := Enum::"Shpfy Name Source"::None;
        Shop."County Source" := Enum::"Shpfy County Source"::Name;
        ShpfyCustomer.Init();
        ShpfyCustomerAddres.Init();

        // [GIVEN] Shop
        ShpfyCustomerExport.SetShop(Shop);

        // [GIVEN] Customer record
        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddres)
        Result := ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddres);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        Assert.IsTrue(Result, 'Result');
        Assert.AreEqual('', ShpfyCustomer."First Name", 'Firstname');
        Assert.AreEqual('', ShpfyCustomer."Last Name", 'Last name');
        Assert.IsTrue(Customer."E-Mail".StartsWith(ShpfyCustomer.Email), 'E-Mail');
        Assert.AreEqual(Customer."Phone No.", ShpfyCustomer."Phone No.", 'Phone No.');
        Assert.AreEqual(Customer.Name, ShpfyCustomerAddres.Company, 'Company');
        Assert.AreEqual(Customer.Address, ShpfyCustomerAddres."Address 1", 'Address 1');
        Assert.AreEqual(Customer."Address 2", ShpfyCustomerAddres."Address 2", 'Address 2');
        Assert.AreEqual(Customer."Post Code", ShpfyCustomerAddres.Zip, 'Post Code');
    end;
}
