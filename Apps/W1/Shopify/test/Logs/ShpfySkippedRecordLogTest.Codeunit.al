codeunit 139581 "Shpfy Skipped Record Log Test"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        LibraryAssert: Codeunit "Library Assert";
        Any: Codeunit Any;
        EmptyCustomerIdsTok: Label '{ "data": { "customers": { "pageInfo": { "hasNextPage": false }, "edges": [] } }, "extensions": { "cost": { "requestedQueryCost": 12, "actualQueryCost": 2, "throttleStatus": { "maximumAvailable": 2000, "currentlyAvailable": 1998, "restoreRate": 100 } } } }', Locked = true;

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
    end;

    [Test]
    procedure UnitTestLogCustomerForSameEmailExist()
    var
        Shop: Record "Shpfy Shop";
        Customer: Record Customer;
        ShpfyCustomer: Record "Shpfy Customer";
        CustomerInitTest: Codeunit "Shpfy Customer Init Test";
        ShpfyCustomerExport: Codeunit "Shpfy Customer Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        LibraryRandom: Codeunit "Library - Random";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        SkippedRecord: Record "Shpfy Skipped Record";
        CustomerId: BigInteger;
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
    end;

    [Test]
    procedure UnitTestLogProductItemBlocked()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyItem: Record "Shpfy Product";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        SkippedRecord: Record "Shpfy Skipped Record";
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
    end;

    [Test]
    procedure UnitTestLogProductItemBlockedAndProductArchived()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        SkippedRecord: Record "Shpfy Skipped Record";
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
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
    end;

    [Test]
    procedure UnitTestLogProductItemBlockedAndProductIsDraft()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ShpfyProduct: Record "Shpfy Product";
        ProductExport: Codeunit "Shpfy Product Export";
        ShpfyInitializeTest: Codeunit "Shpfy Initialize Test";
        ShpfySkippedRecordLogSub: Codeunit "Shpfy Skipped Record Log Sub.";
        SkippedRecord: Record "Shpfy Skipped Record";
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
        LibraryAssert.IsTrue(SkippedRecord.FindFirst(), 'Skipped record is not created');
    end;

    [Test]
    procedure UnitTestLogItemVariantIsIsBlockedAndSalesBlocked()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        // [WHEN] Invoke Shopify Product Export
        BindSubscription(SkippedrecordLogSub);
        Shop.SetRange("Code", Shop.Code);
        ProductExport.SetOnlyUpdatePriceOn();
        ProductExport.Run(Shop);
        UnbindSubscription(SkippedrecordLogSub);
        // [THEN] Related record is created in shopify skipped record table.
        SkippedRecord.SetRange("Record ID", Item.RecordId);
        LibraryAssert.IsFalse(SkippedRecord.IsEmpty(), 'Skipped record is not created');
    end;

    [Test]
    procedure UnitTestLogItemVariantIsBlockedAndSalesBlockedWithUnitOfMeasure()
    var
        Shop: Record "Shpfy Shop";
        Item: Record Item;
        ItemVariant: Record "Item Variant";
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
        // [GIVEN] Shop with UoM as Variant set. Item with variants which is blocked and sales blocked.
        // [GIVEN] Shopify Shop Remove Product Action diffrent than DoNothing.
        Shop := ShpfyInitializeTest.CreateShop();
        Shop."Can Update Shopify Products" := true;
        Shop."Action for Removed Products" := Enum::"Shpfy Remove Product Action"::StatusToArchived;
        Shop."UoM as Variant" := true;
        Shop.Modify(false);
        Item := ProductInitTest.CreateItem(true);
        Item.Blocked := true;
        Item."Sales Blocked" := true;
        Item.Modify(false);

        // [GIVEN] Product Variant with UoM set.
        CreateShpfyProduct(ShpfyProduct, Item.SystemId, Shop.Code);
        LibraryInventory.CreateUnitOfMeasureCode(UnitofMeasure);
        LibraryInventory.CreateItemUnitOfMeasure(ItemUnitofMeasure, Item."No.", UnitofMeasure.Code, Any.DecimalInRange(1, 2));
        ShpfyVariant.SetRange("Product Id", ShpfyProduct.Id);
        ShpfyVariant.FindFirst();
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
        LibraryAssert.IsFalse(SkippedRecord.IsEmpty(), 'Skipped record is not created');




    end;

    local procedure CreateShpfyProduct(var ShopifyProduct: Record "Shpfy Product"; ItemSystemId: Guid; ShopCode: Code[20])
    var
        ShopifyVariant: Record "Shpfy Variant";
    begin
        ShopifyProduct.DeleteAll();
        ShopifyProduct.Init();
        ShopifyProduct.Id := Any.IntegerInRange(10000, 999999);
        ShopifyProduct."Item SystemId" := ItemSystemId;
        ShopifyProduct."Shop Code" := ShopCode;
        ShopifyProduct.Insert();
        ShopifyVariant.DeleteAll();
        ShopifyVariant.Init();
        ShopifyVariant.Id := Any.IntegerInRange(10000, 999999);
        ShopifyVariant."Product Id" := ShopifyProduct.Id;
        ShopifyVariant."Item SystemId" := ItemSystemId;
        ShopifyVariant."Shop Code" := ShopCode;
        ShopifyVariant.Insert();
    end;
}
