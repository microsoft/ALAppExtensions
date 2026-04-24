namespace Microsoft.DataMigration.GP;

using Microsoft.Finance.AllocationAccount;
using Microsoft.Finance.Analysis.StatisticalAccount;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Integration;

codeunit 4017 "GP Account Migrator"
{
    TableNo = "GP Account";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        BeginningBalanceTrxTxt: Label 'Beginning Balance', Locked = true;
        MigrationLogAreaTxt: Label 'Account', Locked = true;
        FiscalYearMissingContextTxt: Label 'Account: %1, Year: %2', Locked = true;
        FiscalYearMissingMessageTxt: Label 'Could not migrate beginning balance because the fiscal year is missing.';
        AllocationAccountMigrationCategoryTok: Label 'Allocation Account: %1', Comment = '%1 = Account Number';
        AllocationAccountSkippedBecauseOfBreakdownIdxMissingErr: Label 'Allocation Account skipped because the breakdown account %1 is missing.', Comment = '%1 = GP Account Index';
        AllocationAccountSkippedBecauseOfDistributionIdxMissingErr: Label 'Allocation Account skipped because the distribution account %1 is missing.', Comment = '%1 = GP Account Index';
        AllocationAccountDistSkippedBecauseOfBreakdownGLMissingErr: Label 'Allocation Account Distribution skipped because the breakdown account %1 is not a G/L Account.', Comment = '%1 = Account Number';
        AllocationAccountDistSkippedBecauseOfDistributionGLMissingErr: Label 'Allocation Account Distribution skipped because the distribution account %1 is not a G/L Account.', Comment = '%1 = Account Number';
        AllocationAccountSkippedBecauseHasNonGLAccountErr: Label 'Allocation Account skipped because it contains a distribution or breakdown account that is not a posting account.';

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    local procedure OnMigrateGlAccount(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPMigrationWarnings: Record "GP Migration Warnings";
        AccountNum: Code[20];
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        GPAccount.Get(RecordIdToMigrate);

        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, 20);
        if AccountNum = '' then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, 'Account Index: ' + Format(GPAccount.AcctIndex), 'Account is skipped because there is no account number.');
            exit;
        end;

        MigrateAccountDetails(GPAccount, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateAccountTransactions', '', true, true)]
    local procedure OnMigrateAccountTransactions(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;

        GPAccount.Get(RecordIdToMigrate);

        GenerateGLTransactionBatches(GPAccount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    local procedure OnMigratePostingGroups(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        GPAccount.Get(RecordIdToMigrate);

        if GPAccount.AccountType <> 1 then
            exit;

        if not GLAccount.Get(GPAccount.AcctNum) then
            exit;

        Sender.CreateGenBusinessPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50));
        Sender.CreateGenProductPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50));
        Sender.CreateGeneralPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 10));

        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesAccount') then
            Sender.SetGeneralPostingSetupSalesAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
            Sender.SetGeneralPostingSetupSalesLineDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
            Sender.SetGeneralPostingSetupSalesInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount') then
            Sender.SetGeneralPostingSetupSalesPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchAccount') then
            Sender.SetGeneralPostingSetupPurchAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount') then
            Sender.SetGeneralPostingSetupPurchInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('COGSAccount') then
            Sender.SetGeneralPostingSetupCOGSAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('COGSAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
            Sender.SetGeneralPostingSetupInventoryAdjmtAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
            Sender.SetGeneralPostingSetupSalesCreditMemoAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc') then
            Sender.SetGeneralPostingSetupPurchPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount') then
            Sender.SetGeneralPostingSetupPurchPrepaymentsAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount'));
        if GPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount') then
            Sender.SetGeneralPostingSetupPurchaseVarianceAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount'));

        Sender.ModifyGLAccount(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnCreateOpeningBalanceTrx', '', true, true)]
    local procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;

        GPAccount.Get(RecordIdToMigrate);
        if GPAccount.IncomeBalance then
            exit;

        CreateBeginningBalance(GPAccount);
    end;

#pragma warning disable AS0078
    procedure CreateBeginningBalance(var GPAccount: Record "GP Account")
#pragma warning restore AS0078
    begin
        case GPAccount.AccountType of
            1:
                CreateGLAccountBeginningBalanceImp(GPAccount);
            2:
                CreateStatisticalAccountBeginningBalanceImp(GPAccount);
        end;
    end;

    local procedure CreateGLAccountBeginningBalanceImp(var GPAccount: Record "GP Account")
    var
        GLAccount: Record "G/L Account";
        GPGL10111: Record "GP GL10111";
        GenJournalLine: Record "Gen. Journal Line";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPMigrationWarnings: Record "GP Migration Warnings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        HelperFunctions: Codeunit "Helper Functions";
        BeginningBalance: Decimal;
        PostingGroupCode: Code[10];
        InitialYear: Integer;
        ACTNUMBR_1: Code[20];
        ACTNUMBR_2: Code[20];
        ACTNUMBR_3: Code[20];
        ACTNUMBR_4: Code[20];
        ACTNUMBR_5: Code[20];
        ACTNUMBR_6: Code[20];
        ACTNUMBR_7: Code[20];
        ACTNUMBR_8: Code[20];
        DimSetID: Integer;
    begin
        if not GLAccount.Get(GPAccount.AcctNum) then
            exit;

        InitialYear := GPCompanyAdditionalSettings.GetInitialYear();
        if InitialYear = 0 then
            exit;

        GPGL10111.SetRange(ACTINDX, GPAccount.AcctIndex);
        GPGL10111.SetRange(PERIODID, 0);
        GPGL10111.SetRange(YEAR1, InitialYear);
        if not GPGL10111.FindFirst() then
            exit;

        BeginningBalance := GPGL10111.PERDBLNC;
        if BeginningBalance = 0 then
            exit;

        PostingGroupCode := PostingGroupCodeTxt + Format(InitialYear) + 'BB';
        if not GPFiscalPeriods.Get(0, InitialYear) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(FiscalYearMissingContextTxt, GPAccount.AcctNum, InitialYear), FiscalYearMissingMessageTxt);
            exit;
        end;

        DataMigrationFacadeHelper.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, 10), '', '');
        DataMigrationFacadeHelper.CreateGeneralJournalLine(
            GenJournalLine,
            PostingGroupCode,
            PostingGroupCode,
            BeginningBalanceTrxTxt,
            GenJournalLine."Account Type"::"G/L Account",
            CopyStr(GPAccount.AcctNum, 1, 20),
            GPFiscalPeriods.PERIODDT,
            0D,
            BeginningBalance,
            BeginningBalance,
            '',
            ''
            );

        ACTNUMBR_1 := GPGL10111.ACTNUMBR_1;
        ACTNUMBR_2 := GPGL10111.ACTNUMBR_2;
        ACTNUMBR_3 := GPGL10111.ACTNUMBR_3;
        ACTNUMBR_4 := GPGL10111.ACTNUMBR_4;
        ACTNUMBR_5 := GPGL10111.ACTNUMBR_5;
        ACTNUMBR_6 := GPGL10111.ACTNUMBR_6;
        ACTNUMBR_7 := GPGL10111.ACTNUMBR_7;
        ACTNUMBR_8 := GPGL10111.ACTNUMBR_8;

        if HelperFunctions.AreAllSegmentNumbersEmpty(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8) then
            HelperFunctions.GetSegmentNumbersFromGPAccountIndex(GPGL10111.ACTINDX, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);

        DimSetID := HelperFunctions.CreateDimSet(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);
        GenJournalLine.Validate("Dimension Set ID", DimSetID);
        GenJournalLine.Modify(true);
    end;

    local procedure CreateStatisticalAccountBeginningBalanceImp(var GPAccount: Record "GP Account")
    var
        GPGL00100: Record "GP GL00100";
        GPGL10111: Record "GP GL10111";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        StatisticalAccJournalLineCurrent: Record "Statistical Acc. Journal Line";
        GPMigrationWarnings: Record "GP Migration Warnings";
        HelperFunctions: Codeunit "Helper Functions";
        InitialYear: Integer;
        BeginningBalance: Decimal;
        DocumentNo: Code[20];
        LineNum: Integer;
        ACTNUMBR_1: Code[20];
        ACTNUMBR_2: Code[20];
        ACTNUMBR_3: Code[20];
        ACTNUMBR_4: Code[20];
        ACTNUMBR_5: Code[20];
        ACTNUMBR_6: Code[20];
        ACTNUMBR_7: Code[20];
        ACTNUMBR_8: Code[20];
        DimSetID: Integer;
    begin
        InitialYear := GPCompanyAdditionalSettings.GetInitialYear();
        if InitialYear = 0 then
            exit;

        if not GPGL00100.Get(GPAccount.AcctIndex) then
            exit;

        if GPGL00100.Clear_Balance then
            exit;

        GPGL10111.SetRange(ACTINDX, GPAccount.AcctIndex);
        GPGL10111.SetRange(PERIODID, 0);
        GPGL10111.SetRange(YEAR1, InitialYear);
        if not GPGL10111.FindFirst() then
            exit;

        BeginningBalance := GPGL10111.PERDBLNC;
        if BeginningBalance = 0 then
            exit;

        DocumentNo := PostingGroupCodeTxt + Format(InitialYear) + 'BB';
        if not GPFiscalPeriods.Get(0, InitialYear) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(FiscalYearMissingContextTxt, GPAccount.AcctNum, InitialYear), FiscalYearMissingMessageTxt);
            exit;
        end;

        if not StatisticalAccJournalBatch.Get('', DocumentNo) then begin
            StatisticalAccJournalBatch.Validate(Name, DocumentNo);
            StatisticalAccJournalBatch.Insert(true);
        end;

        StatisticalAccJournalLineCurrent.SetRange("Journal Batch Name", StatisticalAccJournalBatch.Name);
        if StatisticalAccJournalLineCurrent.FindLast() then
            LineNum := StatisticalAccJournalLineCurrent."Line No." + 10000
        else
            LineNum := 10000;

        StatisticalAccJournalLine.Validate("Journal Batch Name", DocumentNo);
        StatisticalAccJournalLine.Validate("Line No.", LineNum);
        StatisticalAccJournalLine.Validate("Document No.", DocumentNo);
        StatisticalAccJournalLine.Validate(Description, CopyStr(BeginningBalanceTrxTxt, 1, MaxStrLen(StatisticalAccJournalLine.Description)));
        StatisticalAccJournalLine.Validate("Statistical Account No.", CopyStr(GPAccount.AcctNum, 1, MaxStrLen(StatisticalAccJournalLine."Statistical Account No.")));
        StatisticalAccJournalLine.Validate("Posting Date", GPFiscalPeriods.PERIODDT);
        StatisticalAccJournalLine.Validate(Amount, BeginningBalance);
        StatisticalAccJournalLine.Insert();

        ACTNUMBR_1 := GPGL10111.ACTNUMBR_1;
        ACTNUMBR_2 := GPGL10111.ACTNUMBR_2;
        ACTNUMBR_3 := GPGL10111.ACTNUMBR_3;
        ACTNUMBR_4 := GPGL10111.ACTNUMBR_4;
        ACTNUMBR_5 := GPGL10111.ACTNUMBR_5;
        ACTNUMBR_6 := GPGL10111.ACTNUMBR_6;
        ACTNUMBR_7 := GPGL10111.ACTNUMBR_7;
        ACTNUMBR_8 := GPGL10111.ACTNUMBR_8;

        if HelperFunctions.AreAllSegmentNumbersEmpty(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8) then
            HelperFunctions.GetSegmentNumbersFromGPAccountIndex(GPGL10111.ACTINDX, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);

        DimSetID := HelperFunctions.CreateDimSet(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);
        StatisticalAccJournalLine.Validate("Dimension Set ID", DimSetID);
        StatisticalAccJournalLine.Modify(true);
    end;

