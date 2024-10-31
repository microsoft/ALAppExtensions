codeunit 139662 "GP Item Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        Assert: Codeunit Assert;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        GPItemMigrator: Codeunit "GP Item Migrator";
        GPTestHelperFunctions: Codeunit "GP Test Helper Functions";
        ItemNoSashBrshTok: Label '1 1/2\"SASH BRSH', Locked = true;
        ItemNoStepLadderTok: Label '4'' STEPLADDER', Locked = true;
        ItemNoKitComponentInvTok: Label 'KIT COMPONENT INV', Locked = true;
        ItemNoKitComponentSvcTok: Label 'KIT COMPONENT SVC', Locked = true;
        ItemNoKitTok: Label 'KIT', Locked = true;
        ItemNo12345ITEMNUMBERTok: Label '12345ITEMNUMBER!@#$%', Locked = true;
        ItemNumberItemInactiveTok: Label 'ITEM INACTIVE', Locked = true;
        ItemNoItemDiscontinuedTok: Label 'ITEM DISCONTINUED', Locked = true;
        ItemClassesIdTest1Tok: Label 'TEST-1', Locked = true;
        ItemClassIdTest2Tok: Label 'TEST-2', Locked = true;
        PostingGroupGPTok: Label 'GP', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPItemMigration()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Discontinued Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", false);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();

        Assert.IsTrue(GPCompanyAdditionalSettings.GetInventoryModuleEnabled(), 'Inventory module should be enabled.');

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        HelperFunctions.CreatePostMigrationData();

        // [THEN] An Item is created for all configured staging table entries
        Assert.AreEqual(Item.Count(), HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [THEN] Items are created with correct settings
        GPItem.Get(ItemNoSashBrshTok);
        Item.Get(GPItem.No);
        Assert.AreEqual(GPItem.No, Item."No.", 'Item No. not set');
        Assert.AreEqual(0.00, Item."Unit Price", 'Unit Price set');
        Assert.AreEqual(GPItem.CurrentCost, Item."Unit Cost", 'Unit Cost not set');
        Assert.AreEqual(GPItem.StandardCost, Item."Standard Cost", 'Standard Cost not set');
        Assert.AreEqual(GPItem.ShipWeight, Item."Net Weight", 'Net Weight not set');
        Assert.AreEqual(GPItem.BaseUnitOfMeasure, Item."Base Unit of Measure", 'Base Unit of Measure not set');
        Assert.AreEqual(GPItem.Description, Item.Description, 'Description not set.');
        Assert.AreEqual(GPItem.ShortName, Item."Description 2", 'Description2 not set.');
        Assert.AreEqual(GPItem.SearchDescription, Item."Search Description", 'Search Description not set.');
        Assert.AreEqual(GPItem.PurchUnitOfMeasure, Item."Purch. Unit of Measure", 'Purch. Unit of Measure not set.');

        GPItem.Get(ItemNoStepLadderTok);
        Item.Get(GPItem.No);
        Assert.AreEqual(GPItem.No, Item."No.", 'Item No. not set');
        Assert.AreEqual(0.00, Item."Unit Price", 'Unit Price set');
        Assert.AreEqual(GPItem.CurrentCost, Item."Unit Cost", 'Unit Cost not set');
        Assert.AreEqual(GPItem.StandardCost, Item."Standard Cost", 'Standard Cost not set');
        Assert.AreEqual(GPItem.ShipWeight, Item."Net Weight", 'Net Weight not set');
        Assert.AreEqual(GPItem.BaseUnitOfMeasure, Item."Base Unit of Measure", 'Base Unit of Measure not set');
        Assert.AreEqual(GPItem.Description, Item.Description, 'Description not set.');
        Assert.AreEqual(GPItem.ShortName, Item."Description 2", 'Description2 not set.');
        Assert.AreEqual(GPItem.SearchDescription, Item."Search Description", 'Search Description not set.');
        Assert.AreEqual(GPItem.PurchUnitOfMeasure, Item."Purch. Unit of Measure", 'Purch. Unit of Measure not set.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestInventoryDisabled()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        // Disable the Inventory Module setting
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", false);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();

        GPTestHelperFunctions.InitializeMigration();

        // [THEN] Calculated item count to migrate will be correct
        Assert.AreEqual(0, HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] No items are migrated
        Assert.RecordCount(Item, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPItemClassesConfiguredToNotImport()
    var
        GPItem: Record "GP Item";
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        // [SCENARIO] Items and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, but configured to NOT import Item Classes
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();

        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Item Classes", false);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [then] Then the Inventory Posting Groups will NOT be migrated
        InventoryPostingGroup.SetFilter("Code", '%1|%2', ItemClassesIdTest1Tok, ItemClassIdTest2Tok);
        Assert.RecordCount(InventoryPostingGroup, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPItemClassesImport()
    var
        GPItem: Record "GP Item";
        Item: Record Item;
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        InventoryPostingGroup: Record "Inventory Posting Group";
        InventoryPostingSetup: Record "Inventory Posting Setup";
    begin
        // [SCENARIO] Items and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, and configured to import Item Classes
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        Assert.RecordCount(GPIV00101, 8);
        Assert.RecordCount(GPIV40400, 2);

        Assert.IsTrue(GPIV00101.Get(ItemNoSashBrshTok), 'Could not locate item.');
        Assert.AreEqual(ItemClassesIdTest1Tok, GPIV00101.ITMCLSCD, 'Incorrect class Id');
        Assert.IsTrue(GPIV40400.Get(ItemClassesIdTest1Tok), 'Could not class Id.');

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] The Inventory Posting Groups will be migrated
        Item.SetFilter("No.", '%1|%2|%3', ItemNoSashBrshTok, ItemNo12345ITEMNUMBERTok, ItemNoStepLadderTok);
        Assert.IsFalse(Item.IsEmpty(), 'Could not find Items by code.');

        InventoryPostingGroup.SetFilter("Code", '%1|%2|%3', ItemClassesIdTest1Tok, ItemClassIdTest2Tok, PostingGroupGPTok);
        Assert.IsFalse(InventoryPostingGroup.IsEmpty(), 'Could not find Inventory Posting Groups by code.');
        Assert.RecordCount(InventoryPostingGroup, 3);

        // [THEN] Fields for the first Inventory Posting Setup will be correct
        InventoryPostingSetup.SetRange("Invt. Posting Group Code", ItemClassesIdTest1Tok);
        Assert.IsTrue(InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual(ItemClassesIdTest1Tok, InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('1', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", ItemClassIdTest2Tok);
        Assert.IsTrue(InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual(ItemClassIdTest2Tok, InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        // [THEN] The correct Inventory Posting Groups are set
        Item.Get(ItemNoSashBrshTok);
        Assert.AreEqual(ItemClassesIdTest1Tok, Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get(ItemNo12345ITEMNUMBERTok);
        Assert.AreEqual(ItemClassesIdTest1Tok, Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get(ItemNoStepLadderTok);
        Assert.AreEqual(ItemClassIdTest2Tok, Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestInactiveItemsDisabled()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        // [GIVEN] Migration is configured to not migrate inactive items
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", false);
        GPCompanyAdditionalSettings.Validate("Migrate Discontinued Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", false);
        GPCompanyAdditionalSettings.Modify();

        // [THEN] 
        Assert.IsFalse(GPCompanyAdditionalSettings.GetMigrateInactiveItems(), 'Should be configured to not migrate inactive items.');

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        GPTestHelperFunctions.InitializeMigration();

        // [THEN] Calculated item count to migrate will be correct
        Assert.AreEqual(6, HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] Inactive items will not be migrated
        Assert.IsTrue(Item.Count() > 0, 'Items were not migrated.');
        Item.SetRange("No.", ItemNumberItemInactiveTok);
        Assert.IsTrue(Item.IsEmpty(), 'Inactive item should not have been migrated.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestDiscontinuedItemsDisabled()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        // [GIVEN] Migration is configured to not migrate discontinued items
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Discontinued Items", false);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", false);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        GPTestHelperFunctions.InitializeMigration();

        // [THEN] 
        Assert.IsFalse(GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems(), 'Should be configured to not migrate discontinued items.');

        // [THEN] Calculated item count to migrate will be correct
        Assert.AreEqual(6, HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] Discontinued items will not be migrated
        Assert.IsTrue(Item.Count() > 0, 'Items were not migrated.');
        Item.SetRange("No.", ItemNumberItemInactiveTok);
        Assert.IsTrue(Item.FindFirst(), 'Inactive item should have been migrated.');

        Item.SetRange("No.", ItemNoItemDiscontinuedTok);
        Assert.IsTrue(Item.IsEmpty(), 'Discontinued item should have been migrated.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPKitItemMigration()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
        BOMComponent: Record "BOM Component";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Discontinued Items", true);
        GPCompanyAdditionalSettings.Validate("Migrate Kit Items", true);
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();

        Assert.IsTrue(GPCompanyAdditionalSettings.GetInventoryModuleEnabled(), 'Inventory module should be enabled.');

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        HelperFunctions.CreatePostMigrationData();

        // [THEN] A Item is created for all staging table entries
        Assert.RecordCount(Item, 8);
        Assert.AreEqual(Item.Count(), HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        Item.Get(ItemNoKitComponentInvTok);
        Assert.AreEqual(Item.Type::Inventory, Item.Type, 'Type is incorrect (INV).');

        Item.Get(ItemNoKitComponentSvcTok);
        Assert.AreEqual(Item.Type::"Non-Inventory", Item.Type, 'Type is incorrect (SVC).');

        // [THEN] Kit item components are created with correct settings
        BOMComponent.SetRange("Parent Item No.", ItemNoKitTok);
        Assert.RecordCount(BOMComponent, 2);

        BOMComponent.SetRange("No.", ItemNoKitComponentInvTok);
        BOMComponent.FindFirst();
        Assert.AreEqual(10000, BOMComponent."Line No.", 'Line No. is incorrect');
        Assert.AreEqual(BOMComponent.Type::Item, BOMComponent.Type, 'Type is incorrect.');
        Assert.AreEqual('Kit Component Inventory', BOMComponent.Description, 'Description is incorrect.');
        Assert.AreEqual('EACH', BOMComponent."Unit of Measure Code", 'Unit of Measure Code is incorrect.');
        Assert.AreEqual(1, BOMComponent."Quantity per", 'Quantity per is incorrect.');

        BOMComponent.SetRange("No.", ItemNoKitComponentSvcTok);
        BOMComponent.FindFirst();
        Assert.AreEqual(20000, BOMComponent."Line No.", 'Line No. is incorrect');
        Assert.AreEqual(BOMComponent.Type::Item, BOMComponent.Type, 'Type is incorrect.');
        Assert.AreEqual('Kit Component Service', BOMComponent.Description, 'Description is incorrect.');
        Assert.AreEqual('EACH', BOMComponent."Unit of Measure Code", 'Unit of Measure Code is incorrect.');
        Assert.AreEqual(1, BOMComponent."Quantity per", 'Quantity per is incorrect.');
    end;

    local procedure Initialize()
    var
        DataMigrationEntity: Record "Data Migration Entity";
        GPItem: Record "GP Item";
        Item: Record Item;
        GenBusPostingGroup: Record "Gen. Business Posting Group";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
    begin
        Clear(ItemDataMigrationFacade);
        Clear(GPItemMigrator);

        GPItem.DeleteAll();
        Item.DeleteAll();
        GPIV00101.DeleteAll();
        GPIV40400.DeleteAll();
        DataMigrationEntity.DeleteAll();

        if not GenBusPostingGroup.Get(PostingGroupGPTok) then begin
            GenBusPostingGroup.Validate(GenBusPostingGroup.Code, PostingGroupGPTok);
            GenBusPostingGroup.Insert(true);
        end;
    end;

    local procedure Migrate(GPItem: Record "GP Item")
    begin
        if not GPTestHelperFunctions.MigrationConfiguredForTable(Database::Item) then
            exit;

        GPItemMigrator.MigrateItem(ItemDataMigrationFacade, GPItem.RecordId());
        GPItemMigrator.MigrateItemInventoryPostingGroup(GPItem, ItemDataMigrationFacade);
    end;

    local procedure CreateStagingTableEntries(var GPItem: Record "GP Item")
    var
        GPIV00101: Record "GP IV00101";
        GPIV00104: Record "GP IV00104";
    begin
        Clear(GPItem);
        GPItem.No := ItemNoSashBrshTok;
        GPItem.Description := ItemNoSashBrshTok;
        GPItem.SearchDescription := 'Craftsman Brush 1 1/2\" Sash';
        GPItem.ShortName := ItemNoSashBrshTok;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 3.95;
        GPItem.StandardCost := 3.95000;
        GPItem.UnitListPrice := 5.00000;
        GPItem.ShipWeight := 0.38000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 47.75000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        Clear(GPItem);
        GPItem.No := ItemNo12345ITEMNUMBERTok;
        GPItem.Description := '12345ITEMNUMBER!@#$%1234567890';
        GPItem.SearchDescription := 'Item Description !@#123456789012345678901234567890';
        GPItem.ShortName := '12345ITEMNUMBER!@#$%1234567890';
        GPItem.BaseUnitOfMeasure := 'Each1@#$';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 0.00;
        GPItem.StandardCost := 0.00000;
        GPItem.UnitListPrice := 0.00000;
        GPItem.ShipWeight := 0.00000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 00.00000;
        GPItem.SalesUnitOfMeasure := 'Each1@#$';
        GPItem.PurchUnitOfMeasure := '';
        GPItem.Insert();

        Clear(GPItem);
        GPItem.No := ItemNoStepLadderTok;
        GPItem.Description := ItemNoStepLadderTok;
        GPItem.SearchDescription := ItemNoStepLadderTok;
        GPItem.ShortName := ItemNoStepLadderTok;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 27.05000;
        GPItem.StandardCost := 26.99000;
        GPItem.UnitListPrice := 40.00000;
        GPItem.ShipWeight := 1.50000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 120.75000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        Clear(GPItem);
        GPItem.No := ItemNumberItemInactiveTok;
        GPItem.Description := 'Inactive item';
        GPItem.SearchDescription := 'inactive';
        GPItem.ShortName := 'Inactive item';
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 1;
        GPItem.StandardCost := 1;
        GPItem.UnitListPrice := 5;
        GPItem.ShipWeight := 1;
        GPItem.QuantityOnHand := 120.75000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

#pragma warning disable AA0139
        Clear(GPIV00101);
        GPIV00101.ITEMNMBR := GPItem.No;
        GPIV00101.INACTIVE := true;
        GPIV00101.Insert();
#pragma warning restore AA0139

        Clear(GPItem);
        GPItem.No := ItemNoItemDiscontinuedTok;
        GPItem.Description := 'Discontinued item';
        GPItem.SearchDescription := 'discontinued';
        GPItem.ShortName := 'Discontinued item';
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 1;
        GPItem.StandardCost := 1;
        GPItem.UnitListPrice := 5;
        GPItem.ShipWeight := 1;
        GPItem.QuantityOnHand := 120.75000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

#pragma warning disable AA0139
        Clear(GPIV00101);
        GPIV00101.ITEMNMBR := GPItem.No;
        GPIV00101.ITEMTYPE := 2;
        GPIV00101.Insert();
#pragma warning restore AA0139

        // Kit and its components
        Clear(GPItem);
        GPItem.No := ItemNoKitTok;
        GPItem.Description := ItemNoKitTok;
        GPItem.SearchDescription := ItemNoKitTok;
        GPItem.ShortName := ItemNoKitTok;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 2;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 1;
        GPItem.StandardCost := 1;
        GPItem.UnitListPrice := 5;
        GPItem.ShipWeight := 1;
        GPItem.QuantityOnHand := 0;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        Clear(GPIV00101);
        GPIV00101.ITEMNMBR := ItemNoKitTok;
        GPIV00101.ITEMTYPE := 3;
        GPIV00101.Insert();

        Clear(GPItem);
        GPItem.No := ItemNoKitComponentInvTok;
        GPItem.Description := 'Kit Component Inventory';
        GPItem.SearchDescription := 'Kit component inventory';
        GPItem.ShortName := 'Kit Component Inventory';
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 1;
        GPItem.StandardCost := 1;
        GPItem.UnitListPrice := 5;
        GPItem.ShipWeight := 1;
        GPItem.QuantityOnHand := 0;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        Clear(GPIV00101);
        GPIV00101.ITEMNMBR := ItemNoKitComponentInvTok;
        GPIV00101.ITEMTYPE := 1;
        GPIV00101.Insert();

        Clear(GPItem);
        GPItem.No := ItemNoKitComponentSvcTok;
        GPItem.Description := 'Kit Component Service';
        GPItem.SearchDescription := 'Kit component service';
        GPItem.ShortName := 'Kit Component SVC';
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 1;
        GPItem.CostingMethod := '0';
        GPItem.CurrentCost := 1;
        GPItem.StandardCost := 1;
        GPItem.UnitListPrice := 5;
        GPItem.ShipWeight := 1;
        GPItem.QuantityOnHand := 0;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        Clear(GPIV00101);
        GPIV00101.ITEMNMBR := ItemNoKitComponentSvcTok;
        GPIV00101.ITEMTYPE := 5;
        GPIV00101.Insert();

        Clear(GPIV00104);
        GPIV00104.ITEMNMBR := ItemNoKitTok;
        GPIV00104.SEQNUMBR := 1;
        GPIV00104.CMPTITNM := ItemNoKitComponentInvTok;
        GPIV00104.CMPITUOM := 'Each';
        GPIV00104.CMPITQTY := 1;
        GPIV00104.CMPSERNM := false;
        GPIV00104.DEX_ROW_ID := 1;
        GPIV00104.Insert();

        Clear(GPIV00104);
        GPIV00104.ITEMNMBR := ItemNoKitTok;
        GPIV00104.SEQNUMBR := 1;
        GPIV00104.CMPTITNM := ItemNoKitComponentSvcTok;
        GPIV00104.CMPITUOM := 'Each';
        GPIV00104.CMPITQTY := 1;
        GPIV00104.CMPSERNM := false;
        GPIV00104.DEX_ROW_ID := 2;
        GPIV00104.Insert();
    end;

    local procedure CreateItemClassData()
    var
        GPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
    begin
        GPAccount.Init();
        GPAccount.AcctNum := '1';
        GPAccount.AcctIndex := 1;
        GPAccount.Name := 'Account 1';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPAccount.Init();
        GPAccount.AcctNum := '2';
        GPAccount.AcctIndex := 2;
        GPAccount.Name := 'Account 2';
        GPAccount.Active := true;
        GPAccount.Insert();

        GLAccount.Init();
        GLAccount.Validate("No.", GPAccount.AcctNum);
        GLAccount.Validate(Name, GPAccount.Name);
        GLAccount.Validate("Account Type", "G/L Account Type"::Posting);
        GLAccount.Insert();

        GPIV40400.Init();
        GPIV40400.ITMCLSCD := ItemClassesIdTest1Tok;
        GPIV40400.ITMCLSDC := 'Test class 1';
        GPIV40400.IVIVINDX := 1;
        GPIV40400.Insert();

        GPIV40400.Init();
        GPIV40400.ITMCLSCD := ItemClassIdTest2Tok;
        GPIV40400.ITMCLSDC := 'Test class 2';
        GPIV40400.IVIVINDX := 0;
        GPIV40400.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := ItemNoSashBrshTok;
        GPIV00101.ITMCLSCD := ItemClassesIdTest1Tok;
        GPIV00101.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := ItemNo12345ITEMNUMBERTok;
        GPIV00101.ITMCLSCD := ItemClassesIdTest1Tok;
        GPIV00101.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := ItemNoStepLadderTok;
        GPIV00101.ITMCLSCD := ItemClassIdTest2Tok;
        GPIV00101.Insert();
    end;
}