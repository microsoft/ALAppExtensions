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
        HelperFunctions: Codeunit "SL Helper Functions";
        DataMigrationErrorLogging: Codeunit "Data Migration Error Logging";
        AccountNum: Code[20];
        AccountType: Option Posting;
    begin
        AccountNum := CopyStr(SLAccountStaging.AcctNum, 1, 20);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(AccountNum, CopyStr(SLAccountStaging.Name, 1, 50), AccountType::Posting) then
            exit;
        DataMigrationErrorLogging.SetLastRecordUnderProcessing(Format(SLAccountStaging.RecordId));
        GLAccDataMigrationFacade.SetAccountCategory(HelperFunctions.ConvertAccountCategory(SLAccountStaging));
        GLAccDataMigrationFacade.SetDebitCreditType(HelperFunctions.ConvertDebitCreditType(SLAccountStaging));
        GLAccDataMigrationFacade.SetIncomeBalanceType(HelperFunctions.ConvertIncomeBalanceType(SLAccountStaging));
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
        HelperFunctions: Codeunit "SL Helper Functions";
    begin
        if RecordIdToMigrate.TableNo <> Database::"SL Account Staging" then
            exit;
        SLAccountStaging.Get(RecordIdToMigrate);
        Sender.CreateGenBusinessPostingGroupIfNeeded(PostingGroupCodeTxt, PostingGroupDescriptionTxt);
        Sender.CreateGenProductPostingGroupIfNeeded(PostingGroupCodeTxt, PostingGroupDescriptionTxt);
        Sender.CreateGeneralPostingSetupIfNeeded(PostingGroupCodeTxt);

        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesAccount') then
            Sender.SetGeneralPostingSetupSalesAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('SalesAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
            Sender.SetGeneralPostingSetupSalesLineDiscAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
            Sender.SetGeneralPostingSetupSalesInvDiscAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount') then
            Sender.SetGeneralPostingSetupSalesPmtDiscDebitAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchAccount') then
            Sender.SetGeneralPostingSetupPurchAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('PurchAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount') then
            Sender.SetGeneralPostingSetupPurchInvDiscAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('COGSAccount') then
            Sender.SetGeneralPostingSetupCOGSAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('COGSAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
            Sender.SetGeneralPostingSetupInventoryAdjmtAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
            Sender.SetGeneralPostingSetupSalesCreditMemoAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc') then
            Sender.SetGeneralPostingSetupPurchPmtDiscDebitAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount') then
            Sender.SetGeneralPostingSetupPurchPrepaymentsAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount'));
        if SLAccountStaging.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount') then
            Sender.SetGeneralPostingSetupPurchaseVarianceAccount(PostingGroupCodeTxt, HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount'));
        Sender.ModifyGLAccount(true);
    end;

    internal procedure GenerateGLTransactionBatches(SLAccountStaging: Record "SL Account Staging");
    var
        MigrationSlAccountTrans: Record "SL AccountTransactions";
        GenJournalLine: Record "Gen. Journal Line";
        MigrationSLFiscalPeriods: Record "SL Fiscal Periods";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        DimSetID: Integer;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        PostingGroupCode: Text;
    begin
        MigrationSlAccountTrans.SetCurrentKey(Year, PERIODID, AcctNum);
        MigrationSlAccountTrans.SetFilter(AcctNum, '= %1', SLAccountStaging.AcctNum);
        if MigrationSlAccountTrans.FindSet() then
            repeat
                PostingGroupCode := 'SL' + Format(MigrationSlAccountTrans.Year) + '-' + Format(MigrationSlAccountTrans.PERIODID);

                if MigrationSlAccountTrans.Balance = 0 then
                    exit;
                if MigrationSlAccountTrans.CreditAmount > 0 then
                    MigrationSlAccountTrans.Balance := (-1 * MigrationSlAccountTrans.Balance);

                CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, 10));

                if MigrationSLFiscalPeriods.Get(MigrationSlAccountTrans.PERIODID, MigrationSlAccountTrans.Year) then
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                    GenJournalLine,
                    CopyStr(PostingGroupCode, 1, 10),
                    CopyStr(GlDocNoLbl, 1, 20),
                    CopyStr(DescriptionTrxTxt, 1, 50),
                    GenJournalLine."Account Type"::"G/L Account",
                    CopyStr(SLAccountStaging.AcctNum, 1, 20),
                    MigrationSLFiscalPeriods.PerEndDT,
                    0D,
                    MigrationSlAccountTrans.Balance,
                    MigrationSlAccountTrans.Balance,
                    '',
                    '');
                DimSetID := CreateDimSet(MigrationSlAccountTrans);
                GenJournalLine.Validate("Dimension Set ID", DimSetID);
                GenJournalLine.Modify(true);
            until MigrationSlAccountTrans.Next() = 0;
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