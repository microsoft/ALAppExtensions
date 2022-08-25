codeunit 139661 "GP Account Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";
        MSGPAccountMigrationTests: Codeunit "GP Account Tests";
        InvalidAccountNoMsg: Label 'Account No. was expected to be %1 but it was %2 instead', Comment = '%1 - expected value; %2 - actual value', Locked = true;
        InvalidAccountTypeMsg: Label 'Account Type was expected to be %1 but it was %2 instead', Comment = '%1 - expected value; %2 - actual value', Locked = true;
        InvalidAccountCategoryMsg: Label 'Account Category was expected to be %1 but it was %2 instead', Comment = '%1 - expected value; %2 - actual value', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPAccountMigration()
    var
        GPGLTransactions: Record "GP GLTransactions";
        DimensionSetEntry: Record "Dimension Set Entry";
        GPAccount: Record "GP Account";
        GLAccount: Record "G/L Account";
        GPSegements: Record "GP Segments";
        GPCodes: Record "GP Codes";
        GPFiscalPeriods: Record "GP Fiscal Periods";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] G/L Accounts are migrated from GP
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        if not BindSubscription(MSGPAccountMigrationTests) then
            exit;
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateAccountData(GPAccount);
        CreateDimensionData(GPSegements, GPCodes);
        HelperFunctions.CreateDimensions();
        CreateFiscalPeriods(GPFiscalPeriods);
        CreateTrxData(GPGLTransactions);

        // [WHEN] MigrationAccounts is called
        GPAccount.FindSet();
        repeat
            Migrate(GPAccount);
        until GPAccount.Next() = 0;

        // [THEN] G/L Account's, transactions, and dimension sets are created for all staging table entries
        Assert.RecordCount(GLAccount, 7);
        Assert.RecordCount(GPGLTransactions, 3);
        Assert.RecordCount(DimensionSetEntry, 6);

        // [THEN] Accounts are created with correct settings
        GPAccount.FindSet();
        GLAccount.FindSet();
        repeat
            Assert.AreEqual(GPAccount.AcctNum, GLAccount."No.",
                StrSubstNo(InvalidAccountNoMsg, GPAccount.AcctNum, GLAccount."No."));

            Assert.AreEqual(GLAccount."Account Type"::Posting, GLAccount."Account Type",
                StrSubstNo(InvalidAccountTypeMsg, GLAccount."Account Type"::Posting, GLAccount."Account Type"));

            Assert.AreEqual(true, GLAccount."Direct Posting", 'Direct posting not set correctly.');

            Assert.AreEqual(HelperFunctions.ConvertAccountCategory(GPAccount), GLAccount."Account Category",
                StrSubstNo(InvalidAccountCategoryMsg, HelperFunctions.ConvertAccountCategory(GPAccount), GLAccount."Account Category"));

            Assert.AreEqual(HelperFunctions.ConvertDebitCreditType(GPAccount), GLAccount."Debit/Credit",
                'Debit/Credit not set correctly.');
            GPAccount.Next();
        until GLAccount.Next() = 0;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPDimensionsCreation()
    var
        GPSegements: Record "GP Segments";
        GPCodes: Record "GP Codes";
        Dimensions: Record Dimension;
        DimensionValues: Record "Dimension Value";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Dimensions are created for account segments using old account migration from GP
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateDimensionData(GPSegements, GPCodes);

        // [WHEN] CreateDimensions is called
        HelperFunctions.CreateDimensions();

        // [THEN] Dimensions and Dimension Values are created for all staging table entries
        Assert.RecordCount(Dimensions, GPSegements.Count());
        Assert.RecordCount(DimensionValues, GPCodes.Count());

        // [THEN] Dimensions and Dimension Values are created with correct settings  
        GPSegements.FindSet();
        Dimensions.FindSet();
        repeat
            if GPSegements.Id = 'LOCATION' then
                Assert.AreEqual('LOCATIONS', Dimensions.Code, 'Incorrect Code')
            else
                Assert.AreEqual(GPSegements.Id, Dimensions.Code, 'Incorrect Code');
            Assert.AreEqual(GPSegements.Name, Dimensions.Name, 'Incorrect Name');
            Assert.AreEqual(GPSegements.CodeCaption, Dimensions."Code Caption", 'Incorrect Code Caption');
            Assert.AreEqual(GPSegements.FilterCaption, Dimensions."Filter Caption", 'Incorrect Code Caption');
            GPSegements.Next();
        until Dimensions.Next() = 0;
    end;

    local procedure ClearTables()
    var
        GPGLTransactions: Record "GP GLTransactions";
        GPAccount: Record "GP Account";
        GPCodes: Record "GP Codes";
        GPSegements: Record "GP Segments";
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        Dimensions: Record Dimension;
        DimensionValues: Record "Dimension Value";
        DimensionSetEntry: Record "Dimension Set Entry";
        GPFiscalPeriods: Record "GP Fiscal Periods";
    begin
        GPAccount.DeleteAll();
        GPCodes.DeleteAll();
        GPSegements.DeleteAll();
        GLAccount.DeleteAll();
        GenJournalLine.DeleteAll();
        DimensionSetEntry.DeleteAll();
        Dimensions.DeleteAll();
        DimensionValues.DeleteAll();
        GPFiscalPeriods.DeleteAll();
        GPGLTransactions.DeleteAll();
    end;

    local procedure Migrate(GPAccount: Record "GP Account")
    var
        GPAccountMigrator: Codeunit "GP Account Migrator";
    begin
        GPAccountMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, GPAccount.RecordId());
        GPAccountMigrator.OnMigrateAccountTransactions(GLAccDataMigrationFacade, GPAccount.RecordId());
    end;

    local procedure CreateAccountData(var GPAccount: Record "GP Account")
    begin
        GPAccount.Init();
        GPAccount.AcctNum := '0000';
        GPAccount.AcctIndex := 0;
        GPAccount.Name := 'Furniture & Fixtures';
        GPAccount.SearchName := 'Furniture & Fixtures';
        GPAccount.AccountCategory := 9;
        GPAccount.IncomeBalance := false;
        GPAccount.DebitCredit := 0;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 9;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '1100';
        GPAccount.AcctIndex := 1;
        GPAccount.Name := 'Cash in banks-First Bank';
        GPAccount.SearchName := 'Cash in banks-First Bank';
        GPAccount.AccountCategory := 1;
        GPAccount.DebitCredit := 1;
        GPAccount.IncomeBalance := false;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 1;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '1200';
        GPAccount.AcctIndex := 2;
        GPAccount.Name := 'Accounts Receivable';
        GPAccount.SearchName := 'Accounts Receivable';
        GPAccount.AccountCategory := 3;
        GPAccount.DebitCredit := 0;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 3;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '1550';
        GPAccount.AcctIndex := 3;
        GPAccount.Name := 'TRUCKS';
        GPAccount.SearchName := 'TRUCKS';
        GPAccount.AccountCategory := 9;
        GPAccount.DebitCredit := 0;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 9;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '1555';
        GPAccount.AcctIndex := 4;
        GPAccount.Name := 'ACCUM. DEPR.-TRUCKS';
        GPAccount.SearchName := 'ACCUM. DEPR.-TRUCKS';
        GPAccount.AccountCategory := 10;
        GPAccount.DebitCredit := 0;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 10;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '2106';
        GPAccount.AcctIndex := 5;
        GPAccount.Name := 'MISC. PAYABLE';
        GPAccount.SearchName := 'MISC. PAYABLE';
        GPAccount.AccountCategory := 13;
        GPAccount.IncomeBalance := false;
        GPAccount.DebitCredit := 1;
        GPAccount.Active := true;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 13;
        GPAccount.AccountType := 1;
        GPAccount.Insert(true);

        GPAccount.Reset();
        GPAccount.Init();
        GPAccount.AcctNum := '4125';
        GPAccount.AcctIndex := 6;
        GPAccount.Name := 'Markdown';
        GPAccount.SearchName := 'Markdown';
        GPAccount.AccountCategory := 5;
        GPAccount.IncomeBalance := true;
        GPAccount.DebitCredit := 1;
        GPAccount.Active := true;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 5;
        GPAccount.AccountType := 1;
        GPAccount.Insert(true);
    end;

    local procedure CreateDimensionData(var GPSegments: Record "GP Segments"; var GPCodes: Record "GP Codes")
    begin
        GPSegments.Init();
        GPSegments.Id := 'CITY';
        GPSegments.Name := 'City';
        GPSegments.CodeCaption := 'City Code';
        GPSegments.FilterCaption := 'City Filter';
        GPSegments.SegmentNumber := 1;
        GPSegments.Insert();

        GPSegments.Init();
        GPSegments.Id := 'LOCATION';
        GPSegments.Name := 'Location';
        GPSegments.CodeCaption := 'Location Code';
        GPSegments.FilterCaption := 'Location Filter';
        GPSegments.SegmentNumber := 3;
        GPSegments.Insert();

        GPSegments.Init();
        GPSegments.Id := 'DEPARTMENT';
        GPSegments.Name := 'Department';
        GPSegments.CodeCaption := 'Department Code';
        GPSegments.FilterCaption := 'Department Filter';
        GPSegments.SegmentNumber := 4;
        GPSegments.Insert();

        GPCodes.Init();
        GPCodes.Id := 'City';
        GPCodes.Name := '0000';
        GPCodes.Description := 'City 000';
        GPCodes.Insert();

        GPCodes.Init();
        GPCodes.Id := 'City';
        GPCodes.Name := '1000';
        GPCodes.Description := 'City 1000';
        GPCodes.Insert();

        GPCodes.Init();
        GPCodes.Id := 'Location';
        GPCodes.Name := '1000';
        GPCodes.Description := 'Location 1000';
        GPCodes.Insert();

        GPCodes.Init();
        GPCodes.Id := 'Location';
        GPCodes.Name := '2000';
        GPCodes.Description := 'Location 2000';
        GPCodes.Insert();

        GPCodes.Init();
        GPCodes.Id := 'Department';
        GPCodes.Name := '2000';
        GPCodes.Description := 'Department 2000';
        GPCodes.Insert();
    end;

    local procedure CreateFiscalPeriods(GPFiscalPeriods: Record "GP Fiscal Periods")
    begin
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 0;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980401D;
        GPFiscalPeriods.PERDENDT := 19980401D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 1;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980401D;
        GPFiscalPeriods.PERDENDT := 19980430D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 2;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980501D;
        GPFiscalPeriods.PERDENDT := 19980531D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 3;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980601D;
        GPFiscalPeriods.PERDENDT := 19980630D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 4;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980701D;
        GPFiscalPeriods.PERDENDT := 19980731D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 5;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980801D;
        GPFiscalPeriods.PERDENDT := 19980831D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 6;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19980901D;
        GPFiscalPeriods.PERDENDT := 19980930D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 7;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19981001D;
        GPFiscalPeriods.PERDENDT := 19981031D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 8;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19981101D;
        GPFiscalPeriods.PERDENDT := 19981130D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 9;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19981201D;
        GPFiscalPeriods.PERDENDT := 19981231D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 10;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19990101D;
        GPFiscalPeriods.PERDENDT := 19990131D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 11;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19990201D;
        GPFiscalPeriods.PERDENDT := 19990228D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 12;
        GPFiscalPeriods.YEAR1 := 1999;
        GPFiscalPeriods.PERIODDT := 19990301D;
        GPFiscalPeriods.PERDENDT := 19990331D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 1;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990401D;
        GPFiscalPeriods.PERDENDT := 19990430D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 2;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990501D;
        GPFiscalPeriods.PERDENDT := 19990531D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 3;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990601D;
        GPFiscalPeriods.PERDENDT := 19990630D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 4;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990701D;
        GPFiscalPeriods.PERDENDT := 19990731D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 5;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990801D;
        GPFiscalPeriods.PERDENDT := 19990831D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 6;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19990901D;
        GPFiscalPeriods.PERDENDT := 19990930D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 7;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19991001D;
        GPFiscalPeriods.PERDENDT := 19991031D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 8;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19991101D;
        GPFiscalPeriods.PERDENDT := 19991130D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 9;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 19991201D;
        GPFiscalPeriods.PERDENDT := 19991231D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 10;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 20000101D;
        GPFiscalPeriods.PERDENDT := 20000131D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 11;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 20000201D;
        GPFiscalPeriods.PERDENDT := 20000228D;
        GPFiscalPeriods.Insert(true);

        GPFiscalPeriods.Reset();
        GPFiscalPeriods.Init();
        GPFiscalPeriods.PERIODID := 12;
        GPFiscalPeriods.YEAR1 := 2000;
        GPFiscalPeriods.PERIODDT := 20000301D;
        GPFiscalPeriods.PERDENDT := 20000331D;
        GPFiscalPeriods.Insert(true);
    end;

    local procedure CreateTrxData(GPGLTransactions: Record "GP GLTransactions")
    begin
        GPGLTransactions.Init();
        GPGLTransactions.Id := '1';
        GPGLTransactions.MNACSGMT := 2;
        GPGLTransactions.ACTINDX := 2;
        GPGLTransactions.YEAR1 := 1999;
        GPGLTransactions.PERIODID := 1;
        GPGLTransactions.ACTNUMBR_1 := '0000';
        GPGLTransactions.ACTNUMBR_2 := '1200';
        GPGLTransactions.ACTNUMBR_3 := '1000';
        GPGLTransactions.ACTNUMBR_4 := '2000';
        GPGLTransactions.PERDBLNC := 206.99;
        GPGLTransactions.DEBITAMT := 206.99;
        GPGLTransactions.CRDTAMNT := 0.00;
        GPGLTransactions.Insert();

        GPGLTransactions.Reset();
        GPGLTransactions.Init();
        GPGLTransactions.Id := '2';
        GPGLTransactions.MNACSGMT := 2;
        GPGLTransactions.ACTINDX := 1;
        GPGLTransactions.YEAR1 := 1999;
        GPGLTransactions.PERIODID := 1;
        GPGLTransactions.ACTNUMBR_1 := '0000';
        GPGLTransactions.ACTNUMBR_2 := '1100';
        GPGLTransactions.ACTNUMBR_3 := '1000';
        GPGLTransactions.ACTNUMBR_4 := '2000';
        GPGLTransactions.PERDBLNC := 306.99;
        GPGLTransactions.DEBITAMT := 306.99;
        GPGLTransactions.CRDTAMNT := 0.00;
        GPGLTransactions.Insert();

        GPGLTransactions.Reset();
        GPGLTransactions.Init();
        GPGLTransactions.Id := '3';
        GPGLTransactions.MNACSGMT := 2;
        GPGLTransactions.ACTINDX := 3;
        GPGLTransactions.YEAR1 := 1999;
        GPGLTransactions.PERIODID := 1;
        GPGLTransactions.ACTNUMBR_1 := '0000';
        GPGLTransactions.ACTNUMBR_2 := '1550';
        GPGLTransactions.ACTNUMBR_3 := '2000';
        GPGLTransactions.ACTNUMBR_4 := '2000';
        GPGLTransactions.PERDBLNC := 406.99;
        GPGLTransactions.DEBITAMT := 406.99;
        GPGLTransactions.CRDTAMNT := 0.00;
        GPGLTransactions.Insert();
    end;
}