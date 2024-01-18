codeunit 139646 "Shpfy Catalog Prices Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCalcCatalogPrice()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
#if not CLEAN22
        ShpfyTemplates: Codeunit "Shpfy Templates";
#endif
        InitUnitCost: Decimal;
        InitPrice: Decimal;
        InitDiscountPerc: Decimal;
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // Creating test data.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
#if not CLEAN22
        if not ShpfyTemplates.NewTemplatesEnabled() then
            Item := ProductInitTest.CreateItem(Shop."Item Template Code", InitUnitCost, InitPrice)
        else
            Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
#else
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
#endif
#if not CLEAN23
        ProductInitTest.CreateSalesPrice(Shop.Code, Item."No.", InitPrice);
        CustomerDiscountGroup := ProductInitTest.CreateSalesLineDiscount(Shop.Code, Item."No.", InitDiscountPerc);
#else
        CustomerDiscountGroup := ProductInitTest.CreatePriceList(Shop.Code, Item."No.", InitPrice, InitDiscountPerc);
#endif

        // [SCENARIO] Doing the price calculation of an product for a catalog where the fields "Customer Price Group" and Customer Discount Group" are not filled in.
        // [SCENARIO] After modify the "Customer Discount Group" for the same catalog, we must get a discounted price.

        // [GIVEN] the Catalog with the fields "Customer Price Group" and Customer Discount Group" not filled in.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        // [GIVEN] The item and the variable UnitCost, Price and ComparePrice for storing the results.
        // [WHEN] Invoking the procedure: CalcPrice(Item, '', '', UnitCost, Price, ComparePrice)
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] InitUnitCost = UnitCost
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost');
        // [THEN] InitPrice = Price
        LibraryAssert.AreEqual(InitPrice, Price, 'Price');

        // [GIVEN] Update the Catalog."Customer Discount Group" field and set the catalog to the calculation codeunit.
        Catalog."Customer Discount Group" := CustomerDiscountGroup.Code;
        Catalog.Modify();
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);

        // [GIVEN] The item and the variable UnitCost, Price and ComparePrice for storing the results.
        // [WHEN] Invoking the procedure: CalcPrice(Item, '', '', UnitCost, Price, ComparePrice)
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        // [THEN] InitUnitCost = UnitCost
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost');
        // [THEN] InitPrice = ComparePrice. ComparePrice is the price without the discount.
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare Price');
        // [THEN] InitPrice - InitDiscountPerc = Price
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'Discount Price');
    end;
}
