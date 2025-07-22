// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;

codeunit 139637 "Shpfy Company API Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        IsInitialized: Boolean;

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
        ExternalId: Text;
        Result: Boolean;
        CompanyContactId: BigInteger;
        CustomerId: BigInteger;
    begin
        // Creating Test data.
        ShopifyCompany.Insert();
        Name := LibraryRandom.RandText(MaxStrLen(ShopifyCompany.Name));
        ExternalId := LibraryRandom.RandText(MaxStrLen(ShopifyCompany."External Id"));
        CompanyContactId := LibraryRandom.RandIntInRange(100000, 999999);
        CustomerId := LibraryRandom.RandIntInRange(100000, 999999);
        JResponse := CompanyInitialize.CompanyResponse(Name, ExternalId, CompanyContactId, CustomerId);

        // [SCENARIO] Extracting the company from the Shopify response.
        // [GIVEN] JResponse with Company

        // [WHEN] Invoke CompanyAPI.UpdateShopifyCompanyFields
        Result := CompanyAPI.UpdateShopifyCompanyFields(ShopifyCompany, JResponse);

        // [THEN] Shopify company fields are updated.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(ShopifyCompany.Name, Name, 'Name');
        LibraryAssert.AreEqual(ShopifyCompany."External Id", ExternalId, 'External Id');
        LibraryAssert.AreEqual(ShopifyCompany."Main Contact Id", CompanyContactId, 'Company Contact Id');
        LibraryAssert.AreEqual(ShopifyCompany."Main Contact Customer Id", CustomerId, 'Customer Id');
    end;

    [Test]
    procedure UnitTestCreateCompanyWithPaymentTerms()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CompanyAPI: Codeunit "Shpfy Company API";
        GraphQL: Text;
    begin
        // [SCENARIO] Export company with payment terms.

        // [GIVEN] Shopify company
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        // [GIVEN] Shopify company location with payment terms id
        CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation(ShopifyCompany);
        CompanyLocation."Shpfy Payment Terms Id" := LibraryRandom.RandIntInRange(1000, 9999);

        // [WHEN] Invoke CompanyAPI.CreateCompanyGraphQLQuery
        GraphQL := CompanyAPI.CreateCompanyGraphQLQuery(ShopifyCompany, CompanyLocation);

        // [THEN] The payment terms id is present in query.
        LibraryAssert.IsTrue(GraphQL.Contains(StrSubstNo(CompanyInitialize.PaymentTermsGQLNode(), CompanyLocation."Shpfy Payment Terms Id")), 'Payment Terms Id');
    end;

    [Test]
    procedure UnitTestUpdateCompanyWithPaymentTerms()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        GraphQL: Text;
    begin
        // [SCENARIO] Update Shopify company with payment terms.
        Initialize();

        // [GIVEN] Shopify company
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        // [GIVEN] Shopify company location with payment terms id
        CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation(ShopifyCompany);
        CompanyLocation."Shpfy Payment Terms Id" := LibraryRandom.RandIntInRange(1000, 9999);
        CompanyLocation.Modify(false);
        // [GIVEN] Shopify company location with changed payment terms id
        CompanyLocation."Shpfy Payment Terms Id" := LibraryRandom.RandIntInRange(1000, 9999);

        // [WHEN] Invoke CompanyAPI.UpdateCompany
        InvokeUpdateCompany(ShopifyCompany, CompanyLocation, GraphQL);

        // [THEN] The payment terms id is present in query.
        LibraryAssert.IsTrue(GraphQL.Contains(StrSubstNo(CompanyInitialize.PaymentTermsGQLNode(), CompanyLocation."Shpfy Payment Terms Id")), 'Payment terms modification missing in query.');
    end;

    [Test]
    procedure UnitTestUpdateCompanyLocationWithTaxId()
    var
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        GraphQL: Text;
    begin
        // [SCENARIO] Update Shopify company location with tax id.
        Initialize();

        // [GIVEN] Shopify company
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        // [GIVEN] Shopify company location with tax id
        CompanyLocation := CompanyInitialize.CreateShopifyCompanyLocation(ShopifyCompany);
        CompanyLocation."Tax Registration Id" := CopyStr(Any.AlphanumericText(150), 1, MaxStrLen(CompanyLocation."Tax Registration Id"));
        CompanyLocation.Modify(false);
        // [GIVEN] Shopify company location with changed tax id
        CompanyLocation."Tax Registration Id" := CopyStr(Any.AlphanumericText(150), 1, MaxStrLen(CompanyLocation."Tax Registration Id"));

        // [WHEN] Invoke CompanyAPI.UpdateCompany
        InvokeUpdateCompany(ShopifyCompany, CompanyLocation, GraphQL);

        // [THEN] The tax id is present in query.
        LibraryAssert.IsTrue(GraphQL.Contains(CompanyInitialize.TaxIdGQLNode(CompanyLocation)), 'Tax Registration Id  missing in query.');
    end;

    [Test]
    procedure UnitTestCreateCompanyGraphQueryWithExternalId()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CompanyAPI: Codeunit "Shpfy Company API";
        GraphQL: Text;
    begin
        // [SCENARIO] Creating the GrapghQL query to create a new company in Shopify with external id.
        Initialize();

        // [GIVEN] Customer record
        CreateCustomer(Customer);
        // [GIVEN] Shopify Company connected with customer
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        ShopifyCompany."External Id" := Customer."No.";
        ShopifyCompany.Modify();

        // [WHEN] Invoke CompanyAPI.CreateCompanyGraphQLQuery
        GraphQL := CompanyAPI.CreateCompanyGraphQLQuery(ShopifyCompany, CompanyLocation);

        // [THEN] The external id is present in query.
        LibraryAssert.IsTrue(GraphQL.Contains(CompanyInitialize.ExternalIdGQLNode(Customer)), 'externalId missing in query.');
    end;

    local procedure Initialize()
    begin
        Any.SetDefaultSeed();

        if IsInitialized then
            exit;
        Shop := InitializeTest.CreateShop();
        IsInitialized := true;
    end;

    local procedure InvokeUpdateCompany(var ShopifyCompany: Record "Shpfy Company"; var CompanyLocation: Record "Shpfy Company Location"; var GraphQL: Text)
    var
        CompanyAPI: Codeunit "Shpfy Company API";
        CompanyAPISubs: Codeunit "Shpfy Company API Subs.";
    begin
        BindSubscription(CompanyAPISubs);
        CompanyAPI.SetShop(Shop);
        CompanyAPI.UpdateCompany(ShopifyCompany);
        CompanyAPI.UpdateCompanyLocation(CompanyLocation);
        GraphQL := CompanyAPISubs.GetExecutedQuery();
        UnbindSubscription(CompanyAPISubs);
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer.Insert(false);
    end;
}
