codeunit 139535 "MigrationGP Item Tests"
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
        MigrationGPItem: Record "MigrationGP Item";
        Item: Record "Item";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item staging table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(MigrationGPItem);

        // [WHEN] MigrationAccounts is called
        MigrationGPItem.FindSet();
        repeat
            Migrate(MigrationGPItem);
        until MigrationGPItem.Next() = 0;

        // [THEN] A Item is created for all staging table entries
        Assert.RecordCount(Item, MigrationGPItem.Count());

        // [WHEN] Transactions are migrated
        // CreateOpeningBalances();

        // [THEN] Items are created with correct settings
        MigrationGPItem.FindSet();
        Item.FindSet();
        repeat
            Assert.AreEqual(MigrationGPItem.No, Item."No.", 'Item No. not set');
            Assert.AreEqual(0.00, Item."Unit Price", 'Unit Price set');
            Assert.AreEqual(MigrationGPItem.CurrentCost, Item."Unit Cost", 'Unit Cost not set');
            Assert.AreEqual(MigrationGPItem.StandardCost, Item."Standard Cost", 'Standard Cost not set');
            Assert.AreEqual(MigrationGPItem.ShipWeight, Item."Net Weight", 'Net Weight not set');
            Assert.AreEqual(MigrationGPItem.BaseUnitOfMeasure, Item."Base Unit of Measure", 'Base Unit of Measure not set');
            Assert.AreEqual(MigrationGPItem.Description, Item.Description, 'Description not set.');
            Assert.AreEqual(MigrationGPItem.ShortName, Item."Description 2", 'Description2 not set.');
            Assert.AreEqual(MigrationGPItem.SearchDescription, Item."Search Description", 'Search Description not set.');
            Assert.AreEqual(MigrationGPItem.PurchUnitOfMeasure, Item."Purch. Unit of Measure", 'Purch. Unit of Measure not set.');
            MigrationGPItem.Next();
        until Item.Next() = 0;
    end;

    local procedure ClearTables()
    var
        MigrationGPItem: Record "MigrationGP Item";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
    begin
        MigrationGPItem.DeleteAll();
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
    end;

    local procedure Migrate(MigrationGPItem: Record "MigrationGP Item")
    var
        MigrationGPItemMigrator: Codeunit "MigrationGP Item Migrator";
    begin
        MigrationGPItemMigrator.OnMigrateItem(ItemDataMigrationFacade, MigrationGPItem.RecordId());
    end;

    local procedure CreateStagingTableEntries(var MigrationGPItem: Record "MigrationGP Item")
    begin
        MigrationGPItem.Init();
        MigrationGPItem.No := '1 1/2\"SASH BRSH';
        MigrationGPItem.Description := '1 1/2\"SASH BRSH';
        MigrationGPItem.SearchDescription := 'Craftsman Brush 1 1/2\" Sash';
        MigrationGPItem.ShortName := '1 1/2\"SASH BRSH';
        MigrationGPItem.BaseUnitOfMeasure := 'Each';
        MigrationGPItem.ItemType := 0;
        MigrationGPItem.CostingMethod := '0';
        MigrationGPItem.CurrentCost := 3.95;
        MigrationGPItem.StandardCost := 3.95000;
        MigrationGPItem.UnitListPrice := 5.00000;
        MigrationGPItem.ShipWeight := 0.38000;
        MigrationGPItem.InActive := false;
        MigrationGPItem.QuantityOnHand := 47.75000;
        MigrationGPItem.SalesUnitOfMeasure := 'Each';
        MigrationGPItem.PurchUnitOfMeasure := 'Each';
        MigrationGPItem.Insert();

        MigrationGPItem.Init();
        MigrationGPItem.No := '12345ITEMNUMBER!@#$%';
        MigrationGPItem.Description := '12345ITEMNUMBER!@#$%1234567890';
        MigrationGPItem.SearchDescription := 'Item Description !@#123456789012345678901234567890';
        MigrationGPItem.ShortName := '12345ITEMNUMBER!@#$%1234567890';
        MigrationGPItem.BaseUnitOfMeasure := 'Each1@#$';
        MigrationGPItem.ItemType := 0;
        MigrationGPItem.CostingMethod := '0';
        MigrationGPItem.CurrentCost := 0.00;
        MigrationGPItem.StandardCost := 0.00000;
        MigrationGPItem.UnitListPrice := 0.00000;
        MigrationGPItem.ShipWeight := 0.00000;
        MigrationGPItem.InActive := false;
        MigrationGPItem.QuantityOnHand := 00.00000;
        MigrationGPItem.SalesUnitOfMeasure := 'Each1@#$';
        MigrationGPItem.PurchUnitOfMeasure := '';
        MigrationGPItem.Insert();

        MigrationGPItem.Init();
        MigrationGPItem.No := '4'' STEPLADDER';
        MigrationGPItem.Description := '4'' STEPLADDER';
        MigrationGPItem.SearchDescription := '4'' Stepladder';
        MigrationGPItem.ShortName := '4'' STEPLADDER';
        MigrationGPItem.BaseUnitOfMeasure := 'Each';
        MigrationGPItem.ItemType := 0;
        MigrationGPItem.CostingMethod := '0';
        MigrationGPItem.CurrentCost := 27.05000;
        MigrationGPItem.StandardCost := 26.99000;
        MigrationGPItem.UnitListPrice := 40.00000;
        MigrationGPItem.ShipWeight := 1.50000;
        MigrationGPItem.InActive := false;
        MigrationGPItem.QuantityOnHand := 120.75000;
        MigrationGPItem.SalesUnitOfMeasure := 'Each';
        MigrationGPItem.PurchUnitOfMeasure := 'Each';
        MigrationGPItem.Insert();
    end;
}