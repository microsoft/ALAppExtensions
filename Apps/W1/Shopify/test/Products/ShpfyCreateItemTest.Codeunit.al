/// <summary>
/// Codeunit Shpfy Create Item Test (ID 139567).
/// </summary>
codeunit 139567 "Shpfy Create Item Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: codeunit "Library Assert";

    [Test]
    procedure UnitTestCreateItemSKUIsItemNo()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be field in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" must be a null guid value.
        LibraryAssert.IsTrue(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id = NullGuid');

        // [THEN] Check Item fields
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper(), Item."No.", 'Item."No." = SKU');
        LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoFromProductWithMultiVariants()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Items from a Shopify Product with multi variants and the SKU value containing the Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No.";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithMultiVariants(Shop);

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShopifyVariant.SetRange("Product Id", ShopifyVariant."Product Id");
        if ShopifyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be field in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" must be a null guid value.
                LibraryAssert.IsTrue(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id = NullGuid');

                // [THEN] Check Item fields
                ShopifyProduct.Get(ShopifyVariant."Product Id");
                LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper(), Item."No.", 'Item."No." = SKU');
                LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');
            until ShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoAndVaraintCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No and Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithVariantCode(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
        LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId"), 'Get Item Variant');

        // [THEN] Check Item fields
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper().Split(Shop."SKU Field Separator").Get(1), Item."No.", 'Item."No." = SKU.Spilt(Shop."SKU Field Separator")[1]');
        LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] The 'Item Varaint".Code must be equal to the variant part of the SKU.
        LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper().Split(Shop."SKU Field Separator").Get(2), ItemVariant.Code, '"Item Variant".Code." = SKU.Spilt(Shop."SKU Field Separator")[2]');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoAndVaraintCodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        FirstVariant: Boolean;
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No and Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Item No. + Variant Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithMultiVariants(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShopifyVariant.SetRange("Product Id", ShopifyVariant."Product Id");
        if ShopifyVariant.FindSet(false, false) then begin
            FirstVariant := true;
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId"), 'Get Item Variant');

                // [THEN] Check Item fields
                ShopifyProduct.Get(ShopifyVariant."Product Id");
                LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper().Split(Shop."SKU Field Separator").Get(1), Item."No.", 'Item."No." = SKU.Spilt(Shop."SKU Field Separator")[1]');
                LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                if FirstVariant then begin
                    LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                    LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');
                end;

                // [THEN] The 'Item Varaint".Code must be equal to the variant part of the SKU.
                LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper().Split(Shop."SKU Field Separator").Get(2), ItemVariant.Code, '"Item Variant".Code." = SKU.Spilt(Shop."SKU Field Separator")[2]');
            until ShopifyVariant.Next() = 0;
        end;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVaraintCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithVariantCode(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
        LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId"), 'Get Item Variant');

        // [THEN] Check Item fields
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] The 'Item Varaint".Code must be equal to the SKU.
        LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper(), ItemVariant.Code, '"Item Variant".Code" = SKU');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVaraintCodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Variant Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithMultiVariants(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShopifyVariant.SetRange("Product Id", ShopifyVariant."Product Id");
        if ShopifyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShopifyVariant."Item Variant SystemId"), 'Get Item Variant');

                // [THEN] Check Item fields
                ShopifyProduct.Get(ShopifyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');

                // [THEN] The 'Item Varaint".Code must be equal to the SKU.
                LibraryAssert.AreEqual(ShopifyVariant.SKU.ToUpper(), ItemVariant.Code, '"Item Variant".Code" = SKU');
            until ShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVendorItemNo()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        Shop: Record "Shpfy Shop";
        ShopifyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Vendor Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

        // [THEN] Check Item fields
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] Check Vendor Item Reference exsist
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", Item."Vendor No.");
        ItemReference.SetRange("Reference No.", ShopifyVariant.SKU);
        LibraryAssert.RecordIsNotEmpty(ItemReference);
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVendorItemFromProductWithMultiVariants()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Vendor Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Vendor Item No.";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithMultiVariants(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShopifyVariant.SetRange("Product Id", ShopifyVariant."Product Id");
        if ShopifyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

                // [THEN] Check Item fields
                ShopifyProduct.Get(ShopifyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

                // [THEN] Check Vendor Item Reference exsist
                ItemReference.SetRange("Item No.", Item."No.");
                ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
                ItemReference.SetRange("Reference Type No.", Item."Vendor No.");
                ItemReference.SetRange("Reference No.", ShopifyVariant.SKU);
                LibraryAssert.RecordIsNotEmpty(ItemReference);
            until ShopifyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsBarcode()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        Shop: Record "Shpfy Shop";
        ShopifyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Bar Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateStandardProduct(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

        // [THEN] Check Item fields
        ShopifyProduct.Get(ShopifyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] Check Vendor Item Reference exsist
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference Type No.", '');
        ItemReference.SetRange("Reference No.", ShopifyVariant.SKU);
        LibraryAssert.RecordIsNotEmpty(ItemReference);
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsBarcodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        Shop: Record "Shpfy Shop";
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        InitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Bar Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        Shop := InitializeTest.CreateShop();
        Shop."SKU Mapping" := "Shpfy SKU Mapping"::"Bar Code";
        Shop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShopifyVariant := ProductInitTest.CreateProductWithMultiVariants(Shop);
        ShopifyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShopifyVariant.SetRange("Product Id", ShopifyVariant."Product Id");
        if ShopifyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShopifyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShopifyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShopifyVariant."Item SystemId"), 'Get Item');

                // [THEN] Check Item fields
                ShopifyProduct.Get(ShopifyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShopifyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShopifyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShopifyVariant.Price, Item."Unit Price", 'Unit Price');

                // [THEN] Check Vendor Item Reference exsist
                ItemReference.SetRange("Item No.", Item."No.");
                ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
                ItemReference.SetRange("Reference Type No.", '');
                ItemReference.SetRange("Reference No.", ShopifyVariant.SKU);
                LibraryAssert.RecordIsNotEmpty(ItemReference);
            until ShopifyVariant.Next() = 0;
    end;
}