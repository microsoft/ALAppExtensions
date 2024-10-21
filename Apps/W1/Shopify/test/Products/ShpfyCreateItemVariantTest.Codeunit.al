codeunit 139581 "Shpfy Create Item Variant Test"
{
    Subtype = Test;
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
        Item: Record "Item";
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";

        CreateProduct: Codeunit "Shpfy Create Product";
        CreateItemAsVariant: Codeunit "Shpfy Create Item As Variant";
        ParentProductId: BigInteger;
    begin
        // [SCENARIO] Create a variant from a given item
        Initialize();

        // [GIVEN] Item
        Item := ShpfyProductInitTest.CreateItem(Shop."Item Templ. Code", Any.DecimalInRange(10, 100, 2), Any.DecimalInRange(100, 500, 2));
        // [GIVEN] Shopify product
        ParentProductId := CreateShopifyProduct(Item.SystemId);

        // [WHEN] Invoke CreateItemAsVariant.CreateVariantFromItem
        CreateItemAsVariant.SetParentProduct(ParentProductId);
        CreateItemAsVariant.CreateVariantFromItem(Item);



    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Any.SetDefaultSeed();
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
