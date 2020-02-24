codeunit 139532 "MigrationQB Account Tests"
{
    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";

    trigger OnRun();
    begin
        // [FEATURE] [QuickBooks Data Migration]
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestQBAccountMigration()
    var
        MigrationQBAccount: Record "MigrationQB Account";
        GLAccount: Record "G/L Account";
        HelperFunctions: Codeunit "MigrationQB Helper Functions";
    begin
        // [SCENARIO] G/L Accounts are migrated from QB
        // [GIVEN] There are no records in G/L Account, G/L Entry, and staging tables
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateStagingTableEntries(MigrationQBAccount);

        // [WHEN] MigrationAccounts is called
        MigrationQBAccount.FindSet();
        repeat
            Migrate(MigrationQBAccount);
        until MigrationQBAccount.Next() = 0;

        // [THEN] A G/L Account is created for all staging table entries
        Assert.RecordCount(GLAccount, MigrationQBAccount.Count());

        // [WHEN] Transactions are migrated
        CreateOpeningBalances();

        // [THEN] Accounts are created with correct settings
        MigrationQBAccount.FindSet();
        GLAccount.FindSet();
        repeat
            Assert.AreEqual(MigrationQBAccount.AcctNum, GLAccount."No.",
                StrSubstNo('Account No. was expected to be %1 but it was %2 instead', MigrationQBAccount.AcctNum, GLAccount."No."));

            //Assert.AreEqual(MigrationQBAccount.CurrentBalance, GLAccount.Balance, 'Balance was different than expected');

            Assert.AreEqual(GLAccount."Account Type"::Posting, GLAccount."Account Type",
                StrSubstNo('Account Type was expected to be %1 but it was %2 instead', GLAccount."Account Type"::Posting, GLAccount."Account Type"));

            Assert.AreEqual(true, GLAccount."Direct Posting", 'Direct posting not set');

            Assert.AreEqual(HelperFunctions.ConvertAccountCategory(MigrationQBAccount), GLAccount."Account Category",
                StrSubstNo('Account Category was expected to be %1 but it was %2 instead', HelperFunctions.ConvertAccountCategory(MigrationQBAccount), GLAccount."Account Category"));

            MigrationQBAccount.Next();
        until GLAccount.Next() = 0;
    end;

    local procedure ClearTables()
    var
        MigrationQBAccountTable: Record "MigrationQB Account";
        GLAccount: Record "G/L Account";
        GLEntry: Record "G/L Entry";
    begin
        MigrationQBAccountTable.DeleteAll();
        GLAccount.DeleteAll();
        GLEntry.DeleteAll();
    end;

    local procedure Migrate(MigrationQBAccount: Record "MigrationQB Account")
    var
        MigrationQBAccountMigrator: Codeunit "MigrationQB Account Migrator";
    begin
        MigrationQBAccountMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, MigrationQBAccount.RecordId());
    end;

    local procedure CreateStagingTableEntries(var MigrationQBAccount: Record "MigrationQB Account")
    begin
        MigrationQBAccount.Init();
        MigrationQBAccount.Id := '1';
        MigrationQBAccount.AcctNum := '1000';
        MigrationQBAccount.Name := 'Bank';
        MigrationQBAccount.AccountType := 'Bank';
        MigrationQBAccount.Active := true;
        MigrationQBAccount.Insert();

        MigrationQBAccount.Init();
        MigrationQBAccount.Id := '2';
        MigrationQBAccount.AcctNum := '2000';
        MigrationQBAccount.Name := 'Income';
        MigrationQBAccount.AccountType := 'Income';
        MigrationQBAccount.Active := false;
        MigrationQBAccount.Insert();

        MigrationQBAccount.Init();
        MigrationQBAccount.Id := '3';
        MigrationQBAccount.AcctNum := '3000';
        MigrationQBAccount.Name := 'Expense';
        MigrationQBAccount.AccountType := 'Expense';
        MigrationQBAccount.Active := true;
        MigrationQBAccount.Insert();

        MigrationQBAccount.Init();
        MigrationQBAccount.Id := '4';
        MigrationQBAccount.AcctNum := '4000';
        MigrationQBAccount.Name := 'Accounts Receivable';
        MigrationQBAccount.AccountType := 'AccountsReceivable';
        MigrationQBAccount.CurrentBalance := 1234.56;
        MigrationQBAccount.Active := true;
        MigrationQBAccount.Insert();

        MigrationQBAccount.Init();
        MigrationQBAccount.Id := '5';
        MigrationQBAccount.AcctNum := '5000';
        MigrationQBAccount.Name := 'Accounts Payable';
        MigrationQBAccount.AccountType := 'AccountsPayable';
        MigrationQBAccount.Active := true;
        MigrationQBAccount.Insert();
    end;

    local procedure CreateOpeningBalances()
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := 1;
        GLEntry."G/L Account No." := '4000';
        GLEntry.Amount := 1234.56;
        GLEntry.Description := 'Opening entry';
        GLEntry.Insert();
    end;
}