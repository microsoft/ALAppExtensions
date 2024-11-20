codeunit 139581 "Shpfy Skipped Record Log Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Shop: Record "Shpfy Shop";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        SalesShipmentNo: Code[20];
        IsInitialized: Boolean;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    [Test]
    procedure UnitTestLogEmptyCustomerEmail()
    var

        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
    begin
        // [SCENARIO] Log skipped record when customer email is empty on customer export to shopify.
        Initialize();

        // [GIVEN] A customer record with empty email.
        CreateCustomerWithEmail(Customer, '');

        // [WHEN] Invoke Shopify Customer Export
        InvokeShopifyCustomerExport(Customer, 0);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Customer has no e-mail address.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogCustomerForSameEmailExist()
    var
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
    begin
        // [SCENARIO] Log skipped record when customer with same email already exist on customer export to shopify.
        Initialize();

        // [GIVEN] A customer record with email that already exist in shopify.
        CreateCustomerWithEmail(Customer, 'dummy@cust.com');
        // [GIVEN] Shopify customer with random guid.
        CreateShopifyCustomerWithRandomGuid(ShpfyCustomer);

        // [WHEN] Invoke Shopify Customer Export
        InvokeShopifyCustomerExport(Customer, ShpfyCustomer.Id);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Customer already exists with the same e-mail or phone.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]

    [HandlerFunctions('AddItemToShopifyHandler')]
    procedure UnitTestLogItemBlocked()
    var

        Item: Record Item;
        SkippedRecord: Record "Shpfy Skipped Record";
        AddItemToShopify: Report "Shpfy Add Item to Shopify";
    begin
        // [SCENARIO] Log skipped record when item is blocked
        Initialize();

        // [GIVEN] An item record that is blocked
        CreateBlockedItem(Item);
        Commit();

        // [WHEN] Run report Add Items to Shopify
        Item.SetRange("No.", Item."No.");
        AddItemToShopify.SetShop(Shop.Code);
        AddItemToShopify.SetTableView(Item);
        AddItemToShopify.Run();

        // [THEN] Related record is created in shopify skipped record table
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Item is blocked or sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogItemVariantBlocked()
    var
        Item: Record Item;
        ItemVariant: Record "Item Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        TempShopifyProduct: Record "Shpfy Product" temporary;
        TempShopifyVariant: Record "Shpfy Variant" temporary;
        TempShopifyTag: Record "Shpfy Tag" temporary;
        CreateProduct: Codeunit "Shpfy Create Product";
    begin
        // [SCENARIO] Log skipped record when item variant is blocked
        Initialize();

        // [GIVEN] An item record and variant that is blocked
        CreateBlockedItem(Item);
        Item.Blocked := false;
        Item.Modify();
        CreateBlockedItemVariant(Item, ItemVariant);

        // [WHEN] Invoke Create Product
        CreateProduct.CreateTempProduct(Item, TempShopifyProduct, TempShopifyVariant, TempShopifyTag);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", ItemVariant.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Item variant is blocked or sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogProductItemBlocked()
    var

        Item: Record Item;
        ShpfyItem: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Log skipped record when product item is blocked
        Initialize();

        // [GIVEN] A product item record that is blocked.
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShpfyItem, Item.SystemId, Shop.Code);

        // [WHEN] Invoke Shopify Product Export
        ProductExport.SetShop(Shop);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.Run(Shop);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Item is blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogProductItemBlockedAndProductArchived()
    var
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Log skipped record when product item is blocked and product is archived
        Initialize();

        // [GIVEN] A product item record that is blocked and archived. Shop with action for removed products set to status to archived.
        SetActionForRemovedProducts(Shop, Enum::"Shpfy Remove Product Action"::StatusToArchived);
        // [GIVEN] Item that is blocked.
        CreateBlockedItem(Item);
        // [GIVEN] Shpify Product with status archived.
        CreateShopifyProductWithStatus(Item, ShpfyProduct, Enum::"Shpfy Product Status"::Archived);

        // [WHEN] Invoke Shopify Product Export
        ProductExport.SetShop(Shop);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.Run(Shop);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyProduct.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Shopify product is archived.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogProductItemBlockedAndProductIsDraft()
    var

        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
        SkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when product item is blocked and product is draft
        Initialize();

        // [GIVEN] Shop with action for removed products set to status to draft.
        SetActionForRemovedProducts(Shop, Enum::"Shpfy Remove Product Action"::StatusToDraft);

        // [GIVEN] Item that is blocked.
        CreateBlockedItem(Item);

        // [GIVEN] Shpify Product with status draft.
        CreateShopifyProductWithStatus(Item, ShpfyProduct, Enum::"Shpfy Product Status"::Draft);

        // [WHEN] Invoke Shopify Product Export
        BindSubscription(SkippedRecordLogSub);
        ProductExport.SetShop(Shop);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.Run(Shop);
        UnbindSubscription(SkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyProduct.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Shopify product is in draft status.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemUnitOfMeasureForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemunitOfMeasure: Record "Item Unit of Measure";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item unit of measure for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked or sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemUnitOfMeasure);

        // [THEN] Related log record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked or sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemVariantForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemVariant: Record "Item Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item variant for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked or sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemVariant);

        // [THEN] Related log record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked or sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemUnitOfMeasureAndItemVariantForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item unit of measure and item variant for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked or sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemVariant, ItemUnitOfMeasure);

        // [THEN] Related log record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked or sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithNotExistingShopifyCustomer()
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because not existing shopify customer.
        Initialize();

        // [GIVEN] Customer
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Sales Invoice
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", '');

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Customer does not exists as Shopify company or customer.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithNotExistingShopifyPaymentTerms()
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because of not existing shopify payment terms.
        Initialize();

        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CopyStr(Any.AlphanumericText(10), 1, MaxStrLen(PaymentTermsCode));
        // [GIVEN] Sales Invoice
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Payment terms %1 do not exist in Shopify.', PaymentTermsCode), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithCustomerNoIsDefaultCustomerNo()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        ShopWithDefaultCustomerNo: Record "Shpfy Shop";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because bill to customer no which is default shopify shop customer no.
        Initialize();

        // [GIVEN] Customer 
        CreateRandomCustomer(Customer);
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Shop with default customer no set.
        CreateShopWithDefCustomerNo(ShopWithDefaultCustomerNo, Customer."No.");
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(ShopWithDefaultCustomerNo.Code);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, ShopWithDefaultCustomerNo."Default Customer No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(ShopWithDefaultCustomerNo.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Bill-to customer no. %1 is the default customer no. in Shopify customer template for shop %2.', Customer."No.", ShopWithDefaultCustomerNo.Code), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithCustomerNoUsedInShopifyCustomerTemplates()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        ShopWithCustTemplates: Record "Shpfy Shop";
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because customer no which is used in shopify customer templates.
        Initialize();

        // [GIVEN] Customer 
        CreateRandomCustomer(Customer);
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN]  Shop with Shopify Customer Template for customer no.
        CreateShopWithCustomerTemplate(ShopWithCustTemplates, ShopifyCustomerTemplate, Customer."No.");
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(ShopWithCustTemplates.Code);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, ShopifyCustomerTemplate."Default Customer No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(ShopWithCustTemplates.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Shopify customer template exists for customer no. %1 shop %2.', Customer."No.", ShopWithCustTemplates.Code), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithoutSalesLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because it has no sales lines.
        Initialize();

        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice without sales lines.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('No relevant sales invoice lines exist.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithSalesLineWithDecimalQuantity()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        LibraryRandom: Codeunit "Library - Random";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped sales line with decimal quantity.
        Initialize();

        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice with sales line with decimal quantity.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", PaymentTermsCode);
        CreateSalesInvoiceLine(SalesInvoiceLine, SalesInvoiceHeader."No.", LibraryRandom.RandDecInDecimalRange(0.01, 0.99, 2), Any.AlphanumericText(20));

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceLine.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Invalid quantity in sales invoice line.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithSalesLineWithEmptyNoField()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped when sales invoice line has empty No field.
        Initialize();

        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice with sales line with empty No field.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", PaymentTermsCode);
        CreateSalesInvoiceLine(SalesInvoiceLine, SalesInvoiceHeader."No.", Any.IntegerInRange(100), '');

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceLine.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('No. field is empty in Sales Invoice Line.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');

    end;

    [Test]
    [HandlerFunctions('SyncPostedShipmentsToShopify')]
    procedure UnitTestLogSalesShipmentWithoutShipmentLines()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SkippedRecord: Record "Shpfy Skipped Record";
    begin
        // [SCENARIO] Log skipped record when sales shipment export is skipped because not existing shipment lines.
        Initialize();

        // [GIVEN] Posted shipment without lines.
        CreateSalesShipmentHeader(SalesShipmentHeader, Any.IntegerInRange(10000, 999999));
        Commit();

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        Report.Run(Report::"Shpfy Sync Shipm. to Shopify");

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('No lines applicable for fulfillment.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    [HandlerFunctions('SyncPostedShipmentsToShopify')]
    procedure UnitTestLogSalesShipmentWithNotExistingShopifyOrder()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShopifyOrderId: BigInteger;
    begin
        // [SCENARIO] Log skipped record when sales shipment export is skipped because not existing related shopify order.
        Initialize();

        // [GIVEN] Random shopify order id
        ShopifyOrderId := Any.IntegerInRange(10000, 999999);

        // [GIVEN] Posted shipment with line.
        CreateSalesShipmentHeader(SalesShipmentHeader, ShopifyOrderId);
        CreateSalesShipmentLine(SalesShipmentHeader."No.");
        Commit();

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        SalesShipmentNo := SalesShipmentHeader."No.";
        Report.Run(Report::"Shpfy Sync Shipm. to Shopify");

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Shopify order %1 does not exist.', ShopifyOrderId), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure LogSalesShipmentNoCorrespondingFulfillmentWithFailedResponse()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SkippedRecord: Record "Shpfy Skipped Record";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
        ShopifyOrderId: BigInteger;
    begin
        // [SCENARIO] Log skipped record when sales shipment is export is skip because theres no fulfillment lines shopify.
        Initialize();

        // [GIVEN] Shopify order with line
        ShopifyOrderId := CreateshopifyOrder(Shop, Enum::"Shpfy Delivery Method Type"::" ");
        // [GIVEN] Posted shipment with line.
        ShippingHelper.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        ExportShipments.CreateShopifyFulfillment(SalesShipmentHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('No corresponding fulfillment lines found.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure LogSalesShipmentNoFulfilmentCreatedInShopify()
    var
        SalesShipmentHeader: Record "Sales Shipment Header";
        SkippedRecord: Record "Shpfy Skipped Record";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
        SkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        ShopifyOrderId: BigInteger;
        DeliveryMethodType: Enum "Shpfy Delivery Method Type";
    begin
        // [SCENARIO] Log skipped record when sales shipment is exported with no fulfillment created in shopify.
        Initialize();

        // [GIVEN] Shopify order with line
        DeliveryMethodType := DeliveryMethodType::" ";
        ShopifyOrderId := CreateShopifyOrder(Shop, DeliveryMethodType);

        // [GIVEN] Shopify fulfilment related to shopify order
        ShippingHelper.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);

        // [GIVEN] Sales shipment related to shopify order
        ShippingHelper.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        BindSubscription(SkippedRecordLogSub);
        ExportShipments.CreateShopifyFulfillment(SalesShipmentHeader);
        UnbindSubscription(SkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Fulfillment was not created in Shopify.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipLoggingWhenShopHasLoggingModeDisabled()
    var
        ShopWithDisabledLogging: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        SkippedRecordCodeunit: Codeunit "Shpfy Skipped Record";
        RecordID: RecordID;
        ShopifyId: BigInteger;
    begin
        // [SCENARIO] Skip logging when setup in shop for logging is Disabled.
        Initialize();

        // [GIVEN] Shop with logging mode = Disabled.
        CreateShopWithDisabledLogging(ShopWithDisabledLogging);
        // [GIVEN] Random Shopify Id
        ShopifyId := Any.IntegerInRange(10000, 999999);

        // [WHEN] Invoke Skip Record Management
        SkippedRecordCodeunit.LogSkippedRecord(ShopifyId, RecordID, Any.AlphabeticText(250), ShopWithDisabledLogging);

        // [THEN] No record is created in shopify skipped record table.
        SkippedRecord.SetRange("Shopify Id", ShopifyId);
        SkippedRecord.SetRange("Record ID", RecordID);
        LibraryAssert.IsTrue(SkippedRecord.IsEmpty(), 'Skipped record is created');
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Customer" := true;
        Shop."Can Update Shopify Products" := true;
        Shop.Modify(false);

        Commit();

        IsInitialized := true;
    end;

    local procedure CreateShpfyProduct(var ShopifyProduct: Record "Shpfy Product"; ItemSystemId: Guid; ShopCode: Code[20]; var ShopifyVariant: Record "Shpfy Variant")
    begin
        Randomize();
        ShopifyProduct.DeleteAll(false);
        ShopifyProduct.Init();
        ShopifyProduct.Id := Random(999999);
        ShopifyProduct."Item SystemId" := ItemSystemId;
        ShopifyProduct."Shop Code" := ShopCode;
        ShopifyProduct.Insert(false);
        ShopifyVariant.DeleteAll(false);
        ShopifyVariant.Init();
        ShopifyVariant.Id := Random(999999);
        ShopifyVariant."Product Id" := ShopifyProduct.Id;
        ShopifyVariant."Item SystemId" := ItemSystemId;
        ShopifyVariant."Shop Code" := ShopCode;
        ShopifyVariant.Insert(false);
    end;

    local procedure CreateShpfyProduct(var ShopifyProduct: Record "Shpfy Product"; ItemSystemId: Guid; ShopCode: Code[20])
    var
        ShopifyVariant: Record "Shpfy Variant";
    begin
        CreateShpfyProduct(ShopifyProduct, ItemSystemId, ShopCode, ShopifyVariant);
    end;

    local procedure CreateSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20]; PaymentTermsCode: Code[10])
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := Any.AlphanumericText(20);
        SalesInvoiceHeader."Bill-to Customer No." := CustomerNo;
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Insert(false);
    end;

    local procedure CreatePaymentTerms(ShopCode: Code[20]): Code[10]
    var
        PaymentTerms: Record "Payment Terms";
        ShopifyPaymentTerms: Record "Shpfy Payment Terms";
    begin
        PaymentTerms.DeleteAll(false);
        ShopifyPaymentTerms.DeleteAll(false);
        PaymentTerms.Init();
        PaymentTerms.Code := Any.AlphanumericText(10);
        PaymentTerms.Insert(false);
        ShopifyPaymentTerms.Init();
        ShopifyPaymentTerms."Shop Code" := ShopCode;
        ShopifyPaymentTerms."Payment Terms Code" := PaymentTerms.Code;
        ShopifyPaymentTerms."Is Primary" := true;
        ShopifyPaymentTerms.Insert(false);
        exit(PaymentTerms.Code);
    end;

    local procedure CreateSalesInvoiceLine(var SalesInvoiceLine: Record "Sales Invoice Line"; DocumentNo: Code[20]; Quantity: Decimal; No: Text)
    begin
        SalesInvoiceLine.Init();
        SalesInvoiceLine."Document No." := DocumentNo;
        SalesInvoiceLine.Type := SalesInvoiceLine.Type::Item;
        SalesInvoiceLine."No." := No;
        SalesInvoiceLine.Quantity := Quantity;
        SalesInvoiceLine.Insert(false);
    end;

    local procedure CreateSalesShipmentHeader(var SalesShipmentHeader: Record "Sales Shipment Header"; ShpfyOrderId: BigInteger)
    begin
        SalesShipmentHeader.Init();
        SalesShipmentHeader."No." := Any.AlphanumericText(20);
        SalesShipmentHeader."Shpfy Order Id" := ShpfyOrderId;
        SalesShipmentHeader.Insert(false);
    end;

    local procedure CreateShopWithDisabledLogging(var Shop: Record "Shpfy Shop")
    begin
        CreateShopWithDefCustomerNo(Shop, '');
        Shop."Logging Mode" := Enum::"Shpfy Logging Mode"::Disabled;
        Shop.Modify(false);
    end;

    local procedure CreateShopifyOrder(Shop: Record "Shpfy Shop"; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
        ShippingHelper: Codeunit "Shpfy Shipping Helper";
        LocationId: BigInteger;
        ShopifyOrderId: BigInteger;
    begin
        ShopifyOrderId := ShippingHelper.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShopifyOrderHeader.Get(ShopifyOrderId);
        ShopifyOrderHeader."Shop Code" := Shop.Code;
        ShopifyOrderHeader.Modify(false);
        exit(ShopifyOrderId);
    end;

    local procedure CreateShopifyCustomer(Customer: Record Customer)
    var
        ShopifyCustomer: Record "Shpfy Customer";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
    begin
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
    end;

    local procedure CreateRandomCustomer(var Customer: Record Customer)
    begin
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer.Insert(false);
    end;


    local procedure CreateShopifyCustomerTemplate(var ShopifyCustomerTemplate: Record "Shpfy Customer Template"; Shop: Record "Shpfy Shop"; CustomerNo: Code[20])
    begin
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Shop Code" := Shop.Code;
        ShopifyCustomerTemplate."Default Customer No." := CustomerNo;
        ShopifyCustomerTemplate.Insert(false);
    end;

    local procedure CreateSalesShipmentLine(SalesShipmentNo: Code[20])
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        SalesShipmentLine.Init();
        SalesShipmentLine."Document No." := SalesShipmentNo;
        SalesShipmentLine."Line No." := 10000;
        SalesShipmentLine."No." := Any.AlphanumericText(20);
        SalesShipmentLine.Type := SalesShipmentLine.Type::Item;
        SalesShipmentLine.Quantity := Any.IntegerInRange(1, 100);
        SalesShipmentLine.Insert(false);
    end;

    local procedure CreateBlockedItem(var Item: Record Item)
    begin
        Item.Init();
        Item."No." := Any.AlphanumericText(20);
        Item.Blocked := true;
        Item."Sales Blocked" := true;
        Item.Insert(false);
    end;

    local procedure CreateBlockedItemVariant(Item: Record Item; var ItemVariant: Record "Item Variant")
    begin
        ItemVariant.Code := Any.AlphanumericText(10);
        ItemVariant."Item No." := Item."No.";
        ItemVariant.Blocked := true;
        ItemVariant."Sales Blocked" := true;
        ItemVariant.Insert(false);
    end;

    local procedure CreateShopifyCustomerWithRandomGuid(var ShopifyCustomer: Record "Shpfy Customer")
    var
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
    begin
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := CreateGuid();
    end;

    local procedure SetActionForRemovedProducts(var Shop: Record "Shpfy Shop"; ShpfyRemoveProductAction: Enum Microsoft.Integration.Shopify."Shpfy Remove Product Action")
    begin
        Shop."Action for Removed Products" := ShpfyRemoveProductAction;
        Shop.Modify(false);
    end;

    local procedure CreateShopifyProductWithStatus(var Item: Record Item; var ShpfyProduct: Record "Shpfy Product"; ShpfyProductStatus: Enum Microsoft.Integration.Shopify."Shpfy Product Status")
    begin
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        ShpfyProduct.Status := ShpfyProductStatus;
        ShpfyProduct.Modify(false);
    end;

    local procedure CreateCustomerWithEmail(var Customer: Record Customer; EmailAdress: Text)
    begin
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer."E-Mail" := EmailAdress;
        Customer.Insert(true);
    end;

    local procedure CreateShopWithDefCustomerNo(var Shop: Record "Shpfy Shop"; DefaultCustomer: Code[20])
    begin
        Shop.Init();
        Shop.Code := Any.AlphanumericText(20);
        Shop."Default Customer No." := DefaultCustomer;
        Shop.Insert(false);
    end;

    local procedure InvokeShopifyCustomerExport(var Customer: Record Customer; ShpfyCustomerId: BigInteger)
    var
        CustomerExport: Codeunit "Shpfy Customer Export";
        SkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        BindSubscription(SkippedRecordLogSub);
        if ShpfyCustomerId <> 0 then
            SkippedRecordLogSub.SetShopifyCustomerId(ShpfyCustomerId);
        CustomerExport.SetShop(Shop);
        CustomerExport.SetCreateCustomers(true);
        Customer.SetRange("No.", Customer."No.");
        CustomerExport.Run(Customer);
        UnbindSubscription(SkippedRecordLogSub);
    end;

    local procedure CreateShopWithCustomerTemplate(var ShopWithCustTemplates: Record "Shpfy Shop"; var ShopifyCustomerTemplate: Record "Shpfy Customer Template"; CustomerNo: Code[20])
    begin
        CreateShopWithDefCustomerNo(ShopWithCustTemplates, '');
        CreateShopifyCustomerTemplate(ShopifyCustomerTemplate, ShopWithCustTemplates, CustomerNo);
    end;

    [RequestPageHandler]
    procedure SyncPostedShipmentsToShopify(var SyncShipmToShopify: TestRequestPage "Shpfy Sync Shipm. to Shopify")
    begin
        SyncShipmToShopify."Sales Shipment Header".SetFilter("No.", SalesShipmentNo);
        SyncShipmToShopify.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure AddItemToShopifyHandler(var AddItemToShopify: TestRequestPage "Shpfy Add Item to Shopify")
    begin
        AddItemToShopify.OK().Invoke();
    end;
}
