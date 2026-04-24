// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Inventory.Item;
using Microsoft.Sales.Document;
using System.TestLibraries.Utilities;

codeunit 147651 "SL SO Migrator Tests"
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
    procedure TestSLCreateOpenSalesOrders()
    var
        SLSOHeaderBuffer: Record "SL SOHeader Buffer";
        TempExpectedSalesHeader: Record "Sales Header" temporary;
        TempExpectedSalesLine: Record "Sales Line" temporary;
        SLSOMigrator: Codeunit "SL SO Migrator";
        ExpectedSalesHeaderData: XmlPort "SL BC Sales Header Data Temp";
        ExpectedSalesLineData: XmlPort "SL BC Sales Line Data Temp";
        SalesHeaderInstream: InStream;
        SalesLineInstream: InStream;
    begin
        // [Scenario] Open sales order migration from SL to BC
        Initialize();

        // Enable Open Sales Order Migration
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Receivables Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Customer Classes", true);
        SLCompanyAdditionalSettings.Validate("Migrate Inventory Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Open SOs", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [Given] Open SL sales order source data
        SLTestHelperFunctions.ImportSLSOHeaderBufferData();
        SLTestHelperFunctions.ImportSLSOLineBufferData();

        // [When] SL SOHeader Buffer records exist, create Sales Header and Sales Line records
        SLSOHeaderBuffer.SetRange(CpnyID, CopyStr(CompanyName(), 1, MaxStrLen(SLSOHeaderBuffer.CpnyID)));
        SLSOHeaderBuffer.SetFilter(Status, 'O');
        if not SLSOHeaderBuffer.IsEmpty() then
            SLSOMigrator.MigrateOpenSalesOrders();

        // [Then] Verify Sales Header and Sales Line records are created in BC
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCSalesHeader.csv', SalesHeaderInstream);
        ExpectedSalesHeaderData.SetSource(SalesHeaderInstream);
        ExpectedSalesHeaderData.Import();
        ExpectedSalesHeaderData.GetExpectedSalesHeaders(TempExpectedSalesHeader);
        ValidateSalesHeaderData(TempExpectedSalesHeader);

        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCSalesLine.csv', SalesLineInstream);
        ExpectedSalesLineData.SetSource(SalesLineInstream);
        ExpectedSalesLineData.Import();
        ExpectedSalesLineData.GetExpectedSalesLines(TempExpectedSalesLine);
        ValidateSalesLineData(TempExpectedSalesLine);
    end;

    local procedure ValidateSalesHeaderData(var TempExpectedSalesHeader: Record "Sales Header" temporary)
    var
        SalesHeader: Record "Sales Header";
    begin
        TempExpectedSalesHeader.Reset();
        TempExpectedSalesHeader.FindSet();
        repeat
            Assert.IsTrue(SalesHeader.Get(TempExpectedSalesHeader."Document Type", TempExpectedSalesHeader."No."),
              'Sales Header does not exist in BC (Document Type: ' + Format(TempExpectedSalesHeader."Document Type") + ', No.: ' + TempExpectedSalesHeader."No." + ')');

            Assert.AreEqual(TempExpectedSalesHeader."Sell-to Customer No.", SalesHeader."Sell-to Customer No.", 'Sell-to Customer No. does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Bill-to Customer No.", SalesHeader."Bill-to Customer No.", 'Bill-to Customer No. does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Name", SalesHeader."Ship-to Name", 'Ship-to Name does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Address", SalesHeader."Ship-to Address", 'Ship-to Address does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Address 2", SalesHeader."Ship-to Address 2", 'Ship-to Address 2 does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to City", SalesHeader."Ship-to City", 'Ship-to City does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Contact", SalesHeader."Ship-to Contact", 'Ship-to Contact does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Order Date", SalesHeader."Order Date", 'Order Date does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Posting Date", SalesHeader."Posting Date", 'Posting Date does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Posting Description", SalesHeader."Posting Description", 'Posting Description does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Shipment Method Code", SalesHeader."Shipment Method Code", 'Shipment Method Code does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Post Code", SalesHeader."Ship-to Post Code", 'Ship-to Post Code does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to County", SalesHeader."Ship-to County", 'Ship-to State/County does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Ship-to Country/Region Code", SalesHeader."Ship-to Country/Region Code", 'Ship-to Country/Region Code does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Document Date", SalesHeader."Document Date", 'Document Date does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Posting No. Series", SalesHeader."Posting No. Series", 'Posting No. Series does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Shipping No. Series", SalesHeader."Shipping No. Series", 'Shipping No. Series does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader.Status, SalesHeader.Status, 'Status does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
            Assert.AreEqual(TempExpectedSalesHeader."Shipping Advice", SalesHeader."Shipping Advice", 'Shipping Advice does not match for Sales Header (' + TempExpectedSalesHeader."No." + ')');
        until TempExpectedSalesHeader.Next() = 0;
    end;

    local procedure ValidateSalesLineData(var TempExpectedSalesLine: Record "Sales Line" temporary)
    var
        SalesLine: Record "Sales Line";
    begin
        TempExpectedSalesLine.Reset();
        TempExpectedSalesLine.FindSet();
        repeat
            Assert.IsTrue(SalesLine.Get(
                TempExpectedSalesLine."Document Type",
                TempExpectedSalesLine."Document No.",
                TempExpectedSalesLine."Line No."),
              'Sales Line does not exist in BC (Document Type: ' +
              Format(TempExpectedSalesLine."Document Type") +
              ', Document No.: ' + TempExpectedSalesLine."Document No." +
              ', Line No.: ' + Format(TempExpectedSalesLine."Line No.") + ')');

            Assert.AreEqual(TempExpectedSalesLine."Sell-to Customer No.", SalesLine."Sell-to Customer No.", 'Sell-to Customer No. does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine.Type, SalesLine.Type, 'Type does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine."No.", SalesLine."No.", 'No. does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine."Location Code", SalesLine."Location Code", 'Location Code does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine."Unit of Measure Code", SalesLine."Unit of Measure Code", 'Unit of Measure Code does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine.Quantity, SalesLine.Quantity, 'Quantity does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
            Assert.AreEqual(TempExpectedSalesLine."Unit Price", SalesLine."Unit Price", 'Unit Price does not match for Sales Line (' + TempExpectedSalesLine."Document No." + '/' + Format(TempExpectedSalesLine."Line No.") + ')');
        until TempExpectedSalesLine.Next() = 0;
    end;

    local procedure Initialize()
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        SLSOHeader: Record "SL SOHeader Buffer";
        SLSOLine: Record "SL SOLine Buffer";
        SLSOTypeBuffer: Record "SL SOType Buffer";

    begin
        // Delete/empty SL tables
        SLSOHeader.DeleteAll();
        SLSOLine.DeleteAll();
        SLSOTypeBuffer.DeleteAll();

        // Delete/empty BC tables
        SalesLine.DeleteAll();
        SalesHeader.DeleteAll();

        if IsInitialized then
            exit;

        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.ClearSLCustomerTableData();
        SLTestHelperFunctions.ClearSLSOTypeBufferTableData();
        SLTestHelperFunctions.ClearBCCustomerTableData();
        SLTestHelperFunctions.ClearBCItemTableData();
        SLTestHelperFunctions.ClearBCInventoryPostingGroupTableData();
        SLTestHelperFunctions.ClearBCGeneralBusinessPostingGroupTableData();
        SLTestHelperFunctions.ClearBCGenProductPostingGroupTableData();
        SLTestHelperFunctions.DeleteAllSettings();
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportBCCustomerForOpenOrdersData();
        SLTestHelperFunctions.ImportBCLocationsForOpenOrdersData();
        SLTestHelperFunctions.ImportBCUnitOfMeasureForOpenOrdersData();
        SLTestHelperFunctions.ImportBCItemForOpenOrderData();
        SLTestHelperFunctions.ImportBCItemUOMForOpenOrdersData();
        SLTestHelperFunctions.ImportBCInventoryPostingGroupData();
        SLTestHelperFunctions.ImportBCGenBusinessPostingGroupData();
        SLTestHelperFunctions.ImportBCGenProductPostingGroupData();
        SLTestHelperFunctions.ImportSLSOTypeBufferData();
        SLTestHelperFunctions.ImportSLCustomerDataForOpenOrderTest();
        Commit();
        IsInitialized := true;
    end;
}
