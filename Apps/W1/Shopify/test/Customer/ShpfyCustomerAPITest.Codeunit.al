/// <summary>
/// Codeunit Shpfy Customer API Test (ID 139589).
/// </summary>
codeunit 139589 "Shpfy Customer API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateCustomerGraphQuery()
    var
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCustomerApi: Codeunit "Shpfy Customer API";
        ShpfyCustomerInitTest: Codeunit "Shpfy Customer Init Test";
        GraphQL: Text;
    begin
        // Creating Test data.
        ShpfyCustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomerAddress := ShpfyCustomerInitTest.CreateShopifyCustomerAddress(ShpfyCustomer);

        // [SCENARIO] Creating the GrapghQL qeury to create a new customer in Shopify
        // [GIVEN] ShpfyCustomer
        // [GIVEN] ShpfyCustomerAddress

        // [WHEN] Invoke CustomerApi.CreateCustomerGraphQLQuery
        GraphQL := ShpfyCustomerApi.CreateCustomerGraphQLQuery(ShpfyCustomer, ShpfyCustomerAddress);

        // [THEN] CustomerInitTest.CreateCustomerGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(ShpfyCustomerInitTest.CreateCustomerGraphQLResult(), GraphQL, 'CreateCustomerGraphQuery');
    end;

    [Test]
    procedure UnitTestCreateGraphQueryUpdateCustomer()
    var
        ShpfyCustomer: Record "Shpfy Customer";
        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCustomerApi: Codeunit "Shpfy Customer API";
        ShpfyCustomerInitTest: Codeunit "Shpfy Customer Init Test";
        GraphQL: Text;
    begin
        // Creating Test data.
        ShpfyCustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomerAddress := ShpfyCustomerInitTest.CreateShopifyCustomerAddress(ShpfyCustomer);

        // [SCENARIO] Changing the date of an Shopify Customer and the default address.
        // [GIVEN] ShpfyCustomer with change fields
        ShpfyCustomer := ShpfyCustomerInitTest.ModifyFields(ShpfyCustomer);
        // [GIVEN] ShpfyCustomerAddress with change fields
        ShpfyCustomerAddress := ShpfyCustomerInitTest.ModifyFields(ShpfyCustomerAddress);

        // [WHEN] Invoke ShpfyCustomerApi.CreateGraphQueryUpdateCustomer(ShpfyCustomer, ShpfyCustomerAddress)
        GraphQL := ShpfyCustomerApi.CreateGraphQueryUpdateCustomer(ShpfyCustomer, ShpfyCustomerAddress);

        // [THEN] CustomerInitTest.CreateCustomerGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(ShpfyCustomerInitTest.CreateGraphQueryUpdateCustomerResult(ShpfyCustomer.Id, ShpfyCustomerAddress.Id), GraphQL, 'CreateGraphQueryUpdateCustomer');
    end;

    [Test]
    procedure UnitTestUpdateShopifyCustomerFields()
    var
        ShpfyCustomer: Record "Shpfy Customer";

        ShpfyCustomerAddress: Record "Shpfy Customer Address";
        ShpfyCustomerApi: Codeunit "Shpfy Customer API";
        ShpfyCustomerInitTest: Codeunit "Shpfy Customer Init Test";
        Result: Boolean;
        JCustomer: JsonObject;
    begin
        // Creating Test data.
        ShpfyCustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomerAddress := ShpfyCustomerInitTest.CreateShopifyCustomerAddress(ShpfyCustomer);
        JCustomer := ShpfyCustomerInitTest.DummyJsonCustomerObjectFromShopify(ShpfyCustomer.Id, ShpfyCustomerAddress.Id);

        // [SCENARIO] Changing the date of an Shopify Customer and the default address.
        // [GIVEN] ShpfyCustomer to update
        // [GIVEN] JCustomer with the updated data (Text fields will get the name of the field.)

        // [WHEN] Invoke ShpfyCustomerApi.UpdateShopifyCustomerFields(ShpfyCustomer, JCustomer)
        Result := ShpfyCustomerApi.UpdateShopifyCustomerFields(ShpfyCustomer, JCustomer);

        // [THEN] Result = true
        LibraryAssert.IsTrue(Result, 'UpdateShopifyCustomerFields = true');

        //[THEN] Test if the value of Text fields equals of the field name.
        ShpfyCustomerInitTest.TextFieldsContainsFieldName(ShpfyCustomer);
        ShpfyCustomerAddress.Get(ShpfyCustomerAddress.Id);
        ShpfyCustomerInitTest.TextFieldsContainsFieldName(ShpfyCustomerAddress);
    end;
}
