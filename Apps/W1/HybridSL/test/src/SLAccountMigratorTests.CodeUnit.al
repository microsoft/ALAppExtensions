// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using System.TestLibraries.Utilities;
using Microsoft.Foundation.Period;

codeunit 147602 "SL Account Migrator Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        SLTestHelperFunctions: Codeunit "SL Test Helper Functions";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        AccountingPeriod: Record "Accounting Period";
        SLAcctHist: Record "SL AcctHist";
        SLGLSetup: Record "SL GLSetup";
        SLPeriodListWorkTable: Record "SL Period List Work Table";
    begin
        SLGLSetup.DeleteAll();
        SLPeriodListWorkTable.DeleteAll();
        AccountingPeriod.DeleteAll();

        if IsInitialized then
            exit;

        SLAcctHist.DeleteAll();
        SLTestHelperFunctions.ImportSLAcctHist();
        Commit();
        IsInitialized := true;
    end;

    [Test]
    procedure TestCreate12AccountingPeriods()
    var
        TempAccountingPeriod: Record "Accounting Period" temporary;
        SLFiscalPeriods: Codeunit "SL Fiscal Periods";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        SLExpectedBCAccountingPeriodData: XmlPort "SL BC Accounting Period Data";
        BCAccountingPeriodInstream: InStream;
    begin
        Initialize();

        SLTestHelperFunctions.ImportSLGLSetupData12Periods();
        SLPopulateFiscalPeriods.CreateSLFiscalPeriodsFromGLSetup();
        Commit();
        SLFiscalPeriods.MoveStagingData();

        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLAccountingPeriod201501-201812.csv', BCAccountingPeriodInstream);
        SLExpectedBCAccountingPeriodData.SetSource(BCAccountingPeriodInstream);
        SLExpectedBCAccountingPeriodData.Import();
        SLExpectedBCAccountingPeriodData.GetExpectedAccountingPeriods(TempAccountingPeriod);
        ValidateAccountingPeriods(TempAccountingPeriod);
    end;

    local procedure ValidateAccountingPeriods(var TempAccountingPeriod: Record "Accounting Period" temporary)
    var
        AccountingPeriod: Record "Accounting Period";
    begin
        TempAccountingPeriod.Reset();
        TempAccountingPeriod.FindSet();
        repeat
            Assert.IsTrue(AccountingPeriod.Get(TempAccountingPeriod."Starting Date"), 'Accounting Period does not exist in BC (' + Format(TempAccountingPeriod."Starting Date") + ')');
            Assert.AreEqual(AccountingPeriod.Name, TempAccountingPeriod.Name, 'Name does not match for Accounting Period (' + Format(TempAccountingPeriod."Starting Date") + ')');
            Assert.AreEqual(AccountingPeriod."New Fiscal Year", TempAccountingPeriod."New Fiscal Year", 'New Fiscal Year does not match for Accounting Period (' + Format(TempAccountingPeriod."Starting Date") + ')');
        until TempAccountingPeriod.Next() = 0;
    end;

    [Test]
    procedure TestCreate13AccountingPeriods()
    var
        TempAccountingPeriod: Record "Accounting Period" temporary;
        SLFiscalPeriods: Codeunit "SL Fiscal Periods";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        SLExpectedBCAccountingPeriodData: XmlPort "SL BC Accounting Period Data";
        BCAccountingPeriodInstream: InStream;
    begin
        Initialize();

        SLTestHelperFunctions.ImportSLGLSetupData13Periods();
        SLPopulateFiscalPeriods.CreateSLFiscalPeriodsFromGLSetup();
        Commit();
        SLFiscalPeriods.MoveStagingData();

        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLAccountingPeriod201501-201813.csv', BCAccountingPeriodInstream);
        SLExpectedBCAccountingPeriodData.SetSource(BCAccountingPeriodInstream);
        SLExpectedBCAccountingPeriodData.Import();
        SLExpectedBCAccountingPeriodData.GetExpectedAccountingPeriods(TempAccountingPeriod);
        ValidateAccountingPeriods(TempAccountingPeriod);
    end;
}