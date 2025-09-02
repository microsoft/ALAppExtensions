// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using System.TestLibraries.Utilities;
using Microsoft.Inventory.Item;
using System.Integration;

codeunit 147610 "SL Item Migrator Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        Assert: Codeunit "Library Assert";
        SLTestHelperFunctions: Codeunit "SL Test Helper Functions";
        IsInitialized: Boolean;

    [Test]
    procedure TestSLItemImportClassMigrationOn()
    var
        SLInventory: Record "SL Inventory";
        TempItem: Record Item temporary;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        SLItemMigrator: Codeunit "SL Item Migrator";
        SLExpectedBCItemData: XmlPort "SL BC Item Data";
        SLInventoryInstream: InStream;
        BCItemInstream: InStream;
    begin
        // [Scenario] Product Class migration is turned on

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCItemTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

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
        SLInventory: Record "SL Inventory";
        TempItem: Record Item temporary;
        ItemDataMigrationFacade: Codeunit "Item Data Migration Facade";
        SLItemMigrator: Codeunit "SL Item Migrator";
        SLExpectedBCItemData: XmlPort "SL BC Item Data";
        SLInventoryInstream: InStream;
        BCItemInstream: InStream;
    begin
        // [Scenario] Product Class migration is turned off

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCItemTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

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
            SLItemMigrator.MigrateItemPostingGroups(ItemDataMigrationFacade, SLInventory.RecordId, true);
        until SLInventory.Next() = 0;

        // [Then] Verify Item master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCItemWithoutInventoryPostingGroup.csv', BCItemInstream);
        SLExpectedBCItemData.SetSource(BCItemInstream);
        SLExpectedBCItemData.Import();
        SLExpectedBCItemData.GetExpectedItems(TempItem);
        ValidateItemData(TempItem);
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
        SLInventory: Record "SL Inventory";
        SLProductClass: Record "SL ProductClass";
    begin
        // Delete/empty buffer tables        
        SLInventory.DeleteAll();
        SLProductClass.DeleteAll();

        if IsInitialized then
            exit;

        // Import supporting data
        SLTestHelperFunctions.ImportDataMigrationStatus();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportGenProductPostingGroupData();
        SLTestHelperFunctions.ImportSLINSetupData();
        SLTestHelperFunctions.ImportSLProductClassData();
        SLTestHelperFunctions.ImportItemTrackingCodeData();
        Commit();
        IsInitialized := true;
    end;
}

