// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

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
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        CustomerApi: Codeunit "Shpfy Customer API";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        GraphQL: Text;
    begin
        // Creating Test data.
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        CustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress(ShopifyCustomer);

        // [SCENARIO] Creating the GrapghQL query to create a new customer in Shopify
        // [GIVEN] ShpfyCustomer
        // [GIVEN] ShpfyCustomerAddress

        // [WHEN] Invoke CustomerApi.CreateCustomerGraphQLQuery
        GraphQL := CustomerApi.CreateCustomerGraphQLQuery(ShopifyCustomer, CustomerAddress);

        // [THEN] CustomerInitTest.CreateCustomerGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(CustomerInitTest.CreateCustomerGraphQLResult(), GraphQL, 'CreateCustomerGraphQuery');
    end;

    [Test]
    procedure UnitTestCreateGraphQueryUpdateCustomer()
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        CustomerApi: Codeunit "Shpfy Customer API";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        GraphQL: Text;
    begin
        // Creating Test data.
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        CustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress(ShopifyCustomer);

        // [SCENARIO] Changing the date of an Shopify Customer and the default address.
        // [GIVEN] ShpfyCustomer with change fields
        ShopifyCustomer := CustomerInitTest.ModifyFields(ShopifyCustomer);
        // [GIVEN] ShpfyCustomerAddress with change fields
        CustomerAddress := CustomerInitTest.ModifyFields(CustomerAddress);

        // [WHEN] Invoke ShpfyCustomerApi.CreateGraphQueryUpdateCustomer(ShpfyCustomer, ShpfyCustomerAddress)
        GraphQL := CustomerApi.CreateGraphQueryUpdateCustomer(ShopifyCustomer, CustomerAddress);

        // [THEN] CustomerInitTest.CreateCustomerGraphQLResult() = GraphQL.
        LibraryAssert.AreEqual(CustomerInitTest.CreateGraphQueryUpdateCustomerResult(ShopifyCustomer.Id, CustomerAddress.Id), GraphQL, 'CreateGraphQueryUpdateCustomer');
    end;

    [Test]
    procedure UnitTestUpdateShopifyCustomerFields()
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        CustomerApi: Codeunit "Shpfy Customer API";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        Result: Boolean;
        JCustomer: JsonObject;
    begin
        // Creating Test data.
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        CustomerAddress := CustomerInitTest.CreateShopifyCustomerAddress(ShopifyCustomer);
        JCustomer := CustomerInitTest.DummyJsonCustomerObjectFromShopify(ShopifyCustomer.Id, CustomerAddress.Id);

        // [SCENARIO] Changing the date of an Shopify Customer and the default address.
        // [GIVEN] ShpfyCustomer to update
        // [GIVEN] JCustomer with the updated data (Text fields will get the name of the field.)

        // [WHEN] Invoke ShpfyCustomerApi.UpdateShopifyCustomerFields(ShpfyCustomer, JCustomer)
        Result := CustomerApi.UpdateShopifyCustomerFields(ShopifyCustomer, JCustomer);

        // [THEN] Result = true
        LibraryAssert.IsTrue(Result, 'UpdateShopifyCustomerFields = true');

        //[THEN] Test if the value of Text fields equals of the field name.
        CustomerInitTest.TextFieldsContainsFieldName(ShopifyCustomer);
        CustomerAddress.Get(CustomerAddress.Id);
        CustomerInitTest.TextFieldsContainsFieldName(CustomerAddress);
    end;
}