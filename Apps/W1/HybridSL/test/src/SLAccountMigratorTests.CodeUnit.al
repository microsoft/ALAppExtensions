// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Foundation.Period;
using System.TestLibraries.Utilities;

codeunit 147602 "SL Account Migrator Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit "Library Assert";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLTestHelperFunctions: Codeunit "SL Test Helper Functions";
        IsInitialized: Boolean;

    local procedure Initialize()
    var
        AccountingPeriod: Record "Accounting Period";
        SLAccountStaging: Record "SL Account Staging";
        SLAcctHist: Record "SL AcctHist";
        SLGLSetup: Record "SL GLSetup";
        SLPeriodListWorkTable: Record "SL Period List Work Table";
    begin
        SLGLSetup.DeleteAll();
        SLPeriodListWorkTable.DeleteAll();
        AccountingPeriod.DeleteAll();

        if IsInitialized then
            exit;

        SLAccountStaging.DeleteAll();
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

    [Test]
    procedure TestAccountBeginningBalance()
    var
        SLAccountStaging: Record "SL Account Staging";
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
        SLAccountMigrator: Codeunit "SL Account Migrator";
        SLFiscalPeriods: Codeunit "SL Fiscal Periods";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        SLExpectedBCGenJournalLineData: XmlPort "SL BC Gen. Journal Line Data";
        BCGenJournalLineInstream: InStream;
    begin
        // [Scenario] Account beginning balances should be migrated to BC

        // [Given] SL AcctHist data with beginning balances
        Initialize();
        SLTestHelperFunctions.ClearAccountTableData();

        // Import supporting test data
        SLTestHelperFunctions.CreateConfigurationSettings();
        SLTestHelperFunctions.ImportSLFlexDefData();
        SLTestHelperFunctions.ImportSLSegmentsData();
        SLTestHelperFunctions.ImportDimensionData();
        SLTestHelperFunctions.ImportDimensionValueData();
        SLTestHelperFunctions.ImportSLAccountStagingData();
        SLTestHelperFunctions.ImportGLAccountData();
        SLTestHelperFunctions.ImportSLGLSetupData12Periods();
        SLPopulateFiscalPeriods.CreateSLFiscalPeriodsFromGLSetup();
        Commit();
        SLFiscalPeriods.MoveStagingData();

        // Set Oldest GL Year to Migrate to 2016
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Oldest GL Year to Migrate", 2016);
        SLCompanyAdditionalSettings.Validate("Skip Posting Account Batches", true);
        SLCompanyAdditionalSettings.Modify();

        // [When] Migrating SL AcctHist data with beginning balances, create Beginning Balances for G/L Accounts, if applicable
        SLAccountStaging.FindSet();
        repeat
            SLAccountMigrator.CreateGLAccountBeginningBalance(SLAccountStaging);
        until SLAccountStaging.Next() = 0;

        // [Then] Verify Accounts have Beginning Balance transactions in BC
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCGenJournalLineBeginningBalance.csv', BCGenJournalLineInstream);
        SLExpectedBCGenJournalLineData.SetSource(BCGenJournalLineInstream);
        SLExpectedBCGenJournalLineData.Import();
        SLExpectedBCGenJournalLineData.GetExpectedGenJournalLines(TempGenJournalLine);
        ValidateAccountBeginningBalanceData(TempGenJournalLine);
    end;

    procedure ValidateAccountBeginningBalanceData(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        TempGenJournalLine.SetRange("Journal Batch Name", 'SL2016-00');
        TempGenJournalLine.FindSet();
        repeat
            Assert.IsTrue(GenJournalLine.Get(TempGenJournalLine."Journal Template Name", TempGenJournalLine."Journal Batch Name", TempGenJournalLine."Line No."), 'Beginning Balance Journal Line does not exist in BC (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Account No.", TempGenJournalLine."Account No.", 'Account No. does not match for Beginning Balance Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine.Amount, TempGenJournalLine.Amount, 'Amount does not match for Beginning Balance Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Debit Amount", TempGenJournalLine."Debit Amount", 'Debit Amount does not match for Beginning Balance Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Credit Amount", TempGenJournalLine."Credit Amount", 'Credit Amount does not match for Beginning Balance Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
        until TempGenJournalLine.Next() = 0;
    end;
}