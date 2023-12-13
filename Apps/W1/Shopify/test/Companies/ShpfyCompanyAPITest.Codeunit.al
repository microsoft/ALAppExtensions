codeunit 139637 "Shpfy Company API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateCompanyGraphQuery()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CompanyAPI: Codeunit "Shpfy Company API";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
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
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
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
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
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
}
