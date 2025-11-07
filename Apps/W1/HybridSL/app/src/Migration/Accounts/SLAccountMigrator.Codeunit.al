// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;

codeunit 47000 "SL Account Migrator"
{
    Access = Internal;

    var
        BeginningBalanceDescriptionTxt: Label 'Beginning Balance for ', Locked = true;
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from SL', Locked = true;
        GLModuleIDLbl: Label 'GL', Locked = true;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", OnMigrateGlAccount, '', true, true)]
    local procedure OnMigrateGlAccount(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLAccountStaging: Record "SL Account Staging";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        SLAccountStaging.Get(RecordIdToMigrate);
        MigrateAccountDetails(SLAccountStaging, Sender);
    end;

    internal procedure MigrateAccountDetails(SLAccountStaging: Record "SL Account Staging"; GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        AccountNum: Code[20];
        AccountType: Option Posting;
    begin
        if not SLAccountStaging.Active then
            exit;
        AccountNum := CopyStr(SLAccountStaging.AcctNum, 1, MaxStrLen(SLAccountStaging.AcctNum));
        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(AccountNum, CopyStr(SLAccountStaging.Name, 1, MaxStrLen(SLAccountStaging.Name)), AccountType::Posting) then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAccountStaging.RecordId));
        GLAccDataMigrationFacade.SetAccountCategory(SLHelperFunctions.ConvertAccountCategory(SLAccountStaging));
        GLAccDataMigrationFacade.SetDebitCreditType(SLHelperFunctions.ConvertDebitCreditType(SLAccountStaging));
        GLAccDataMigrationFacade.SetIncomeBalanceType(SLHelperFunctions.ConvertIncomeBalanceType(SLAccountStaging));
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", OnMigrateAccountTransactions, '', true, true)]
    local procedure OnMigrateAccountTransactions(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLAccountStaging: Record "SL Account Staging";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if SLCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;
        SLAccountStaging.Get(RecordIdToMigrate);
        GenerateGLTransactionBatches(SLAccountStaging);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", OnMigratePostingGroups, '', true, true)]
    local procedure OnMigratePostingGroups(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        MigratePostingGroups(Sender, RecordIdToMigrate);
    end;

    internal procedure MigratePostingGroups(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLAccountStaging: Record "SL Account Staging";
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        SLAccountStaging.Get(RecordIdToMigrate);
        if not SLAccountStaging.Active then
            exit;
        Sender.CreateGenBusinessPostingGroupIfNeeded(PostingGroupCodeTxt, PostingGroupDescriptionTxt);
        Sender.CreateGenProductPostingGroupIfNeeded(PostingGroupCodeTxt, PostingGroupDescriptionTxt);
        Sender.CreateGeneralPostingSetupIfNeeded(PostingGroupCodeTxt);

        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('SalesAccount') then
            Sender.SetGeneralPostingSetupSalesAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('SalesAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
            Sender.SetGeneralPostingSetupSalesLineDiscAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
            Sender.SetGeneralPostingSetupSalesInvDiscAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount') then
            Sender.SetGeneralPostingSetupSalesPmtDiscDebitAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('PurchAccount') then
            Sender.SetGeneralPostingSetupPurchAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('PurchAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount') then
            Sender.SetGeneralPostingSetupPurchInvDiscAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('COGSAccount') then
            Sender.SetGeneralPostingSetupCOGSAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('COGSAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
            Sender.SetGeneralPostingSetupInventoryAdjmtAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
            Sender.SetGeneralPostingSetupSalesCreditMemoAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc') then
            Sender.SetGeneralPostingSetupPurchPmtDiscDebitAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount') then
            Sender.SetGeneralPostingSetupPurchPrepaymentsAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount'));
        if SLAccountStaging.AcctNum = SLHelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount') then
            Sender.SetGeneralPostingSetupPurchaseVarianceAccount(PostingGroupCodeTxt, SLHelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount'));
        Sender.ModifyGLAccount(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", OnCreateOpeningBalanceTrx, '', true, true)]
    local procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    begin
        CreateOpeningBalanceTrx(Sender, RecordIdToMigrate);
    end;

    internal procedure CreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        SLAccountStaging: Record "SL Account Staging";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        if not SLCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;
        if SLCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;

        SLAccountStaging.Get(RecordIdToMigrate);
        if SLAccountStaging.IncomeBalance then
            exit;

        CreateGLAccountBeginningBalance(SLAccountStaging);
    end;

    internal procedure CreateGLAccountBeginningBalance(SLAcccountStaging: Record "SL Account Staging");
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        SLAcctHist: Record "SL AcctHist";
        SLCompanyAdditionalSettings: Record "SL Company Additional Settings";
        SLFiscalPeriods: Record "SL Fiscal Periods";
        SLGLSetup: Record "SL GLSetup";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        SLPopulateAccountHistory: Codeunit "SL Populate Account History";
        PostingGroupCode: Code[10];
        SubSegment_1: Code[20];
        SubSegment_2: Code[20];
        SubSegment_3: Code[20];
        SubSegment_4: Code[20];
        SubSegment_5: Code[20];
        SubSegment_6: Code[20];
        SubSegment_7: Code[20];
        SubSegment_8: Code[20];
        BeginningBalanceDate: Date;
        BeginningBalance: Decimal;
        InitialYear: Integer;
        PreviousYear: Integer;
        NbrOfSegments: Integer;
        DimSetID: Integer;
        BeginningBalancePeriodTxt: Label '-00', Locked = true;
    begin
        if not GLAccount.Get(SLAcccountStaging.AcctNum) then
            exit;
        if not SLGLSetup.Get(GLModuleIDLbl) then
            exit;

        SLCompanyAdditionalSettings.GetSingleInstance();
        InitialYear := SLCompanyAdditionalSettings.GetInitialYear();
        if InitialYear = 0 then
            exit;
        PreviousYear := InitialYear - 1;
        if SLFiscalPeriods.Get(SLGLSetup.NbrPer, PreviousYear) then
            BeginningBalanceDate := SLFiscalPeriods.PerEndDT
        else
            exit;

        NbrOfSegments := SLPopulateAccountHistory.GetNumberOfSegments();

        PostingGroupCode := PostingGroupCodeTxt + Format(InitialYear) + BeginningBalancePeriodTxt;
        SLAcctHist.SetRange(CpnyID, CompanyName());
        SLAcctHist.SetRange(Acct, SLAcccountStaging.AcctNum);
        SLAcctHist.SetRange(LedgerID, SLGLSetup.LedgerID);
        SLAcctHist.SetRange(FiscYr, Format(InitialYear));

        if SLAcctHist.FindSet() then
            repeat
                if SLAcccountStaging.AccountCategory = 2 then
                    BeginningBalance := SLAcctHist.BegBal * -1
                else
                    BeginningBalance := SLAcctHist.BegBal;
                if BeginningBalance <> 0 then begin
                    CreateBeginningBalanceGenJournalBatchIfNeeded(PostingGroupCode, InitialYear);
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                        GenJournalLine,
                        PostingGroupCode,
                        PostingGroupCode,
                        BeginningBalanceDescriptionTxt + Format(InitialYear),
                        GenJournalLine."Account Type"::"G/L Account",
                        SLAcccountStaging.AcctNum,
                        BeginningBalanceDate,
                        0D,
                        BeginningBalance,
                        BeginningBalance,
                        '',
                        '');

                    SubSegment_1 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 1, NbrOfSegments), 1, MaxStrLen(SubSegment_1));
                    SubSegment_2 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 2, NbrOfSegments), 1, MaxStrLen(SubSegment_2));
                    SubSegment_3 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 3, NbrOfSegments), 1, MaxStrLen(SubSegment_3));
                    SubSegment_4 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 4, NbrOfSegments), 1, MaxStrLen(SubSegment_4));
                    SubSegment_5 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 5, NbrOfSegments), 1, MaxStrLen(SubSegment_5));
                    SubSegment_6 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 6, NbrOfSegments), 1, MaxStrLen(SubSegment_6));
                    SubSegment_7 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 7, NbrOfSegments), 1, MaxStrLen(SubSegment_7));
                    SubSegment_8 := CopyStr(SLPopulateAccountHistory.GetSubAcctSegmentText(SLAcctHist.Sub, 8, NbrOfSegments), 1, MaxStrLen(SubSegment_8));

                    DimSetID := CreateDimSet(SubSegment_1, SubSegment_2, SubSegment_3, SubSegment_4, SubSegment_5, SubSegment_6, SubSegment_7, SubSegment_8);
                    GenJournalLine.Validate("Dimension Set ID", DimSetID);
                    GenJournalLine.Modify(true);
                end;
            until SLAcctHist.Next() = 0;
    end;

    internal procedure CreateBeginningBalanceGenJournalBatchIfNeeded(GeneralJournalBatchCode: Code[10]; InitialYear: Integer)
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        TemplateName: Code[10];
    begin
        TemplateName := CreateBeginningBalanceGenJournalTemplateIfNeeded(GeneralJournalBatchCode, InitialYear);
        GenJournalBatch.SetRange("Journal Template Name", TemplateName);
        GenJournalBatch.SetRange(Name, GeneralJournalBatchCode);
        if not GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Init();
            GenJournalBatch.Validate("Journal Template Name", TemplateName);
            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Validate(Name, GeneralJournalBatchCode);
            GenJournalBatch.Validate(Description, BeginningBalanceDescriptionTxt + Format(InitialYear));
            GenJournalBatch.Insert(true);
        end;
    end;

    internal procedure CreateBeginningBalanceGenJournalTemplateIfNeeded(GenJournalBatchCode: Code[10]; InitialYear: Integer): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            Clear(GenJournalTemplate);
            GenJournalTemplate.Validate(Name, GenJournalBatchCode);
            GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::General);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Validate(Description, BeginningBalanceDescriptionTxt + Format(InitialYear));
            GenJournalTemplate.Insert(true);
        end;
        exit(GenJournalTemplate.Name);
    end;

    internal procedure GenerateGLTransactionBatches(SLAccountStaging: Record "SL Account Staging");
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        SLAccountTransactions: Record "SL AccountTransactions";
        SLFiscalPeriods: Record "SL Fiscal Periods";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DimSetID: Integer;
        DescriptionTrxTxt: Label 'SL migrated account balance for period ', Locked = true;
        BatchDescription: Text[50];
        BatchDocumentNo: Code[20];
        PostingGroupCode: Text;
        PostingGroupPeriod: Text;
    begin
        SLAccountTransactions.SetCurrentKey(Year, PERIODID, AcctNum);
        SLAccountTransactions.SetFilter(AcctNum, '= %1', SLAccountStaging.AcctNum);
        if SLAccountTransactions.FindSet() then
            repeat
                PostingGroupPeriod := Format(SLAccountTransactions.PERIODID);
                if SLAccountTransactions.PERIODID < 10 then
                    PostingGroupPeriod := '0' + PostingGroupPeriod;
                PostingGroupCode := PostingGroupCodeTxt + Format(SLAccountTransactions.Year) + '-' + PostingGroupPeriod;

                if SLAccountTransactions.Balance = 0 then
                    exit;
                if SLAccountStaging.AccountCategory = 2 then  // Liability
                    SLAccountTransactions.Balance := (-1 * SLAccountTransactions.Balance);
                if SLAccountStaging.AccountCategory = 4 then  // Income
                    SLAccountTransactions.Balance := (-1 * SLAccountTransactions.Balance);

                CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, MaxStrLen(GenJournalBatch.Name)));
                BatchDocumentNo := PostingGroupCodeTxt + GLModuleIDLbl + SLAccountTransactions.Year + PostingGroupPeriod;
                BatchDescription := DescriptionTrxTxt + SLAccountTransactions.Year + '-' + PostingGroupPeriod;

                if SLFiscalPeriods.Get(SLAccountTransactions.PERIODID, SLAccountTransactions.Year) then
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                    GenJournalLine,
                    CopyStr(PostingGroupCode, 1, MaxStrLen(GenJournalLine."Journal Batch Name")),
                    CopyStr(BatchDocumentNo, 1, MaxStrLen(BatchDocumentNo)),
                    CopyStr(BatchDescription, 1, MaxStrLen(BatchDescription)),
                    GenJournalLine."Account Type"::"G/L Account",
                    CopyStr(SLAccountStaging.AcctNum, 1, MaxStrLen(SLAccountStaging.AcctNum)),
                    SLFiscalPeriods.PerEndDT,
                    0D,
                    SLAccountTransactions.Balance,
                    SLAccountTransactions.Balance,
                    '',
                    '');
                DimSetID := CreateDimSet(SLAccountTransactions);
                GenJournalLine.Validate("Dimension Set ID", DimSetID);
                GenJournalLine.Modify(true);
            until SLAccountTransactions.Next() = 0;
    end;

    internal procedure CreateGeneralJournalBatchIfNeeded(GeneralJournalBatchCode: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        TemplateName: Code[10];
        GeneralLbl: Label 'GENERAL', Locked = true;
    begin
        TemplateName := CreateGeneralJournalTemplateIfNeeded(GeneralLbl);
        GenJournalBatch.SetRange("Journal Template Name", TemplateName);
        GenJournalBatch.SetRange(Name, GeneralJournalBatchCode);
        if not GenJournalBatch.FindFirst() then begin
            GenJournalBatch.Validate("Journal Template Name", TemplateName);
            GenJournalBatch.SetupNewBatch();
            GenJournalBatch.Validate(Name, GeneralJournalBatchCode);
            GenJournalBatch.Validate(Description, GeneralJournalBatchCode);
            GenJournalBatch.Insert(true);
        end;
    end;

    internal procedure CreateGeneralJournalTemplateIfNeeded(GeneralJournalTemplateCode: Code[10]): Code[10]
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Name, GeneralJournalTemplateCode);
        GenJournalTemplate.SetRange(Recurring, false);
        if not GenJournalTemplate.FindFirst() then begin
            GenJournalTemplate.Validate(Name, GeneralJournalTemplateCode);
            GenJournalTemplate.Validate(Type, GenJournalTemplate.Type::General);
            GenJournalTemplate.Validate(Recurring, false);
            GenJournalTemplate.Insert(true);
        end;
        exit(GenJournalTemplate.Name);
    end;

    internal procedure CreateDimSet(MigrationSlAccountTrans: Record "SL AccountTransactions"): Integer
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
        SLSegments: Record "SL Segments";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DimensionManagement: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        SLSegments.SetCurrentKey(SLSegments.SegmentNumber);
        SLSegments.Ascending(true);
        if SLSegments.FindSet() then
            repeat
                DimensionValue.Get(SLHelperFunctions.CheckDimensionName(SLSegments.Id), GetSegmentValue(MigrationSlAccountTrans, SLSegments.SegmentNumber));
                TempDimensionSetEntry.Init();
                TempDimensionSetEntry.Validate("Dimension Code", DimensionValue."Dimension Code");
                TempDimensionSetEntry.Validate("Dimension Value Code", DimensionValue.Code);
                TempDimensionSetEntry.Validate("Dimension Value ID", DimensionValue."Dimension Value ID");
                TempDimensionSetEntry.Insert(true);
            until SLSegments.Next() = 0;

        NewDimSetID := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        TempDimensionSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    internal procedure CreateDimSet(SubSegment_1: Code[20]; SubSegment_2: Code[20]; SubSegment_3: Code[20]; SubSegment_4: Code[20]; SubSegment_5: Code[20]; SubSegment_6: Code[20]; SubSegment_7: Code[20]; SubSegment_8: Code[20]): Integer
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
        SLSegments: Record "SL Segments";
        SLHelperFunctions: Codeunit "SL Helper Functions";
        DimensionManagement: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        if SLSegments.FindSet() then
            repeat
                if DimensionValue.Get(SLHelperFunctions.CheckDimensionName(SLSegments.Id), GetSegmentValue(SubSegment_1, SubSegment_2, SubSegment_3, SubSegment_4, SubSegment_5, SubSegment_6, SubSegment_7, SubSegment_8, SLSegments.SegmentNumber)) then begin
                    TempDimensionSetEntry.Init();
                    TempDimensionSetEntry.Validate("Dimension Code", DimensionValue."Dimension Code");
                    TempDimensionSetEntry.Validate("Dimension Value Code", DimensionValue.Code);
                    TempDimensionSetEntry.Validate("Dimension Value ID", DimensionValue."Dimension Value ID");
                    TempDimensionSetEntry.Insert(true);
                end;
            until SLSegments.Next() = 0;

        NewDimSetID := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        TempDimensionSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    internal procedure GetSegmentValue(MigrationSlAccountTrans: Record "SL AccountTransactions"; SegmentNumber: Integer): Code[20]
    var
        SLSegments: Record "SL Segments";
    begin
        case SegmentNumber of
            1:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_1, 1, MaxStrLen(SLSegments.Id)));
            2:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_2, 1, MaxStrLen(SLSegments.Id)));
            3:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_3, 1, MaxStrLen(SLSegments.Id)));
            4:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_4, 1, MaxStrLen(SLSegments.Id)));
            5:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_5, 1, MaxStrLen(SLSegments.Id)));
            6:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_6, 1, MaxStrLen(SLSegments.Id)));
            7:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_7, 1, MaxStrLen(SLSegments.Id)));
            8:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_8, 1, MaxStrLen(SLSegments.Id)));
        end;
    end;

    internal procedure GetSegmentValue(SubSegment_1: Code[20]; SubSegment_2: Code[20]; SubSegment_3: Code[20]; SubSegment_4: Code[20]; SubSegment_5: Code[20]; SubSegment_6: Code[20]; SubSegment_7: Code[20]; SubSegment_8: Code[20]; SegmentNumber: Integer): Code[20]
    begin
        case SegmentNumber of
            1:
                exit(SubSegment_1);
            2:
                exit(SubSegment_2);
            3:
                exit(SubSegment_3);
            4:
                exit(SubSegment_4);
            5:
                exit(SubSegment_5);
            6:
                exit(SubSegment_6);
            7:
                exit(SubSegment_7);
            8:
                exit(SubSegment_8);
        end;
    end;

    internal procedure AreAllSegmentNumbersEmpty(SubSegment_1: Code[20]; SubSegment_2: Code[20]; SubSegment_3: Code[20]; SubSegment_4: Code[20]; SubSegment_5: Code[20]; SubSegment_6: Code[20]; SubSegment_7: Code[20]; SubSegment_8: Code[20]): Boolean
    begin
        exit(
            CodeIsEmpty(SubSegment_1) and
            CodeIsEmpty(SubSegment_2) and
            CodeIsEmpty(SubSegment_3) and
            CodeIsEmpty(SubSegment_4) and
            CodeIsEmpty(SubSegment_5) and
            CodeIsEmpty(SubSegment_6) and
            CodeIsEmpty(SubSegment_7) and
            CodeIsEmpty(SubSegment_8)
        );
    end;

    internal procedure CodeIsEmpty(TheCode: Code[20]): Boolean
    var
        CodeText: Text[20];
    begin
        CodeText := TheCode;
        CodeText := CopyStr(CodeText.Trim(), 1, MaxStrLen(CodeText));
        exit(CodeText = '');
    end;
}