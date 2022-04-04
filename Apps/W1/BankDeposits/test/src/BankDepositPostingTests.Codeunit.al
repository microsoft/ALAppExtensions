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

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
    procedure PostBankDepositAsLumpSum()
    var
        GLAccount: Record "G/L Account";
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
        GenJournalLine: Record "Gen. Journal Line";
        SourceCodeSetup: Record "Source Code Setup";
        GLEntry: Record "G/L Entry";
    begin
        // Verify G/L Entry after post Deposit with Unchecked Force Doc. Balance.

        // Setup: Create GL Account and Vendor, create Bank Deposit with Account Type GL, Vendor.
        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryPurchase.CreateVendor(Vendor);
        CreateMultilineDepositDocument(
          BankDepositHeader, GLAccount."No.", GenJournalLine."Account Type"::"G/L Account", Vendor."No.", GenJournalLine."Account Type"::Vendor,
          GenJournalLine."Document Type"::Refund);

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
        GLEntry.FindFirst();
        GLEntry.TestField("Document Type", GLEntry."Document Type"::" ");
        GLEntry.TestField(Amount, BankDepositHeader."Total Deposit Amount");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
    procedure ErrorOnPostVendPaymentBankDepositWithDefaultDimension()
    var
        Vendor: Record Vendor;
        BankDepositHeader: Record "Bank Deposit Header";
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
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
    procedure ErrorOnPostCustPaymentBankDepositWithDefaultDimension()
    var
        Customer: Record Customer;
        BankDepositHeader: Record "Bank Deposit Header";
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
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
        GLEntry.SetRange("Bal. Account No.", GLAccount."No.");
        GLEntry.FindFirst();
        GLEntry.TestField("Journal Batch Name", BankDepositHeader."Journal Batch Name");
    end;

    [Test]
    [HandlerFunctions('GeneralJournalBatchesPageHandler,ConfirmHandler')]
    [Scope('OnPrem')]
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
    [Scope('OnPrem')]
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
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Type::"Bank Deposits");
        CreateBankDepositHeaderWithBankAccount(BankDepositHeader, GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", GenJournalLine."Document Type"::Payment,
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
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // Create Bank Deposit WIth two line with different Account Type.
        CreateBankDeposit(BankDepositHeader, AccountNo, AccountType, -1);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, BankDepositHeader."Journal Template Name", BankDepositHeader."Journal Batch Name", DocumentType,
          AccountType2, AccountNo2, -LibraryRandom.RandInt(1000));  // Using Random value for Deposit Amount.
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

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure GeneralJournalBatchesPageHandler(var GeneralJournalBatches: TestPage "General Journal Batches")
    begin
        GeneralJournalBatches.OK().Invoke();
    end;

    [ConfirmHandler]
    [Scope('OnPrem')]
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

