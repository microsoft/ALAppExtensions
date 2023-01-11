codeunit 4017 "GP Account Migrator"
{
    TableNo = "GP Account";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        BeginningBalanceTrxTxt: Label 'Beginning Balance', Locked = true;

#pragma warning disable AA0207
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    procedure OnMigrateGlAccount(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        GPAccount.Get(RecordIdToMigrate);
        MigrateAccountDetails(GPAccount, Sender);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateAccountTransactions', '', true, true)]
    procedure OnMigrateAccountTransactions(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        if GPCompanyAdditionalSettings.GetMigrateOnlyGLMaster() then
            exit;

        GPAccount.Get(RecordIdToMigrate);
        GenerateGLTransactionBatches(GPAccount);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    procedure OnMigratePostingGroups(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        GPAccount.Get(RecordIdToMigrate);
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
    procedure OnCreateOpeningBalanceTrx(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        GPAccount: Record "GP Account";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"GP Account" then
            exit;

        GPAccount.Get(RecordIdToMigrate);
        if GPAccount.IncomeBalance then
            exit;

        CreateBeginningBalance(GPAccount);
    end;
#pragma warning restore AA0207

    local procedure CreateBeginningBalance(GPAccount: Record "GP Account")
    var
        GPGL10111: Record "GP GL10111";
        GenJournalLine: Record "Gen. Journal Line";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        DataMigrationFacadeHelper: Codeunit "Data Migration Facade Helper";
        BeginningBalance: Decimal;
        PostingGroupCode: Code[10];
        InitialYear: Integer;
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
        GPFiscalPeriods.SetRange(YEAR1, InitialYear);
        if GPFiscalPeriods.FindFirst() then begin
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
        end;
    end;

    local procedure MigrateAccountDetails(GPAccount: Record "GP Account"; GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        HelperFunctions: Codeunit "Helper Functions";
        AccountType: Option Posting;
        AccountNum: Code[20];
    begin
        AccountNum := CopyStr(GPAccount.AcctNum, 1, 20);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(AccountNum, CopyStr(GPAccount.Name, 1, 50), AccountType::Posting) then
            exit;

        GLAccDataMigrationFacade.SetDirectPosting(GPAccount.DirectPosting);
        GLAccDataMigrationFacade.SetAccountCategory(HelperFunctions.ConvertAccountCategory(GPAccount));
        GLAccDataMigrationFacade.SetDebitCreditType(HelperFunctions.ConvertDebitCreditType(GPAccount));
        GLAccDataMigrationFacade.SetAccountSubCategory(HelperFunctions.AssignSubAccountCategory(GPAccount));
        GLAccDataMigrationFacade.SetIncomeBalanceType(HelperFunctions.ConvertIncomeBalanceType(GPAccount));
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    local procedure GenerateGLTransactionBatches(GPAccount: Record "GP Account");
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
                    DimSetID := CreateDimSet(GPGLTransactions);
                    GenJournalLine.Validate("Dimension Set ID", DimSetID);
                    GenJournalLine.Modify(true);
                end;
            until GPGLTransactions.Next() = 0;
    end;

    local procedure CreateDimSet(GPGLTransactions: Record "GP GLTransactions"): Integer
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
                DimensionValue.Get(HelperFunctions.CheckDimensionName(GPSegments.Id), GetSegmentValue(GPGLTransactions, GPSegments.SegmentNumber));      //'0000'); GPGLTransactions ACTNUMBR_1 - 9
                TempDimensionSetEntry.Init();
                TempDimensionSetEntry.Validate("Dimension Code", DimensionValue."Dimension Code");
                TempDimensionSetEntry.Validate("Dimension Value Code", DimensionValue.Code);
                TempDimensionSetEntry.Validate("Dimension Value ID", DimensionValue."Dimension Value ID");
                TempDimensionSetEntry.Insert(true);
            until GPSegments.Next() = 0;

        NewDimSetID := DimensionManagement.GetDimensionSetID(TempDimensionSetEntry);
        TempDimensionSetEntry.DeleteAll();
        exit(NewDimSetID);
    end;

    local procedure GetSegmentValue(GPGLTransactions: Record "GP GLTransactions"; SegmentNumber: Integer): Code[20]
    begin
        case SegmentNumber of
            1:
                exit(GPGLTransactions.ACTNUMBR_1);
            2:
                exit(GPGLTransactions.ACTNUMBR_2);
            3:
                exit(GPGLTransactions.ACTNUMBR_3);
            4:
                exit(GPGLTransactions.ACTNUMBR_4);
            5:
                exit(GPGLTransactions.ACTNUMBR_5);
            6:
                exit(GPGLTransactions.ACTNUMBR_6);
            7:
                exit(GPGLTransactions.ACTNUMBR_7);
            8:
                exit(GPGLTransactions.ACTNUMBR_8);
        end;
    end;
}