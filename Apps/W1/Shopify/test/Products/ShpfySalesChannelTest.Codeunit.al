// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;

codeunit 139698 "Shpfy Sales Channel Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
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
        JPublications: JsonArray;
    begin
        // [SCENARIO] Importing sales channel from Shopify to Business Central.
        Initialize();

        // [GIVEN] Shopify response with sales channel data.
        JPublications := SalesChannelHelper.GetDefaultShopifySalesChannelResponse(Any.IntegerInRange(10000, 99999), Any.IntegerInRange(10000, 99999));

        // [WHEN] Invoking the procedure: SalesChannelAPI.RetrieveSalesChannelsFromShopify
        InvokeRetrieveSalesChannelsFromShopify(JPublications);

        // [THEN] The sales channels are imported to Business Central.
        SalesChannel.SetRange("Shop Code", Shop.Code);
        LibraryAssert.IsFalse(SalesChannel.IsEmpty(), 'Sales Channel not created');
        LibraryAssert.AreEqual(2, SalesChannel.Count(), 'Sales Channel count is not equal to 2');
        SalesChannel.SetRange("Default", true);
        LibraryAssert.IsFalse(SalesChannel.IsEmpty(), 'Default Sales Channel not created');
    end;

    [Test]
    procedure UnitTestRemoveNotExistingChannelsTest()
    var
        SalesChannel: Record "Shpfy Sales Channel";
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
        CreateSalesChannel(Shop.Code, 'Additional Sales Channel', AdditionalChannelId, false);
        // [GIVEN] Shopify response with default sales channel data.
        JPublications := SalesChannelHelper.GetDefaultShopifySalesChannelResponse(OnlineStoreId, POSId);

        // [WHEN] Invoking the procedure: SalesChannelAPI.InvokeRetreiveSalesChannelsFromShopify
        InvokeRetrieveSalesChannelsFromShopify(JPublications);

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
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        GraphQueryTxt: Text;
        OnlineShopId, POSId : BigInteger;
        ProductLbl: Label 'id: \"gid://shopify/Product/%1\"', Comment = '%1 - Product Id', Locked = true;
        PublicationLbl: Label 'publicationId: \"gid://shopify/Publication/%1\"', Comment = '%1 - Publication Id', Locked = true;
    begin
        // [SCENARIO] Publishing not active product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with archived status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Archived, Any.IntegerInRange(10000, 99999));
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        POSId := OnlineShopId + 1;
        CreateDefaultSalesChannels(OnlineShopId, POSId);

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        BindSubscription(SalesChannelSubs);
        ShopifyProductAPI.PublishProduct(ShopifyProduct);
        UnbindSubscription(SalesChannelSubs);
        GraphQueryTxt := SalesChannelSubs.GetGraphQueryTxt();

        // [THEN] Query for publishing the product is generated.
        LibraryAssert.IsTrue(GraphQueryTxt.Contains(StrSubstNo(ProductLbl, ShopifyProduct.Id)), 'Product Id is not in the query');
        LibraryAssert.IsTrue(GraphQueryTxt.Contains(StrSubstNo(PublicationLbl, OnlineShopId)), 'Publication Id for Online Shop is not in the query');
    end;

    [Test]
    procedure UnitTestPublishProductWithDraftStatusTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        GraphQueryTxt: Text;
        OnlineShopId, POSId : BigInteger;
        ProductLbl: Label 'id: \"gid://shopify/Product/%1\"', Comment = '%1 - Product Id', Locked = true;
        PublicationLbl: Label 'publicationId: \"gid://shopify/Publication/%1\"', Comment = '%1 - Publication Id', Locked = true;
    begin
        // [SCENARIO] Publishing draft product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with draft status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Draft, Any.IntegerInRange(10000, 99999));
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        POSId := OnlineShopId + 1;
        CreateDefaultSalesChannels(OnlineShopId, POSId);

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        BindSubscription(SalesChannelSubs);
        ShopifyProductAPI.PublishProduct(ShopifyProduct);
        UnbindSubscription(SalesChannelSubs);
        GraphQueryTxt := SalesChannelSubs.GetGraphQueryTxt();

        // [THEN] Query for publishing the product is generated.
        LibraryAssert.IsTrue(GraphQueryTxt.Contains(StrSubstNo(ProductLbl, ShopifyProduct.Id)), 'Product Id is not in the query');
        LibraryAssert.IsTrue(GraphQueryTxt.Contains(StrSubstNo(PublicationLbl, OnlineShopId)), 'Publication Id for Online Shop is not in the query');
    end;

    [Test]
    procedure UnitTestPublishProductToDefaultSalesChannelTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        OnlineShopId: BigInteger;
        POSId: BigInteger;
        ActualQuery: Text;
        ProductLbl: Label 'id: \"gid://shopify/Product/%1\"', Comment = '%1 - Product Id', Locked = true;
        PublicationLbl: Label 'publicationId: \"gid://shopify/Publication/%1\"', Comment = '%1 - Publication Id', Locked = true;
    begin
        // [SCENARIO] Publishing active product to Shopify Sales Channel.
        Initialize();

        // [GIVEN] Product with active status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Active, Any.IntegerInRange(10000, 99999));
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        POSId := OnlineShopId + 1;
        CreateDefaultSalesChannels(OnlineShopId, POSId);

        // [WHEN] Invoking the procedure: ShopifyProductAPI.PublishProduct(ShopifyProduct)
        BindSubscription(SalesChannelSubs);
        ShopifyProductAPI.PublishProduct(ShopifyProduct);
        ActualQuery := SalesChannelSubs.GetGraphQueryTxt();
        UnbindSubscription(SalesChannelSubs);

        // [THEN] Query for publishing the product is generated.
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(ProductLbl, ShopifyProduct.Id)), 'Product Id is not in the query');
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(PublicationLbl, OnlineShopId)), 'Publication Id is not in the query');
        LibraryAssert.IsFalse(ActualQuery.Contains(StrSubstNo(PublicationLbl, POSId)), 'Publication Id for POS is in the query');
    end;

    [Test]
    procedure UnitTestPublishProductToMultipleSalesChannelsTest()
    var
        ShopifyProduct: Record "Shpfy Product";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        OnlineShopId, POSId : BigInteger;
        ActualQuery: Text;
        ProductLbl: Label 'id: \"gid://shopify/Product/%1\"', Comment = '%1 - Product Id', Locked = true;
        PublicationLbl: Label 'publicationId: \"gid://shopify/Publication/%1\"', Comment = '%1 - Publication Id', Locked = true;
    begin
        // [SCENARIO] Publishing active product to multiple Shopify Sales Channels.
        Initialize();

        // [GIVEN] Product with active status.
        CreateProductWithStatus(ShopifyProduct, Enum::"Shpfy Product Status"::Active, Any.IntegerInRange(10000, 99999));
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
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(ProductLbl, ShopifyProduct.Id)), 'Product Id is not in the query');
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(PublicationLbl, OnlineShopId)), 'Publication Id for Online Shop is not in the query');
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(PublicationLbl, POSId)), 'Publication Id for POS is not in the query');
    end;

    [Test]
    procedure UnitTestPublishProductOnCreateProductTest()
    var
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        ShopifyTag: Record "Shpfy Tag";
        ShopifyProductAPI: Codeunit "Shpfy Product API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
        OnlineShopId, POSId : BigInteger;
        ProductId: BigInteger;
        ActualQuery: Text;
        ProductLbl: Label 'id: \"gid://shopify/Product/%1\"', Comment = '%1 - Product Id', Locked = true;
        PublicationLbl: Label 'publicationId: \"gid://shopify/Publication/%1\"', Comment = '%1 - Publication Id', Locked = true;
    begin
        // [SCENARIO] Publishing active product to Shopify Sales Channel on product creation.
        Initialize();

        // [GIVEN] Product with active status.
        CreateProductWithStatus(TempShopifyProduct, Enum::"Shpfy Product Status"::Active, 0);
        // [GIVEN] Shopify Variant
        CreateShopifyVariant(TempShopifyProduct, TempShopifyVariant, 0);
        // [GIVEN] Default sales channels.
        OnlineShopId := Any.IntegerInRange(10000, 99999);
        POSId := OnlineShopId + 1;
        CreateDefaultSalesChannels(OnlineShopId, POSId);

        // [WHEN] Invoke Product API
        BindSubscription(SalesChannelSubs);
        ProductId := ShopifyProductAPI.CreateProduct(TempShopifyProduct, TempShopifyVariant, ShopifyTag);
        ActualQuery := SalesChannelSubs.GetGraphQueryTxt();
        UnbindSubscription(SalesChannelSubs);

        // [THEN] Query for publishing the product is generated.
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(ProductLbl, ProductId)), 'Product Id is not in the query');
        LibraryAssert.IsTrue(ActualQuery.Contains(StrSubstNo(PublicationLbl, OnlineShopId)), 'Publication Id for Online Shop is not in the query');
    end;

    local procedure Initialize()
    begin
        Any.SetDefaultSeed();
        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
        IsInitialized := true;
        Commit();
    end;

    local procedure CreateSalesChannel(ShopCode: Code[20]; ChannelName: Text[100]; ChannelId: BigInteger; IsDefault: Boolean)
    var
        SalesChannel: Record "Shpfy Sales Channel";
    begin
        SalesChannel.Init();
        SalesChannel.Id := ChannelId;
        SalesChannel."Shop Code" := ShopCode;
        SalesChannel.Name := ChannelName;
        SalesChannel.Default := IsDefault;
        SalesChannel.Insert(true);
    end;

    local procedure CreateDefaultSalesChannels(OnlineStoreId: BigInteger; POSId: BigInteger)
    var
        SalesChannel: Record "Shpfy Sales Channel";
    begin
        SalesChannel.DeleteAll(false);
        CreateSalesChannel(Shop.Code, 'Online Store', OnlineStoreId, true);
        CreateSalesChannel(Shop.Code, 'Point of Sale', POSId, false);
    end;

    local procedure CreateProductWithStatus(var ShopifyProduct: Record "Shpfy Product"; ShpfyProductStatus: Enum Microsoft.Integration.Shopify."Shpfy Product Status"; Id: BigInteger)
    begin
        ShopifyProduct.Init();
        ShopifyProduct.Id := Id;
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

    local procedure CreateShopifyVariant(ShopifyProduct: Record "Shpfy Product"; var ShpfyVariant: Record "Shpfy Variant"; Id: BigInteger)
    begin
        ShpfyVariant.Init();
        ShpfyVariant.Id := Id;
        ShpfyVariant."Product Id" := ShopifyProduct.Id;
        ShpfyVariant.Insert(false);
    end;

    local procedure InvokeRetrieveSalesChannelsFromShopify(var JPublications: JsonArray)
    var
        SalesChannelAPI: Codeunit "Shpfy Sales Channel API";
        SalesChannelSubs: Codeunit "Shpfy Sales Channel Subs.";
    begin
        BindSubscription(SalesChannelSubs);
        SalesChannelSubs.SetJEdges(JPublications);
        SalesChannelAPI.RetrieveSalesChannelsFromShopify(Shop.Code);
        UnbindSubscription(SalesChannelSubs);
    end;
}
