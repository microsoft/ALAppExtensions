// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.DataMigration.SL;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using System.TestLibraries.Utilities;

codeunit 147604 "SL Cash Manager Migrator Tests"
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
    procedure TestSLCreateBankAccount()
    var
        SLCashAcct: Record "SL CashAcct";
        SLCashManagerMigrator: Codeunit "SL Cash Manager Migrator";
        BankAccountInstream: InStream;
        ExpectedBankAccountData: XmlPort "SL BC Bank Account Data";
        TempBankAccount: Record "Bank Account" temporary;
    begin
        // [Scenario] Cash Account to Bank Account migration
        Initialize();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Enable Cash Management Module settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Cash Manager Module", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [Given] SL data
        SLTestHelperFunctions.ImportSLAddressData();
        SLTestHelperFunctions.ImportSLCashAcctData();

        // [When] Cash Account exist, create Bank Account
        SLCashAcct.SetRange(CpnyID, CompanyName());
        SLCashAcct.SetRange(Active, 1);
        SLCashAcct.FindSet();
        repeat
            // Run Create Bank Account procedure
            SLCashManagerMigrator.CreateBankAccount(SLCashAcct);
        until SLCashAcct.Next() = 0;

        // [Then] Verify Bank Account master data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCBankAccount.csv', BankAccountInstream);
        ExpectedBankAccountData.SetSource(BankAccountInstream);
        ExpectedBankAccountData.Import();
        ExpectedBankAccountData.GetExpectedBankAccounts(TempBankAccount);
        ValidateBankAccountData(TempBankAccount);
    end;

    [Test]
    procedure TestSLCreateBankTransactions()
    var
        SLCashAcct: Record "SL CashAcct";
        SLCashManagerMigrator: Codeunit "SL Cash Manager Migrator";
        SLFiscalPeriods: Codeunit "SL Fiscal Periods";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        BankTransactionInstream: InStream;
        SLExpectedBCGenJournalLineData: XmlPort "SL BC Gen. Journal Line Data";
        TempBankAccount: Record "Bank Account" temporary;
        TempGenJournalLine: Record "Gen. Journal Line" temporary;
    begin
        // [Scenario] Cash Account to Bank Account migration
        Initialize();
        SLTestHelperFunctions.ClearAccountTableData();
        SLTestHelperFunctions.CreateConfigurationSettings();

        // Import supporting test data
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

        // Enable Cash Management Module settings
        SLCompanyAdditionalSettings.GetSingleInstance();
        SLCompanyAdditionalSettings.Validate("Migrate Cash Manager Module", true);
        SLCompanyAdditionalSettings.Validate("Migrate Only CashAcct Master", false);
        SLCompanyAdditionalSettings.Validate("Skip Posting Account Batches", true);
        SLCompanyAdditionalSettings.Modify();
        Commit();

        // [Given] SL data
        SLTestHelperFunctions.ImportSLAddressData();
        SLTestHelperFunctions.ImportSLCashAcctData();
        SLTestHelperFunctions.ImportSLCASetupData();
        SLTestHelperFunctions.ImportSLCashSumDData();

        // [When] Cash Account exist, create Bank Account
        SLCashAcct.SetRange(CpnyID, CompanyName());
        SLCashAcct.SetRange(Active, 1);
        SLCashAcct.FindSet();
        repeat
            // Run Create Bank Account procedure
            SLCashManagerMigrator.CreateBankAccount(SLCashAcct);
            if not SLCompanyAdditionalSettings.GetMigrateOnlyCashAcctMaster() then
                // Run Create Bank Transactions procedure
                SLCashManagerMigrator.CreateBankTransactions(SLCashAcct);
        until SLCashAcct.Next() = 0;

        // [Then] Verify Bank Account General Journal Line data
        SLTestHelperFunctions.GetInputStreamFromResource('datasets/results/SLBCGenJournalLineSLCASH.csv', BankTransactionInstream);
        SLExpectedBCGenJournalLineData.SetSource(BankTransactionInstream);
        SLExpectedBCGenJournalLineData.Import();
        SLExpectedBCGenJournalLineData.GetExpectedGenJournalLines(TempGenJournalLine);
        ValidateBankGenJournalLineData(TempGenJournalLine);
    end;

    procedure ValidateBankAccountData(var TempBankAccount: Record "Bank Account" temporary)
    var
        BankAccount: Record "Bank Account";
    begin
        TempBankAccount.Reset();
        TempBankAccount.FindSet();
        repeat
            Assert.IsTrue(BankAccount.Get(TempBankAccount."No."), 'Bank Account does not exist in BC' + ' (Bank Account: ' + TempBankAccount."No." + ')');
            Assert.AreEqual(TempBankAccount.Name, BankAccount.Name, 'Bank Account Name does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Bank Account No.", BankAccount."Bank Account No.", 'Bank Account No. does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Bank Acc. Posting Group", BankAccount."Bank Acc. Posting Group", 'Bank Acc. Posting Group does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Transit No.", BankAccount."Transit No.", 'Transit No. does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount.Address, BankAccount.Address, 'Address does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Address 2", BankAccount."Address 2", 'Address 2 does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."City", BankAccount."City", 'City does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount.Contact, BankAccount.Contact, 'Contact does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Phone No.", BankAccount."Phone No.", 'Phone No. does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Country/Region Code", BankAccount."Country/Region Code", 'Country/Region Code does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Fax No.", BankAccount."Fax No.", 'Fax No. does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount."Post Code", BankAccount."Post Code", 'Post Code does not match for Bank Account: ' + TempBankAccount."No.");
            Assert.AreEqual(TempBankAccount.County, BankAccount.County, 'County (State) does not match for Bank Account: ' + TempBankAccount."No.");
        until TempBankAccount.Next() = 0;
    end;

    procedure ValidateBankGenJournalLineData(var TempGenJournalLine: Record "Gen. Journal Line" temporary)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        TempGenJournalLine.Reset();
        TempGenJournalLine.SetRange("Journal Template Name", 'GENERAL');
        TempGenJournalLine.SetRange("Journal Batch Name", 'SLCASH');
        TempGenJournalLine.FindSet();
        repeat
            Assert.IsTrue(GenJournalLine.Get(TempGenJournalLine."Journal Template Name", TempGenJournalLine."Journal Batch Name", TempGenJournalLine."Line No."), 'Bank Account Journal Line does not exist in BC (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Account No.", TempGenJournalLine."Account No.", 'Account No. does not match for Bank Account Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine.Amount, TempGenJournalLine.Amount, 'Amount does not match for Bank Account Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Debit Amount", TempGenJournalLine."Debit Amount", 'Debit Amount does not match for Bank Account Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
            Assert.AreEqual(GenJournalLine."Credit Amount", TempGenJournalLine."Credit Amount", 'Credit Amount does not match for Bank Account Journal Line (' + Format(TempGenJournalLine."Line No.") + ')');
        until TempGenJournalLine.Next() = 0;
    end;

    local procedure Initialize()
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        SLAddress: Record "SL Address";
        SLCASetup: Record "SL CASetup";
        SLCashAcct: Record "SL CashAcct";
        SLCashSumD: Record "SL CashSumD";
        SLPeriodListWorkTable: Record "SL Period List Work Table";
    begin
        // Delete/empty buffer tables        
        SLCashAcct.DeleteAll();
        SLAddress.DeleteAll();
        BankAccount.DeleteAll();
        SLCASetup.DeleteAll();
        SLCashSumD.DeleteAll();

        if IsInitialized then
            exit;

        // Empty BC tables
        GLAccount.DeleteAll();

        // Import supporting BC data        
        SLTestHelperFunctions.ImportGLAccountData();
        Commit();
        IsInitialized := true;
    end;
}