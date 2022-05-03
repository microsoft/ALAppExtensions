codeunit 139678 "GP Checkbook Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    TestPermissions = Disabled;

    var
        GPCheckbookMSTRTable: Record "GP Checkbook MSTR";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        BankAccount: Record "Bank Account";
        Assert: Codeunit Assert;
        InvalidBankAccountMsg: Label '%1 should not have been created.', Comment = '%1 - bank account no.', Locked = true;
        MissingBankAccountMsg: Label '%1 should have been created.', Comment = '%1 - bank account no.', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCheckbookMigrationIncludeInactive()
    var
        BankAccount: Record "Bank Account";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are to be migrated
        ConfigureMigrationSettings(true);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Bank Accounts are created
        Assert.RecordCount(BankAccount, 5);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    procedure TestGPCheckbookMigrationExcludeInactive()
    var
        BankAccount: Record "Bank Account";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        ConfigureMigrationSettings(false);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", 'MyBank01');
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, 'MyBank01'));

        BankAccount.SetRange("No.", 'MyBank02');
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, 'MyBank02'));

        BankAccount.SetRange("No.", 'MyBank03');
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, 'MyBank03'));

        BankAccount.SetRange("No.", 'MyBank04');
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, 'MyBank04'));

        BankAccount.SetRange("No.", 'MyBank05');
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, 'MyBank05'));
    end;

    local procedure ClearTables()
    begin
        BankAccount.DeleteAll();
        BankAccountPostingGroup.DeleteAll();
        GPCheckbookMSTRTable.DeleteAll();
        GPCompanyMigrationSettings.DeleteAll();
        GPCompanyAdditionalSettings.DeleteAll();
    end;

    local procedure Migrate()
    begin
        GPCheckbookMSTRTable.MoveStagingData();
    end;

    local procedure ConfigureMigrationSettings(MigrateInactive: Boolean)
    begin
        GPCompanyMigrationSettings.Init();
        GPCompanyMigrationSettings.Name := CompanyName();
        GPCompanyMigrationSettings.Insert(true);

        GPCompanyAdditionalSettings.Init();
        GPCompanyAdditionalSettings.Name := GPCompanyMigrationSettings.Name;
        GPCompanyAdditionalSettings."Migrate Inactive Checkbooks" := MigrateInactive;
        GPCompanyAdditionalSettings.Insert(true);
    end;

    local procedure CreateCheckbookData()
    begin
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := 'MyBank01';
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := 'MyBank02';
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := 'MyBank03';
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := 'MyBank04';
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := 'MyBank05';
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.Insert(true);
    end;
}