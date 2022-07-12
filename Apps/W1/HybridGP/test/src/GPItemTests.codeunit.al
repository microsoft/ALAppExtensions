codeunit 139662 "GP Item Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GPIV00101: Record "GP IV00101";
        GPIV40400: Record "GP IV40400";
        Assert: Codeunit Assert;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        GPItemMigrator: Codeunit "GP Item Migrator";

    local procedure ConfigureMigrationSettings(MigrateItemClasses: Boolean)
    var
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        CompanyNameText: Text[30];
    begin
        CompanyNameText := CompanyName();

        GPCompanyMigrationSettings.Name := CompanyNameText;
        GPCompanyMigrationSettings.Insert(true);

        GPCompanyAdditionalSettings.Name := CompanyNameText;
        GPCompanyAdditionalSettings."Migrate Item Classes" := MigrateItemClasses;
        GPCompanyAdditionalSettings.Insert(true);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPItemMigration()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        Initialize();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(GPItem);

        // [WHEN] MigrationAccounts is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] A Item is created for all staging table entries
        Assert.RecordCount(Item, GPItem.Count());

        // [WHEN] Transactions are migrated
        // CreateOpeningBalances();

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
    procedure TestGPItemClassesConfiguredToNotImport()
    var
        GPItem: Record "GP Item";
        InventoryPostingGroup: Record "Inventory Posting Group";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, but configured to NOT import Item Classes
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        ConfigureMigrationSettings(false);

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
            GPItemMigrator.MigrateItemInventoryPostingGroup(GPItem, ItemDataMigrationFacade);
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
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items and their class information are queried from GP
        // [GIVEN] GP data
        Initialize();

        // [WHEN] Data is imported and migrated, and configured to import Item Classes
        CreateStagingTableEntries(GPItem);
        CreateItemClassData();
        ConfigureMigrationSettings(true);

        GPIV00101.FindSet();
        Assert.RecordCount(GPIV00101, 3);

        GPIV40400.FindSet();
        Assert.RecordCount(GPIV40400, 2);

        GPItem.FindSet();
        repeat
            Migrate(GPItem);
            GPItemMigrator.MigrateItemInventoryPostingGroup(GPItem, ItemDataMigrationFacade);
        until GPItem.Next() = 0;

        // [then] Then the Inventory Posting Groups will be migrated
        Item.SetFilter("No.", '%1|%2|%3', '1 1/2\"SASH BRSH', '12345ITEMNUMBER!@#$%', '4'' STEPLADDER');
        Assert.AreEqual(true, Item.FindSet(), 'Could not find Items by code.');

        InventoryPostingGroup.SetFilter("Code", '%1|%2|%3', 'TEST-1', 'TEST-2', 'GP');
        Assert.AreEqual(true, InventoryPostingGroup.FindSet(), 'Could not find Inventory Posting Groups by code.');
        Assert.RecordCount(InventoryPostingGroup, 3);

        // [then] Then fields for the first Inventory Posting Setup will be correct
        InventoryPostingSetup.SetRange("Invt. Posting Group Code", 'TEST-1');
        Assert.AreEqual(true, InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual('TEST-1', InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('1', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        InventoryPostingSetup.SetRange("Invt. Posting Group Code", 'TEST-2');
        Assert.AreEqual(true, InventoryPostingSetup.FindFirst(), 'Could not find Inventory Posting Setup by code.');
        Assert.AreEqual('TEST-2', InventoryPostingSetup."Invt. Posting Group Code", 'Invt. Posting Group Code of InventoryPostingSetup is incorrect.');
        Assert.AreEqual('', InventoryPostingSetup."Inventory Account", 'Inventory Account of InventoryPostingSetup is incorrect.');

        // [then] The correct Inventory Posting Groups are set
        Item.Get('1 1/2\"SASH BRSH');
        Assert.AreEqual('TEST-1', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get('12345ITEMNUMBER!@#$%');
        Assert.AreEqual('TEST-1', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');

        Item.Get('4'' STEPLADDER');
        Assert.AreEqual('TEST-2', Item."Inventory Posting Group", 'Inventory Posting Group of migrated Item is incorrect.');
    end;

    local procedure Initialize()
    var
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

        if not GenBusPostingGroup.Get('GP') then begin
            GenBusPostingGroup.Validate(GenBusPostingGroup.Code, 'GP');
            GenBusPostingGroup.Insert(true);
        end;
    end;

    local procedure Migrate(GPItem: Record "GP Item")
    begin
        GPItemMigrator.OnMigrateItem(ItemDataMigrationFacade, GPItem.RecordId());
    end;

    local procedure CreateStagingTableEntries(var GPItem: Record "GP Item")
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