#pragma warning disable AS0078
    procedure MigrateAccountDetails(var GPAccount: Record "GP Account"; var GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
#pragma warning restore AS0078
    begin
        case GPAccount.AccountType of
            1:
                MigrateGLAccountDetailsImp(GPAccount, GLAccDataMigrationFacade);
            2:
                MigrateStatisticalAccountDetailsImp(GPAccount);
        end;
    end;

    local procedure MigrateGLAccountDetailsImp(var GPAccount: Record "GP Account"; var GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        HelperFunctions: Codeunit "Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        AccountType: Option Posting;
        AccountNum: Code[20];
    begin
        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, 20);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(AccountNum, CopyStr(GPAccount.Name, 1, 50), AccountType::Posting) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPAccount.RecordId));
        GLAccDataMigrationFacade.SetAccountCategory(HelperFunctions.ConvertAccountCategory(GPAccount));
        GLAccDataMigrationFacade.SetDebitCreditType(HelperFunctions.ConvertDebitCreditType(GPAccount));
        GLAccDataMigrationFacade.SetAccountSubCategory(HelperFunctions.AssignSubAccountCategory(GPAccount));
        GLAccDataMigrationFacade.SetIncomeBalanceType(HelperFunctions.ConvertIncomeBalanceType(GPAccount));
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    local procedure MigrateStatisticalAccountDetailsImp(var GPAccount: Record "GP Account")
    var
        StatisticalAccount: Record "Statistical Account";
        GeneralLedgerSetup: Record "General Ledger Setup";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        AccountNum: Code[20];
    begin
        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, MaxStrLen(StatisticalAccount."No."));

        if StatisticalAccount.Get(AccountNum) then
            exit;

        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPAccount.RecordId));

        StatisticalAccount."No." := AccountNum;
        StatisticalAccount.Name := CopyStr(GPAccount.Name, 1, MaxStrLen(StatisticalAccount.Name));

        if GeneralLedgerSetup.Get() then begin
            StatisticalAccount."Global Dimension 1 Code" := GeneralLedgerSetup."Global Dimension 1 Code";
            StatisticalAccount."Global Dimension 2 Code" := GeneralLedgerSetup."Global Dimension 2 Code";
        end;

        StatisticalAccount.Insert(true);
    end;

