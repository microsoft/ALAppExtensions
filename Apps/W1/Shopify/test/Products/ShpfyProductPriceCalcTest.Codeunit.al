/// <summary>
/// Codeunit Shpfy Product Price Calc. Test (ID 139605).
/// </summary>
codeunit 139605 "Shpfy Product Price Calc. Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

#if not CLEAN19
    var
        Any: Codeunit Any;
        LibraryAssert: Codeunit "Library Assert";


    [Test]
    procedure UnitTestCalcPriceTest()
    var
        ShpfyShop: Record "Shpfy Shop";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfyProductInitTest: Codeunit "Shpfy Product Init Test";
        ShpfyProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
        InitDiscountPerc: Decimal;
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // [INIT] Initialization startup data.
        ShpfyShop := ShpfyInitializeTest.CreateShop();
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        Item := ShpfyProductInitTest.CreateItem(ShpfyShop."Item Template Code", InitUnitCost, InitPrice);
        ShpfyProductInitTest.CreateSalesPrice(ShpfyShop.Code, Item."No.", InitPrice);
        CustomerDiscountGroup := ShpfyProductInitTest.CreateSalesLineDiscount(ShpfyShop.Code, Item."No.", InitDiscountPerc);

        // [SCENARIO] Doing the price calculation of an product for a shop where the fields "Customer Price Group" and Customer Discount Group" are not filled in.
        // [SCENARIO] After modify de "Customer Discount Group" for the same shop, we must get a discounted price.

        // [GIVEN] the Shop with the fields "Customer Price Group" and Customer Discount Group" not filled in.
        ShpfyProductPriceCalculation.SetShop(ShpfyShop);
        // [GIVEN] The item and the variable UnitCost, Price and ComparePrice for storing the results.
        // [WHEN] Invoking the procedure: CalcPrice(Item, '', '', UnitCost, Price, ComparePrice)
        ShpfyProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] InitUnitCost = UnitCost
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost');
        // [THEN] InitPrice = Price
        LibraryAssert.AreEqual(InitPrice, Price, 'Price');

        // [GIVEN] Update the Shop."Customer Discount Group" field and set the shop to the calculation codeunit.
        ShpfyShop."Customer Discount Group" := CustomerDiscountGroup.Code;
        ShpfyShop.Modify();
        ShpfyProductPriceCalculation.SetShop(ShpfyShop);

        // [GIVEN] The item and the variable UnitCost, Price and ComparePrice for storing the results.
        // [WHEN] Invoking the procedure: CalcPrice(Item, '', '', UnitCost, Price, ComparePrice)
        ShpfyProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        // [THEN] InitUnitCost = UnitCost
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost');
        // [THEN] InitPrice = ComparePrice. ComparePrice is the price without the discount.
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare Price');
        // [THEN] InitPrice - InitDiscountPerc = Price
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'Discount Price');
    end;
#endif
}