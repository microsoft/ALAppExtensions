// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;
using Microsoft.Inventory.Journal;
using Microsoft.Inventory.Ledger;
using Microsoft.Inventory.Location;
using System.Integration;
using System.TestLibraries.Utilities;

codeunit 147610 "SL Item Migrator Tests"
{
    // [FEATURE] [SL Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestType = IntegrationTest;
    Permissions = tabledata "Item Ledger Entry" = rimd;
    TestPermissions = Disabled;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        Assert: Codeunit "Library Assert";
        SLTestHelperFunctions: Codeunit "SL Test Helper Functions";
        IsInitialized: Boolean;

    [Test]
    procedure TestSLItemImportClassMigrationOn()
    var
        SLInventory: Record "SL Inventory Buffer";
        TempItem: Record Item temporary;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        SLItemMigrator: Codeunit "SL Item Migrator";
        SLExpectedBCItemData: XmlPort "SL BC Item Data Expected";
        SLInventoryInstream: InStream;
        BCItemInstream: InStream;
    begin
        // [Scenario] Product Class migration is turned on

        // [Given] SL data
        Initialize();

        // Enable Inventory Module and Product Class settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Inventory data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLInventoryWithClassID.csv', SLInventoryInstream);
        PopulateInventoryBufferTable(SLInventoryInstream);

        // Run Inventory related migration procedures
        SLInventory.FindSet();
        repeat
            SLItemMigrator.MigrateItem(ItemDataMigrationFacade, SLInventory.RecordId);
            SLItemMigrator.MigrateItemPostingGroups(ItemDataMigrationFacade, SLInventory.RecordId, true);
        until SLInventory.Next() = 0;

        // [Then] Verify Item master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCItemWithInventoryPostingGroup.csv', BCItemInstream);
        SLExpectedBCItemData.SetSource(BCItemInstream);
        SLExpectedBCItemData.Import();
        SLExpectedBCItemData.GetExpectedItems(TempItem);
        ValidateItemData(TempItem);
    end;

    [Test]
    procedure TestSLItemImportClassMigrationOff()
    var
        SLInventory: Record "SL Inventory Buffer";
        TempItem: Record Item temporary;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        SLItemMigrator: Codeunit "SL Item Migrator";
        SLExpectedBCItemData: XmlPort "SL BC Item Data Expected";
        SLInventoryInstream: InStream;
        BCItemInstream: InStream;
    begin
        // [Scenario] Product Class migration is turned off

        // [Given] SL data
        Initialize();

        // Enable Inventory Module and Product Class settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Item Classes", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Inventory data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLInventoryWithClassID.csv', SLInventoryInstream);
        PopulateInventoryBufferTable(SLInventoryInstream);

        // Run Inventory related migration procedures
        SLInventory.FindSet();
        repeat
            SLItemMigrator.MigrateItem(ItemDataMigrationFacade, SLInventory.RecordId);
        until SLInventory.Next() = 0;

        // [Then] Verify Item master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCItemWithoutInventoryPostingGroup.csv', BCItemInstream);
        SLExpectedBCItemData.SetSource(BCItemInstream);
        SLExpectedBCItemData.Import();
        SLExpectedBCItemData.GetExpectedItems(TempItem);
        ValidateItemData(TempItem);
    end;

    [Test]
    procedure TestSLItemJournalLines()
    var
        ItemLedgerEntry: Record "Item Ledger Entry";
        SLInventory: Record "SL Inventory Buffer";
        SLItemSiteBuffer: Record "SL ItemSite Buffer";
        SLMigrationWarning: Record "SL Migration Warnings";
        TempItemJournalLine: Record "Item Journal Line" temporary;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        SLItemMigrator: Codeunit "SL Item Migrator";
        SLInventoryInstream: InStream;
        ItemJournalLineInstream: InStream;
    begin
        // [Scenario] SL Inventory Quantity and Cost migration to Item Journal Lines

        // [Given] SL data
        Initialize();

        // Enable Inventory Module and Product Class settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Only Inventory Master", false);
        SLCompanyAdditionalSettings.Validate("Migrate Item Classes", true);
        SLCompanyAdditionalSettings.Validate("Skip Posting Item Batches", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Inventory data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLInventoryForItemJournalTest.csv', SLInventoryInstream);
        PopulateInventoryBufferTable(SLInventoryInstream);
        SLTestHelperFunctions.ImportSLItemSiteBufferData();

        // Run Inventory related migration procedures
        SLInventory.FindSet();
        repeat
            SLItemMigrator.MigrateItem(ItemDataMigrationFacade, SLInventory.RecordId);
            SLItemMigrator.MigrateItemPostingGroups(ItemDataMigrationFacade, SLInventory.RecordId, true);
            SLItemMigrator.MigrateInventoryTransactions(ItemDataMigrationFacade, SLInventory.RecordId, true);
        until SLInventory.Next() = 0;

        SLHelperFunctions.PostGLTransactions();
        Assert.RecordCount(SLMigrationWarning, 0);

        // [THEN] Item Ledger Entries exist
        Assert.IsTrue(ItemLedgerEntry.Count() > 0, 'No Item Ledger Entries were created');

        // Verify Item Ledger Quantity matches SL ItemSite on hand quantity
        SLInventory.FindSet();
        repeat
            SLItemSiteBuffer.Reset();
            SLItemSiteBuffer.SetFilter(InvtID, CopyStr(SLInventory.InvtID, 1, MaxStrLen(SLItemSiteBuffer.InvtID)));
            SLItemSiteBuffer.SetFilter(QtyOnHand, '<> 0');
            SLItemSiteBuffer.FindSet();
            repeat
                ItemLedgerEntry.Reset();
                ItemLedgerEntry.SetFilter("Item No.", CopyStr(SLItemSiteBuffer.InvtID, 1, MaxStrLen(ItemLedgerEntry."Item No.")));
                ItemLedgerEntry.SetFilter("Location Code", SLItemSiteBuffer.SiteId);
                ItemLedgerEntry.FindSet();

                Assert.AreEqual(SLItemSiteBuffer.QtyOnHand, ItemLedgerEntry.Quantity, 'Quantity does not match for Item (' + ItemLedgerEntry."Item No." + ')' + ' at Location (' + ItemLedgerEntry."Location Code" + ')');

            until SLItemSiteBuffer.Next() = 0;
        until SLInventory.Next() = 0;
    end;

    local procedure PopulateInventoryBufferTable(var Instream: InStream)
    begin
        // Populate Inventory buffer table
        Xmlport.Import(Xmlport::"SL Inventory Data", Instream);
    end;

    local procedure ValidateItemData(var TempItem: Record Item temporary)
    var
        Item: Record Item;
    begin
        TempItem.Reset();
        TempItem.FindSet();
        repeat
            Assert.IsTrue(Item.Get(TempItem."No."), 'Item does not exist in BC (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem.Description, Item.Description, 'Description does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Search Description", Item."Search Description", 'Search Description does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Base Unit of Measure", Item."Base Unit of Measure", 'Base Unit of Measure does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem.Type, Item.Type, 'Type does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Inventory Posting Group", Item."Inventory Posting Group", 'Inventory Posting Group does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Unit Price", Item."Unit Price", 'Unit Price does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Costing Method", Item."Costing Method", 'Costing Method does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Standard Cost", Item."Standard Cost", 'Standard Cost does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem.Blocked, Item.Blocked, 'Blocked status does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Block Reason", Item."Block Reason", 'Block Reason does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Sales Unit of Measure", Item."Sales Unit of Measure", 'Sales Unit of Measure does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Purch. Unit of Measure", Item."Purch. Unit of Measure", 'Purch. Unit of Measure does not match for Item (' + TempItem."No." + ')');
            Assert.AreEqual(TempItem."Item Tracking Code", Item."Item Tracking Code", 'Item Tracking Code does not match for Item (' + TempItem."No." + ')');
        until TempItem.Next() = 0;
    end;

    local procedure Initialize()
    var
        SLInventory: Record "SL Inventory Buffer";
        SLProductClass: Record "SL ProductClass";
    begin
        // Delete/empty buffer tables        
        SLInventory.DeleteAll();
        SLProductClass.DeleteAll();

        SLTestHelperFunctions.ClearBCItemTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportSLProductClassData();

        if IsInitialized then
            exit;

        // Import supporting data
        SLTestHelperFunctions.ImportDataMigrationStatus();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportGenProductPostingGroupData();
        SLTestHelperFunctions.ImportSLINSetupData();
        SLTestHelperFunctions.ImportItemTrackingCodeData();
        SLTestHelperFunctions.ImportSLSiteData();
        CreateLocations();
        Commit();
        IsInitialized := true;
    end;

    local procedure CreateLocations()
    var
        SLSite: Record "SL Site";
        Location: Record Location;
    begin
        if SLSite.FindSet() then
            repeat
                if not Location.Get(SLSite.SiteId) then begin
                    Clear(Location);
                    Location.Validate("Code", SLSite.SiteId);
                    Location.Name := SLSite.Name;
                    Location.Address := SLSite.Addr1;
                    Location."Address 2" := CopyStr(SLSite.Addr2, 1, 50);
                    Location.Validate(City, SLSite.City);
                    Location."Phone No." := SLSite.Phone;
                    Location."Fax No." := SLSite.Fax;
                    Location.Validate("Post Code", SLSite.Zip);
                    Location.Insert(true);
                end;
            until SLSite.Next() = 0;
    end;
}