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
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
#if not CLEAN25
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
        Catalog."Allow Line Disc." := true;
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

    [Test]
    procedure UnitTestCalcCatalogPriceAllCustomers()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
#if CLEAN25
        InitDiscountPerc: Decimal;
#endif
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // [GIVEN] Initializing test environment and creating necessary test records.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);

        // Creating a customer entry, though it is generic as discounts apply to all customers.
        LibrarySales.CreateCustomer(Customer);

        // [WHEN] Calculating initial prices without any discounts applied.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Confirm initial price calculations match expectations.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Initial unit cost should match expected.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Initial price should match expected before discount application.');

        // [GIVEN] Updating the catalog to apply a universal discount to all customers.
#if CLEAN25
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        ProductInitTest.CreateAllCustomerPriceList(Shop.Code, Item."No.", InitPrice, InitDiscountPerc);
        Catalog."Customer No." := Customer."No.";
        Catalog.Modify();

        // [WHEN] Recalculating prices after applying the discount.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Validate the results reflect the universal discount.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain consistent after discount application.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should reflect the original price prior to any discounts.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'The final price should accurately reflect the applied discount for all customers.');
#endif
    end;

    [Test]
    procedure UnitTestCalcCustomerCatalogPrice()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
#if CLEAN25
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
#endif
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
#if CLEAN25
        CustDiscPerc: Decimal;
#endif
    begin
        // [GIVEN] Setting up the test environment: Shop, Catalog, Item, and Customer with specific pricing and discount.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);

        // [WHEN] Calculating prices without and then with customer-specific discounts.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Verify initial unit cost matches setup.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Verify initial price matches setup before discount.');
#if CLEAN25
        // Creating a customer entry, though it is generic as discounts apply to all customers.
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Applying customer-specific discounts.
        CustDiscPerc := Any.DecimalInRange(5, 20, 1);
	ProductInitTest.CreateCustomerPriceList(Shop.Code, Item."No.", InitPrice, CustDiscPerc, Customer);
        Catalog."Customer No." := Customer."No.";
        Catalog.Modify();
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);

        // [WHEN] Recalculating prices with customer-specific discounts.
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Confirming pricing accuracy with applied discounts.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain unchanged after applying discounts.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should reflect the original price pre-discount.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - CustDiscPerc / 100), Price, 0.01, 'Discounted price should be accurately calculated.');
#endif
    end;

    [Test]
    procedure UnitTestCalcCustomerCatalogPriceAllCustomers()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
#if CLEAN25
        Customer: Record Customer;
        LibrarySales: Codeunit "Library - Sales";
#endif
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
#if CLEAN25
        InitPerc: Decimal;
        CustDiscPerc: Decimal;
#endif        
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // [GIVEN] Setting up shop, catalog, item, and customer-specific pricing.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);

        // [WHEN] Calculating prices without discounts applied.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Verifying initial prices match expectations.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Initial unit cost should match.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Initial price should match before discount.');

#if CLEAN25
        // Creating a customer entry, though it is generic as discounts apply to all customers.
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Applying a universal discount for all customers.
        CustDiscPerc := Any.DecimalInRange(5, 20, 1);
	ProductInitTest.CreateCustomerPriceList(Shop.Code, Item."No.", InitPrice, CustDiscPerc, Customer);
        ProductInitTest.CreateAllCustomerPriceList(Shop.Code, Item."No.", InitPrice, InitPerc);
        Catalog."Customer No." := Customer."No.";
        Catalog.Modify();

        // [WHEN] Recalculating prices with discounts.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Confirming discounts are accurately reflected in the final prices.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain consistent.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should reflect initial pricing.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - CustDiscPerc / 100), Price, 0.01, 'Discounted price should be accurately calculated.');
#endif
    end;

    [Test]
    procedure UnitTestCalcCustomerDiscountCatalogPrice()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
#if CLEAN25
        Customer: Record Customer;
        CustomerDiscountGroup: Record "Customer Discount Group";
        LibrarySales: Codeunit "Library - Sales";
#endif        
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
#if CLEAN25
        InitDiscountPerc: Decimal;
#endif        
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // [GIVEN] Creating shop, catalog, item, and setting customer discount details.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);

        // [WHEN] Calculating initial prices without any discounts applied.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Verifying initial price settings.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Initial unit cost should match setup.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Initial price should match setup without discounts.');
#if CLEAN25
        LibrarySales.CreateCustomer(Customer);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
	CustomerDiscountGroup := ProductInitTest.CreatePriceList(Shop.Code, Item."No.", InitPrice, InitDiscountPerc);
        // [GIVEN] Updating catalog with customer-specific discount group details.
        Catalog."Customer No." := Customer."No.";
        Customer."Customer Disc. Group" := CustomerDiscountGroup.Code;
        Customer.Modify();
        Catalog.Modify();

        // [WHEN] Recalculating prices post-update.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // [THEN] Confirming accurate reflection of discount updates in final prices.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain unchanged post-update.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare Price should match initial settings.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'Accurate calculation of discounted price should be verified.');
#endif
    end;
}
