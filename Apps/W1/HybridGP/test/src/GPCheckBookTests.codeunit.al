codeunit 139678 "GP Checkbook Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    Permissions = tableData "Bank Account Ledger Entry" = rimd;
    TestPermissions = Disabled;

    var
        GlobalGPAccount: Record "GP Account";
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        GPCM20600: Record "GP CM20600";
        GenJournalTemplate: Record "Gen. Journal Template";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        GlobalBankAccount: Record "Bank Account";
        Assert: Codeunit Assert;
        GPTestHelperFunctions: Codeunit "GP Test Helper Functions";
        InvalidBankAccountMsg: Label '%1 should not have been created.', Comment = '%1 - bank account no.', Locked = true;
        MissingBankAccountMsg: Label '%1 should have been created.', Comment = '%1 - bank account no.', Locked = true;
        ExtraTransactionMsg: Label 'Invalid transaction with discription "%1" should have been created.', Comment = '%1 - transaction description.', Locked = true;
        MyBankStr1Txt: Label 'MyBank01', Comment = 'Bank name', Locked = true;
        MyBankStr2Txt: Label 'MyBank02', Comment = 'Bank name', Locked = true;
        MyBankStr3Txt: Label 'MyBank03', Comment = 'Bank name', Locked = true;
        MyBankStr4Txt: Label 'MyBank04', Comment = 'Bank name', Locked = true;
        MyBankStr5Txt: Label 'MyBank05', Comment = 'Bank name', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationIncludeInactive()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", true);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Bank Accounts are created
        Assert.RecordCount(BankAccount, 5);

        // [THEN] General Journal Lines are created
        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 17);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr1Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 2);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr3Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr4Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr5Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 7);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationExcludeInactive()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1Txt));

        BankAccount.SetRange("No.", MyBankStr3Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3Txt));

        BankAccount.SetRange("No.", MyBankStr2Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr2Txt));

        BankAccount.SetRange("No.", MyBankStr4Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr4Txt));

        BankAccount.SetRange("No.", MyBankStr5Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr5Txt));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr1Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 2);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr3Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr4Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr5Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 7);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationVerifySkipReconciled()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
        X: Integer;
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        //  including reconciled bank transactions
        CreateMoreCheckBookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1Txt));

        BankAccount.SetRange("No.", MyBankStr2Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr2Txt));

        BankAccount.SetRange("No.", MyBankStr3Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3Txt));

        BankAccount.SetRange("No.", MyBankStr4Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr4Txt));

        BankAccount.SetRange("No.", MyBankStr5Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr5Txt));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger only unreconciled transactions are created.
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 2);

        repeat
            if BankAccountLedgerEntry."Entry No." <> 0 then begin
                X := StrPos('Reconcile', BankAccountLedgerEntry.Description);
                Assert.AreEqual(0, X, StrSubstNo(ExtraTransactionMsg, BankAccountLedgerEntry.Description));
            end;
        until BankAccountLedgerEntry.Next() = 0;
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestBankMasterDataOnly()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        //  including reconciled bank transactions
        CreateMoreCheckBookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", true);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] General Journal Lines are not created
        Assert.RecordCount(GenJournalLine, 0);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestBankSkipPosting()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        //  including reconciled bank transactions
        CreateMoreCheckBookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", false);
        GPCompanyAdditionalSettings.Validate("Skip Posting Bank Batches", true);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] The GL Batch is created but not posted
        Clear(GenJournalLine);
        GenJournalLine.SetRange("Journal Batch Name", 'GPBANK');
        Assert.AreEqual(false, GenJournalLine.IsEmpty(), 'Could not locate the bank batch.');
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationBankTransfers()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedger: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
    begin
