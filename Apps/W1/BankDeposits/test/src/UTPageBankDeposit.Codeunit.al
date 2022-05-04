codeunit 139768 "UT Page Bank Deposit"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Deposit] [UI]
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryUTUtility: Codeunit "Library UT Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryERM: Codeunit "Library - ERM";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryApplicationArea: Codeunit "Library - Application Area";
        Initialized: Boolean;
        InitializeHandled: Boolean;
        ValueMustExistMsg: Label 'Value must exist.';
        PostingDateErr: Label 'Validation error for Field: Posting Date,  Message = ''Posting Date must have a value in Bank Deposit Header: No.=%1. It cannot be zero or empty. (Select Refresh to discard errors)''';
        FeatureKeyIdTok: Label 'StandardizedBankReconciliationAndDeposits', Locked = true;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionTestReportDeposits()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposits: TestPage "Bank Deposits";
    begin
        // Purpose of the test is to validate TestReport - OnAction trigger of the Page ID: 36646, BankDeposits.
        // Setup.
        Initialize();
        EnableBankDepositsFeature();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount());
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue value for use in DepositTestReportRequestPageHandler.

        // Exercise & Verify: Verify the Deposit Test Report after calling action Test Report on Deposits page through DepositTestReportRequestPageHandler.
        BankDeposits.OpenEdit();
        BankDeposits.GotoRecord(BankDepositHeader);
        BankDeposits.TestReport.Invoke();  // Invokes DepositTestReportRequestPageHandler.
        BankDeposits.Close();
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedBankDepositList()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        PostedBankDepositList: TestPage "Posted Bank Deposit List";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10147, Posted Deposit List.
        // Setup.
        Initialize();
        EnableBankDepositsFeature();
        LibraryApplicationArea.EnableEssentialSetup();
        CreatePostedBankDepositForCustomer(PostedBankDepositHeader, PostedBankDepositLine);
        UpdateDimensionOnPostedBankDepositHeader(PostedBankDepositHeader, CreateDimension());

        // Exercise & Verify: Verify the Dimensions on Posted Deposits List page through DimensionSetEntriesPageHandler.
        PostedBankDepositList.OpenEdit();
        PostedBankDepositList.GotoRecord(PostedBankDepositHeader);
        PostedBankDepositList.Dimensions.Invoke();  // Invokes DimensionSetEntriesPageHandler.
        PostedBankDepositList.Close();
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedBankDepositSubform()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page: Posted Bank Deposit Subform.
        // Setup.
        Initialize();
        LibraryApplicationArea.EnableEssentialSetup();
        CreatePostedBankDepositForCustomer(PostedBankDepositHeader, PostedBankDepositLine);
        PostedBankDepositLine."Dimension Set ID" := CreateDimension();
        PostedBankDepositLine.Modify();

        // Exercise & Verify: Verify the Dimensions on Posted Deposits Subform page through DimensionSetEntriesPageHandler.
        PostedBankDepositLine.ShowDimensions();  // Invokes DimensionSetEntriesPageHandler.
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountLedgerEntriesPostedBankDepositSubform()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        // Purpose of the test is to validate AccountLedgerEntries - OnAction trigger of the Page ID: 10144, Posted Deposit Subform.
        // Setup.
        Initialize();
        CreatePostedBankDepositForCustomer(PostedBankDepositHeader, PostedBankDepositLine);
        CreatePostedSalesInvoiceLine(PostedBankDepositLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, PostedBankDepositLine."Document No.", PostedBankDepositLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", PostedBankDepositLine."Account No.");

        // Exercise: Show Account Ledger Entries.
        CustomerLedgerEntries.Trap();
        PostedBankDepositLine.ShowAccountLedgerEntries();

        // Verify: Verify Customer No and Amount on the Customer Ledger Entries.
        CustomerLedgerEntries."Customer No.".AssertEquals(PostedBankDepositLine."Account No.");
        CustomerLedgerEntries.Amount.AssertEquals(PostedBankDepositLine.Amount);
        CustomerLedgerEntries.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountCardPostedBankDepositSubform()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of the test is to validate AccountCard - OnAction trigger of the Page ID: 10144, Posted Deposit Subform.
        // Setup.
        Initialize();
        CreatePostedBankDepositForCustomer(PostedBankDepositHeader, PostedBankDepositLine);
        LibraryVariableStorage.Enqueue(PostedBankDepositLine."Account No.");  // Enqueue values for use in CustomerCardPageHandler.

        // Exercise: Show Account Card - Customer Card.
        CustomerCard.Trap();
        PostedBankDepositLine.ShowAccountCard();

        // Verify: Verify Customer No on Customer Card.
        CustomerCard."No.".AssertEquals(PostedBankDepositLine."Account No.");
        CustomerCard.Close();
    end;

    [Test]
    [HandlerFunctions('DimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsPostedBankDeposit()
    var
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        PostedBankDeposit: TestPage "Posted Bank Deposit";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10143, Posted Deposit.
        // Setup.
        Initialize();
        LibraryApplicationArea.EnableEssentialSetup();
        CreatePostedBankDepositForCustomer(PostedBankDepositHeader, PostedBankDepositLine);
        UpdateDimensionOnPostedBankDepositHeader(PostedBankDepositHeader, CreateDimension());

        // Exercise & Verify: Verify the Dimension on Posted Deposit page through DimensionSetEntriesPageHandler.
        OpenPostedBankDepositPage(PostedBankDeposit, PostedBankDepositHeader);
        PostedBankDeposit.Dimensions.Invoke();  // Invokes DimensionSetEntriesPageHandler.
        PostedBankDeposit.Close();
    end;

    [Test]
    [HandlerFunctions('EditDimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize();
        LibraryApplicationArea.EnableEssentialSetup();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());

        // Exercise: Update the Dimension on Deposit Subform page through EditDimensionSetEntriesPageHandler.
        OpenDepositSubForm(BankDeposit, BankDepositHeader, GenJournalLine);
        BankDeposit.Subform.Dimensions.Invoke();  // Invokes EditDimensionSetEntriesPageHandler.
        BankDeposit.Close();

        // Verify: Verify Dimension Set ID on Gen. Journal Line.
        GenJournalLine.Get(GenJournalLine."Journal Template Name", GenJournalLine."Journal Batch Name", GenJournalLine."Line No.");
        GenJournalLine.TestField("Dimension Set ID");
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountCardDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CustomerCard: TestPage "Customer Card";
    begin
        // Purpose of the test is to validate AccountCard - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());
        LibraryVariableStorage.Enqueue(GenJournalLine."Account No.");  // Enqueue values for use in CustomerCardPageHandler.

        // Exercise: Show Customer Card.
        OpenDepositSubForm(BankDeposit, BankDepositHeader, GenJournalLine);
        CustomerCard.Trap();
        BankDeposit.Subform.AccountCard.Invoke();

        // Verify: Verify Customer Number on Customer Card.
        CustomerCard."No.".AssertEquals(GenJournalLine."Account No.");
        CustomerCard.Close();
        BankDeposit.Close();
    end;

    [Test]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionAccountLedgerEntriesDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankDeposit: TestPage "Bank Deposit";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
    begin
        // Purpose of the test is to validate AccountLedgerEntries - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());
        CreatePostedSalesInvoiceLine(GenJournalLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Exercise: Open Customer Ledger Entries
        OpenDepositSubForm(BankDeposit, BankDepositHeader, GenJournalLine);
        CustomerLedgerEntries.Trap();
        BankDeposit.Subform.AccountLedgerEntries.Invoke();  // Invokes CustomerLedgerEntriesPageHandler.

        // Verify: Verify the Customer Ledger Entries.
        CustomerLedgerEntries."Customer No.".AssertEquals(CustLedgerEntry."Customer No.");
        CustomerLedgerEntries.Amount.AssertEquals(CustLedgerEntry.Amount);
        CustomerLedgerEntries.OK().Invoke();
        BankDeposit.Close();
    end;

    [Test]
    [HandlerFunctions('ApplyCustomerEntriesPageHandler')]
    [Scope('OnPrem')]
    procedure OnActionApplyEntriesDepositSubform()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankDeposit: TestPage "Bank Deposit";
    begin
        // Purpose of the test is to validate ApplyEntries - OnAction trigger of the Page ID: 10141, Deposit Subform.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::Customer, CreateCustomer());
        CreatePostedSalesInvoiceLine(GenJournalLine."Account No.");
        CreateCustomerLedgerEntry(CustLedgerEntry, GenJournalLine."Document No.", GenJournalLine."Account No.");
        CreateDetailedCustomerLedgerEntry(CustLedgerEntry."Entry No.", GenJournalLine."Account No.");

        // Enqueue values for use in ApplyCustomerEntriesPageHandler.
        CustLedgerEntry.CalcFields("Remaining Amount");
        LibraryVariableStorage.Enqueue(GenJournalLine."Account No.");
        LibraryVariableStorage.Enqueue(CustLedgerEntry."Remaining Amount");

        // Exercise & Verify: Verify the Apply Customer Entries on Deposit Subform page through ApplyCustomerEntriesPageHandler.
        OpenDepositSubForm(BankDeposit, BankDepositHeader, GenJournalLine);
        BankDeposit.Subform.ApplyEntries.Invoke();  // Invokes ApplyCustomerEntriesPageHandler.
        BankDeposit.Close();
    end;

    [Test]
    [HandlerFunctions('ConfirmHandlerTRUE')]
    [Scope('OnPrem')]
    procedure OnActionPostDeposit()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        PostedBankDeposit: TestPage "Posted Bank Deposit";
    begin
        // Purpose of the test is to validate Post - OnAction trigger of the Page ID: 10140, Deposit. Transaction model is AutoCommit for explicit commit used in Codeunit: Bank Deposit-Post.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount());

        // Exercise.
        OpenDepositPage(BankDeposit, BankDepositHeader);
        PostedBankDeposit.Trap();
        BankDeposit.Post.Invoke();
        PostedBankDeposit.Close();

        // Verify: Verify the Posted Deposit exist after posting Deposit.
        Assert.IsTrue(PostedBankDepositHeader.Get(BankDepositHeader."No."), ValueMustExistMsg);
    end;

    [Test]
    [HandlerFunctions('DepositTestReportRequestPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDepositTestReportDeposit()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
    begin
        // Purpose of the test is to validate DepositTestReport - OnAction trigger of the Page ID: 10140, Deposit.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        LibraryVariableStorage.Enqueue(BankDepositHeader."No.");  // Enqueue values for use in DepositTestReportRequestPageHandler.

        // Exercise & verify: Verify the Deposit Test Report run from Deposit page through DepositTestReportRequestPageHandler.
        OpenDepositPage(BankDeposit, BankDepositHeader);
        BankDeposit."Test Report".Invoke();  // Invokes DepositTestReportRequestPageHandler.
        BankDeposit.Close();
    end;

    [Test]
    [HandlerFunctions('DepositReportHandler,ConfirmHandlerTRUE')]
    [Scope('OnPrem')]
    procedure OnActionPostAndPrintDeposit()
    var
        GenJournalLine: Record "Gen. Journal Line";
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        PostedBankDeposit: TestPage "Posted Bank Deposit";
    begin
        // Purpose of the test is to validate PostAndPrint - OnAction trigger of the Page ID: 10140, Deposit. Transaction model is AutoCommit for explicit commit used in Codeunit ID: 10140, Deposit-Post.
        // Setup.
        Initialize();
        CreateBankDepositHeader(BankDepositHeader, '');
        CreateGenJournalLine(GenJournalLine, BankDepositHeader, GenJournalLine."Account Type"::"G/L Account", CreateGLAccount());

        // Exercise.
        OpenDepositPage(BankDeposit, BankDepositHeader);
        PostedBankDeposit.Trap();
        BankDeposit.PostAndPrint.Invoke();  // Invokes DepositReportHandler.
        PostedBankDeposit.Close();

        // Verify: Verify the Posted Deposit Header exist after Post and Print of Deposit.
        Assert.IsTrue(PostedBankDepositHeader.Get(BankDepositHeader."No."), ValueMustExistMsg);
    end;

    [Test]
    [HandlerFunctions('EditDimensionSetEntriesPageHandler')]
    [TransactionModel(TransactionModel::AutoRollback)]
    [Scope('OnPrem')]
    procedure OnActionDimensionsDeposit()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
    begin
        // Purpose of the test is to validate Dimensions - OnAction trigger of the Page ID: 10140, Deposit.
        // Setup.
        Initialize();
        LibraryApplicationArea.EnableEssentialSetup();
        CreateBankDepositHeader(BankDepositHeader, '');

        // Exercise: Update the Dimension on Deposit page through EditDimensionSetEntriesPageHandler.
        OpenDepositPage(BankDeposit, BankDepositHeader);
        BankDeposit.Dimensions.Invoke();  // Invokes EditDimensionSetEntriesPageHandler.
        BankDeposit.Close();

        // Verify: Verify Dimension Set ID on Deposit Header.
        BankDepositHeader.Get(BankDepositHeader."No.");
        BankDepositHeader.TestField("Dimension Set ID");
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TotalDepositLinesControlIsUpdatedWhenCreateDepositLine()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CreditAmount: Decimal;
    begin
        // [SCENARIO 218101] 'Total Deposit Lines' and Difference controls are updated when Credit Amount is updated on Deposit Subpage
        Initialize();

        // [GIVEN] Deposit page is opened with 'Total Deposit Amount' = 100
        CreateBankDepositHeader(BankDepositHeader, '');

        BankDepositHeader.Validate("Total Deposit Amount", LibraryRandom.RandDecInRange(100, 200, 2));
        BankDepositHeader.Modify(true);
        OpenDepositPage(BankDeposit, BankDepositHeader);

        // [WHEN] Set Credit Amount = 20
        CreditAmount := LibraryRandom.RandDec(10, 2);
        BankDeposit.Subform."Credit Amount".SetValue(CreditAmount);

        // [THEN] 'Total Deposit Lines' is updated with 20
        // [THEN] 'Difference' is updated with 80
        BankDeposit.Subform.TotalDepositLines.AssertEquals(CreditAmount);
        BankDeposit.Difference.AssertEquals(BankDepositHeader."Total Deposit Amount" - CreditAmount);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure CloseDepositPageWithEmptyPostingDate()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
    begin
        // [FEATURE] [Posting Date]
        // [SCENARIO 317751] User can validate an empty Posting Date on a Deposit Card
        Initialize();

        // [GIVEN] Created a Deposit Header and opened its Deposit Card
        CreateBankDepositHeader(BankDepositHeader, '');
        OpenDepositPage(BankDeposit, BankDepositHeader);

        // [WHEN] Try to validate an empty Posting Date
        asserterror BankDeposit."Posting Date".Value := '';

        // [THEN] Error is thrown: "Validation error for Field: Posting Date,  Message = 'Posting Date must have a value.."
        Assert.ExpectedError(StrSubstNo(PostingDateErr, BankDepositHeader."No."));
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,GeneralJournalBatchesMPH')]
    procedure TemplateAndBatchSelectionIsShownOnlyOnceForANewDeposit_SingleTemplate()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [SCENARIO 396854] Template and Batch selection is shown only once for a new deposit
        // [SCENARIO 396854] in case of single deposit template
        Initialize();

        // [GIVEN] One journal template for "Deposits"
        CreateGenJournalBatch(GenJournalBatch);

        // [GIVEN] Open deposit list page, create a new one
        // [GIVEN] Template and Batch selection is shown
        // [GIVEN] Validate deposit line with "Account Type" = "G/L Account", "Account No." = "X", close deposit card
        // [WHEN] Open the deposit card again
        CreateNewDepositTypeLineAndReopen(GenJournalBatch);

        // [THEN] Template and batch selection is not shown anymore and deposit line has "Account Type" = "G/L Account", "Account No." = "X"
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('GeneralJournalTemplateListPageHandler,GeneralJournalBatchesMPH')]
    procedure TemplateAndBatchSelectionIsShownOnlyOnceForANewDeposit_MultiTemplates()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        // [SCENARIO 396854] Template and Batch selection is shown only once for a new deposit
        // [SCENARIO 396854] in case of several deposit templates
        Initialize();

        // [GIVEN] Several journal template for "Deposits"
        CreateGenJournalBatch(GenJournalBatch);
        CreateGenJournalBatch(GenJournalBatch);

        // [GIVEN] Open deposit list page, create a new one
        // [GIVEN] Template and Batch selection is shown
        // [GIVEN] Validate deposit line with "Account Type" = "G/L Account", "Account No." = "X", close deposit card
        // [WHEN] Open the deposit card again
        CreateNewDepositTypeLineAndReopen(GenJournalBatch);

        // [THEN] Template and batch selection is not shown anymore and deposit line has "Account Type" = "G/L Account", "Account No." = "X"
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure LCYDepositWithTwoLinesChangeBankToFCY()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        Amount: Decimal;
        AmountLCY: Decimal;
    begin
        // [SCENARIO 400406] Deposit lines currency code and factor in case of changing deposit bank account from LCY to FCY
        Initialize();
        CurrencyFactor := LibraryRandom.RandDecInRange(10, 20, 2);
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), CurrencyFactor, CurrencyFactor);
        Amount := LibraryRandom.RandDecInRange(1000, 2000, 2);
        AmountLCY := Round(Amount * CurrencyFactor);

        // [GIVEN] LCY Deposit with two lines
        CreateBankDepositHeader(BankDepositHeader, '');
        OpenDepositAndAddTwoGLLines(BankDeposit, BankDepositHeader, AmountLCY);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, '', 0, AmountLCY, AmountLCY);

        // [WHEN] Validate deposit FCY bank account
        BankDeposit."Bank Account No.".SetValue(CreateBankAccount(CurrencyCode));
        BankDeposit.Close();

        // [THEN] Deposit header and lines are updated with FCY currency code and factor
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode, CurrencyFactor, AmountLCY, Amount);
    end;

    [Test]
    procedure FCYDepositWithTwoLinesChangeBankToLCY()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CurrencyCode: Code[10];
        CurrencyFactor: Decimal;
        Amount: Decimal;
        AmountLCY: Decimal;
    begin
        // [SCENARIO 400406] Deposit lines currency code and factor in case of changing deposit bank account from FCY to LCY
        Initialize();
        CurrencyFactor := LibraryRandom.RandDecInRange(10, 20, 2);
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), CurrencyFactor, CurrencyFactor);
        AmountLCY := LibraryRandom.RandDecInRange(1000, 2000, 2);
        Amount := Round(AmountLCY * CurrencyFactor);

        // [GIVEN] FCY Deposit with two lines
        CreateBankDepositHeader(BankDepositHeader, CurrencyCode);
        OpenDepositAndAddTwoGLLines(BankDeposit, BankDepositHeader, Amount);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode, CurrencyFactor, Amount, AmountLCY);

        // [WHEN] Validate deposit LCY bank account
        BankDeposit."Bank Account No.".SetValue(CreateBankAccount(''));
        BankDeposit.Close();

        // [THEN] Deposit header and lines are updated with LCY currency code and factor
        VerifyCurrencyCodeAndFactor(BankDepositHeader, '', 0, Amount, Amount);
    end;

    [Test]
    procedure FCYDepositWithTwoLinesChangeBankToFCY2()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CurrencyCode: array[2] of Code[10];
        CurrencyFactor: array[2] of Decimal;
        Amount: Decimal;
        AmountLCY: Decimal;
        i: Integer;
    begin
        // [SCENARIO 400406] Deposit lines currency code and factor in case of changing deposit bank account from FCY1 to FCY2
        Initialize();

        for i := 1 to ArrayLen(CurrencyCode) do begin
            CurrencyFactor[i] := LibraryRandom.RandDecInRange(10, 20, 2);
            CurrencyCode[i] := LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), CurrencyFactor[i], CurrencyFactor[i]);
        end;
        AmountLCY := LibraryRandom.RandDecInRange(1000, 2000, 2);
        Amount := Round(AmountLCY * CurrencyFactor[1]);

        // [GIVEN] LCY Deposit with two lines
        CreateBankDepositHeader(BankDepositHeader, CurrencyCode[1]);
        OpenDepositAndAddTwoGLLines(BankDeposit, BankDepositHeader, Amount);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode[1], CurrencyFactor[1], Amount, AmountLCY);

        // [WHEN] Validate deposit FCY2 bank account
        BankDeposit."Bank Account No.".SetValue(CreateBankAccount(CurrencyCode[2]));
        BankDeposit.Close();

        // [THEN] Deposit header and lines are updated with FCY2 currency code and factor
        AmountLCY := Round(Amount / CurrencyFactor[2]);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode[2], CurrencyFactor[2], Amount, AmountLCY);
    end;

    [Test]
    procedure FCYDepositWithTwoLinesChangePostingDate()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        BankDeposit: TestPage "Bank Deposit";
        CurrencyCode: Code[10];
        CurrencyFactor: array[2] of Decimal;
        Amount: Decimal;
        AmountLCY: Decimal;
        i: Integer;
    begin
        // [SCENARIO 400406] Deposit lines currency factor in case of changing deposit posting date
        Initialize();

        for i := 1 to ArrayLen(CurrencyFactor) do
            CurrencyFactor[i] := LibraryRandom.RandDecInRange(10, 20, 2);
        CurrencyCode := LibraryERM.CreateCurrencyWithExchangeRate(WorkDate(), CurrencyFactor[1], CurrencyFactor[1]);
        LibraryERM.CreateExchangeRate(CurrencyCode, WorkDate() + 1, CurrencyFactor[2], CurrencyFactor[2]);
        AmountLCY := LibraryRandom.RandDecInRange(1000, 2000, 2);
        Amount := Round(AmountLCY * CurrencyFactor[1]);

        // [GIVEN] FCY Deposit with two lines
        CreateBankDepositHeader(BankDepositHeader, CurrencyCode);
        OpenDepositAndAddTwoGLLines(BankDeposit, BankDepositHeader, Amount);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode, CurrencyFactor[1], Amount, AmountLCY);

        // [WHEN] Modify deposit posting date
        BankDeposit."Posting Date".SetValue(WorkDate() + 1);
        BankDeposit.Close();

        // [THEN] Deposit header and lines are updated with a new currency factor
        AmountLCY := Round(Amount / CurrencyFactor[2]);
        VerifyCurrencyCodeAndFactor(BankDepositHeader, CurrencyCode, CurrencyFactor[2], Amount, AmountLCY);
    end;

    local procedure GetBankDepositsFeature(var FeatureDataUpdateStatus: Record "Feature Data Update Status"; ID: Text[50])
    begin
        if FeatureDataUpdateStatus.Get(ID, CompanyName()) then
            exit;
        FeatureDataUpdateStatus."Feature Key" := ID;
        FeatureDataUpdateStatus."Company Name" := CopyStr(CompanyName(), 1, 30);
        FeatureDataUpdateStatus."Data Update Required" := false;
        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Disabled;
        FeatureDataUpdateStatus.Insert();
    end;

    local procedure EnableBankDepositsFeature()
    var
        FeatureDataUpdateStatus: Record "Feature Data Update Status";
        FeatureManagementFacade: Codeunit "Feature Management Facade";
        ID: Text[50];
    begin
        ID := FeatureKeyIdTok;
        if FeatureManagementFacade.IsEnabled(ID) then
            exit;
        GetBankDepositsFeature(FeatureDataUpdateStatus, ID);
        FeatureDataUpdateStatus."Feature Status" := FeatureDataUpdateStatus."Feature Status"::Enabled;
        FeatureDataUpdateStatus.Modify(true);
    end;

    local procedure Initialize()
    begin
        LibraryVariableStorage.Clear();

        if Initialized then
            exit;

        OnBeforeInitialize(InitializeHandled);
        if InitializeHandled then
            exit;

        OnAfterInitialize(InitializeHandled);
        Initialized := true;
    end;

    local procedure CreateNewDepositTypeLineAndReopen(GenJournalBatch: Record "Gen. Journal Batch")
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        BankDeposit: TestPage "Bank Deposit";
        DepositNo: Code[20];
        GLAccountNo: Code[20];
    begin
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        DepositNo := LibraryUtility.GenerateGUID();
        GLAccountNo := LibraryERM.CreateGLAccountNo();

        BankDeposit.OpenNew();
        BankDeposit."No.".SetValue(DepositNo);
        BankDeposit.Subform."Account Type".SetValue(GenJournalLine."Account Type"::"G/L Account");
        BankDeposit.Subform."Account No.".SetValue(GLAccountNo);
        BankDeposit.Close();

        BankDepositHeader.Get(DepositNo);
        BankDepositHeader.TestField("Journal Template Name", GenJournalBatch."Journal Template Name");
        BankDepositHeader.TestField("Journal Batch Name", GenJournalBatch.Name);
        GenJournalLine.Get(GenJournalBatch."Journal Template Name", GenJournalBatch.Name, '10000');
        GenJournalLine.TestField("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.TestField("Account No.", GLAccountNo);

        BankDeposit.Trap();
        BankDepositHeader.SetRecFilter();
        Page.Run(Page::"Bank Deposit", BankDepositHeader);
        BankDeposit.Subform."Account Type".AssertEquals(GenJournalLine."Account Type");
        BankDeposit.Subform."Account No.".AssertEquals(GenJournalLine."Account No.");
        BankDeposit.Close();
    end;

    local procedure CreateBankDepositHeader(var BankDepositHeader: Record "Bank Deposit Header"; CurrencyCode: Code[10])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalBatch(GenJournalBatch);
        BankDepositHeader."No." := LibraryUtility.GenerateGUID();
        BankDepositHeader."Journal Template Name" := GenJournalBatch."Journal Template Name";
        BankDepositHeader."Journal Batch Name" := GenJournalBatch.Name;
        BankDepositHeader."Posting Date" := WorkDate();
        BankDepositHeader."Document Date" := WorkDate();
        BankDepositHeader.Validate("Bank Account No.", CreateBankAccount(CurrencyCode));
        BankDepositHeader."Total Deposit Amount" := LibraryRandom.RandDec(10, 2);
        BankDepositHeader.Insert();
    end;

    local procedure CreatePostedBankDepositForCustomer(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; var PostedBankDepositLine: Record "Posted Bank Deposit Line")
    begin
        PostedBankDepositHeader."No." := LibraryUtility.GenerateGUID();
        PostedBankDepositHeader.Insert();

        PostedBankDepositLine."Bank Deposit No." := PostedBankDepositHeader."No.";
        PostedBankDepositLine."Line No." := LibraryRandom.RandInt(10);
        PostedBankDepositLine."Account Type" := PostedBankDepositLine."Account Type"::Customer;
        PostedBankDepositLine."Document Type" := PostedBankDepositLine."Document Type"::Payment;
        PostedBankDepositLine."Account No." := CreateCustomer();
        PostedBankDepositLine.Insert();
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Name := LibraryUtility.GenerateGUID();
        GenJournalTemplate.Type := GenJournalTemplate.Type::"Bank Deposits";
        GenJournalTemplate."Page ID" := PAGE::"Bank Deposit";
        GenJournalTemplate.Insert();

        GenJournalBatch."Journal Template Name" := GenJournalTemplate.Name;
        GenJournalBatch.Name := LibraryUtility.GenerateGUID();
        GenJournalBatch.Insert();
    end;

    local procedure CreateGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; BankDepositHeader: Record "Bank Deposit Header"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    begin
        GenJournalLine."Journal Template Name" := BankDepositHeader."Journal Template Name";
        GenJournalLine."Journal Batch Name" := BankDepositHeader."Journal Batch Name";
        GenJournalLine."Line No." := LibraryRandom.RandInt(10);
        GenJournalLine."Posting Date" := WorkDate();
        GenJournalLine."Document Type" := GenJournalLine."Document Type"::Payment;
        GenJournalLine."Account Type" := AccountType;
        GenJournalLine."Account No." := AccountNo;
        GenJournalLine.Amount := -BankDepositHeader."Total Deposit Amount";
        GenJournalLine."Document No." := LibraryUTUtility.GetNewCode();
        GenJournalLine.Description := GenJournalLine."Document No.";
        GenJournalLine."Source Type" := GenJournalLine."Source Type"::"Bank Account";
        GenJournalLine."Source Code" := BankDepositHeader."Bank Account No.";
        GenJournalLine.Insert();
    end;

    local procedure CreateBankAccount(CurrencyCode: Code[10]): Code[20]
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        BankAccount.Validate("Currency Code", CurrencyCode);
        BankAccount.Modify(true);
        exit(BankAccount."No.");
    end;

    local procedure CreateGLAccount(): Code[20]
    begin
        exit(LibraryERM.CreateGLAccountNo());
    end;

    local procedure CreateCustomer(): Code[20]
    var
        Customer: Record Customer;
    begin
        Customer."No." := LibraryUTUtility.GetNewCode();
        Customer.Insert(true);
        exit(Customer."No.");
    end;

    local procedure CreateDimension() DimensionSetID: Integer
    var
        DimensionValue: Record "Dimension Value";
        Dimension: Record Dimension;
    begin
        Dimension.Code := LibraryUTUtility.GetNewCode();
        Dimension.Insert();
        DimensionValue.Code := LibraryUTUtility.GetNewCode();
        DimensionValue."Dimension Code" := Dimension.Code;
        DimensionValue.Insert();
        DimensionSetID := CreateDimensionSetEntry(DimensionValue."Dimension Code", DimensionValue.Code);
        LibraryVariableStorage.Enqueue(DimensionValue."Dimension Code");  // Enqueue value for Page Handler - EditDimensionSetEntriesPageHandler or DimensionSetEntriesPageHandler.
    end;

    local procedure CreateDimensionSetEntry(DimensionCode: Code[20]; DimensionValueCode: Code[20]): Integer
    var
        DimensionSetEntry: Record "Dimension Set Entry";
        DimensionSetEntry2: Record "Dimension Set Entry";
    begin
        DimensionSetEntry2.FindLast();
        DimensionSetEntry."Dimension Set ID" := DimensionSetEntry2."Dimension Set ID" + 1;
        DimensionSetEntry."Dimension Code" := DimensionCode;
        DimensionSetEntry."Dimension Value Code" := DimensionValueCode;
        DimensionSetEntry."Dimension Value ID" := DimensionSetEntry."Dimension Set ID";
        DimensionSetEntry.Insert();
        exit(DimensionSetEntry."Dimension Set ID");
    end;

    local procedure CreateCustomerLedgerEntry(var CustLedgerEntry: Record "Cust. Ledger Entry"; DocumentNo: Code[20]; CustomerNo: Code[20])
    var
        CustLedgerEntry2: Record "Cust. Ledger Entry";
    begin
        CustLedgerEntry2.FindLast();
        CustLedgerEntry."Entry No." := CustLedgerEntry2."Entry No." + 1;
        CustLedgerEntry."Document Type" := CustLedgerEntry."Document Type"::Invoice;
        CustLedgerEntry."Document No." := DocumentNo;
        CustLedgerEntry.Open := true;
        CustLedgerEntry."Customer No." := CustomerNo;
        CustLedgerEntry.Insert();
    end;

    local procedure CreateDetailedCustomerLedgerEntry(CustLedgerEntryNo: Integer; CustomerNo: Code[20])
    var
        DetailedCustomerLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedCustomerLedgEntry2: Record "Detailed Cust. Ledg. Entry";
    begin
        DetailedCustomerLedgEntry2.FindLast();
        DetailedCustomerLedgEntry."Entry No." := DetailedCustomerLedgEntry2."Entry No." + 1;
        DetailedCustomerLedgEntry."Cust. Ledger Entry No." := CustLedgerEntryNo;
        DetailedCustomerLedgEntry."Customer No." := CustomerNo;
        DetailedCustomerLedgEntry.Amount := LibraryRandom.RandDec(10, 2);
        DetailedCustomerLedgEntry.Insert();
    end;

    local procedure CreatePostedSalesInvoiceLine(SellToCustomerNo: Code[20])
    var
        SalesInvoiceLine: Record "Sales Invoice Line";
    begin
        SalesInvoiceLine."Document No." := LibraryUTUtility.GetNewCode();
        SalesInvoiceLine."Sell-to Customer No." := SellToCustomerNo;
        SalesInvoiceLine."Unit Price" := LibraryRandom.RandDec(10, 2);
        SalesInvoiceLine.Insert();
    end;

    local procedure OpenDepositPage(var BankDeposit: TestPage "Bank Deposit"; BankDepositHeader: Record "Bank Deposit Header")
    begin
        BankDeposit.Trap();
        BankDepositHeader.SetRecFilter();
        Page.Run(Page::"Bank Deposit", BankDepositHeader);
    end;

    local procedure OpenDepositSubForm(var BankDeposit: TestPage "Bank Deposit"; BankDepositHeader: Record "Bank Deposit Header"; GenJournalLine: Record "Gen. Journal Line")
    begin
        OpenDepositPage(BankDeposit, BankDepositHeader);
        BankDeposit.Subform.GotoRecord(GenJournalLine);
    end;

    local procedure OpenPostedBankDepositPage(var PostedBankDeposit: TestPage "Posted Bank Deposit"; PostedBankDepositHeader: Record "Posted Bank Deposit Header")
    begin
        PostedBankDeposit.OpenEdit();
        PostedBankDeposit.GotoRecord(PostedBankDepositHeader);
    end;

    local procedure OpenDepositAndAddTwoGLLines(var BankDeposit: TestPage "Bank Deposit"; BankDepositHeader: Record "Bank Deposit Header"; Amount: Decimal)
    var
        GenJournalAccountType: Enum "Gen. Journal Account Type";
    begin
        OpenDepositPage(BankDeposit, BankDepositHeader);
        BankDeposit.Subform."Account Type".SetValue(GenJournalAccountType::"G/L Account");
        BankDeposit.Subform."Account No.".SetValue(LibraryERM.CreateGLAccountNo());
        BankDeposit.Subform."Credit Amount".SetValue(Amount);
        BankDeposit.Subform.Next();
        BankDeposit.Subform."Account Type".SetValue(GenJournalAccountType::"G/L Account");
        BankDeposit.Subform."Account No.".SetValue(LibraryERM.CreateGLAccountNo());
        BankDeposit.Subform."Credit Amount".SetValue(Amount);
        BankDeposit.Subform.Next();
    end;

    local procedure UpdateDimensionOnPostedBankDepositHeader(var PostedBankDepositHeader: Record "Posted Bank Deposit Header"; DimensionSetID: Integer)
    begin
        PostedBankDepositHeader."Dimension Set ID" := DimensionSetID;
        PostedBankDepositHeader.Modify();
    end;

    local procedure VerifyCurrencyCodeAndFactor(BankDepositHeader: Record "Bank Deposit Header"; CurrencyCode: Code[10]; CurrencyFactor: Decimal; Amount: Decimal; AmountLCY: Decimal)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        BankDepositHeader.Find();
        BankDepositHeader.TestField("Currency Code", CurrencyCode);
        BankDepositHeader.TestField("Currency Factor", CurrencyFactor);

        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.SetRange("Posting Date", BankDepositHeader."Posting Date");
        GenJournalLine.SetRange("Bal. Account Type", GenJournalLine."Bal. Account Type"::"Bank Account");
        GenJournalLine.SetRange("Bal. Account No.", BankDepositHeader."Bank Account No.");
        GenJournalLine.SetRange("Currency Code", CurrencyCode);
        GenJournalLine.SetRange("Currency Factor", CurrencyFactor);
        Assert.RecordCount(GenJournalLine, 2);

        GenJournalLine.FindFirst();
        GenJournalLine.TestField(Amount, -Amount);
        GenJournalLine.TestField("Amount (LCY)", -AmountLCY);
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure EditDimensionSetEntriesPageHandler(var EditDimensionSetEntries: TestPage "Edit Dimension Set Entries")
    var
        DimensionValue: Record "Dimension Value";
    begin
        DimensionValue.SetRange("Global Dimension No.", 1);  // Global Dimension - 1.
        DimensionValue.FindFirst();
        EditDimensionSetEntries."Dimension Code".SetValue(DimensionValue."Dimension Code");
        EditDimensionSetEntries.DimensionValueCode.SetValue(DimensionValue.Code);
        EditDimensionSetEntries.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure DimensionSetEntriesPageHandler(var DimensionSetEntries: TestPage "Dimension Set Entries")
    var
        DimensionCode: Variant;
    begin
        LibraryVariableStorage.Dequeue(DimensionCode);
        DimensionSetEntries."Dimension Code".AssertEquals(DimensionCode);
        DimensionSetEntries.OK().Invoke();
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure DepositRequestPageHandler(var BankDeposit: TestRequestPage "Bank Deposit")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        BankDeposit."Posted Bank Deposit Header".SetFilter("No.", No);
        BankDeposit.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    [Scope('OnPrem')]
    procedure DepositTestReportRequestPageHandler(var BankDepositTestReport: TestRequestPage "Bank Deposit Test Report")
    var
        No: Variant;
    begin
        LibraryVariableStorage.Dequeue(No);
        BankDepositTestReport."Bank Deposit Header".SetFilter("No.", No);
        BankDepositTestReport.SaveAsXml(LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure ApplyCustomerEntriesPageHandler(var ApplyCustomerEntries: TestPage "Apply Customer Entries")
    var
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerNo: Variant;
        RemainingAmount: Variant;
    begin
        LibraryVariableStorage.Dequeue(CustomerNo);
        LibraryVariableStorage.Dequeue(RemainingAmount);
        ApplyCustomerEntries."Document Type".AssertEquals(CustLedgerEntry."Document Type"::Invoice);
        ApplyCustomerEntries."Customer No.".AssertEquals(CustomerNo);
        ApplyCustomerEntries."Remaining Amount".AssertEquals(RemainingAmount);
        ApplyCustomerEntries.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GeneralJournalTemplateListPageHandler(var GeneralJournalTemplateList: TestPage "General Journal Template List")
    begin
        GeneralJournalTemplateList.FILTER.SetFilter(Name, LibraryVariableStorage.DequeueText());
        GeneralJournalTemplateList.OK().Invoke();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GeneralJournalBatchesMPH(var GeneralJournalBatches: TestPage "General Journal Batches")
    begin
        GeneralJournalBatches.FILTER.SetFilter(Name, LibraryVariableStorage.DequeueText());
        GeneralJournalBatches.OK().Invoke();
    end;

    [ReportHandler]
    [Scope('OnPrem')]
    procedure DepositReportHandler(var BankDeposit: Report "Bank Deposit")
    begin
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
    procedure ConfirmHandlerTRUE(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeInitialize(var InitializeHandled: Boolean)
    begin
    end;

    [IntegrationEvent(false, false)]
    local procedure OnAfterInitialize(var InitializeHandled: Boolean)
    begin
    end;
}

