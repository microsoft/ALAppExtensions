codeunit 139581 "Shpfy Skipped Record Log Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        SalesShipmentNo: Code[20];

    [Test]
    procedure UnitTestLogEmptyCustomerEmail()
    var
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        SkippedRecord: Record "Shpfy Skipped Record";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when customer email is empty on customer export to shopify.

        // [GIVEN] A customer record with empty email.
        Shop := ShpfyInitializeTest.CreateShop();
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        Customer."E-Mail" := '';
        Customer.Modify(false);
        Customer.SetRange("No.", Customer."No.");

        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(0);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
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
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when customer with same email already exist on customer export to shopify.

        // [GIVEN] A customer record with email that already exist in shopify.
        Shop := ShpfyInitializeTest.CreateShop();
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify customer with random guid.
        CustomerInitTest.CreateShopifyCustomer(ShpfyCustomer);
        ShpfyCustomer."Customer SystemId" := CreateGuid();
        // [GIVEN] Shop with 
        Shop."Can Update Shopify Customer" := true;
        Shop.Modify(false);

        // [WHEN] Invoke Shopify Customer Export
        BindSubscription(ShpfySkippedRecordLogSub);
        ShpfySkippedRecordLogSub.SetShopifyCustomerId(ShpfyCustomer.Id);
        ShpfyCustomerExport.SetShop(Shop);
        ShpfyCustomerExport.SetCreateCustomers(true);
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
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyItem: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Log skipped record when product item is blocked
        // [GIVEN] A product item record that is blocked.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop.Modify(false);
        Item := ShpfyInitializeTest.GetDummyItem();
        Item."Blocked" := true;
        Item.Modify(false);
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
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Log skipped record when product item is blocked and product is archived
        // [GIVEN] A product item record that is blocked and archived. Shop with action for removed products set to status to archived.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToArchived;
        Shop.Modify(false);
        Item := ShpfyInitializeTest.GetDummyItem();
        Item."Blocked" := true;
        Item.Modify(false);
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        ShpfyProduct.Status := Enum::"Shpfy Product Status"::Archived;
        ShpfyProduct.Modify(false);

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
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when product item is blocked and product is draft
        // [GIVEN] A product item record that is blocked and draft. Shop with action for removed products set to status to draft.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToDraft;
        Shop.Modify(false);
        Item := ShpfyInitializeTest.GetDummyItem();
        Item."Blocked" := true;
        Item.Modify(false);
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        ShpfyProduct.Status := Enum::"Shpfy Product Status"::Draft;
        ShpfyProduct.Modify(false);
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
        LibraryAssert.AreEqual('Shopify Product is draft.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogItemVariantIsIsBlockedAndSalesBlocked()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SkippedrecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
    begin
        // [SCENARIO] Log skipped record when item variant item is blocked and sales blocked
        // [GIVEN] Shop with Sync Prices = true. Item with variants which is blocked and sales blocked.
        // [GIVEN] Shopify Shop Remove Product Action diffrent than DoNothing.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToArchived;
        Shop.Modify(false);
        Item := ProductInitTest.CreateItem(true);
        Item.Blocked := true;
        Item."Sales Blocked" := true;
        Item.Modify(false);
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code, ShpfyVariant);

        // [WHEN] Invoke Shopify Product Export
        BindSubscription(SkippedrecordLogSub);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.Run(Shop);
        UnbindSubscription(SkippedrecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyVariant.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Price is not synchronized because the item is blocked and sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogItemIsBlockedAndSalesBlockedWithUnitOfMeasureAsUoMOptionId()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        UnitofMeasure: Record "Unit of Measure";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SkippedrecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] Log skipped record when item variant item is blocked and sales blocked with unit of measure set fot shopify variant and shop as UoM Option ID.

        // [GIVEN] Shop with UoM as Variant set. Item with variants which is blocked and sales blocked.
        // [GIVEN] Shopify Shop Remove Product Action diffrent than DoNothing.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToArchived;
        Shop."UoM as Variant" := true;
        Shop.Modify(false);
        // [GIVEN] Item with blocked and sales blocked.
        Item := ProductInitTest.CreateItem(false);
        Item.Blocked := true;
        Item."Sales Blocked" := true;
        Item.Modify(false);
        // [GIVEN] Unit of Measure and Item Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, Any.DecimalInRange(1, 2));
        ShpfyVariant.SetRange("Product Id", ShpfyProduct.Id);
        // [GIVEN] Product Variant with UoM and UomM Option Id set.
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code, ShpfyVariant);
        ShpfyVariant."UoM Option Id" := 1;
        ShpfyVariant."Option 1 Value" := ItemUnitofMeasure.Code;
        ShpfyVariant.Modify(false);

        // [WHEN] Invoke Shopify Product Export
        BindSubscription(SkippedrecordLogSub);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.Run(Shop);
        UnbindSubscription(SkippedrecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        SkippedRecord.SetRange("Shopify Id", ShpfyVariant.Id);
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
        LibraryAssert.AreEqual('Price is not synchronized because the item is blocked and sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogItemVariantIsBlockedAndSalesBlockedWithUnitOfMeasureSetOnVariantOptions()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ShpfyVariant: Record "Shpfy Variant";
        SkippedRecord: Record "Shpfy Skipped Record";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        UnitofMeasure: Record "Unit of Measure";
        ProductInitTest: Codeunit "Shpfy Product Init Test";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SkippedrecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        // [SCENARIO] Log skipped record when item variant item is blocked and sales blocked with unit of measure set fot shopify variant and shop.

        // [GIVEN] Shop with UoM as Variant and Option name for UoM set. Item with variants which is blocked and sales blocked.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToArchived;
        Shop."UoM as Variant" := true;
        Shop."Option Name for UoM" := Any.AlphanumericText(MaxStrLen(Shop."Option Name for UoM"));
        Shop.Modify(false);
        // [GIVEN] Item with blocked and sales blocked.
        Item := ProductInitTest.CreateItem(false);
        Item.Blocked := true;
        Item."Sales Blocked" := true;
        Item.Modify(false);
        // [GIVEN] Unit of Measure and Item Unit of Measure.
        LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, Any.DecimalInRange(1, 2));
        // [GIVEN] Product Variant with UoM and UoM Option name set as in shop. 
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        ShpfyVariant.SetRange("Product Id", ShpfyProduct.Id);
        ShpfyVariant.FindFirst();
        ShpfyVariant."Option 1 Name" := Shop."Option Name for UoM";
        ShpfyVariant."Option 1 Value" := ItemUnitofMeasure.Code;
        ShpfyVariant.Modify(false);

        // [WHEN] Invoke Shopify Product Export
        BindSubscription(SkippedrecordLogSub);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.Run(Shop);
        UnbindSubscription(SkippedrecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        LibraryAssert.AreEqual(2, SkippedRecord.Count(), 'Skipped record is not created'); //Two recrds are created because its not possible to omit one with Shop."UoM as Variant" := true;
        SkippedRecord.FindLast();
        LibraryAssert.AreEqual('Price is not synchronized because the item is blocked and sales blocked.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithNotExistingShopifyCustomer()
    var
        Customer: Record Customer;
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibrarySales: Codeunit "Library - Sales";
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because not existing shopify customer.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer
        LibrarySales.CreateCustomer(Customer);
        // [GIVEN] Sales Invoice
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.");

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
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShopifyCustomer: Record "Shpfy Customer";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because of not existing shopify payment terms.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := Any.AlphanumericText(10);
        // [GIVEN] Sales Invoice
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Payment terms %1 does not exist in Shopify.', PaymentTermsCode), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithCustomerNoIsDefaultCustomerNo()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because bill to customer no which is default shopify shop customer no.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer 
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Shop with default customer no set.
        Shop."Default Customer No." := Customer."No.";
        Shop.Modify(false);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Shop."Default Customer No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop.Code);
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
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShopifyCustomerTemplate: Record "Shpfy Customer Template";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because customer no which is used in shopify customer templates.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer 
        Customer.Init();
        Customer."No." := Any.AlphanumericText(20);
        Customer.Insert(false);
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Shopify Customer Template with customer no.
        ShopifyCustomerTemplate.Init();
        ShopifyCustomerTemplate."Shop Code" := Shop.Code;
        ShopifyCustomerTemplate."Default Customer No." := Customer."No.";
        ShopifyCustomerTemplate.Insert(false);
        // [GIVEN] Sales Invoice for default customer no.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, ShopifyCustomerTemplate."Default Customer No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);

        // [WHEN] Invoke Shopify Posted Invoice Export
        PostedInvoiceExport.SetShop(Shop.Code);
        PostedInvoiceExport.ExportPostedSalesInvoiceToShopify(SalesInvoiceHeader);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesInvoiceHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual(StrSubstNo('Shopify Customer template exists for customer no. %1 shop %2.', Customer."No.", Shop.Code), SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestLogSalesInvoiceWithoutSalesLine()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesInvoiceLine: Record "Sales Invoice Line";
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped because it has no sales lines.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);

        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice without sales line.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);
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
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryRandom: Codeunit "Library - Random";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped sales line with decimal quantity.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice with sales line with decimal quantity.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);
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
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShopifyCustomer: Record "Shpfy Customer";
        SkippedRecord: Record "Shpfy Skipped Record";
        PostedInvoiceExport: Codeunit "Shpfy Posted Invoice Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        PaymentTermsCode: Code[10];
    begin
        // [SCENARIO] Log skipped record when sales invoice export is skipped when sales invoice line has empty No field.

        // [GIVEN] Shop with setup Posted Invoice Sync = true.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Posted Invoice Sync" := true;
        Shop.Modify(false);
        // [GIVEN] Customer
        Customer := ShpfyInitializeTest.GetDummyCustomer();
        // [GIVEN] Shopify Customer
        CustomerInitTest.CreateShopifyCustomer(ShopifyCustomer);
        ShopifyCustomer."Customer SystemId" := Customer.SystemId;
        ShopifyCustomer.Modify(false);
        // [GIVEN] Payment Terms Code
        PaymentTermsCode := CreatePaymentTerms(Shop.Code);
        // [GIVEN] Sales Invoice with sales line with empty No field.
        CreateSalesInvoiceHeader(SalesInvoiceHeader, Customer."No.");
        SalesInvoiceHeader."Payment Terms Code" := PaymentTermsCode;
        SalesInvoiceHeader.Modify(false);
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
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
    begin
        // [SCENARIO] Log skipped record when sales shipment export is skipped because not existing shipment lines.

        // [GIVEN] Shop
        Shop := ShpfyInitializeTest.CreateShop();
        // [GIVEN] Posted shipment without lines.
        CreateSalesShipmentHeader(SalesShipmentHeader, Any.IntegerInRange(10000, 999999));
        SalesShipmentNo := SalesShipmentHeader."No.";
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
        SalesShipmentLine: Record "Sales Shipment Line";
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShopifyOrderId: BigInteger;
    begin
        // [SCENARIO] Log skipped record when sales shipment export is skipped because not existing related shopify order.

        // [GIVEN] Shop
        Shop := ShpfyInitializeTest.CreateShop();
        // [GIVEN] Posted shipment with line.
        ShopifyOrderId := Any.IntegerInRange(10000, 999999);
        CreateSalesShipmentHeader(SalesShipmentHeader, ShopifyOrderId);
        SalesShipmentNo := SalesShipmentHeader."No.";
        SalesShipmentLine.Init();
        SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
        SalesShipmentLine."Line No." := 10000;
        SalesShipmentLine.Type := SalesShipmentLine.Type::Item;
        SalesShipmentLine."No." := Any.AlphanumericText(20);
        SalesShipmentLine.Quantity := Any.IntegerInRange(1, 100);
        SalesShipmentLine.Insert(false);
        Commit();

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
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
        SalesShipmentLine: Record "Sales Shipment Line";
        Shop: Record "Shpfy Shop";
        ShopifyOrderHeader: Record "Shpfy Order Header";
        ShopifyOrderLine: Record "Shpfy Order Line";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ExportShipments: Codeunit "Shpfy Export Shipments";
    begin
        // [SCENARIO] Log skipped record when sales shipment is export is skip because theres no fulfillment lines shopify.

        // [GIVEN] Shop
        Shop := ShpfyInitializeTest.CreateShop();
        // [GIVEN] Shopify order with line
        ShopifyOrderHeader.Init();
        ShopifyOrderHeader."Shop Code" := Shop.Code;
        ShopifyOrderHeader."Shopify Order Id" := Any.IntegerInRange(10000, 999999);
        ShopifyOrderHeader.Insert(false);

        ShopifyOrderLine.Init();
        ShopifyOrderLine."Shopify Order Id" := ShopifyOrderHeader."Shopify Order Id";
        ShopifyOrderLine."Line Id" := Any.IntegerInRange(10000, 999999);
        ShopifyOrderLine.Quantity := Any.IntegerInRange(1, 100);
        ShopifyOrderLine.Insert(false);

        // [GIVEN] Posted shipment with line.
        CreateSalesShipmentHeader(SalesShipmentHeader, ShopifyOrderHeader."Shopify Order Id");
        SalesShipmentLine.Init();
        SalesShipmentLine."Document No." := SalesShipmentHeader."No.";
        SalesShipmentLine."Line No." := 10000;
        SalesShipmentLine.Type := SalesShipmentLine.Type::Item;
        SalesShipmentLine."No." := Any.AlphanumericText(20);
        SalesShipmentLine.Quantity := ShopifyOrderLine.Quantity;
        SalesShipmentLine."Shpfy Order Line Id" := ShopifyOrderLine."Line Id";
        SalesShipmentLine.Insert(false);
        Commit();

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
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        ShopifyOrderHeader: Record "Shpfy Order Header";
        ExportShipments: Codeunit "Shpfy Export Shipments";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShippingTest: Codeunit "Shpfy Shipping Test";
        SkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        ShopifyOrderId: BigInteger;
        LocationId: BigInteger;
        DeliveryMethodType: Enum "Shpfy Delivery Method Type";
    begin
        // [SCENARIO] Log skipped record when sales shipment is exported with no fulfillment created in shopify.

        // [GIVEN] Sales shipment, shopify order and shopify fulfilment
        Shop := ShpfyInitializeTest.CreateShop();
        ShopifyOrderId := Any.IntegerInRange(10000, 999999);
        DeliveryMethodType := DeliveryMethodType::" ";
        ShopifyOrderId := ShippingTest.CreateRandomShopifyOrder(LocationId, DeliveryMethodType);
        ShopifyOrderHeader.Get(ShopifyOrderId);
        ShopifyOrderHeader."Shop Code" := Shop.Code;
        ShopifyOrderHeader.Modify(false);
        ShippingTest.CreateShopifyFulfillmentOrder(ShopifyOrderId, DeliveryMethodType);
        ShippingTest.CreateRandomSalesShipment(SalesShipmentHeader, ShopifyOrderId);

        // [WHEN] Invoke Shopify Sync Shipment to Shopify
        BindSubscription(SkippedRecordLogSub);
        ExportShipments.CreateShopifyFulfillment(SalesShipmentHeader);
        UnbindSubscription(SkippedRecordLogSub);

        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", SalesShipmentHeader.RecordId);
        LibraryAssert.IsTrue(SkippedRecord.FindLast(), 'Skipped record is not created');
        LibraryAssert.AreEqual('No corresponding fulfillment lines found.', SkippedRecord."Skipped Reason", 'Skipped reason is not as expected');
    end;

    [Test]
    procedure UnitTestSkipLoggingWhenShopHasLoggingModeDisabled()
    var
        Shop: Record "Shpfy Shop";
        SkippedRecord: Record "Shpfy Skipped Record";
        SkipRecordMgt: Codeunit "Shpfy Skip Record Mgt.";
        RecordID: RecordID;
        ShopifyId: BigInteger;
        TableId: Integer;
    begin
        // [SCENARIO] Skip logging when setup in shop for logging is Disabled.

        // [GIVEN] Shop with logging mode = Disabled.
        Shop.Init();
        Shop.Code := Any.AlphanumericText(20);
        Shop."Logging Mode" := Enum::"Shpfy Logging Mode"::Disabled;
        Shop.Insert(false);

        // [WHEN] Invoke Skip Record Management
        ShopifyId := Any.IntegerInRange(10000, 999999);
        TableId := Any.IntegerInRange(1, 50000);
        SkipRecordMgt.LogSkippedRecord(ShopifyId, TableId, RecordID, Any.AlphabeticText(250), Shop);

        // [THEN] No record is created in shopify skipped record table.
        SkippedRecord.SetRange("Shopify Id", ShopifyId);
        SkippedRecord.SetRange("Table Id", TableId);
        LibraryAssert.IsTrue(SkippedRecord.IsEmpty(), 'Skipped record is created');
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

    local procedure CreateSalesInvoiceHeader(var SalesInvoiceHeader: Record "Sales Invoice Header"; CustomerNo: Code[20])
    begin
        SalesInvoiceHeader.Init();
        SalesInvoiceHeader."No." := Any.AlphanumericText(20);
        SalesInvoiceHeader."Bill-to Customer No." := CustomerNo;
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

    [RequestPageHandler]
    procedure SyncPostedShipmentsToShopify(var SyncShipmToShopify: TestRequestPage "Shpfy Sync Shipm. to Shopify")
    begin
        SyncShipmToShopify."Sales Shipment Header".SetFilter("No.", SalesShipmentNo);
        SyncShipmToShopify.OK().Invoke();
    end;
}
