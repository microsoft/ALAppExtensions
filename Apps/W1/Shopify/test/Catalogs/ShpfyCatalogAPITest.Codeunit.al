// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Sales.Customer;

codeunit 139645 "Shpfy Catalog API Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";

    [Test]
    procedure UnitTestExtractShopifyCatalogs()
    var
        ShopifyCompany: Record "Shpfy Company";
        Catalog: Record "Shpfy Catalog";
        CatalogAPI: Codeunit "Shpfy Catalog API";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        JResponse: JsonObject;
        Result: Boolean;
        Cursor: Text;
    begin
        // Creating Test data.
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        JResponse := CatalogInitialize.CatalogResponse();

        // [SCENARIO] Extracting the Catalogs from the Shopify response.
        // [GIVEN] JResponse with Catalogs

        // [WHEN] Invoke CatalogAPI.ExtractShopifyCatalogs
        Result := CatalogAPI.ExtractShopifyCatalogs(ShopifyCompany, JResponse, Cursor);

        // [THEN] Result = true and Catalog prices are created.
        LibraryAssert.IsTrue(Result, 'ExtractShopifyCatalogs');
        LibraryAssert.RecordIsNotEmpty(Catalog);
    end;

    [Test]
    procedure UnitTestExtractShopifyCatalogPrices()
    var
        TempCatalogPrice: Record "Shpfy Catalog Price" temporary;
        CatalogAPI: Codeunit "Shpfy Catalog API";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        JResponse: JsonObject;
        Result: Boolean;
        Cursor: Text;
        ProductId: BigInteger;
        ProductsList: List of [BigInteger];
    begin
        // Creating Test data.
        ProductId := LibraryRandom.RandIntInRange(100000, 999999);
        ProductsList.Add(ProductId);
        JResponse := CatalogInitialize.CatalogPriceResponse(ProductId);

        // [SCENARIO] Extracting the Catalog Prices from the Shopify response.
        // [GIVEN] JResponse with Catalog Prices

        // [WHEN] Invoke CatalogAPI.ExtractShopifyCatalogPrices
        Result := CatalogAPI.ExtractShopifyCatalogPrices(TempCatalogPrice, ProductsList, JResponse, Cursor);

        // [THEN] Result = true and Catalog prices are created.
        LibraryAssert.IsTrue(Result, 'ExtractShopifyCatalogPrices');
        LibraryAssert.RecordIsNotEmpty(TempCatalogPrice);
    end;

    [Test]
    procedure UnitTestCreateCatalog()
    var
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCompany: Record "Shpfy Company";
        Catalog: Record "Shpfy Catalog";
        CatalogAPI: Codeunit "Shpfy Catalog API";
        ShopifyInitializeTest: Codeunit "Shpfy Initialize Test";
        CatalogAPISubscribers: Codeunit "Shpfy Catalog API Subscribers";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] Create a catalog for a company.

        // [GIVEN] Shop
        Shop := ShopifyInitializeTest.CreateShop();
        // [GIVEN] Customer
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] A company record.
        CreateCompany(ShopifyCompany, Customer.SystemId);

        // [WHEN] Invoke CatalogAPI.CreateCatalog
        BindSubscription(CatalogAPISubscribers);
        CatalogAPI.CreateCatalog(ShopifyCompany, Customer);
        UnbindSubscription(CatalogAPISubscribers);

        // [THEN] A catalog is created.
        Catalog.SetRange("Company SystemId", ShopifyCompany.SystemId);
        Catalog.FindFirst();
        LibraryAssert.AreEqual(Customer."No.", Catalog."Customer No.", 'Customer No. is not transferred to catalog');
    end;

    local procedure CreateCompany(var ShopifyCompany: Record "Shpfy Company"; CustomerSystemId: Guid)
    var
        ShopifyCompanyInitialize: Codeunit "Shpfy Company Initialize";
    begin
        ShopifyCompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        ShopifyCompany."Customer SystemId" := CustomerSystemId;
        ShopifyCompany.Modify(false);
    end;
}
