codeunit 139534 "MigrationGP Account Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";
        MSGPAccountMigrationTests: Codeunit "MigrationGP Account Tests";

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPAccountMigration()
    var
        MigrationGPAccount: Record "MigrationGP Account";
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        // [SCENARIO] G/L Accounts are migrated from GP
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        if not BindSubscription(MSGPAccountMigrationTests) then
            exit;
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateAccountData(MigrationGPAccount);

        // [WHEN] MigrationAccounts is called
        MigrationGPAccount.FindSet();
        repeat
            Migrate(MigrationGPAccount);
        until MigrationGPAccount.Next() = 0;

        // [THEN] A G/L Account is created for all staging table entries
        Assert.RecordCount(GLAccount, 7);

        // [THEN] Accounts are created with correct settings
        MigrationGPAccount.FindSet();
        GLAccount.FindSet();
        repeat
            Assert.AreEqual(MigrationGPAccount.AcctNum, GLAccount."No.",
                StrSubstNo('Account No. was expected to be %1 but it was %2 instead', MigrationGPAccount.AcctNum, GLAccount."No."));

            Assert.AreEqual(GLAccount."Account Type"::Posting, GLAccount."Account Type",
                StrSubstNo('Account Type was expected to be %1 but it was %2 instead',
                    GLAccount."Account Type"::Posting, GLAccount."Account Type"));

            Assert.AreEqual(true, GLAccount."Direct Posting", 'Direct posting not set correctly.');

            Assert.AreEqual(HelperFunctions.ConvertAccountCategory(MigrationGPAccount), GLAccount."Account Category",
                StrSubstNo('Account Category was expected to be %1 but it was %2 instead',
                    HelperFunctions.ConvertAccountCategory(MigrationGPAccount), GLAccount."Account Category"));

            Assert.AreEqual(HelperFunctions.ConvertDebitCreditType(MigrationGPAccount), GLAccount."Debit/Credit",
                'Debit/Credit not set correctly.');
            MigrationGPAccount.Next();
        until GLAccount.Next() = 0;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPDimensionsCreation()
    var
        MigrationGPSegements: Record "MigrationGP Segments";
        MigrationGPCodes: Record "MigrationGP Codes";
        Dimensions: Record Dimension;
        DimensionValues: Record "Dimension Value";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
    begin
        // [SCENARIO] Dimensions are created for account segments using old account migration from GP
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateDimensionData(MigrationGPSegements, MigrationGPCodes);

        // [WHEN] CreateDimensions is called
        HelperFunctions.CreateDimensions();

        // [THEN] Dimensions and Dimension Values are created for all staging table entries
        Assert.RecordCount(Dimensions, MigrationGPSegements.Count());
        Assert.RecordCount(DimensionValues, MigrationGPCodes.Count());

        // [THEN] Dimensions and Dimension Values are created with correct settings  
        MigrationGPSegements.FindSet();
        Dimensions.FindSet();
        repeat
            if MigrationGPSegements.Id = 'LOCATION' then
                exit;
            Assert.AreEqual(MigrationGPSegements.Id, Dimensions.Code, 'Incorrect Code');
            Assert.AreEqual(MigrationGPSegements.Name, Dimensions.Name, 'Incorrect Name');
            Assert.AreEqual(MigrationGPSegements.CodeCaption, Dimensions."Code Caption", 'Incorrect Code Caption');
            Assert.AreEqual(MigrationGPSegements.FilterCaption, Dimensions."Filter Caption", 'Incorrect Code Caption');
            MigrationGPSegements.Next();
        until Dimensions.Next() = 0;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPAccountMigrationNew()
    var
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
        MigrationGPConfig: Record "MigrationGP Config";
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        AccountMigrator: Codeunit "MigrationGP Account Migrator";
        JArrayAccounts: JsonArray;
        JArrayGLTrx: JsonArray;
        JArrayFiscPeriods: JsonArray;
    begin
        // [SCENARIO] G/L Accounts are migrated from GP
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        if not BindSubscription(MSGPAccountMigrationTests) then
            exit;
        ClearTables();
        if not UnbindSubscription(MSGPAccountMigrationTests) then
            exit;

        // [GIVEN] Some records are created in the staging table
        GetDataFromFile('Account2', GetGetAllAccountsResponse(), JArrayAccounts);
        GetDataFromFile('GLTrx', GetGetAllGLTrxResponse(), JArrayGLTrx);
        GetDataFromFile('FiscalPeriods', GetFiscalPeriodsResponse(), JArrayFiscPeriods);

        // [WHEN] Data is imported
        MigrationGPConfig.GetSingleInstance();
        if MigrationGPConfig."Chart of Account Option" <> MigrationGPConfig."Chart of Account Option"::New then begin
            MigrationGPConfig."Chart of Account Option" := MigrationGPConfig."Chart of Account Option"::New;
            MigrationGPConfig.Modify();
        end;
        AccountMigrator.GetAccountsFromJson(JArrayAccounts);
        AccountMigrator.GetGLTrxFromJson(JArrayGLTrx);
        GetFiscalPeriodInfoFromJson(JArrayFiscPeriods);

        // [THEN] Then the correct number of Accounts and GL Transactions are imported.
        Assert.AreEqual(66, MigrationGPAccount.Count(), 'Wrong number of Accounts read');
        Assert.AreEqual(230, MigrationGPGLTrans.Count(), 'Wrong number of GL Transactions read');

        // [WHEN] MigrationAccounts is called
        // Need to copy the AcctNum to AcctNumNew for "new" Account chart of accounts option
        MigrationGPAccount.FindSet();
        repeat
            MigrationGPAccount.AcctNumNew := MigrationGPAccount.AcctNum;
            MigrationGPAccount.Modify();
        until MigrationGPAccount.Next() = 0;

        MigrationGPAccount.FindSet();
        repeat
            MigrateNew(MigrationGPAccount);
        until MigrationGPAccount.Next() = 0;

        // [THEN] A G/L Account is created for all staging table entries
        Assert.RecordCount(GLAccount, MigrationGPAccount.Count());

        // [THEN] Accounts are created with correct settings
        MigrationGPAccount.FindSet();
        GLAccount.FindSet();
        repeat
            Assert.AreEqual(MigrationGPAccount.AcctNum, GLAccount."No.",
                StrSubstNo('Account No. was expected to be %1 but it was %2 instead', MigrationGPAccount.AcctNum, GLAccount."No."));
            Assert.AreEqual(GLAccount."Account Type"::Posting, GLAccount."Account Type",
                StrSubstNo('Account Type was expected to be %1 but it was %2 instead',
                    GLAccount."Account Type"::Posting, GLAccount."Account Type"));
            Assert.AreEqual(true, GLAccount."Direct Posting", 'Direct posting not set');
            Assert.AreEqual(HelperFunctions.ConvertAccountCategory(MigrationGPAccount), GLAccount."Account Category",
                StrSubstNo('Account Category was expected to be %1 but it was %2 instead',
                    HelperFunctions.ConvertAccountCategory(MigrationGPAccount), GLAccount."Account Category"));
            Assert.AreEqual(HelperFunctions.ConvertDebitCreditType(MigrationGPAccount), GLAccount."Debit/Credit",
                StrSubstNo('Debit/Credit Type was expected to be %1 but it was %2 instead',
                    HelperFunctions.ConvertDebitCreditType(MigrationGPAccount), GLAccount."Debit/Credit"));
            MigrationGPAccount.Next();
        until GLAccount.Next() = 0;

        // [THEN] General Joural Lines are created
        GenJournalLine.FindSet();
        Assert.AreEqual(230, GenJournalLine.Count(),
            StrSubstNo('Expecting 230 Gen Journal Line entries but found %1', GenJournalLine.Count()));
    end;

    local procedure ClearTables()
    var
        MigrationGPAccount: Record "MigrationGP Account";
        MigrationGPCodes: Record "MigrationGP Codes";
        MigrationGPSegements: Record "MigrationGP Segments";
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        Dimensions: Record Dimension;
        DimensionValues: Record "Dimension Value";
        MigrationGPGLTrans: Record "MigrationGP GLTrans";
    begin
        MigrationGPAccount.DeleteAll();
        MigrationGPCodes.DeleteAll();
        MigrationGPSegements.DeleteAll();
        MigrationGPGLTrans.DeleteAll();
        GLAccount.DeleteAll();
        GenJournalLine.DeleteAll();
        Dimensions.DeleteAll();
        DimensionValues.DeleteAll();
    end;

    local procedure Migrate(MigrationGPAccount: Record "MigrationGP Account")
    var
        MigrationGPAccountMigrator: Codeunit "MigrationGP Account Migrator";
    begin
        MigrationGPAccountMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, MigrationGPAccount.RecordId());
        // MigrationGPAccountMigrator.OnCreateOpeningBalanceTrx(GLAccDataMigrationFacade, MigrationGPAccount.RecordId());
    end;

    local procedure MigrateNew(MigrationGPAccount: Record "MigrationGP Account")
    var
        MigrationGPAccountMigrator: Codeunit "MigrationGP Account Migrator";
    begin
        MigrationGPAccountMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, MigrationGPAccount.RecordId());
        MigrationGPAccountMigrator.OnMigrateAccountTransactions(GLAccDataMigrationFacade, MigrationGPAccount.RecordId());
    end;

    local procedure CreateAccountData(var MigrationGPAccount: Record "MigrationGP Account")
    begin
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '0000';
        MigrationGPAccount.Name := 'Furniture & Fixtures';
        MigrationGPAccount.SearchName := 'Furniture & Fixtures';
        MigrationGPAccount.AccountCategory := 9;
        MigrationGPAccount.IncomeBalance := false;
        MigrationGPAccount.DebitCredit := 0;
        MigrationGPAccount.Active := false;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 9;
        MigrationGPAccount.Balance := 0.0;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '1100';
        MigrationGPAccount.Name := 'Cash in banks-First Bank';
        MigrationGPAccount.SearchName := 'Cash in banks-First Bank';
        MigrationGPAccount.AccountCategory := 1;
        MigrationGPAccount.DebitCredit := 1;
        MigrationGPAccount.IncomeBalance := false;
        MigrationGPAccount.Active := false;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 1;
        MigrationGPAccount.Balance := 433800.70000;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '1200';
        MigrationGPAccount.Name := 'Accounts Receivable';
        MigrationGPAccount.SearchName := 'Accounts Receivable';
        MigrationGPAccount.AccountCategory := 3;
        MigrationGPAccount.DebitCredit := 0;
        MigrationGPAccount.Active := false;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 3;
        MigrationGPAccount.Balance := 742044.19000;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '1550';
        MigrationGPAccount.Name := 'TRUCKS';
        MigrationGPAccount.SearchName := 'TRUCKS';
        MigrationGPAccount.AccountCategory := 9;
        MigrationGPAccount.DebitCredit := 0;
        MigrationGPAccount.Active := false;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 9;
        MigrationGPAccount.Balance := 119737.50000;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '1555';
        MigrationGPAccount.Name := 'ACCUM. DEPR.-TRUCKS';
        MigrationGPAccount.SearchName := 'ACCUM. DEPR.-TRUCKS';
        MigrationGPAccount.AccountCategory := 10;
        MigrationGPAccount.DebitCredit := 0;
        MigrationGPAccount.Active := false;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 10;
        MigrationGPAccount.Balance := -79608.61000;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '2106';
        MigrationGPAccount.Name := 'MISC. PAYABLE';
        MigrationGPAccount.SearchName := 'MISC. PAYABLE';
        MigrationGPAccount.AccountCategory := 13;
        MigrationGPAccount.IncomeBalance := false;
        MigrationGPAccount.DebitCredit := 1;
        MigrationGPAccount.Active := true;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 13;
        MigrationGPAccount.Balance := -109695.19000;
        MigrationGPAccount.AccountType := 1;
        MigrationGPAccount.Insert(true);

        MigrationGPAccount.Reset();
        MigrationGPAccount.Init();
        MigrationGPAccount.AcctNum := '4125';
        MigrationGPAccount.Name := 'Markdown';
        MigrationGPAccount.SearchName := 'Markdown';
        MigrationGPAccount.AccountCategory := 5;
        MigrationGPAccount.IncomeBalance := true;
        MigrationGPAccount.DebitCredit := 1;
        MigrationGPAccount.Active := true;
        MigrationGPAccount.DirectPosting := true;
        MigrationGPAccount.AccountSubcategoryEntryNo := 5;
        MigrationGPAccount.Balance := 0.00;
        MigrationGPAccount.AccountType := 1;
        MigrationGPAccount.Insert(true);
    end;

    local procedure CreateDimensionData(var MigrationGPSegments: Record "MigrationGP Segments"; var MigrationGPCodes: Record "MigrationGP Codes")
    begin
        MigrationGPSegments.Init();
        MigrationGPSegments.Id := 'CITY';
        MigrationGPSegments.Name := 'City';
        MigrationGPSegments.CodeCaption := 'City Code';
        MigrationGPSegments.FilterCaption := 'City Filter';
        MigrationGPSegments.Insert();

        MigrationGPSegments.Init();
        MigrationGPSegments.Id := 'LOCATION';
        MigrationGPSegments.Name := 'Location';
        MigrationGPSegments.CodeCaption := 'Location Code';
        MigrationGPSegments.FilterCaption := 'Location Filter';
        MigrationGPSegments.Insert();

        MigrationGPSegments.Init();
        MigrationGPSegments.Id := 'DEPARTMENT';
        MigrationGPSegments.Name := 'Department';
        MigrationGPSegments.CodeCaption := 'Department Code';
        MigrationGPSegments.FilterCaption := 'Department Filter';
        MigrationGPSegments.Insert();

        MigrationGPCodes.Init();
        MigrationGPCodes.Id := 'City';
        MigrationGPCodes.Name := '0000';
        MigrationGPCodes.Description := 'City 000';
        MigrationGPCodes.Insert();

        MigrationGPCodes.Init();
        MigrationGPCodes.Id := 'City';
        MigrationGPCodes.Name := '1000';
        MigrationGPCodes.Description := 'City 1000';
        MigrationGPCodes.Insert();

        MigrationGPCodes.Init();
        MigrationGPCodes.Id := 'Location';
        MigrationGPCodes.Name := '1000';
        MigrationGPCodes.Description := 'Location 1000';
        MigrationGPCodes.Insert();

        MigrationGPCodes.Init();
        MigrationGPCodes.Id := 'Location';
        MigrationGPCodes.Name := '2000';
        MigrationGPCodes.Description := 'Location 2000';
        MigrationGPCodes.Insert();
    end;

    local procedure Initialize()
    begin
        if not BindSubscription(MSGPAccountMigrationTests) then
            exit;
        ClearTables();
        if UnbindSubscription(MSGPAccountMigrationTests) then
            exit;
    end;

    local procedure GetDataFromFile(EntityName: Text; TestDataFile: Text; var JArray: JsonArray): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        if JObject.ReadFrom(GetFileContent(GetInetroot() + TestDataFile)) then
            if JObject.SelectToken(EntityName, JToken) then
                if JToken.IsArray() then begin
                    JArray := JToken.AsArray();
                    exit(true);
                end;

        exit(false);
    end;

    local procedure GetFileContent(FileName: Text): Text
    var
        TempFile: File;
        FileContent: Text;
        Line: Text;
    begin
        if FileName <> '' then begin
            TempFile.TextMode(true);
            TempFile.WriteMode(false);
            TempFile.Open(FileName);
            repeat
                TempFile.Read(Line);
                FileContent := FileContent + Line;
            until (TempFile.Pos() = TempFile.Len());
            exit(FileContent);
        end;
    end;

    local procedure GetInetroot(): Text[170]
    begin
        exit(ApplicationPath() + '\..\..\');
    end;

    local procedure GetGetAllAccountsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\Account2.txt');
    end;

    local procedure GetGetAllGLTrxResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\GPResponse\GLTrx.txt');
    end;

    local procedure GetFiscalPeriodsResponse(): Text[100]
    begin
        exit('\App\Apps\W1\DynamicsGPDataMigrationV2\test\resources\FiscalPeriods.txt');
    end;

    procedure GetFiscalPeriodInfoFromJson(JArray: JsonArray)
    var
        MigrationGPFiscalPeriods: Record "MigrationGP Fiscal Periods";
        HelperFunctions: Codeunit "MigrationGP Helper Functions";
        TypeHelper: Codeunit "Type Helper";
        MyVariant: Variant;
        ChildJToken: JsonToken;
        i: Integer;
        DateVar: Date;
        IntegerVarPeriodID: Integer;
        IntegerVarYear1: Integer;
        WorkingText: Text;
    begin
        if not HelperFunctions.IsUsingNewAccountFormat() then
            exit;
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
}