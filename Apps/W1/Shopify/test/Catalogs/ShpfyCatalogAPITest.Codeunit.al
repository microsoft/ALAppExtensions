codeunit 139645 "Shpfy Catalog API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

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
    begin
        // Creating Test data.
        JResponse := CatalogInitialize.CatalogPriceResponse();

        // [SCENARIO] Extracting the Catalog Prices from the Shopify response.
        // [GIVEN] JResponse with Catalog Prices

        // [WHEN] Invoke CatalogAPI.ExtractShopifyCatalogPrices
        Result := CatalogAPI.ExtractShopifyCatalogPrices(TempCatalogPrice, JResponse, Cursor);

        // [THEN] Result = true and Catalog prices are created.
        LibraryAssert.IsTrue(Result, 'ExtractShopifyCatalogPrices');
        LibraryAssert.RecordIsNotEmpty(TempCatalogPrice);
    end;
}
