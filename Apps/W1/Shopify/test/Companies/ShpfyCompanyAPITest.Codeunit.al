codeunit 139637 "Shpfy Company API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";

    [Test]
    procedure UnitTestCreateCompanyGraphQuery()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CompanyAPI: Codeunit "Shpfy Company API";
        GraphQL: Text;
    begin
        // Creating Test data.
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation(ShopifyCompany);

        // [SCENARIO] Creating the GrapghQL query to create a new company in Shopify
        // [GIVEN] ShpfyCompany
        // [GIVEN] ShpfyCompanyLocation

        // [WHEN] Invoke CompanyAPI.CreateCompanyGraphQLQuery
        GraphQL := CompanyAPI.CreateCompanyGraphQLQuery(ShopifyCompany, CompanyLocation);

        // [THEN] CompanyInitialize.CreateCompanyGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(CompanyInitialize.CreateCompanyGraphQLResult(), GraphQL, 'CreateCompanyGraphQuery');
    end;

    [Test]
    procedure UnitTestCreateGraphQueryUpdateCompany()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyAPI: Codeunit "Shpfy Company API";
        GraphQL: Text;
    begin
        // Creating Test data.
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);

        // [SCENARIO] Changing the date of an Shopify Company and the default address.
        // [GIVEN] ShpfyCompany with change fields
        ShopifyCompany := CompanyInitialize.ModifyFields(ShopifyCompany);

        // [WHEN] Invoke ShpfyCompanyAPI.CreateGraphQueryUpdateCompany(ShpfyCompany)
        GraphQL := CompanyAPI.CreateGraphQueryUpdateCompany(ShopifyCompany);

        // [THEN] CompanyInitialize.CreateGraphQueryUpdateCompanyResult() = GraphQL.
        LibraryAssert.AreEqual(CompanyInitialize.CreateGraphQueryUpdateCompanyResult(ShopifyCompany.Id), GraphQL, 'CreateGraphQueryUpdateCompany');
    end;

    [Test]
    procedure UnitTestCreateGraphQueryUpdateCompanyLocation()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CompanyAPI: Codeunit "Shpfy Company API";
        GraphQL: Text;
    begin
        // Creating Test data.
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation(ShopifyCompany);

        // [SCENARIO] Changing the date of an Shopify Customer and the default address.
        // [GIVEN] ShpfyCompanyLocation with change fields
        CompanyLocation := CompanyInitialize.ModifyFields(CompanyLocation);

        // [WHEN] Invoke ShpfyCompanyAPI.CreateGraphQueryUpdateLocation(ShpfyCompanyLocation)
        GraphQL := CompanyAPI.CreateGraphQueryUpdateLocation(CompanyLocation);

        // [THEN] CompanyInitialize.CreateCustomerGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(CompanyInitialize.CreateGraphQueryUpdateCompanyLocationResult(CompanyLocation.Id), GraphQL, 'CreateGraphQueryUpdateCompanyLocation');
    end;

    [Test]
    procedure UnitTestUpdateShopifyCustomerFields()
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CompanyAPI: Codeunit "Shpfy Company API";
        JResponse: JsonObject;
        Id: BigInteger;
        FirstName: Text;
        LastName: Text;
        Email: Text;
        PhoneNo: Text;
    begin
        // Creating Test data.
        Id := LibraryRandom.RandIntInRange(100000, 999999);
        FirstName := LibraryRandom.RandText(MaxStrLen(ShopifyCustomer."First Name"));
        LastName := LibraryRandom.RandText(MaxStrLen(ShopifyCustomer."Last Name"));
        Email := LibraryRandom.RandText(MaxStrLen(ShopifyCustomer."Email"));
        PhoneNo := Format(LibraryRandom.RandIntInRange(10000000, 99999999));
        JResponse := CompanyInitialize.CompanyMainContactResponse(Id, FirstName, LastName, Email, PhoneNo);

        // [SCENARIO] Extracting the company main contact from the Shopify response.
        // [GIVEN] JResponse with Company main contact

        // [WHEN] Invoke CompanyAPI.UpdateShopifyCustomerFields
        CompanyAPI.UpdateShopifyCustomerFields(ShopifyCustomer, JResponse);

        // [THEN] Shopify customer fields are updated.
        LibraryAssert.AreEqual(ShopifyCustomer.Id, Id, 'Id');
        LibraryAssert.AreEqual(ShopifyCustomer."First Name", FirstName, 'First Name');
        LibraryAssert.AreEqual(ShopifyCustomer."Last Name", LastName, 'Last Name');
        LibraryAssert.AreEqual(ShopifyCustomer."Email", Email, 'Email');
        LibraryAssert.AreEqual(ShopifyCustomer."Phone No.", PhoneNo, 'Phone');
    end;

    [Test]
    procedure UnitTestUpdateShopifyCompanyFields()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyAPI: Codeunit "Shpfy Company API";
        JResponse: JsonObject;
        Name: Text;
        Result: Boolean;
        CompanyContactId: BigInteger;
        CustomerId: BigInteger;
        CompanyLocationId: BigInteger;
    begin
        // Creating Test data.
        ShopifyCompany.Insert();
        Name := LibraryRandom.RandText(MaxStrLen(ShopifyCompany.Name));
        CompanyContactId := LibraryRandom.RandIntInRange(100000, 999999);
        CustomerId := LibraryRandom.RandIntInRange(100000, 999999);
        CompanyLocationId := LibraryRandom.RandIntInRange(100000, 999999);
        JResponse := CompanyInitialize.CompanyResponse(Name, CompanyContactId, CustomerId, CompanyLocationId);

        // [SCENARIO] Extracting the company from the Shopify response.
        // [GIVEN] JResponse with Company

        // [WHEN] Invoke CompanyAPI.UpdateShopifyCompanyFields
        Result := CompanyAPI.UpdateShopifyCompanyFields(ShopifyCompany, JResponse);

        // [THEN] Shopify company fields are updated.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(ShopifyCompany.Name, Name, 'Name');
        LibraryAssert.AreEqual(ShopifyCompany."Main Contact Id", CompanyContactId, 'Company Contact Id');
        LibraryAssert.AreEqual(ShopifyCompany."Main Contact Customer Id", CustomerId, 'Customer Id');
        LibraryAssert.AreEqual(ShopifyCompany."Location Id", CompanyLocationId, 'Company Location Id');
    end;
}
