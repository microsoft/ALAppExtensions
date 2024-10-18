/// <summary>
/// Codeunit Shpfy Sales Channel Test (ID 139581).        
/// </summary>
codeunit 139581 "Shpfy Sales Channel Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SalesChannelHelper: Codeunit "Shpfy Sales Channel Helper";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestImportSalesChannelTest()
    var
        SalesChannel: Record "Shpfy Sales Channel";
        SalesChannelAPI: Codeunit "Shpfy Sales Channel API";
        JPublications: JsonArray;
    begin
        // [SCENARIO] Importing sales channel from Shopify to Business Central.
        Initialize();

        // [GIVEN] Shopify response with sales channel data.
        JPublications := SalesChannelHelper.GetDefaultShopifySalesChannelResponse(Any.IntegerInRange(10000, 99999), Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoking the procedure: SalesChannelAPI.ProcessPublications(JPublications, Shop.Code)
        SalesChannelAPI.ProcessPublications(JPublications, Shop.Code);

        // [THEN] The sales channels are imported to Business Central.
        SalesChannel.SetRange("Shop Code", Shop.Code);
        LibraryAssert.IsFalse(SalesChannel.IsEmpty(), 'Sales Channel not created');
        LibraryAssert.AreEqual(2, SalesChannel.Count(), 'Sales Channel count is not equal to 2');
    end;

    [Test]
    procedure UnitTestRemoveNotExistingChannelsTest()
    var
        SalesChannel: Record "Shpfy Sales Channel";
        SalesChannelAPI: Codeunit "Shpfy Sales Channel API";
        JPublications: JsonArray;
        OnlineStoreId, POSId, AdditionalChannelId : BigInteger;
    begin
        // [SCENARIO] Removing not existing sales channels from Business Central.
        Initialize();

        // [GIVEN] Defult sales channels impported
        OnlineStoreId := Any.IntegerInRange(10000, 99999);
        POSId := Any.IntegerInRange(10000, 99999);
        CreateDefaultSalesChannels(OnlineStoreId, POSId);
        // [GIVEN] Additional sales channel
        AdditionalChannelId := Any.IntegerInRange(10000, 99999);
        CreateSalesChannel(Shop.Code, 'Additional Sales Channel', AdditionalChannelId);
        // [GIVEN] Shopify response with default sales channel data.
        JPublications := SalesChannelHelper.GetDefaultShopifySalesChannelResponse(OnlineStoreId, POSId);

        // [WHEN] Invoking the procedure: SalesChannelAPI.ProcessPublications(JPublications, Shop.Code) for empty json array.
        SalesChannelAPI.ProcessPublications(JPublications, Shop.Code);

        // [THEN] The additional sales channel is removed from Business Central.
        SalesChannel.SetRange("Shop Code", Shop.Code);
        SalesChannel.SetRange("Id", AdditionalChannelId);
        LibraryAssert.IsTrue(SalesChannel.IsEmpty(), 'Sales Channel not removed');
    end;

    [Test]
    procedure UnitTestPublishProductWitArchivedStatusTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
    begin
        // [SCENARIO] Publishing not active product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with archived status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Archived);

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        ShopifyProductAPI.PublishProduct(ShopifyProduct);

        // [THEN] Procedure exits without publishing the product.
    end;

    [Test]
    procedure UnitTestPublishProductWithDraftStatusTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
    begin
        // [SCENARIO] Publishing draft product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with draft status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Draft);
        // [GIVEN] Default sales channels.
        CreateDefaultSalesChannels(Any.IntegerInRange(10000, 99999), Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        ShopifyProductAPI.PublishProduct(ShopifyProduct);

        // [THEN] Procedure exits without publishing the product.
    end;

    [Test]
    procedure UnitTestPublishProductTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        OnlineShopId: BigInteger;
        ExpectedPublishQueryTok: Label '{"query":"mutation {publishablePublish(id: \"gid://shopify/Product/%1\" input: [{ publicationId: \"gid://shopify/Publication/%2\"}]){userErrors {field, message}}}"}', Locked = true;
        ActualQuery: Text;
    begin
        // [SCENARIO] Publishing active product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with active status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Active);
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        CreateDefaultSalesChannels(OnlineShopId, Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        BindSubscription(SalesChannelSubs);
        ShopifyProductAPI.PublishProduct(ShopifyProduct);
        ActualQuery := SalesChannelSubs.GetGraphQueryTxt();
        UnbindSubscription(SalesChannelSubs);

        // [THEN] Query for publishing the product is generated.
        LibraryAssert.AreEqual(StrSubstNo(ExpectedPublishQueryTok, ShopifyProduct.Id, OnlineShopId), ActualQuery, 'Wrong query for publishing the product is not generated');
    end;

    [Test]
    procedure UnitTestPublishProductToMultipleSalesChannelsTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        OnlineShopId, POSId : BigInteger;
        ExpectedPublishQueryTok: Label '{"query":"mutation {publishablePublish(id: \"gid://shopify/Product/%1\" input: [{ publicationId: \"gid://shopify/Publication/%2\"},{ publicationId: \"gid://shopify/Publication/%3\"}]){userErrors {field, message}}}"}', Locked = true;
        ActualQuery: Text;
    begin
        // [SCENARIO] Publishing active product to multiple Shopify Sales Channels.
        Initialize();

        // [GIVEN] Product with active status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Active);
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        POSId := OnlineShopId + 1;
        CreateDefaultSalesChannels(OnlineShopId, POSId);
        // [GIVEN] Online Shop used for publication
        SetPublicationForSalesChannel(OnlineShopId);
        // [GIVEN] POS used for publication
        SetPublicationForSalesChannel(POSId);

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        BindSubscription(SalesChannelSubs);
        ShopifyProductAPI.PublishProduct(ShopifyProduct);
        ActualQuery := SalesChannelSubs.GetGraphQueryTxt();
        UnbindSubscription(SalesChannelSubs);

        // [THEN] Query for publishing the product to multiple sales channels is generated.
        LibraryAssert.AreEqual(StrSubstNo(ExpectedPublishQueryTok, ShopifyProduct.Id, OnlineShopId, POSId), ActualQuery, 'Wrong query for publishing the product to multiple sales channels is not generated');
    end;



    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Any.SetDefaultSeed();
        Shop := ShpfyInitializeTest.CreateShop();
        IsInitialized := true;
        Commit();
    end;

    local procedure CreateSalesChannel(ShopCode: Code[20]; ChannelName: Text; ChannelId: BigInteger)
    var
        SalesChannel: Record "Shpfy Sales Channel";
    begin
        SalesChannel.Init();
        SalesChannel.Id := ChannelId;
        SalesChannel."Shop Code" := ShopCode;
        SalesChannel.Name := ChannelName;
        SalesChannel.Insert(true);
    end;

    local procedure CreateDefaultSalesChannels(OnlineStoreId: BigInteger; POSId: BigInteger)
    var
        SakesChannel: Record "Shpfy Sales Channel";
    begin
        SakesChannel.DeleteAll(false);
        CreateSalesChannel(Shop.Code, 'Online Store', OnlineStoreId);
        CreateSalesChannel(Shop.Code, 'Point of Sale', POSId);
    end;

    local procedure CreateProductWithStatus(var ShopifyProduct: Record "Shpfy Product"; ShpfyProductStatus: Enum Microsoft.Integration.Shopify."Shpfy Product Status")
    begin
        Any.SetDefaultSeed();
        ShopifyProduct.Init();
        ShopifyProduct.Id := Any.IntegerInRange(10000, 99999);
        ShopifyProduct."Shop Code" := Shop.Code;
        ShopifyProduct.Status := ShpfyProductStatus;
        ShopifyProduct.Insert(true);
    end;

    local procedure SetPublicationForSalesChannel(SalesChannelId: BigInteger)
    var
        SalesChannel: Record "Shpfy Sales Channel";
    begin
        SalesChannel.Get(SalesChannelId);
        SalesChannel."Use for publication" := true;
        SalesChannel.Modify(false);
    end;
}
