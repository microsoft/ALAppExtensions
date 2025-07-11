// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.SL;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;

codeunit 47000 "SL Account Migrator"
{
    Access = Internal;

    var
        PostingGroupCodeTxt: Label 'SL', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from SL', Locked = true;
        GlDocNoLbl: Label 'G000000001', Locked = true;

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
    var
        SLAccountStaging: Record "SL Account Staging";
        SLHelperFunctions: Codeunit "SL Helper Functions";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        SLAccountStaging.Get(RecordIdToMigrate);
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

    internal procedure GenerateGLTransactionBatches(SLAccountStaging: Record "SL Account Staging");
    var
        GenJournalLine: Record "Gen. Journal Line";
        SLAccountTransactions: Record "SL AccountTransactions";
        SLFiscalPeriods: Record "SL Fiscal Periods";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DimSetID: Integer;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        PostingGroupCode: Text;
    begin
        SLAccountTransactions.SetCurrentKey(Year, PERIODID, AcctNum);
        SLAccountTransactions.SetFilter(AcctNum, '= %1', SLAccountStaging.AcctNum);
        if SLAccountTransactions.FindSet() then
            repeat
                PostingGroupCode := 'SL' + Format(SLAccountTransactions.Year) + '-' + Format(SLAccountTransactions.PERIODID);

                if SLAccountTransactions.Balance = 0 then
                    exit;
                if SLAccountStaging.AccountCategory = 2 then  // Liability
                    SLAccountTransactions.Balance := (-1 * SLAccountTransactions.Balance);
                if SLAccountStaging.AccountCategory = 4 then  // Income
                    SLAccountTransactions.Balance := (-1 * SLAccountTransactions.Balance);

                CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, 10));

                if SLFiscalPeriods.Get(SLAccountTransactions.PERIODID, SLAccountTransactions.Year) then
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                    GenJournalLine,
                    CopyStr(PostingGroupCode, 1, 10),
                    CopyStr(GlDocNoLbl, 1, MaxStrLen(GlDocNoLbl)),
                    CopyStr(DescriptionTrxTxt, 1, MaxStrLen(DescriptionTrxTxt)),
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
    begin
        TemplateName := CreateGeneralJournalTemplateIfNeeded('GENERAL');
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

    internal procedure GetSegmentValue(MigrationSlAccountTrans: Record "SL AccountTransactions"; SegmentNumber: Integer): Code[20]
    begin
        case SegmentNumber of
            1:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_1, 1, 20));
            2:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_2, 1, 20));
            3:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_3, 1, 20));
            4:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_4, 1, 20));
            5:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_5, 1, 20));
            6:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_6, 1, 20));
            7:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_7, 1, 20));
            8:
                exit(CopyStr(MigrationSlAccountTrans.SubSegment_8, 1, 20));
        end;
    end;
}