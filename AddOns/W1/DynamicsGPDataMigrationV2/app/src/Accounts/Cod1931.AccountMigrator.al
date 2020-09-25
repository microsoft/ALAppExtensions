codeunit 1931 "MigrationGP Account Migrator"
{
    TableNo = "MigrationGP Account";

    var
        PostingGroupCodeTxt: Label 'GP', Locked = true;
        PostingGroupDescriptionTxt: Label 'Migrated from GP', Locked = true;
        DescriptionTxt: Label 'Opening Balance', Locked = true;
        DescriptionTrxTxt: Label 'Migrated transaction', Locked = true;
        GlDocNoTxt: Label 'G00001', Locked = true;
        PackageCodeTxt: Label 'GP.MIGRATION.EXCEL', Locked = true;
        TooManyAccountsMsg: Label 'The Excel workbook contains more accounts than you imported.', Locked = false;
        TooFewAccountsMsg: Label 'The Excel workbook contains fewer accounts than you imported.', Locked = false;
        DuplicateAccountMsg: Label '%1 is used for more than one account. Each account must have a unique number.', Comment = '%1 = Account number', Locked = false;
        DuplicateIndexMsg: Label 'Account index %1 is used for more than one account. Each account must have a unique index.', Comment = '%1 = Account index', Locked = false;
        EmptyAccountMsg: Label 'All accounts must have an account number.', Locked = false;
        AccountTooLongMsg: Label 'The account number is too long. Account numbers can have up to 20 characters.', Locked = false;
        DifferentAccountIndexMsg: Label 'The account index cannot be mapped for account index %1.', Comment = '%1 = Account index', Locked = false;
        AccountDescriptionTooLongMsg: Label 'Description for account number %1 is too long, it can only be 50 characters long.', Comment = '%1 = Account number', Locked = false;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateGlAccount', '', true, true)]
    procedure OnMigrateGlAccount(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPAccount: Record "MigrationGP Account";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Account" then
            exit;
        MigrationGPAccount.Get(RecordIdToMigrate);
        MigrateAccountDetails(MigrationGPAccount, Sender);
    end;

    procedure MigrateAccountDetails(MigrationGPAccount: Record "MigrationGP Account"; GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade")
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        AccountType: Option Posting;
        AccountNum: Code[20];
    begin
        if HelperFunctions.IsUsingNewAccountFormat() then
            AccountNum := MigrationGPAccount.AcctNumNew
        else
            AccountNum := CopyStr(MigrationGPAccount.AcctNum, 1, 20);

        if not GLAccDataMigrationFacade.CreateGLAccountIfNeeded(AccountNum, CopyStr(MigrationGPAccount.Name, 1, 50), AccountType::Posting) then
            exit;

        GLAccDataMigrationFacade.SetDirectPosting(MigrationGPAccount.DirectPosting);
        // GLAccDataMigrationFacade.SetBlocked(not MigrationGPAccount.Active);
        GLAccDataMigrationFacade.SetAccountCategory(HelperFunctions.ConvertAccountCategory(MigrationGPAccount));
        GLAccDataMigrationFacade.SetDebitCreditType(HelperFunctions.ConvertDebitCreditType(MigrationGPAccount));
        GLAccDataMigrationFacade.SetAccountSubCategory(HelperFunctions.AssignSubAccountCategory(MigrationGPAccount));
        GLAccDataMigrationFacade.SetIncomeBalanceType(HelperFunctions.ConvertIncomeBalanceType(MigrationGPAccount));
        GLAccDataMigrationFacade.ModifyGLAccount(true);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnCreateOpeningBalanceTrx', '', true, true)]
    procedure OnCreateOpeningBalanceTrx(var Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPAccount: Record "MigrationGP Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        // Do not run this code for the new accounts, we'll want to do something with a new integration point.  See the next method.
        if HelperFunctions.IsUsingNewAccountFormat() then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Account" then
            exit;

        MigrationGPAccount.Get(RecordIdToMigrate);
        if MigrationGPAccount.Balance = 0 then
            exit;

        Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 10), '', '');
        Sender.CreateGeneralJournalLine(
            CopyStr(PostingGroupCodeTxt, 1, 10),
            CopyStr(GlDocNoTxt, 1, 20),
            CopyStr(DescriptionTxt, 1, 50),
            Today(),
            0D,
            MigrationGPAccount.Balance,
            MigrationGPAccount.Balance,
            '',
            ''
        );
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigrateAccountTransactions', '', true, true)]
    procedure OnMigrateAccountTransactions(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPConfig: Record "MigrationGP Config";
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if not HelperFunctions.IsUsingNewAccountFormat() then
            exit;

        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Account" then
            exit;

        // Once the number of accounts matches the number expected to be migrated, then post the GL transactions...		
        MigrationGPConfig.GetSingleInstance();
        MigrationGPAccount.Reset();
        MigrationGPAccount.SetRange(AccountType, 1);
        if GLAccount.Count() = MigrationGPConfig."Total Accounts" then
            GenerateGLTransactionBatches();
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"GL Acc. Data Migration Facade", 'OnMigratePostingGroups', '', true, true)]
    procedure OnMigratePostingGroups(VAR Sender: Codeunit "GL Acc. Data Migration Facade"; RecordIdToMigrate: RecordId)
    var
        MigrationGPAccount: Record "MigrationGP Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        if RecordIdToMigrate.TableNo() <> Database::"MigrationGP Account" then
            exit;

        MigrationGPAccount.Get(RecordIdToMigrate);
        Sender.CreateGenBusinessPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50));
        Sender.CreateGenProductPostingGroupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 20), CopyStr(PostingGroupDescriptionTxt, 1, 50));
        Sender.CreateGeneralPostingSetupIfNeeded(CopyStr(PostingGroupCodeTxt, 1, 10));

        if not HelperFunctions.IsUsingNewAccountFormat() then begin
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesAccount') then
                Sender.SetGeneralPostingSetupSalesAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
                Sender.SetGeneralPostingSetupSalesLineDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
                Sender.SetGeneralPostingSetupSalesInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount') then
                Sender.SetGeneralPostingSetupSalesPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchAccount') then
                Sender.SetGeneralPostingSetupPurchAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount') then
                Sender.SetGeneralPostingSetupPurchInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('COGSAccount') then
                Sender.SetGeneralPostingSetupCOGSAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('COGSAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
                Sender.SetGeneralPostingSetupInventoryAdjmtAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
                Sender.SetGeneralPostingSetupSalesCreditMemoAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc') then
                Sender.SetGeneralPostingSetupPurchPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount') then
                Sender.SetGeneralPostingSetupPurchPrepaymentsAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount'));
            if MigrationGPAccount.AcctNum = HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount') then
                Sender.SetGeneralPostingSetupPurchaseVarianceAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount'));
        end else begin
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('SalesAccount') then
                Sender.SetGeneralPostingSetupSalesAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount') then
                Sender.SetGeneralPostingSetupSalesLineDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesLineDiscAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount') then
                Sender.SetGeneralPostingSetupSalesInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesInvDiscAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount') then
                Sender.SetGeneralPostingSetupSalesPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesPmtDiscDebitAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('PurchAccount') then
                Sender.SetGeneralPostingSetupPurchAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount') then
                Sender.SetGeneralPostingSetupPurchInvDiscAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchInvDiscAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('COGSAccount') then
                Sender.SetGeneralPostingSetupCOGSAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('COGSAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount') then
                Sender.SetGeneralPostingSetupInventoryAdjmtAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('InventoryAdjmtAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount') then
                Sender.SetGeneralPostingSetupSalesCreditMemoAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('SalesCreditMemoAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc') then
                Sender.SetGeneralPostingSetupPurchPmtDiscDebitAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPmtDiscDebitAcc'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount') then
                Sender.SetGeneralPostingSetupPurchPrepaymentsAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchPrepaymentsAccount'));
            if MigrationGPAccount.AcctNumNew = HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount') then
                Sender.SetGeneralPostingSetupPurchaseVarianceAccount(CopyStr(PostingGroupCodeTxt, 1, 20), HelperFunctions.GetPostingAccountNumber('PurchaseVarianceAccount'));
        end;
        Sender.ModifyGLAccount(true);
    end;

    procedure GetAll()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JArray: JsonArray;
        UsingNewAccountFormat: Boolean;
    begin
        UsingNewAccountFormat := HelperFunctions.IsUsingNewAccountFormat();

        if UsingNewAccountFormat then
            HelperFunctions.GetEntities('Account2', JArray)
        else
            HelperFunctions.GetEntities('Account', JArray);

        GetAccountsFromJson(JArray);
        GetFiscalPeriodInfo();
        GetPostingGroupInfo();
        if UsingNewAccountFormat then
            GetTransactions();
        if not UsingNewAccountFormat then
            HelperFunctions.GetDimensionInfo();
    end;

    procedure PopulateStagingTable(JArray: JsonArray)
    begin
        GetAccountsFromJson(JArray);
    end;

    procedure DeleteAll()
    var
        MigrationGPAccount: Record "MigrationGP Account";
    begin
        MigrationGPAccount.DeleteAll();
    end;

    procedure GetAccountsFromJson(JArray: JsonArray)
    var
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPConfig: Record "MigrationGP Config";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[75];
        i: Integer;
        AccountType: integer;
    begin
        i := 0;
        MigrationGPAccount.Reset();
        MigrationGPAccount.DeleteAll();

        while JArray.Get(i, ChildJToken) do begin
            evaluate(AccountType, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'ACCTTYPE')));
            if AccountType = 1 then begin // Only want to bring in Posting Accounts, no unit accounts allowed
                EntityId := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'ACTNUMST')), 1, MaxStrLen(MigrationGPAccount.AcctNum));

                if not MigrationGPAccount.Get(EntityId) then begin
                    MigrationGPAccount.Init();
                    MigrationGPAccount.Validate(MigrationGPAccount.AcctNum, EntityId);
                    MigrationGPAccount.Insert(true);
                end;

                RecordVariant := MigrationGPAccount;
                UpdateAccountFromJson(RecordVariant, ChildJToken);
                MigrationGPAccount := RecordVariant;
                MigrationGPAccount.Modify(false);
            end;
            i := i + 1;
        end;
        // When we are done, we want to update the config file for the actual number of accounts we will be working with
        MigrationGPConfig.GetSingleInstance();
        MigrationGPConfig."Total Accounts" := MigrationGPAccount.Count();
        MigrationGPConfig.Modify();
    end;

    local procedure UpdateAccountFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPAccount: Record "MigrationGP Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(Name), JToken.AsObject(), 'ACTDESCR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(AccountCategory), JToken.AsObject(), 'ACCATNUM');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(IncomeBalance), JToken.AsObject(), 'PSTNGTYP');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(DebitCredit), JToken.AsObject(), 'TPCLBLNC');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(Active), JToken.AsObject(), 'ACTIVE');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(DirectPosting), JToken.AsObject(), 'ACCTENTR');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(AccountSubcategoryEntryNo), JToken.AsObject(), 'ACCOUNTSUBCATEGORYENTRYNO');

        if HelperFunctions.IsUsingNewAccountFormat() then begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(AcctIndex), JToken.AsObject(), 'ACTINDX');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(AccountType), JToken.AsObject(), 'ACCTTYPE');
        end else begin
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNO(Balance), JToken.AsObject(), 'ACCTBALANCE');
            HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNO(SearchName), JToken.AsObject(), 'SEARCHNAME');
        end;
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPAccount.FieldNo(AccountType), JToken.AsObject(), 'ACCTTYPE');
    end;

    local procedure GetFiscalPeriodInfo()
    var
        MigrationGPFiscalPeriods: Record "MigrationGP Fiscal Periods";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        TypeHelper: Codeunit "Type Helper";
        MyVariant: Variant;
        JArray: JsonArray;
        ChildJToken: JsonToken;
        i: Integer;
        DateVar: Date;
        IntegerVarPeriodID: Integer;
        IntegerVarYear1: Integer;
        WorkingText: Text;
    begin
        if not HelperFunctions.IsUsingNewAccountFormat() then
            exit;
        HelperFunctions.GetEntities('FiscalPeriods', JArray);

        i := 0;
        while JArray.Get(i, ChildJToken) do begin
            MigrationGPFiscalPeriods.Init();
            evaluate(IntegerVarPeriodID, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'PERIODID')));
            MigrationGPFiscalPeriods.PERIODID := IntegerVarPeriodID;

            evaluate(IntegerVarYear1, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'YEAR1')));
            MigrationGPFiscalPeriods.YEAR1 := IntegerVarYear1;
            If not MigrationGPFiscalPeriods.Get(IntegerVarPeriodID, IntegerVarYear1) then
                MigrationGPFiscalPeriods.Insert();

            WorkingText := HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'PERIODDT'));
            MyVariant := DateVar;
            TypeHelper.Evaluate(MyVariant, WorkingText, 'yyyy-MM-dd', 'en-US');
            MigrationGPFiscalPeriods.PERIODDT := MyVariant;

            WorkingText := HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'PERDENDT'));
            MyVariant := DateVar;
            TypeHelper.Evaluate(MyVariant, WorkingText, 'yyyy-MM-dd', 'en-US');
            MigrationGPFiscalPeriods.PERDENDT := MyVariant;

            MigrationGPFiscalPeriods.Modify();
            i := i + 1;
        end;

    end;

    local procedure GetPostingGroupInfo()
    var
        MigrationGPAccountSetup: Record "MigrationGP Account Setup";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JToken: JsonToken;
        UsingNewAccounts: boolean;
    begin
        UsingNewAccounts := HelperFunctions.IsUsingNewAccountFormat();

        if UsingNewAccounts then
            HelperFunctions.GetEntitiesAsJToken('GenPostGroup2', JToken)
        else
            HelperFunctions.GetEntitiesAsJToken('GenPostGroup', JToken);
        MigrationGPAccountSetup.DeleteAll();

        MigrationGPAccountSetup.Init();
        // GL Posting Group Accounts
        if not UsingNewAccounts then begin
            MigrationGPAccountSetup.SalesAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'SALEACCT')), 1, 20);
            MigrationGPAccountSetup.SalesLineDiscAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'MKDNACCT')), 1, 20);
            MigrationGPAccountSetup.SalesInvDiscAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRDDISCT')), 1, 20);
            MigrationGPAccountSetup.SalesPmtDiscDebitAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TDISCTKN')), 1, 20);
            MigrationGPAccountSetup.PurchAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PURCHACCOUNT')), 1, 20);
            MigrationGPAccountSetup.PurchLineDiscAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRADEDISCPURCHASE')), 1, 20);
            MigrationGPAccountSetup.COGSAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'COGS')), 1, 20);
            MigrationGPAccountSetup.InventoryAdjmtAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'INVENTORYCONTROL')), 1, 20);
            MigrationGPAccountSetup.SalesCreditMemoAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'CREDITMEMO')), 1, 20);
            MigrationGPAccountSetup.PurchPmtDiscDebitAcc := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'DISCTAKENPURCHASE')), 1, 20);
            MigrationGPAccountSetup.PurchPrepaymentsAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PrepaymentAccountIndex')), 1, 20);
            MigrationGPAccountSetup.PurchaseVarianceAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PURPVIDX')), 1, 20);
        end;
        if UsingNewAccounts then begin
            Evaluate(MigrationGPAccountSetup.SalesAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'SALEACCTIDX')));
            Evaluate(MigrationGPAccountSetup.SalesLineDiscAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'MKDNACCTIDX')));
            Evaluate(MigrationGPAccountSetup.SalesInvDiscAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRDDISCTIDX')));
            Evaluate(MigrationGPAccountSetup.SalesPmtDiscDebitAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TDISCTKNIDX')));
            Evaluate(MigrationGPAccountSetup.PurchAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PURCHACCOUNTIDX')));
            Evaluate(MigrationGPAccountSetup.PurchLineDiscAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRADEDISCPURCHASEIDX')));
            Evaluate(MigrationGPAccountSetup.COGSAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'COGSIDX')));
            Evaluate(MigrationGPAccountSetup.InventoryAdjmtAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'INVENTORYCONTROLIDX')));
            Evaluate(MigrationGPAccountSetup.SalesCreditMemoAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'CREDITMEMOIDX')));
            Evaluate(MigrationGPAccountSetup.PurchPmtDiscDebitAccIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'DISCTAKENPURCHASEIDX')));
            Evaluate(MigrationGPAccountSetup.PurchPrepaymentsAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PrepaymentAccountIndexIDX')));
            Evaluate(MigrationGPAccountSetup.PurchaseVarianceAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'PURPVIDXIDX')));
        end;

        // Customer Posting Group Accounts
        if UsingNewAccounts then
            HelperFunctions.GetEntitiesAsJToken('CustPostGroup2', JToken)
        else
            HelperFunctions.GetEntitiesAsJToken('CustPostGroup', JToken);
        if not UsingNewAccounts then begin
            MigrationGPAccountSetup.ReceivablesAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'ACCOUNTSRECIEVABLE')), 1, 20);
            MigrationGPAccountSetup.ServiceChargeAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'FINANCECHARGE')), 1, 20);
            MigrationGPAccountSetup.PaymentDiscDebitAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRADEDISCTAKEN')), 1, 20);
        end;
        if UsingNewAccounts then begin
            Evaluate(MigrationGPAccountSetup.ReceivablesAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'ACCOUNTSRECIEVABLEIDX')));
            Evaluate(MigrationGPAccountSetup.ServiceChargeAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'FINANCECHARGEIDX')));
            Evaluate(MigrationGPAccountSetup.PaymentDiscDebitAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'TRADEDISCTAKENIDX')));
        end;

        // Inventory Posting Group Accounts
        if UsingNewAccounts then
            HelperFunctions.GetEntitiesAsJToken('InvPostGroup2', JToken)
        else
            HelperFunctions.GetEntitiesAsJToken('InvPostGroup', JToken);
        if not UsingNewAccounts then
            MigrationGPAccountSetup.InventoryAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'INVTACCT')), 1, 20);
        if UsingNewAccounts then
            Evaluate(MigrationGPAccountSetup.InventoryAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'INVTACCTIDX')));

        // Vendor Posting Group Accounts
        if UsingNewAccounts then
            HelperFunctions.GetEntitiesAsJToken('VendPostGroup2', JToken)
        else
            HelperFunctions.GetEntitiesAsJToken('VendPostGroup', JToken);

        if not UsingNewAccounts then begin
            MigrationGPAccountSetup.PayablesAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'ACCOUNTSPAYABLE')), 1, 20);
            MigrationGPAccountSetup.PurchServiceChargeAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'FINANCECHARGEPURCHASE')), 1, 20);
            MigrationGPAccountSetup.PurchPmtDiscDebitAccount := CopyStr(HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'DISCTAKEN')), 1, 20);
        end else begin
            Evaluate(MigrationGPAccountSetup.PayablesAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'ACCOUNTSPAYABLEIDX')));
            Evaluate(MigrationGPAccountSetup.PurchServiceChargeAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'FINANCECHARGEPURCHASEIDX')));
            Evaluate(MigrationGPAccountSetup.PurchPmtDiscDebitAccountIdx, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(JToken, 'DISCTAKENIDX')));
        end;

        MigrationGPAccountSetup.Insert();
    end;

    procedure ValidateNewAccountNumbers(): Boolean
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageData2: Record "Config. Package Data";
        ConfigPackageDataDesc: Record "Config. Package Data";
        MigrationGPConfig: Record "MigrationGP Config";
        MigrationGPAccount: Record "MigrationGP Account";
        AccountIndex: integer;
    begin
        // after this point, we should be able to validate the new account numbers where the ImportExcelData() method 
        // created in the 'Config Package Data' table.

        // 1. Make sure we have the correct number of accounts.
        MigrationGPConfig.GetSingleInstance();
        ConfigPackageData.Reset();
        ConfigPackageData.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageData.SetRange("Table ID", Database::"MigrationGP Account");
        ConfigPackageData.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctNumNew));
        If ConfigPackageData.Count() > MigrationGPConfig."Total Accounts" then begin
            message(TooManyAccountsMsg);
            EXIT(FALSE);
        end;
        If ConfigPackageData.Count() < MigrationGPConfig."Total Accounts" then begin
            message(TooFewAccountsMsg);
            EXIT(FALSE);
        end;

        // 2. Loop through Config Package Data table, with the Package Code of GP.MIGRATION.EXCEL, Table ID=1941, and Field ID for AcctNumNew.
        //    Use the Field ID of 2 for the Account Index to map to the right record in the Account Staging table.
        ConfigPackageData.FindSet();
        repeat
            // Check that we dont have duplicate, empty, or too long account numbers
            ConfigPackageData2.Reset();
            ConfigPackageData2.SetRange("Package Code", PackageCodeTxt);
            ConfigPackageData2.SetRange("Table ID", Database::"MigrationGP Account");
            ConfigPackageData2.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctNumNew));
            ConfigPackageData2.SetRange(Value, ConfigPackageData.Value);
            if (ConfigPackageData2.Count() > 1) and (ConfigPackageData.Value <> '') then begin
                message(DuplicateAccountMsg, Format(ConfigPackageData.Value));
                exit(false);
            end;
            if ConfigPackageData2.FindFirst() then begin
                if ConfigPackageData2.Value = '' then begin
                    message(EmptyAccountMsg);
                    exit(false);
                end;
                if StrLen(ConfigPackageData2.Value) > 20 then begin
                    message(AccountTooLongMsg);
                    exit(false);
                end;
            end;

            // Check to make sure the Account description is not greater than 50 characters.
            ConfigPackageDataDesc.Reset();
            ConfigPackageDataDesc.SetRange("Package Code", PackageCodeTxt);
            ConfigPackageDataDesc.SetRange("Table ID", Database::"MigrationGP Account");
            ConfigPackageDataDesc.Setrange("No.", ConfigPackageData."No.");
            ConfigPackageDataDesc.SetRange("Field ID", MigrationGPAccount.FieldNo(Name));
            ConfigPackageDataDesc.FINDSET();
            repeat
                if StrLen(ConfigPackageDataDesc.Value) > 50 then begin
                    message(AccountDescriptionTooLongMsg, Format(ConfigPackageData.Value));
                    exit(false);
                end;
            until ConfigPackageDataDesc.Next() = 0;

        until ConfigPackageData.Next() = 0;

        // 3. Make sure we have the account indexes exist in the Account staging table
        MigrationGPConfig.GetSingleInstance();
        ConfigPackageData.Reset();
        ConfigPackageData.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageData.SetRange("Table ID", Database::"MigrationGP Account");
        ConfigPackageData.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctIndex));
        ConfigPackageData.FINDSET();
        repeat
            ConfigPackageData2.Reset();
            ConfigPackageData2.SetRange("Package Code", PackageCodeTxt);
            ConfigPackageData2.SetRange("Table ID", Database::"MigrationGP Account");
            ConfigPackageData2.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctIndex));
            ConfigPackageData2.SetRange(Value, ConfigPackageData.Value);
            if (ConfigPackageData2.Count() > 1) and (ConfigPackageData.Value <> '') then begin
                message(DuplicateIndexMsg, Format(ConfigPackageData.Value));
                exit(false);
            end;

            // see if the account index value exists in the account staging table
            MigrationGPAccount.Reset();
            Evaluate(AccountIndex, ConfigPackageData.Value);
            MigrationGPAccount.SetRange(AcctIndex, AccountIndex);
            if MigrationGPAccount.IsEmpty() then begin
                message(DifferentAccountIndexMsg, Format(AccountIndex));
                EXIT(FALSE);
            end;
        until ConfigPackageData.Next() = 0;

        MigrationGPConfig.ClearAccountValidationError();
        exit(true);
    end;

    procedure UpdateAccountStagingTable(): Boolean;
    var
        ConfigPackageData: Record "Config. Package Data";
        ConfigPackageData2: Record "Config. Package Data";
        ConfigPackageData3: Record "Config. Package Data";
        MigrationGPAccount: Record "MigrationGP Account";
        AccountIndex: integer;
    begin
        // ConfigPackageData contains the record containing the account index
        // ConfigPackageData2 contains the record containing the new account number
        ConfigPackageData.Reset();
        ConfigPackageData.SetRange("Package Code", PackageCodeTxt);
        ConfigPackageData.SetRange("Table ID", Database::"MigrationGP Account");
        ConfigPackageData.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctIndex));
        ConfigPackageData.FindSet();
        repeat
            // Update the New Account Number
            ConfigPackageData2.Reset();
            ConfigPackageData2.SetRange("Package Code", PackageCodeTxt);
            ConfigPackageData2.SetRange("Table ID", Database::"MigrationGP Account");
            ConfigPackageData2.Setrange("No.", ConfigPackageData."No.");
            ConfigPackageData2.SetRange("Field ID", MigrationGPAccount.FieldNo(AcctNumNew));
            if ConfigPackageData2.FindFirst() then begin
                MigrationGPAccount.Reset();
                Evaluate(AccountIndex, ConfigPackageData.Value);
                MigrationGPAccount.SetRange(AcctIndex, AccountIndex);
                if MigrationGPAccount.FindFirst() then begin
                    MigrationGPAccount.AcctNumNew := CopyStr(ConfigPackageData2.Value, 1, 20);
                    MigrationGpAccount.Modify();
                end;
            end;

            // Update the Account Description
            ConfigPackageData3.Reset();
            ConfigPackageData3.SetRange("Package Code", PackageCodeTxt);
            ConfigPackageData3.SetRange("Table ID", Database::"MigrationGP Account");
            ConfigPackageData3.Setrange("No.", ConfigPackageData."No.");
            ConfigPackageData3.SetRange("Field ID", MigrationGPAccount.FieldNo(Name));
            if ConfigPackageData3.FindFirst() then begin
                MigrationGPAccount.Reset();
                Evaluate(AccountIndex, ConfigPackageData.Value);
                MigrationGPAccount.SetRange(AcctIndex, AccountIndex);
                if MigrationGPAccount.FindFirst() then begin
                    MigrationGPAccount.Name := CopyStr(ConfigPackageData3.Value, 1, 20);
                    MigrationGpAccount.Modify();
                end;
            end;
        until ConfigPackageData.Next() = 0;
        Exit(true);
    end;

    procedure UpdateDefaultAccounts()
    var
        MigrationGPAccountSetup: Record "MigrationGP Account Setup";
    begin
        MigrationGPAccountSetup.Reset();
        if MigrationGPAccountSetup.FindFirst() then begin
            MigrationGPAccountSetup.SalesAccount := GetNewAccountNumber(MigrationGPAccountSetup.SalesAccountIdx);
            MigrationGPAccountSetup.SalesLineDiscAccount := GetNewAccountNumber(MigrationGPAccountSetup.SalesLineDiscAccountIdx);
            MigrationGPAccountSetup.SalesInvDiscAccount := GetNewAccountNumber(MigrationGPAccountSetup.SalesInvDiscAccountIdx);
            MigrationGPAccountSetup.SalesPmtDiscDebitAccount := GetNewAccountNumber(MigrationGPAccountSetup.SalesPmtDiscDebitAccountIdx);
            MigrationGPAccountSetup.PurchAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchAccountIdx);
            MigrationGPAccountSetup.PurchInvDiscAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchInvDiscAccountIdx);
            MigrationGPAccountSetup.PurchLineDiscAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchLineDiscAccountIdx);
            MigrationGPAccountSetup.COGSAccount := GetNewAccountNumber(MigrationGPAccountSetup.COGSAccountIdx);
            MigrationGPAccountSetup.InventoryAdjmtAccount := GetNewAccountNumber(MigrationGPAccountSetup.InventoryAdjmtAccountIdx);
            MigrationGPAccountSetup.SalesCreditMemoAccount := GetNewAccountNumber(MigrationGPAccountSetup.SalesCreditMemoAccountIdx);
            MigrationGPAccountSetup.PurchPmtDiscDebitAcc := GetNewAccountNumber(MigrationGPAccountSetup.PurchPmtDiscDebitAccIdx);
            MigrationGPAccountSetup.PurchPrepaymentsAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchPrepaymentsAccountIdx);
            MigrationGPAccountSetup.PurchaseVarianceAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchaseVarianceAccountIdx);

            MigrationGPAccountSetup.InventoryAccount := GetNewAccountNumber(MigrationGPAccountSetup.InventoryAccountIdx);
            MigrationGPAccountSetup.ReceivablesAccount := GetNewAccountNumber(MigrationGPAccountSetup.ReceivablesAccountIdx);
            MigrationGPAccountSetup.ServiceChargeAccount := GetNewAccountNumber(MigrationGPAccountSetup.ServiceChargeAccountIdx);
            MigrationGPAccountSetup.PaymentDiscDebitAccount := GetNewAccountNumber(MigrationGPAccountSetup.PaymentDiscDebitAccountIdx);
            MigrationGPAccountSetup.PayablesAccount := GetNewAccountNumber(MigrationGPAccountSetup.PayablesAccountIdx);
            MigrationGPAccountSetup.PurchServiceChargeAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchServiceChargeAccountIdx);
            MigrationGPAccountSetup.PurchPmtDiscDebitAccount := GetNewAccountNumber(MigrationGPAccountSetup.PurchPmtDiscDebitAccountIdx);
            MigrationGPAccountSetup.Modify();
        end;
    end;

    procedure GetNewAccountNumber(AccountIndex: Integer): Code[20];
    var
        MigrationGPAccount: Record "MigrationGP Account";
    begin
        MigrationGPAccount.setrange(AcctIndex, AccountIndex);
        if MigrationGPAccount.FindFirst() then
            exit(MigrationGPAccount.AcctNumNew);
    end;

    local procedure GetTransactions()
    var
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        JArray: JsonArray;
    begin
        if (HelperFunctions.GetEntities('GLTrx', JArray)) then begin
            GetGLTrxFromJson(JArray);
            HelperFunctions.RemoveEmptyGLTransactions();
        end;
    end;

    procedure GetGLTrxFromJson(JArray: JsonArray);
    var
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
        MigrationGPAccount: Record "MigrationGP Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        RecordVariant: Variant;
        ChildJToken: JsonToken;
        EntityId: Text[40];
        i: Integer;
        AccountIndex: integer;
    begin
        i := 0;
        MigrationGPGLTrans.Reset();
        MigrationGPGLTrans.DeleteAll();
        WHILE JArray.Get(i, ChildJToken) do begin
            // only create if the account index is in the Account staging table
            evaluate(AccountIndex, HelperFunctions.TrimStringQuotes(HelperFunctions.GetTextFromJToken(ChildJToken, 'ACTINDX')));
            MigrationGPAccount.Reset();
            MigrationGPAccount.SetRange(AcctIndex, AccountIndex);
            if not MigrationGPAccount.IsEmpty() then begin
                EntityId := CopyStr(HelperFunctions.GetTextFromJToken(ChildJToken, 'Id'), 1, MAXSTRLEN(MigrationGPGLTrans.Id));
                EntityId := CopyStr(HelperFunctions.TrimStringQuotes(EntityId), 1, 40);

                if not MigrationGPGLTrans.Get(EntityId) then begin
                    MigrationGPGLTrans.Init();
                    MigrationGPGLTrans.Validate(MigrationGPGLTrans.Id, EntityId);
                    MigrationGPGLTrans.Insert(true);
                end;

                RecordVariant := MigrationGPGLTrans;
                UpdateGLTrxFromJson(RecordVariant, ChildJToken);
                MigrationGPGLTrans := RecordVariant;
                MigrationGPGLTrans.Modify(true);
            end;
            i := i + 1;
        end;
    end;

    procedure UpdateGLTransactions();
    var
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
    begin
        // Need to add the account number to the GL trx table
        MigrationGPGLTrans.Reset();
        MigrationGPGLTrans.FindFirst();
        repeat
            MigrationGPAccount.setrange(AcctIndex, MigrationGPGLTrans.ACTINDX);
            if MigrationGPAccount.FindFirst() then begin
                MigrationGPGLTrans.AccountNumber := MigrationGPAccount.AcctNumNew;
                MigrationGPGLTrans.Modify();
            end;
        until MigrationGPGLTrans.Next() = 0;
    end;

    local procedure UpdateGLTrxFromJson(var RecordVariant: Variant; JToken: JsonToken)
    var
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(ACTINDX), JToken.AsObject(), 'ACTINDX');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(YEAR1), JToken.AsObject(), 'YEAR1');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(PERIODID), JToken.AsObject(), 'PERIODID');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(DEBITAMT), JToken.AsObject(), 'DEBITAMT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(CRDTAMNT), JToken.AsObject(), 'CRDTAMNT');
        HelperFunctions.UpdateFieldValue(RecordVariant, MigrationGPGLTrans.FieldNo(PERDBLNC), JToken.AsObject(), 'PERDBLNC');
    end;

    local procedure GenerateGLTransactionBatches();
    var
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
        GenJournalLine: Record "Gen. Journal Line";
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPFiscalPeriods: Record "MigrationGP Fiscal Periods";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        Sender: Codeunit "Data Migration Facade Helper";
        PostingGroupCode: Text;
    begin
        if HelperFunctions.HaveGLTrxsBeenProcessed() then
            exit;

        MigrationGPGLTrans.Reset();
        MigrationGPGLTrans.SetCurrentKey(YEAR1, PERIODID, AccountNumber);
        if MigrationGPGLTrans.FindSet() then
            Repeat
                PostingGroupCode := PostingGroupCodeTxt + format(MigrationGPGLTrans.YEAR1) + '-' + format(MigrationGPGLTrans.PERIODID);
                Sender.CreateGeneralJournalBatchIfNeeded(CopyStr(PostingGroupCode, 1, 10), '', '');

                MigrationGPAccount.SetRange(AcctIndex, MigrationGPGLTrans.ACTINDX);
                if MigrationGPAccount.FindFirst() then
                    if MigrationGPFiscalPeriods.Get(MigrationGPGLTrans.PERIODID, MigrationGPGLTrans.YEAR1) then
                        Sender.CreateGeneralJournalLine(
                            GenJournalLine,
                            CopyStr(PostingGroupCode, 1, 10),
                            CopyStr(GlDocNoTxt, 1, 20),
                            CopyStr(DescriptionTrxTxt, 1, 50),
                            GenJournalLine."Account Type"::"G/L Account",
                            MigrationGPAccount.AcctNumNew,
                            MigrationGPFiscalPeriods.PERDENDT,//  End date for the fiscal period.
                            0D,
                            MigrationGPGLTrans.PERDBLNC,
                            MigrationGPGLTrans.PERDBLNC,
                            '',
                            ''
                        );
            until MigrationGPGLTrans.Next() = 0;
        HelperFunctions.SetTransactionProcessedFlag();
    end;
}