#pragma warning disable AA0210
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedger.Reset();
        BankAccountLedger.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedger.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", true);
        GPCompanyAdditionalSettings.Validate("Migrate Only Bank Master", false);
        GPCompanyAdditionalSettings.Validate("Migrate Inactive Checkbooks", false);
        GPCompanyAdditionalSettings.Validate("Skip Posting Bank Batches", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1Txt));

        BankAccount.SetRange("No.", MyBankStr2Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr2Txt));

        BankAccount.SetRange("No.", MyBankStr3Txt);
        Assert.IsTrue(BankAccount.IsEmpty(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3Txt));

        BankAccount.SetRange("No.", MyBankStr4Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr4Txt));

        BankAccount.SetRange("No.", MyBankStr5Txt);
        Assert.IsFalse(BankAccount.IsEmpty(), StrSubstNo(MissingBankAccountMsg, MyBankStr5Txt));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr1Txt));
        Assert.RecordCount(BankAccountLedger, 0);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr2Txt));
        Assert.RecordCount(BankAccountLedger, 2);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr3Txt));
        Assert.RecordCount(BankAccountLedger, 0);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr4Txt));
        Assert.RecordCount(BankAccountLedger, 4);

        BankAccountLedger.SetRange("Document No.", 'XFR000000001');
        BankAccountLedger.SetFilter(Amount, '>0');

        BankAccountLedger.FindFirst();
        Assert.AreEqual(100.00, BankAccountLedger.Amount, 'Transfer amount is wrong for Trx 520, MyBank4');

        BankAccountLedger.Reset();
        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr5Txt));
        Assert.RecordCount(BankAccountLedger, 7);

        BankAccountLedger.SetRange("Document No.", 'XFR000000001');
        BankAccountLedger.SetFilter(Amount, '<0');
        BankAccountLedger.FindFirst();
        Assert.AreEqual(-100.00, BankAccountLedger.Amount, 'Transfer amount is wrong for Trx 520, MyBank5');
