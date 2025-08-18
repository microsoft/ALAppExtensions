// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 139568 "Shpfy Customer Export Test"
{
    Subtype = Test;
    TestType = Uncategorized;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        CustomerExport: Codeunit "Shpfy Customer Export";

    [Test]
    procedure UnitTestSpiltNameIntoFirstAndLastName()
    var
        Name: Text;
        FirstName: Text[100];
        LastName: Text[100];
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
        // [SCENARIO] Convert an existing customer record to a "Shpfy Customer" and "Shpfy Customer Address" record.

        // [GIVEN] Customer record
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

    [Test]
    procedure UnitTestFillInShopifyCustomerDataCounty()
    var
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerAddress: Record "Shpfy Customer Address";
        Shop: Record "Shpfy Shop";
        TaxArea: Record "Shpfy Tax Area";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        Result: boolean;
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

        Shop := InitializeTest.CreateShop();
        Shop."Name Source" := Enum::"Shpfy Name Source"::CompanyName;
        Shop."Name 2 Source" := Enum::"Shpfy Name Source"::None;
        Shop."Contact Source" := Enum::"Shpfy Name Source"::None;
        Shop."County Source" := Enum::"Shpfy County Source"::Name;
        ShopifyCustomer.Init();
        CustomerAddress.Init();

        // [GIVEN] Shop
        CustomerExport.SetShop(Shop);

        // [WHEN] Invoke ShpfyCustomerExport.FillInShopifyCustomerData(Customer, ShpfyCustomer, ShpfyCustomerAddres)
        Result := CustomerExport.FillInShopifyCustomerData(Customer, ShopifyCustomer, CustomerAddress);

        // [THEN] The result is true and the content of address fields can be found in the shpfy records.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.IsTrue(CustomerAddress."Province Code" <> '', 'Province Code');
        LibraryAssert.IsTrue(CustomerAddress."Province Name" <> '', 'Province Name');

        // [WHEN] Change the county to a country without provinces
        Customer."Country/Region Code" := 'DE';
        Customer.Modify();
        Clear(CustomerAddress);
        Clear(ShopifyCustomer);
        Result := CustomerExport.FillInShopifyCustomerData(Customer, ShopifyCustomer, CustomerAddress);

        // [THEN] The result is true and the province fields are empty.
        LibraryAssert.IsTrue(Result, 'Result');
        LibraryAssert.IsTrue(CustomerAddress."Province Code" = '', 'Province Code');
        LibraryAssert.IsTrue(CustomerAddress."Province Name" = '', 'Province Name');
    end;
}
