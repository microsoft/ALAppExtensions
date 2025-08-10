// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.PaymentTerms;

codeunit 139636 "Shpfy Company Export Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        CompanyExport: Codeunit "Shpfy Company Export";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerData()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        ShopifyShop: Record "Shpfy Shop";
        Result: Boolean;
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Convert an existing company record to a "Shpfy Company" and "Shpfy Company Location" record.

        // [GIVEN] Customer record
        Customer.FindFirst();
        ShopifyShop := InitializeTest.CreateShop();
        ShopifyShop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        ShopifyShop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        ShopifyShop."Contact Source" := Enum::"Shpfy Name Source"::None;
        ShopifyShop."County Source" := Enum::"Shpfy County Source"::Name;
        ShopifyShop."B2B Enabled" := true;
        ShopifyCompany.Init();
        CompanyLocation.Init();
        ShopifyPaymentTermsId := 0;

        // [GIVEN] Shop
        CompanyExport.SetShop(ShopifyShop);

        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCompany(Customer, ShopifyCompany) and ShpfyCustomerExport.FillInShopifyCompanyLocation(Customer, CompanyLocation)
        Result := CompanyExport.FillInShopifyCompany(Customer, ShopifyCompany) and
                  CompanyExport.FillInShopifyCompanyLocation(Customer, CompanyLocation);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.AreEqual(Customer.Name, ShopifyCompany.Name, 'Name');
        LibraryAssert.AreEqual(Customer."Phone No.", CompanyLocation."Phone No.", 'Phone No.');
        LibraryAssert.AreEqual(Customer.Address, CompanyLocation.Address, 'Address 1');
        LibraryAssert.AreEqual(Customer."Address 2", CompanyLocation."Address 2", 'Address 2');
        LibraryAssert.AreEqual(Customer."Post Code", CompanyLocation.Zip, 'Post Code');
        LibraryAssert.AreEqual(Customer.City, CompanyLocation.City, 'City');
        LibraryAssert.AreEqual(Customer."Country/Region Code", CompanyLocation."Country/Region Code", 'Country');
        LibraryAssert.AreEqual(Customer.Name, CompanyLocation.Recipient, 'Recipient');
        LibraryAssert.AreEqual(ShopifyPaymentTermsId, CompanyLocation."Shpfy Payment Terms Id", 'Payment Terms Id should be 0');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerDataWithLocationPaymentTerm()
    var
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        CompanyLocation: Record "Shpfy Company Location";
        PaymentTermsCode: Code[10];
        ShopifyPaymentTermsId: BigInteger;
    begin
        // [SCENARIO] Export company with payment terms.
        Initialize();

        // [GIVEN] Payment terms
        PaymentTermsCode := CreatePaymentTerms();
        // [GIVEN] Shopify payment terms
        ShopifyPaymentTermsId := CreateShopifyPaymentTerms(PaymentTermsCode);
        // [GIVEN] Customer record with payment terms
        CreateCustomer(Customer, PaymentTermsCode);
        // [GIVEN] Shopify Company 
        CreateCompany(ShopifyCompany, Customer.SystemId);
        // [GIVEN] Company Location
        CreateCompanyLocation(CompanyLocation, ShopifyCompany.SystemId, ShopifyPaymentTermsId);

        // [WHEN] Invoke FillInShopifyCompany and FillInShopifyCompanyLocation
        CompanyExport.FillInShopifyCompany(Customer, ShopifyCompany);
        CompanyExport.FillInShopifyCompanyLocation(Customer, CompanyLocation);

        // [THEN] The payment terms id is set in the company location record.
        LibraryAssert.AreEqual(ShopifyPaymentTermsId, CompanyLocation."Shpfy Payment Terms Id", 'Payment Terms Id');
    end;

    [Test]
    procedure UnitTestFillInShopifyCustomerDataCounty()
    var
        Customer: Record Customer;
        CompanyLocation: Record "Shpfy Company Location";
        ShopifyShop: Record "Shpfy Shop";
        TaxArea: Record "Shpfy Tax Area";
        Result: Boolean;
    begin
        // [SCENARIO] County information is only sent to Shopify if the country has any provinces

        // [GIVEN] Customer record
        Customer.FindFirst();
        Customer."Country/Region Code" := 'US';
        Customer."County" := 'CA';
        Customer.Modify();

        TaxArea."Country/Region Code" := 'US';
        TaxArea.County := 'CA';
        TaxArea."County Code" := 'CA';
        TaxArea.Insert();

        ShopifyShop := InitializeTest.CreateShop();
        ShopifyShop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        ShopifyShop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        ShopifyShop."Contact Source" := Enum::"Shpfy Name Source"::None;
        ShopifyShop."County Source" := Enum::"Shpfy County Source"::Name;
        ShopifyShop."B2B Enabled" := true;
        CompanyLocation.Init();

        // [GIVEN] Shop
        CompanyExport.SetShop(ShopifyShop);

        // [GIVEN] Customer record
        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCompanyLocation(Customer, CompanyLocation)
        Result := CompanyExport.FillInShopifyCompanyLocation(Customer, CompanyLocation);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.IsTrue(CompanyLocation."Province Code" <> '', 'Province Code');
        LibraryAssert.IsTrue(CompanyLocation."Province Name" <> '', 'Province Name');

        // [WHEN] Change the county to a country without provinces
        Customer."Country/Region Code" := 'DE';
        Customer.Modify();
        Clear(CompanyLocation);
        Result := CompanyExport.FillInShopifyCompanyLocation(Customer, CompanyLocation);

        // [THEN] The result is true and the province fields are empty.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.IsTrue(CompanyLocation."Province Code" = '', 'Province Code');
        LibraryAssert.IsTrue(CompanyLocation."Province Name" = '', 'Province Name');
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

    local procedure CreateCustomer(var Customer: Record Customer; PaymentTermsCode: Code[10])
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
        ShopifyCompany.Insert(false);
    end;

    local procedure CreateCompanyLocation(var CompanyLocation: Record "Shpfy Company Location"; ShopifyCompanySystemId: Guid; PaymentTermsId: BigInteger)
    begin
        CompanyLocation.Init();
        CompanyLocation."Company SystemId" := ShopifyCompanySystemId;
        CompanyLocation.Id := Any.IntegerInRange(10000, 99999);
        CompanyLocation."Shpfy Payment Terms Id" := PaymentTermsId;
        CompanyLocation.Insert(false);
    end;
}
