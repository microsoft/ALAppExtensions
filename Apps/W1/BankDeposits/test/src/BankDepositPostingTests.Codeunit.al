codeunit 139769 "Bank Deposit Posting Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Bank Deposit] [Posting]
    end;

    var
        Assert: Codeunit Assert;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryERMCountryData: Codeunit "Library - ERM Country Data";
        LibraryInventory: Codeunit "Library - Inventory";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryUtility: Codeunit "Library - Utility";
        LibrarySetupStorage: Codeunit "Library - Setup Storage";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;
        InitializeHandled: Boolean;
        DimensionErr: Label 'A dimension used in Gen. Journal Line';
        GLEntryErr: Label 'Unexpected G/L entries amount.';
        PostedDepositLinkErr: Label 'Posted Deposit is missing a link.', Locked = true;
        SingleHeaderAllowedErr: Label 'Only one %1 is allowed for each %2. Choose Change Batch action if you want to create a new bank deposit.', Locked = true;
        BatchNameErr: Label 'Batch Name must be %1 on %2', Comment = '%1 - Batch Name , %2 - Field Name';

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure GLBankDeposit()
    var
        GLAccount: Record "G/L Account";
        BankAccount: Record "Bank Account";
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        GLEntry: Record "G/L Entry";
    begin
        // Verify G/L Entry after post Deposit with Account Type GL as Payment, Vendor as Refund and Bank without Document Type.

        // Setup: Create GL Account, Vendor and Bank Account.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateBankAccount(BankAccount);

        // Exercise.
        SetupAndPostBankDeposit(BankDepositHeader, GLAccount."No.", Vendor."No.", BankAccount."No.");

        // Verify: Verify G/L Entry after post Deposit with Account Type GL, Vendor and Bank.
        Assert.AreEqual(
          BankDepositHeader."Total Deposit Amount", CalcGLEntryAmount(
            Vendor."No.", GLEntry."Bal. Account Type"::Vendor, GLEntry."Document Type"::Refund) + CalcGLEntryAmount(
            GLAccount."No.", GLEntry."Bal. Account Type"::"G/L Account", GLEntry."Document Type"::Payment) + CalcGLEntryAmount(
            BankAccount."No.", GLEntry."Bal. Account Type"::"Bank Account", GLEntry."Document Type"::" "), GLEntryErr);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure DoNotPostBankDepositAsLumpSum()
    var
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        // Verify G/L Entry after post Deposit with Checked Force Doc. Balance.

        // Setup: Create GL Account and Vendor, create Bank Deposit with Account Type GL, Customer.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibrarySales.CreateCustomer(Customer);
        CreateMultilineDepositDocument(BankDepositHeader, Customer."No.", GenJournalLine."Account Type"::Customer, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", GenJournalLine."Document Type"::Payment);

        // Update Total Deposit Amount on header, set Post as Lump Sum to false and post Bank Deposit.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        BankDepositHeader."Post as Lump Sum" := false;
        BankDepositHeader.Modify();

        // Exercise.
        PostBankDeposit(BankDepositHeader);

        // Verify: Verify G/L Entry after post Deposit with Checked Force Doc. Balance.
        Assert.AreEqual(
          BankDepositHeader."Total Deposit Amount", CalcGLEntryAmount(
            Customer."No.", GLEntry."Bal. Account Type"::Customer, GLEntry."Document Type"::Payment) + CalcGLEntryAmount(
            GLAccount."No.", GLEntry."Bal. Account Type"::"G/L Account", GLEntry."Document Type"::Payment), GLEntryErr);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostBankDepositAsLumpSum()
    var
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        TransactionNo: Integer;
    begin
        // Verify that when bank deposit has multiple lines, and 'Post as Lump Sum' is checked - it posts it as lump sum

        // Setup: Create GL Account and Vendor, create Bank Deposit with Account Type GL, Vendor.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        CreateMultilineDepositDocument(
          BankDepositHeader, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", Vendor."No.", GenJournalLine."Account Type"::Vendor,
          GenJournalLine."Document Type"::" ", true);

        // Update Total Deposit Amount on header, set Post as Lump Sum to true and post Bank Deposit.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        BankDepositHeader."Post as Lump Sum" := true;
        BankDepositHeader.Modify();
        SourceCodeSetup.Get();
        SourceCodeSetup."Bank Deposit" := 'BankDep';
        SourceCodeSetup.Modify();

        // Exercise.
        PostBankDeposit(BankDepositHeader);

        // Verify: Verify G/L Entry after post Deposit with Unchecked Force Doc. Balance.
        GLEntry.SetRange("Document No.", BankDepositHeader."No.");
        GLEntry.SetRange(Amount, BankDepositHeader."Total Deposit Amount");
        GLEntry.FindFirst();
        GLEntry.TestField("Document Type", GLEntry."Document Type"::" ");

        // Verify all entries are in the same transaction
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        TransactionNo := 0;
        PostedBankDepositLine.FindSet();
        repeat
            GLEntry.Reset();
            GLEntry.Get(PostedBankDepositLine."Entry No.");
            if TransactionNo = 0 then
                TransactionNo := GLEntry."Transaction No.";
            Assert.AreEqual(GLEntry."Transaction No.", TransactionNo, 'All GLEntries should be in the same transaction');
        until PostedBankDepositLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostBankDepositAsLumpSumOneLine()
    var
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
        TransactionNo: Integer;
    begin
        // Bug 539413: Verify that when bank deposit has one line, and 'Post as Lump Sum' is checked - it posts it as lump sum

        // Setup: Create GL Account and Vendor, create Bank Deposit with Account Type GL, Vendor.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        CreateBankDeposit(BankDepositHeader, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", -1, GenJournalLine."Document Type"::" ");

        // Update Total Deposit Amount on header, set Post as Lump Sum to true and post Bank Deposit.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        BankDepositHeader."Post as Lump Sum" := true;
        BankDepositHeader.Modify();
        SourceCodeSetup.Get();
        SourceCodeSetup."Bank Deposit" := 'BankDep';
        SourceCodeSetup.Modify();

        // Exercise.
        PostBankDeposit(BankDepositHeader);

        // Verify: Verify G/L Entry after post Deposit with Unchecked Force Doc. Balance.
        GLEntry.SetRange("Document No.", BankDepositHeader."No.");
        GLEntry.SetRange(Amount, BankDepositHeader."Total Deposit Amount");
        GLEntry.FindFirst();
        GLEntry.TestField("Document Type", GLEntry."Document Type"::" ");

        // Verify all entries are in the same transaction
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        TransactionNo := 0;
        PostedBankDepositLine.FindSet();
        repeat
            GLEntry.Reset();
            GLEntry.Get(PostedBankDepositLine."Entry No.");
            if TransactionNo = 0 then
                TransactionNo := GLEntry."Transaction No.";
            Assert.AreEqual(GLEntry."Transaction No.", TransactionNo, 'All GLEntries should be in the same transaction');
        until PostedBankDepositLine.Next() = 0;
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostingAsLumpSumInDifferentDocumentsShouldntBePossible()
    var
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        First: Boolean;
    begin
        // Verify G/L Entry after post Deposit with Unchecked Force Doc. Balance.

        // Setup: Create GL Account and Vendor, create Bank Deposit with Account Type GL, Vendor.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        CreateMultilineDepositDocument(
          BankDepositHeader, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", Vendor."No.", GenJournalLine."Account Type"::Vendor,
          GenJournalLine."Document Type"::" ", true);

        // Update Total Deposit Amount on header, set Post as Lump Sum to true and post Bank Deposit.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        BankDepositHeader."Post as Lump Sum" := true;
        BankDepositHeader.Modify();
        SourceCodeSetup.Get();
        SourceCodeSetup."Bank Deposit" := 'BankDep';
        SourceCodeSetup.Modify();

        // [WHEN] Lines have different document no, type or date
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        First := true;
        repeat
            if First then
                First := false
            else begin
                GenJournalLine."Posting Date" += 1;
                GenJournalLine.Modify();
            end;
        until GenJournalLine.Next() = 0;

        // Exercise. It should fail the same transaction validation
        asserterror PostBankDeposit(BankDepositHeader);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure FullyAppliedSalesInvoice()
    var
        Item: Record Item;
        TaxGroup: Record "Tax Group";
        Customer: Record Customer;
        BankDepositHeader: Record "Bank Deposit Header";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
    begin
        // Verify fully applied Customer Ledger Entry after post Deposit.

        // Setup: Create Sales Document and post, create Bank Deposit with Applies-to Doc. No. and post.
        Initialize();
        LibraryERM.CreateTaxGroup(TaxGroup);
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        CreateAndPostSalesDocument(
          SalesLine, Customer."No.", SalesLine."Document Type"::Order, SalesLine.Type::Item, Item."No.",
          LibraryRandom.RandInt(10), LibraryRandom.RandDec(100, 2));  // Using Random value for Quantity and Unit Price.
        CreateBankDeposit(
          BankDepositHeader, SalesLine."Sell-to Customer No.", GenJournalLine."Account Type"::Customer, -1);  // Using 1 as Sign Factor.
        UpdateGenJournalLine(BankDepositHeader, SalesLine);
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);

        // Exercise.
        PostBankDeposit(BankDepositHeader);

        // Verify: Verify fully applied Customer Ledger Entry after post Deposit.
        CustLedgerEntry.SetRange("Document Type", CustLedgerEntry."Document Type"::Invoice);
        CustLedgerEntry.SetRange("Customer No.", SalesLine."Sell-to Customer No.");
        CustLedgerEntry.FindFirst();
        CustLedgerEntry.TestField("Closed by Amount", BankDepositHeader."Total Deposit Amount");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure ErrorOnPostVendPaymentBankDepositWithDefaultDimension()
    var
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankAccCommentLine: Record "Bank Acc. Comment Line";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Verify Error while posting Bank Deposit with different default Dimension on Vendor.

        // Setup: Create Vendor, create Bank Deposit with Dimension.
        Initialize();
        LibraryPurchase.CreateVendor(Vendor);
        SetupFoBankDepositWithDimension(
          BankDepositHeader, DATABASE::Vendor, Vendor."No.", GenJournalLine."Account Type"::Vendor, 1);  // Using 1 as Sign Factor.

        // Exercise.
        asserterror PostBankDeposit(BankDepositHeader);

        // Verify: Verify Error while posting Bank Deposit with different Dimension.
        Assert.ExpectedError(DimensionErr);
        // Verify: No Posted Bank Deposit Header, Lines or Comments with the same Deposit "No." exist.
        Assert.IsFalse(PostedBankDepositHeader.Get(BankDepositHeader."No."), 'The Posted Bank Deposit Header should not exist.');
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        Assert.IsTrue(PostedBankDepositLine.IsEmpty(), 'The Posted Bank Deposit Line should be empty.');
        BankAccCommentLine.SetRange("Bank Account No.", BankDepositHeader."Bank Account No.");
        BankAccCommentLine.SetRange("Table Name", BankAccCommentLine."Table Name"::"Posted Bank Deposit Header");
        BankAccCommentLine.SetRange("No.", BankDepositHeader."No.");
        Assert.IsTrue(BankAccCommentLine.IsEmpty(), 'The Bank Account Comment Line should be empty.');
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure ErrorOnPostCustPaymentBankDepositWithDefaultDimension()
    var
        Customer: Record Customer;
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        BankAccCommentLine: Record "Bank Acc. Comment Line";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Verify Error while posting Bank Deposit with different default Dimension on Customer.

        // Setup: Create Customer, create Bank Deposit with Dimension.
        Initialize();
        LibrarySales.CreateCustomer(Customer);
        SetupFoBankDepositWithDimension(
          BankDepositHeader, DATABASE::Customer, Customer."No.", GenJournalLine."Account Type"::Customer, -1);  // Using 1 as Sign Factor.

        // Exercise.
        asserterror PostBankDeposit(BankDepositHeader);

        // Verify: Verify Error while posting Bank Deposit with different Dimension.
        Assert.ExpectedError(DimensionErr);
        // Verify: No Posted Bank Deposit Header, Lines or Comments with the same Deposit "No." exist.
        Assert.IsFalse(PostedBankDepositHeader.Get(BankDepositHeader."No."), 'The Posted Bank Deposit Header should not exist.');
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        Assert.IsTrue(PostedBankDepositLine.IsEmpty(), 'The Posted Bank Deposit Line should be empty.');
        BankAccCommentLine.SetRange("Bank Account No.", BankDepositHeader."Bank Account No.");
        BankAccCommentLine.SetRange("Table Name", BankAccCommentLine."Table Name"::"Posted Bank Deposit Header");
        BankAccCommentLine.SetRange("No.", BankDepositHeader."No.");
        Assert.IsTrue(BankAccCommentLine.IsEmpty(), 'The Bank Account Comment Line should be empty.');

    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostedBankDepositAndBankAccLedger()
    var
        BankAccount: Record "Bank Account";
        BankDepositHeader: Record "Bank Deposit Header";
        GLAccount: Record "G/L Account";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        Vendor: Record Vendor;
    begin
        // Verify Posted Deposit after post Deposit and Bank Account Ledger Entry.

        // Setup: Create GL Account, Vendor and Bank Account.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        LibraryERM.CreateBankAccount(BankAccount);

        // Exercise.
        SetupAndPostBankDeposit(BankDepositHeader, GLAccount."No.", Vendor."No.", BankAccount."No.");

        // Verify: Verify Posted Deposit after post Deposit and Bank Account Ledger Entry.

        PostedBankDepositHeader.Get(BankDepositHeader."No.");
        PostedBankDepositHeader.TestField("Bank Account No.", BankDepositHeader."Bank Account No.");
        PostedBankDepositHeader.TestField("Total Deposit Amount", BankDepositHeader."Total Deposit Amount");
        VerifyBankAccLedgerEntryAmount(BankDepositHeader."Bank Account No.", BankDepositHeader."Total Deposit Amount");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure BankDepositWithNewGenJournalBatch()
    var
        GLAccount: Record "G/L Account";
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        // Verify Journal Batch Name in G/L Entry after post Deposit with Account Type GL.

        // Setup: Create GL Account, Deposit and update Total Deposit Amount on header.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        CreateBankDeposit(BankDepositHeader, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", 1);
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);

        // Exercise.
        PostBankDeposit(BankDepositHeader);

        // Verify: Verify Journal Batch Name in G/L Entry after post Deposit with Account Type GL.
