codeunit 139604 "Shpfy Product Mapping Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestFindMappingWithNoSKUMapping()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
        Barcode: Code[50];
    begin
        // [SCENARIO] Shopify product to an item and with the SKU empty.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::" ";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem();
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        if ItemReference.FindFirst() then
            BarCode := ItemReference."Reference No.";

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has the same barcode of that from the item record.
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.Barcode := Barcode;
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");

        // [WHEN] Invoke ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant)
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToItemNo()
    var
        Item: Record Item;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Item No.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No.";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem();
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SKU := Item."No.";
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the item no.
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Variant Code.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Variant Code";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem(true);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SKU := ItemVariant.Code;
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the variant code of a variant of item.
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId
        LibraryAssert.AreEqual(ItemVariant.SystemId, ShpfyVariant."Item Variant SystemId", 'ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToItemNoAndVariantCode()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Item No. + Variant Code.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code field on the Shopify Variant record.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Item No. + Variant Code";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem(true);
        ItemVariant.SetRange("Item No.", Item."No.");
        ItemVariant.FindFirst();
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SKU := Item."No." + ShpfyShop."SKU Field Separator" + ItemVariant.Code;
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the item.no. + variant code of a variant of item.
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId
        LibraryAssert.AreEqual(ItemVariant.SystemId, ShpfyVariant."Item Variant SystemId", 'ShpfyVariant."Item Variant SystemId" = ItemVariant.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToVendorItemNo()
    var
        Item: Record Item;
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
    begin
        // [SCENARIO] Shopify product to an item and with the SKU mapped to Vendor Item No.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the vendor and SKU field.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Vendor Item No.";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem();
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SKU := Item."Vendor Item No.";
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");
        ShpfyProduct.Vendor := Item."Vendor No.";
        ShpfyProduct.Modify();

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has SKU filled in with the vendor item no.
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;

    [Test]
    procedure UnitTestFindMappingWithSKUMappedToBarCode()
    var
        Item: Record Item;
        ItemReference: Record "Item Reference";
        ShpfyShop: Record "Shpfy Shop";
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductMapping: Codeunit "Shpfy Product Mapping";
        Barcode: Code[50];
    begin
        // [SCENARIO] Shopify product to an item and with the SKU empty.
        // [SCENARIO] Because there is no SKU mapping, it will try to find the mapping based on the bar code in the SKU field on the Shopify Variant record.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        ShpfyShop."SKU Mapping" := "Shpfy SKU Mappging"::"Bar Code";
        ShpfyShop.Modify();
        Item := ShpfyProductInitTest.CreateItem();
        ItemReference.SetRange("Item No.", Item."No.");
        ItemReference.SetRange("Reference Type", "Item Reference Type"::"Bar Code");
        if ItemReference.FindFirst() then
            BarCode := ItemReference."Reference No.";

        // [GIVEN] A Shopify Product Record
        // [GIVEN] A Shopify Variant record that belongs to the Shopify Product record and has the same barcode of that from the item record.
        ShpfyVariant := ShpfyProductInitTest.CreateStandardProduct(ShpfyShop);
        ShpfyVariant.SKU := Barcode;
        ShpfyVariant.Modify();
        ShpfyProduct.Get(ShpfyVariant."Product Id");

        // [WHEN] Invoke ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant)
        ShpfyProductMapping.FindMapping(ShpfyProduct, ShpfyVariant);

        // [THEN] ShpfyVariant."Item SystemId" = Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyVariant."Item SystemId", 'ShpfyVariant."Item SystemId" = Item.SystemId');

        // [THEN] ShpfyProduct."Item SystemId"= Item.SystemId
        LibraryAssert.AreEqual(Item.SystemId, ShpfyProduct."Item SystemId", 'ShpfyProduct."Item SystemId"= Item.SystemId');
    end;
}