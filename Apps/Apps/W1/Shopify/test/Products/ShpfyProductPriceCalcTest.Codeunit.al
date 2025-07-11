/// <summary>
/// Codeunit Shpfy Product Price Calc. Test (ID 139605).
/// </summary>
codeunit 139605 "Shpfy Product Price Calc. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestCalcPriceTest()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
        InitDiscountPerc: Decimal;
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // [INIT] Initialization startup data.
        Shop := InitializeTest.CreateShop();
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
#if not CLEAN25
        ProductInitTest.CreateSalesPrice(Shop.Code, Item."No.", InitPrice);
        CustomerDiscountGroup := ProductInitTest.CreateSalesLineDiscount(Shop.Code, Item."No.", InitDiscountPerc);
#else
        CustomerDiscountGroup := ProductInitTest.CreatePriceList(Shop.Code, Item."No.", InitPrice, InitDiscountPerc);
#endif

        // [SCENARIO] Doing the price calculation of an product for a shop where the fields "Customer Price Group" and Customer Discount Group" are not filled in.
        // [SCENARIO] After modify de "Customer Discount Group" for the same shop, we must get a discounted price.

        // [GIVEN] the Shop with the fields "Customer Price Group" and Customer Discount Group" not filled in.
        ProductPriceCalculation.SetShop(Shop);
        // [GIVEN] The item and the variable UnitCost, Price and ComparePrice for storing the results.
        // [WHEN] Invoking the procedure: CalcPrice(Item, '', '', UnitCost, Price, ComparePrice)
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] InitUnitCost = UnitCost
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost');
        // [THEN] InitPrice = Price
        LibraryAssert.AreEqual(InitPrice, Price, 'Price');

        // [GIVEN] Update the Shop."Customer Discount Group" field and set the shop to the calculation codeunit.
        Shop."Customer Discount Group" := CustomerDiscountGroup.Code;
        Shop.Modify();
        ProductPriceCalculation.SetShop(Shop);

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