#pragma warning disable AS0078
    procedure GenerateGLTransactionBatches(var GPAccount: Record "GP Account")
#pragma warning restore AS0078
    begin
        case GPAccount.AccountType of
            1:
                GenerateGLAccountTransactionsImp(GPAccount);
            2:
                GenerateStatisticalAccountTransactionsImp(GPAccount);
        end;
    end;

    local procedure GenerateGLAccountTransactionsImp(var GPAccount: Record "GP Account")
    var
        GPGLTransactions: Record "GP GLTransactions";
        GenJournalLine: Record "Gen. Journal Line";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GLAccount: Record "G/L Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        HelperFunctions: Codeunit "Helper Functions";
        DocumentNo: Code[10];
        DimSetID: Integer;
        InitialYear: Integer;
    begin
        if not GLAccount.Get(GPAccount.AcctNum) then
            exit;

        InitialYear := GPCompanyAdditionalSettings.GetInitialYear();

        GPGLTransactions.SetCurrentKey(YEAR1, PERIODID, ACTINDX);
        GPGLTransactions.SetRange(ACTINDX, GPAccount.AcctIndex);

        if InitialYear > 0 then
            GPGLTransactions.SetFilter(YEAR1, '>= %1', InitialYear);

        if GPGLTransactions.FindSet() then
            repeat
                DocumentNo := PostingGroupCodeTxt + Format(GPGLTransactions.YEAR1) + '-' + Format(GPGLTransactions.PERIODID);

                if GPFiscalPeriods.Get(GPGLTransactions.PERIODID, GPGLTransactions.YEAR1) then begin
                    DataMigrationFacadeHelper.CreateGeneralJournalBatchIfNeeded(CopyStr(DocumentNo, 1, 10), '', '');
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                        GenJournalLine,
                        DocumentNo,
                        DocumentNo,
                        CopyStr(DescriptionTrxTxt, 1, 50),
                        GenJournalLine."Account Type"::"G/L Account",
                        CopyStr(GPAccount.AcctNum, 1, 20),
                        GPFiscalPeriods.PERDENDT,//  End date for the fiscal period.
                        0D,
                        GPGLTransactions.PERDBLNC,
                        GPGLTransactions.PERDBLNC,
                        '',
                        ''
                        );

                    DimSetID := HelperFunctions.CreateDimSet(GPGLTransactions.ACTNUMBR_1, GPGLTransactions.ACTNUMBR_2, GPGLTransactions.ACTNUMBR_3, GPGLTransactions.ACTNUMBR_4, GPGLTransactions.ACTNUMBR_5, GPGLTransactions.ACTNUMBR_6, GPGLTransactions.ACTNUMBR_7, GPGLTransactions.ACTNUMBR_8);
                    GenJournalLine.Validate("Dimension Set ID", DimSetID);
                    GenJournalLine.Modify(true);
                end;
            until GPGLTransactions.Next() = 0;
    end;

    local procedure GenerateStatisticalAccountTransactionsImp(var GPAccount: Record "GP Account")
    var
        GPGLTransactions: Record "GP GLTransactions";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        StatisticalAccount: Record "Statistical Account";
        StatisticalAccJournalBatch: Record "Statistical Acc. Journal Batch";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
        StatisticalAccJournalLineCurrent: Record "Statistical Acc. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
        InitialYear: Integer;
        DocumentNo: Code[10];
        LineNum: Integer;
        DimSetID: Integer;
    begin
        if not StatisticalAccount.Get(GPAccount.AcctNum) then
            exit;

        InitialYear := GPCompanyAdditionalSettings.GetInitialYear();

        GPGLTransactions.SetCurrentKey(YEAR1, PERIODID, ACTINDX);
        GPGLTransactions.SetRange(ACTINDX, GPAccount.AcctIndex);

        if InitialYear > 0 then
            GPGLTransactions.SetFilter(YEAR1, '>= %1', InitialYear);

        if GPGLTransactions.FindSet() then
            repeat
                DocumentNo := PostingGroupCodeTxt + Format(GPGLTransactions.YEAR1) + '-' + Format(GPGLTransactions.PERIODID);
                if GPFiscalPeriods.Get(GPGLTransactions.PERIODID, GPGLTransactions.YEAR1) then begin
                    if not StatisticalAccJournalBatch.Get('', DocumentNo) then begin
                        StatisticalAccJournalBatch.Validate(Name, DocumentNo);
                        StatisticalAccJournalBatch.Insert(true);
                    end;

                    StatisticalAccJournalLineCurrent.SetRange("Journal Batch Name", StatisticalAccJournalBatch.Name);
                    if StatisticalAccJournalLineCurrent.FindLast() then
                        LineNum := StatisticalAccJournalLineCurrent."Line No." + 10000
                    else
                        LineNum := 10000;

                    StatisticalAccJournalLine.Validate("Journal Batch Name", DocumentNo);
                    StatisticalAccJournalLine.Validate("Line No.", LineNum);
                    StatisticalAccJournalLine.Validate("Document No.", DocumentNo);
                    StatisticalAccJournalLine.Validate(Description, CopyStr(DescriptionTrxTxt, 1, MaxStrLen(StatisticalAccJournalLine.Description)));
                    StatisticalAccJournalLine.Validate("Statistical Account No.", CopyStr(GPAccount.AcctNum, 1, MaxStrLen(StatisticalAccJournalLine."Statistical Account No.")));
                    StatisticalAccJournalLine.Validate("Posting Date", GPFiscalPeriods.PERIODDT);
                    StatisticalAccJournalLine.Validate(Amount, GPGLTransactions.PERDBLNC);
                    StatisticalAccJournalLine.Insert();

                    DimSetID := HelperFunctions.CreateDimSet(GPGLTransactions.ACTNUMBR_1, GPGLTransactions.ACTNUMBR_2, GPGLTransactions.ACTNUMBR_3, GPGLTransactions.ACTNUMBR_4, GPGLTransactions.ACTNUMBR_5, GPGLTransactions.ACTNUMBR_6, GPGLTransactions.ACTNUMBR_7, GPGLTransactions.ACTNUMBR_8);
                    StatisticalAccJournalLine.Validate("Dimension Set ID", DimSetID);
                    StatisticalAccJournalLine.Modify(true);
                end;
            until GPGLTransactions.Next() = 0;
    end;

    internal procedure CreateAllocationAccounts()
    var
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GPAccount: Record "GP Account";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
    begin
        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        GPAccount.SetRange(AccountType, 3);
        if not GPCompanyAdditionalSettings.GetMigrateInactiveAllocationAccounts() then
            GPAccount.SetRange(Active, true);

        if not GPAccount.FindSet() then
            exit;

        repeat
            DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(GPAccount.RecordId));
            MigrateAllocationAccount(GPAccount);
        until GPAccount.Next() = 0;
    end;

    local procedure MigrateAllocationAccount(var GPAccount: Record "GP Account")
    begin
        case GPAccount."Sub Type" of
            GPAccount."Sub Type"::Fixed:
                MigrateFixedAllocationAccountImp(GPAccount);
            GPAccount."Sub Type"::Variable:
                MigrateVariableAllocationAccountImp(GPAccount);
        end;
    end;

    local procedure MigrateFixedAllocationAccountImp(var GPAccount: Record "GP Account")
    var
        AllocationAccount: Record "Allocation Account";
        GPGL00103: Record "GP GL00103";
        GPMigrationWarnings: Record "GP Migration Warnings";
        AccountNum: Code[20];
        LineNo: Integer;
    begin
        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, MaxStrLen(AllocationAccount."No."));

        if AllocationAccount.Get(AccountNum) then
            exit;

        GPGL00103.SetRange(ACTINDX, GPAccount.AcctIndex);
        GPGL00103.SetRange("Dist. Is Posting Account", false);
        if not GPGL00103.IsEmpty() then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), AllocationAccountSkippedBecauseHasNonGLAccountErr);
            exit;
        end;

        GPGL00103.Reset();
        GPGL00103.SetRange(ACTINDX, GPAccount.AcctIndex);
        if not GPGL00103.FindSet() then
            exit;

        Clear(AllocationAccount);
        AllocationAccount.Validate("No.", AccountNum);
        AllocationAccount.Validate(Name, GPAccount.Name);
        AllocationAccount.Validate("Account Type", AllocationAccount."Account Type"::Fixed);
        AllocationAccount.Validate("Document Lines Split", AllocationAccount."Document Lines Split"::"Split Amount");
        AllocationAccount.Insert(true);

        repeat
            CreateFixedAllocationAccountDistribution(AllocationAccount, GPGL00103, GPMigrationWarnings, LineNo, AccountNum);
        until GPGL00103.Next() = 0;
    end;

    local procedure CreateFixedAllocationAccountDistribution(var AllocationAccount: Record "Allocation Account"; var GPGL00103: Record "GP GL00103"; var GPMigrationWarnings: Record "GP Migration Warnings"; var LineNo: Integer; AccountNum: Code[20])
    var
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        DistGPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "Helper Functions";
        DistAccountNum: Code[20];
        DimSetID: Integer;
    begin
        if not DistGPAccount.Get(GPGL00103.DSTINDX) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountSkippedBecauseOfDistributionIdxMissingErr, GPGL00103.DSTINDX));
            exit;
        end;

        DistAccountNum := CopyStr(DistGPAccount.AcctNum.Trim(), 1, MaxStrLen(AllocationAccount."No."));

        if not GLAccount.Get(DistAccountNum) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountDistSkippedBecauseOfDistributionGLMissingErr, DistAccountNum));
            exit;
        end;

        LineNo := LineNo + 10000;

        Clear(AllocAccountDistribution);
        AllocAccountDistribution.Validate("Allocation Account No.", AccountNum);
        AllocAccountDistribution.Validate("Line No.", LineNo);
        AllocAccountDistribution.Validate("Account Type", AllocAccountDistribution."Account Type"::Fixed);
        AllocAccountDistribution.Validate(Share, GPGL00103.PRCNTAGE);
        AllocAccountDistribution.Validate("Destination Account Type", AllocAccountDistribution."Destination Account Type"::"G/L Account");
        AllocAccountDistribution.Validate("Destination Account Number", DistAccountNum);

        DimSetID := HelperFunctions.CreateDimSet(DistGPAccount.ACTNUMBR_1, DistGPAccount.ACTNUMBR_2, DistGPAccount.ACTNUMBR_3, DistGPAccount.ACTNUMBR_4, DistGPAccount.ACTNUMBR_5, DistGPAccount.ACTNUMBR_6, DistGPAccount.ACTNUMBR_7, DistGPAccount.ACTNUMBR_8);
        AllocAccountDistribution.Validate("Dimension Set ID", DimSetID);

        AllocAccountDistribution.Insert(true);
    end;

    local procedure MigrateVariableAllocationAccountImp(var GPAccount: Record "GP Account")
    var
        AllocationAccount: Record "Allocation Account";
        GPGL00104: Record "GP GL00104";
        GPMigrationWarnings: Record "GP Migration Warnings";
        AccountNum: Code[20];
        LineNo: Integer;
    begin
        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, MaxStrLen(AllocationAccount."No."));

        if AllocationAccount.Get(AccountNum) then
            exit;

        GPGL00104.SetRange(ACTINDX, GPAccount.AcctIndex);
        GPGL00104.SetRange("Dist. Is Posting Account", false);
        if not GPGL00104.IsEmpty() then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), AllocationAccountSkippedBecauseHasNonGLAccountErr);
            exit;
        end;

        GPGL00104.Reset();
        GPGL00104.SetRange(ACTINDX, GPAccount.AcctIndex);
        GPGL00104.SetRange("Brkdn. Is Posting Account", false);
        if not GPGL00104.IsEmpty() then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), AllocationAccountSkippedBecauseHasNonGLAccountErr);
            exit;
        end;

        GPGL00104.Reset();
        GPGL00104.SetRange(ACTINDX, GPAccount.AcctIndex);
        if not GPGL00104.FindSet() then
            exit;

        Clear(AllocationAccount);
        AllocationAccount.Validate("No.", AccountNum);
        AllocationAccount.Validate(Name, GPAccount.Name);
        AllocationAccount.Validate("Account Type", AllocationAccount."Account Type"::Variable);
        AllocationAccount.Validate("Document Lines Split", AllocationAccount."Document Lines Split"::"Split Amount");
        AllocationAccount.Insert(true);

        repeat
            CreateVariableAllocationAccountDistribution(GPAccount, AllocationAccount, GPGL00104, GPMigrationWarnings, LineNo, AccountNum);
        until GPGL00104.Next() = 0;
    end;

    local procedure CreateVariableAllocationAccountDistribution(var GPAccount: Record "GP Account"; var AllocationAccount: Record "Allocation Account"; var GPGL00104: Record "GP GL00104"; var GPMigrationWarnings: Record "GP Migration Warnings"; var LineNo: Integer; AccountNum: Code[20])
    var
        AllocAccountDistribution: Record "Alloc. Account Distribution";
        BreakdownGPAccount: Record "GP Account";
        DistGPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "Helper Functions";
        BreakdownAccountNum: Code[20];
        DistAccountNum: Code[20];
        DimSetID: Integer;
    begin
        if not BreakdownGPAccount.Get(GPGL00104.BDNINDX) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountSkippedBecauseOfBreakdownIdxMissingErr, GPGL00104.BDNINDX));
            exit;
        end;

        if not DistGPAccount.Get(GPGL00104.DSTINDX) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountSkippedBecauseOfDistributionIdxMissingErr, GPGL00104.DSTINDX));
            exit;
        end;

        BreakdownAccountNum := CopyStr(BreakdownGPAccount.AcctNum.Trim(), 1, MaxStrLen(AllocationAccount."No."));
        DistAccountNum := CopyStr(DistGPAccount.AcctNum.Trim(), 1, MaxStrLen(AllocationAccount."No."));

        if not GLAccount.Get(BreakdownAccountNum) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountDistSkippedBecauseOfBreakdownGLMissingErr, BreakdownAccountNum));
            exit;
        end;

        if not GLAccount.Get(DistAccountNum) then begin
            GPMigrationWarnings.InsertWarning(MigrationLogAreaTxt, StrSubstNo(AllocationAccountMigrationCategoryTok, AccountNum), StrSubstNo(AllocationAccountDistSkippedBecauseOfDistributionGLMissingErr, DistAccountNum));
            exit;
        end;

        LineNo := LineNo + 10000;

        Clear(AllocAccountDistribution);
        AllocAccountDistribution.Validate("Allocation Account No.", AccountNum);
        AllocAccountDistribution.Validate("Line No.", LineNo);
        AllocAccountDistribution.Validate("Account Type", AllocAccountDistribution."Account Type"::Variable);

        AllocAccountDistribution.Validate("Breakdown Account Type", AllocAccountDistribution."Breakdown Account Type"::"G/L Account");
        AllocAccountDistribution.Validate("Breakdown Account Number", BreakdownAccountNum);

        AllocAccountDistribution.Validate("Destination Account Type", AllocAccountDistribution."Destination Account Type"::"G/L Account");
        AllocAccountDistribution.Validate("Destination Account Number", DistAccountNum);

        case GPAccount."Balance For Calculation" of
            GPAccount."Balance For Calculation"::YTD:
                AllocAccountDistribution.Validate("Calculation Period", AllocAccountDistribution."Calculation Period"::"Balance at Date");
            GPAccount."Balance For Calculation"::Period:
                AllocAccountDistribution.Validate("Calculation Period", AllocAccountDistribution."Calculation Period"::Month);
        end;

        DimSetID := HelperFunctions.CreateDimSet(DistGPAccount.ACTNUMBR_1, DistGPAccount.ACTNUMBR_2, DistGPAccount.ACTNUMBR_3, DistGPAccount.ACTNUMBR_4, DistGPAccount.ACTNUMBR_5, DistGPAccount.ACTNUMBR_6, DistGPAccount.ACTNUMBR_7, DistGPAccount.ACTNUMBR_8);
        AllocAccountDistribution.Validate("Dimension Set ID", DimSetID);

        AllocAccountDistribution.Insert(true);
    end;
}