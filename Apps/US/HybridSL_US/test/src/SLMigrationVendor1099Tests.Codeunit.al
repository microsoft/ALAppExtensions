// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Payables;
using Microsoft.Purchases.Vendor;
using System.TestLibraries.Utilities;

codeunit 147650 "SL Migration Vendor 1099 Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;
    Permissions = tabledata "Detailed Vendor Ledg. Entry" = rimd,
                  tabledata "Vendor Ledger Entry" = rimd;

    var
        Assert: Codeunit "Library Assert";
        SLTestHelperFunctions: Codeunit "SL Test Helper Functions";
        IsInitialized: Boolean;

    [Test]
    procedure TestVendor1099Migration()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        TempVendor: Record Vendor temporary;
        TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        SLCloudMigrationUS: Codeunit "SL Cloud Migration US";
        ExpectedVendorData: XmlPort "SL BC Vendor With 1099 Data";
        ExpectedSLVendorLedgerEntryData: XmlPort "SL BC Vendor Ledger Entry Data";
        VendorInstream: InStream;
        VendorLedgerEntryInstream: InStream;
    begin
        // [Given] SL Data
        Initialize();

        // Enable Current 1099 Year and Next 1099 Year migration in SL Company Additional Settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Current 1099 Year", true);
        SLCompanyAdditionalSettings.Validate("Migrate Next 1099 Year", true);
        SLCompanyAdditionalSettings.Modify();

        // Import test data  
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportVendorPostingGroupData();
        SLTestHelperFunctions.ImportSLVendorData();
        SLTestHelperFunctions.ImportBCVendorDataNo1099();
        SLTestHelperFunctions.ImportSLAPBalancesData();

        // [When] SL migration has completed and the Vendor 1099 migration has started
        SLCloudMigrationUS.RunPostMigration();

        // [Then] Validate BC Vendor 1099 data has been populated correctly
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorWith1099.csv', VendorInstream);
        ExpectedVendorData.SetSource(VendorInstream);
        ExpectedVendorData.Import();
        ExpectedVendorData.GetExpectedVendors(TempVendor);
        ValidateVendor1099Data(TempVendor);

        // [Then] The Vendor will have Vendor Ledger Entries applied correctly
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCVendorLedgerEntry.csv', VendorLedgerEntryInstream);
        ExpectedSLVendorLedgerEntryData.SetSource(VendorLedgerEntryInstream);
        ExpectedSLVendorLedgerEntryData.Import();
        ExpectedSLVendorLedgerEntryData.GetExpectedVendorLedgerEntries(TempVendorLedgerEntry);
        ValidateVendorLedgerEntryData(TempVendorLedgerEntry);
    end;

    [Test]
    procedure TestMappingCreated()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLSupportedTaxYear: Record "SL Supported Tax Year";
        TempSL1099BoxMapping: Record "SL 1099 Box Mapping" temporary;
        TempSLSupportedTaxYear: Record "SL Supported Tax Year" temporary;
        SLCloudMigrationUS: Codeunit "SL Cloud Migration US";
        ExpectedSL1099BoxMappingData: XmlPort "SL 1099 Box Mapping Data";
        ExpectedSLSupportedTaxYearData: XmlPort "SL Supported Tax Year Data";
        SL1099BoxMappingInstream: InStream;
        SLSupportedTaxYearInstream: InStream;
    begin
        // [Scenario] Current 1099 Year and Next 1099 Year migration enabled in SL Company Additional Settings

        // [Given] SL Data
        Initialize();

        // Enable Current 1099 Year and Next 1099 Year migration in SL Company Additional Settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Current 1099 Year", true);
        SLCompanyAdditionalSettings.Validate("Migrate Next 1099 Year", true);
        SLCompanyAdditionalSettings.Modify();

        // Import test data
        SLTestHelperFunctions.ImportSLVendorData();
        SLTestHelperFunctions.ImportBCVendorDataNo1099();

        // [When] SL migration has completed and the Vendor 1099 migration has started
        SLCloudMigrationUS.RunPostMigration();

        // [Then] Mappings will be present for the supported tax years
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SL1099BoxMapping.csv', SL1099BoxMappingInstream);
        ExpectedSL1099BoxMappingData.SetSource(SL1099BoxMappingInstream);
        ExpectedSL1099BoxMappingData.Import();
        ExpectedSL1099BoxMappingData.GetExpectedSL1099BoxMapping(TempSL1099BoxMapping);
        ValidateSL1099BoxMappingData(TempSL1099BoxMapping);

        // [Then] Validate supported tax years
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLSupportedTaxYear.csv', SLSupportedTaxYearInstream);
        ExpectedSLSupportedTaxYearData.SetSource(SLSupportedTaxYearInstream);
        ExpectedSLSupportedTaxYearData.Import();
        ExpectedSLSupportedTaxYearData.GetExpectedSLSupportedTaxYear(TempSLSupportedTaxYear);
        ValidateSLSupportedTaxYearData(TempSLSupportedTaxYear);
    end;


    local procedure ValidateSLSupportedTaxYearData(var TempSLSupportedTaxYear: Record "SL Supported Tax Year" temporary)
    var
        SLSupportedTaxYear: Record "SL Supported Tax Year";
    begin
        TempSLSupportedTaxYear.Reset();
        TempSLSupportedTaxYear.FindSet();
        repeat
            Assert.IsTrue(SLSupportedTaxYear.Get(TempSLSupportedTaxYear."Tax Year"), 'SL Supported Tax Year record not found for Tax Year ' + Format(TempSLSupportedTaxYear."Tax Year"));
        until TempSLSupportedTaxYear.Next() = 0;
    end;

    local procedure ValidateSL1099BoxMappingData(var TempSL1099BoxMapping: Record "SL 1099 Box Mapping" temporary)
    var
        SL1099BoxMapping: Record "SL 1099 Box Mapping";
    begin
        TempSL1099BoxMapping.Reset();
        TempSL1099BoxMapping.FindSet();
        repeat
            Assert.IsTrue(SL1099BoxMapping.Get(TempSL1099BoxMapping."Tax Year", TempSL1099BoxMapping."SL Data Value"), 'SL 1099 Box Mapping record not found for Tax Year ' + Format(TempSL1099BoxMapping."Tax Year") + ' and SL Data Value ' + TempSL1099BoxMapping."SL Data Value");
            Assert.AreEqual(TempSL1099BoxMapping."SL 1099 Box No.", SL1099BoxMapping."SL 1099 Box No.", 'SL 1099 Box No. does not match for Tax Year ' + Format(TempSL1099BoxMapping."Tax Year") + ' and SL Data Value ' + TempSL1099BoxMapping."SL Data Value");
            Assert.AreEqual(TempSL1099BoxMapping."Form Type", SL1099BoxMapping."Form Type", 'Form Type does not match for Tax Year ' + Format(TempSL1099BoxMapping."Tax Year") + ' and SL Data Value ' + TempSL1099BoxMapping."SL Data Value");
            Assert.AreEqual(TempSL1099BoxMapping."BC IRS 1099 Code", SL1099BoxMapping."BC IRS 1099 Code", 'BC IRS 1099 Code does not match for Tax Year ' + Format(TempSL1099BoxMapping."Tax Year") + ' and SL Data Value ' + TempSL1099BoxMapping."SL Data Value");
        until TempSL1099BoxMapping.Next() = 0;
    end;

    local procedure ValidateVendor1099Data(var TempVendor: Record Vendor temporary)
    var
        Vendor: Record Vendor;
    begin
        TempVendor.Reset();
        TempVendor.FindSet();
        repeat
            Assert.IsTrue(Vendor.Get(TempVendor."No."), 'Vendor record not found for No. ' + TempVendor."No.");
            Assert.AreEqual(TempVendor."Federal ID No.", Vendor."Federal ID No.", 'Federal ID No. does not match for Vendor No. ' + TempVendor."No.");
            Assert.AreEqual(TempVendor."FATCA Requirement", Vendor."FATCA Requirement", 'FATCA Requirement does not match for Vendor No. ' + TempVendor."No.");
            Assert.AreEqual(TempVendor."Tax Identification Type", Vendor."Tax Identification Type", 'Tax Identification Type does not match for Vendor No. ' + TempVendor."No.");
        until TempVendor.Next() = 0;
    end;

    local procedure ValidateVendorLedgerEntryData(var TempVendorLedgerEntry: Record "Vendor Ledger Entry" temporary)
    var
        VendorLedgerEntry: Record "Vendor Ledger Entry";
    begin
        TempVendorLedgerEntry.Reset();
        TempVendorLedgerEntry.FindSet();
        repeat
            VendorLedgerEntry.SetRange("Vendor No.", TempVendorLedgerEntry."Vendor No.");
            VendorLedgerEntry.SetRange("Posting Date", TempVendorLedgerEntry."Posting Date");
            VendorLedgerEntry.SetRange("Document Type", TempVendorLedgerEntry."Document Type");
            VendorLedgerEntry.SetRange("Document No.", TempVendorLedgerEntry."Document No.");
            Assert.IsTrue(VendorLedgerEntry.Count() > 0, 'Vendor Ledger Entry record not found for Vendor No. ' + TempVendorLedgerEntry."Vendor No." + ', Posting Date ' + Format(TempVendorLedgerEntry."Posting Date") + ', Document Type ' + Format(TempVendorLedgerEntry."Document Type") + ', Document No. ' + TempVendorLedgerEntry."Document No.");
            VendorLedgerEntry.FindFirst();
            Assert.AreEqual(TempVendorLedgerEntry."IRS 1099 Subject For Reporting", VendorLedgerEntry."IRS 1099 Subject For Reporting", 'IRS 1099 Subject For Reporting does not match for Vendor Ledger Entry No. ' + Format(TempVendorLedgerEntry."Entry No."));
            Assert.AreEqual(TempVendorLedgerEntry."IRS 1099 Reporting Period", VendorLedgerEntry."IRS 1099 Reporting Period", 'IRS 1099 Reporting Period does not match for Vendor Ledger Entry No. ' + Format(TempVendorLedgerEntry."Entry No."));
            Assert.AreEqual(TempVendorLedgerEntry."IRS 1099 Form No.", VendorLedgerEntry."IRS 1099 Form No.", 'IRS 1099 Form No. does not match for Vendor Ledger Entry No. ' + Format(TempVendorLedgerEntry."Entry No."));
            Assert.AreEqual(TempVendorLedgerEntry."IRS 1099 Form Box No.", VendorLedgerEntry."IRS 1099 Form Box No.", 'IRS 1099 Form Box No. does not match for Vendor Ledger Entry No. ' + Format(TempVendorLedgerEntry."Entry No."));
            Assert.AreEqual(TempVendorLedgerEntry."IRS 1099 Reporting Amount", VendorLedgerEntry."IRS 1099 Reporting Amount", 'IRS 1099 Reporting Amount does not match for Vendor Ledger Entry No. ' + Format(TempVendorLedgerEntry."Entry No."));
        until TempVendorLedgerEntry.Next() = 0;
    end;

    local procedure Initialize()
    var
        SLAPBalances: Record "SL AP_Balances";
        SLAPSetup: Record "SL APSetup";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
        SLVendor: Record "SL Vendor";

    begin
        // Clear existing data
        if not SLAPSetup.IsEmpty() then
            SLAPSetup.DeleteAll();
        if not SLVendor.IsEmpty() then
            SLVendor.DeleteAll();
        if not SLAPBalances.IsEmpty() then
            SLAPBalances.DeleteAll();

        if IsInitialized then
            exit;

        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportSLAPSetupData();
        Commit();
        IsInitialized := true;
    end;
}
