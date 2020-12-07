codeunit 139662 "GP Item Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPItemMigration()
    var
        GPItem: Record "GP Item";
        Item: Record "Item";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        ClearTables();

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

    local procedure ClearTables()
    var
        GPItem: Record "GP Item";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        GPItem.DeleteAll();
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
    end;

    local procedure Migrate(GPItem: Record "GP Item")
    var
        GPItemMigrator: Codeunit "GP Item Migrator";
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
}