#pragma warning disable AA0210
        GLEntry.SetRange("Bal. Account No.", GLAccount."No.");
#pragma warning restore
        GLEntry.FindFirst();
        GLEntry.TestField("Journal Batch Name", BankDepositHeader."Journal Batch Name");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostBankDepositWithLink()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
    begin
        // [FEATURE] [Record Link]
        // [SCENARIO 378922] Deposit posting procedure copy links to posted document
        Initialize();

        // [GIVEN] Deposit with random Link added
        CreateBankDeposit(BankDepositHeader, LibrarySales.CreateCustomerNo(), GenJournalLine."Account Type"::Customer, -1);
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        BankDepositHeader.AddLink(LibraryUtility.GenerateRandomText(10));

        // [WHEN] Post Deposit
        PostBankDeposit(BankDepositHeader);

        // [THEN] Posted Depostit has attached link
        PostedBankDepositHeader.Get(BankDepositHeader."No.");
        Assert.IsTrue(PostedBankDepositHeader.HasLinks, PostedDepositLinkErr);
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler')]
    procedure DuplicateBankDepositForSameBatchWithFilter()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        // [SCENARIO 313506] Check for existing Deposit Headers for Gen. Journal Batch on insert new record disregards filters
        Initialize();

        // [GIVEN] Gen. Journal Batch for Deposits template
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");

        // [GIVEN] Deposit Header with "Bank Account No." = "BANK01"
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);

        // [WHEN] Create new Deposit Header for the same Gen. Journal Batch with filter set to "Bank Account No." <> "BANK01"
        BankDepositHeader.SetFilter("Bank Account No.", '<>%1', BankDepositHeader."Bank Account No.");
        asserterror CreateBankDepositHeader(BankDepositHeader, GenJournalBatch);

        // [THEN] Error: "Only one Deposit Header is allowed for each Gen. Journal Batch."
        Assert.ExpectedErrorCode('Dialog');
        Assert.ExpectedError(StrSubstNo(SingleHeaderAllowedErr, BankDepositHeader.TableCaption, GenJournalBatch.TableCaption));
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure CheckGenJournalBatchNameShouldNotBeChanged()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PreviousBatchName: Code[10];
    begin
        // [SCENARIO 472099] Post Bank Deposits and Verify Batch Name: Batch name should not be changed.
        // IF Increment Batch Name is disabled on the General Journal Template.
        Initialize();

        // [GIVEN] Create Gen. Journal Template with Increment Batch Name and Batch Name for Deposits template.
        CreateGenJournalTemplateAndBatchWithIncrementBatchName(
            GenJournalTemplate,
            GenJournalBatch,
            GenJournalTemplate.Type::"Bank Deposits",
            false);

        // [THEN] Save Batch Name in a variable.
        PreviousBatchName := GenJournalBatch.Name;

        // [GIVEN] Create a Deposit Header with Bank Account.
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);

        // [GIVEN] Create a Deposit Line with Account Type "GL Account".
        LibraryERM.CreateGeneralJnlLine(
                  GenJournalLine,
                  BankDepositHeader."Journal Template Name",
                  BankDepositHeader."Journal Batch Name",
                  GenJournalLine."Document Type"::" ",
                  GenJournalLine."Account Type"::"G/L Account",
                  LibraryERM.CreateGLAccountNo(),
                  -LibraryRandom.RandInt(1000));

        // [THEN] Update Deposit Amount on Bank Deposit Header.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);

        // [THEN] Post Bank Deposit.
        PostBankDeposit(BankDepositHeader);

        // [VERIFY] The Batch Name must be same as Increment Batch Name is False.
        Assert.AreEqual(
            PreviousBatchName,
            GetBatchNameFromGenJournalTemplate(GenJournalTemplate),
            StrSubstNo(BatchNameErr, PreviousBatchName, GenJournalTemplate.FieldCaption(Name)));
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostingNegativeAndPositiveLinesShouldBePossible()
    var
        GLAccount: Record "G/L Account";
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        PostedBankDepositHeader: Record "Posted Bank Deposit Header";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        Amount: Decimal;
    begin
        // [SCENARIO 535786] A bank deposit can be posted even if it has negative "Credit Amount" lines that have been marked as "Correction"
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);
        // [GIVEN] A deposit with positive and negative Credit Amount lines.
        Amount := 100;
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", -Amount);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", 0);
        GenJournalLine.Validate("Credit Amount", -2 * Amount);
        GenJournalLine.Modify();
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        Commit();
        // [THEN] It should be possible to post the deposit.
        PostBankDeposit(BankDepositHeader);
        // [THEN] The total amount of the deposit should be the sum of the lines.
        PostedBankDepositHeader.SetAutoCalcFields("Total Deposit Lines");
        PostedBankDepositHeader.Get(BankDepositHeader."No.");
        Assert.AreEqual(-Amount, PostedBankDepositHeader."Total Deposit Lines", 'The total amount of the deposit should be the sum of the lines');
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostLumpSumNegativeLineWithSameAmountAsTotalDeposit()
    var
        GLAccount: Record "G/L Account";
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        GenJournalDocumentType: Enum "Gen. Journal Document Type";
        TotalAmount: Decimal;
    begin
        // [SCENARIO 538420] A Bank deposit is posted with lump sum and a negative line that equals the total amount of the deposit. The lines should be transferred to the Posted Bank Deposit Lines.
        // [GIVEN] A Bank deposit with lump sum and a negative line that equals the total amount.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);
        TotalAmount := 500;
        BankDepositHeader."Post as Lump Sum" := true;
        BankDepositHeader."Total Deposit Amount" := TotalAmount;
        BankDepositHeader."Posting Date" := WorkDate();
        BankDepositHeader."Document Date" := WorkDate();
        BankDepositHeader.Modify();
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", -2 * TotalAmount);
        GenJournalLine."Posting Date" := WorkDate();
        GenJournalLine."Document No." := BankDepositHeader."No.";
        GenJournalLine.Modify();
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalDocumentType::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", TotalAmount);
        GenJournalLine."Posting Date" := WorkDate();
        GenJournalLine."Document No." := BankDepositHeader."No.";
        GenJournalLine.Modify();
        Commit();
        // [WHEN] Posting the bank deposit.
        PostBankDeposit(BankDepositHeader);
        // [THEN] Both lines should be transferred.
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        Assert.AreEqual(2, PostedBankDepositLine.Count(), 'The same number of lines posted should be transferred as part of the bank deposit.');
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure NavigatePageOfAPostedBankDepositShowsRelatedEntries()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalLine: Record "Gen. Journal Line";
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        BankDeposit: TestPage "Bank Deposit";
        PostedBankDeposit: TestPage "Posted Bank Deposit";
        Navigate: TestPage Navigate;
        BankEntryFound, CustomerEntryFound : Boolean;
        TableName: Text;
    begin
        // [SCENARIO 537831] Related entries are shown on the Navigate page of a posted bank deposit
        Initialize();
        // [GIVEN] A Posted Bank Deposit with a G/L Account and a Customer.
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);
        BankDepositHeader."Total Deposit Amount" := 1000;
        BankDepositHeader.Modify();
        BankDeposit.Trap();
        BankDepositHeader.SetRecFilter();
        Page.Run(Page::"Bank Deposit", BankDepositHeader);
        LibraryERM.CreateGLAccount(GLAccount);
        BankDeposit.Subform."Account Type".SetValue(GenJournalLine."Account Type"::"G/L Account");
        BankDeposit.Subform."Account No.".SetValue(GLAccount."No.");
        BankDeposit.Subform."Credit Amount".SetValue(-10);
        BankDeposit.Subform.Next();
        LibrarySales.CreateCustomer(Customer);
        BankDeposit.Subform."Account Type".SetValue(GenJournalLine."Account Type"::Customer);
        BankDeposit.Subform."Account No.".SetValue(Customer."No.");
        BankDeposit.Subform."Credit Amount".SetValue(1010);
        PostedBankDeposit.Trap();
        BankDeposit.Post.Invoke();
        // [WHEN] Navigate action is invoked from the posted bank deposit
        Navigate.Trap();
        PostedBankDeposit."&Navigate".Invoke();

        repeat
            TableName := Navigate."Table Name".Value();
            case TableName of
                BankAccountLedgerEntry.TableCaption():
                    BankEntryFound := true;
                CustLedgerEntry.TableCaption():
                    CustomerEntryFound := true;
            end;
        until (not Navigate.Next());
        // [THEN] The entries posted are found.
        Assert.IsTrue(BankEntryFound, 'Bank Account Ledger Entry should be found');
        Assert.IsTrue(CustomerEntryFound, 'Customer Ledger Entry should be found');
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostedBankDepositReportShowsCustomerApplications()
    var
        Item: Record Item;
        TaxGroup: Record "Tax Group";
        Customer: Record Customer;
        BankDepositHeader: Record "Bank Deposit Header";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        SalesLine: Record "Sales Line";
        GenJournalLine: Record "Gen. Journal Line";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        PaymentCustLedgerEntry: Record "Cust. Ledger Entry";
        AppliedCustLedgerEntry: Record "Cust. Ledger Entry" temporary;
        BankDeposit: Report "Bank Deposit";
        EntryApplicationMgt: Codeunit "Entry Application Mgt";
        InvoiceEntryNo: Integer;
    begin
        // [SCENARIO 542679] Applications on Customer Ledger Entries are correctly retrieved for posted bank deposits
        // [GIVEN] A posted bank deposit fully applied to an open sales document.
        Initialize();
        LibraryERM.CreateTaxGroup(TaxGroup);
        LibrarySales.CreateCustomer(Customer);
        LibraryInventory.CreateItem(Item);
        CreateAndPostSalesDocument(
          SalesLine, Customer."No.", SalesLine."Document Type"::Order, SalesLine.Type::Item, Item."No.",
          LibraryRandom.RandInt(10), LibraryRandom.RandDec(100, 2));
        CreateBankDeposit(
          BankDepositHeader, SalesLine."Sell-to Customer No.", GenJournalLine."Account Type"::Customer, -1);
        CustLedgerEntry.SetRange("Customer No.", Customer."No.");
        CustLedgerEntry.FindLast();
        InvoiceEntryNo := CustLedgerEntry."Entry No.";
        UpdateGenJournalLine(BankDepositHeader, SalesLine);
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);

        PostBankDeposit(BankDepositHeader);

        // [WHEN] Getting the applied customer ledger entries as the report does
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        PostedBankDepositLine.FindFirst();
        BankDeposit.FilterDepositCustLedgerEntry(PostedBankDepositLine, PaymentCustLedgerEntry);
        // [THEN] Only one entry is attached to the deposit line
        Assert.RecordCount(PaymentCustLedgerEntry, 1);
        PaymentCustLedgerEntry.FindFirst();
        // [THEN] Only one invoice entry is found as applied
        EntryApplicationMgt.GetAppliedCustEntries(AppliedCustLedgerEntry, PaymentCustLedgerEntry, false);
        Assert.RecordCount(AppliedCustLedgerEntry, 1);
        Assert.AreEqual(AppliedCustLedgerEntry."Entry No.", InvoiceEntryNo, 'The found entry should be the invoice.');
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    procedure PostedBankDepositReportShowsVendorApplications()
    var
        BankDepositHeader: Record "Bank Deposit Header";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        GenJournalLine: Record "Gen. Journal Line";
        PaymentVendorLedgerEntry: Record "Vendor Ledger Entry";
        VendorLedgerEntry: Record "Vendor Ledger Entry";
        PostedBankDepositLine: Record "Posted Bank Deposit Line";
        AppliedVendorLedgerEntry: Record "Vendor Ledger Entry" temporary;
        BankDeposit: Report "Bank Deposit";
        EntryApplicationMgt: Codeunit "Entry Application Mgt";
        InvoiceEntryNo: Integer;
    begin
        // [SCENARIO 542679] Applications on Vendor Ledger Entries are correctly retrieved for posted bank deposits
        // [GIVEN] A posted bank deposit fully applied to an open purchase document.
        Initialize();
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        LibraryERM.FindVendorLedgerEntry(VendorLedgerEntry, VendorLedgerEntry."Document Type"::Invoice, PurchaseHeader."Last Posting No.");
        InvoiceEntryNo := VendorLedgerEntry."Entry No.";
        CreateBankDeposit(BankDepositHeader, PurchaseLine."Buy-from Vendor No.", GenJournalLine."Account Type"::Vendor, 1);
        BankDepositHeader."Total Deposit Amount" := -550;
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.FindLast();
        GenJournalLine.Validate(Amount, 550);
        GenJournalLine.Modify();
        UpdateApplicationOnGenJournalLine(GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", VendorLedgerEntry."Document No.", 0D, 550);
        PostBankDeposit(BankDepositHeader);
        // [WHEN] Getting the applied vendor ledger entries as the report does
        PostedBankDepositLine.SetRange("Bank Deposit No.", BankDepositHeader."No.");
        PostedBankDepositLine.FindFirst();
        BankDeposit.FilterDepositVendorLedgerEntry(PostedBankDepositLine, PaymentVendorLedgerEntry);
        // [THEN] Only one entry is attached to the deposit line
        Assert.RecordCount(PaymentVendorLedgerEntry, 1);
        // [THEN] Only one invoice entry is found as applied
        EntryApplicationMgt.GetAppliedVendEntries(AppliedVendorLedgerEntry, PaymentVendorLedgerEntry, false);
        Assert.RecordCount(AppliedVendorLedgerEntry, 1);
        Assert.AreEqual(AppliedVendorLedgerEntry."Entry No.", InvoiceEntryNo, 'The found entry should be the invoice.');
    end;

    local procedure Initialize()
    var
        InventorySetup: Record "Inventory Setup";
    begin
        LibrarySetupStorage.Restore();

        OnBeforeInitialize(InitializeHandled);
        if InitializeHandled then
            exit;

        if IsInitialized then
            exit;

        LibraryERMCountryData.CreateVATData();
        LibraryInventory.NoSeriesSetup(InventorySetup);
        UpdateGenLedgerSetup('');
        UpdateSalesReceivablesSetup();
        LibrarySetupStorage.Save(DATABASE::"General Ledger Setup");
        IsInitialized := true;
        Commit();
        OnAfterInitialize(InitializeHandled);
    end;

    local procedure CalcGLEntryAmount(BalAccountNo: Code[20]; BalAccountType: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type") Amount: Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("Bal. Account No.", BalAccountNo);
        GLEntry.SetRange("Bal. Account Type", BalAccountType);
        GLEntry.SetRange("Document Type", DocumentType);
        GLEntry.FindSet();
        repeat
            Amount += GLEntry.Amount;
        until GLEntry.Next() = 0;
    end;

    local procedure CreateAndPostSalesDocument(var SalesLine: Record "Sales Line"; CustomerNo: Code[20]; DocumentType: Enum "Sales Document Type"; Type: Enum "Sales Line Type"; No: Code[20]; Quantity: Decimal; UnitPrice: Decimal): Code[20]
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesHeader(SalesHeader, DocumentType, CustomerNo);
        LibrarySales.CreateSalesLine(SalesLine, SalesHeader, Type, No, Quantity);
        SalesLine.Validate("Unit Price", UnitPrice);
        SalesLine.Modify(true);
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    local procedure CreateDefaultDimension(TableID: Integer; No: Code[20])
    var
        Dimension: Record Dimension;
        DimensionValue: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryDimension.CreateDimension(Dimension);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
        LibraryDimension.CreateDefaultDimension(DefaultDimension, TableID, No, Dimension.Code, DimensionValue.Code);
        LibraryDimension.FindDefaultDimension(DefaultDimension, TableID, No);
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Same Code");
        DefaultDimension.Modify(true);
    end;

    local procedure CreateBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; SignFactor: Integer)
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        CreateBankDeposit(BankDepositHeader, AccountNo, AccountType, SignFactor, GenJournalLine."Document Type"::Payment);
    end;

    local procedure CreateBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; SignFactor: Integer; DocumentType: Enum "Gen. Journal Document Type")
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", DocumentType,
          AccountType, AccountNo, LibraryRandom.RandInt(1000) * SignFactor);  // Using Random value for Deposit Amount.
    end;

    local procedure CreateBankDepositHeaderWithBankAccount(var BankDepositHeader: Record "Bank Deposit Header"; GenJournalBatch: Record "Gen. Journal Batch")
    var
        BankAccount: Record "Bank Account";
    begin
        LibraryERM.CreateBankAccount(BankAccount);
        CreateBankDepositHeader(BankDepositHeader, GenJournalBatch);
        BankDepositHeader.Validate("Bank Account No.", BankAccount."No.");
        BankDepositHeader.Modify(true);
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch"; Type: Enum "Gen. Journal Template Type")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Modify(true);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
    end;

    local procedure CreateMultilineDepositDocument(var BankDepositHeader: Record "Bank Deposit Header"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; AccountNo2: Code[20]; AccountType2: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type")
    begin
        CreateMultilineDepositDocument(BankDepositHeader, AccountNo, AccountType, AccountNo2, AccountType2, DocumentType, false);
    end;

    local procedure CreateMultilineDepositDocument(var BankDepositHeader: Record "Bank Deposit Header"; AccountNo: Code[20]; AccountType: Enum "Gen. Journal Account Type"; AccountNo2: Code[20]; AccountType2: Enum "Gen. Journal Account Type"; DocumentType: Enum "Gen. Journal Document Type"; PostAsLumpSum: Boolean)
    var
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        DocumentNo := '';
        // Create Bank Deposit WIth two line with different Account Type.
        if PostAsLumpSum then
            CreateBankDeposit(BankDepositHeader, AccountNo, AccountType, -1, DocumentType)
        else
            CreateBankDeposit(BankDepositHeader, AccountNo, AccountType, -1);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", DocumentType,
          AccountType2, AccountNo2, -LibraryRandom.RandInt(1000));  // Using Random value for Deposit Amount.

        BankDepositHeader."Post as Lump Sum" := PostAsLumpSum;
        if not PostAsLumpSum then
            exit;
        GenJournalLine.SetRange("Journal Template Name", BankDepositHeader."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", BankDepositHeader."Journal Batch Name");
        GenJournalLine.FindSet();
        repeat
            if DocumentNo = '' then
                DocumentNo := GenJournalLine."Document No."
            else
                GenJournalLine."Document No." := DocumentNo;
            GenJournalLine.Modify();
        until GenJournalLine.Next() = 0;
    end;

    local procedure SetupAndPostBankDeposit(var BankDepositHeader: Record "Bank Deposit Header"; GLAccountNo: Code[20]; VendorNo: Code[20]; BankAccountNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Create Bank Deposit with Account Type GL, Vendor and Bank.
        CreateMultilineDepositDocument(
          BankDepositHeader, GLAccountNo, GenJournalLine."Account Type"::"G/L Account", VendorNo, GenJournalLine."Account Type"::Vendor,
          GenJournalLine."Document Type"::Refund);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"Bank Account", BankAccountNo, -LibraryRandom.RandInt(1000));  // Using Random value for Deposit Amount.
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
        PostBankDeposit(BankDepositHeader);
    end;

    local procedure SetupFoBankDepositWithDimension(var BankDepositHeader: Record "Bank Deposit Header"; TableID: Integer; No: Code[20]; AccountType: Enum "Gen. Journal Account Type"; SignFactor: Integer)
    begin
        // Create Default Dimension, create Bank Deposit and update Total Deposit Amount.
        CreateDefaultDimension(TableID, No);
        CreateBankDeposit(BankDepositHeader, No, AccountType, SignFactor);
        CreateDefaultDimension(DATABASE::"Bank Account", BankDepositHeader."Bank Account No.");
        UpdateBankDepositHeaderWithAmount(BankDepositHeader);
    end;

    local procedure UpdateApplicationOnGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; JournalTemplateName: Code[10]; JournalBatchName: Code[10]; AppliestoDocNo: Code[20]; DueDate: Date; Amount: Decimal)
    begin
        GenJournalLine.SetRange("Journal Template Name", JournalTemplateName);
        GenJournalLine.SetRange("Journal Batch Name", JournalBatchName);
        GenJournalLine.FindFirst();
        GenJournalLine.Validate(Amount, Amount);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", AppliestoDocNo);
        GenJournalLine.Validate("Due Date", DueDate);
        GenJournalLine.Modify(true);
    end;

    local procedure UpdateBankDepositHeaderWithAmount(var BankDepositHeader: Record "Bank Deposit Header")
    begin
        BankDepositHeader.CalcFields("Total Deposit Lines");
        BankDepositHeader.Validate("Total Deposit Amount", BankDepositHeader."Total Deposit Lines");
        BankDepositHeader.Modify(true);
    end;

    local procedure UpdateGenJournalLine(BankDepositHeader: Record "Bank Deposit Header"; SalesLine: Record "Sales Line")
    var
        GenJournalLine: Record "Gen. Journal Line";
        SalesInvoiceHeader: Record "Sales Invoice Header";
    begin
        SalesInvoiceHeader.SetRange("Sell-to Customer No.", SalesLine."Sell-to Customer No.");
        SalesInvoiceHeader.FindFirst();
        UpdateApplicationOnGenJournalLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name",
          SalesInvoiceHeader."No.", 0D, -SalesLine."Amount Including VAT");
    end;

    local procedure UpdateGenLedgerSetup(CurrencyCode: Code[10])
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Additional Reporting Currency" := CurrencyCode; // Validate is not required.
        GeneralLedgerSetup.Modify(true);
    end;

    local procedure UpdateSalesReceivablesSetup()
    var
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
    begin
        SalesReceivablesSetup.Get();
        SalesReceivablesSetup.Validate("Bank Deposit Nos.", LibraryUtility.GetGlobalNoSeriesCode());
        SalesReceivablesSetup.Modify(true);
    end;

    local procedure VerifyBankAccLedgerEntryAmount(BankAccountNo: Code[20]; TotalDepositAmount: Decimal)
    var
        BankAccountLedgerEntry: Record "Bank Account Ledger Entry";
        Amount: Decimal;
    begin
        BankAccountLedgerEntry.SetRange("Bank Account No.", BankAccountNo);
        BankAccountLedgerEntry.FindSet();
        repeat
            Amount += BankAccountLedgerEntry.Amount;
        until BankAccountLedgerEntry.Next() = 0;
        Assert.AreEqual(TotalDepositAmount, Amount, GLEntryErr);
    end;

    local procedure PostBankDeposit(var BankDepositHeader: Record "Bank Deposit Header")
    var
        PostedBankDeposit: TestPage "Posted Bank Deposit";
        BankDepositHeaderNo: Code[20];
        PostedBankDepositHeaderNo: Code[20];
    begin
        PostedBankDeposit.Trap();
        BankDepositHeaderNo := BankDepositHeader."No.";
        Codeunit.Run(Codeunit::"Bank Deposit-Post (Yes/No)", BankDepositHeader);
        PostedBankDepositHeaderNo := COPYSTR(PostedBankDeposit."No.".Value(), 1, MaxStrLen(PostedBankDepositHeaderNo));
        PostedBankDeposit.Close();
        Assert.AreEqual(BankDepositHeaderNo, PostedBankDepositHeaderNo, '');
    end;

    local procedure CreateBankDepositHeader(var BankDepositHeader: Record "Bank Deposit Header"; GenJournalBatch: Record "Gen. Journal Batch")
    begin
        BankDepositHeader.SetFilter("Journal Template Name", GenJournalBatch."Journal Template Name");
        BankDepositHeader.SetFilter("Journal Batch Name", GenJournalBatch.Name);
        BankDepositHeader.Init();
        BankDepositHeader.Insert(true);
    end;

    local procedure CreateGenJournalTemplateAndBatchWithIncrementBatchName(
        var GenJournalTemplate: Record "Gen. Journal Template";
        var GenJournalBatch: Record "Gen. Journal Batch";
        Type: Enum "Gen. Journal Template Type";
        IncrementBatchName: Boolean)
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        GenJournalTemplate.Validate(Type, Type);
        GenJournalTemplate.Validate("Increment Batch Name", IncrementBatchName);
        GenJournalTemplate.Modify(true);

        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Rename(
            GenJournalBatch."Journal Template Name",
            LibraryRandom.RandText(
                LibraryUtility.GetFieldLength(DATABASE::"Gen. Journal Batch",
                GenJournalBatch.FieldNo(Name)) - 2) + Format(LibraryRandom.RandInt(50)));
        GenJournalBatch.Validate(Description, GenJournalBatch.Name);
        GenJournalBatch.Modify(true);
    end;

    local procedure GetBatchNameFromGenJournalTemplate(GenJournalTemplate: Record "Gen. Journal Template"): code[10]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        GenJournalBatch.SetRange("Journal Template Name", GenJournalTemplate.Name);
        GenJournalBatch.FindFirst();
        exit(GenJournalBatch.Name);
    end;

    [ModalPageHandler]
    procedure GeneralJournalBatchesPageHandler(var GeneralJournalBatches: TestPage "General Journal Batches")
    begin
        GeneralJournalBatches.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure ConfirmHandler(Question: Text[1024]; var Reply: Boolean)
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

