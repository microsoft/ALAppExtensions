// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Inventory.Item;
using Microsoft.Purchases.Document;
using System.TestLibraries.Utilities;

codeunit 147605 "SL PO Migrator Tests"
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
    procedure TestSLCreateOpenPurchaseOrders()
    var
        TempExpectedPurchaseHeader: Record "Purchase Header" temporary;
        TempExpectedPurchaseLine: Record "Purchase Line" temporary;
        SLPurchOrdBuffer: Record "SL PurchOrd Buffer";
        SLPOMigrator: Codeunit "SL PO Migrator";
        ExpectedPurchaseHeaderData: XmlPort "SL BC Purch. Header Data Temp";
        ExpectedPurchaseLineData: XmlPort "SL BC Purchase Line Data";
        PurchaseHeaderInstream: InStream;
        PurchaseLineInstream: InStream;
    begin
        // [Scenario] Open purchase order migration from SL to BC
        Initialize();

        // Enable Open Purchase Order Migration
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Payables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Vendor Classes", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Open POs", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [Given] Open SL purchase order header and detail data
        SLTestHelperFunctions.ImportSLPurchOrdBufferData();
        SLTestHelperFunctions.ImportSLPurOrdDetBufferData();

        // [When] SL PurchOrd record exist, create Purchase Header record
        SLPurchOrdBuffer.SetRange(CpnyID, CopyStr(CompanyName(), 1, MaxStrLen(SLPurchOrdBuffer.CpnyID)));
        SLPurchOrdBuffer.SetRange(POType, 'OR'); // Regular Order
        SLPurchOrdBuffer.SetFilter(Status, 'O|P'); // Open Order | Purchase Order
        SLPurchOrdBuffer.SetFilter(VendID, '<>%1', '');
        if not SLPurchOrdBuffer.IsEmpty() then
            SLPOMigrator.MigrateOpenPurchaseOrderData();

        // [Then] Verify Purchase Header and Purchase Line records are created in BC
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCPurchaseHeader.csv', PurchaseHeaderInstream);
        ExpectedPurchaseHeaderData.SetSource(PurchaseHeaderInstream);
        ExpectedPurchaseHeaderData.Import();
        ExpectedPurchaseHeaderData.GetExpectedPurchaseHeaders(TempExpectedPurchaseHeader);
        ValidatePurchaseHeaderData(TempExpectedPurchaseHeader);

        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCPurchaseLine.csv', PurchaseLineInstream);
        ExpectedPurchaseLineData.SetSource(PurchaseLineInstream);
        ExpectedPurchaseLineData.Import();
        ExpectedPurchaseLineData.GetExpectedPurchaseLines(TempExpectedPurchaseLine);
        ValidatePurchaseLineData(TempExpectedPurchaseLine);
    end;

    local procedure ValidatePurchaseHeaderData(var TempExpectedPurchaseHeader: Record "Purchase Header" temporary)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        TempExpectedPurchaseHeader.Reset();
        TempExpectedPurchaseHeader.FindSet();
        repeat
            Assert.IsTrue(PurchaseHeader.Get(TempExpectedPurchaseHeader."Document Type", TempExpectedPurchaseHeader."No."),
              'Purchase Header does not exist in BC (Document Type: ' + Format(TempExpectedPurchaseHeader."Document Type") + ', No.: ' + TempExpectedPurchaseHeader."No." + ')');

            Assert.AreEqual(TempExpectedPurchaseHeader."Buy-from Vendor No.", PurchaseHeader."Buy-from Vendor No.", 'Buy-from Vendor No. does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Pay-to Vendor No.", PurchaseHeader."Pay-to Vendor No.", 'Pay-to Vendor No. does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to Name", PurchaseHeader."Ship-to Name", 'Ship-to Name does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to Address", PurchaseHeader."Ship-to Address", 'Ship-to Address does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to Address 2", PurchaseHeader."Ship-to Address 2", 'Ship-to Address 2 does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to City", PurchaseHeader."Ship-to City", 'Ship-to City does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Order Date", PurchaseHeader."Order Date", 'Order Date does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Posting Date", PurchaseHeader."Posting Date", 'Posting Date does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Posting Description", PurchaseHeader."Posting Description", 'Posting Description does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Prices Including VAT", PurchaseHeader."Prices Including VAT", 'Prices Including VAT does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to Post Code", PurchaseHeader."Ship-to Post Code", 'Ship-to Post Code does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to County", PurchaseHeader."Ship-to County", 'Ship-to State/County does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Ship-to Country/Region Code", PurchaseHeader."Ship-to Country/Region Code", 'Ship-to Country/Region Code does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Document Date", PurchaseHeader."Document Date", 'Document Date does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Posting No. Series", PurchaseHeader."Posting No. Series", 'Posting No. Series does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader."Receiving No. Series", PurchaseHeader."Receiving No. Series", 'Receiving No. Series does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
            Assert.AreEqual(TempExpectedPurchaseHeader.Status, PurchaseHeader.Status, 'Status does not match for Purchase Header (' + TempExpectedPurchaseHeader."No." + ')');
        until TempExpectedPurchaseHeader.Next() = 0;
    end;

    local procedure ValidatePurchaseLineData(var TempExpectedPurchaseLine: Record "Purchase Line" temporary)
    var
        PurchaseLine: Record "Purchase Line";
    begin
        TempExpectedPurchaseLine.Reset();
        TempExpectedPurchaseLine.FindSet();
        repeat
            Assert.IsTrue(PurchaseLine.Get(
                TempExpectedPurchaseLine."Document Type",
                TempExpectedPurchaseLine."Document No.",
                TempExpectedPurchaseLine."Line No."),
              'Purchase Line does not exist in BC (Document Type: ' +
              Format(TempExpectedPurchaseLine."Document Type") +
              ', Document No.: ' + TempExpectedPurchaseLine."Document No." +
              ', Line No.: ' + Format(TempExpectedPurchaseLine."Line No.") + ')');

            Assert.AreEqual(TempExpectedPurchaseLine."Buy-from Vendor No.", PurchaseLine."Buy-from Vendor No.", 'Buy-from Vendor No. does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedPurchaseLine."No.", PurchaseLine."No.", 'No. does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedPurchaseLine.Description, PurchaseLine.Description, 'Description does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedPurchaseLine.Quantity, PurchaseLine.Quantity, 'Quantity does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedPurchaseLine."Direct Unit Cost", PurchaseLine."Direct Unit Cost", 'Direct Unit Cost does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedPurchaseLine."Unit of Measure Code", PurchaseLine."Unit of Measure Code", 'Unit of Measure Code does not match for Purchase Line (' + TempExpectedPurchaseLine."Document No." + '/' + Format(TempExpectedPurchaseLine."Line No.") + ')');
        until TempExpectedPurchaseLine.Next() = 0;
    end;

    local procedure Initialize()
    var
        GLAccount: Record "G/L Account";
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        SLPurchOrder: Record "SL PurchOrd Buffer";
        SLPurOrdDet: Record "SL PurOrdDet Buffer";
        SLVendor: Record "SL Vendor";
        SLVendClass: Record "SL VendClass";
    begin
        // Delete/empty SL tables
        SLPurchOrder.DeleteAll();
        SLPurOrdDet.DeleteAll();

        // Delete/empty BC tables
        PurchaseLine.DeleteAll();
        PurchaseHeader.DeleteAll();

        if IsInitialized then
            exit;

        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.ClearBCVendorTableData();
        SLTestHelperFunctions.ClearBCItemTableData();
        SLTestHelperFunctions.ClearBCInventoryPostingGroupTableData();
        SLTestHelperFunctions.ClearBCGeneralBusinessPostingGroupTableData();
        SLTestHelperFunctions.ClearBCGenProductPostingGroupTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportBCVendorForOpenPOsData();
        SLTestHelperFunctions.ImportBCLocationsForOpenOrdersData();
        SLTestHelperFunctions.ImportBCUnitOfMeasureForOpenOrdersData();
        SLTestHelperFunctions.ImportBCItemForOpenOrderData();
        SLTestHelperFunctions.ImportBCItemUOMForOpenOrdersData();
        SLTestHelperFunctions.ImportBCInventoryPostingGroupData();
        SLTestHelperFunctions.ImportBCGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportBCGenProductPostingGroupData();
        Commit();
        IsInitialized := true;
    end;
}