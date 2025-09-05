// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Sales.Customer;
using Microsoft.Purchases.Vendor;
using Microsoft.Inventory.Item;

codeunit 147601 "SL Test Helper Functions"
{
    procedure ClearBCCustomerTableData()
    var
        Customer: Record Customer;
    begin
        Customer.DeleteAll();
    end;

    procedure ClearBCItemTableData()
    var
        Item: Record Item;
    begin
        Item.DeleteAll();
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

    procedure GetInputStreamFromResource(ResourcePath: Text; var ResInstream: InStream)
    begin
        NavApp.GetResource(ResourcePath, ResInstream);
    end;

    procedure ImportDataMigrationStatus()
    var
        DataMigrationStatusInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLDataMigrationStatus.csv', DataMigrationStatusInstream);
        PopulateDataMigrationStatusTable(DataMigrationStatusInstream);
    end;

    procedure ImportGLAccountData()
    var
        GLAccountInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLGLChartOfAccounts.csv', GLAccountInstream);
        PopulateGLAccountTable(GLAccountInstream);
    end;

    procedure ImportGenBusinessPostingGroupData()
    var
        GenBusinessPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLGenBusinessPostingGroup.csv', GenBusinessPostingGroupInstream);
        PopulateGenBusinessPostingGroupTable(GenBusinessPostingGroupInstream);
    end;

    procedure ImportGenProductPostingGroupData()
    var
        GenProductPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCGeneralProductPostingGroup.csv', GenProductPostingGroupInstream);
        PopulateGenProductPostingGroupTable(GenProductPostingGroupInstream);
    end;

    procedure ImportItemTrackingCodeData()
    var
        ItemTrackingCodeInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCItemTrackingCode.csv', ItemTrackingCodeInstream);
        PopulateItemTrackingCodeTable(ItemTrackingCodeInstream);
    end;

    procedure ImportSLAcctHist()
    var
        SLAcctHistInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAcctHistDataForAccountingPeriodTest.csv', SLAcctHistInstream);
        PopulateSLAcctHistTable(SLAcctHistInstream);
    end;

    procedure ImportSLAPSetupData()
    var
        SLAPSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAPSetup.csv', SLAPSetupInstream);
        PopulateSLAPSetupTable(SLAPSetupInstream);
    end;

    procedure ImportSLARSetupData()
    var
        SLARSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLARSetup.csv', SLARSetupInstream);
        PopulateSLARSetupTable(SLARSetupInstream);
    end;

    procedure ImportSLCompanyAdditionalSettingsData()
    var
        SLCompanyAdditionalSettingsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLCompanyAdditonalSettingsDefault.csv', SLCompanyAdditionalSettingsInstream);
        PopulateSLCompanyAdditionalSettingsTable(SLCompanyAdditionalSettingsInstream);
    end;

    procedure ImportSLCustClassData()
    var
        SLCustClassInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCustClass.csv', SLCustClassInstream);
        PopulateSLCustClassTable(SLCustClassInstream);
    end;


    procedure ImportSLGLSetupData12Periods()
    var
        SLGLSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLGLSetup12Periods.csv', SLGLSetupInstream);
        PopulateSLGLSetupTable(SLGLSetupInstream);
    end;

    procedure ImportSLGLSetupData13Periods()
    var
        SLGLSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLGLSetup13Periods.csv', SLGLSetupInstream);
        PopulateSLGLSetupTable(SLGLSetupInstream);
    end;

    procedure ImportSLINSetupData()
    var
        SLINSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLINSetup.csv', SLINSetupInstream);
        PopulateSLINSetupTable(SLINSetupInstream);
    end;

    procedure ImportSLProductClassData()
    var
        SLProductClassInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLProductClass.csv', SLProductClassInstream);
        PopulateSLProductClassTable(SLProductClassInstream);
    end;


    procedure ImportSLSalesTaxData()
    var
        SLSalesTaxInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSalesTax.csv', SLSalesTaxInstream);
        PopulateSLSalesTaxTable(SLSalesTaxInstream);
    end;

    procedure ImportSLSOAddressData()
    var
        SLSOAddressInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSOAddress.csv', SLSOAddressInstream);
        PopulateSLSOAddressTable(SLSOAddressInstream);
    end;

    procedure ImportSLVendClassData()
    var
        SLVendClassInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLVendClass.csv', SLVendClassInstream);
        PopulateSLVendClassTable(SLVendClassInstream);
    end;

    procedure PopulateDataMigrationStatusTable(var Instream: InStream)
    begin
        // Populate Data Migration Status table
        Xmlport.Import(Xmlport::"SL BC Data Migration Status", Instream);
    end;

    procedure PopulateGLAccountTable(var Instream: InStream)
    begin
        // Populate G/L Account table
        Xmlport.Import(Xmlport::"SL BC GL Account Data", Instream);
    end;

    procedure PopulateGenBusinessPostingGroupTable(var Instream: InStream)
    begin
        // Populate Gen. Business Posting Group table
        Xmlport.Import(Xmlport::"SL BC Gen. Bus. Posting Group", Instream);
    end;

    procedure PopulateGenProductPostingGroupTable(var Instream: InStream)
    begin
        // Populate Gen. Product Posting Group table
        Xmlport.Import(Xmlport::"SL BC Gen. Prod. Posting Group", Instream);
    end;

    procedure PopulateItemTrackingCodeTable(var Instream: InStream)
    begin
        // Populate Item Tracking Code table
        Xmlport.Import(Xmlport::"SL BC Item Tracking Code Data", Instream);
    end;

    procedure PopulateSLAcctHistTable(var Instream: InStream)
    begin
        // Populate SL AcctHist table
        Xmlport.Import(Xmlport::"SL AcctHist Data", Instream);
    end;

    procedure PopulateSLAPSetupTable(var Instream: InStream)
    begin
        // Populate SL APSetup table
        Xmlport.Import(Xmlport::"SL APSetup Data", Instream);
    end;

    procedure PopulateSLARSetupTable(var Instream: InStream)
    begin
        // Populate SL ARSetup table
        Xmlport.Import(Xmlport::"SL ARSetup Data", Instream);
    end;

    procedure PopulateSLCompanyAdditionalSettingsTable(var Instream: InStream)
    begin
        // Populate SL Company Additional Settings table
        Xmlport.Import(Xmlport::"SL Company Additional Settings", Instream);
    end;

    procedure PopulateSLCustClassTable(var Instream: InStream)
    begin
        // Populate SL CustClass table
        Xmlport.Import(Xmlport::"SL CustClass Data", Instream);
    end;

    procedure PopulateSLGLSetupTable(var Instream: InStream)
    begin
        // Populate SL GLSetup table
        Xmlport.Import(Xmlport::"SL GLSetup Data", Instream);
    end;

    procedure PopulateSLINSetupTable(var Instream: InStream)
    begin
        // Populate SL INSetup table
        Xmlport.Import(Xmlport::"SL INSetup Data", Instream);
    end;

    procedure PopulateSLProductClassTable(var Instream: InStream)
    begin
        // Populate SL ProductClass table
        Xmlport.Import(Xmlport::"SL ProductClass Data", Instream);
    end;

    procedure PopulateSLSalesTaxTable(var Instream: InStream)
    begin
        // Populate SL SalesTax table
        Xmlport.Import(Xmlport::"SL SalesTax Data", Instream);
    end;

    procedure PopulateSLSOAddressTable(var Instream: InStream)
    begin
        // Populate SL SOAddress table
        Xmlport.Import(Xmlport::"SL SOAddress Data", Instream);
    end;

    procedure PopulateSLVendClassTable(var Instream: InStream)
    begin
        // Populate SL VendClass table
        Xmlport.Import(Xmlport::"SL VendClass Data", Instream);
    end;
}
