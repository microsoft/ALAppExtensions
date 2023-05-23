codeunit 139601 "Shpfy Create Product Test"
{
    Subtype = Test;
    TestPermissions = Disabled;


    var
        Any: codeunit Any;
        LibraryAssert: codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateTempProductFromItem()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2))
        else
            Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
#else
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
#endif
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShopifyProduct.Title = Item.Description');

        // [THEN] TempShopifyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

        // [THEN] TempShopifyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithItemAttributes()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU empty.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = " ", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::" ";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ''
                LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ''''');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNo()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item.No.
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item."No."
                LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item."No."');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code"
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''"
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = ''
        LibraryAssert.AreEqual('', TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ''''');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsItemNoVariantCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."No."
        LibraryAssert.AreEqual(Item."No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item No. + ShpfyShop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code
                LibraryAssert.AreEqual(Item."No." + Shop."SKU Field Separator" + ItemVariant.Code, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = Item No. + Shop."SKU Field Separator" + ItemVariant.Code');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNo()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsVendorItemNoAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
=======
        TempTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Item."Vendor Item No."
        LibraryAssert.AreEqual(Item."Vendor Item No.", TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = Item."Vendor Item No."');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithVariantsAndSKUIsVendorItemNo()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
<<<<<<< HEAD
        TempShofyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
=======
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No."
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShofyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShofyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShofyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = VendorItemNo');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = VendorItemNo');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = VendorItemNo');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        VendorItemNo: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Vendor Item No.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.", "Sync Item Extended Text" = true, "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = VendorItemNo');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = VendorItemNo
                VendorItemNo := ItemReferenceMgt.GetItemReference(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure", "Item Reference Type"::Vendor, Item."Vendor No.");
                LibraryAssert.AreEqual(VendorItemNo, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = VendorItemNo');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCode()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndExtendedText()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() must contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');
    end;

    [Test]
    procedure UnitTestCreateTempProductFromItemWithSKUIsBarCodeAndExtendedTextAndItemAttributes()
    var
        Item: Record Item;
        TempShopifyProduct: Record "Shpfy Product" temporary;
        Shop: Record "Shpfy Shop";
<<<<<<< HEAD
        TempShfyVariant: Record "Shpfy Variant" temporary;
=======
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with no variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true;
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2));
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShfyVariant);

        // [THEN] TempShpfyProduct.Title = Item.Description
        LibraryAssert.AreEqual(Item.Description, TempShopifyProduct.Title, 'TempShpfyProduct.Title = Item.Description');

        // [THEN] TempShpfyVariant.SKU = Bar Code
        BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", '', Item."Sales Unit of Measure");
        LibraryAssert.AreEqual(BarCode, TempShfyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

        // [THEN] TempShpfyVariant.Price = Item.Price
        LibraryAssert.AreEqual(Item."Unit Price", TempShfyVariant.Price, 'TempShpfyVariant.Price := Item.Price');

        // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
        LibraryAssert.AreEqual(Item."Unit Cost", TempShfyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
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
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code"
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Don't copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := false;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Don't copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := false;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() cannot contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsFalse(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

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
<<<<<<< HEAD
=======
        TempTag: Record "Shpfy Tag" temporary;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        CreateProduct: Codeunit "Shpfy Create Product";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ItemReferenceMgt: Codeunit "Shpfy Item Reference Mgt.";
<<<<<<< HEAD
=======
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        ItemTemplateCode: Code[20];
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        BarCode: Text;
    begin
        // [SCENARIO] Create a Item with variants from a Shopify Product with the SKU mapped to Bar Code.
        // [SCENARIO] Copy the extended text of the item.
        // [SCENARIO] Copy the item attributtes.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code", "Sync Item Extended Text" = true, "Sync Item Attributes" = true
        Shop := InitializeTest.CreateShop();
<<<<<<< HEAD
        Shop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
=======
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        Shop."Sync Item Extended Text" := true;
        Shop."Sync Item Attributes" := true;
        Shop.Modify();
        CreateProduct.SetShop(Shop);

        // [GIVEN] a Item record
<<<<<<< HEAD
        Item := ProductInitTest.CreateItem(Shop."Item Template Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke ShpfyCreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateProduct(Item, TempShopifyProduct, TempShopifyVariant);

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShpfyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShpfyVariant records;
=======
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            ItemTemplateCode := Shop."Item Template Code"
        else
            ItemTemplateCode := Shop."Item Templ. Code";
#else
        ItemTemplateCode := Shop."Item Templ. Code";
#endif
        Item := ProductInitTest.CreateItem(ItemTemplateCode, Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 1000, 2), true);
        Item.SetRecFilter();

        // [WHEN] Invoke CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant)
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempTag);

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productDescription">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productDescription">'), '<div class="productDescription">');

        // [THEN] TempShopifyProduct.GetDescriptionHtml() contains the HTML section '<div class="productAttributes">'
        LibraryAssert.IsTrue(TempShopifyProduct.GetDescriptionHtml().Contains('<div class="productAttributes">'), '<div class="productAttributes">');

        // [THEN] There are TempShopifyVariant records;
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2
        LibraryAssert.RecordIsNotEmpty(TempShopifyVariant);

        if TempShopifyVariant.FindSet(false, false) then
            repeat
<<<<<<< HEAD
                // [THEN] There is a Item Variant record linked to the TempShpfyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShpfyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShpfyVariant.SKU = BarCode');

                // [THEN] TempShpfyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShpfyVariant.Title = ItemVariant.Description');

                // [THEN] TempShpfyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShpfyVariant.Price := Item.Price');
=======
                // [THEN] There is a Item Variant record linked to the TempShopifyVariant record.
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(TempShopifyVariant."Item Variant SystemId"), 'Item Variant Record is found.');

                // [THEN] TempShopifyVariant.SKU = BarCode
                BarCode := ItemReferenceMgt.GetItemBarcode(Item."No.", ItemVariant.Code, Item."Sales Unit of Measure");
                LibraryAssert.AreEqual(BarCode, TempShopifyVariant.SKU, 'TempShopifyVariant.SKU = BarCode');

                // [THEN] TempShopifyVariant.Title = ItemVariant.Description
                LibraryAssert.AreEqual(ItemVariant.Description, TempShopifyVariant.Title, 'TempShopifyVariant.Title = ItemVariant.Description');

                // [THEN] TempShopifyVariant.Price = Item.Price
                LibraryAssert.AreEqual(Item."Unit Price", TempShopifyVariant.Price, 'TempShopifyVariant.Price := Item.Price');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

                // [THEN] TempShpyVariant."Unit Cost" = Item."Unit Cost";
                LibraryAssert.AreEqual(Item."Unit Cost", TempShopifyVariant."Unit Cost", 'TempShpyVariant."Unit Cost" = Item."Unit Cost"');

<<<<<<< HEAD
                // [THEN] TempShpfyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShpfyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShpfyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShpfyVariant."Option 1 Value" = ItemVariant.Code');
=======
                // [THEN] TempShopifyVariant."Option 1 Name" = 'Variant'
                LibraryAssert.AreEqual('Variant', TempShopifyVariant."Option 1 Name", 'TempShopifyVariant."Option 1 Name" = ''Variant''');

                // [THEN] TempShopifyVariant."Option 1 Value" = ItemVariant.Code
                LibraryAssert.AreEqual(ItemVariant.Code, TempShopifyVariant."Option 1 Value", 'TempShopifyVariant."Option 1 Value" = ItemVariant.Code');
>>>>>>> 7d2dcc7d383d53737ef62941c8139e946afb8fb2

            until TempShopifyVariant.Next() = 0;
    end;
}