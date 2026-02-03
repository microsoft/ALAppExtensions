// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Address;
using Microsoft.Foundation.Shipping;
using Microsoft.Sales.Customer;
using System.Integration;
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
        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportGLAccountData();
        Commit();

        // Enable Receivables Module and Customer classes settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        SLCompanyAdditionalSettings.Modify();

        // [When] Customer data is imported
        SLTestHelperFunctions.ImportSLCustomerData();

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
        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportGLAccountData();
        Commit();

        // Enable Receivables module and disable Customer Class setting
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", false);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Customer data is imported
        SLTestHelperFunctions.ImportSLCustomerData();

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
        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportGLAccountData();
        Commit();

        // Select Receivables module and Inactive Customer options
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inactive Customers", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [When] Customer data is imported
        SLTestHelperFunctions.ImportSLCustomerData();

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
        SLTestHelperFunctions.ImportSLCustomerData();

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

    [Test]
    procedure TestCustomerTransactions()
    var
        SLCustomer: Record "SL Customer";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        CustomerDataMigrationFacade: Codeunit "Customer Data Migration Facade";
        SLCustomerMigrator: Codeunit "SL Customer Migrator";
        SLExpectedBCGenJournalLineData: XmlPort "SL BC Gen. Journal Line Data";
        BCGenJournalLineInstream: InStream;
    begin
        IsInitialized := false;
        // [Scenario] Open Customer balances should be migrated to BC
        Initialize();
        SLTestHelperFunctions.ClearAccountTableData();

        // [Given] SL ARDoc data
        SLTestHelperFunctions.ImportSLARDocBufferData();

        // Import supporting test data
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportSLBatchData();
        SLTestHelperFunctions.ImportGLAccountData();
        Commit();

        // Set Congfiguration Settings for AR Module
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate GL Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        SLCompanyAdditionalSettings.Validate("Skip Posting Customer Batches", true);
        SLCompanyAdditionalSettings.Modify();

        // [When] Migrating open Customer balances, create general journal entries
        // Run Migrate Customer Transactions
        SLCustomer.FindSet();
        repeat
            SLCustomerMigrator.MigrateCustomer(CustomerDataMigrationFacade, SLCustomer.RecordId);
            SLCustomerMigrator.MigrateCustomerPostingGroups(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
            SLCustomerMigrator.MigrateCustomerTransactions(CustomerDataMigrationFacade, SLCustomer.RecordId, true);
        until SLCustomer.Next() = 0;

        // [Then] Verify Customer open balance data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCGenJournalLineOpenAR.csv', BCGenJournalLineInstream);
        SLExpectedBCGenJournalLineData.SetSource(BCGenJournalLineInstream);
        SLExpectedBCGenJournalLineData.Import();
        SLExpectedBCGenJournalLineData.GetExpectedGenJournalLines(TempGenJournalLine);
        ValidateCustomerOpenBalanceData(TempGenJournalLine);
    end;

    procedure ValidateCustomerOpenBalanceData(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        TempGenJournalLine.SetRange("Journal Batch Name", 'SLCUST');
        TempGenJournalLine.FindSet();
        repeat
            Assert.IsTrue(GenJournalLine.Get(TempGenJournalLine."Journal Template Name", TempGenJournalLine."Journal Batch Name", TempGenJournalLine."Line No."), 'Open AR Journal Line does not exist in BC (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Account No.", TempGenJournalLine."Account No.", 'Account No. does not match for Open AR Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine.Amount, TempGenJournalLine.Amount, 'Amount does not match for Open AR Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Debit Amount", TempGenJournalLine."Debit Amount", 'Debit Amount does not match for Open AR Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Credit Amount", TempGenJournalLine."Credit Amount", 'Credit Amount does not match for Open AR Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
        until TempGenJournalLine.Next() = 0;
    end;

    local procedure Initialize()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ShipmentMethod: Record "Shipment Method";
        SLCustomer: Record "SL Customer";
        SLCustClass: Record "SL CustClass";
        ZipCode: Record "Post Code";
    begin
        // Delete/empty buffer tables        
        GenJournalLine.DeleteAll(true);
        SLCustomer.DeleteAll(true);
        SLCustClass.DeleteAll(true);

        if IsInitialized then
            exit;

        ShipmentMethod.DeleteAll(true);
        ZipCode.DeleteAll(true);

        // Import supporting data
        SLTestHelperFunctions.ImportDataMigrationStatus();
        SLTestHelperFunctions.ImportGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportSLARSetupData();
        SLTestHelperFunctions.ImportSLSalesTaxData();
        SLTestHelperFunctions.ImportSLSOAddressData();
        SLTestHelperFunctions.ImportSLCustClassData();
        SLTestHelperFunctions.ImportSLCustomerData();
        Commit();
        IsInitialized := true;
    end;
}
