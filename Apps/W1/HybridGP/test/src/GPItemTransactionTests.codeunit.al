codeunit 139665 "GP Item Transaction Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        FIFOItemNoLbl: Label 'FIFO Item', MaxLength = 50, Locked = true;
        FIFOSerialItemNoLbl: Label 'FIFO SERIAL Item', MaxLength = 50, Locked = true;
        StandardItemNoLbl: Label 'STANDARD Item', MaxLength = 50, Locked = true;
        StandardLotItemNoLbl: Label 'STANDARD LOT Item', MaxLength = 50, Locked = true;
        AverageItemNoLbl: Label 'AVERAGE Item', MaxLength = 50, Locked = true;
        AverageSerialItemNoLbl: Label 'AVERAGE SERIAL Item', MaxLength = 50, Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPItemTransactionMigration()
    var
        GPItem: Record "GP Item";
        GPItemTransaction: Record "GP Item Transactions";
        GPPostingAccount: Record "GP Posting Accounts";
        GPItemLocation: Record "GP Item Location";
        Item: Record "Item";
        ItemLedgerEntry: Record "Item Ledger Entry";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Items are migrated from GP
        // [GIVEN] There are no records in Item and ItemTransaction staging tables
        ClearTables();

        // [GIVEN] Some sample data is created
        CreateLocations();
        CreateGLAccount();
        CreateGenPostingGroups();
        HelperFunctions.CreateItemTrackingCodes();

        // [GIVEN] Some records are created in the staging tables
        CreateGPItemStagingTableEntries(GPItem);
        CreateGPItemTransactionStagingTableEntries(GPItemTransaction);
        CreateGPPostingAccountsStagingTableEntries(GPPostingAccount);
        CreateGPItemLocationsStagingTableEntries(GPItemLocation);

        // [WHEN] Migration is called
        GPItem.FindSet();
        repeat
            Migrate(GPItem);
        until GPItem.Next() = 0;

        // [THEN] A Item is created for all staging table entries
        Assert.RecordCount(Item, GPItem.Count());

        // [THEN] Correct Item Ledger Entries get created for each type of item
        GPItem.FindSet();
        repeat
            ItemLedgerEntry.Reset();
            ItemLedgerEntry.SetFilter("Item No.", GPItem.No);
            ItemLedgerEntry.FindSet();
            case GPItem.No of
                FIFOItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 3);

                        ItemLedgerEntry.SetRange("Location Code", 'NORTH');
                        ItemLedgerEntry.SetRange(Quantity, 12);
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 12, 36, DMY2Date(21, 3, 2020));

                        ItemLedgerEntry.SetRange("Location Code", 'NORTH');
                        ItemLedgerEntry.SetRange(Quantity, 27);
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 27, 108, DMY2Date(18, 3, 2020));

                        ItemLedgerEntry.SetRange("Location Code", 'SOUTH');
                        ItemLedgerEntry.SetRange(Quantity, 8);
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 8, 31.2, DMY2Date(21, 3, 2020));
                    end;
                FIFOSerialItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 3);

                        ItemLedgerEntry.SetRange("Serial No.", '1');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 1, 3.95, DMY2Date(21, 3, 2022));

                        ItemLedgerEntry.SetRange("Serial No.", '2');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 1, 3.95, DMY2Date(21, 4, 2022));

                        ItemLedgerEntry.SetRange("Serial No.", '3');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 1, 3.95, DMY2Date(21, 3, 2022));
                    end;
                StandardItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 1);
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 4, 24, WorkDate());
                    end;
                StandardLotItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 3);

                        ItemLedgerEntry.SetRange("Lot No.", 'LOT1');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 3, 39, WorkDate());

                        ItemLedgerEntry.SetRange("Lot No.", 'LOT2');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'NORTH', 2, 26, WorkDate());

                        ItemLedgerEntry.SetRange("Lot No.", 'LOT3');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 5, 65, WorkDate());
                    end;
                AverageItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 1);
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 6, 84, WorkDate());
                    end;
                AverageSerialItemNoLbl:
                    begin
                        Assert.RecordCount(ItemLedgerEntry, 2);

                        ItemLedgerEntry.SetRange("Serial No.", '888');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 1, 4, WorkDate());

                        ItemLedgerEntry.SetRange("Serial No.", '889');
                        ItemLedgerEntry.FindFirst();
                        CheckItemLedgerEntryFields(ItemLedgerEntry, 'SOUTH', 1, 4, WorkDate());
                    end;
            end;
        until GPItem.Next() = 0;
    end;

    local procedure CheckItemLedgerEntryFields(ItemLedgerEntry: Record "Item Ledger Entry"; LocationCode: Code[10]; Quantity: Decimal; CostAmount: Decimal; PostingDate: Date)
    begin
        Assert.AreEqual(LocationCode, ItemLedgerEntry."Location Code", 'Location code not set.');
        Assert.AreEqual(Quantity, ItemLedgerEntry.Quantity, 'Incorrect quantity posted.');
        ItemLedgerEntry.CalcFields("Cost Amount (Actual)");
        Assert.AreEqual(CostAmount, ItemLedgerEntry."Cost Amount (Actual)", 'Incorrect cost posted.');
        Assert.AreEqual(PostingDate, ItemLedgerEntry."Posting Date", 'Incorrect date posted.');
    end;

    local procedure ClearTables()
    var
        GPItem: Record "GP Item";
        GPItemTransaction: Record "GP Item Transactions";
        GPItemLocation: Record "GP Item Location";
        GPPostingAccounts: Record "GP Posting Accounts";
        ItemLedgerEntry: Record "Item Ledger Entry";
        Item: Record Item;
        Location: Record Location;
        PostValueEntryToGL: Record "Post Value Entry to G/L";
        TrackingSpecification: Record "Tracking Specification";
        ReservationEntry: Record "Reservation Entry";
        ValueEntry: Record "Value Entry";
        ItemTrackingCode: Record "Item Tracking Code";
        GLAccount: Record "G/L Account";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GPItem.DeleteAll();
        GPItemTransaction.DeleteAll();
        GPItemLocation.DeleteAll();
        GPPostingAccounts.DeleteAll();
        PostValueEntryToGL.DeleteAll();
        TrackingSpecification.DeleteAll();
        ReservationEntry.DeleteAll();
        ValueEntry.DeleteAll();
        ItemLedgerEntry.DeleteAll();
        Item.DeleteAll();
        Location.DeleteAll();
        ItemTrackingCode.DeleteAll();
        GLAccount.DeleteAll();
        GenProductPostingGroup.DeleteAll();
        GeneralPostingSetup.DeleteAll();
    end;

    local procedure Migrate(GPItem: Record "GP Item")
    var
        GPItemMigrator: Codeunit "GP Item Migrator";
    begin
        GPItemMigrator.OnMigrateItem(ItemDataMigrationFacade, GPItem.RecordId());
        GPItemMigrator.OnMigrateItemPostingGroups(ItemDataMigrationFacade, GPItem.RecordId(), true);
        GPItemMigrator.OnMigrateInventoryTransactions(ItemDataMigrationFacade, GPItem.RecordId(), true);
    end;

    local procedure CreateLocations()
    var
        Location: Record Location;
    begin
        Location.Init();
        Location.Code := 'NORTH';
        Location.Name := 'North Warehouse';
        Location.Insert();

        Location.Init();
        Location.Code := 'SOUTH';
        Location.Name := 'South Warehouse';
        Location.Insert();
    end;

    local procedure CreateGLAccount()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Init();
        GLAccount."No." := '1300';
        GLAccount.Name := 'Inventory - Retail/Parts';
        GLAccount."Account Type" := 0;
        GLAccount.Insert();
    end;

    local procedure CreateGenPostingGroups()
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        GeneralPostingSetup: Record "General Posting Setup";
    begin
        GenProductPostingGroup.Init();
        GenProductPostingGroup.Code := 'GP';
        GenProductPostingGroup.Description := 'Migrated from GP';
        GenProductPostingGroup."Auto Insert Default" := true;
        GenProductPostingGroup.Insert();

        GeneralPostingSetup.Init();
        GeneralPostingSetup."Gen. Prod. Posting Group" := 'GP';
        GeneralPostingSetup."Inventory Adjmt. Account" := '1300';
        GeneralPostingSetup.Insert();
    end;

    local procedure CreateGPItemStagingTableEntries(var GPItem: Record "GP Item")
    begin
        GPItem.Init();
        GPItem.No := FIFOItemNoLbl;
        GPItem.Description := FIFOItemNoLbl;
        GPItem.SearchDescription := FIFOItemNoLbl;
        GPItem.ShortName := FIFOItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.ItemTrackingCode := '';
        GPItem.CurrentCost := 3.95;
        GPItem.StandardCost := 3.95000;
        GPItem.UnitListPrice := 5.00000;
        GPItem.ShipWeight := 0.38000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 47.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        GPItem.Init();
        GPItem.No := FIFOSerialItemNoLbl;
        GPItem.Description := FIFOSerialItemNoLbl;
        GPItem.SearchDescription := FIFOSerialItemNoLbl;
        GPItem.ShortName := FIFOSerialItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '0';
        GPItem.ItemTrackingCode := 'SERIAL';
        GPItem.CurrentCost := 3.95;
        GPItem.StandardCost := 3.95000;
        GPItem.UnitListPrice := 5.00000;
        GPItem.ShipWeight := 0.38000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 3.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := 'Each';
        GPItem.Insert();

        GPItem.Init();
        GPItem.No := StandardItemNoLbl;
        GPItem.Description := StandardItemNoLbl;
        GPItem.SearchDescription := StandardItemNoLbl;
        GPItem.ShortName := StandardItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '4';
        GPItem.ItemTrackingCode := '';
        GPItem.CurrentCost := 0.00;
        GPItem.StandardCost := 6.00000;
        GPItem.UnitListPrice := 0.00000;
        GPItem.ShipWeight := 0.00000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 4.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := '';
        GPItem.Insert();

        GPItem.Init();
        GPItem.No := StandardLotItemNoLbl;
        GPItem.Description := StandardLotItemNoLbl;
        GPItem.SearchDescription := StandardLotItemNoLbl;
        GPItem.ShortName := StandardLotItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '4';
        GPItem.ItemTrackingCode := 'LOT';
        GPItem.CurrentCost := 0.00;
        GPItem.StandardCost := 13.00000;
        GPItem.UnitListPrice := 0.00000;
        GPItem.ShipWeight := 0.00000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 10.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := '';
        GPItem.Insert();

        GPItem.Init();
        GPItem.No := AverageItemNoLbl;
        GPItem.Description := AverageItemNoLbl;
        GPItem.SearchDescription := AverageItemNoLbl;
        GPItem.ShortName := AverageItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '3';
        GPItem.ItemTrackingCode := '';
        GPItem.CurrentCost := 14.00;
        GPItem.StandardCost := 0.00000;
        GPItem.UnitListPrice := 0.00000;
        GPItem.ShipWeight := 0.00000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 6.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := '';
        GPItem.Insert();

        GPItem.Init();
        GPItem.No := AverageSerialItemNoLbl;
        GPItem.Description := AverageSerialItemNoLbl;
        GPItem.SearchDescription := AverageSerialItemNoLbl;
        GPItem.ShortName := AverageSerialItemNoLbl;
        GPItem.BaseUnitOfMeasure := 'Each';
        GPItem.ItemType := 0;
        GPItem.CostingMethod := '3';
        GPItem.ItemTrackingCode := 'SERIAL';
        GPItem.CurrentCost := 4.00;
        GPItem.StandardCost := 0.00000;
        GPItem.UnitListPrice := 0.00000;
        GPItem.ShipWeight := 0.00000;
        GPItem.InActive := false;
        GPItem.QuantityOnHand := 2.00000;
        GPItem.SalesUnitOfMeasure := 'Each';
        GPItem.PurchUnitOfMeasure := '';
        GPItem.Insert();
    end;

    local procedure CreateGPItemTransactionStagingTableEntries(var GPItemTransaction: Record "GP Item Transactions")
    begin
        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2020);
        GPItemTransaction.Quantity := 12;
        GPItemTransaction.ReceiptNumber := 'ABC';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 3.00000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(18, 3, 2020);
        GPItemTransaction.Quantity := 27;
        GPItemTransaction.ReceiptNumber := 'DEF';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 4.00000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2020);
        GPItemTransaction.Quantity := 8;
        GPItemTransaction.ReceiptNumber := 'ABC';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 3.90000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOSerialItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2022);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'A123';
        GPItemTransaction.SerialNumber := '1';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 3.95000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOSerialItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 4, 2022);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'B456';
        GPItemTransaction.SerialNumber := '2';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 3.95000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := FIFOSerialItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2022);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'A123';
        GPItemTransaction.SerialNumber := '3';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 3.95000;
        GPItemTransaction.CurrentCost := 3.95000;
        GPItemTransaction.StandardCost := 3.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := StandardItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2022);
        GPItemTransaction.Quantity := 3;
        GPItemTransaction.ReceiptNumber := 'REC1';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 0.00000;
        GPItemTransaction.CurrentCost := 0.00000;
        GPItemTransaction.StandardCost := 6.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := StandardItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(1, 1, 2019);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'REC2';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 0.00000;
        GPItemTransaction.CurrentCost := 0.00000;
        GPItemTransaction.StandardCost := 6.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := StandardLotItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(1, 1, 2019);
        GPItemTransaction.Quantity := 3;
        GPItemTransaction.ReceiptNumber := 'REC4';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := 'LOT1';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 13.00000;
        GPItemTransaction.CurrentCost := 12.50000;
        GPItemTransaction.StandardCost := 13.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := StandardLotItemNoLbl;
        GPItemTransaction.Location := 'NORTH';
        GPItemTransaction.DateReceived := DMY2Date(1, 2, 2019);
        GPItemTransaction.Quantity := 2;
        GPItemTransaction.ReceiptNumber := 'REC5';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := 'LOT2';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 13.00000;
        GPItemTransaction.CurrentCost := 12.50000;
        GPItemTransaction.StandardCost := 13.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := StandardLotItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(1, 2, 2019);
        GPItemTransaction.Quantity := 5;
        GPItemTransaction.ReceiptNumber := 'REC5';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := 'LOT3';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 13.00000;
        GPItemTransaction.CurrentCost := 12.50000;
        GPItemTransaction.StandardCost := 13.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := AverageItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 3, 2022);
        GPItemTransaction.Quantity := 3;
        GPItemTransaction.ReceiptNumber := 'REC11';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 14.00000;
        GPItemTransaction.CurrentCost := 14.00000;
        GPItemTransaction.StandardCost := 13.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := AverageItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(1, 1, 2019);
        GPItemTransaction.Quantity := 3;
        GPItemTransaction.ReceiptNumber := 'REC22';
        GPItemTransaction.SerialNumber := '';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 14.00000;
        GPItemTransaction.CurrentCost := 14.00000;
        GPItemTransaction.StandardCost := 13.95000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := AverageSerialItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 7, 2029);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'B888';
        GPItemTransaction.SerialNumber := '888';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 4.00000;
        GPItemTransaction.CurrentCost := 4.00000;
        GPItemTransaction.StandardCost := 4.00000;
        GPItemTransaction.Insert();

        GPItemTransaction.Init();
        GPItemTransaction.No := AverageSerialItemNoLbl;
        GPItemTransaction.Location := 'SOUTH';
        GPItemTransaction.DateReceived := DMY2Date(21, 7, 2029);
        GPItemTransaction.Quantity := 1;
        GPItemTransaction.ReceiptNumber := 'B888';
        GPItemTransaction.SerialNumber := '889';
        GPItemTransaction.LotNumber := '';
        GPItemTransaction.ReceiptSEQNumber := 1;
        GPItemTransaction.UnitCost := 4.00000;
        GPItemTransaction.CurrentCost := 4.00000;
        GPItemTransaction.StandardCost := 4.00000;
        GPItemTransaction.Insert();
    end;

    local procedure CreateGPPostingAccountsStagingTableEntries(GPPostingAccount: Record "GP Posting Accounts")
    begin
        GPPostingAccount.Init();
        GPPostingAccount.InventoryAccount := '1300';
        GPPostingAccount.Insert();
    end;

    local procedure CreateGPItemLocationsStagingTableEntries(GPItemLocation: Record "GP Item Location")
    begin
        GPItemLocation.Init();
        GPItemLocation.LOCNCODE := 'NORTH';
        GPItemLocation.LOCNDSCR := 'North Warehouse';
        GPItemLocation.Insert();

        GPItemLocation.Init();
        GPItemLocation.LOCNCODE := 'SOUTH';
        GPItemLocation.LOCNDSCR := 'South Warehouse';
        GPItemLocation.Insert();
    end;
}