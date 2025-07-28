// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;

codeunit 139632 "Shpfy Create Item Variant Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestCreateVariantFromItem()
    var
        Item: Record Item;
        ParentItem: Record "Item";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        CreateItemAsVariantSub: Codeunit "Shpfy CreateItemAsVariantSub";
        ParentProductId: BigInteger;
        VariantId: BigInteger;
    begin
        // [SCENARIO] Create a variant from a given item
        Initialize();

        // [GIVEN] Parent Item
        ParentItem := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ParentProductId := CreateShopifyProduct(ParentItem.SystemId);
        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));

        // [WHEN] Invoke CreateItemAsVariant.CreateVariantFromItem
        BindSubscription(CreateItemAsVariantSub);
        CreateItemAsVariant.SetParentProduct(ParentProductId);
        CreateItemAsVariant.CheckProductAndShopSettings();
        CreateItemAsVariant.CreateVariantFromItem(Item);
        VariantId := CreateItemAsVariantSub.GetNewVariantId();
        UnbindSubscription(CreateItemAsVariantSub);

        // [THEN] Variant is created
        LibraryAssert.IsTrue(ShpfyVariant.Get(VariantId), 'Variant not created');
        LibraryAssert.AreEqual(Item."No.", ShpfyVariant.Title, 'Title not set');
        LibraryAssert.AreEqual(Item."No.", ShpfyVariant."Option 1 Value", 'Option 1 Value not set');
        LibraryAssert.AreEqual('Variant', ShpfyVariant."Option 1 Name", 'Option 1 Name not set');
        LibraryAssert.AreEqual(ParentProductId, ShpfyVariant."Product Id", 'Parent product not set');
        LibraryAssert.IsTrue(ShpfyProduct.Get(ParentProductId), 'Parent product not found');
        LibraryAssert.IsTrue(ShpfyProduct."Has Variants", 'Has Variants not set');
    end;

    [Test]
    procedure UnitTestCreateVariantFromItemWithNonDefaultOption()
    var
        Item: Record Item;
        ParentItem: Record "Item";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        CreateItemAsVariantSub: Codeunit "Shpfy CreateItemAsVariantSub";
        ParentProductId: BigInteger;
        VariantId: BigInteger;
        OptionName: Text;
    begin
        // [SCENARIO] Create a variant from a given item
        Initialize();

        // [GIVEN] Parent Item
        ParentItem := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ParentProductId := CreateShopifyProduct(ParentItem.SystemId);
        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Non default option for the product in Shopify
        OptionName := Any.AlphabeticText(10);
        CreateItemAsVariantSub.SetNonDefaultOption(OptionName);

        // [WHEN] Invoke CreateItemAsVariant.CreateVariantFromItem
        BindSubscription(CreateItemAsVariantSub);
        CreateItemAsVariant.SetParentProduct(ParentProductId);
        CreateItemAsVariant.CheckProductAndShopSettings();
        CreateItemAsVariant.CreateVariantFromItem(Item);
        VariantId := CreateItemAsVariantSub.GetNewVariantId();
        UnbindSubscription(CreateItemAsVariantSub);

        // [THEN] Variant is created
        LibraryAssert.IsTrue(ShpfyVariant.Get(VariantId), 'Variant not created');
        LibraryAssert.AreEqual(Item."No.", ShpfyVariant.Title, 'Title not set');
        LibraryAssert.AreEqual(Item."No.", ShpfyVariant."Option 1 Value", 'Option 1 Value not set');
        LibraryAssert.AreEqual(OptionName, ShpfyVariant."Option 1 Name", 'Option 1 Name not set');
        LibraryAssert.AreEqual(ParentProductId, ShpfyVariant."Product Id", 'Parent product not set');
        LibraryAssert.IsTrue(ShpfyProduct.Get(ParentProductId), 'Parent product not found');
        LibraryAssert.IsTrue(ShpfyProduct."Has Variants", 'Has Variants not set');
    end;

    [Test]
    procedure UnitTestGetProductOptions()
    var
        Item: Record "Item";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductAPI: Codeunit "Shpfy Product API";
        CreateItemAsVariantSub: Codeunit "Shpfy CreateItemAsVariantSub";
        ProductId: BigInteger;
        Options: Dictionary of [Text, Text];
    begin
        // [SCENARIO] Get product options for a given shopify product
        Initialize();

        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ProductId := Any.IntegerInRange(10000, 99999);

        // [WHEN] Invoke ProductAPI.GetProductOptions
        BindSubscription(CreateItemAsVariantSub);
        Options := ProductAPI.GetProductOptions(ProductId);
        UnbindSubscription(CreateItemAsVariantSub);

        // [THEN] Options are returned
        LibraryAssert.AreEqual(1, Options.Count(), 'Options not returned');
    end;

    [Test]
    procedure UnitTestCreateVariantFromProductWithMultipleOptions()
    var
        Item: Record "Item";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        CreateItemAsVariantSub: Codeunit "Shpfy CreateItemAsVariantSub";
        ProductId: BigInteger;
    begin
        // [SCENARIO] Create a variant from a product with multiple options
        Initialize();

        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ProductId := CreateShopifyProduct(Item.SystemId);

        // [GIVEN] Multiple options for the product in Shopify
        CreateItemAsVariantSub.SetMultipleOptions(true);

        // [WHEN] Invoke ProductAPI.CheckProductAndShopSettings
        BindSubscription(CreateItemAsVariantSub);
        CreateItemAsVariant.SetParentProduct(ProductId);
        asserterror CreateItemAsVariant.CheckProductAndShopSettings();
        UnbindSubscription(CreateItemAsVariantSub);

        // [THEN] Error is thrown
        LibraryAssert.ExpectedError('The product has more than one option. Items cannot be added as variants to a product with multiple options.');
    end;

    [Test]
    procedure UnitTestCreateVariantFromSameItem()
    var
        Item: Record "Item";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        CreateItemAsVariantSub: Codeunit "Shpfy CreateItemAsVariantSub";
        ParentProductId: BigInteger;
        VariantId: BigInteger;
    begin
        // [SCENARIO] Create a variant from a given item for the same item
        Initialize();

        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ParentProductId := CreateShopifyProduct(Item.SystemId);

        // [WHEN] Invoke CreateItemAsVariant.CreateVariantFromItem
        BindSubscription(CreateItemAsVariantSub);
        CreateItemAsVariant.SetParentProduct(ParentProductId);
        CreateItemAsVariant.CreateVariantFromItem(Item);
        VariantId := CreateItemAsVariantSub.GetNewVariantId();
        UnbindSubscription(CreateItemAsVariantSub);

        // [THEN] Variant is not created
        LibraryAssert.IsFalse(ShpfyVariant.Get(VariantId), 'Variant created');
    end;

    local procedure Initialize()
    begin
        Any.SetDefaultSeed();
        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
        Commit();
        IsInitialized := true;
    end;

    local procedure CreateShopifyProduct(SystemId: Guid): BigInteger
    var
        ShopifyProduct: Record "Shpfy Product";
    begin
        ShopifyProduct.Init();
        ShopifyProduct.Id := Any.IntegerInRange(10000, 99999);
        ShopifyProduct."Shop Code" := Shop."Code";
        ShopifyProduct."Item SystemId" := SystemId;
        ShopifyProduct.Insert(true);
        exit(ShopifyProduct."Id");
    end;
}
