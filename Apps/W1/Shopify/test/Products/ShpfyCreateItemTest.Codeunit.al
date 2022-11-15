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
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";

    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be field in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" must be a null guid value.
        LibraryAssert.IsTrue(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id = NullGuid');

        // [THEN] Check Item fields
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper(), Item."No.", 'Item."No." = SKU');
        LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoFromProductWithMultiVariants()
    var
        Item: Record Item;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";

    begin
        // [SCENARIO] Create a Items from a Shopify Product with multi variants and the SKU value containing the Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No.";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithMultiVariants(ShpfyShop);

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShpfyVariant.SetRange("Product Id", ShpfyVariant."Product Id");
        if ShpfyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be field in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" must be a null guid value.
                LibraryAssert.IsTrue(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id = NullGuid');

                // [THEN] Check Item fields
                ShpfyProduct.Get(ShpfyVariant."Product Id");
                LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper(), Item."No.", 'Item."No." = SKU');
                LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');
            until ShpfyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoAndVaraintCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";

    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No and Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithVariantCode(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
        LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShpfyVariant."Item Variant SystemId"), 'Get Item Variant');

        // [THEN] Check Item fields
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper().Split(ShpfyShop."SKU Field Separator").Get(1), Item."No.", 'Item."No." = SKU.Spilt(Shop."SKU Field Separator")[1]');
        LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] The 'Item Varaint".Code must be equal to the variant part of the SKU.
        LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper().Split(ShpfyShop."SKU Field Separator").Get(2), ItemVariant.Code, '"Item Variant".Code." = SKU.Spilt(Shop."SKU Field Separator")[2]');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsItemNoAndVaraintCodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        FirstVariant: Boolean;
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Item No and Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Item No. + Variant Code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithMultiVariants(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShpfyVariant.SetRange("Product Id", ShpfyVariant."Product Id");
        if ShpfyVariant.FindSet(false, false) then begin
            FirstVariant := true;
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShpfyVariant."Item Variant SystemId"), 'Get Item Variant');

                // [THEN] Check Item fields
                ShpfyProduct.Get(ShpfyVariant."Product Id");
                LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper().Split(ShpfyShop."SKU Field Separator").Get(1), Item."No.", 'Item."No." = SKU.Spilt(Shop."SKU Field Separator")[1]');
                LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                if FirstVariant then begin
                    LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                    LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');
                end;

                // [THEN] The 'Item Varaint".Code must be equal to the variant part of the SKU.
                LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper().Split(ShpfyShop."SKU Field Separator").Get(2), ItemVariant.Code, '"Item Variant".Code." = SKU.Spilt(Shop."SKU Field Separator")[2]');
            until ShpfyVariant.Next() = 0;
        end;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVaraintCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";

    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithVariantCode(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

        // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
        LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShpfyVariant."Item Variant SystemId"), 'Get Item Variant');

        // [THEN] Check Item fields
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] The 'Item Varaint".Code must be equal to the SKU.
        LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper(), ItemVariant.Code, '"Item Variant".Code" = SKU');
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVaraintCodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Variant Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Variant Code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithMultiVariants(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShpfyVariant.SetRange("Product Id", ShpfyVariant."Product Id");
        if ShpfyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

                // [THEN] On the "Shpfy Variant" record, the field "ITem Varaint SystemId" filled in and then "Item Variant" record must exist..
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item Variant SystemId"), 'Item Variant System Id <> NullGuid');
                LibraryAssert.IsTrue(ItemVariant.GetBySystemId(ShpfyVariant."Item Variant SystemId"), 'Get Item Variant');

                // [THEN] Check Item fields
                ShpfyProduct.Get(ShpfyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');

                // [THEN] The 'Item Varaint".Code must be equal to the SKU.
                LibraryAssert.AreEqual(ShpfyVariant.SKU.ToUpper(), ItemVariant.Code, '"Item Variant".Code" = SKU');
            until ShpfyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVendorItemNo()
    var
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Vendor Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

        // [THEN] Check Item fields
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] Check Vendor Item Reference exsist
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
        ItemReference.SetRange("Reference Type No.", Item."Vendor No.");
        ItemReference.SetRange("Reference No.", ShpfyVariant.SKU);
        LibraryAssert.RecordIsNotEmpty(ItemReference);
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsVendorItemFromProductWithMultiVariants()
    var
        Item: Record Item;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Vendor Item No.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Vendor Item No.";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithMultiVariants(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShpfyVariant.SetRange("Product Id", ShpfyVariant."Product Id");
        if ShpfyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

                // [THEN] Check Item fields
                ShpfyProduct.Get(ShpfyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

                // [THEN] Check Vendor Item Reference exsist
                ItemReference.SetRange("Item No.", Item."No.");
                ItemReference.SetRange("Reference Type", "Item Reference Type"::Vendor);
                ItemReference.SetRange("Reference Type No.", Item."Vendor No.");
                ItemReference.SetRange("Reference No.", ShpfyVariant.SKU);
                LibraryAssert.RecordIsNotEmpty(ItemReference);
            until ShpfyVariant.Next() = 0;
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsBarcode()
    var
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the Bar Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" with the "Shpfy Variant" Record.
        Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

        // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
        LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
        LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

        // [THEN] Check Item fields
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
        LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
        LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

        // [THEN] Check Vendor Item Reference exsist
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        ItemReference.SetRange("Reference Type No.", '');
        ItemReference.SetRange("Reference No.", ShpfyVariant.SKU);
        LibraryAssert.RecordIsNotEmpty(ItemReference);
    end;

    [Test]
    procedure UnitTestCreateItemSKUIsBarcodeFromProductWithMultiVariants()
    var
        Item: Record Item;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ItemReference: Record "Item Reference";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Create a Item from a Shopify Product with the SKU value containing the  Bar Code.

        // [GIVEN] The Shop with the setting "SKU Mapping" = "Bar Code";
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
        ShpfyShop.Modify();

        // [GIVEN] A Shopify variant record of a standard shopify product. (The variant record always exists, even if the products don't have any variants.)
        ShpfyVariant := ShpfyProductInitTest.CreateProductWithMultiVariants(ShpfyShop);
        ShpfyVariant.SetRecFilter();

        // [WHEN] Executing the report "Shpfy Create Item" for each record of the "Shpfy Variant" Records filtered on "Product Id".
        ShpfyVariant.SetRange("Product Id", ShpfyVariant."Product Id");
        if ShpfyVariant.FindSet(false, false) then
            repeat
                Codeunit.Run(Codeunit::"Shpfy Create Item", ShpfyVariant);

                // [THEN] On the "Shpfy Variant" record, the field "Item SystemId" must be filled in and the Item record must exist.
                LibraryAssert.IsFalse(IsNullGuid(ShpfyVariant."Item SystemId"), 'Item SystemId <> NullGuid');
                LibraryAssert.IsTrue(Item.GetBySystemId(ShpfyVariant."Item SystemId"), 'Get Item');

                // [THEN] Check Item fields
                ShpfyProduct.Get(ShpfyVariant."Product Id");
                LibraryAssert.AreEqual(CopyStr(ShpfyProduct.Title, 1, MaxStrLen(Item.Description)), Item.Description, 'Description');
                LibraryAssert.AreEqual(ShpfyVariant."Unit Cost", Item."Unit Cost", 'Unit Cost');
                LibraryAssert.AreEqual(ShpfyVariant.Price, Item."Unit Price", 'Unit Price');

                // [THEN] Check Vendor Item Reference exsist
                ItemReference.SetRange("Item No.", Item."No.");
                ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
                ItemReference.SetRange("Reference Type No.", '');
                ItemReference.SetRange("Reference No.", ShpfyVariant.SKU);
                LibraryAssert.RecordIsNotEmpty(ItemReference);
            until ShpfyVariant.Next() = 0;
    end;
}