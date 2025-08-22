// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Foundation.Shipping;
using Microsoft.Foundation.Address;
using Microsoft.Sales.Customer;
using System.TestLibraries.Utilities;

codeunit 147600 "SL Customer Migrator Tests"
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
    procedure TestSLCustomerImportClassMigrationOn()
    var
        SLCustomer: Record "SL Customer";
        TempCustomer: Record Customer temporary;
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLExpectedBCCustomerData: XmlPort "SL BC Customer Data";
        SLCustomerInstream: InStream;
        BCCustomerInstream: InStream;
    begin
        // [Scenario] Customer Class migration is turned on

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Receivables Module and Customer classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        SLCompanyAdditionalSettings.Modify();

        // [When] Customer data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLCustomerWithClassID.csv', SLCustomerInstream);
        PopulateCustomerBufferTable(SLCustomerInstream);

        // Run Customer related migration procedures
        SLCustomer.FindSet();
        repeat
            SLCustomerMigrator.MigrateCustomer(CustomerDataMigrationFacade, SLCustomer.RecordId);
            SLCustomerMigrator.MigrateCustomerPostingGroups(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
        until SLCustomer.Next() = 0;

        // [Then] Verify Customer master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCCustomerWithCustomerPostingGroup.csv', BCCustomerInstream);
        SLExpectedBCCustomerData.SetSource(BCCustomerInstream);
        SLExpectedBCCustomerData.Import();
        SLExpectedBCCustomerData.GetExpectedCustomers(TempCustomer);
        ValidateCustomerData(TempCustomer);
    end;

    [Test]
    procedure TestSLCustomerImportClassMigrationOff()
    var
        SLCustomer: Record "SL Customer";
        TempCustomer: Record Customer temporary;
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLExpectedBCCustomerData: XmlPort "SL BC Customer Data";
        SLCustomerInstream: InStream;
        BCCustomerInstream: InStream;
    begin
        // [Scenario] Customer Class migration is turned off

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCCustomerTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Receivables module and disable Customer Class setting
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Customer data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLCustomerWithClassID.csv', SLCustomerInstream);
        PopulateCustomerBufferTable(SLCustomerInstream);

        // Run Customer related migration procedures
        SLCustomer.FindSet();
        repeat
            SLCustomerMigrator.MigrateCustomer(CustomerDataMigrationFacade, SLCustomer.RecordId);
            SLCustomerMigrator.MigrateCustomerPostingGroups(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
        until SLCustomer.Next() = 0;

        // [Then] Verify Customer master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCCustomerWithoutCustomerPostingGroup.csv', BCCustomerInstream);
        SLExpectedBCCustomerData.SetSource(BCCustomerInstream);
        SLExpectedBCCustomerData.Import();
        SLExpectedBCCustomerData.GetExpectedCustomers(TempCustomer);
        ValidateCustomerData(TempCustomer);
    end;

    [Test]
    procedure TestSLCustomerImportWithInactiveCustomers()
    var
        SLCustomer: Record "SL Customer";
        TempCustomer: Record Customer temporary;
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLExpectedBCCustomerData: XmlPort "SL BC Customer Data";
        SLCustomerInstream: InStream;
        BCCustomerInstream: InStream;
    begin
        // [Scenario] Inactive Customers is turned on

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCCustomerTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Select Receivables module and Inactive Customer options
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inactive Customers", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Customer data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLCustomerWithClassID.csv', SLCustomerInstream);
        PopulateCustomerBufferTable(SLCustomerInstream);

        // Run Customer related migration procedures
        SLCustomer.FindSet();
        repeat
            SLCustomerMigrator.MigrateCustomer(CustomerDataMigrationFacade, SLCustomer.RecordId);
            SLCustomerMigrator.MigrateCustomerPostingGroups(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
        until SLCustomer.Next() = 0;

        // [Then] Verify Customer master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCCustomerWithInactiveCustomers.csv', BCCustomerInstream);
        SLExpectedBCCustomerData.SetSource(BCCustomerInstream);
        SLExpectedBCCustomerData.Import();
        SLExpectedBCCustomerData.GetExpectedCustomers(TempCustomer);
        ValidateCustomerData(TempCustomer);
    end;

    [Test]
    procedure TestSLCustomerImportWithoutInactiveCustomers()
    var
        SLCustomer: Record "SL Customer";
        TempCustomer: Record Customer temporary;
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLExpectedBCCustomerData: XmlPort "SL BC Customer Data";
        SLCustomerInstream: InStream;
        BCCustomerInstream: InStream;
    begin
        // [Scenario] Inactive Customers is turned off

        // [Given] SL data
        Initialize();
        SLTestHelperFunctions.ClearBCCustomerTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Select Receivables module and deselect Inactive Customer option
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inactive Customers", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Customer data is imported
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/input/SLTables/SLCustomerWithClassID.csv', SLCustomerInstream);
        PopulateCustomerBufferTable(SLCustomerInstream);

        // Run Customer related migration procedures
        SLCustomer.FindSet();
        repeat
            SLCustomerMigrator.MigrateCustomer(CustomerDataMigrationFacade, SLCustomer.RecordId);
            SLCustomerMigrator.MigrateCustomerPostingGroups(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
        until SLCustomer.Next() = 0;

        // [Then] Verify Customer master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCCustomerWithoutInactiveCustomers.csv', BCCustomerInstream);
        SLExpectedBCCustomerData.SetSource(BCCustomerInstream);
        SLExpectedBCCustomerData.Import();
        SLExpectedBCCustomerData.GetExpectedCustomers(TempCustomer);
        ValidateCustomerData(TempCustomer);
    end;

    local procedure PopulateCustomerBufferTable(var Instream: InStream)
    begin
        // Populate Customer buffer table
        Xmlport.Import(Xmlport::"SL Customer Data", Instream);
    end;

    local procedure ValidateCustomerData(var TempCustomer: Record Customer temporary)
    var
        Customer: Record Customer;
    begin
        TempCustomer.Reset();
        TempCustomer.FindSet();
        repeat
            Assert.IsTrue(Customer.Get(TempCustomer."No."), 'Customer does not exist in BC ' + ' (Customer: ' + TempCustomer."No." + ')');
            Assert.AreEqual(TempCustomer.Name, Customer.Name, 'Customer Name does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Search Name", Customer."Search Name", 'Customer Search Name does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Name 2", Customer."Name 2", 'Customer Name 2 does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer.Address, Customer.Address, 'Customer Address does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Address 2", Customer."Address 2", 'Customer Address 2 does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer.City, Customer.City, 'Customer City does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Contact", Customer."Contact", 'Customer Contact does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Phone No.", Customer."Phone No.", 'Customer Phone No. does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Territory Code", Customer."Territory Code", 'Customer Territory Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Credit Limit (LCY)", Customer."Credit Limit (LCY)", 'Customer Credit Limit does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Customer Posting Group", Customer."Customer Posting Group", 'Customer Posting Group does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Payment Terms Code", Customer."Payment Terms Code", 'Customer Payment Terms Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Salesperson Code", Customer."Salesperson Code", 'Customer Salesperson Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Post Code", Customer."Post Code", 'Customer Post Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Country/Region Code", Customer."Country/Region Code", 'Customer Country/Region Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer.Blocked, Customer.Blocked, 'Customer Blocked does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Fax No.", Customer."Fax No.", 'Customer Fax No. does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Gen. Bus. Posting Group", Customer."Gen. Bus. Posting Group", 'Customer Gen. Bus. Posting Group does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Tax Area Code", Customer."Tax Area Code", 'Customer Tax Area Code does not match' + ' (Customer: ' + Customer."No." + ')');
            Assert.AreEqual(TempCustomer."Tax Liable", Customer."Tax Liable", 'Customer Tax Liable does not match' + ' (Customer: ' + Customer."No." + ')');
        until TempCustomer.Next() = 0;
    end;

    local procedure Initialize()
    var
        ShipmentMethod: Record "Shipment Method";
        SLCustomer: Record "SL Customer";
        SLCustClass: Record "SL CustClass";
        ZipCode: Record "Post Code";

    begin
        // Delete/empty buffer tables        
        SLCustomer.DeleteAll();
        SLCustClass.DeleteAll();

        if IsInitialized then
            exit;

        ShipmentMethod.DeleteAll();
        ZipCode.DeleteAll();

        // Import supporting data
        SLTestHelperFunctions.ImportDataMigrationStatus();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportSLARSetupData();
        SLTestHelperFunctions.ImportSLSalesTaxData();
        SLTestHelperFunctions.ImportSLSOAddressData();
        SLTestHelperFunctions.ImportSLCustClassData();
        Commit();
        IsInitialized := true;
    end;
}
