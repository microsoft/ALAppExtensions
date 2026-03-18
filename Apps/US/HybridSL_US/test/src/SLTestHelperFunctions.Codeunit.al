// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Purchases.Vendor;

codeunit 147651 "SL Test Helper Functions"
{
    procedure GetInputStreamFromResource(ResourcePath: Text; var ResInstream: InStream)
    begin
        NavApp.GetResource(ResourcePath, ResInstream);
    end;

    procedure ImportGLAccountData()
    var
        GLAccountInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCGLAccount.csv', GLAccountInstream);
        PopulateGLAccountTable(GLAccountInstream);
    end;

    procedure ImportSLAPBalancesData()
    var
        SLAPBalancesInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAP_Balances.csv', SLAPBalancesInstream);
        PopulateSLAPBalancesTable(SLAPBalancesInstream);
    end;

    procedure ImportSLAPSetupData()
    var
        SLAPSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAPSetup.csv', SLAPSetupInstream);
        PopulateSLAPSetupTable(SLAPSetupInstream);
    end;

    procedure ImportSLCompanyAdditionalSettingsData()
    var
        SLCompanyAdditionalSettingsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLCompanyAdditionalSettings.csv', SLCompanyAdditionalSettingsInstream);
        PopulateSLCompanyAdditionalSettingsTable(SLCompanyAdditionalSettingsInstream);
    end;

    procedure ImportSLCompanyMigrationSettingsData()
    var
        SLCompanyMigrationSettingsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLCompanyMigrationSettings.csv', SLCompanyMigrationSettingsInstream);
        PopulateSLCompanyMigrationSettingsTable(SLCompanyMigrationSettingsInstream);
    end;

    procedure ImportVendorPostingGroupData()
    var
        VendorPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCVendorPostingGroup.csv', VendorPostingGroupInstream);
        PopulateVendorPostingGroupTable(VendorPostingGroupInstream);
    end;

    procedure ImportSLVendorData()
    var
        SLVendorInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLVendorWith1099.csv', SLVendorInstream);
        PopulateSLVendorTable(SLVendorInstream);
    end;

    procedure ImportBCVendorDataNo1099()
    var
        BCVendorInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCVendorNo1099.csv', BCVendorInstream);
        PopulateBCVendorTableNo1099(BCVendorInstream);
    end;

    procedure PopulateGLAccountTable(var Instream: InStream)
    begin
        // Populate GL Account table
        Xmlport.Import(Xmlport::"SL BC GL Account Data", Instream);
    end;

    procedure PopulateSLAPBalancesTable(var Instream: InStream)
    begin
        // Populate SL AP_Balances table
        Xmlport.Import(Xmlport::"SL AP Balances Data", Instream);
    end;

    procedure PopulateSLAPSetupTable(var Instream: InStream)
    begin
        // Populate SL APSetup table
        Xmlport.Import(Xmlport::"SL APSetup Data", Instream);
    end;

    procedure PopulateSLCompanyAdditionalSettingsTable(var Instream: InStream)
    begin
        // Populate SL Company Additional Settings table
        Xmlport.Import(Xmlport::"SL Company Additional Settings", Instream);
    end;

    procedure PopulateSLCompanyMigrationSettingsTable(var Instream: InStream)
    begin
        // Populate SL Company Migration Settings table
        Xmlport.Import(Xmlport::"SL Company Migration Settings", Instream);
    end;

    procedure PopulateSLVendorTable(var Instream: InStream)
    begin
        // Populate SL Vendor table
        Xmlport.Import(Xmlport::"SL Vendor Data", Instream);
    end;

    procedure PopulateBCVendorTableNo1099(var Instream: InStream)
    begin
        // Populate BC Vendor table
        Xmlport.Import(Xmlport::"SL BC Vendor No 1099 Data", Instream);
    end;

    procedure PopulateVendorPostingGroupTable(var Instream: InStream)
    begin
        // Populate Vendor Posting Group table
        Xmlport.Import(Xmlport::"SL Vendor Posting Group Data", Instream);
    end;

    procedure ClearBCVendorTableData()
    var
        Vendor: Record Vendor;
    begin
        Vendor.DeleteAll();
    end;

    procedure CreateConfigurationSettings()
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        CompanyNameText: Text[30];
    begin
        CompanyNameText := CompanyName();

        if not SLCompanyMigrationSettings.Get(CompanyNameText) then begin
            SLCompanyMigrationSettings.Name := CompanyNameText;
            SLCompanyMigrationSettings.Insert();
        end;

        if not SLCompanyAdditionalSettings.Get(CompanyNameText) then begin
            SLCompanyAdditionalSettings.Name := CompanyNameText;
            SLCompanyAdditionalSettings.Insert();
        end;
    end;

    procedure DeleteAllSettings()
    var
        SLCompanyMigrationSettings: Record "SL Company Migration Settings";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        SLCompanyMigrationSettings.DeleteAll();
        SLCompanyAdditionalSettings.DeleteAll();
    end;
}