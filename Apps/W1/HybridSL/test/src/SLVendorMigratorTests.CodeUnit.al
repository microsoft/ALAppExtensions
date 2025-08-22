// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Foundation.Address;
using System.TestLibraries.Utilities;
using Microsoft.Purchases.Vendor;

codeunit 147603 "SL Vendor Migrator Tests"
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
    procedure TestSLVendorImportClassMigrationOn()
    var
        SLVendor: Record "SL Vendor";
        TempVendor: Record Vendor temporary;
        VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        SLVendorMigrator: Codeunit "SL Vendor Migrator";
        SLExpectedBCVendorData: XmlPort "SL BC Vendor Data";
        SLVendorInstream: InStream;
        BCVendorInstream: InStream;
    begin
        // [Scenario] Vendor Class migration is turned on

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module and Vendor classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        SLCompanyAdditionalSettings.Modify();

        // [When] Vendor data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLVendorWithClassID.csv', SLVendorInstream);
        PopulateVendorBufferTable(SLVendorInstream);

        // Run Vendor related migration procedures
        SLVendor.FindSet();
        repeat
            SLVendorMigrator.MigrateVendor(VendorDataMigrationFacade, SLVendor.RecordId);
            SLVendorMigrator.MigrateVendorPostingGroups(VendorDataMigrationFacade, SLVendor.RecordId, true);
        until SLVendor.Next() = 0;

        // [Then] Verify Vendor master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorWithVendorPostingGroup.csv', BCVendorInstream);
        SLExpectedBCVendorData.SetSource(BCVendorInstream);
        SLExpectedBCVendorData.Import();
        SLExpectedBCVendorData.GetExpectedVendors(TempVendor);
        ValidateVendorData(TempVendor);
    end;

    [Test]
    procedure TestSLVendorImportClassMigrationOff()
    var
        SLVendor: Record "SL Vendor";
        TempVendor: Record Vendor temporary;
        VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        SLVendorMigrator: Codeunit "SL Vendor Migrator";
        SLExpectedBCVendorData: XmlPort "SL BC Vendor Data";
        SLVendorInstream: InStream;
        BCVendorInstream: InStream;
    begin
        // [Scenario] Vendor Class migration is turned off

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module and disable Vendor classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Vendor Classes", false);
        SLCompanyAdditionalSettings.Modify();

        // [When] Vendor data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLVendorWithClassID.csv', SLVendorInstream);
        PopulateVendorBufferTable(SLVendorInstream);

        // Run Vendor related migration procedures
        SLVendor.FindSet();
        repeat
            SLVendorMigrator.MigrateVendor(VendorDataMigrationFacade, SLVendor.RecordId);
            SLVendorMigrator.MigrateVendorPostingGroups(VendorDataMigrationFacade, SLVendor.RecordId, true);
        until SLVendor.Next() = 0;

        // [Then] Verify Vendor master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorWithoutVendorPostingGroup.csv', BCVendorInstream);
        SLExpectedBCVendorData.SetSource(BCVendorInstream);
        SLExpectedBCVendorData.Import();
        SLExpectedBCVendorData.GetExpectedVendors(TempVendor);
        ValidateVendorData(TempVendor);
    end;

    [Test]
    procedure TestSLVendorImportWithInactiveVendors()
    var
        SLVendor: Record "SL Vendor";
        TempVendor: Record Vendor temporary;
        VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        SLVendorMigrator: Codeunit "SL Vendor Migrator";
        SLExpectedBCVendorData: XmlPort "SL BC Vendor Data";
        SLVendorInstream: InStream;
        BCVendorInstream: InStream;
    begin
        // [Scenario] Inactive Vendors is turned on

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module and Vendor classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Vendor data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLVendorWithClassID.csv', SLVendorInstream);
        PopulateVendorBufferTable(SLVendorInstream);

        // Run Vendor related migration procedures
        SLVendor.FindSet();
        repeat
            SLVendorMigrator.MigrateVendor(VendorDataMigrationFacade, SLVendor.RecordId);
            SLVendorMigrator.MigrateVendorPostingGroups(VendorDataMigrationFacade, SLVendor.RecordId, true);
        until SLVendor.Next() = 0;

        // [Then] Verify Vendor master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorWithInactiveVendors.csv', BCVendorInstream);
        SLExpectedBCVendorData.SetSource(BCVendorInstream);
        SLExpectedBCVendorData.Import();
        SLExpectedBCVendorData.GetExpectedVendors(TempVendor);
        ValidateVendorData(TempVendor);
    end;

    [Test]
    procedure TestSLVendorImportWithoutInactiveVendors()
    var
        SLVendor: Record "SL Vendor";
        TempVendor: Record Vendor temporary;
        VendorDataMigrationFacade: Codeunit "Vendor Data Migration Facade";
        SLVendorMigrator: Codeunit "SL Vendor Migrator";
        SLExpectedBCVendorData: XmlPort "SL BC Vendor Data";
        SLVendorInstream: InStream;
        BCVendorInstream: InStream;
    begin
        // [Scenario] Inactive Vendors is turned off

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Payables Module and Vendor classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inactive Vendors", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Vendor data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLVendorWithClassID.csv', SLVendorInstream);
        PopulateVendorBufferTable(SLVendorInstream);

        // Run Vendor related migration procedures
        SLVendor.FindSet();
        repeat
            SLVendorMigrator.MigrateVendor(VendorDataMigrationFacade, SLVendor.RecordId);
            SLVendorMigrator.MigrateVendorPostingGroups(VendorDataMigrationFacade, SLVendor.RecordId, true);
        until SLVendor.Next() = 0;

        // [Then] Verify Vendor master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorWithoutInactiveVendors.csv', BCVendorInstream);
        SLExpectedBCVendorData.SetSource(BCVendorInstream);
        SLExpectedBCVendorData.Import();
        SLExpectedBCVendorData.GetExpectedVendors(TempVendor);
        ValidateVendorData(TempVendor);
    end;

    local procedure PopulateVendorBufferTable(var Instream: InStream)
    begin
        // Populate Vendor buffer table
        Xmlport.Import(Xmlport::"SL Vendor Data", Instream);
    end;

    local procedure ValidateVendorData(var TempVendor: Record Vendor temporary)
    var
        Vendor: Record Vendor;
    begin
        TempVendor.Reset();
        TempVendor.FindSet();
        repeat
            Assert.IsTrue(Vendor.Get(TempVendor."No."), 'Vendor does not exist in BC' + ' (Vendor: ' + TempVendor."No." + ')');
            Assert.AreEqual(TempVendor.Name, Vendor.Name, 'Vendor Name does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Search Name", Vendor."Search Name", 'Vendor Search Name does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Name 2", Vendor."Name 2", 'Vendor Name 2 does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor.Address, Vendor.Address, 'Vendor Address does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Address 2", Vendor."Address 2", 'Vendor Address 2 does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor.City, Vendor.City, 'Vendor City does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Contact", Vendor."Contact", 'Vendor Contact does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Phone No.", Vendor."Phone No.", 'Vendor Phone No. does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Vendor Posting Group", Vendor."Vendor Posting Group", 'Vendor Vendor Posting Group does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Payment Terms Code", Vendor."Payment Terms Code", 'Vendor Payment Terms Code does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Country/Region Code", Vendor."Country/Region Code", 'Vendor Country/Region Code does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor.Blocked, Vendor.Blocked, 'Vendor Blocked does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Fax No.", Vendor."Fax No.", 'Vendor Fax No. does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."VAT Registration No.", Vendor."VAT Registration No.", 'Vendor VAT Registration No. does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Gen. Bus. Posting Group", Vendor."Gen. Bus. Posting Group", 'Vendor Gen. Bus. Posting Group does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Post Code", Vendor."Post Code", 'Vendor Post Code does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor.County, Vendor.County, 'Vendor County does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."E-Mail", Vendor."E-Mail", 'Vendor E-Mail does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Tax Area Code", Vendor."Tax Area Code", 'Vendor Tax Area Code does not match' + ' (Vendor: ' + Vendor."No." + ')');
            Assert.AreEqual(TempVendor."Tax Liable", Vendor."Tax Liable", 'Vendor Tax Liable does not match' + ' (Vendor: ' + Vendor."No." + ')');
        until TempVendor.Next() = 0;
    end;

    local procedure Initialize()
    var
        SLVendor: Record "SL Vendor";
        SLVendClass: Record "SL VendClass";
        ZipCode: Record "Post Code";
    begin
        // Delete/empty buffer tables        
        SLVendor.DeleteAll();
        SLVendClass.DeleteAll();

        if IsInitialized then
            exit;

        // ShipmentMethod.DeleteAll();
        ZipCode.DeleteAll();

        // Import supporting data
        SLTestHelperFunctions.ImportDataMigrationStatus();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportSLAPSetupData();
        SLTestHelperFunctions.ImportSLSalesTaxData();
        SLTestHelperFunctions.ImportSLVendClassData();
        Commit();
        IsInitialized := true;
    end;
}
