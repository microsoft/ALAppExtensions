// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using Microsoft.Bank.BankAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using System.Integration;

codeunit 47010 "SL Cash Manager Migrator"
{
    var
        BankWarningTxt: Label 'Unable to get %1 posting account.', Comment = '%1 = Posting Group', Locked = true;
        BatchNameTok: Label 'SLCASH', Locked = true;
        BatchDescriptionTxt: Label 'SL Cash Manager Migration Batch', Locked = true;
        DescriptionTxt: Label 'Migrated SL Cash Account Current Balance Amount', Locked = true;
        GeneralLbl: Label 'GENERAL', Locked = true;

    procedure MigrateCashManagerModule()
    var
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        SLCompanyAdditionalSettings.Get(CompanyName);
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if not SLCompanyAdditionalSettings.GetCashManagerModuleEnabled() then
            exit;

        MigrateCashAccounts();
    end;

    procedure MigrateCashAccounts()
    var
        SLCashAcct: Record "SL CashAcct";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        SLCashAcct.SetRange(CpnyID, CompanyName());
        SLCashAcct.SetRange(Active, 1);
        if not SLCashAcct.FindSet() then
            exit;
        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(SLCashAcct.CpnyID.TrimEnd() + '|' + SLCashAcct.BankAcct.TrimEnd() + '|' + SLCashAcct.BankSub.TrimEnd());
            CreateBankAccount(SLCashAcct);
            if not SLCompanyAdditionalSettings.GetMigrateOnlyCashAcctMaster() then
                CreateBankTransactions(SLCashAcct);
        until SLCashAcct.Next() = 0;
    end;

    procedure CreateBankAccount(SLCashAcct: Record "SL CashAcct")
    var
        BankAccount: Record "Bank Account";
        SLAddress: Record "SL Address";
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        if SLCashAcct.BankAcct = '' then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CashAcct', '', 'BankAcct is blank for Cash Account ' + SLCashAcct.CashAcctName.TrimEnd() + '.');
            exit
        end;
        if BankAccount.Get(SLCashAcct.AcctNbr.TrimEnd()) then
            exit;

        BankAccount.Validate("No.", SLCashAcct.BankAcct.TrimEnd());
        BankAccount.Validate(Name, SLCashAcct.CashAcctName.TrimEnd());
        BankAccount.Validate("Bank Account No.", SLCashAcct.AcctNbr.TrimEnd());
        BankAccount."Bank Acc. Posting Group" := GetOrCreateBankAccPostingGroup(SLCashAcct.BankAcct);
        BankAccount."Transit No." := CopyStr(SLCashAcct.transitnbr, 1, MaxStrLen(BankAccount."Transit No."));
        if SLCashAcct.AddrID <> '' then
            if SLAddress.Get(SLCashAcct.AddrID) then begin
                BankAccount.Address := CopyStr(SLAddress.Addr1.TrimEnd(), 1, MaxStrLen(BankAccount.Address));
                BankAccount."Address 2" := CopyStr(SLAddress.Addr2.TrimEnd(), 1, MaxStrLen(BankAccount."Address 2"));
                BankAccount.Validate(City, SLAddress.City.TrimEnd());
                BankAccount.Contact := CopyStr(SLAddress.Attn.TrimEnd(), 1, MaxStrLen(BankAccount.Contact));
                BankAccount."Phone No." := CopyStr(SLAddress.Phone.TrimEnd(), 1, MaxStrLen(BankAccount."Phone No."));
                BankAccount.Validate("Country/Region Code", SLAddress.Country.TrimEnd());
                BankAccount."Fax No." := CopyStr(SLAddress.Fax.TrimEnd(), 1, MaxStrLen(BankAccount."Fax No."));
                BankAccount.Validate("Post Code", SLAddress.Zip.TrimEnd());
                BankAccount.County := CopyStr(SLAddress.State.TrimEnd(), 1, MaxStrLen(BankAccount.County));
            end;
        BankAccount.Insert(true);

        SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CashAcct', 'Data Missing', 'Bank Account ' + SLCashAcct.BankAcct.TrimEnd() + ' created successfully in D365BC.');
    end;

    procedure CreateBankTransactions(SLCashAcct: Record "SL CashAcct")
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        SLCASetup: Record "SL CASetup";
        SLCashSumD: Record "SL CashSumD";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        SLPopulateFiscalPeriods: Codeunit "SL Populate Fiscal Periods";
        PostingAccountNumber: Code[20];
        PeriodEndDate: Date;
        CurrentCashBalance: Decimal;
        TotalDisbursements: Decimal;
        TotalReceipts: Decimal;
        DimSetID: Integer;
        SLCASetupIDTxt: Label 'CA', Locked = true;
    begin
        if SLCashAcct.BankAcct = '' then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CashAcct', 'Data Missing', 'BankAcct is blank for Cash Account ' + SLCashAcct.CashAcctName.TrimEnd() + '.');
            exit;
        end;
        if SLCashAcct.BankSub = '' then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CashAcct', 'Data Missing', 'BankSub is blank for Cash Account ' + SLCashAcct.CashAcctName.TrimEnd() + '.');
            exit;
        end;
        if not BankAccount.Get(SLCashAcct.BankAcct.TrimEnd()) then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'Bank Account', 'Data Missing', 'Bank Account ' + SLCashAcct.BankAcct.TrimEnd() + ' not found in D365BC.');
            exit;
        end;
        if not GetBankAccPostingAccountNumber(PostingAccountNumber, BankAccount."Bank Acc. Posting Group") then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'Bank Account Posting Group', 'Data Missing', 'Unable to get posting account for Bank Account Posting Group ' + BankAccount."Bank Acc. Posting Group" + '.');
            exit;
        end;
        if not SLCASetup.Get(SLCASetupIDTxt) then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CASetup', 'Data Missing', 'SL CASetup record not found.');
            exit;
        end;

        SLCashSumD.SetRange(CpnyID, CompanyName());
        SLCashSumD.SetRange(BankAcct, SLCashAcct.BankAcct.TrimEnd());
        SLCashSumD.SetRange(BankSub, SLCashAcct.BankSub.TrimEnd());
        SLCashSumD.SetFilter(TranDate, '>%1', SLCASetup.paststartdate);
        if not SLCashSumD.FindSet() then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'SL CashSumD', 'Data Missing', 'No SL CashSumD records found for Cash Account ' + SLCashAcct.BankAcct.TrimEnd() + ' and Bank Sub ' + SLCashAcct.BankSub.TrimEnd() + '.');
            exit;
        end;

        SLCashSumD.CalcSums(Disbursements);
        TotalDisbursements := SLCashSumD.Disbursements;
        SLCashSumD.CalcSums(Receipts);
        TotalReceipts := SLCashSumD.Receipts;
        CurrentCashBalance := TotalReceipts - TotalDisbursements;

        if CurrentCashBalance <> 0 then begin
            PeriodEndDate := SLPopulateFiscalPeriods.GetCalendarEndDateOfGLPeriod(SLCASetup.PerNbr);
            CreateBankJournalLine(
                GenJournalLine,
                'SLCASHBALANCE',
                DescriptionTxt,
                '',
                PeriodEndDate,
                PostingAccountNumber,
                CurrentCashBalance,
                BankAccount."No.");

            DimSetID := SLHelperFunctions.GetDimSetIDByFullSubaccount(SLCashAcct.BankSub);
            GenJournalLine.Validate("Dimension Set ID", DimSetID);
            GenJournalLine.Modify(true);
        end;
    end;

    procedure GetOrCreateBankAccPostingGroup(BankAcct: Text[10]): Code[20]
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GLAccount: Record "G/L Account";
    begin
        if not GLAccount.Get(BankAcct) then
            exit;

        // If a posting group already exists for this GL account use it.
        BankAccountPostingGroup.SetRange("G/L Account No.", BankAcct.TrimEnd());
        if BankAccountPostingGroup.FindFirst() then
            exit(BankAccountPostingGroup.Code);

        BankAccountPostingGroup.Code := 'SL' + Format(GetNextPostingGroupNumber());
        BankAccountPostingGroup."G/L Account No." := CopyStr(BankAcct.TrimEnd(), 1, MaxStrLen(BankAccountPostingGroup."G/L Account No."));
        BankAccountPostingGroup.Insert(true);
        exit(BankAccountPostingGroup.Code);
    end;

    procedure GetNextPostingGroupNumber(): Integer
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
    begin
        BankAccountPostingGroup.SetFilter(Code, 'SL' + '*');
        if BankAccountPostingGroup.IsEmpty then
            exit(1);

        exit(BankAccountPostingGroup.Count + 1);
    end;

    procedure GetBankAccPostingAccountNumber(var GLAccountNumber: Code[20]; BankAccPostingGroup: Code[20]): Boolean
    var
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        if not BankAccountPostingGroup.Get(BankAccPostingGroup) then begin
            SLHelperFunctions.LogPostMigrationDataMessage('CASH MANAGER', 'Bank Account Posting Group', 'Data Missing', 'Bank Account Posting Group ' + BankAccPostingGroup + ' not found.');
            Session.LogMessage('0000HRD', StrSubstNo(BankWarningTxt, BankAccPostingGroup), Verbosity::Normal, DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher, 'Category', SLHelperFunctions.GetTelemetryCategory());
            exit(false);
        end;

        GLAccountNumber := BankAccountPostingGroup."G/L Account No.";
        exit(true);
    end;

    procedure CreateBankJournalLine(var GenJournalLine: Record "Gen. Journal Line"; DocumentNo: Code[20]; Description: Text[100]; ExternalDocumentNo: Code[35]; PostingDate: Date; OffsetAccount: Code[20]; TranAmount: Decimal; BankAccount: Code[20])
    var
        GenJournalLineCurrent: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        JournalTemplateName: Code[10];
        LineNumber: Integer;
    begin
        JournalTemplateName := GeneralLbl;
        CreateGeneralJournalBatchIfNeeded(JournalTemplateName);

        GenJournalLineCurrent.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCurrent.SetRange("Journal Batch Name", BatchNameTok);
        if GenJournalLineCurrent.FindLast() then
            LineNumber := GenJournalLineCurrent."Line No." + 10
        else
            LineNumber := 10;

        GenJournalTemplate.Get(JournalTemplateName);
        Clear(GenJournalLine);
        GenJournalLine.SetHideValidation(true);
        GenJournalLine.Validate("Source Code", GenJournalTemplate."Source Code");
        GenJournalLine.Validate("Journal Template Name", JournalTemplateName);
        GenJournalLine.Validate("Journal Batch Name", BatchNameTok);
        GenJournalLine.Validate("Line No.", LineNumber);
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::" ");
        GenJournalLine.Validate("Document No.", DocumentNo);
        GenJournalLine.Validate("External Document No.", ExternalDocumentNo);
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"Bank Account");
        GenJournalLine.Validate("Account No.", BankAccount);
        GenJournalLine.Validate("Description", Description);
        GenJournalLine.Validate("Document Date", PostingDate);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Amount", TranAmount);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", OffsetAccount);
        GenJournalLine.Validate("Bal. Gen. Posting Type", GenJournalLine."Bal. Gen. Posting Type"::" ");
        GenJournalLine.Validate("Bal. Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Bal. Gen. Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Prod. Posting Group", '');
        GenJournalLine.Validate("Bal. VAT Bus. Posting Group", '');
        GenJournalLine.Insert(true);
    end;

    local procedure CreateGeneralJournalBatchIfNeeded(JournalTemplateName: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange(Name, BatchNameTok);
        GenJournalBatch.SetRange("Journal Template Name", JournalTemplateName);

        if GenJournalBatch.FindFirst() then
            exit;

        Clear(GenJournalBatch);
        GenJournalBatch.Validate(Name, BatchNameTok);
        GenJournalBatch.Validate(Description, BatchDescriptionTxt);
        GenJournalBatch.Validate("Journal Template Name", JournalTemplateName);
        GenJournalBatch.SetupNewBatch();
        GenJournalBatch.Insert(true);
    end;
}