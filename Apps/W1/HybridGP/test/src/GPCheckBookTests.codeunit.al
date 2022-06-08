codeunit 139678 "GP Checkbook Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    Permissions = tableData "Bank Account Ledger Entry" = rimd;
    TestPermissions = Disabled;

    var
        GPAccount: Record "GP Account";
        GPCheckbookMSTR: Record "GP Checkbook MSTR";
        GPCheckbookTransactions: Record "GP Checkbook Transactions";
        GPCM20600: Record "GP CM20600";
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        BankAccount: Record "Bank Account";
        Assert: Codeunit Assert;
        GenJournalTemplate: Record "Gen. Journal Template";
        InvalidBankAccountMsg: Label '%1 should not have been created.', Comment = '%1 - bank account no.', Locked = true;
        MissingBankAccountMsg: Label '%1 should have been created.', Comment = '%1 - bank account no.', Locked = true;
        ExtraTransactionMsg: Label 'Invalid transaction with discription "%1" should have been created.', Comment = '%1 - transaction description.', Locked = true;
        MyBankStr1: Label 'MyBank01', Comment = 'Bank name', Locked = true;
        MyBankStr2: Label 'MyBank02', Comment = 'Bank name', Locked = true;
        MyBankStr3: Label 'MyBank03', Comment = 'Bank name', Locked = true;
        MyBankStr4: Label 'MyBank04', Comment = 'Bank name', Locked = true;
        MyBankStr5: Label 'MyBank05', Comment = 'Bank name', Locked = true;

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
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1, MyBankStr2, MyBankStr3, MyBankStr4, MyBankStr5);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are to be migrated
        ConfigureMigrationSettings(true);

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
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr1));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2));
        Assert.RecordCount(BankAccountLedgerEntry, 2);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr3));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr4));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr5));
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
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1, MyBankStr2, MyBankStr3, MyBankStr4, MyBankStr5);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        ConfigureMigrationSettings(false);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1));

        BankAccount.SetRange("No.", MyBankStr2);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr2));

        BankAccount.SetRange("No.", MyBankStr3);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3));

        BankAccount.SetRange("No.", MyBankStr4);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr4));

        BankAccount.SetRange("No.", MyBankStr5);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr5));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr1));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2));
        Assert.RecordCount(BankAccountLedgerEntry, 2);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr3));
        Assert.RecordCount(BankAccountLedgerEntry, 0);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr4));
        Assert.RecordCount(BankAccountLedgerEntry, 4);

        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr5));
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
        BankAccountLedgerEntry.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1, MyBankStr2, MyBankStr3, MyBankStr4, MyBankStr5);
        BankAccountLedgerEntry.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        //  including reconciled bank transactions
        CreateMoreCheckBookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        ConfigureMigrationSettings(false);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1));

        BankAccount.SetRange("No.", MyBankStr2);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr2));

        BankAccount.SetRange("No.", MyBankStr3);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3));

        BankAccount.SetRange("No.", MyBankStr4);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr4));

        BankAccount.SetRange("No.", MyBankStr5);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr5));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger only unreconciled transactions are created.
        BankAccountLedgerEntry.Reset();
        BankAccountLedgerEntry.SetRange("Bank Account No.", UpperCase(MyBankStr2));
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
    procedure TestGPCheckbookMigrationBankTransfers()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedger: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
    begin
        // [SCENARIO] CheckBooks are migrated from GP
        // [GIVEN] There are no records in the BankAcount table
        ClearTables();
        GenJournalLine.DeleteAll();
        BankAccountLedger.Reset();
        BankAccountLedger.SetFilter("Bank Account No.", '%1|%2|%3|%4|%5', MyBankStr1, MyBankStr2, MyBankStr3, MyBankStr4, MyBankStr5);
        BankAccountLedger.DeleteAll();

        // [GIVEN] Some records are created in the staging table
        CreateCheckbookData();

        // [GIVEN] Inactive checkbooks are NOT to be migrated
        ConfigureMigrationSettings(false);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Active Bank Accounts are created
        Assert.RecordCount(BankAccount, 3);

        // [THEN] Active Bank Accounts are created with correct settings
        BankAccount.SetRange("No.", MyBankStr1);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr1));

        BankAccount.SetRange("No.", MyBankStr2);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr2));

        BankAccount.SetRange("No.", MyBankStr3);
        Assert.IsFalse(BankAccount.FindFirst(), StrSubstNo(InvalidBankAccountMsg, MyBankStr3));

        BankAccount.SetRange("No.", MyBankStr4);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr4));

        BankAccount.SetRange("No.", MyBankStr5);
        Assert.IsTrue(BankAccount.FindFirst(), StrSubstNo(MissingBankAccountMsg, MyBankStr5));

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 13);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr1));
        Assert.RecordCount(BankAccountLedger, 0);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr2));
        Assert.RecordCount(BankAccountLedger, 2);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr3));
        Assert.RecordCount(BankAccountLedger, 0);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr4));
        Assert.RecordCount(BankAccountLedger, 4);

        BankAccountLedger.SetRange("Document No.", Format(525));
        BankAccountLedger.FindFirst();
        Assert.AreEqual(100.00, BankAccountLedger.Amount, 'Transfer amount is wrong for Trx 520, MyBank4');

        BankAccountLedger.Reset();
        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr5));
        Assert.RecordCount(BankAccountLedger, 7);

        BankAccountLedger.SetRange("Document No.", Format(520));
        BankAccountLedger.FindFirst();
        Assert.AreEqual(-100.00, BankAccountLedger.Amount, 'Transfer amount is wrong for Trx 520, MyBank5');

    end;

    local procedure ClearTables()
    begin
        BankAccount.DeleteAll();
        GPCheckbookMSTR.DeleteAll();
        GPCompanyMigrationSettings.DeleteAll();
        GPCompanyAdditionalSettings.DeleteAll();
        GPAccount.DeleteAll();
        GPCheckbookMSTR.DeleteAll();
        GPCheckbookTransactions.DeleteAll();
        GPCM20600.DeleteAll();
    end;

    local procedure Migrate()
    var
        GPCheckbookMigrator: Codeunit "GP Checkbook Migrator";
    begin
        GPAccount.FindSet();
        repeat
            MigrateGL(GPAccount);
        until GPAccount.Next() = 0;
        GPCheckbookMigrator.MoveCheckbookStagingData();
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

    local procedure CreateMoreCheckBookData()
    begin
        CreateCheckbookData();

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 600.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210807D;
        GPCheckbookTransactions.TRXAMNT := 700.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled1 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 610.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210808D;
        GPCheckbookTransactions.TRXAMNT := 1400.00;
        GPCheckbookTransactions.CMLinkID := '5000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled2 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 620.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210809D;
        GPCheckbookTransactions.TRXAMNT := 750.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled3 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 630.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210810D;
        GPCheckbookTransactions.TRXAMNT := 750.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Reconciled4 - Vendor Check';
        GPCheckbookTransactions.Recond := true;
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 640.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
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
        GPCheckbookMSTR.CHEKBKID := MyBankStr1;
        GPCheckbookMSTR.BNKACTNM := MyBankStr1;
        GPCheckbookMSTR.INACTIVE := true;
        GPCheckbookMSTR.ACTINDX := 0;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr2;
        GPCheckbookMSTR.BNKACTNM := MyBankStr2;
        GPCheckbookMSTR.INACTIVE := false;
        GPCheckbookMSTR.ACTINDX := 1;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr3;
        GPCheckbookMSTR.BNKACTNM := MyBankStr3;
        GPCheckbookMSTR.INACTIVE := true;
        GPCheckbookMSTR.ACTINDX := 2;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr4;
        GPCheckbookMSTR.BNKACTNM := MyBankStr4;
        GPCheckbookMSTR.INACTIVE := false;
        GPCheckbookMSTR.ACTINDX := 3;
        GPCheckbookMSTR.Insert(true);

        GPCheckbookMSTR.Reset();
        GPCheckbookMSTR.Init();
        GPCheckbookMSTR.CHEKBKID := MyBankStr5;
        GPCheckbookMSTR.BNKACTNM := MyBankStr5;
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
        GPCheckbookTransactions.CHEKBKID := MyBankStr1;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 395.59;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck1 - Vendor Check';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 120.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1;
        GPCheckbookTransactions.CMTrxType := 1;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 500.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Deposit1';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 125.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1;
        GPCheckbookTransactions.CMTrxType := 2;
        GPCheckbookTransactions.TRXDATE := 20210902D;
        GPCheckbookTransactions.TRXAMNT := 250.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Receipt1';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 130.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr1;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 650.00;
        GPCheckbookTransactions.CMLinkID := '2000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck2 - NonVendor Check';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 200.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 450.36;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck3 - Vendor Check';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 210.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr2;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 450.36;
        GPCheckbookTransactions.CMLinkID := '3000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck4 - NonVendor Check';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 400.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4;
        GPCheckbookTransactions.CMTrxType := 3;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'APCheck5 - Vendor Check';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 410.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4;
        GPCheckbookTransactions.CMTrxType := 4;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Withdrawl/Payroll Check1';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 500.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 2;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'Receipt2';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 505.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 5;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'IncreaseAdjustment1';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 510.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 6;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'DecreaseAdjustment1';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 520.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 100.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer1';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000001';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 525.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210801D;
        GPCheckbookTransactions.TRXAMNT := 100.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer1';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000001';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 530.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr4;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer2';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000002';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 535.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210802D;
        GPCheckbookTransactions.TRXAMNT := 200.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer2';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000002';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 540.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
        GPCheckbookTransactions.CMTrxType := 7;
        GPCheckbookTransactions.TRXDATE := 20210803D;
        GPCheckbookTransactions.TRXAMNT := 300.00;
        GPCheckbookTransactions.CMLinkID := '1000';
        GPCheckbookTransactions.DSCRIPTN := 'BankTransfer3';
        GPCheckbookTransactions.CMTrxNum := 'XFR000000003';
        GPCheckbookTransactions.Insert(true);

        GPCheckbookTransactions.Init();
        GPCheckbookTransactions.CMRECNUM := 545.00;
        GPCheckbookTransactions.CHEKBKID := MyBankStr5;
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
        GPCM20600.CMFRMCHKBKID := MyBankStr5;
        GPCM20600.CMCHKBKID := MyBankStr4;
        GPCM20600.Insert(true);

        GPCM20600.Init();
        GPCM20600.Xfr_Record_Number := 2.0;
        GPCM20600.CMXFRNUM := 'XFR000000002';
        GPCM20600.CMFRMRECNUM := 530;
        GPCM20600.CMTORECNUM := 535;
        GPCM20600.CMFRMCHKBKID := MyBankStr4;
        GPCM20600.CMCHKBKID := MyBankStr5;
        GPCM20600.Insert(true);

        GPCM20600.Init();
        GPCM20600.Xfr_Record_Number := 3.0;
        GPCM20600.CMXFRNUM := 'XFR000000003';
        GPCM20600.CMFRMRECNUM := 540;
        GPCM20600.CMTORECNUM := 545;
        GPCM20600.CMFRMCHKBKID := MyBankStr5;
        GPCM20600.CMCHKBKID := MyBankStr5;
        GPCM20600.Insert(true);
    end;

    local procedure CreateAccounts()
    begin
        GPAccount.Init();
        GPAccount.AcctNum := '100';
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
        GPAccount.AcctNum := '110';
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
        GPAccount.AcctNum := '120';
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
        GPAccount.AcctNum := '130';
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
        GPAccount.AcctNum := '140';
        GPAccount.AcctIndex := 4;
        GPAccount.Name := 'MISC';
        GPAccount.SearchName := 'MISC';
        GPAccount.AccountCategory := 1;
        GPAccount.DebitCredit := 1;
        GPAccount.IncomeBalance := false;
        GPAccount.Active := false;
        GPAccount.DirectPosting := true;
        GPAccount.AccountSubcategoryEntryNo := 1;
        GPAccount.Insert(true);
    end;

    local procedure CreateGenJournalTemplates()
    begin
        GenJournalTemplate.Reset();
        GenJournalTemplate.SetRange(Name, 'GENERAL');
        if not GenJournalTemplate.FindFirst then begin
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
        GPAccountMigrator.OnMigrateGlAccount(GLAccDataMigrationFacade, GPAccount.RecordId());
        GPAccountMigrator.OnMigrateAccountTransactions(GLAccDataMigrationFacade, GPAccount.RecordId());
    end;
}