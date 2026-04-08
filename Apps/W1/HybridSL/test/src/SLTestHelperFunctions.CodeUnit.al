// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Setup;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Vendor;
using Microsoft.Sales.Customer;

codeunit 147601 "SL Test Helper Functions"
{
    procedure ClearAccountTableData()
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.DeleteAll();
    end;

    procedure ClearBCCustomerTableData()
    var
        Customer: Record Customer;
    begin
        Customer.DeleteAll();
    end;

    procedure ClearBCGeneralBusinessPostingGroupTableData()
    var
        GenBusinessPostingGroup: Record "Gen. Business Posting Group";
    begin
        GenBusinessPostingGroup.DeleteAll();
    end;

    procedure ClearBCGenProductPostingGroupTableData();
    var
        GenProductPostingGroup: Record "Gen. Product Posting Group";
    begin
        GenProductPostingGroup.DeleteAll();
    end;

    procedure ClearBCInventoryPostingGroupTableData()
    var
        InventoryPostingGroup: Record "Inventory Posting Group";
    begin
        InventoryPostingGroup.DeleteAll();
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

    procedure ClearSLCustomerTableData()
    var
        SLCustomer: Record Customer;
    begin
        SLCustomer.DeleteAll();
    end;

    procedure ClearSLSOTypeBufferTableData()
    var
        SLSOTypeBuffer: Record "SL SOType Buffer";
    begin
        SLSOTypeBuffer.DeleteAll();
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

    procedure ImportDimensionData()
    var
        DimensionInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCDimension.csv', DimensionInstream);
        PopulateDimensionTable(DimensionInstream);
    end;

    procedure ImportDimensionValueData()
    var
        DimensionValueInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCDimensionValue.csv', DimensionValueInstream);
        PopulateDimensionValueTable(DimensionValueInstream);
    end;

    procedure ImportGLAccountData()
    var
        GLAccountInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCGLAccounts.csv', GLAccountInstream);
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

    procedure ImportSLAccountStagingData()
    var
        SLAccountStagingInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAccountStagingWithInactiveAccount.csv', SLAccountStagingInstream);
        PopulateSLAccountStagingTable(SLAccountStagingInstream);
    end;

    procedure ImportSLAcctHist()
    var
        SLAcctHistInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAcctHistWithBeginningBalances.csv', SLAcctHistInstream);
        PopulateSLAcctHistTable(SLAcctHistInstream);
    end;

    procedure ImportSLAddressData()
    var
        SLAddressInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAddress.csv', SLAddressInstream);
        PopulateSLAddressTable(SLAddressInstream);
    end;

    procedure ImportSLAPDocBufferData()
    var
        SLAPDocBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAPDocBuffer.csv', SLAPDocBufferInstream);
        PopulateSLAPDocBufferTable(SLAPDocBufferInstream);
    end;

    procedure ImportSLAPSetupData()
    var
        SLAPSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLAPSetup.csv', SLAPSetupInstream);
        PopulateSLAPSetupTable(SLAPSetupInstream);
    end;

    procedure ImportSLARDocBufferData()
    var
        SLARDocBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLARDocBuffer.csv', SLARDocBufferInstream);
        PopulateSLARDocBufferTable(SLARDocBufferInstream);
    end;

    procedure ImportSLARSetupData()
    var
        SLARSetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLARSetup.csv', SLARSetupInstream);
        PopulateSLARSetupTable(SLARSetupInstream);
    end;

    procedure ImportSLBatchData()
    var
        SLBatchInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLBatch.csv', SLBatchInstream);
        PopulateSLBatchTable(SLBatchInstream);
    end;

    procedure ImportSLCASetupData()
    var
        SLCASetupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCASetup.csv', SLCASetupInstream);
        PopulateSLCASetupTable(SLCASetupInstream);
    end;

    procedure ImportSLCashAcctData()
    var
        SLCashAcctInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCashAcct.csv', SLCashAcctInstream);
        PopulateSLCashAcctTable(SLCashAcctInstream);
    end;

    procedure ImportSLCashSumDData()
    var
        SLCashSumDInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCashSumD.csv', SLCashSumDInstream);
        PopulateSLCashSumDTable(SLCashSumDInstream);
    end;

    procedure ImportSLCompanyMigrationSettingsData()
    var
        SLCompanyMigrationSettingsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLCompanyMigrationSettings.csv', SLCompanyMigrationSettingsInstream);
        PopulateSLCompanyMigrationSettingsTable(SLCompanyMigrationSettingsInstream);
    end;

    procedure ImportSLCustClassData()
    var
        SLCustClassInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCustClass.csv', SLCustClassInstream);
        PopulateSLCustClassTable(SLCustClassInstream);
    end;

    procedure ImportSLCustomerData()
    var
        SLCustomerInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCustomerWithClassID.csv', SLCustomerInstream);
        PopulateSLCustomerTable(SLCustomerInstream);
    end;

    procedure ImportSLCustomerDataForOpenOrderTest()
    var
        SLCustomerInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLCustomerForOpenOrderTest.csv', SLCustomerInstream);
        PopulateSLCustomerTable(SLCustomerInstream);
    end;

    procedure ImportSLFlexDefData()
    var
        SLFlexDefInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLFlexDef.csv', SLFlexDefInstream);
        PopulateSLFlexDefTable(SLFlexDefInstream);
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

    procedure ImportSLItemSiteBufferData()
    var
        SLItemSiteInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLItemSiteForItemJournalTest.csv', SLItemSiteInstream);
        PopulateSLItemSiteBufferTable(SLItemSiteInstream);
    end;

    procedure ImportSLPurchOrdBufferData()
    var
        SLPurchOrdBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLPurchOrdBuffer.csv', SLPurchOrdBufferInstream);
        PopulateSLPurchOrdBufferTable(SLPurchOrdBufferInstream);
    end;

    procedure ImportSLPurOrdDetBufferData()
    var
        SLPurOrdDetBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLPurOrdDetBuffer.csv', SLPurOrdDetBufferInstream);
        PopulateSLPurOrdDetBufferTable(SLPurOrdDetBufferInstream);
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

    procedure ImportSLSegmentsData()
    var
        SLSegmentsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSegments.csv', SLSegmentsInstream);
        PopulateSLSegmentsTable(SLSegmentsInstream);
    end;

    procedure ImportSLSiteData()
    var
        SLSiteInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSite.csv', SLSiteInstream);
        PopulateSLSiteTable(SLSiteInstream);
    end;

    procedure ImportSLSOAddressData()
    var
        SLSOAddressInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSOAddress.csv', SLSOAddressInstream);
        PopulateSLSOAddressTable(SLSOAddressInstream);
    end;

    procedure ImportSLSOHeaderBufferData()
    var
        SLSOHeaderBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSOHeaderBuffer.csv', SLSOHeaderBufferInstream);
        PopulateSLSOHeaderBufferTable(SLSOHeaderBufferInstream);
    end;

    procedure ImportSLSOLineBufferData()
    var
        SLSOLineBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSOLineBuffer.csv', SLSOLineBufferInstream);
        PopulateSLSOLineBufferTable(SLSOLineBufferInstream);
    end;

    procedure ImportSLSOTypeBufferData()
    var
        SLSOTypeBufferInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLSOTypeBuffer.csv', SLSOTypeBufferInstream);
        PopulateSLSOTypeBufferTable(SLSOTypeBufferInstream);
    end;

    procedure ImportSLVendClassData()
    var
        SLVendClassInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLVendClass.csv', SLVendClassInstream);
        PopulateSLVendClassTable(SLVendClassInstream);
    end;

    procedure ImportSLVendorData()
    var
        SLVendorInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLTables/SLVendorWithClassID.csv', SLVendorInstream);
        PopulateSLVendorTable(SLVendorInstream);
    end;

    procedure ImportBCVendorForOpenPOsData()
    var
        SLBCVendorForOpenPOsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCVendorForOpenPOs.csv', SLBCVendorForOpenPOsInstream);
        PopulateSLBCVendorForOpenPOsTable(SLBCVendorForOpenPOsInstream);
    end;

    procedure ImportBCItemForOpenOrderData()
    var
        SLBCItemForOpenOrderInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCItemForOpenOrders.csv', SLBCItemForOpenOrderInstream);
        PopulateSLBCItemForOpenOrderTable(SLBCItemForOpenOrderInstream);
    end;

    procedure ImportBCUnitOfMeasureForOpenOrdersData()
    var
        SLBCUnitOfMeasureForOpenOrdersInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCUnitOfMeasureForOpenOrders.csv', SLBCUnitOfMeasureForOpenOrdersInstream);
        PopulateSLBCUnitOfMeasureForOpenOrdersTable(SLBCUnitOfMeasureForOpenOrdersInstream);
    end;

    procedure ImportBCInventoryPostingGroupData()
    var
        SLBCInventoryPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCInventoryPostingGroup.csv', SLBCInventoryPostingGroupInstream);
        PopulateSLBCInventoryPostingGroupTable(SLBCInventoryPostingGroupInstream);
    end;

    procedure ImportBCItemUOMForOpenOrdersData()
    var
        SLBCItemUOMForOpenOrdersInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCItemUOMForOpenOrders.csv', SLBCItemUOMForOpenOrdersInstream);
        PopulateSLBCItemUOMForOpenOrdersTable(SLBCItemUOMForOpenOrdersInstream);
    end;

    procedure ImportBCLocationsForOpenOrdersData()
    var
        SLBCLocationsInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCLocations.csv', SLBCLocationsInstream);
        PopulateSLBCLocationsForOpenOrdersTable(SLBCLocationsInstream);
    end;

    procedure ImportBCCustomerForOpenOrdersData()
    var
        SLBCCustomerForOpenOrdersInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCCustomerForOpenOrders.csv', SLBCCustomerForOpenOrdersInstream);
        PopulateSLBCCustomerForOpenOrdersTable(SLBCCustomerForOpenOrdersInstream);
    end;

    procedure PopulateSLCustomerTable(var Instream: InStream)
    begin
        // Populate Customer buffer table
        Xmlport.Import(Xmlport::"SL Customer Data", Instream);
    end;

    procedure PopulateDataMigrationStatusTable(var Instream: InStream)
    begin
        // Populate Data Migration Status table
        Xmlport.Import(Xmlport::"SL BC Data Migration Status", Instream);
    end;

    procedure PopulateDimensionTable(var Instream: InStream)
    begin
        // Populate Dimension table
        Xmlport.Import(Xmlport::"SL BC Dimension Data", Instream);
    end;

    procedure PopulateDimensionValueTable(var Instream: InStream)
    begin
        // Populate Dimension Value table
        Xmlport.Import(Xmlport::"SL BC Dimension Value Data", Instream);
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

    procedure PopulateSLAccountStagingTable(var Instream: InStream)
    begin
        // Populate SL Account Staging table
        Xmlport.Import(Xmlport::"SL Account Staging Data", Instream);
    end;

    procedure PopulateSLAcctHistTable(var Instream: InStream)
    begin
        // Populate SL AcctHist table
        Xmlport.Import(Xmlport::"SL AcctHist Data", Instream);
    end;

    procedure PopulateSLAddressTable(var Instream: InStream)
    begin
        // Populate SL Address table
        Xmlport.Import(Xmlport::"SL Address Data", Instream);
    end;

    procedure PopulateSLAPDocBufferTable(var Instream: InStream)
    begin
        // Populate SL APDoc Buffer table
        Xmlport.Import(Xmlport::"SL APDoc Buffer Data", Instream);
    end;

    procedure PopulateSLAPSetupTable(var Instream: InStream)
    begin
        // Populate SL APSetup table
        Xmlport.Import(Xmlport::"SL APSetup Data", Instream);
    end;

    procedure PopulateSLARDocBufferTable(var Instream: InStream)
    begin
        // Populate SL ARDoc Buffer table
        Xmlport.Import(Xmlport::"SL ARDoc Buffer Data", Instream);
    end;

    procedure PopulateSLARSetupTable(var Instream: InStream)
    begin
        // Populate SL ARSetup table
        Xmlport.Import(Xmlport::"SL ARSetup Data", Instream);
    end;

    procedure PopulateSLBatchTable(var Instream: InStream)
    begin
        // Populate SL Batch table
        Xmlport.Import(Xmlport::"SL Batch Data", Instream);
    end;

    procedure PopulateSLCASetupTable(var Instream: InStream)
    begin
        // Populate SL CASetup table
        Xmlport.Import(Xmlport::"SL CASetup Data", Instream);
    end;

    procedure PopulateSLCashAcctTable(var Instream: InStream)
    begin
        // Populate SL CashAcct table
        Xmlport.Import(Xmlport::"SL CashAcct Data", Instream);
    end;

    procedure PopulateSLCashSumDTable(var Instream: InStream)
    begin
        // Populate SL CashSumD table
        Xmlport.Import(Xmlport::"SL CashSumD Data", Instream);
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

    procedure PopulateSLCustClassTable(var Instream: InStream)
    begin
        // Populate SL CustClass table
        Xmlport.Import(Xmlport::"SL CustClass Data", Instream);
    end;

    procedure PopulateSLFlexDefTable(var Instream: InStream)
    begin
        // Populate SL FlexDef table
        Xmlport.Import(Xmlport::"SL FlexDef Data", Instream);
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

    procedure PopulateSLItemSiteBufferTable(var Instream: InStream)
    begin
        // Populate SL ItemSite Buffer table
        Xmlport.Import(Xmlport::"SL ItemSite Buffer Data", Instream);
    end;

    procedure PopulateSLPurchOrdBufferTable(var Instream: InStream)
    begin
        // Populate SL PurchOrd Buffer table
        Xmlport.Import(Xmlport::"SL PurchOrd Buffer Data", Instream);
    end;

    procedure PopulateSLPurOrdDetBufferTable(var Instream: InStream)
    begin
        // Populate SL PurOrdDet Buffer table
        Xmlport.Import(Xmlport::"SL PurOrdDet Buffer Data", Instream);
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

    procedure PopulateSLSegmentsTable(var Instream: InStream)
    begin
        // Populate SL Segments table
        Xmlport.Import(Xmlport::"SL Segments", Instream);
    end;

    procedure PopulateSLSiteTable(var Instream: InStream)
    begin
        // Populate SL Site table
        Xmlport.Import(Xmlport::"SL Site Data", Instream);
    end;

    procedure PopulateSLSOAddressTable(var Instream: InStream)
    begin
        // Populate SL SOAddress table
        Xmlport.Import(Xmlport::"SL SOAddress Data", Instream);
    end;

    procedure PopulateSLSOHeaderBufferTable(var Instream: InStream)
    begin
        // Populate SL SOHeader Buffer table
        Xmlport.Import(Xmlport::"SL SOHeader Buffer Data", Instream);
    end;

    procedure PopulateSLSOLineBufferTable(var Instream: InStream)
    begin
        // Populate SL SOLine Buffer table
        Xmlport.Import(Xmlport::"SL SOLine Buffer Data", Instream);
    end;

    procedure PopulateSLSOTypeBufferTable(var Instream: InStream)
    begin
        // Populate SL SOType Buffer table
        Xmlport.Import(Xmlport::"SL SOType Buffer Data", Instream);
    end;

    procedure PopulateSLVendClassTable(var Instream: InStream)
    begin
        // Populate SL VendClass table
        Xmlport.Import(Xmlport::"SL VendClass Data", Instream);
    end;

    procedure PopulateSLVendorTable(var Instream: InStream)
    begin
        // Populate SL Vendor table
        Xmlport.Import(Xmlport::"SL Vendor Data", Instream);
    end;

    procedure PopulateSLBCVendorForOpenPOsTable(var Instream: InStream)
    begin
        // Populate BC Vendor table for open PO tests
        Xmlport.Import(Xmlport::"SL BC Vendor for Open POs Data", Instream);
    end;

    procedure PopulateSLBCInventoryPostingGroupTable(var Instream: InStream)
    begin
        // Populate BC Inventory Posting Group table for open order tests
        Xmlport.Import(Xmlport::"SL BC Invt Posting Group Data", Instream);
    end;

    procedure PopulateSLBCItemForOpenOrderTable(var Instream: InStream)
    begin
        // Populate BC Item table for open order tests
        Xmlport.Import(Xmlport::"SL BC Item for Open Order Data", Instream);
    end;

    procedure PopulateSLBCUnitOfMeasureForOpenOrdersTable(var Instream: InStream)
    begin
        // Populate BC Unit of Measure table for open order tests
        Xmlport.Import(Xmlport::"SL BC UOM Open Orders", Instream);
    end;

    procedure PopulateSLBCItemUOMForOpenOrdersTable(var Instream: InStream)
    begin
        // Populate BC Item Unit of Measure table for open order tests
        Xmlport.Import(Xmlport::"SL BC Item UOM Open Orders", Instream);
    end;

    procedure PopulateSLBCLocationsForOpenOrdersTable(var Instream: InStream)
    begin
        // Populate BC Location table for open order tests
        Xmlport.Import(Xmlport::"SL BC Locations Open Orders", Instream);
    end;

    procedure PopulateSLBCCustomerForOpenOrdersTable(var Instream: InStream)
    begin
        // Populate BC Customer table for open sales order tests
        Xmlport.Import(Xmlport::"SL BC Customer Open Order Data", Instream);
    end;

    procedure ImportBCGenBusinessPostingGroupData()
    var
        SLBCGenBusinessPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCGenBusinessPostingGroup.csv', SLBCGenBusinessPostingGroupInstream);
        PopulateGenBusinessPostingGroupTable(SLBCGenBusinessPostingGroupInstream);
    end;

    procedure ImportBCGenProductPostingGroupData()
    var
        SLBCGenProductPostingGroupInstream: InStream;
    begin
        GetInputStreamFromResource('datasets/input/SLBCGenProductPostingGroup.csv', SLBCGenProductPostingGroupInstream);
        PopulateSLBCGenProductPostingGroupTable(SLBCGenProductPostingGroupInstream);
    end;

    procedure PopulateSLBCGenProductPostingGroupTable(var Instream: InStream)
    begin
        // Populate BC Gen. Product Posting Group table for open order tests
        Xmlport.Import(Xmlport::"SL Gen Prod Posting Group Data", Instream);
    end;
}
