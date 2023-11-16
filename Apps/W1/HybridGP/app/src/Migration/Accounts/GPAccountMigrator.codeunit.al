namespace Microsoft.DataMigration.GP;

using System.Integration;
using Microsoft.Finance.GeneralLedger.Journal;
using Microsoft.Finance.Dimension;
using Microsoft.Finance.GeneralLedger.Account;

codeunit 4017 "GP Account Migrator"
{
    TableNo = "GP Account";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        BeginningBalanceTrxTxt: Label 'Beginning Balance', Locked = true;

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    procedure OnMigrateGlAccount(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    local procedure OnMigrateGlAccount(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#endif
    var
        GPAccount: Record "GP Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        AccountNum: Code[20];
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        GPAccount.Get(RecordIdToMigrate);

        AccountNum := CopyStr(GPAccount.AcctNum.Trim(), 1, 20);
        if AccountNum = '' then
            exit;

        MigrateAccountDetails(GPAccount, Sender);
    end;

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateAccountTransactions', '', true, true)]
    procedure OnMigrateAccountTransactions(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateAccountTransactions', '', true, true)]
    local procedure OnMigrateAccountTransactions(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#endif
    var
        GPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if not GPCompanyAdditionalSettings.GetGLModuleEnabled() then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;

        GPAccount.Get(RecordIdToMigrate);

        if not GLAccount.Get(GPAccount.AcctNum) then
            exit;

        GenerateGLTransactionBatches(GPAccount);
    end;

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    procedure OnMigratePostingGroups(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    local procedure OnMigratePostingGroups(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#endif
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

#if not CLEAN22
#pragma warning disable AA0207
    [Obsolete('The procedure will be made local.', '22.0')]
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnCreateOpeningBalanceTrx', '', true, true)]
    procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#pragma warning restore AA0207
#else
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnCreateOpeningBalanceTrx', '', true, true)]
    local procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
#endif
    var
        GPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
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

        if not GLAccount.Get(GPAccount.AcctNum) then
            exit;

        CreateBeginningBalance(GPAccount);
    end;

    procedure CreateBeginningBalance(GPAccount: Record "GP Account")
    var
        GPGL10111: Record "GP GL10111";
        GenJournalLine: Record "Gen. Journal Line";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
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

        PostingGroupCode := PostingGroupCodeTxt + format(InitialYear) + 'BB';
        if GPFiscalPeriods.Get(0, InitialYear) then begin
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

            if AreAllSegmentNumbersEmpty(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8) then
                GetSegmentNumbersFromGPAccountIndex(GPGL10111.ACTINDX, ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);

            DimSetID := CreateDimSet(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8);
            GenJournalLine.Validate("Dimension Set ID", DimSetID);
            GenJournalLine.Modify(true);
        end;
    end;

    procedure MigrateAccountDetails(GPAccount: Record "GP Account"; var GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
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

    procedure GenerateGLTransactionBatches(GPAccount: Record "GP Account");
    var
        GPGLTransactions: Record "GP GLTransactions";
        GenJournalLine: Record "Gen. Journal Line";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        PostingGroupCode: Code[10];
        DimSetID: Integer;
        InitialYear: Integer;
    begin
        InitialYear := GPCompanyAdditionalSettings.GetInitialYear();

        GPGLTransactions.Reset();
        GPGLTransactions.SetCurrentKey(YEAR1, PERIODID, ACTINDX);
        GPGLTransactions.SetFilter(ACTINDX, '= %1', GPAccount.AcctIndex);

        if InitialYear > 0 then
            GPGLTransactions.SetFilter(YEAR1, '>= %1', InitialYear);

        if GPGLTransactions.FindSet() then
            repeat
                PostingGroupCode := PostingGroupCodeTxt + format(GPGLTransactions.YEAR1) + '-' + format(GPGLTransactions.PERIODID);

                if GPFiscalPeriods.Get(GPGLTransactions.PERIODID, GPGLTransactions.YEAR1) then begin
                    DataMigrationFacadeHelper.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, 10), '', '');
                    DataMigrationFacadeHelper.CreateGeneralJournalLine(
                        GenJournalLine,
                        PostingGroupCode,
                        PostingGroupCode,
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
                    DimSetID := CreateDimSet(GPGLTransactions.ACTNUMBR_1, GPGLTransactions.ACTNUMBR_2, GPGLTransactions.ACTNUMBR_3, GPGLTransactions.ACTNUMBR_4, GPGLTransactions.ACTNUMBR_5, GPGLTransactions.ACTNUMBR_6, GPGLTransactions.ACTNUMBR_7, GPGLTransactions.ACTNUMBR_8);
                    GenJournalLine.Validate("Dimension Set ID", DimSetID);
                    GenJournalLine.Modify(true);
                end;
            until GPGLTransactions.Next() = 0;
    end;

    local procedure CreateDimSet(ACTNUMBR_1: Code[20]; ACTNUMBR_2: Code[20]; ACTNUMBR_3: Code[20]; ACTNUMBR_4: Code[20]; ACTNUMBR_5: Code[20]; ACTNUMBR_6: Code[20]; ACTNUMBR_7: Code[20]; ACTNUMBR_8: Code[20]): Integer
    var
        TempDimensionSetEntry: Record "Dimension Set Entry" temporary;
        DimensionValue: Record "Dimension Value";
        GPSegments: Record "GP Segments";
        HelperFunctions: Codeunit "Helper Functions";
        DimensionManagement: Codeunit DimensionManagement;
        NewDimSetID: Integer;
    begin
        if GPSegments.FindSet() then
            repeat
                if DimensionValue.Get(HelperFunctions.CheckDimensionName(GPSegments.Id), GetSegmentValue(ACTNUMBR_1, ACTNUMBR_2, ACTNUMBR_3, ACTNUMBR_4, ACTNUMBR_5, ACTNUMBR_6, ACTNUMBR_7, ACTNUMBR_8, GPSegments.SegmentNumber)) then begin
                    TempDimensionSetEntry.Init();
                    TempDimensionSetEntry.Validate("Dimension Code", DimensionValue."Dimension Code");
                    TempDimensionSetEntry.Validate("Dimension Value Code", DimensionValue.Code);
                    TempDimensionSetEntry.Validate("Dimension Value ID", DimensionValue."Dimension Value ID");
                    TempDimensionSetEntry.Insert(true);
                end;
            until GPSegments.Next() = 0;

        NewDimSetID := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        TempDimensionSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    local procedure GetSegmentValue(ACTNUMBR_1: Code[20]; ACTNUMBR_2: Code[20]; ACTNUMBR_3: Code[20]; ACTNUMBR_4: Code[20]; ACTNUMBR_5: Code[20]; ACTNUMBR_6: Code[20]; ACTNUMBR_7: Code[20]; ACTNUMBR_8: Code[20]; SegmentNumber: Integer): Code[20]
    begin
        case SegmentNumber of
            1:
                exit(ACTNUMBR_1);
            2:
                exit(ACTNUMBR_2);
            3:
                exit(ACTNUMBR_3);
            4:
                exit(ACTNUMBR_4);
            5:
                exit(ACTNUMBR_5);
            6:
                exit(ACTNUMBR_6);
            7:
                exit(ACTNUMBR_7);
            8:
                exit(ACTNUMBR_8);
        end;
    end;

    local procedure GetSegmentNumbersFromGPAccountIndex(GPAccountIndex: Integer; var ACTNUMBR_1: Code[20]; var ACTNUMBR_2: Code[20]; var ACTNUMBR_3: Code[20]; var ACTNUMBR_4: Code[20]; var ACTNUMBR_5: Code[20]; var ACTNUMBR_6: Code[20]; var ACTNUMBR_7: Code[20]; var ACTNUMBR_8: Code[20]): Code[20]
    var
        GPGL00100: Record "GP GL00100";
    begin
        if GPGL00100.Get(GPAccountIndex) then begin
            ACTNUMBR_1 := GPGL00100.ACTNUMBR_1;
            ACTNUMBR_2 := GPGL00100.ACTNUMBR_2;
            ACTNUMBR_3 := GPGL00100.ACTNUMBR_3;
            ACTNUMBR_4 := GPGL00100.ACTNUMBR_4;
            ACTNUMBR_5 := GPGL00100.ACTNUMBR_5;
            ACTNUMBR_6 := GPGL00100.ACTNUMBR_6;
            ACTNUMBR_7 := GPGL00100.ACTNUMBR_7;
            ACTNUMBR_8 := GPGL00100.ACTNUMBR_8;
        end;
    end;

    local procedure AreAllSegmentNumbersEmpty(ACTNUMBR_1: Code[20]; ACTNUMBR_2: Code[20]; ACTNUMBR_3: Code[20]; ACTNUMBR_4: Code[20]; ACTNUMBR_5: Code[20]; ACTNUMBR_6: Code[20]; ACTNUMBR_7: Code[20]; ACTNUMBR_8: Code[20]): Boolean
    begin
        exit(
                CodeIsEmpty(ACTNUMBR_1) and
                CodeIsEmpty(ACTNUMBR_2) and
                CodeIsEmpty(ACTNUMBR_3) and
                CodeIsEmpty(ACTNUMBR_4) and
                CodeIsEmpty(ACTNUMBR_5) and
                CodeIsEmpty(ACTNUMBR_6) and
                CodeIsEmpty(ACTNUMBR_7) and
                CodeIsEmpty(ACTNUMBR_8)
            );
    end;

    local procedure CodeIsEmpty(TheCode: Code[20]): Boolean
    var
        CodeText: Text[20];
    begin
        CodeText := TheCode;
        CodeText := CopyStr(CodeText.Trim(), 1, MaxStrLen(CodeText));
        exit(CodeText = '');
    end;
}