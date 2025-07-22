// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.Integration.Shopify.Test;

using Microsoft.Integration.Shopify;
using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using Microsoft.Inventory.Item.Catalog;

codeunit 139601 "Shpfy Create Product Test"
{
    Subtype = Test;
    TestType = IntegrationTest;
    TestPermissions = Disabled;


    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateTempProductFromItem()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithItemAttributes()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNo()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item.No.
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNo()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code"
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''"
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVariantCodeAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoVariantCodeAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsItemNoVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNo()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemTemplateCode: Code[20];
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVendorItemNo()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No."
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVendorItemNoAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVendorItemNoAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVendorItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsBarCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code"
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsBarCodeAndExtendedText()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsBarCodeAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsBarCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
        ItemTemplateCode: Code[20];
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
        ItemTemplateCode := Shop."Item Templ. Code";
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false) then
            repeat
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');

            until TempShopifyVariant.Next() = 0;
    end;
}
