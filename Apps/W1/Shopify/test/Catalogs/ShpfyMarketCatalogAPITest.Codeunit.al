codeunit 139542 "Shpfy Market Catalog API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = AllowOutboundFromHandler;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        OutboundHttpRequests: Codeunit "Library - Variable Storage";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler')]
    procedure UnitTestExtractShopifyMarketCatalogs()
    var
        Catalog: Record "Shpfy Catalog";
        Shop: Record "Shpfy Shop";
        CatalogAPI: Codeunit "Shpfy Catalog API";
    begin
        Initialize();

        // [SCENARIO] Get Market Catalogs and linked markets from the Shopify.

        // [GIVEN] Market Catalogs and Linked Catalog Markets JResponses

        // [GIVEN] Register Expected Outbound API Requests
        RegisterExpectedOutboundHttpRequests();

        // [WHEN] Invoke CatalogAPI.GetMarketCatalogs to get Market Catalogs and linked markets
        Shop.Get(LibraryVariableStorage.PeekText(1));
        CatalogAPI.SetShop(Shop);
        CatalogAPI.GetMarketCatalogs();

        // [THEN] Verify that market catalogs are created
        Catalog.SetRange("Catalog Type", Catalog."Catalog Type"::Market);
        Catalog.SetRange("Shop Code", Shop.Code);
        LibraryAssert.AreEqual(3, Catalog.Count(), 'Incorrect number of Market Catalogs');
        OutboundHttpRequests.AssertEmpty();
        LibraryAssert.RecordIsNotEmpty(Catalog);
    end;

    //TODO: Re-implement to Http mocking
    // [Test]
    // procedure UnitTestExtractShopifyMarketCatalogPrices()
    // var
    //     TempCatalogPrice: Record "Shpfy Catalog Price" temporary;
    //     CatalogAPI: Codeunit "Shpfy Catalog API";
    //     CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
    //     JResponse: JsonObject;
    //     Result: Boolean;
    //     Cursor: Text;
    //     ProductId: BigInteger;
    //     ProductsList: List of [BigInteger];
    // begin
    //     // Creating Test data.
    //     ProductId := LibraryRandom.RandIntInRange(100000, 999999);
    //     ProductsList.Add(ProductId);
    //     JResponse := CatalogInitialize.MarketCatalogPriceResponse(ProductId);

    //     // [SCENARIO] Extracting the Market Catalog Prices from the Shopify response.
    //     // [GIVEN] JResponse with Market Catalog Prices

    //     // [WHEN] Invoke CatalogAPI.ExtractShopifyCatalogPrices
    //     Result := CatalogAPI.ExtractShopifyCatalogPrices(TempCatalogPrice, ProductsList, JResponse, Cursor);

    //     // [THEN] Result = true and Market Catalog prices are created.
    //     LibraryAssert.IsTrue(Result, 'ExtractShopifyMarketCatalogPrices');
    //     LibraryAssert.RecordIsNotEmpty(TempCatalogPrice);
    // end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        UnexpectedAPICallsErr: Label 'More than expected API calls to Shopify detected.';
        MarketCatalogsResponseTok: Label 'Catalogs/MarketCatalogResponse.txt', Locked = true;
        CatalogMarketsResponse1Tok: Label 'Catalogs/CatalogMarkets1.txt', Locked = true;
        CatalogMarketsResponse2Tok: Label 'Catalogs/CatalogMarkets2.txt', Locked = true;
        CatalogMarketsResponse3Tok: Label 'Catalogs/CatalogMarkets3.txt', Locked = true;
        ShopifyShopUrlTok: Label 'admin\/api\/.+\/graphql.json', Locked = true;
    begin
        if not Regex.IsMatch(Request.Path, ShopifyShopUrlTok) then
            exit(true);

        case OutboundHttpRequests.Length() of
            4:
                LoadResourceIntoHttpResponse(MarketCatalogsResponseTok, Response);
            3:
                LoadResourceIntoHttpResponse(CatalogMarketsResponse1Tok, Response);
            2:
                LoadResourceIntoHttpResponse(CatalogMarketsResponse2Tok, Response);
            1:
                LoadResourceIntoHttpResponse(CatalogMarketsResponse3Tok, Response);
            0:
                Error(UnexpectedAPICallsErr);
        end;
        exit(false);
    end;

    local procedure Initialize()
    var
        Shop: Record "Shpfy Shop";
        CommunicationMgt: Codeunit "Shpfy Communication Mgt.";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        AccessToken: SecretText;
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Shpfy Market Catalog API Test");
        ClearLastError();
        OutboundHttpRequests.Clear();
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");

        LibraryRandom.Init();

        IsInitialized := true;
        Commit();

        // Creating Shopify Shop
        Shop := InitializeTest.CreateShop();
        LibraryVariableStorage.Enqueue(Shop.Code);
        // Disable Event Mocking 
        CommunicationMgt.SetTestInProgress(false);
        //Register Shopify Access Token
        AccessToken := LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(Shop.GetStoreName(), AccessToken);

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");
    end;

    local procedure RegisterExpectedOutboundHttpRequests()
    begin
        OutboundHttpRequests.Enqueue('GQL Get Catalogs');
        OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 1');
        OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 2');
        OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 3');
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
        OutboundHttpRequests.DequeueText();
    end;
}
