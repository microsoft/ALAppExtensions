codeunit 139542 "Shpfy Market Catalog API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";

    [Test]
    procedure UnitTestExtractShopifyMarketCatalogs()
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

        // [SCENARIO] Extracting the Market Catalogs from the Shopify response.
        // [GIVEN] JResponse with Market Catalogs

        // [WHEN] Invoke CatalogAPI.ExtractShopifyMarketCatalogs
        Result := CatalogAPI.ExtractShopifyMarketCatalogs(JResponse, Cursor);

        // [THEN] Result = true and Market Catalog prices are created.
        LibraryAssert.IsTrue(Result, 'ExtractShopifyMarketCatalogs');
        LibraryAssert.RecordIsNotEmpty(Catalog);
    end;

    [Test]
    procedure UnitTestExtractShopifyMarketCatalogPrices()
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
        JResponse := CatalogInitialize.MarketCatalogPriceResponse(ProductId);

        // [SCENARIO] Extracting the Market Catalog Prices from the Shopify response.
        // [GIVEN] JResponse with Market Catalog Prices

        // [WHEN] Invoke CatalogAPI.ExtractShopifyCatalogPrices
        Result := CatalogAPI.ExtractShopifyCatalogPrices(TempCatalogPrice, ProductsList, JResponse, Cursor);

        // [THEN] Result = true and Market Catalog prices are created.
        LibraryAssert.IsTrue(Result, 'ExtractShopifyMarketCatalogPrices');
        LibraryAssert.RecordIsNotEmpty(TempCatalogPrice);
    end;
}
