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
        this.Initialize();

        // [SCENARIO] Get Market Catalogs and linked markets from the Shopify.

        // [GIVEN] Market Catalogs and Linked Catalog Markets JResponses

        // [GIVEN] Register Expected Outbound API Requests
        this.RegisterExpectedOutboundHttpRequests();

        // [WHEN] Invoke CatalogAPI.GetMarketCatalogs to get Market Catalogs and linked markets
        Shop.Get(this.LibraryVariableStorage.PeekText(1));
        CatalogAPI.SetShop(Shop);
        CatalogAPI.GetMarketCatalogs();

        // [THEN] Verify that market catalogs are created
        Catalog.SetRange("Catalog Type", Catalog."Catalog Type"::Market);
        Catalog.SetRange("Shop Code", Shop.Code);
        this.LibraryAssert.AreEqual(3, Catalog.Count(), 'Incorrect number of Market Catalogs');
        this.OutboundHttpRequests.AssertEmpty();
        this.LibraryAssert.RecordIsNotEmpty(Catalog);
    end;

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
                this.LoadResourceIntoHttpResponse(MarketCatalogsResponseTok, Response);
            3:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse1Tok, Response);
            2:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse2Tok, Response);
            1:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse3Tok, Response);
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
        this.LibraryTestInitialize.OnTestInitialize(Codeunit::"Shpfy Market Catalog API Test");
        ClearLastError();
        this.OutboundHttpRequests.Clear();
        if IsInitialized then
            exit;

        this.LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");

        this.LibraryRandom.Init();

        this.IsInitialized := true;
        Commit();

        // Creating Shopify Shop
        Shop := InitializeTest.CreateShop();
        this.LibraryVariableStorage.Enqueue(Shop.Code);
        // Disable Event Mocking 
        CommunicationMgt.SetTestInProgress(false);
        //Register Shopify Access Token
        AccessToken := this.LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(Shop.GetStoreName(), AccessToken);

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");
    end;

    local procedure RegisterExpectedOutboundHttpRequests()
    begin
        this.OutboundHttpRequests.Enqueue('GQL Get Catalogs');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 1');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 2');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 3');
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
        this.OutboundHttpRequests.DequeueText();
    end;
}
