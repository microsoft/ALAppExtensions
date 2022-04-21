codeunit 139700 "GP Checkbook Tests"
{
    // [FEATURE] [GP Data Migration]

    EventSubscriberInstance = Manual;
    Subtype = Test;
    Permissions = tableData "Bank Account Ledger Entry" = rimd;
    TestPermissions = Disabled;

    var
        Assert: Codeunit Assert;
        GPAccount: Record "GP Account";
        GPCheckbookMSTRTable: Record "GP Checkbook MSTR";
        Vendor: Record Vendor;
        MSFTCM20200Table: Record MSFTCM20200;
        GPCompanyMigrationSettings: Record "GP Company Migration Settings";
        GPCompanyAdditionalSettings: Record "GP Company Additional Settings";
        VendorPostingGroup: Record "Vendor Posting Group";
        BankAccount: Record "Bank Account";
        GenJournalTemplate: Record "Gen. Journal Template";
        InvalidBankAccountMsg: Label '%1 should not have been created.', Comment = '%1 - bank account no.', Locked = true;
        MissingBankAccountMsg: Label '%1 should have been created.', Comment = '%1 - bank account no.', Locked = true;
        MyBankStr1: Label 'MyBank01', Comment = 'Bank name', Locked = true;
        MyBankStr2: Label 'MyBank02', Comment = 'Bank name', Locked = true;
        MyBankStr3: Label 'MyBank03', Comment = 'Bank name', Locked = true;
        MyBankStr4: Label 'MyBank04', Comment = 'Bank name', Locked = true;
        MyBankStr5: Label 'MyBank05', Comment = 'Bank name', Locked = true;
        GPBankAccountPostingGroupLbl: Label 'GPBANKGROUP', Comment = 'Posting Group name', Locked = true;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationIncludeInactive()
    var
        BankAccount: Record "Bank Account";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountLedger: Record "Bank Account Ledger Entry";
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

        // [GIVEN] Inactive checkbooks are to be migrated
        ConfigureMigrationSettings(true);

        // [WHEN] Checkbook migration code is called
        Migrate();

        // [THEN] Bank Accounts are created
        Assert.RecordCount(BankAccount, 5);

        // [THEN] General Journal Lines are created
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'CASHRCPT');
        Assert.RecordCount(GenJournalLine, 3);

        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'PAYMENT');
        Assert.RecordCount(GenJournalLine, 5);

        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 4);

        // [WHEN] Batches are posted.
        HelperFunctions.PostGLTransactions();

        // [THEN] Bank Account Ledger entries are created
        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr1));
        Assert.RecordCount(BankAccountLedger, 4);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr2));
        Assert.RecordCount(BankAccountLedger, 2);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr3));
        Assert.RecordCount(BankAccountLedger, 0);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr4));
        Assert.RecordCount(BankAccountLedger, 2);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr5));
        Assert.RecordCount(BankAccountLedger, 4);
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoCommit)]
    procedure TestGPCheckbookMigrationExcludeInactive()
    var
        BankAccount: Record "Bank Account";
        BankAccountLedger: Record "Bank Account Ledger Entry";
        GenJournalLine: Record "Gen. Journal Line";
        HelperFunctions: Codeunit "Helper Functions";
        test: Code[2];
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
        GenJournalLine.SetFilter("Journal Template Name", 'CASHRCPT');
        Assert.RecordCount(GenJournalLine, 1);

        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'PAYMENT');
        Assert.RecordCount(GenJournalLine, 3);

        GenJournalLine.Reset();
        GenJournalLine.SetFilter("Journal Batch Name", 'GPBANK');
        GenJournalLine.SetFilter("Journal Template Name", 'GENERAL');
        Assert.RecordCount(GenJournalLine, 4);

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
        Assert.RecordCount(BankAccountLedger, 2);

        BankAccountLedger.SetRange("Bank Account No.", UpperCase(MyBankStr5));
        Assert.RecordCount(BankAccountLedger, 4);
    end;

    local procedure ClearTables()
    begin
        BankAccount.DeleteAll();
        GPCheckbookMSTRTable.DeleteAll();
        GPCompanyMigrationSettings.DeleteAll();
        GPCompanyAdditionalSettings.DeleteAll();
        GPAccount.DeleteAll();
        GPCheckbookMSTRTable.DeleteAll();
        MSFTCM20200Table.DeleteAll();
    end;

    local procedure Migrate()
    begin
        GPAccount.FindSet();
        repeat
            MigrateGL(GPAccount);
        until GPAccount.Next() = 0;
        CreateVendor();
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
        CreateGenJournalTemplates();
        CreateAccounts();

        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr1;
        GPCheckbookMSTRTable.BNKACTNM := MyBankStr1;
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.ACTINDX := 0;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr2;
        GPCheckbookMSTRTable.BNKACTNM := MyBankStr2;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.ACTINDX := 1;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr3;
        GPCheckbookMSTRTable.BNKACTNM := MyBankStr3;
        GPCheckbookMSTRTable.INACTIVE := true;
        GPCheckbookMSTRTable.ACTINDX := 2;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr4;
        GPCheckbookMSTRTable.BNKACTNM := MyBankStr4;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.ACTINDX := 3;
        GPCheckbookMSTRTable.Insert(true);

        GPCheckbookMSTRTable.Reset();
        GPCheckbookMSTRTable.Init();
        GPCheckbookMSTRTable.CHEKBKID := MyBankStr5;
        GPCheckbookMSTRTable.BNKACTNM := MyBankStr5;
        GPCheckbookMSTRTable.INACTIVE := false;
        GPCheckbookMSTRTable.ACTINDX := 4;
        GPCheckbookMSTRTable.Insert(true);

        // Transactions
        ///   CMTrxType = 
        ///        1        2        3                  4                    5                  6                  7
        ///     Deposit, Receipt, APCheck, "Withdrawl/Payroll Check", IncreaseAdjustment, DecreaseAdjustment, BankTransfer;
        /// 
        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 100.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr1;
        MSFTCM20200Table.CMTrxType := 3;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 395.59;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'APCheck1 - Vendor Check';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 120.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr1;
        MSFTCM20200Table.CMTrxType := 1;
        MSFTCM20200Table.TRXDATE := 20210802D;
        MSFTCM20200Table.TRXAMNT := 500.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'Deposit1';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 125.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr1;
        MSFTCM20200Table.CMTrxType := 2;
        MSFTCM20200Table.TRXDATE := 20210902D;
        MSFTCM20200Table.TRXAMNT := 250.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'Receipt1';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 130.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr1;
        MSFTCM20200Table.CMTrxType := 3;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 650.00;
        MSFTCM20200Table.CMLinkID := '2000';
        MSFTCM20200Table.DSCRIPTN := 'APCheck2 - NonVendor Check';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 200.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr2;
        MSFTCM20200Table.CMTrxType := 3;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 450.36;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'APCheck3 - Vendor Check';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 210.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr2;
        MSFTCM20200Table.CMTrxType := 3;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 450.36;
        MSFTCM20200Table.CMLinkID := '3000';
        MSFTCM20200Table.DSCRIPTN := 'APCheck4 - NonVendor Check';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 400.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr4;
        MSFTCM20200Table.CMTrxType := 3;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'APCheck5 - Vendor Check';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 410.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr4;
        MSFTCM20200Table.CMTrxType := 4;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'Withdrawl/Payroll Check1';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 500.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr5;
        MSFTCM20200Table.CMTrxType := 2;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'Receipt2';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 505.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr5;
        MSFTCM20200Table.CMTrxType := 5;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'IncreaseAdjustment1';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 510.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr5;
        MSFTCM20200Table.CMTrxType := 6;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'DecreaseAdjustment1';
        MSFTCM20200Table.Insert(true);

        MSFTCM20200Table.Init();
        MSFTCM20200Table.CMRECNUM := 520.00;
        MSFTCM20200Table.CHEKBKID := MyBankStr5;
        MSFTCM20200Table.CMTrxType := 7;
        MSFTCM20200Table.TRXDATE := 20210801D;
        MSFTCM20200Table.TRXAMNT := 200.00;
        MSFTCM20200Table.CMLinkID := '1000';
        MSFTCM20200Table.DSCRIPTN := 'BankTransfer1';
        MSFTCM20200Table.Insert(true);
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
        GenJournalTemplate.SetRange(Name, 'CASHRCPT');
        if not GenJournalTemplate.FindFirst then begin
            GenJournalTemplate.Init();
            GenJournalTemplate.Validate(Name, 'CASHRCPT');
            GenJournalTemplate.Validate(Description, 'Cash receipts');
            GenJournalTemplate.Validate("Source Code", 'CASHRECJNL');
            GenJournalTemplate.Validate("No. Series", 'GJNL-RCPT');
            GenJournalTemplate.Insert(true);
        end;

        GenJournalTemplate.Reset();
        GenJournalTemplate.SetRange(Name, 'PAYMENT');
        if not GenJournalTemplate.FindFirst then begin
            GenJournalTemplate.Init();
            GenJournalTemplate.Validate(Name, 'PAYMENT');
            GenJournalTemplate.Validate(Description, 'Payments');
            GenJournalTemplate.Validate("Source Code", 'PAYMENTJNL');
            GenJournalTemplate.Validate("No. Series", 'GJNL-PMT');
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

    local procedure CreateVendor()
    begin
        if not Vendor.Get('1000') then begin
            Vendor.Init();
            Vendor.Validate("No.", '1000');
            Vendor.Validate(Name, 'Test Vendor');
            Vendor.Validate("Vendor Posting Group", CreateVendorPostingGroup());
            Vendor.Insert(true);
        end;
    end;

    local procedure CreateVendorPostingGroup(): Code[20]
    begin
        if not VendorPostingGroup.Get('GPVEND') then begin
            VendorPostingGroup.Init();
            VendorPostingGroup.Validate(Code, 'GPVEND');
            VendorPostingGroup.Validate("Payables Account", '140');
            VendorPostingGroup.Insert(true);
        end;

        exit(VendorPostingGroup.Code);
    end;
}