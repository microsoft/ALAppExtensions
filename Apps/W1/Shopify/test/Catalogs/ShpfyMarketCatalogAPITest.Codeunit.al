codeunit 139542 "Shpfy Market Catalog API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        OutboundHttpRequests: Codeunit "Library - Variable Storage";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        ShopifyShop: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        UnexpectedAPICallsErr: Label 'More than expected API calls to Shopify detected.';
        ShopifyShopUrlTok: Label 'admin\/api\/.+\/graphql.json', Locked = true;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler_GetMarketCatalogs')]
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
        this.RegExpectedOutboundHttpRequestsForGetMarketCatalogs();

        // [WHEN] Invoke CatalogAPI.GetMarketCatalogs to get Market Catalogs and linked markets
        Shop.Get(this.ShopifyShop.PeekText(1));
        CatalogAPI.SetShop(Shop);
        CatalogAPI.GetMarketCatalogs();

        // [THEN] Verify that market catalogs are created
        Catalog.SetRange("Catalog Type", Catalog."Catalog Type"::Market);
        Catalog.SetRange("Shop Code", Shop.Code);
        this.LibraryAssert.AreEqual(3, Catalog.Count(), 'Incorrect number of Market Catalogs has been created');

        // [THEN] Verify that all expected outbound HTTP requests were executed
        this.OutboundHttpRequests.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler_UpdateCatalogPrices')]
    procedure UnitTestSynchronizeMarketCatalogPrices()
    var
        Catalog: Record "Shpfy Catalog";
        Shop: Record "Shpfy Shop";
        SyncCatalogPrices: Codeunit "Shpfy Sync Catalog Prices";
    begin
        this.Initialize();

        // [SCENARIO] Synchronize Market Catalog Prices from the Business Central.

        // [GIVEN] Market Catalogs and Linked Catalog Markets JResponses

        // [GIVEN] Create Shopify Shop
        Shop.Get(this.ShopifyShop.PeekText(1));

        // [GIVEN] Shopify Products and Pruduct Variants
        this.CreateProductsWithVariants(Shop);

        // [GIVEN] Create Market Catalog
        this.CreateMarketCatalog(Catalog, Shop);

        // [GIVEN] Register Expected Outbound API Requests for Catalog Prices Synchronization
        this.RegExpectedOutboundHttpRequestsForSyncCatalogPrices();

        // [WHEN] Invoke CatalogAPI.SynchronizeMarketCatalogPrices to synchronize Market Catalog Prices
        SyncCatalogPrices.SetCatalogType("Shpfy Catalog Type"::Market);
        SyncCatalogPrices.SyncCatalogPrices(Catalog);

        // [THEN] Verify that all expected outbound HTTP requests were executed
        this.LibraryAssert.IsTrue(this.OutboundHttpRequests.Length() = 0, 'Not all Http requests were executed');
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler_GetMarketCatalogs(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        MarketCatalogsResponseTok: Label 'Catalogs/MarketCatalogResponse.txt', Locked = true;
        CatalogMarketsResponse1Tok: Label 'Catalogs/CatalogMarkets1.txt', Locked = true;
        CatalogMarketsResponse2Tok: Label 'Catalogs/CatalogMarkets2.txt', Locked = true;
        CatalogMarketsResponse3Tok: Label 'Catalogs/CatalogMarkets3.txt', Locked = true;
    begin
        if not Regex.IsMatch(Request.Path, ShopifyShopUrlTok) then
            exit(true);

        case this.OutboundHttpRequests.Length() of
            4:
                this.LoadResourceIntoHttpResponse(MarketCatalogsResponseTok, Response);
            3:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse1Tok, Response);
            2:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse2Tok, Response);
            1:
                this.LoadResourceIntoHttpResponse(CatalogMarketsResponse3Tok, Response);
            0:
                Error(this.UnexpectedAPICallsErr);
        end;
        exit(false);
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler_UpdateCatalogPrices(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        CatalogProductsResponseTok: Label 'Catalogs/CatalogProducts.txt', Locked = true;
        CatalogPricesResponseTok: Label 'Catalogs/CatalogPrices.txt', Locked = true;
        CatalogPriceUpdateResponseTok: Label 'Catalogs/CatalogPricesUpdate.txt', Locked = true;
    begin
        if not Regex.IsMatch(Request.Path, ShopifyShopUrlTok) then
            exit(true);

        case this.OutboundHttpRequests.Length() of
            3:
                this.LoadCatalogProductsHttpResponse(CatalogProductsResponseTok, Response);
            2:
                this.LoadCatalogProductsPriceListHttpResponse(CatalogPricesResponseTok, Response);
            1:
                this.LoadResourceIntoHttpResponse(CatalogPriceUpdateResponseTok, Response);
            0:
                Error(this.UnexpectedAPICallsErr);
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
        this.LibraryVariableStorage.Clear();
        if this.IsInitialized then
            exit;

        this.LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");

        this.LibraryRandom.Init();

        this.IsInitialized := true;
        Commit();

        // Creating Shopify Shop
        Shop := InitializeTest.CreateShop();
        this.ShopifyShop.Enqueue(Shop.Code);
        // Disable Event Mocking 
        CommunicationMgt.SetTestInProgress(false);
        //Register Shopify Access Token
        AccessToken := this.LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(Shop.GetStoreName(), AccessToken);

        this.LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Market Catalog API Test");
    end;

    local procedure RegExpectedOutboundHttpRequestsForGetMarketCatalogs()
    begin
        this.OutboundHttpRequests.Enqueue('GQL Get Catalogs');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 1');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 2');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Markets 3');
    end;

    local procedure RegExpectedOutboundHttpRequestsForSyncCatalogPrices()
    begin
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Products');
        this.OutboundHttpRequests.Enqueue('GQL Get Catalog Prices');
        this.OutboundHttpRequests.Enqueue('GQL Update Catalog Prices');
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
        this.OutboundHttpRequests.DequeueText();
    end;

    local procedure LoadCatalogProductsHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    var
        ResultTxt: Text;
    begin
        ResultTxt := NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8);
        ResultTxt := ResultTxt.Replace('{{ProductId1}}', this.GetIdValueFromVariableStorage(1));
        ResultTxt := ResultTxt.Replace('{{ProductId2}}', this.GetIdValueFromVariableStorage(3));
        ResultTxt := ResultTxt.Replace('{{ProductId3}}', this.GetIdValueFromVariableStorage(5));
        Response.Content.WriteFrom(ResultTxt);
        this.OutboundHttpRequests.DequeueText();
    end;

    local procedure LoadCatalogProductsPriceListHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    var
        ResultTxt: Text;
    begin
        ResultTxt := NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8);
        ResultTxt := ResultTxt.Replace('{{ProductId1}}', this.GetIdValueFromVariableStorage(1));
        ResultTxt := ResultTxt.Replace('{{ProductVariantId1}}', this.GetIdValueFromVariableStorage(2));
        ResultTxt := ResultTxt.Replace('{{ProductId2}}', this.GetIdValueFromVariableStorage(3));
        ResultTxt := ResultTxt.Replace('{{ProductVariantId2}}', this.GetIdValueFromVariableStorage(4));
        ResultTxt := ResultTxt.Replace('{{ProductId3}}', this.GetIdValueFromVariableStorage(5));
        ResultTxt := ResultTxt.Replace('{{ProductVariantId3}}', this.GetIdValueFromVariableStorage(6));
        Response.Content.WriteFrom(ResultTxt);
        this.OutboundHttpRequests.DequeueText();
    end;

    local procedure GetIdValueFromVariableStorage(Index: Integer): Text
    var
        IdValue: Variant;
    begin
        this.LibraryVariableStorage.Peek(IdValue, Index);
        exit(Format(IdValue));
    end;

    local procedure CreateMarketCatalog(var Catalog: Record "Shpfy Catalog"; Shop: Record "Shpfy Shop")
    var
        ShpfyCatalogInitialize: Codeunit "Shpfy Catalog Initialize";
    begin
        Catalog := ShpfyCatalogInitialize.CreateCatalog(Catalog."Catalog Type"::Market);
        Catalog."Shop Code" := Shop.Code;
        Catalog."Sync Prices" := true;
        Catalog.Modify(false);
    end;

    local procedure CreateProductsWithVariants(Shop: Record "Shpfy Shop")
    var
        ShpfyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        i: Integer;
    begin
        for i := 1 to 3 do begin
            ShpfyVariant := ProductInitTest.CreateStandardProduct(Shop);
            this.AssignItemToShpfyVariant(ShpfyVariant);
            this.LibraryVariableStorage.Enqueue(ShpfyVariant."Product Id");
            this.LibraryVariableStorage.Enqueue(ShpfyVariant."Id");
        end;
    end;

    local procedure AssignItemToShpfyVariant(var ShpfyVariant: Record "Shpfy Variant")
    var
        Item: Record Item;
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        if not Item.FindFirst() then
            LibraryInventory.CreateItem(Item);
        ShpfyVariant."Item SystemId" := Item.SystemId;
        ShpfyVariant.Modify(false);
    end;
}
