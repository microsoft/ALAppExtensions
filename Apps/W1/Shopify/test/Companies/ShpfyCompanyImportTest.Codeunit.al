// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.PaymentTerms;

codeunit 139647 "Shpfy Company Import Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        InitializeTest: Codeunit "Shpfy Initialize Test";
        IsInitialized: Boolean;

    [Test]
    procedure UnitTestFindMappingBetweenCompanyAndCustomer()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        ShopifyCustomer: Record "Shpfy Customer";
        ShopifyShop: Record "Shpfy Shop";
        CompanyMapping: Codeunit "Shpfy Company Mapping";
        Result: Boolean;
    begin
        // [SCENARIO] Importing a company record that is already mapped to a customer record via email.
        Initialize();
        ShopifyShop := InitializeTest.CreateShop();
        ShopifyShop."B2B Enabled" := true;

        // [GIVEN] Shop, Shopify company and Shopify customer
        CompanyMapping.SetShop(ShopifyShop);
        ShopifyCompany.Insert();
#pragma warning disable AA0210
        Customer.SetFilter("E-Mail", '<>%1', '');
#pragma warning restore AA0210
        Customer.FindFirst();
        ShopifyCustomer.Email := Customer."E-Mail";


        // [WHEN] Invoke CompanyMapping.FindMapping(ShopifyCompany, ShopifyCustomer)
        Result := CompanyMapping.FindMapping(ShopifyCompany, ShopifyCustomer);

        // [THEN] The result is true and Shopify company has the correct customer id.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(ShopifyCompany."Customer SystemId", Customer.SystemId, 'Customer SystemId');
    end;

    [Test]
    procedure UnitTestImportCompanyWithLocation()
    var
        ShopifyCompany: Record "Shpfy Company";
        LocationValues: Dictionary of [Text, Text];
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Importing a company with location with defined payment term.
        Initialize();

        // [GIVEN] Shopify company
        CreateCompany(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company location values in Shopify
        CreateLocationValues(LocationValues);

        // [WHEN] Invoke CompanyImport
        InvokeCompanyImport(ShopifyCompany, LocationValues);

        // [THEN] Location is created with the correct payment term and all other .
        VerifyShopifyCompanyLocationValues(ShopifyCompany, LocationValues);
    end;

    [Test]
    procedure UnitTestUpdateCustomerFromCompanyWithPaymentTerms()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        UpdateCustomer: Codeunit "Shpfy Update Customer";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Update a customer from a company with location with defined payment term and existing payment terms in BC.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        ShopifyPaymentTermsId := CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Customer record with payment terms
        CreateCustomerWithPaymentTerms(Customer, PaymentTermsCode);
        // [GIVEN] Shopify Company
        CreateCompany(ShopifyCompany, Customer.SystemId);
        // [GIVEN] Company Location
        CreateCompanyLocation(CompanyLocation, ShopifyCompany, ShopifyPaymentTermsId);

        // [WHEN] Invoke UpdateCustomerFromCompany
        UpdateCustomer.UpdateCustomerFromCompany(ShopifyCompany);

        // [THEN] Customer record is updated with the correct payment terms.
        Customer.GetBySystemId(Customer.SystemId);
        LibraryAssert.AreEqual(Customer."Payment Terms Code", PaymentTermsCode, 'Payment Terms Code');
    end;

    [Test]
    procedure UnitTestCreateCustomerFromCompanyWithPaymentTerms()
    var
        Customer: Record Customer;
        TempShopifyCustomer: Record "Shpfy Customer" temporary;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        CreateCustomer: Codeunit "Shpfy Create Customer";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
        EmptyGuid: Guid;
    begin
        // [SCENARIO] Create a customer from a company with location with defined payment term.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        ShopifyPaymentTermsId := CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Shopify Company
        CreateCompany(ShopifyCompany, EmptyGuid);
        // [GIVEN] Company Location
        CreateCompanyLocation(CompanyLocation, ShopifyCompany, ShopifyPaymentTermsId);
        // [GIVEN] TempShopifyCustomer
        CreateTempShopifyCustomer(TempShopifyCustomer);

        // [WHEN] Invoke CreateCustomerFromCompany
        CreateCustomer.SetShop(Shop);
        CreateCustomer.SetTemplateCode(Shop."Customer Templ. Code");
        CreateCustomer.CreateCustomerFromCompany(ShopifyCompany, TempShopifyCustomer);

        // [THEN] Customer record is created with the correct payment terms.
        Customer.GetBySystemId(ShopifyCompany."Customer SystemId");
        LibraryAssert.AreEqual(Customer."Payment Terms Code", PaymentTermsCode, 'Payment Terms Code');
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
        PaymentTerms.Code := CopyStr(Any.AlphanumericText(10), 1, MaxStrLen(PaymentTerms.Code));
        PaymentTerms.Insert(false);
        exit(PaymentTerms.Code);
    end;

    local procedure CreateShopifyPaymentTerms(PaymentTermsCode: Code[10]): BigInteger
    var
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        ShopifyPaymentTerms.Init();
        ShopifyPaymentTerms.Id := Any.IntegerInRange(10000, 99999);
        ShopifyPaymentTerms."Payment Terms Code" := PaymentTermsCode;
        ShopifyPaymentTerms.Insert(false);
        exit(ShopifyPaymentTerms.Id);
    end;

    local procedure CreateCustomerWithPaymentTerms(var Customer: Record Customer; PaymentTermsCode: Code[10])
    begin
        Customer.Init();
        Customer."No." := CopyStr(Any.AlphanumericText(20), 1, MaxStrLen(Customer."No."));
        Customer."Payment Terms Code" := PaymentTermsCode;
        Customer.Insert(false);
    end;

    local procedure CreateCompany(var ShopifyCompany: Record "Shpfy Company"; CustomerSystemId: Guid)
    begin
        ShopifyCompany.Init();
        ShopifyCompany.Id := Any.IntegerInRange(10000, 99999);
        ShopifyCompany."Customer SystemId" := CustomerSystemId;
        ShopifyCompany."Shop Id" := Shop."Shop Id";
        ShopifyCompany.Insert(false);
    end;

    local procedure CreateCompanyLocation(var CompanyLocation: Record "Shpfy Company Location"; var ShopifyCompany: Record "Shpfy Company"; PaymentTermsId: BigInteger)
    begin
        CompanyLocation.Init();
        CompanyLocation."Company SystemId" := ShopifyCompany.SystemId;
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Shpfy Payment Terms Id" := PaymentTermsId;
        CompanyLocation.Insert(false);

        ShopifyCompany."Location Id" := CompanyLocation.Id;
        ShopifyCompany.Modify(false);
    end;

    local procedure CreateTempShopifyCustomer(var TempShopifyCustomer: Record "Shpfy Customer" temporary)
    begin
        TempShopifyCustomer.Init();
        TempShopifyCustomer.Id := Any.IntegerInRange(10000, 99999);
        TempShopifyCustomer.Insert(false);
    end;

    local procedure InvokeCompanyImport(var ShopifyCompany: Record "Shpfy Company"; LocationValues: Dictionary of [Text, Text])
    var
        CompanyImport: Codeunit "Shpfy Company Import";
        CompanyImportSubs: Codeunit "Shpfy Company Import Subs.";
    begin
        BindSubscription(CompanyImportSubs);
        CompanyImportSubs.SetLocationValues(LocationValues);
        CompanyImport.SetShop(Shop);
        ShopifyCompany.SetRange("Id", ShopifyCompany.Id);
        CompanyImport.Run(ShopifyCompany);
        UnbindSubscription(CompanyImportSubs);
    end;

    local procedure VerifyShopifyCompanyLocationValues(var ShopifyCompany: Record "Shpfy Company"; LocationValues: Dictionary of [Text, Text])
    var
        CompanyLocation: Record "Shpfy Company Location";
        Id, PaymentTermsId : BigInteger;
    begin
        Evaluate(Id, LocationValues.Get('id'));
        Evaluate(PaymentTermsId, LocationValues.Get('paymentTermsTemplateId'));
        CompanyLocation.SetRange("Company SystemId", ShopifyCompany.SystemId);
        LibraryAssert.IsTrue(CompanyLocation.FindFirst(), 'Company location does not exist');
        LibraryAssert.AreEqual(Id, CompanyLocation.Id, 'Id not imported');
        LibraryAssert.AreEqual(LocationValues.Get('address1'), CompanyLocation.Address, 'Address not imported');
        LibraryAssert.AreEqual(LocationValues.Get('address2'), CompanyLocation."Address 2", 'Address 2 not imported');
        LibraryAssert.AreEqual(LocationValues.Get('phone'), CompanyLocation."Phone No.", 'Phone No. not imported');
        LibraryAssert.AreEqual(LocationValues.Get('zip'), CompanyLocation.Zip, 'Zip not imported');
        LibraryAssert.AreEqual(LocationValues.Get('city'), CompanyLocation.City, 'City not imported');
        LibraryAssert.AreEqual(LocationValues.Get('countryCode').ToUpper(), CompanyLocation."Country/Region Code", 'Country/Region Code not imported');
        LibraryAssert.AreEqual(LocationValues.Get('zoneCode').ToUpper(), CompanyLocation."Province Code", 'Province Code not imported');
        LibraryAssert.AreEqual(LocationValues.Get('province'), CompanyLocation."Province Name", 'Province Name not imported');
        LibraryAssert.AreEqual(PaymentTermsId, CompanyLocation."Shpfy Payment Terms Id", 'Payment Terms Id not imported');
        LibraryAssert.AreEqual(LocationValues.Get('taxRegistrationId'), CompanyLocation."Tax Registration Id", 'Tax Registration id not imported');
    end;

    local procedure CreateLocationValues(LocationValues: Dictionary of [Text, Text])
    begin
        LocationValues.Add('id', Format(Any.IntegerInRange(10000, 99999)));
        LocationValues.Add('address1', Any.AlphanumericText(20));
        LocationValues.Add('address2', Any.AlphanumericText(20));
        LocationValues.Add('phone', Format(Any.IntegerInRange(1000, 9999)));
        LocationValues.Add('zip', Format(Any.IntegerInRange(1000, 9999)));
        LocationValues.Add('city', Any.AlphanumericText(20));
        LocationValues.Add('countryCode', Any.AlphanumericText(2));
        LocationValues.Add('zoneCode', Any.AlphanumericText(2));
        LocationValues.Add('province', Any.AlphanumericText(20));
        LocationValues.Add('paymentTermsTemplateId', Format(Any.IntegerInRange(10000, 99999)));
        LocationValues.Add('taxRegistrationId', Any.AlphanumericText(50));
    end;
}