#pragma warning restore AA0240
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestBankModuleDisabled()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] Bank module is disabled
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1Txt, MyBankStr2Txt, MyBankStr3Txt, MyBankStr4Txt, MyBankStr5Txt);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Bank module is disabled
        GPTestHelperFunctions.CreateConfigurationSettings();
        GPCompanyAdditionalSettings.GetSingleInstance();
        GPCompanyAdditionalSettings.Validate("Migrate Bank Module", false);
        GPCompanyAdditionalSettings.Modify();

        GPTestHelperFunctions.InitializeMigration();

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Bank Accounts are not created
        Assert.RecordCount(BankAccount, 0);

        // [THEN] General Journal Lines are not created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 0);

        // [WHEN] Batch posting is called.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are not created
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr1Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr3Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr4Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr5Txt));
        Assert.RecordCount(BankAccountLedgerEntry, 0);
    end;

    local procedure ClearTables()
    var
        GPConfiguration: Record "GP Configuration";
    begin
        GlobalBankAccount.DeleteAll();
        GPCheckbookMSTR.DeleteAll();
        GPTestHelperFunctions.DeleteAllSettings();
        GlobalGPAccount.DeleteAll();
        GPCheckbookMSTR.DeleteAll();
        GPCheckbookTransactions.DeleteAll();
        GPCM20600.DeleteAll();

        GPConfiguration.GetSingleInstance();
        GPConfiguration."CheckBooks Created" := false;
        GPConfiguration.Modify();
    end;

    local procedure Migrate()
    var
        HelperFunctions: Codeunit "Helper Functions";
    begin
        GlobalGPAccount.FindSet();
        repeat
            MigrateGL(GlobalGPAccount);
        until GlobalGPAccount.Next() = 0;
        HelperFunctions.CreatePostMigrationData();
    end;

    local procedure CreateMoreCheckBookData()
    begin
        CreateCheckbookData();

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 600.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210807D;
        GPCheckbookTransactions.TRXAMNT := 700.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled1 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 610.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210808D;
        GPCheckbookTransactions.TRXAMNT := 1400.00;
        GPCheckbookTransactions.CMLinkID := '5000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled2 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 620.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210809D;
        GPCheckbookTransactions.TRXAMNT := 750.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled3 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 630.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210810D;
        GPCheckbookTransactions.TRXAMNT := 750.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled4 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 640.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210811D;
        GPCheckbookTransactions.TRXAMNT := 750.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled5 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);
    end;

    local procedure CreateCheckbookData()
    begin
        CreateGenJournalTemplates();
        CreateAccounts();

        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr1Txt;
        GPCheckbookMSTR.BNKACTNM := MyBankStr1Txt;
        GPCheckbookMSTR.INACTIVE := true;
        GPCheckbookMSTR.ACTINDX := 0;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr2Txt;
        GPCheckbookMSTR.BNKACTNM := MyBankStr2Txt;
        GPCheckbookMSTR.INACTIVE := false;
        GPCheckbookMSTR.ACTINDX := 1;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr3Txt;
        GPCheckbookMSTR.BNKACTNM := MyBankStr3Txt;
        GPCheckbookMSTR.INACTIVE := true;
        GPCheckbookMSTR.ACTINDX := 2;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr4Txt;
        GPCheckbookMSTR.BNKACTNM := MyBankStr4Txt;
        GPCheckbookMSTR.INACTIVE := false;
        GPCheckbookMSTR.ACTINDX := 3;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr5Txt;
        GPCheckbookMSTR.BNKACTNM := MyBankStr5Txt;
        GPCheckbookMSTR.INACTIVE := false;
        GPCheckbookMSTR.ACTINDX := 4;
        GPCheckbookMSTR.Insert(true);

        // Transactions
        ///   CMTrxType = 
        ///        1        2        3                  4                    5                  6                  7
        ///     Deposit, Receipt, APCheck, "Withdrawl/Payroll Check", IncreaseAdjustment, DecreaseAdjustment, BankTransfer;
        /// 
        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 100.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 395.59;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck1 - Vendor Check';
        GPCheckbookTransactions.CMTrxNum := '100';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 120.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1Txt;
        GPCheckbookTransactions.CMTrxType := 1;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 500.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Deposit1';
        GPCheckbookTransactions.CMTrxNum := '120';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 125.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1Txt;
        GPCheckbookTransactions.CMTrxType := 2;
        GPCheckbookTransactions.TRXDATE := 20210902D;
        GPCheckbookTransactions.TRXAMNT := 250.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Receipt1';
        GPCheckbookTransactions.CMTrxNum := '125';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 130.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 650.00;
        GPCheckbookTransactions.CMLinkID := '2000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck2 - NonVendor Check';
        GPCheckbookTransactions.CMTrxNum := '130';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 200.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 450.36;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck3 - Vendor Check';
        GPCheckbookTransactions.CMTrxNum := '200';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 210.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 450.36;
        GPCheckbookTransactions.CMLinkID := '3000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck4 - NonVendor Check';
        GPCheckbookTransactions.CMTrxNum := '210';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 400.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4Txt;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck5 - Vendor Check';
        GPCheckbookTransactions.CMTrxNum := '400';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 410.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4Txt;
        GPCheckbookTransactions.CMTrxType := 4;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Withdrawl/Payroll Check1';
        GPCheckbookTransactions.CMTrxNum := '410';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 500.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 2;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Receipt2';
        GPCheckbookTransactions.CMTrxNum := '500';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 505.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 5;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'IncreaseAdjustment1';
        GPCheckbookTransactions.CMTrxNum := '505';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 510.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 6;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'DecreaseAdjustment1';
        GPCheckbookTransactions.CMTrxNum := '510';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 520.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 100.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer1';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000001';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 525.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 100.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer1';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000001';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 530.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer2';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000002';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 535.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer2';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000002';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 540.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210803D;
        GPCheckbookTransactions.TRXAMNT := 300.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer3';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000003';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 545.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5Txt;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210803D;
        GPCheckbookTransactions.TRXAMNT := 300.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer3';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000003';
        GPCheckbookTransactions.Insert(true);

        GPCM20600.Init();
        GPCM20600.Xfr_Record_Number := 1.0;
        GPCM20600.CMXFRNUM := 'XFR000000001';
        GPCM20600.CMFRMRECNUM := 520;
        GPCM20600.CMTORECNUM := 525;
        GPCM20600.CMFRMCHKBKID := MyBankStr5Txt;
        GPCM20600.CMCHKBKID := MyBankStr4Txt;
        GPCM20600.Insert(true);

        GPCM20600.Init();
        GPCM20600.Xfr_Record_Number := 2.0;
        GPCM20600.CMXFRNUM := 'XFR000000002';
        GPCM20600.CMFRMRECNUM := 530;
        GPCM20600.CMTORECNUM := 535;
        GPCM20600.CMFRMCHKBKID := MyBankStr4Txt;
        GPCM20600.CMCHKBKID := MyBankStr5Txt;
        GPCM20600.Insert(true);

        GPCM20600.Init();
        GPCM20600.Xfr_Record_Number := 3.0;
        GPCM20600.CMXFRNUM := 'XFR000000003';
        GPCM20600.CMFRMRECNUM := 540;
        GPCM20600.CMTORECNUM := 545;
        GPCM20600.CMFRMCHKBKID := MyBankStr5Txt;
        GPCM20600.CMCHKBKID := MyBankStr5Txt;
        GPCM20600.Insert(true);
    end;

    local procedure CreateAccounts()
    begin
        GlobalGPAccount.Init();
        GlobalGPAccount.AcctNum := '100';
        GlobalGPAccount.AcctIndex := 0;
        GlobalGPAccount.Name := 'Furniture & Fixtures';
        GlobalGPAccount.SearchName := 'Furniture & Fixtures';
        GlobalGPAccount.AccountCategory := 9;
        GlobalGPAccount.IncomeBalance := false;
        GlobalGPAccount.DebitCredit := 0;
        GlobalGPAccount.Active := false;
        GlobalGPAccount.DirectPosting := true;
        GlobalGPAccount.AccountSubcategoryEntryNo := 9;
        GlobalGPAccount.Insert(true);

        GlobalGPAccount.Reset();
        GlobalGPAccount.Init();
        GlobalGPAccount.AcctNum := '110';
        GlobalGPAccount.AcctIndex := 1;
        GlobalGPAccount.Name := 'Cash in banks-First Bank';
        GlobalGPAccount.SearchName := 'Cash in banks-First Bank';
        GlobalGPAccount.AccountCategory := 1;
        GlobalGPAccount.DebitCredit := 1;
        GlobalGPAccount.IncomeBalance := false;
        GlobalGPAccount.Active := false;
        GlobalGPAccount.DirectPosting := true;
        GlobalGPAccount.AccountSubcategoryEntryNo := 1;
        GlobalGPAccount.Insert(true);

        GlobalGPAccount.Reset();
        GlobalGPAccount.Init();
        GlobalGPAccount.AcctNum := '120';
        GlobalGPAccount.AcctIndex := 2;
        GlobalGPAccount.Name := 'Accounts Receivable';
        GlobalGPAccount.SearchName := 'Accounts Receivable';
        GlobalGPAccount.AccountCategory := 3;
        GlobalGPAccount.DebitCredit := 0;
        GlobalGPAccount.Active := false;
        GlobalGPAccount.DirectPosting := true;
        GlobalGPAccount.AccountSubcategoryEntryNo := 3;
        GlobalGPAccount.Insert(true);

        GlobalGPAccount.Reset();
        GlobalGPAccount.Init();
        GlobalGPAccount.AcctNum := '130';
        GlobalGPAccount.AcctIndex := 3;
        GlobalGPAccount.Name := 'TRUCKS';
        GlobalGPAccount.SearchName := 'TRUCKS';
        GlobalGPAccount.AccountCategory := 9;
        GlobalGPAccount.DebitCredit := 0;
        GlobalGPAccount.Active := false;
        GlobalGPAccount.DirectPosting := true;
        GlobalGPAccount.AccountSubcategoryEntryNo := 9;
        GlobalGPAccount.Insert(true);

        GlobalGPAccount.Reset();
        GlobalGPAccount.Init();
        GlobalGPAccount.AcctNum := '140';
        GlobalGPAccount.AcctIndex := 4;
        GlobalGPAccount.Name := 'MISC';
        GlobalGPAccount.SearchName := 'MISC';
        GlobalGPAccount.AccountCategory := 1;
        GlobalGPAccount.DebitCredit := 1;
        GlobalGPAccount.IncomeBalance := false;
        GlobalGPAccount.Active := false;
        GlobalGPAccount.DirectPosting := true;
        GlobalGPAccount.AccountSubcategoryEntryNo := 1;
        GlobalGPAccount.Insert(true);
    end;

    local procedure CreateGenJournalTemplates()
    begin
        GenJournalTemplate.Reset();
        GenJournalTemplate.SetRange(Name, 'GENERAL');
        if not GenJournalTemplate.FindFirst() then begin
            GenJournalTemplate.Init();
            GenJournalTemplate.Validate(Name, 'GENERAL');
            GenJournalTemplate.Validate(Description, 'General');
            GenJournalTemplate.Validate("Source Code", 'GENJNL');
            GenJournalTemplate.Validate("No. Series", 'GJNL-GEN');
            GenJournalTemplate.Insert(true);
        end;
    end;

    local procedure MigrateGL(GPAccount: Record "GP Account")
    var
        GLAccDataMigrationFacade: Codeunit "GL Acc. Data Migration Facade";
        GPAccountMigrator: Codeunit "GP Account Migrator";
    begin
        GPAccountMigrator.MigrateAccountDetails(GPAccount, GLAccDataMigrationFacade);
        GPAccountMigrator.GenerateGLTransactionBatches(GPAccount);
    end;
}