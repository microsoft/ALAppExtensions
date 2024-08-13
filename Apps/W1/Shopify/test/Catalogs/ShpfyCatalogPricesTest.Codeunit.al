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




    [Test]
    procedure UnitTestCalcCatalogPriceAllCustomers()
    var
        Shop: Record "Shpfy Shop";
        LibrarySales: Codeunit "Library - Sales";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        Customer: Record Customer;
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
        // Setup initial test environment and create necessary records.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
        LibrarySales.CreateCustomer(Customer);  // This may be unused if discount applies to all customers generically.

        // Verify initial price calculations without any discounts applied.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Verify initial unit cost is as expected.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Verify initial price is as expected without any discounts.');

        // Update the catalog to apply a universal discount to all customers and verify the changes.
        ProductInitTest.CreateAllCustomerPriceList(Shop.Code, Item."No.", InitPrice, InitDiscountPerc);
        Catalog."Customer No." := Customer."No.";  // This step might need adjustment depending on business logic.
        Catalog.Modify();
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // Validate the results after applying the discount.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain consistent even after discount application.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should reflect the original price before any discounts were applied.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'The final price should accurately reflect the applied discount for all customers.');
    end;

    [Test]
    procedure UnitTestCalcCatalogPriceCustomer()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        Customer: Record Customer;
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
        CustDiscPerc: Decimal;
    begin
        // Set up the test environment: Shop, Catalog, Item, and Customer with specific pricing and discount.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        CustDiscPerc := Any.DecimalInRange(5, 20, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
        ProductInitTest.CreateSalesPrice(Shop.Code, Item."No.", InitPrice);

        // Create a customer price list with a specific discount.
        Customer := ProductInitTest.CreateCustomerPriceList(Shop.Code, Item."No.", InitPrice, CustDiscPerc);

        // Validate initial price calculations without customer-specific discount.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Initial unit cost should match setup.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Initial price should match setup before discount application.');

        // Apply the customer-specific discount and re-calculate the prices.
        Catalog."Customer No." := Customer."No.";
        Catalog.Modify();
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // Confirm that the pricing reflects the customer-specific discounts correctly.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain unchanged.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should reflect the price before discount.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - CustDiscPerc / 100), Price, 0.01, 'Discounted price should be correctly calculated.');
    end;


    [Test]
    procedure UnitTestCalcCatalogPriceCustomer2()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        ShopifyCompany: Record "Shpfy Company";
        Item: Record Item;
        CustomerDiscountGroup: Record "Customer Discount Group";
        Customer: Record Customer;
        InitializeTest: Codeunit "Shpfy Initialize Test";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        CatalogInitialize: Codeunit "Shpfy Catalog Initialize";
        CompanyInitialize: Codeunit "Shpfy Company Initialize";
        ProductPriceCalculation: Codeunit "Shpfy Product Price Calc.";
        InitUnitCost: Decimal;
        InitPrice: Decimal;
        InitPerc: Decimal;
        CustDiscPerc: Decimal;
        UnitCost: Decimal;
        Price: Decimal;
        ComparePrice: Decimal;
    begin
        // Setup test environment: creating shop, catalog, and customer with specific discounts.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitPerc := Any.DecimalInRange(5, 20, 1);
        CustDiscPerc := Any.DecimalInRange(5, 20, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);

        // Create standard sales price for item.
        ProductInitTest.CreateSalesPrice(Shop.Code, Item."No.", InitPrice);

        // Create customer-specific price list which might include specific discounts.
        Customer := ProductInitTest.CreateCustomerPriceList(Shop.Code, Item."No.", InitPrice, CustDiscPerc);

        // Begin test scenario for price calculation without initial discounts.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // Validate initial prices without discounts.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Validate initial unit cost matches expected.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Validate initial price matches expected before discount.');

        // Update catalog with customer-specific discount and validate recalculated prices.
        Catalog."Customer No." := Customer."No.";
        Catalog.Modify();
        ProductInitTest.CreateAllCustomerPriceList(Shop.Code, Item."No.", InitPrice, InitPerc);
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // Verify the results post discount application.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit cost should remain consistent post-discount.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare price should still reflect initial price pre-discount.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - CustDiscPerc / 100), Price, 0.01, 'Verify discounted price is calculated correctly.');
    end;

    [Test]
    procedure UnitTestCalcCatalogPriceCustomer3()
    var
        Shop: Record "Shpfy Shop";
        Catalog: Record "Shpfy Catalog";
        LibrarySales: Codeunit "Library - Sales";
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
        Customer: Record Customer;
    begin
        // Set up the initial environment and create necessary records.
        Shop := InitializeTest.CreateShop();
        CompanyInitialize.CreateShopifyCompany(ShopifyCompany);
        Catalog := CatalogInitialize.CreateCatalog(ShopifyCompany);
        CatalogInitialize.CopyParametersFromShop(Catalog, Shop);
        InitUnitCost := Any.DecimalInRange(10, 100, 1);
        InitPrice := Any.DecimalInRange(2 * InitUnitCost, 4 * InitUnitCost, 1);
        InitDiscountPerc := Any.DecimalInRange(5, 20, 1);
        Item := ProductInitTest.CreateItem(Shop."Item Templ. Code", InitUnitCost, InitPrice);
        LibrarySales.CreateCustomer(Customer);
        CustomerDiscountGroup := ProductInitTest.CreateCustDiscPriceList(Any.AlphabeticText(10), Item."No.", InitPrice, InitDiscountPerc);

        // Perform initial price calculation without any discounts applied.
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost should match the initial setup.');
        LibraryAssert.AreEqual(InitPrice, Price, 'Price should match the initial setup without discounts.');

        // Update the catalog with customer discount information and re-calculate the prices.
        Catalog."Customer No." := Customer."No.";
        Customer."Customer Disc. Group" := CustomerDiscountGroup.Code;
        Customer.Modify();
        Catalog.Modify();
        ProductPriceCalculation.SetShopAndCatalog(Shop, Catalog);
        ProductPriceCalculation.CalcPrice(Item, '', '', UnitCost, Price, ComparePrice);

        // Confirm that the calculations reflect the updated discount information.
        LibraryAssert.AreEqual(InitUnitCost, UnitCost, 'Unit Cost should remain unchanged after applying discounts.');
        LibraryAssert.AreEqual(InitPrice, ComparePrice, 'Compare Price should reflect the original price before discounts.');
        LibraryAssert.AreNearlyEqual(InitPrice * (1 - InitDiscountPerc / 100), Price, 0.01, 'The discounted price should be accurately calculated.');
    end;

}
