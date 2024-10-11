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
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when customer email is empty on customer export to shopify.
        Initialize();

        // [GIVEN] A customer record with empty email.
        CreateCustomerWithEmail(Customer, '');

        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(0);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
        Customer.SetRange("No.", Customer."No.");
        ShpfyCustomerExport.Run(Customer);
        UnbindSubscription(ShpfySkippedRecordLogSub);

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
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when customer with same email already exist on customer export to shopify.
        Initialize();

        // [GIVEN] A customer record with email that already exist in shopify.
        CreateCustomerWithEmail(Customer, 'dummy@cust.com');
        // [GIVEN] Shopify customer with random guid.
        CreateShopifyCustomerWithRandomGuid(ShpfyCustomer);

        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(ShpfyCustomer.Id);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
        Customer.SetRange("No.", Customer."No.");
        ShpfyCustomerExport.Run(Customer);
        UnbindSubscription(ShpfySkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Customer.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Customer already exists with the same e-mail or phone.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
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
        CreateSHopifyProductWithStatus(Item, ShpfyProduct, Enum::"Shpfy Product Status"::Archived);

        // [WHEN] Invoke Shopify Product Export
        ProductExport.SetShop(Shop);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.Run(Shop);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyProduct.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Shopify Product is archived.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogProductItemBlockedAndProductIsDraft()
    var

        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when product item is blocked and product is draft
        Initialize();

        // [GIVEN] Shop with action for removed products set to status to draft.
        SetActionForRemovedProducts(Shop, Enum::"Shpfy Remove Product Action"::StatusToDraft);

        // [GIVEN] Item that is blocked.
        CreateBlockedItem(Item);

        // [GIVEN] Shpify Product with status draft.
        CreateSHopifyProductWithStatus(Item, ShpfyProduct, Enum::"Shpfy Product Status"::Draft);

        // [WHEN] Invoke Shopify Product Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ProductExport.SetShop(Shop);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.Run(Shop);
        UnbindSubscription(ShpfySkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyProduct.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Shopify Product is in draft status.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemUnitOfMeasureForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemunitOfMeasure: Record "Item Unit of Measure";
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item unit of measure for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked and sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemUnitOfMeasure);

        // [THEN] Related log record is created in shopify skipped record table.
        ShpfySkippedRecord.SetRange("Record ID", Item.RecordId);
        ShpfySkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(ShpfySkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked and sales blocked.', ShpfySkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemVariantForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemVariant: Record "Item Variant";
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item variant for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked and sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemVariant);

        // [THEN] Related log record is created in shopify skipped record table.
        ShpfySkippedRecord.SetRange("Record ID", Item.RecordId);
        ShpfySkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(ShpfySkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked and sales blocked.', ShpfySkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipShopifyVariantPriceCalcWithItemUnitOfMeasureAndItemVariantForVariantWithBlockedItem()
    var
        Item: Record Item;
        ShopifyProduct: Record "Shpfy Product";
        ShopifyVariant: Record "Shpfy Variant";
        ItemUnitOfMeasure: Record "Item Unit of Measure";
        ItemVariant: Record "Item Variant";
        ShpfySkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
    begin
        // [SCENARIO] Skip shopify variant price calculation using item unit of measure and item variant for variant with blocked item.
        Initialize();

        // [GIVEN] Blocked and sales blokced item
        CreateBlockedItem(Item);
        // [GIVEN] Shopify Product
        CreateShpfyProduct(ShopifyProduct, Item.SystemId, Shop.Code, ShopifyVariant);

        // [WHEN] Invoke FillInProductVariantData
        ProductExport.SetShop(Shop);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.FillInProductVariantData(ShopifyVariant, Item, ItemVariant, ItemUnitOfMeasure);

        // [THEN] Related log record is created in shopify skipped record table.
        ShpfySkippedRecord.SetRange("Record ID", Item.RecordId);
        ShpfySkippedRecord.SetRange("Shopify Id", ShopifyVariant.Id);
        LibraryAssert.IsTrue(ShpfySkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Variant price is not synchronized because the item is blocked and sales blocked.', ShpfySkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
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
        LibraryAssert.AreEqual('Customer not existing as Shopify company or customer.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
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
        PaymentTermsCode := Any.AlphanumericText(10);
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
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        Shop2: Record "Shpfy Shop";
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
        CreateShop(Shop2, Customer."No.");
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop2.Code);
        // [GIVEN] Shop with default customer no set.
        SetCustomerAsDefaultForShop(Shop2, Customer);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Shop2."Default Customer No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop2.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Bill-to customer no. is the default customer no. for Shopify shop.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithCustomerNoUsedInShopifyCustomerTemplates()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        Shop2: Record "Shpfy Shop";
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because customer no which is used in shopify customer templates.
        Initialize();

        // [GIVEN] Customer 
        CreateRandomCustomer(Customer);
        // [GIVEN]  Shop 
        CreateShop(Shop2, '');
        // [GIVEN] Shopify Customer
        CreateShopifyCustomer(Customer);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop2.Code);
        // [GIVEN] Shopify Customer Template with customer no.
        CreateShopifyCustomerTemplate(ShopifyCustomerTemplate, Shop2, Customer);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, ShopifyCustomerTemplate."Default Customer No.", PaymentTermsCode);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop2.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Shopify Customer template exists for customer no. %1 shop %2.', Customer."No.", Shop2.Code), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithoutSalesLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
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
        // [GIVEN] Sales Invoice without sales line.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.", PaymentTermsCode);
        // [GIVEN] No existing sales lines.
        if not SalesInvoiceLine.IsEmpty() then
            SalesInvoiceLine.DeleteAll(false);

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
        ShippingTest: Codeunit "Shpfy Shipping Test";
        ShopifyOrderId: BigInteger;
    begin
        // [SCENARIO] Log skipped record when sales shipment is export is skip because theres no fulfillment lines shopify.
        Initialize();

        // [GIVEN] Shopify order with line
        ShopifyOrderId := CreateshopifyOrder(Shop, Enum::"Shpfy Delivery Method Type"::" ");
        // [GIVEN] Posted shipment with line.
        ShippingTest.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

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
        ShippingTest: Codeunit "Shpfy Shipping Test";
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
        ShippingTest.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);

        // [GIVEN] Sales shipment related to shopify order
        ShippingTest.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        BindSubscription(SkippedRecordLogSub);
        ExportShipments.CreateShopifyFulfillment(SalesShipmentHeader);
        UnbindSubscription(SkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Fullfilment was not created in Shopify.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipLoggingWhenShopHasLoggingModeDisabled()
    var

        SkippedRecord: Record "Shpfy Skipped Record";
        SkipRecordMgt: Codeunit "Shpfy Skip Record Mgt.";
        RecordID: RecordID;
        ShopifyId: BigInteger;
        TableId: Integer;
    begin
        // [SCENARIO] Skip logging when setup in shop for logging is Disabled.
        Initialize();

        // [GIVEN] Shop with logging mode = Disabled.
        CreateShopWithDisabledLogging(Shop);
        // [GIVEN] Random Shopify Id
        ShopifyId := Any.IntegerInRange(10000, 999999);

        // [WHEN] Invoke Skip Record Management
        SkipRecordMgt.LogSkippedRecord(ShopifyId, RecordID, Any.AlphabeticText(250), Shop);

        // [THEN] No record is created in shopify skipped record table.
        SkippedRecord.SetRange("Shopify Id", ShopifyId);
        SkippedRecord.SetRange("Table Id", TableId);
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
        CreateShop(Shop, '');
        Shop."Logging Mode" := Enum::"Shpfy Logging Mode"::Disabled;
        Shop.Modify(false);
    end;

    local procedure CreateShopifyOrder(Shop: Record "Shpfy Shop"; DeliveryMethodType: Enum "Shpfy Delivery Method Type"): BigInteger
    var
        ShopifyOrderHeader: Record "Shpfy Order Header";
        ShippingTest: Codeunit "Shpfy Shipping Test";
        LocationId: BigInteger;
        ShopifyOrderId: BigInteger;
    begin
        ShopifyOrderId := ShippingTest.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
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

    local procedure SetCustomerAsDefaultForShop(var Shop: Record "Shpfy Shop"; Customer: Record Customer)
    begin
        Shop."Default Customer No." := Customer."No.";
        Shop.Modify(false);
    end;

    local procedure CreateShopifyCustomerTemplate(var ShopifyCustomerTemplate: Record "Shpfy Customer Template"; Shop: Record "Shpfy Shop"; Customer: Record Customer)
    begin
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Shop Code" := Shop.Code;
        ShopifyCustomerTemplate."Default Customer No." := Customer."No.";
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

    local procedure CreateShopifyCustomerWithRandomGuid(var ShpfyCustomer: Record "Shpfy Customer")
    var
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
    begin
        CustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := CreateGuid();
    end;

    local procedure SetActionForRemovedProducts(var Shop: Record "Shpfy Shop"; ShpfyRemoveProductAction: Enum Microsoft.Integration.Shopify."Shpfy Remove Product Action")
    begin
        Shop."Action for Removed Products" := ShpfyRemoveProductAction;
        Shop.Modify(false);
    end;

    local procedure CreateSHopifyProductWithStatus(var Item: Record Item; var ShpfyProduct: Record "Shpfy Product"; ShpfyProductStatus: Enum Microsoft.Integration.Shopify."Shpfy Product Status")
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

    local procedure CreateShop(var Shop: Record "Shpfy Shop"; DefaultCustomer: Code[20])
    begin
        Shop.Init();
        Shop.Code := Any.AlphanumericText(20);
        Shop."Default Customer No." := DefaultCustomer;
        Shop.Insert(false);
    end;

    [RequestPageHandler]
    procedure SyncPostedShipmentsToShopify(var SyncShipmToShopify: TestRequestPage "Shpfy Sync Shipm. to Shopify")
    begin
        SyncShipmToShopify."Sales Shipment Header".SetFilter("No.", SalesShipmentNo);
        SyncShipmToShopify.OK().Invoke();
    end;
}
