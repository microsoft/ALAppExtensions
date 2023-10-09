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

        // [THEN] A Item is created for all staging table entries
        Assert.RecordCount(Item, GPItem.Count());
        Assert.AreEqual(GPItem.Count(), HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [THEN] Items are created with correct settings
        GPItem.FindSet();
        Item.FindSet();
        repeat
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
            GPItem.Next();
        until Item.Next() = 0;
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
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [then] Then the Inventory Posting Groups will NOT be migrated
        InventoryPostingGroup.SetFilter("Code", '%1|%2', 'TEST-1', 'TEST-2');
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
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        Assert.RecordCount(GPIV00101, 5);
        Assert.RecordCount(GPIV40400, 2);

        Assert.IsTrue(GPIV00101.Get('1 1/2\"SASH BRSH'), 'Could not locate item.');
        Assert.AreEqual('TEST-1', GPIV00101.ITMCLSCD, 'Incorrect class Id');
        Assert.IsTrue(GPIV40400.Get('TEST-1'), 'Could not class Id.');

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] The Inventory Posting Groups will be migrated
        Item.SetFilter("No.", '%1|%2|%3', '1 1/2\"SASH BRSH', '12345ITEMNUMBER!@#$%', '4'' STEPLADDER');
        Assert.IsFalse(Item.IsEmpty(), 'Could not find Items by code.');

        InventoryPostingGroup.SetFilter("Code", '%1|%2|%3', 'TEST-1', 'TEST-2', 'GP');
        Assert.IsFalse(InventoryPostingGroup.IsEmpty(), 'Could not find Inventory Posting Groups by code.');
        Assert.RecordCount(InventoryPostingGroup, 3);

        // [THEN] Fields for the first Inventory Posting Setup will be correct
        InventoryPostingSetup.SetRange("Invt. Posting Group Code", 'TEST-1');
        Assert.IsTrue(InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual('TEST-1', InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('1', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", 'TEST-2');
        Assert.IsTrue(InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual('TEST-2', InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        // [THEN] The correct Inventory Posting Groups are set
        Item.Get('1 1/2\"SASH BRSH');
        Assert.AreEqual('TEST-1', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get('12345ITEMNUMBER!@#$%');
        Assert.AreEqual('TEST-1', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get('4'' STEPLADDER');
        Assert.AreEqual('TEST-2', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');
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
        GPCompanyAdditionalSettings.Modify();

        // [THEN] 
        Assert.IsFalse(GPCompanyAdditionalSettings.GetMigrateInactiveItems(), 'Should be configured to not migrate inactive items.');

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        GPTestHelperFunctions.InitializeMigration();

        // [THEN] Calculated item count to migrate will be correct
        Assert.AreEqual(4, HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] Inactive items will not be migrated
        Assert.IsTrue(Item.Count() > 0, 'Items were not migrated.');
        Item.SetRange("No.", 'ITEM INACTIVE');
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
        GPCompanyAdditionalSettings.Modify();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        GPTestHelperFunctions.InitializeMigration();

        // [THEN] 
        Assert.IsFalse(GPCompanyAdditionalSettings.GetMigrateDiscontinuedItems(), 'Should be configured to not migrate discontinued items.');

        // [THEN] Calculated item count to migrate will be correct
        Assert.AreEqual(4, HelperFunctions.GetNumberOfItems(), 'Wrong number of Items calculated');

        // [WHEN] Migrate is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] Discontinued items will not be migrated
        Assert.IsTrue(Item.Count() > 0, 'Items were not migrated.');
        Item.SetRange("No.", 'ITEM INACTIVE');
        Assert.IsTrue(Item.FindFirst(), 'Inactive item should have been migrated.');

        Item.SetRange("No.", 'ITEM DISCONTINUED');
        Assert.IsTrue(Item.IsEmpty(), 'Discontinued item should have been migrated.');
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

        if not GenBusPostingGroup.Get('GP') then begin
            GenBusPostingGroup.Validate(GenBusPostingGroup.Code, 'GP');
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
    begin
        GPItem.Init();
        GPItem.No := '1 1/2\"SASH BRSH';
        GPItem.Description := '1 1/2\"SASH BRSH';
        GPItem.SearchDescription := 'Craftsman Brush 1 1/2\" Sash';
        GPItem.ShortName := '1 1/2\"SASH BRSH';
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

        GPItem.Init();
        GPItem.No := '12345ITEMNUMBER!@#$%';
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

        GPItem.Init();
        GPItem.No := '4'' STEPLADDER';
        GPItem.Description := '4'' STEPLADDER';
        GPItem.SearchDescription := '4'' Stepladder';
        GPItem.ShortName := '4'' STEPLADDER';
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

        GPItem.Init();
        GPItem.No := 'ITEM INACTIVE';
        GPItem.Description := 'Inactive item';
        GPItem.SearchDescription := 'inactive';
        GPItem.ShortName := 'Inactive item';
        GPItem.BaseUnitOfMeasure := 'Each';
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
        GPIV00101.Init();
        GPIV00101.ITEMNMBR := GPItem.No;
        GPIV00101.INACTIVE := true;
        GPIV00101.Insert();
#pragma warning restore AA0139

        GPItem.Init();
        GPItem.No := 'ITEM DISCONTINUED';
        GPItem.Description := 'Discontinued item';
        GPItem.SearchDescription := 'discontinued';
        GPItem.ShortName := 'Discontinued item';
        GPItem.BaseUnitOfMeasure := 'Each';
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
        GPIV00101.Init();
        GPIV00101.ITEMNMBR := GPItem.No;
        GPIV00101.ITEMTYPE := 2;
        GPIV00101.Insert();
#pragma warning restore AA0139
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
        GPIV40400.ITMCLSCD := 'TEST-1';
        GPIV40400.ITMCLSDC := 'Test class 1';
        GPIV40400.IVIVINDX := 1;
        GPIV40400.Insert();

        GPIV40400.Init();
        GPIV40400.ITMCLSCD := 'TEST-2';
        GPIV40400.ITMCLSDC := 'Test class 2';
        GPIV40400.IVIVINDX := 0;
        GPIV40400.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := '1 1/2\"SASH BRSH';
        GPIV00101.ITMCLSCD := 'TEST-1';
        GPIV00101.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := '12345ITEMNUMBER!@#$%';
        GPIV00101.ITMCLSCD := 'TEST-1';
        GPIV00101.Insert();

        GPIV00101.Init();
        GPIV00101.ITEMNMBR := '4'' STEPLADDER';
        GPIV00101.ITMCLSCD := 'TEST-2';
        GPIV00101.Insert();
    end;
}