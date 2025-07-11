codeunit 18996 "Voucher Interface Tests"
{
    Subtype = Test;

    [Test]
    procedure CreateVoucherSetupThroughCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355488] [Check if the system is allowing  to define No series and G/L accounts/Bank Account for each type of Voucher in Company Information]
        // [GIVEN] Create GLAccount/BankAccount for different Voucher Setup
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Receipt Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
    end;

    [Test]
    procedure CreateVoucherSetupThroughLocation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355489] [Check if the system is allowing  to define No series and G/L accounts/Bank Account for each type of Voucher in Location]
        // [GIVEN] Create GLAccount/BankAccount for different Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        StorageBoolean.Set('LocationSetup', true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Receipt Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        StorageBoolean.Remove('LocationSetup');
    end;

    [Test]
    procedure PostFromContraVoucherWithVoucherNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        Amount: Decimal;
    begin
        // [SCENARIO] [355496] [Check if the system is allowing the entering of narration for the total voucher while creating contra voucher.]
        // [FEATURE] [Voucher Interface] [Contra Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Contra Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Contra Voucher with Voucher Narration
        Amount := LibRandom.RandDec(100000, 2);
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"Bank Account", BankAccount."No.", Amount, WorkDate());
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", -Amount, WorkDate());
        LibraryVoucher.AssignVoucherNarration(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure CreateContraVoucherWithChequeDateAndChequeNumber()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
        Amount: Decimal;
    begin
        // [SCENARIO] [355498] [Check if the system is allowing the entering of cheque number and date while creating contra voucher.]
        // [FEATURE] [Voucher Interface] [Contra Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Contra Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Contra Voucher
        Amount := LibRandom.RandDec(100000, 2);
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"Bank Account", BankAccount."No.", Amount, WorkDate());
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", -Amount, WorkDate());

        // [THEN] Assigned Cheque No.
        LibraryVoucher.AssignChequeNo(GeneralJnlLine."Document No.");
    end;

    [Test]
    procedure PostFromMultiLineContraVoucherwithVoucherSetup()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        Amount: Decimal;
    begin
        // [SCENARIO] [355500] [Check if the system is creating correct GL entries after posting contra voucher.]
        // [FEATURE] [Voucher Interface] [Contra Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Contra Voucher", RecLocation.Code);

        // [WHEN] Created and Posted Multiline Contra Voucher
        Amount := LibRandom.RandDec(100000, 2);
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"Bank Account", BankAccount."No.", Amount, WorkDate());
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", -Amount, WorkDate());
        LibraryVoucher.AssignVoucherNarration(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure PostFromContraVoucherWithCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        Amount: Decimal;
    begin
        // [SCENARIO] [355521] [Check if the system consider no. series and GL/Bank Account related Information from the Company Information master if same information is blank in the location while posting Contra Voucher]
        // [FEATURE] [Voucher Interface] [Contra Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Contra Voucher", RecLocation.Code);

        // [WHEN] Created and Posted Multiline Contra Voucher
        Amount := LibRandom.RandDec(100000, 2);
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"Bank Account", BankAccount."No.", Amount, WorkDate());
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", -Amount, WorkDate());
        LibraryVoucher.AssignVoucherNarration(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure CreatedCashReceiptVoucherWithSpecificNoseries()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355444] [Check if the cash receipt voucher is "location" based with specific No. series.]
        // [FEATURE] [Voucher Interface] [Cash Receipt Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Receipt Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Receipt Voucher", RecLocation.Code);

        /// [WHEN] Created Cash Receipt Voucher
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", LibRandom.RandDec(100000, 2), WorkDate());

        // [THEN] Assert Error Verified
        Assert.AreEqual(GeneralJnlLine."Location Code", RecLocation.Code, 'Location are not equal');
    end;

    [Test]
    procedure CreateJournalVoucherWithSpecficNoSeries()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355501] [Check if the Journal voucher is location based with specific No. series.]
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);

        // [WHEN] Created Journal Voucher Line
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"G/L Account", GLAccount."No.", LibRandom.RandDec(100000, 2), WorkDate());

        // [THEN] Assert Error Verified
        Assert.AreEqual(GeneralJnlLine."Location Code", RecLocation.Code, LocationCompareErr);
    end;

    [Test]
    procedure PostFromMultiLineJournalVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [SCENARIO] [355510] [Check is the system is creating correct GL entries after posting journal voucher.]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);

        // [WHEN] Created and Posted Multiline Journal Voucher
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified      
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure PostFromMultiLineJournalVoucherNotAffectingCashandBankAccounts()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355502] [Check if the entries which are neither affecting cash accounts nor bank accounts can be entered through journal voucher.]
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Journal Voucher.
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure PostFromMultiLineJournalVoucherWithVoucherNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355504] [Check if the system is allowing the entering of narration for the total voucher while creating Journal voucher.]
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Journal Voucher with Voucher Narration
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryVoucher.AssignVoucherNarration(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure PostFromJournalVoucherWithVoucherNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [SCENARIO] [355505] [Check if the system is allowing the entering of narration in single or multiple lines while creating Journal voucher.
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Journal Voucher with Voucher Narration with different Posting Date.
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignVoucherNarration(DocumentNo);
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignVoucherNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CheckBankReceiptvVoucherWithsSecificNoseries()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355457] [Check if the Bank receipt voucher is location based with specific No. series.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created Bank Receipt Voucher
        CreateGenJnlLine(GeneralJnlLine, DummyGenJnlBatch.Name, GeneralJnlLine."Account Type"::"Bank Account", BankAccount."No.", LibRandom.RandDec(100000, 2), WorkDate());

        // [THEN] Assert Error Verified
        Assert.AreEqual(GeneralJnlLine."Location Code", RecLocation.Code, LocationCompareErr);
    end;

    [Test]
    procedure PostFromMultiLineJournalVoucherWithDifferentPostingDates()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355503] [Check if the system is allowing the entering of multiple lines while creating journal voucher with different posting dates.]
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Journal Voucher                                               
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", RecLocation.Code);
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        CreateMultiLinesJournalVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure PostFromMultiLineCashPaymentVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355452] [Check if the entries that are affecting only the Cash Accounts can be entered through the cash payment voucher.]
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Cash Payment Voucher                                              
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CashAccountInBankReceiptVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        Location: Record Location;
        GLAccount: Record "G/L Account";
        VoucherEnum: enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355518] [Check if the system is not allowing to enter Cash Account in Bank Receipt voucher.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        StorageEnum.Set('AccountType', format(GeneralJnlLine."Account Type"::"Bank Account"));

        CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Receipt Voucher");
        Storage.Set('TemplateName', GenJournalTemplate.Name);

        // [WHEN] Create and Post Bank Receipt Voucher for multiple lines
        LibraryERM.CreateGLAccount(GLAccount);

        // [WHEN] Execution of MultiLne Bank Receipt Voucher & Posted.                                                
        CreateGenJnlLine(
            GeneralJnlLine, GenJournalBatch.name, GeneralJnlLine."Account Type"::Customer, LibSales.CreateCustomerNo(),
            -LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
        GeneralJnlLine.Validate("Bal. Account No.", GLAccount."No.");
        GeneralJnlLine.Modify(true);
        asserterror LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] ExpectedError Verified
        Assert.ExpectedError(StrSubstNo(AccountTypeErr, GLAccount."No.", GeneralJnlLine."Document No."));
    end;

    [Test]
    procedure BankReceiptVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355458] [Check if the entries affecting only the Bank Accounts can be entered through the bank receipt voucher.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created and Posted Multiline Bank Receipt Voucher
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        LibraryVoucher.AssignChequeNo(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure ToCheckChequeNumberAndDateInBankReceiptVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355462] [Check if the system is allowing the entering of cheque number and date while creating bank receipt voucher.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Creation of Multiline Bank Receipt voucher & posted.
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");

        // [THEN] Assigned Cheque No.
        LibraryVoucher.AssignChequeNo(GeneralJnlLine."Document No.");
    end;

    [Test]
    procedure BankReceiptVoucherwithdifferentPostingDateVoucherNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [SCENARIO] [355459] [Check if the system is allowing the entering of multiple line while creating bank receipt voucher with different posting dates.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Receipt Voucher created with Voucher Narration & Cheque No  & Posted.
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo);
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CashPaymentVoucherMultiLineWithDifferentPostingDate()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [SCENARIO] [355453] [Check if the system is allowing the entering of multiple lines while creating cash payment voucher with different posting dates.]
        // [GIVEN] Create Location,G/L Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Cash Payment Voucher
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CheckIfSystemIsAllowingTotalVoucherInBankreceiptvoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [SCENARIO] [355460] [Check if the system is allowing the entering of narration for the total voucher while creating bank receipt voucher.]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Receipt Voucher created with Voucher Narration & Cheque No  & Posted
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo);
        LibraryVoucher.AssignVoucherNarration(DocumentNo);
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo2);
        LibraryVoucher.AssignVoucherNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure BankPaymentVoucherWithDebitAccount()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355520] [Check if the system is not allowing to enter Bank Account as Debit Amount in Bank Payment Voucher]
        // [FEATURE] [Voucher Interface] [Bank Payment Voucher]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Payment voucher with Cheque No & Voucher Narration & Posted
        CreateGenJnlLine(
            GeneralJnlLine, DummyGenJnlBatch.name, GeneralJnlLine."Account Type"::Customer, LibSales.CreateCustomerNo(),
            LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
        GeneralJnlLine.Validate("Bal. Account Type", GeneralJnlLine."Bal. Account Type"::"Bank Account");
        GeneralJnlLine.Validate("Bal. Account No.", BankAccount."No.");
        GeneralJnlLine.Modify(true);
        asserterror LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] Expected Error Verified
        Assert.ExpectedError(NegativeAmtErr);
    end;

    [Test]
    procedure CashPaymentVoucherWithDebitAccount()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [SCENARIO] [355515] [Check if the system is not allowing to enter Cash Account as Debit Amount in Cash Payment Voucher.]
        // [GIVEN] Create Location,G/L Account with Voucher Setup
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Craeted MultiLne Bank Payment Voucher with Cheque No & Voucher Narration & Posted
        CreateMultiLinesWrongVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        asserterror LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] Expected Assert Error Verified
        Assert.ExpectedError(PositiveAmtErr);
    end;

    [Test]
    procedure BankReceiptVoucherWithCreditAccount()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355517] [Check if the system is not allowing to enter Bank Account as Credit Amount in Bank Receipt Voucher.]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            '');
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Craeted MultiLne Bank Receipt voucherwith Credit Account & Posted
        CreateMultiLinesWrongVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        asserterror LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] Expected Assert Error Verified
        Assert.ExpectedError(NegativeAmtErr);
    end;

    [Test]
    procedure BankPaymentVoucherWithVoucherNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [SCENARIO] [355468] [Check if the system is allowing the entering of narration for the total voucher while creating bank payment voucher.]
        // [FEATURE] [Voucher Interface] [Bank Payment Voucher]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Craeted MultiLne Bank Payment voucher with Cheque No & Voucher Narration & Posted
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo);
        LibraryVoucher.AssignVoucherNarration(DocumentNo);
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo2);
        LibraryVoucher.AssignVoucherNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure BankPaymentVoucherWithChequeNumberAndChequeDate()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355470] [Check if the system is allowing the entering of cheque number and date while creating bank payment voucher.]
        // [FEATURE] [Voucher Interface] [Bank Payment Voucher]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Payment voucher with Cheque No & Voucher Narration & Posted
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";

        // [THEN] Cheque No. Assignment Verified
        LibraryVoucher.AssignChequeNo(DocumentNo);
    end;

    [Test]
    procedure BankPaymentVoucherWithLineNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [FEATURE] [Voucher Interface] [Bank Payment Voucher]
        // [SCENARIO] [355469] [Check if the system is allowing the entering of narration in single or multiple lines while creating bank payment voucher.]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Payment voucher with Cheque No & Line Voucher Narration & Posted
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo);
        LibraryVoucher.AssignLineNarration(DocumentNo);
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo2);
        LibraryVoucher.AssignLineNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CheckMultilineBankReceiptVoucherWithLineNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [SCENARIO] [355461] [Check if the system is allowing the entering of narration in single or multiple lines while creating bank receipt voucher.]
        // [GIVEN] Create Location,Bank Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Bank Receipt voucher with Cheque No & Line Voucher Narration & Posted
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo);
        LibraryVoucher.AssignLineNarration(DocumentNo);
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignChequeNo(DocumentNo2);
        LibraryVoucher.AssignLineNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CashPaymentVoucherMultiLineWithLineNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [SCENARIO] [355455] [Check if the system is allowing the entering of narration in single or multiple lines while creating cash payment voucher.]
        // [GIVEN] Create Location,G/L Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne cash payment voucher with Line Voucher Narration & Posted
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryVoucher.AssignLineNarration(GeneralJnlLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CashPaymentVoucherMultiLineWithDifferentPostingDateWithNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [SCENARIO] [355454] [Check if the system is allowing the entering of narration for the total voucher while creating cash payment voucher.]
        // [GIVEN] Create Location,G/L Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created MultiLne Cash Payment Voucher with Voucher Narration & Posted
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignVoucherNarration(DocumentNo);
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignVoucherNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure CashPaymentVoucherMultiLineWithDifferentPostingDateWithLineNarration()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
        DocumentNo, DocumentNo2 : Code[20];
    begin
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [SCENARIO] [355456] [Check if the system is creating correct GL entries after posting of cash payment voucher]
        // [GIVEN] Create Location,G/L Account with Voucher Setup
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLine Cash Payment Voucher with different posting dates.
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignLineNarration(DocumentNo);
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        DocumentNo2 := GeneralJnlLine."Document No.";
        LibraryVoucher.AssignLineNarration(DocumentNo2);
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 4);
    end;

    [Test]
    procedure ToCheckPagesofDifferentTypeofVoucher()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        GenJournalBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355511] [Check if the separate screens are open for different type of voucher (contra, cash, bank and Journal).]
        // [GIVEN] Create Location
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);

        // [WHEN] Creation of Cash Receipt Voucher
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Receipt Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Cash Receipt Voucher", RecLocation.Code);

        // [WHEN] Creation of Cash Payment Voucher
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Creation of Bank Payment Voucher
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Creation of Bank Receipt Voucher
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher", GeneralJnlLine."Account Type"::"Bank Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Creation of Contra Voucher
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Contra Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Contra Voucher", RecLocation.Code);

        // [WHEN] Creation of Journal Voucher
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher", GeneralJnlLine."Account Type"::"G/L Account", RecLocation.Code);
        CreatePaymentVoucherTemplate(GenJournalBatch, VoucherType::"Journal Voucher", RecLocation.Code);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure BankReceiptVocuherForGLEntries()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        BankAccNo: code[20];
    begin
        // [SCENARIO] [355463] Check if the system is creating correct GL entries after posting Bank receipt voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"Bank Account"));
        BankAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Receipt Voucher");

        // [WHEN] Created and Posted Bank Receipt Voucher for Multiple Lines
        LibraryVoucher.CreateGenJournalLineForBankToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, BankAccNo);
        LibraryVoucher.CreateGenJournalLineForBankToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, BankAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure CheckLocationCodeWithNoSeriesOnBankPaymentVoucher()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        BankAccNo: code[20];
    begin
        // [SCENARIO] [355465] Check if the Bank payment voucher is location based with specific No. series.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"Bank Account"));
        BankAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Payment Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Payment Voucher");

        // [WHEN] Created Bank Payment Voucher
        LibraryVoucher.CreateGenJournalLineForBankToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, BankAccNo);

        // [THEN] Location Code Verified
        Assert.IsSubstring(Location.Code, GenJournalLine."Location Code");
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure BankPaymentVoucherForGLEntries()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        BankAccNo: code[20];
    begin
        // [SCENARIO] [355466] Check if the entries affecting only the Bank Accounts can be entered through the bank payment voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"Bank Account"));
        BankAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Payment Voucher");

        // [WHEN] Created and Posted Bank Payment Voucher 
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Payment Voucher");
        LibraryVoucher.CreateGenJournalLineForVendorToBank(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, BankAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 2);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure BankPaymentVoucherWithDifferentPostingDates()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        BankAccNo: code[20];
    begin
        // [SCENARIO] [355467] Check if the system is allowing the entering of multiple line while creating bank payment voucher with different posting dates.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"Bank Account"));
        BankAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Payment Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Payment Voucher");

        // [WHEN] Created and Posted MultiLine Bank Payment Voucher with different posting dates
        LibraryVoucher.CreateGenJournalLineForVendorToBank(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, BankAccNo);
        InsertGenJnlCopy(GenJournalLine);
        LibraryVoucher.CreateGenJournalLineForVendorToBank(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, BankAccNo);
        GenJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));
        GenJournalLine.Modify(true);
        InsertGenJnlCopy(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries verified 
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
        VerifyGLEntryForDifferentPostingDates(GenJournalTemplate.Name, GenJournalBatch.Name);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure BankPaymentVoucherWithCorrectGLEntries()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        BankAccNo: code[20];
    begin
        // [SCENARIO] [355471] Check if the system is creating correct GL entries after posting Bank payment voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"Bank Account"));
        BankAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Bank Payment Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Bank Payment Voucher");

        // [WHEN] Created and Posted Bank Payment Voucher for multiple lines
        LibraryVoucher.CreateGenJournalLineForVendorToBank(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, BankAccNo);
        LibraryVoucher.CreateGenJournalLineForVendorToBank(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, BankAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
    End;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure CheckLocationCodeWithNoSeriesOnContraVoucher()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: Code[20];
    begin
        // [SCENARIO] [355490] Check if the Contra voucher is location based with specific No. series.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Contra Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Contra Voucher");

        // [WHEN] Created Contra Voucher
        LibraryVoucher.CreateGenJournalLineForGLAccount(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);

        // [THEN] Check Location on Contra Voucher
        Assert.IsSubstring(Location.Code, GenJournalLine."Location Code");
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure ContraVoucherWithDifferentPostingDates()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: code[20];
    begin
        // [SCENARIO] [355492] Check if the system is allowing the entering of multiple lines while creating contra voucher with different posting dates.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Contra Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Contra Voucher");

        // [WHEN] Created and Posted Contra Voucher with different posting dates
        LibraryVoucher.CreateGenJournalLineForGLAccount(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        GenJournalLine.Validate("Posting Date", WorkDate());
        GenJournalLine.Modify(true);
        InsertGenJnlCopy(GenJournalLine);
        LibraryVoucher.CreateGenJournalLineForGLAccount(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        GenJournalLine.Validate("Posting Date", CalcDate('<-1D>', WorkDate()));
        GenJournalLine.Modify(true);
        InsertGenJnlCopy(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
        VerifyGLEntryForDifferentPostingdates(GenJournalTemplate.Name, GenJournalBatch.Name);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountCredit')]
    procedure ContraVoucherWithCashAndBankAccount()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: Code[20];
    begin
        // [SCENARIO] [355491] Check if the entries affecting only the Cash Accounts and Bank accounts between them selves can be entered through the contra voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Contra Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Contra Voucher");

        // [WHEN] Created and Posted Cotra Voucher for Multiple Lines
        LibraryVoucher.CreateGenJournalLineForGLAccount(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        LibraryVoucher.CreateGenJournalLineForGLAccount(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
    end;

    [Test]
    procedure CashReceiptVoucherUsingCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355512] [Check if the system consider no. series and GL Account related Information from the Company Information master if same information is blank in the location while posting Cash Receipt Voucher]
        // [FEATURE] [Voucher Interface] [Cash Receipt Voucher]
        // [GIVEN] Created G/L Account and Voucher Setup Using Company Information
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Receipt Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Receipt Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Cash Receipt Voucher                                               
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [Then] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure BankReceiptVoucherUsingCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355516] [Check if the system consider no. series and Bank Account related Information from the Company Information master if same information is blank in the location while posting Bank Receipt Voucher]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Created G/L Account and Voucher Setup Using Company Information
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Receipt Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Receipt Voucher", RecLocation.Code);

        // [WHEN] Created and  MultiLne Bank Receipt Voucher                                                 
        CreateMultiLinesinVoucherForCustomer(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure BankPaymentVoucherUsingCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        BankAccount: Record "Bank Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355519] [Check if the system consider no. series and Bank Account related Information from the Company Information master if same information is blank in the location while posting Bank Payment Voucher]
        // [FEATURE] [Voucher Interface] [Bank Receipt Voucher]
        // [GIVEN] Create G/L Account & Voucher Setup Using Company Information
        CreateBankAccountWithVoucherAcc(BankAccount, VoucherType::"Bank Payment Voucher",
            GeneralJnlLine."Account Type"::"Bank Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Bank Payment Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Bank Receipt Voucher                                              
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, BankAccount."No.", GeneralJnlLine."Account Type"::"Bank Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    procedure CashPaymentVoucherUsingCompanyInformation()
    var
        GeneralJnlLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        RecLocation: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [355513] [Check if the system consider no. series and GL Account related Information from the Company Information master if same information is blank in the location while posting Cash Payment Voucher]
        // [FEATURE] [Voucher Interface] [Cash Payment Voucher]
        // [GIVEN] Create G/L Account & Voucher Setup Using Company Information
        LibInventory.CreateLocationWMS(RecLocation, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Cash Payment Voucher",
            GeneralJnlLine."Account Type"::"G/L Account",
            RecLocation.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Cash Payment Voucher", RecLocation.Code);

        // [WHEN] Created and Posted MultiLne Cash Payment Voucher                                               
        CreateMultiLinesinVoucherForVendor(GeneralJnlLine, DummyGenJnlBatch.Name, GLAccount."No.", GeneralJnlLine."Account Type"::"G/L Account");
        LibraryERM.PostGeneralJnlLine(GeneralJnlLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 2);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CashReceiptVoucherWithCorrectGLEntries()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: code[20];
    begin
        // [SCENARIO] [355445] Check if the entries that are affecting only the Cash Accounts can be entered through the cash receipt voucher.
        // [SCENARIO] [355450] Check if the system is creating correct GL entries after posting of cash receipt voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Cash Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Cash Receipt Voucher");

        // [WHEN] Created and Posted Cash Receipt Voucher
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 2);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CashReceiptVoucherWithDifferentPostingDate()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: code[20];
    begin
        // [SCENARIO] [355446] Check if the system is allowing the entering of multiple lines while creating cash receipt voucher with different posting dates.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Cash Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Cash Receipt Voucher");

        // [WHEN] Created and Posted Cash Receipt Voucher for different posting dates
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        InsertGenJnlCopy(GenJournalLine);
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        GenJournalLine.Validate("Posting Date", CalcDate('<-CM>', WorkDate()));
        GenJournalLine.Modify(true);
        InsertGenJnlCopy(GenJournalLine);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 4);
        VerifyGLEntryForDifferentPostingDates(GenJournalTemplate.Name, GenJournalBatch.Name);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CashReceiptVoucherWithNarration()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355447] Check if the system is allowing the entering of narration for the total voucher while creating cash receipt voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Cash Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Cash Receipt Voucher");

        // [WHEN] Created and Posted Cash Receipt Voucher
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);
        LibraryVoucher.AssignVoucherNarration(GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        DocumentNo := LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 2);
        CheckPostedNarration(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CashReceiptVoucherWithLineNarration()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: code[20];
        DocumentNo: Code[20];
    begin
        // [SCENARIO] [355448] Check if the system is allowing the entering of narration in single or multiple lines while creating cash receipt voucher.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Cash Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Cash Receipt Voucher");

        // [WHEN] Created and Posted Cash Receipt Voucher
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, true, GLAccNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/LEntries Verified
        DocumentNo := LibraryVoucher.VerifyVoucherGLEntryCount(GenJournalBatch.Name, 2);
        CheckPostedNarration(DocumentNo);
    end;

    [Test]
    [HandlerFunctions('VoucherAccountDebit')]
    procedure CheckLocationCodeWithNoSeriesOnCashReceiptVoucher()
    var
        Location: Record Location;
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        VoucherEnum: Enum "Gen. Journal Template Type";
        GLAccNo: Code[20];
    begin
        // [SCENARIO] [355451] Check if the cash payment voucher is location based with specific No. series.
        // [GIVEN] Create Setup for Location, Template and Batch
        StorageEnum.Set('AccountType', format(GenJournalLine."Account Type"::"G/L Account"));
        GLAccNo := CreateLocationWithVoucherSetup(Location, VoucherEnum::"Cash Receipt Voucher");
        CreateGenJnlTemplateAndBatch(GenJournalTemplate, GenJournalBatch, Location.Code, VoucherEnum::"Cash Receipt Voucher");

        // [WHEN] Created Contra Voucher
        LibraryVoucher.CreateGenJournalLineForGLToCustomer(GenJournalLine, GenJournalTemplate, GenJournalBatch, false, GLAccNo);

        // [THEN] Location Code Verified on Contra Voucher
        Assert.IsSubstring(Location.Code, GenJournalLine."Location Code");
    end;

    [Test]
    procedure PostFromJournalVoucherWithMultiLines()
    var
        GenJournalLine: Record "Gen. Journal Line";
        DummyGenJnlBatch: Record "Gen. Journal Batch";
        Location: Record Location;
        GLAccount: Record "G/L Account";
        VoucherType: Enum "Gen. Journal Template Type";
    begin
        // [SCENARIO] [468119] [[Performance] [Production] Performance delay in Journal Voucher]
        // [FEATURE] [Voucher Interface] [Journal Voucher]
        // [GIVEN] Create Location,Bank Account,GLAccount with Voucher Setup
        LibInventory.CreateLocationWMS(Location, false, false, false, false, true);
        CreateGLAccountWithVoucherAcc(GLAccount, VoucherType::"Journal Voucher", GenJournalLine."Account Type"::"G/L Account", Location.Code);
        CreatePaymentVoucherTemplate(DummyGenJnlBatch, VoucherType::"Journal Voucher", Location.Code);

        // [WHEN] Created and Posted MultiLne Journal Voucher with Voucher Narration
        CreateMultiLinesJournalVoucher(GenJournalLine, DummyGenJnlBatch.Name, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account");
        LibraryVoucher.AssignVoucherNarration(GenJournalLine."Document No.");
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] G/L Entries Verified
        LibraryVoucher.VerifyVoucherGLEntryCount(DummyGenJnlBatch.Name, 200);
    end;

    local procedure CheckPostedNarration(DocumentNo: Code[20])
    var
        PostedNarration: Record "Posted Narration";
    begin
        PostedNarration.SetRange("Document No.", DocumentNo);
        PostedNarration.FindFirst();
        Assert.RecordIsNotEmpty(PostedNarration);
    end;

    local procedure VerifyGLEntryForDifferentPostingDates(JournalTemplateName: Code[10]; JournaBatchName: code[10])
    var
        GenJournalLineCopy: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        Record: Variant;
    begin
        LibVarStorage.Dequeue(Record);
        GenJournalLineCopy := Record;
        GenJournalLineCopy.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLineCopy.SetRange("Journal Batch Name", JournaBatchName);
        if not GenJournalLineCopy.IsEmpty() then
            repeat
                GLEntry.SetRange("External Document No.", GenJournalLineCopy."Document No.");
                GLEntry.FindFirst();
                Assert.IsSubstring(format(GenJournalLineCopy."Posting Date"), format(GLEntry."Posting Date"));
            until GenJournalLineCopy.Next() = 0;
    end;

    local procedure CreateGLAccountWithVoucherAcc(VAR GLAccount: Record "G/L Account";
        Type: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
        LocationCode: Code[10])
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        CreateVoucherAccount(GLAccount."No.", AccountType, Type, FORMAT(Type), LocationCode);
        GLAccount.SetRange("No.", GLAccount."No.");
        GLAccount.SetFilter("Date Filter", '%1..%2', CalcDate('< -1M >', WorkDate()), CalcDate('< +1Y >', WorkDate()));
        GLAccount.FindFirst();
    end;

    local procedure CreateBankAccountWithVoucherAcc(VAR BankAccount: Record "Bank Account";
        Type: Enum "Gen. Journal Template Type";
        AccountType: Enum "Gen. Journal Account Type";
        LocationCode: Code[10])
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        CreateVoucherAccount(BankAccount."No.", AccountType, Type, FORMAT(Type), LocationCode);
    end;

    Local procedure CreateVoucherAccount(AccountNo: Code[20];
        AccType: Enum "Gen. Journal Account Type";
        SubType: Enum "Gen. Journal Template Type";
        TaxtType: Text;
        LocationCode: Code[10])
    var
        VoucherCrAccount: Record "Voucher Posting Credit Account";
        VoucherDrAccount: Record "Voucher Posting Debit Account";
        CompanyInformationPage: TestPage "Company Information";
        LocationCard: TestPage "Location Card";
        VoucherSetupPage: TestPage "Journal Voucher Posting Setup";
    begin
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher":
                begin
                    VoucherCrAccount.Init();
                    VoucherCrAccount.Validate("Location code", LocationCode);
                    VoucherCrAccount.Validate(Type, SubType);
                    VoucherCrAccount.Validate("Account Type", AccType);
                    VoucherCrAccount.Validate("Account No.", AccountNo);
                    VoucherCrAccount.Insert();
                end;
            SubType::"Bank Receipt Voucher", SubType::"Cash Receipt Voucher":
                begin
                    VoucherDrAccount.Init();
                    VoucherDrAccount.Validate("Location code", LocationCode);
                    VoucherDrAccount.Validate(Type, SubType);
                    VoucherDrAccount.Validate("Account Type", AccType);
                    VoucherDrAccount.Validate("Account No.", AccountNo);
                    VoucherDrAccount.Insert();
                end;
            else begin
                VoucherDrAccount.Init();
                VoucherDrAccount.Validate("Location code", LocationCode);
                VoucherDrAccount.Validate(Type, SubType);
                VoucherDrAccount.Validate("Account Type", AccType);
                VoucherDrAccount.Validate("Account No.", AccountNo);
                VoucherDrAccount.Insert();
            end;
        end;
        CreateNoSeries();
        if StorageBoolean.ContainsKey('LocationSetup') then begin
            LocationCard.OpenEdit();
            LocationCard.GoToKey(LocationCode);
            VoucherSetupPage.Trap();
            LocationCard."Voucher Setup".Invoke();
            VoucherSetupPage.Filter.SetFilter(Type, TaxtType);
            VoucherSetupPage.Filter.SetFilter("Location Code", LocationCode);
            VoucherSetupPage."Posting No. Series".SetValue(Storage.Get('Noseries'));
        end else begin
            CompanyInformationPage.OpenEdit();
            VoucherSetupPage.Trap();
            CompanyInformationPage."Journal Voucher Posting Setup".Invoke();
            VoucherSetupPage.Filter.SetFilter(Type, TaxtType);
            VoucherSetupPage.Filter.SetFilter("Location Code", LocationCode);
            VoucherSetupPage."Posting No. Series".SetValue(Storage.Get('Noseries'));
        end;
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher":
                VoucherSetupPage."Credit Account".Invoke();
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher":
                VoucherSetupPage."Debit Account".Invoke();
        end;
    end;

    local procedure CreateNoSeries(): Code[20]
    var
        Noseries: Code[20];
    begin
        if not Storage.ContainsKey('Noseries') then begin
            Noseries := LibraryERM.CreateNoSeriesCode();
            Storage.Set('Noseries', Noseries);
            exit(Noseries);
        end;
    end;

    local procedure CreatePaymentVoucherTemplate(VAR GenJournalBatch: Record "Gen. Journal Batch"; Type:
        Enum "Gen. Journal Template Type";
        LocationCode: Code[10])
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Modify();
        Storage.Set('TemplateName', GenJournalTemplate.Name);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Modify();
    end;

    local procedure CreateMultiLinesinVoucherForVendor(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, -LibRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Vendor, LibPurchase.CreateVendorNo(),
            LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateMultiLinesWrongVoucherForVendor(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, LibRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Vendor, LibPurchase.CreateVendorNo(),
            -LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateMultiLinesWrongVoucherForCustomer(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, -LibRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Customer, LibSales.CreateCustomerNo(),
            LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateMultiLinesJournalVoucherForVendor(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateJournalVoucherLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, LibRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateJournalVoucherLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Vendor, LibPurchase.CreateVendorNo(),
            -LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateMultiLinesJournalVoucher(VAR GenJournalLine: Record "Gen. Journal Line";
       GenJnlBatchName: Code[10];
       AccountNo: Code[20];
       AccountType: Enum "Gen. Journal Account Type")
    var
        Counter: Integer;
        NoOfLines: Integer;
    begin
        NoOfLines := 100;
        for Counter := 1 to NoOfLines do begin
            CreateJournalVoucherLine(
                GenJournalLine, GenJnlBatchName, AccountType, AccountNo, LibRandom.RandDecInDecimalRange(10000, 6000, 2),
                CalcDate('<-CM>', WorkDate()));
            CreateJournalVoucherLine(
                GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Vendor, LibPurchase.CreateVendorNo(),
                -LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
        end;

    end;

    local procedure CreateMultiLinesinVoucherForCustomer(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type")
    begin
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, AccountType, AccountNo, LibRandom.RandDecInDecimalRange(10000, 6000, 2),
            CalcDate('<-CM>', WorkDate()));
        CreateGenJnlLine(
            GenJournalLine, GenJnlBatchName, GenJournalLine."Account Type"::Customer, LibSales.CreateCustomerNo(),
            -LibRandom.RandDecInDecimalRange(10000, 6000, 2), CalcDate('<-CM>', WorkDate()));
    end;

    local procedure CreateGenJnlLine(VAR GenJournalLine: Record "Gen. Journal Line"; GenJnlBatchName: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
        AccountNo: Code[20];
        Amount: Decimal;
        PostingDate: Date): Code[20]
    var
        TemplateName: Code[10];
    begin
        TemplateName := CopyStr(Storage.Get('TemplateName'), 1, 10);
        LibraryERM.CreateGeneralJnlLine2(GenJournalLine, TemplateName, GenJnlBatchName, GenJournalLine."Document Type"::Payment,
        AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify();
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateJournalVoucherLine(VAR GenJournalLine: Record "Gen. Journal Line";
        GenJnlBatchName: Code[10];
        AccountType: Enum "Gen. Journal Account Type";
        AccountNo: Code[20];
        Amount: Decimal;
        PostingDate: Date): Code[20]
    var
        TemplateName: Code[10];
    begin
        TemplateName := CopyStr(Storage.Get('TemplateName'), 1, 10);
        LibraryERM.CreateGeneralJnlLine2(GenJournalLine, TemplateName, GenJnlBatchName, GenJournalLine."Document Type"::Invoice,
        AccountType, AccountNo, Amount);
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify();
        exit(GenJournalLine."Document No.");
    end;

    local procedure CreateGenJnlTemplateAndBatch(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        LocationCode: code[20];
        VoucherType: enum "Gen. Journal Template Type");
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, VoucherType);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("Location Code", LocationCode);
        GenJournalBatch.Validate("Posting No. Series", Storage.Get('Noseries'));
        GenJournalBatch.Modify(true);
    end;

    local procedure CreateLocationWithVoucherSetup(
        var Location: Record Location;
        Type: Enum "Gen. Journal Template Type"): Code[20]
    var
        BankAccount: Record "Bank Account";
        GLAccount: Record "G/L Account";
        LibraryWarehouse: Codeunit "Library - Warehouse";
    begin
        CreateNoSeries();
        LibraryWarehouse.CreateLocationWithInventoryPostingSetup(Location);
        case Type of
            Type::"Bank Payment Voucher", Type::"Bank Receipt Voucher":
                begin
                    LibraryERM.CreateBankAccount(BankAccount);
                    LibVarStorage.Clear();
                    LibVarStorage.Enqueue(BankAccount."No.");
                    CreateVoucherAccountSetup(Type, Location.Code);
                    exit(BankAccount."No.");
                end;
            type::"Contra Voucher", type::"Cash Receipt Voucher":
                begin
                    LibraryERM.CreateGLAccount(GLAccount);
                    LibVarStorage.Clear();
                    LibVarStorage.Enqueue(GLAccount."No.");
                    CreateVoucherAccountSetup(Type, Location.Code);
                    exit(GLAccount."No.");
                end;
        end;
    end;

    local procedure CreateVoucherAccountSetup(
        SubType: Enum "Gen. Journal Template Type";
        LocationCode: Code[10])
    var
        VoucherSetupPage: TestPage "Journal Voucher Posting Setup";
        LocationCard: TestPage "Location Card";
    begin
        LocationCard.OpenEdit();
        LocationCard.GoToKey(LocationCode);
        VoucherSetupPage.Trap();
        LocationCard."Voucher Setup".Invoke();
        VoucherSetupPage.Filter.SetFilter(Type, Format(SubType));
        VoucherSetupPage.Filter.SetFilter("Location Code", LocationCode);
        VoucherSetupPage."Posting No. Series".SetValue(Storage.Get('Noseries'));
        case SubType of
            SubType::"Bank Payment Voucher", SubType::"Cash Payment Voucher", SubType::"Contra Voucher":
                begin
                    VoucherSetupPage."Transaction Direction".SetValue('Credit');
                    VoucherSetupPage."Credit Account".Invoke();
                end;
            SubType::"Cash Receipt Voucher", SubType::"Bank Receipt Voucher":
                begin
                    VoucherSetupPage."Transaction Direction".SetValue('Debit');
                    VoucherSetupPage."Debit Account".Invoke();
                end;
        end;
    end;

    [PageHandler]
    procedure VoucherAccountCredit(var VoucherCrAccount: TestPage "Voucher Posting Credit Account");
    var
        Value: Variant;
        AccountNo: Code[20];
        AccountType: Enum "Gen. Journal Account Type";
    begin
        LibVarStorage.Dequeue(Value);
        AccountNo := Value;
        Evaluate(AccountType, StorageEnum.Get('AccountType'));
        VoucherCrAccount.Type.SetValue(AccountType);
        VoucherCrAccount."Account No.".SetValue(AccountNo);
    end;

    [PageHandler]
    procedure VoucherAccountDebit(var VoucherDrAccount: TestPage "Voucher Posting Debit Accounts");
    var
        AccountNo: Variant;
        AccountType: Enum "Gen. Journal Account Type";
    begin
        LibVarStorage.Dequeue(AccountNo);
        Evaluate(AccountType, StorageEnum.Get('AccountType'));
        VoucherDrAccount.Type.SetValue(AccountType);
        VoucherDrAccount."Account No.".SetValue(AccountNo);
    end;

    local procedure InsertGenJnlCopy(var GenJournalLine: Record "Gen. Journal Line");
    var
        TempGenJournalLineCopy: Record "Gen. Journal Line" temporary;
    begin
        TempGenJournalLineCopy.Init();
        TempGenJournalLineCopy.TransferFields(GenJournalLine);
        TempGenJournalLineCopy.Insert();
        LibVarStorage.Clear();
        LibVarStorage.Enqueue(TempGenJournalLineCopy);
    end;

    var
        LibInventory: Codeunit "Library - Warehouse";
        LibraryERM: Codeunit "Library - ERM";
        LibRandom: Codeunit "Library - Random";
        LibPurchase: Codeunit "Library - Purchase";
        LibVarStorage: Codeunit "Library - Variable Storage";
        Assert: Codeunit Assert;
        LibSales: Codeunit "Library - Sales";
        LibraryVoucher: Codeunit "Library Voucher Interface";
        Storage: Dictionary of [Text, Code[20]];
        StorageBoolean: Dictionary of [Text, Boolean];
        StorageEnum: Dictionary of [Text, Text];
        NegativeAmtErr: Label 'must be negative';
        LocationCompareErr: Label 'Location are not equal';
        PositiveAmtErr: Label 'must be positive';
        AccountTypeErr: Label 'Account No. %1 is not defined as Debit account for the Voucher Sub Type Bank Receipt Voucher and Document No. %2.', Comment = '%1 =Account No., %2= Document No.';
}