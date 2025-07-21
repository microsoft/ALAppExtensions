codeunit 139544 "Shpfy Create Item API Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    TestHttpRequestPolicy = BlockOutboundRequests;
    EventSubscriberInstance = Manual;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        OutboundHttpRequests: Codeunit "Library - Variable Storage";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        ShopifyShop: Codeunit "Library - Variable Storage";
        ShpfyCreateItemAPITest: Codeunit "Shpfy Create Item API Test";
        IsInitialized: Boolean;
        CreateItemErr: Label 'Item not created', Locked = true;
        UnexpectedAPICallsErr: Label 'More than expected API calls to Shopify detected.';
        ShopifyShopUrlTok: Label 'admin\/api\/.+\/graphql.json', Locked = true;

    trigger OnRun()
    begin
        this.IsInitialized := false;
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler_GetProducts')]
    procedure UnitTestErrorClearOnSuccessfulItemCreation()
    var
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyCreateItem: Codeunit "Shpfy Create Item";
        EmptyGuid: Guid;
    begin
        this.Initialize();

        // [SCENARIO] Clear error on Shopify Product when Item from a Shopify Product creation is successful.

        // [GIVEN] Register Expected Outbound API Requests.
        this.RegExpectedOutboundHttpRequestsForGetProducts();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        Shop.Get(this.ShopifyShop.PeekText(1));
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);

        // [GIVEN] A Shopify product record has error logged.
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        ShopifyProduct."Has Error" := true;
        ShopifyProduct."Error Message" := this.CreateItemErr;
        ShopifyProduct.Modify(false);

        // [WHEN] Invoke ShpfyCreateItem.CreateItemFromShopifyProduct to create items from Shopify product.
        ShpfyCreateItem.CreateItemFromShopifyProduct(ShopifyProduct);

        // [THEN] On the "Shpfy Product" record, the field "Item SystemId" must be filled.
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        this.LibraryAssert.AreNotEqual(ShopifyProduct."Item SystemId", EmptyGuid, '"Item SystemId" value must not be empty');

        // [THEN] On the "Shpfy Product" record, the field "Has Error" must have value false.
        this.LibraryAssert.IsFalse(ShopifyProduct."Has Error", '"Has Error" value must be false');

        // [THEN] On the "Shpfy Product" record, the field "Error Message" must be empty.
        this.LibraryAssert.AreEqual(ShopifyProduct."Error Message", '', '"Error Message" value must be empty');
    end;

    [Test]
    [HandlerFunctions('HttpSubmitHandler_GetProducts')]
    procedure UnitTestLogErrorOnUnsuccessfulItemCreation()
    var
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyCreateItem: Codeunit "Shpfy Create Item";
        EmptyGuid: Guid;
    begin
        this.Initialize();

        // [SCENARIO] Inserts error on Shopify Product when Item from a Shopify Product creation is unsuccessful.

        // [GIVEN] Register Expected Outbound API Requests.
        this.RegExpectedOutboundHttpRequestsForGetProducts();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        Shop.Get(this.ShopifyShop.PeekText(1));
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);

        // [WHEN] Invoke ShpfyCreateItem.CreateItemFromShopifyProduct to unsuccessfully create item from Shopify product.
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        BindSubscription(this.ShpfyCreateItemAPITest);
        ShpfyCreateItem.CreateItemFromShopifyProduct(ShopifyProduct);
        UnbindSubscription(this.ShpfyCreateItemAPITest);

        // [THEN] On the "Shpfy Product" record, the field "Item SystemId" must be empty.
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        this.LibraryAssert.AreEqual(ShopifyProduct."Item SystemId", EmptyGuid, '"Item SystemId" value must be empty');

        // [THEN] On the "Shpfy Product" record, the field "Has Error" must have value true.
        this.LibraryAssert.IsTrue(ShopifyProduct."Has Error", '"Has Error" value must be true');

        // [THEN] On the "Shpfy Product" record, the field "Error Message" must be filled.
        this.LibraryAssert.IsTrue(ShopifyProduct."Error Message".contains(this.CreateItemErr), '"Error Message" must contain error text');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Shpfy Product Events", OnBeforeCreateItem, '', true, false)]
    local procedure OnBeforeCreateItem()
    begin
        Error(this.CreateItemErr);
    end;

    [HttpClientHandler]
    internal procedure HttpSubmitHandler_GetProducts(Request: TestHttpRequestMessage; var Response: TestHttpResponseMessage): Boolean
    var
        Regex: Codeunit Regex;
        ProductsResponse1Tok: Label 'Products/Products1.txt', Locked = true;
        ProductsResponse2Tok: Label 'Products/Products2.txt', Locked = true;
        ProductsResponse3Tok: Label 'Products/Products3.txt', Locked = true;
    begin
        if not Regex.IsMatch(Request.Path, this.ShopifyShopUrlTok) then
            exit(true);

        case this.OutboundHttpRequests.Length() of
            3:
                this.LoadResourceIntoHttpResponse(ProductsResponse1Tok, Response);
            2:
                this.LoadResourceIntoHttpResponse(ProductsResponse2Tok, Response);
            1:
                this.LoadResourceIntoHttpResponse(ProductsResponse3Tok, Response);
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
        this.LibraryTestInitialize.OnTestInitialize(Codeunit::"Shpfy Create Item API Test");
        ClearLastError();
        this.OutboundHttpRequests.Clear();
        this.LibraryVariableStorage.Clear();
        if this.IsInitialized then
            exit;

        this.LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Shpfy Create Item API Test");

        this.LibraryRandom.Init();

        this.IsInitialized := true;
        Commit();

        // Creating Shopify Shop
        Shop := InitializeTest.CreateShop();
        Shop."Auto Create Unknown Items" := true;
        Shop.modify(false);

        this.ShopifyShop.Enqueue(Shop.Code);
        // Disable Event Mocking 
        CommunicationMgt.SetTestInProgress(false);
        //Register Shopify Access Token
        AccessToken := this.LibraryRandom.RandText(20);
        InitializeTest.RegisterAccessTokenForShop(Shop.GetStoreName(), AccessToken);

        this.LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Shpfy Create Item API Test");
    end;

    local procedure RegExpectedOutboundHttpRequestsForGetProducts()
    begin
        this.OutboundHttpRequests.Enqueue('GQL Get Products 1');
        this.OutboundHttpRequests.Enqueue('GQL Get Products 2');
        this.OutboundHttpRequests.Enqueue('GQL Get Products 3');
    end;

    local procedure LoadResourceIntoHttpResponse(ResourceText: Text; var Response: TestHttpResponseMessage)
    begin
        Response.Content.WriteFrom(NavApp.GetResourceAsText(ResourceText, TextEncoding::UTF8));
        this.OutboundHttpRequests.DequeueText();
    end;
}
