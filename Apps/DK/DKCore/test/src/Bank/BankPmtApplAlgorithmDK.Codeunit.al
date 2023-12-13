codeunit 134270 "Bank Pmt. Appl. Algorithm DK"
{
    Permissions = TableData "Cust. Ledger Entry" = imd,
                  TableData "Vendor Ledger Entry" = imd,
                  TableData "Bank Account Ledger Entry" = imd;
    Subtype = Test;
    TestPermissions = NonRestrictive;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Payment Application] [Match]
    end;

    var
        TempBankStatementMatchingBuffer: Record "Bank Statement Matching Buffer" temporary;
        TempBankPmtApplRule: Record "Bank Pmt. Appl. Rule" temporary;
        ZeroVATPostingSetup: Record "VAT Posting Setup";
        LibraryRandom: Codeunit "Library - Random";
        LibraryERM: Codeunit "Library - ERM";
        LibrarySales: Codeunit "Library - Sales";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data DK";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryApplicationArea: Codeunit "Library - Application Area DK";
        Assert: Codeunit Assert;
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        isInitialized: Boolean;
        LinesAreAppliedTxt: Label 'are applied';
        RandomizeCount: Integer;
        AvailableCharactersTxt: Label 'abcdefghijklmnopqrstuvwxyz0123456789', Locked = true;
        ShortNameToExcludFromMatchingTxt: Label 'aaa', Locked = true;


    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestCustMatchOnBankAccountOnly()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Customer: Record Customer;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        CustomerBankAccount: Record "Customer Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateCustomer(Customer);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostSalesInvoiceWithOneLine(Customer."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, Amount / 2, '', '');
        CreateCustomerBankAccount(CustomerBankAccount, Customer."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          CustomerBankAccount."Bank Branch No." + CustomerBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"No Matches");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(
          BankAccReconciliation, BankPmtApplRule, BankAccReconciliationLine."Account Type"::Customer, Amount / 2, 0, 0, 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestCustCertainAndMultipleAmountMatch()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Customer: Record Customer;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        CustomerBankAccount: Record "Customer Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateCustomer(Customer);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostSalesInvoiceWithOneLine(Customer."No.", GenerateExtDocNo(), Amount);
        CreateAndPostSalesInvoiceWithOneLine(Customer."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, Amount, '', '');
        CreateCustomerBankAccount(CustomerBankAccount, Customer."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          CustomerBankAccount."Bank Branch No." + CustomerBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"Multiple Matches");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(
          BankAccReconciliation, BankPmtApplRule, BankAccReconciliationLine."Account Type"::Customer, Amount, 0, 2, 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestCustCertainAndSingleAmountMatch()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Customer: Record Customer;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        CustomerBankAccount: Record "Customer Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateCustomer(Customer);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostSalesInvoiceWithOneLine(Customer."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, Amount, '', '');
        CreateCustomerBankAccount(CustomerBankAccount, Customer."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          CustomerBankAccount."Bank Branch No." + CustomerBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"One Match");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(
          BankAccReconciliation, BankPmtApplRule, BankAccReconciliationLine."Account Type"::Customer, Amount, 0, 1, 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestVendMatchOnBankAccountOnly()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Vendor: Record Vendor;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        VendorBankAccount: Record "Vendor Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateVendor(Vendor);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostPurchaseInvoiceWithOneLine(Vendor."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, -Amount / 2, '', '');
        CreateVendorBankAccount(VendorBankAccount, Vendor."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          VendorBankAccount."Bank Branch No." + VendorBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"No Matches");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(BankAccReconciliation, BankPmtApplRule,
          BankAccReconciliationLine."Account Type"::Vendor, -Amount / 2, 0, 0, 1);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestVendCertainAndMultipleAmountMatch()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Vendor: Record Vendor;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        VendorBankAccount: Record "Vendor Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateVendor(Vendor);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostPurchaseInvoiceWithOneLine(Vendor."No.", GenerateExtDocNo(), Amount);
        CreateAndPostPurchaseInvoiceWithOneLine(Vendor."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, -Amount, '', '');
        CreateVendorBankAccount(VendorBankAccount, Vendor."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          VendorBankAccount."Bank Branch No." + VendorBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"Multiple Matches");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(BankAccReconciliation, BankPmtApplRule,
          BankAccReconciliationLine."Account Type"::Vendor, -Amount, 0, 2, 0);
    end;

    [Test]
    [HandlerFunctions('MessageHandler,VerifyMatchDetailsOnPaymentApplicationsPage')]
    [Scope('OnPrem')]
    procedure TestVendCertainAndSingleAmountMatch()
    var
        BankAccReconciliation: Record "Bank Acc. Reconciliation";
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        Vendor: Record Vendor;
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        VendorBankAccount: Record "Vendor Bank Account";
        Amount: Decimal;
    begin
        Initialize();

        // Setup
        CreateVendor(Vendor);
        Amount := LibraryRandom.RandDecInRange(1, 1000, 2);
        CreateAndPostPurchaseInvoiceWithOneLine(Vendor."No.", GenerateExtDocNo(), Amount);

        CreateBankReconciliationAmountTolerance(BankAccReconciliation, 0);
        CreateBankReconciliationLine(BankAccReconciliation, BankAccReconciliationLine, -Amount, '', '');
        CreateVendorBankAccount(VendorBankAccount, Vendor."No.", BankAccReconciliation."Bank Account No.");
        UpdateBankReconciliationLine(BankAccReconciliationLine,
          VendorBankAccount."Bank Branch No." + VendorBankAccount."Bank Account No.", '', '', '');

        // Exercise
        RunMatch(BankAccReconciliation, true);

        // Verify
        SetRule(BankPmtApplRule, BankPmtApplRule."Related Party Matched"::Fully,
          BankPmtApplRule."Doc. No./Ext. Doc. No. Matched"::No, BankPmtApplRule."Amount Incl. Tolerance Matched"::"One Match");
        VerifyReconciliation(BankPmtApplRule, BankAccReconciliationLine."Statement Line No.");
        VerifyMatchDetailsData(BankAccReconciliation, BankPmtApplRule,
          BankAccReconciliationLine."Account Type"::Vendor, -Amount, 0, 1, 0);
    end;


    local procedure Initialize()
    var
        BankPmtApplRule: Record "Bank Pmt. Appl. Rule";
        BankPmtApplSettings: Record "Bank Pmt. Appl. Settings";
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Bank Pmt. Appl. Algorithm DK");
        CleanupPreviousTestData();
        ClearGlobals();
        LibraryVariableStorage.Clear();
        BankPmtApplRule.DeleteAll();
        BankPmtApplRule.InsertDefaultMatchingRules();
        BankPmtApplSettings.DeleteAll();

        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Bank Pmt. Appl. Algorithm DK");

        LibraryApplicationArea.EnableFoundationSetup();
        TempBankPmtApplRule.LoadRules();
        LibraryERMCountryData.UpdateLocalData();
        LibraryERMCountryData.CreateVATData();
        LibraryERMCountryData.UpdateGeneralPostingSetup();
        LibraryERM.FindZeroVATPostingSetup(ZeroVATPostingSetup, ZeroVATPostingSetup."VAT Calculation Type"::"Normal VAT");

        isInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Bank Pmt. Appl. Algorithm DK");
    end;

    local procedure CleanupPreviousTestData()
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        Customer: Record "Customer";
        Vendor: Record "Vendor";
        TextToAccountMapping: Record "Text-to-Account Mapping";
    begin
        CustLedgerEntry.SetRange(Open, true);
        CustLedgerEntry.ModifyAll(Open, false);

        VendorLedgerEntry.SetRange(Open, true);
        VendorLedgerEntry.ModifyAll(Open, false);

        BankAccountLedgerEntry.SetRange(Open, true);
        BankAccountLedgerEntry.ModifyAll(Open, false);

        Customer.ModifyAll(Name, ShortNameToExcludFromMatchingTxt);
        Vendor.ModifyAll(Name, ShortNameToExcludFromMatchingTxt);

        TextToAccountMapping.DeleteAll();
    end;

    local procedure ClearGlobals()
    begin
        Clear(TempBankStatementMatchingBuffer);
        TempBankStatementMatchingBuffer.DeleteAll();
    end;

    local procedure CreateCustomer(var Customer: Record Customer)
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("VAT Bus. Posting Group", ZeroVATPostingSetup."VAT Bus. Posting Group");
        Customer.Validate(Name, GenerateRandomSmallLettersWithSpaces(50));
        Customer.Validate(Address, GenerateRandomSmallLettersWithSpaces(50));
        Customer.Validate("Address 2", GenerateRandomSmallLettersWithSpaces(50));
        Customer.Validate("Country/Region Code", '');
        Customer.Validate(City, GenerateRandomSmallLettersWithSpaces(30));
        Customer.Modify(true);
    end;

    local procedure CreateVendor(var Vendor: Record Vendor)
    begin
        LibraryPurchase.CreateVendor(Vendor);
        Vendor.Validate("VAT Bus. Posting Group", ZeroVATPostingSetup."VAT Bus. Posting Group");
        Vendor.Validate(Name, GenerateRandomSmallLettersWithSpaces(50));
        Vendor.Validate(Address, GenerateRandomSmallLettersWithSpaces(50));
        Vendor.Validate("Address 2", GenerateRandomSmallLettersWithSpaces(50));
        Vendor.Validate("Country/Region Code", '');
        Vendor.Validate(City, GenerateRandomSmallLettersWithSpaces(30));
        Vendor.Modify(true);
    end;

    local procedure CreateItem(var Item: Record Item; Amount: Decimal)
    begin
        LibraryInventory.CreateItem(Item);
        Item.Validate("VAT Prod. Posting Group", ZeroVATPostingSetup."VAT Prod. Posting Group");
        Item.Validate("Unit Price", Amount);
        Item.Validate("Last Direct Cost", Amount);
        Item.Modify(true);
    end;

    local procedure CreateCustomerBankAccount(var CustomerBankAccount: Record "Customer Bank Account"; CustomerNo: Code[20]; BankAccountNo: Code[20])
    begin
        LibrarySales.CreateCustomerBankAccount(CustomerBankAccount, CustomerNo);
        CustomerBankAccount.IBAN := '';
        CustomerBankAccount."Bank Account No." := BankAccountNo;
        CustomerBankAccount."Bank Branch No." := BankAccountNo;
        CustomerBankAccount.Modify(true);
    end;

    local procedure CreateVendorBankAccount(var VendorBankAccount: Record "Vendor Bank Account"; VendorNo: Code[20]; BankAccountNo: Code[20])
    begin
        LibraryPurchase.CreateVendorBankAccount(VendorBankAccount, VendorNo);
        VendorBankAccount.IBAN := '';
        VendorBankAccount."Bank Account No." := BankAccountNo;
        VendorBankAccount."Bank Branch No." := BankAccountNo;
        VendorBankAccount.Modify(true);
    end;

    local procedure CreateAndPostSalesInvoiceWithOneLine(CustomerNo: Code[20]; ExtDocNo: Code[20]; Amount: Decimal): Code[20]
    begin
        exit(CreateAndPostSalesInvoiceWithOneLine2(CustomerNo, ExtDocNo, Amount, 0D));
    end;

    local procedure CreateAndPostSalesInvoiceWithOneLine2(CustomerNo: Code[20]; ExtDocNo: Code[20]; Amount: Decimal; DueDate: Date): Code[20]
    var
        Item: Record Item;
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
    begin
        CreateItem(Item, Amount);
        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, CustomerNo);
        SalesHeader.Validate("External Document No.", ExtDocNo);

        if DueDate <> 0D then
            SalesHeader.Validate("Due Date", DueDate);

        SalesHeader.Modify(true);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, SalesLine.Type::Item, Item."No.", 1);

        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateAndPostPurchaseInvoiceWithOneLine(VendorNo: Code[20]; ExtDocNo: Code[20]; Amount: Decimal): Code[20]
    begin
        exit(CreateAndPostPurchaseInvoiceWithOneLine2(VendorNo, ExtDocNo, Amount, 0D));
    end;

    local procedure CreateAndPostPurchaseInvoiceWithOneLine2(VendorNo: Code[20]; ExtDocNo: Code[20]; Amount: Decimal; DueDate: Date): Code[20]
    var
        Item: Record Item;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        CreateItem(Item, Amount);
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, VendorNo);
        PurchaseHeader.Validate("Vendor Invoice No.", ExtDocNo);
        if DueDate <> 0D then
            PurchaseHeader.Validate("Due Date", DueDate);

        PurchaseHeader.Modify(true);
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::Item, Item."No.", 1);

        exit(LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true));
    end;

    local procedure CreateBankReconciliationAmountTolerance(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; ToleranceValue: Decimal)
    var
        BankAccount: Record "Bank Account";
    begin
        CreateBankReconciliation(BankAccReconciliation, BankAccount."Match Tolerance Type"::Amount, ToleranceValue);
    end;

    local procedure CreateBankReconciliation(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; ToleranceType: Option; ToleranceValue: Decimal)
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Match Tolerance Type", ToleranceType);
        BankAccount.Validate("Match Tolerance Value", ToleranceValue);
        BankAccount.Modify(true);
        LibraryERM.CreateBankAccReconciliation(BankAccReconciliation, BankAccount."No.",
          BankAccReconciliation."Statement Type"::"Payment Application");
    end;

    local procedure CreateBankReconciliationLine(var BankAccReconciliation: Record "Bank Acc. Reconciliation"; var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; Amount: Decimal; TransactionText: Text[140]; AdditionalTransactionInfo: Text[100])
    begin
        LibraryERM.CreateBankAccReconciliationLn(BankAccReconciliationLine, BankAccReconciliation);
        BankAccReconciliationLine.Validate("Transaction Text", TransactionText);
        BankAccReconciliationLine.Validate("Additional Transaction Info", AdditionalTransactionInfo);
        BankAccReconciliationLine.Validate("Transaction Date", WorkDate());
        BankAccReconciliationLine.Validate("Statement Amount", Amount);
        BankAccReconciliationLine.Modify(true);
    end;


    local procedure UpdateBankReconciliationLine(var BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line"; BankAccountNo: Text[50]; Name: Text[100]; Address: Text[100]; City: Text[50])
    begin
        BankAccReconciliationLine.Validate("Related-Party Bank Acc. No.", BankAccountNo);
        BankAccReconciliationLine.Validate("Related-Party Name", Name);
        BankAccReconciliationLine.Validate("Related-Party Address", Address);
        BankAccReconciliationLine.Validate("Related-Party City", City);
        BankAccReconciliationLine.Modify(true);
    end;



    local procedure GenerateExtDocNo(): Code[20]
    begin
        exit(LibraryUtility.GenerateGUID() + GenerateRandomSmallLetters(10));
    end;

    local procedure GenerateRandomSmallLettersWithSpaces(Length: Integer) String: Text
    var
        SpacePosition: Integer;
    begin
        String := GenerateRandomSmallLetters(Length);
        repeat
            RandomizeCount += 1;
            Randomize(RandomizeCount);
            SpacePosition += 5 + Random(15);
            if SpacePosition < Length - 5 then
                String[SpacePosition] := ' ';
        until SpacePosition > Length;

        exit(String);
    end;

    local procedure GenerateRandomSmallLetters(Length: Integer) String: Text
    var
        i: Integer;
        AvailableCharactersText: Text;
    begin
        AvailableCharactersText := AvailableCharactersTxt;
        for i := 1 to Length do begin
            RandomizeCount += 1;
            Randomize(RandomizeCount);
            String[i] := AvailableCharactersText[Random(StrLen(AvailableCharactersText))];
        end;

        exit(String);
    end;


    local procedure OpenPaymentRecJournal(BankAccReconciliation: Record "Bank Acc. Reconciliation")
    var
        PmtReconciliationJournals: TestPage "Pmt. Reconciliation Journals";
    begin
        PmtReconciliationJournals.OpenView();
        PmtReconciliationJournals.GotoRecord(BankAccReconciliation);
        PmtReconciliationJournals.EditJournal.Invoke();
    end;


    local procedure VerifyReconciliation(ExpectedBankPmtApplRule: Record "Bank Pmt. Appl. Rule"; StatementLineNo: Integer)
    begin
        TempBankStatementMatchingBuffer.Reset();
        TempBankStatementMatchingBuffer.SetRange("Line No.", StatementLineNo);
        TempBankStatementMatchingBuffer.FindFirst();

        Assert.AreEqual(TempBankPmtApplRule.GetBestMatchScore(ExpectedBankPmtApplRule),
          TempBankStatementMatchingBuffer.Quality, 'Matching is wrong for statement line ' + Format(StatementLineNo))
    end;


    local procedure VerifyMatchDetailsData(BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; AccountType: Enum "Gen. Journal Account Type"; Amount: Decimal; Tolerance: Decimal; ExpectedNumberOfEntriesWithinTolerance: Integer; ExpectedNumberOfEntriesOutsideTolerance: Integer)
    var
        BankAccount: Record "Bank Account";
        TempBankPmtApplRuleLocal: Record "Bank Pmt. Appl. Rule" temporary;
    begin
        TempBankPmtApplRuleLocal.LoadRules();
        TempBankPmtApplRuleLocal.GetBestMatchScore(BankPmtApplRule);
        BankPmtApplRule."Match Confidence" := TempBankPmtApplRuleLocal."Match Confidence";

        VerifyMatchDetailsData2(BankAccReconciliation, BankPmtApplRule, AccountType,
          Amount, Tolerance, BankAccount."Match Tolerance Type"::Amount, ExpectedNumberOfEntriesWithinTolerance,
          ExpectedNumberOfEntriesOutsideTolerance,
          false, -1);
    end;

    local procedure VerifyMatchDetailsData2(BankAccReconciliation: Record "Bank Acc. Reconciliation"; BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; AccountType: Enum "Gen. Journal Account Type"; Amount: Decimal; Tolerance: Decimal; ToleranceType: Option; ExpectedNumberOfEntriesWithinTolerance: Integer; ExpectedNumberOfEntriesOutsideTolerance: Integer; GoToEntroNo: Boolean; EntryNo: Integer)
    var
        PaymentReconciliationJournal: TestPage "Payment Reconciliation Journal";
    begin
        PaymentReconciliationJournal.Trap();
        OpenPaymentRecJournal(BankAccReconciliation);

        LibraryVariableStorage.Enqueue(Format(BankPmtApplRule."Match Confidence"));
        LibraryVariableStorage.Enqueue(BankPmtApplRule."Related Party Matched");
        LibraryVariableStorage.Enqueue(BankPmtApplRule."Doc. No./Ext. Doc. No. Matched");
        LibraryVariableStorage.Enqueue(ExpectedNumberOfEntriesWithinTolerance);
        LibraryVariableStorage.Enqueue(ExpectedNumberOfEntriesOutsideTolerance);
        LibraryVariableStorage.Enqueue(AccountType);
        LibraryVariableStorage.Enqueue(Amount);
        LibraryVariableStorage.Enqueue(Tolerance);
        LibraryVariableStorage.Enqueue(ToleranceType);
        LibraryVariableStorage.Enqueue(GoToEntroNo);

        if GoToEntroNo then
            LibraryVariableStorage.Enqueue(EntryNo);

        PaymentReconciliationJournal.First();
        PaymentReconciliationJournal.ApplyEntries.Invoke();

        PaymentReconciliationJournal.Close();
    end;

    local procedure VerifyNoOfCustomerLedgerEntriesOnMatchDetailsLookup(PaymentApplication: TestPage "Payment Application"; Tolerance: Decimal; ToleranceType: Option; Amount: Decimal)
    var
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
        EntryRemainingAmount: Decimal;
    begin
        CustomerLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesWithinAmount.DrillDown();
        if CustomerLedgerEntries.First() then
            repeat
                Evaluate(EntryRemainingAmount, CustomerLedgerEntries."Remaining Amount".Value);
                Assert.IsTrue(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is not within tolerance range');
            until not CustomerLedgerEntries.Next();
        CustomerLedgerEntries.Close();

        CustomerLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesOutsideAmount.DrillDown();
        if CustomerLedgerEntries.First() then
            repeat
                Evaluate(EntryRemainingAmount, CustomerLedgerEntries."Remaining Amount".Value);
                Assert.IsFalse(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is within tolerance range');
            until not CustomerLedgerEntries.Next();
        CustomerLedgerEntries.Close();
    end;

    local procedure VerifyNoOfVendorLedgerEntriesOnMatchDetailsLookup(PaymentApplication: TestPage "Payment Application"; Tolerance: Decimal; ToleranceType: Option; Amount: Decimal)
    var
        VendorLedgerEntries: TestPage "Vendor Ledger Entries";
        EntryRemainingAmount: Decimal;
    begin
        VendorLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesWithinAmount.DrillDown();
        if VendorLedgerEntries.First() then
            repeat
                Evaluate(EntryRemainingAmount, VendorLedgerEntries."Remaining Amount".Value);
                Assert.IsTrue(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is not within tolerance range');
            until not VendorLedgerEntries.Next();

        VendorLedgerEntries.Close();
        VendorLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesOutsideAmount.DrillDown();
        if VendorLedgerEntries.First() then
            repeat
                Evaluate(EntryRemainingAmount, VendorLedgerEntries."Remaining Amount".Value);
                Assert.IsFalse(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is within tolerance range');
            until not VendorLedgerEntries.Next();
        VendorLedgerEntries.Close();
    end;

    local procedure VerifyNoOfBankAccountLedgerEntriesOnMatchDetailsLookup(PaymentApplication: TestPage "Payment Application"; Tolerance: Decimal; ToleranceType: Option; Amount: Decimal)
    var
        BankAccountLedgerEntries: TestPage "Bank Account Ledger Entries";
        EntryRemainingAmount: Decimal;
    begin
        BankAccountLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesWithinAmount.DrillDown();
        if BankAccountLedgerEntries.First() then
            repeat
                EntryRemainingAmount := LibraryERMCountryData.AmountOnBankAccountLedgerEntriesPage(BankAccountLedgerEntries);
                Assert.IsTrue(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is not within tolerance range');
            until not BankAccountLedgerEntries.Next();

        BankAccountLedgerEntries.Close();
        BankAccountLedgerEntries.Trap();
        PaymentApplication.Control2.NoOfLedgerEntriesOutsideAmount.DrillDown();
        if BankAccountLedgerEntries.First() then
            repeat
                EntryRemainingAmount := LibraryERMCountryData.AmountOnBankAccountLedgerEntriesPage(BankAccountLedgerEntries);
                Assert.IsFalse(IsEntryAmountWithinToleranceRange(EntryRemainingAmount, Amount, Tolerance, ToleranceType),
                  'Entry is within tolerance range');
            until not BankAccountLedgerEntries.Next();
        BankAccountLedgerEntries.Close();
    end;

    local procedure IsEntryAmountWithinToleranceRange(EntryRemainingAmount: Decimal; Amount: Decimal; Tolerance: Decimal; ToleranceType: Option): Boolean
    var
        BankAccount: Record "Bank Account";
        MinAmount: Decimal;
        MaxAmount: Decimal;
        TempAmount: Decimal;
    begin
        if ToleranceType = BankAccount."Match Tolerance Type"::Percentage then begin
            MinAmount := EntryRemainingAmount - Round(EntryRemainingAmount * Tolerance / 100);
            MaxAmount := EntryRemainingAmount + Round(EntryRemainingAmount * Tolerance / 100);

            if EntryRemainingAmount < 0 then begin
                TempAmount := MinAmount;
                MinAmount := MaxAmount;
                MaxAmount := TempAmount;
            end;
        end else begin
            MinAmount := EntryRemainingAmount - Tolerance;
            MaxAmount := EntryRemainingAmount + Tolerance;
        end;

        exit((MinAmount <= Amount) and (MaxAmount >= Amount));
    end;

    local procedure SetRule(var BankPmtApplRule: Record "Bank Pmt. Appl. Rule"; RelatedPartyMatched: Option; DocNoMatched: Option; AmountInclToleranceMatched: Option)
    begin
        Clear(BankPmtApplRule);

        BankPmtApplRule."Related Party Matched" := RelatedPartyMatched;
        BankPmtApplRule."Doc. No./Ext. Doc. No. Matched" := DocNoMatched;
        BankPmtApplRule."Amount Incl. Tolerance Matched" := AmountInclToleranceMatched;
    end;

    local procedure RunMatch(BankAccReconciliation: Record "Bank Acc. Reconciliation"; ApplyEntries: Boolean)
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchBankPayments: Codeunit "Match Bank Payments";
    begin
        if ApplyEntries then
            LibraryVariableStorage.Enqueue(LinesAreAppliedTxt);

        BankAccReconciliationLine.SetRange("Statement Type", BankAccReconciliation."Statement Type");
        BankAccReconciliationLine.SetRange("Statement No.", BankAccReconciliation."Statement No.");
        BankAccReconciliationLine.SetRange("Bank Account No.", BankAccReconciliation."Bank Account No.");
        MatchBankPayments.SetApplyEntries(ApplyEntries);
        MatchBankPayments.Code(BankAccReconciliationLine);

        MatchBankPayments.GetBankStatementMatchingBuffer(TempBankStatementMatchingBuffer);
    end;

    [MessageHandler]
    [Scope('OnPrem')]
    procedure MessageHandler(Message: Text[1024])
    var
        ExpectedMsg: Variant;
    begin
        LibraryVariableStorage.Dequeue(ExpectedMsg);
        Assert.IsTrue(StrPos(Message, ExpectedMsg) > 0, Message);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure VerifyMatchDetailsOnPaymentApplicationsPage(var PaymentApplication: TestPage "Payment Application")
    var
        BankAccReconciliationLine: Record "Bank Acc. Reconciliation Line";
        MatchConfidenceVariant: Variant;
        RelatedPartyMatchedVariant: Variant;
        DocExtDocNoMatchedVariant: Variant;
        ExpectedNumberOfEntriesWithinToleranceVariant: Variant;
        ExpectedNumberOfEntriesOutsideToleranceVariant: Variant;
        AccountTypeVariant: Variant;
        AmountVariant: Variant;
        ToleranceVariant: Variant;
        ToleranceTypeVariant: Variant;
        GoToEntryNoVariant: Variant;
        EntryNoVariant: Variant;
        AccountType: Enum "Gen. Journal Account Type";
        AccountTypeInt: Integer;
        GoToEntryNo: Boolean;
    begin
        LibraryVariableStorage.Dequeue(MatchConfidenceVariant);
        LibraryVariableStorage.Dequeue(RelatedPartyMatchedVariant);
        LibraryVariableStorage.Dequeue(DocExtDocNoMatchedVariant);
        LibraryVariableStorage.Dequeue(ExpectedNumberOfEntriesWithinToleranceVariant);
        LibraryVariableStorage.Dequeue(ExpectedNumberOfEntriesOutsideToleranceVariant);
        LibraryVariableStorage.Dequeue(AccountTypeVariant);
        LibraryVariableStorage.Dequeue(AmountVariant);
        LibraryVariableStorage.Dequeue(ToleranceVariant);
        LibraryVariableStorage.Dequeue(ToleranceTypeVariant);
        LibraryVariableStorage.Dequeue(GoToEntryNoVariant);

        GoToEntryNo := GoToEntryNoVariant;
        if GoToEntryNo then begin
            LibraryVariableStorage.Dequeue(EntryNoVariant);
            Assert.IsTrue(PaymentApplication.FindFirstField("Applies-to Entry No.", EntryNoVariant), 'Cannot find row on the page');
        end;

        AccountTypeInt := AccountTypeVariant;
        AccountType := "Gen. Journal Account Type".FromInteger(AccountTypeInt);

        // Verify Overall Confidence matches
        Assert.AreEqual(
          MatchConfidenceVariant,
          PaymentApplication.Control2.MatchConfidence.Value,
          'Unexpected value of ''Match Confidence''');
        Assert.AreEqual(
          Format(RelatedPartyMatchedVariant),
          PaymentApplication.Control2.RelatedPatryMatchedOverview.Value,
          'Unexpected value of ''Related Party Matched''');
        Assert.AreEqual(
          Format(DocExtDocNoMatchedVariant),
          PaymentApplication.Control2.DocExtDocNoMatchedOverview.Value,
          'Unexpected value of ''Doc. No./Ext. Doc. No. Matched''');

        // Verify No. Of Entries within tolerance and lookups
        Assert.AreEqual(
          Format(ExpectedNumberOfEntriesWithinToleranceVariant),
          PaymentApplication.Control2.NoOfLedgerEntriesWithinAmount.Value,
          'Unexpected value of ''Number of Ledger Entries Within Amount Tolerance''');
        Assert.AreEqual(
          Format(ExpectedNumberOfEntriesOutsideToleranceVariant),
          PaymentApplication.Control2.NoOfLedgerEntriesOutsideAmount.Value,
          'Unexpected value of ''Number of Ledger Entries Outside Amount Tolerance''');

        case AccountType of
            BankAccReconciliationLine."Account Type"::Customer:
                VerifyNoOfCustomerLedgerEntriesOnMatchDetailsLookup(PaymentApplication, ToleranceVariant, ToleranceTypeVariant, AmountVariant);
            BankAccReconciliationLine."Account Type"::Vendor:
                VerifyNoOfVendorLedgerEntriesOnMatchDetailsLookup(PaymentApplication, ToleranceVariant, ToleranceTypeVariant, AmountVariant);
            BankAccReconciliationLine."Account Type"::"Bank Account":
                VerifyNoOfBankAccountLedgerEntriesOnMatchDetailsLookup(
                  PaymentApplication, ToleranceVariant, ToleranceTypeVariant, AmountVariant);
            else
                Assert.Fail('Wrong Account Type found');
        end;
    end;
}

