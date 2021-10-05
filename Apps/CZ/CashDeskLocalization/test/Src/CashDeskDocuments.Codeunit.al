codeunit 148070 "Cash Desk Documents CZP"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Cash Desk] [Documents]
        isInitialized := false;
    end;

    var
        CashDeskCZP: Record "Cash Desk CZP";
        BankAccountPostingGroup: Record "Bank Account Posting Group";
        CashDeskUserCZP: Record "Cash Desk User CZP";
        CashDeskEventCZP: Record "Cash Desk Event CZP";
        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryCashDeskCZP: Codeunit "Library - Cash Desk CZP";
        LibraryCashDocumentCZP: Codeunit "Library - Cash Document CZP";
        AmountLimitErr: Label 'Cash Document Amount exceeded maximal limit (%1).', Comment = '%1 = Cash Desk Maximal Limit';
        PostCashDocNotExistErr: Label 'Posted Cash Document does not exist.';
        CashDocStatusErr: Label 'Status in Cash Document must be Released.';
        NoOfEntriesMustBeEqualErr: Label 'Number of entries must be equal.';
        AmountMustBePositiveErr: Label 'Amount Including VAT must be positive in Cash Document Header Cash Desk No.=''%1'',No.=''%2''.', Comment = '%1 = Cash Desk No., %2 = Cash Document No.';
        isInitialized: Boolean;

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Cash Desk Documents CZP");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Cash Desk Documents CZP");

        LibraryCashDeskCZP.CreateCashDeskCZP(CashDeskCZP);
        LibraryCashDeskCZP.SetupCashDeskCZP(CashDeskCZP, true);
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", true, true, true);

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Cash Desk Documents CZP");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseReceiptCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCEANRIO] Release of Receipt Cash Document
        TestReleaseCashDocument(CashDocumentHeaderCZP."Document Type"::Receipt);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseWithdrawalCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCEANRIO] Release of Withdrawal Cash Document
        TestReleaseCashDocument(CashDocumentHeaderCZP."Document Type"::Withdrawal);
    end;

    local procedure TestReleaseCashDocument(CashDocType: Enum "Cash Document Type CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        Initialize();

        // [GIVEN] Cash Document has been created
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");

        // [WHEN] Release Cash Document
        ReleaseCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Cash Document Status will be Released
        Assert.IsTrue(CashDocumentHeaderCZP.Status = CashDocumentHeaderCZP.Status::Released, CashDocStatusErr);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseReceiptCashDocumentWithGreatAmount()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        // [SCENARIO] Error occurs on release of Receipt Cash Document with great amount
        Initialize();

        // [GIVEN] Create Receipt Cash Document with great amount
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");
        CashDocumentLineCZP.Validate(Amount, CashDeskCZP."Cash Receipt Limit" * 2); // Modify amount over the limit
        CashDocumentLineCZP.Modify(true);

        // [WHEN] Release Cash Document
        asserterror ReleaseCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Verify Error
        Assert.ExpectedError(StrSubstNo(AmountLimitErr, CashDeskCZP."Cash Receipt Limit"));
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure PostingReceiptCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        GLEntry: Record "G/L Entry";
    begin
        // [SCENARIO] Posting of Receipt Cash Document
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [WHEN] Post Cash Document
        PostCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Check Posted Cash Document exists
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        Assert.IsTrue(PostedCashDocumentHdrCZP.FindLast(), PostCashDocNotExistErr);

        // [THEN] Check Bank Account G/L Entry exists for Posted Cash Document
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PostedCashDocumentHdrCZP."No.");
        GLEntry.SetRange("Posting Date", PostedCashDocumentHdrCZP."Posting Date");

        BankAccountPostingGroup.Get(CashDeskCZP."Bank Acc. Posting Group");
        GLEntry.FindSet();
        GLEntry.TestField("G/L Account No.", BankAccountPostingGroup."G/L Account No.");
        GLEntry.TestField("Debit Amount", CashDocumentLineCZP.Amount);

        // [THEN] Check Cash Document Line G/L Entry exists for Posted Cash Document
        GLEntry.Next();
        GLEntry.TestField("G/L Account No.", CashDocumentLineCZP."Account No.");
        GLEntry.TestField("Credit Amount", CashDocumentLineCZP.Amount);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure PostingWithdrawalCashDocument()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: array[2] of Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        GLEntry: Record "G/L Entry";
        VATEntry: Record "VAT Entry";
        VATPostingSetup: Record "VAT Posting Setup";
        RangeAmount: Decimal;
        i: Integer;
    begin
        // [SCENARIO] Posting of Withdrawal Cash Document
        Initialize();

        // [GIVEN] Create Withdrawal Cash Document
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Withdrawal, CashDeskCZP."No.");

        // [GIVEN] Create Cash Desk Event
        LibraryCashDeskCZP.CreateCashDeskEventCZP(
          CashDeskEventCZP, CashDeskCZP."No.", CashDocumentHeaderCZP."Document Type"::Withdrawal,
          CashDeskEventCZP."Account Type"::"G/L Account", LibraryCashDocumentCZP.GetNewGLAccountNo(true));

        // [GIVEN] Create Withdrawal Cash Document Line 1
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP[1], CashDocumentHeaderCZP, CashDeskEventCZP.Code, 0);
        RangeAmount := Round((CashDeskCZP."Cash Withdrawal Limit" / 2) * (100 - CashDocumentLineCZP[1]."VAT %") / 100, 1, '<');
        CashDocumentLineCZP[1].Validate(Amount, LibraryRandom.RandInt(RangeAmount));
        CashDocumentLineCZP[1].Modify();

        // [GIVEN] Create Withdrawal Cash Document Line 2
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP[2], CashDocumentHeaderCZP, CashDeskEventCZP.Code, LibraryRandom.RandInt(Round(CashDeskCZP."Cash Withdrawal Limit", 1, '<')));
        RangeAmount := Round((CashDeskCZP."Cash Withdrawal Limit" / 2) * (100 - CashDocumentLineCZP[2]."VAT %") / 100, 1, '<');
        CashDocumentLineCZP[2].Validate(Amount, LibraryRandom.RandInt(RangeAmount));
        CashDocumentLineCZP[2].Modify();

        // [WHEN] Post Cash Document
        PostCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Check Posted Cash Document exists
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        Assert.IsTrue(PostedCashDocumentHdrCZP.FindLast(), PostCashDocNotExistErr);

        // [THEN] Check G/L Entries
        PostedCashDocumentHdrCZP.CalcFields("Amount Including VAT (LCY)");
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PostedCashDocumentHdrCZP."No.");
        GLEntry.SetRange("Posting Date", PostedCashDocumentHdrCZP."Posting Date");
        GLEntry.FindSet();
        GLEntry.TestField("G/L Account No.", BankAccountPostingGroup."G/L Account No.");
        GLEntry.TestField("Credit Amount", PostedCashDocumentHdrCZP."Amount Including VAT (LCY)");
        for i := 1 to 2 do begin
            FindVATPostingSetupFromGLAccount(VATPostingSetup, CashDocumentLineCZP[i]."Account No.");
            GLEntry.Next();
            GLEntry.TestField("G/L Account No.", CashDocumentLineCZP[i]."Account No.");
            GLEntry.TestField("Debit Amount", CashDocumentLineCZP[i].Amount);
            GLEntry.Next();
            GLEntry.TestField("G/L Account No.", VATPostingSetup."Purchase VAT Account");
            GLEntry.TestField("Debit Amount", CashDocumentLineCZP[i]."VAT Amount");
        end;

        // [THEN] Check VAT Entry
        VATEntry.SetCurrentKey("Document No.", "Posting Date");
        VATEntry.SetRange("Document No.", PostedCashDocumentHdrCZP."No.");
        VATEntry.SetRange("Posting Date", PostedCashDocumentHdrCZP."Posting Date");
        VATEntry.FindSet();
        VATEntry.TestField(Base, CashDocumentLineCZP[1].Amount);
        VATEntry.TestField(Amount, CashDocumentLineCZP[1]."VAT Amount");
        VATEntry.Next();
        VATEntry.TestField(Base, CashDocumentLineCZP[2].Amount);
        VATEntry.TestField(Amount, CashDocumentLineCZP[2]."VAT Amount");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseWithdrawalCashDocumentWithRounding()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        // [SCENARIO] Release of Withdrawal Cash Document with rounding
        Initialize();

        // [GIVEN] Create Withdrawal Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Withdrawal, CashDeskCZP."No.");
        CashDocumentLineCZP.Validate(Amount, CashDocumentLineCZP.Amount - 0.1); // Modify amount to decimal number
        CashDocumentLineCZP.Modify(true);

        // [WHEN] Release Cash Document
        ReleaseCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Verify rounding line exists
        CashDocumentLineCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        CashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
        CashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::"G/L Account");
        CashDocumentLineCZP.SetRange("Account No.", CashDeskCZP."Debit Rounding Account");
        Assert.RecordIsNotEmpty(CashDocumentLineCZP);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure PostingWithdrawalCashDocumentWithFixedAsset()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        GLEntry: Record "G/L Entry";
        FALedgerEntry: Record "FA Ledger Entry";
    begin
        // [SCENARIO] Posting of Withdrawal Cash Document with Fixed Asset
        Initialize();

        // [GIVEN] Create Withdrawal Cash Document
        CreateCashDocumentWithFixedAsset(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Withdrawal, CashDeskCZP."No.");

        // [WHEN] Post Cash Document
        PostCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Check Posted Cash Document exists
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        Assert.IsTrue(PostedCashDocumentHdrCZP.FindLast(), PostCashDocNotExistErr);

        // [THEN] Check G/L Entries
        GLEntry.SetCurrentKey("Document No.", "Posting Date");
        GLEntry.SetRange("Document No.", PostedCashDocumentHdrCZP."No.");
        GLEntry.SetRange("Posting Date", PostedCashDocumentHdrCZP."Posting Date");
        GLEntry.SetFilter("G/L Account No.", '<>%1&<>%2', CashDeskCZP."Debit Rounding Account", CashDeskCZP."Credit Rounding Account");
        Assert.AreEqual(3, GLEntry.Count, NoOfEntriesMustBeEqualErr);

        // [THEN] Check FA Ledger Entry
        FALedgerEntry.SetCurrentKey("Document No.", "Posting Date");
        FALedgerEntry.SetRange("Document No.", PostedCashDocumentHdrCZP."No.");
        FALedgerEntry.SetRange("Posting Date", PostedCashDocumentHdrCZP."Posting Date");
        FALedgerEntry.FindLast();
        FALedgerEntry.TestField("FA No.", CashDocumentLineCZP."Account No.");
        FALedgerEntry.TestField("FA Posting Type", FALedgerEntry."FA Posting Type"::"Acquisition Cost");
        FALedgerEntry.TestField(Amount, CashDocumentLineCZP.Amount);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ApplyingSalesInvoice()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        PostedCashDocumentHdrCZP: Record "Posted Cash Document Hdr. CZP";
        CustLedgerEntry: Record "Cust. Ledger Entry";
        CustomerLedgerEntries: TestPage "Customer Ledger Entries";
        AppliedCustomerEntries: TestPage "Applied Customer Entries";
        PostDocNo: Code[20];
    begin
        // [SCENARIO] Check that Posted Sales Invoice was closed after posting Receipt Cash Document
        Initialize();

        // [GIVEN] Create Sales Invoice
        CreateSalesInvoice(SalesHeader, SalesLine);

        // [GIVEN] Post Sales Invoice
        PostDocNo := PostSalesDocument(SalesHeader);

        // [GIVEN] Create Receipt Cash Document
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [GIVEN] Create Cash Desk Event
        LibraryCashDeskCZP.CreateCashDeskEventCZP(
          CashDeskEventCZP, CashDeskCZP."No.", CashDocumentHeaderCZP."Document Type"::Receipt,
          CashDeskEventCZP."Account Type"::Customer, '');

        // [GIVEN] Create Receipt Cash Document Line
        LibraryCashDocumentCZP.CreateCashDocumentLineCZPWithCashDeskEvent(
          CashDocumentLineCZP, CashDocumentHeaderCZP, CashDeskEventCZP.Code, 0);
        CashDocumentLineCZP.Validate("Account No.", SalesHeader."Bill-to Customer No.");
        CashDocumentLineCZP.Modify(true);
        CashDocumentLineCZP.Validate("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::Invoice);
        CashDocumentLineCZP.Validate("Applies-To Doc. No.", PostDocNo);
        CashDocumentLineCZP.Modify(true);

        // [WHEN] Post Cash Document
        PostCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Verify Customer Ledger Entry
        PostedCashDocumentHdrCZP.SetRange("Cash Desk No.", CashDeskCZP."No.");
        Assert.IsTrue(PostedCashDocumentHdrCZP.FindLast(), PostCashDocNotExistErr);

        CustomerLedgerEntries.OpenView();
        CustomerLedgerEntries.Filter.SetFilter("Document No.", PostedCashDocumentHdrCZP."No.");
        CustomerLedgerEntries.Filter.SetFilter("Posting Date", Format(PostedCashDocumentHdrCZP."Posting Date"));
        CustomerLedgerEntries.Last();
        CustomerLedgerEntries."Customer No.".AssertEquals(SalesHeader."Bill-to Customer No.");
        CustomerLedgerEntries.Amount.AssertEquals(-SalesLine."Amount Including VAT");

        // [THEN] Verify Applied Customer Ledger Entry
        AppliedCustomerEntries.Trap();
        CustomerLedgerEntries.AppliedEntries.Invoke();

        AppliedCustomerEntries.Last();
        AppliedCustomerEntries."Posting Date".AssertEquals(SalesHeader."Posting Date");
        AppliedCustomerEntries."Document Type".AssertEquals(CustLedgerEntry."Document Type"::Invoice);
        AppliedCustomerEntries."Document No.".AssertEquals(PostDocNo);
        AppliedCustomerEntries.Amount.AssertEquals(SalesLine."Amount Including VAT");

        AppliedCustomerEntries.OK().Invoke();
        CustomerLedgerEntries.OK().Invoke();
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseReceiptCashDocumentWithNegativeAmount()
    var
        DummyCashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that error occurs on release of Receipt Cash Document with negative amount
        ReleaseCashDocumentWithNegativeAmount(DummyCashDocumentHeaderCZP."Document Type"::Receipt);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure ReleaseWithdrawalCashDocumentWithNegativeAmount()
    var
        DummyCashDocumentHeaderCZP: Record "Cash Document Header CZP";
    begin
        // [SCENARIO] Check that error occurs on release of Withdrawal Cash Document with negative amount
        ReleaseCashDocumentWithNegativeAmount(DummyCashDocumentHeaderCZP."Document Type"::Withdrawal);
    end;

    local procedure ReleaseCashDocumentWithNegativeAmount(CashDocType: Enum "Cash Document Type CZP")
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
    begin
        Initialize();

        // [GIVEN] Create cash document with negative amount
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskCZP."No.");
        CashDocumentLineCZP.Validate(Amount, -CashDocumentLineCZP.Amount);
        CashDocumentLineCZP.Modify();

        // [WHEN] Release Cash Document
        asserterror ReleaseCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Error Occurs
        Assert.ExpectedError(StrSubstNo(AmountMustBePositiveErr, CashDeskCZP."No.", CashDocumentHeaderCZP."No."));
    end;

    [Test]
    procedure CreateCashDocumentWithoutPermissions()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        PermissionErr: Label 'You don''t have permission to create Cash Document Header.';
    begin
        // [SCENARIO] The error must occur if the user doesn't have permisions to create Cash Document
        Initialize();

        // [GIVEN] Create Cash Desk User
        LibraryCashDeskCZP.CreateCashDeskUserCZP(CashDeskUserCZP, CashDeskCZP."No.", false, true, true);

        // [WHEN] Create Cash Document
        asserterror LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(
            CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [THEN] Error Occurs
        Assert.ExpectedError(PermissionErr);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,CashDocumentStatisticsCZPModalPageHandler')]
    procedure TestDocumentRounding()
    var
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        RoundingCashDocumentLineCZP: Record "Cash Document Line CZP";
        CashDocumentCZP: TestPage "Cash Document CZP";
        AmountNotMatchErr: Label 'Amount of rounding doesn''t match.';
    begin
        // [SCENARIO] The rounding amount in cash document line is recalculated only if the amount in cash document lines is changes
        Initialize();

        // [GIVEN] Create Receipt Cash Document
        CreateCashDocument(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [GIVEN] Set Amounts Including VAT
        CashDocumentHeaderCZP.Validate("Amounts Including VAT", true);
        CashDocumentHeaderCZP.Modify();

        // [GIVEN] Set Amount to 119.71
        CashDocumentLineCZP.Validate(Amount, 119.71);
        CashDocumentLineCZP.Modify();

        // [WHEN] Open Cash Document Statistics
        CashDocumentCZP.OpenEdit();
        CashDocumentCZP.GoToRecord(CashDocumentHeaderCZP);
        CashDocumentCZP.Statistics.Invoke();

        // [THEN] Rounding line must be created and rounding amount must be calculated
        RoundingCashDocumentLineCZP.Reset();
        RoundingCashDocumentLineCZP.SetRange("Cash Desk No.", CashDocumentHeaderCZP."Cash Desk No.");
        RoundingCashDocumentLineCZP.SetRange("Cash Document No.", CashDocumentHeaderCZP."No.");
#pragma warning disable AA0210
        RoundingCashDocumentLineCZP.SetRange("Account Type", CashDocumentLineCZP."Account Type"::"G/L Account");
        RoundingCashDocumentLineCZP.SetFilter("Account No.", '%1|%2', CashDeskCZP."Debit Rounding Account", CashDeskCZP."Credit Rounding Account");
        RoundingCashDocumentLineCZP.SetRange("System-Created Entry", true);
#pragma warning restore
        RoundingCashDocumentLineCZP.FindFirst();
        Assert.AreEqual(0.29, RoundingCashDocumentLineCZP.Amount, AmountNotMatchErr);

        // [GIVEN] Change Amount to 119.70
        CashDocumentLineCZP.Validate(Amount, 119.70);
        CashDocumentLineCZP.Modify();

        // [WHEN] Open Cash Document Statistics
        CashDocumentCZP.Statistics.Invoke();

        // [THEN] Amount in rounding line must be recalculated
        RoundingCashDocumentLineCZP.FindFirst();
        Assert.AreEqual(0.30, RoundingCashDocumentLineCZP.Amount, AmountNotMatchErr);

        // [WHEN] Open Cash Document Statistics again
        CashDocumentCZP.Statistics.Invoke();

        // [THEN] Amount in rounding line mustn't be recalculated but the amount must be the same as before
        RoundingCashDocumentLineCZP.FindFirst();
        Assert.AreEqual(0.30, RoundingCashDocumentLineCZP.Amount, AmountNotMatchErr);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler')]
    procedure PaymentToleranceInCashDocument()
    var
        SalesHeader: Record "Sales Header";
        SalesLine: Record "Sales Line";
        CashDocumentHeaderCZP: Record "Cash Document Header CZP";
        CashDocumentLineCZP: Record "Cash Document Line CZP";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        CashDocumentAccountTypeCZP: Enum "Cash Document Account Type CZP";
        PaymentToleranceAmount: Decimal;
        PostDocNo: Code[20];
        MustExistErr: Label 'Detailed Customer Ledger Entry with payment tolerance must exist.';
        AmountNotMatchErr: Label 'Amount of payment tolerance doesn''t match.';
    begin
        // [SCENARIO] When the payment tolerance is enabled and Cash Document is applying e.g. Sales Invoice with different amount
        // which is posted by Sales Invoice then Detailed Customer Ledger Entry with payment tolerance type must be created.
        Initialize();

        // [GIVEN] Enable Payment Tolerance
        EnablePaymentTolerance();

        // [GIVEN] Create Sales Invoice
        CreateSalesInvoice(SalesHeader, SalesLine);

        // [GIVEN] Post Sales Invoice
        PostDocNo := PostSalesDocument(SalesHeader);

        // [GIVEN] Create Receipt Cash Document
        LibraryCashDocumentCZP.CreateCashDocumentHeaderCZP(CashDocumentHeaderCZP, CashDocumentHeaderCZP."Document Type"::Receipt, CashDeskCZP."No.");

        // [GIVEN] Create Receipt Cash Document Line with application to created invoice and round the amount to an integer
        LibraryCashDocumentCZP.CreateCashDocumentLineCZP(CashDocumentLineCZP, CashDocumentHeaderCZP, CashDocumentAccountTypeCZP::Customer, SalesHeader."Bill-to Customer No.", 0);
        CashDocumentLineCZP.Modify(true);
        CashDocumentLineCZP.Validate("Applies-To Doc. Type", CashDocumentLineCZP."Applies-To Doc. Type"::Invoice);
        CashDocumentLineCZP.Validate("Applies-To Doc. No.", PostDocNo);
        PaymentToleranceAmount := CashDocumentLineCZP.Amount - Round(CashDocumentLineCZP.Amount, 1, '=');
        CashDocumentLineCZP.Validate(Amount, Round(CashDocumentLineCZP.Amount, 1, '='));
        CashDocumentLineCZP.Modify(true);

        // [WHEN] Post Cash Document
        LibraryCashDocumentCZP.PostCashDocumentCZP(CashDocumentHeaderCZP);

        // [THEN] Detailed Customer Ledger Entry with Payment Tolerance is created
        DetailedCustLedgEntry.SetRange("Customer No.", CashDocumentLineCZP."Account No.");
        DetailedCustLedgEntry.SetRange("Document No.", CashDocumentHeaderCZP."No.");
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::"Payment Tolerance");
        Assert.IsTrue(DetailedCustLedgEntry.FindFirst(), MustExistErr);
        Assert.AreEqual(-PaymentToleranceAmount, DetailedCustLedgEntry.Amount, AmountNotMatchErr);
    end;

    local procedure EnablePaymentTolerance()
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."Max. Payment Tolerance Amount" := 1;
        GeneralLedgerSetup.Modify();
    end;

    local procedure CreateCashDocument(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        LibraryCashDocumentCZP.CreateCashDocumentWithEvent(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskNo);
    end;

    local procedure CreateCashDocumentWithFixedAsset(var CashDocumentHeaderCZP: Record "Cash Document Header CZP"; var CashDocumentLineCZP: Record "Cash Document Line CZP";
                                                        CashDocType: Enum "Cash Document Type CZP"; CashDeskNo: Code[20])
    begin
        LibraryCashDocumentCZP.CreateCashDocumentWithFixedAsset(CashDocumentHeaderCZP, CashDocumentLineCZP, CashDocType, CashDeskNo);
    end;

    local procedure CreateSalesInvoice(var SalesHeader: Record "Sales Header"; var SalesLine: Record "Sales Line")
    var
        Customer: Record Customer;
    begin
        LibrarySales.CreateCustomer(Customer);
        Customer.Validate("Application Method", Customer."Application Method"::Manual);
        Customer.Modify(true);

        LibrarySales.CreateSalesHeader(SalesHeader, SalesHeader."Document Type"::Invoice, Customer."No.");
        LibrarySales.CreateSalesLine(
          SalesLine, SalesHeader, SalesLine.Type::"G/L Account", LibraryCashDocumentCZP.GetExistGLAccountNo(), 1);
        SalesLine.Validate("Unit Price", LibraryRandom.RandDecInDecimalRange(1000.40, 1000.60, 2));
        SalesLine.Modify(true);
    end;

    local procedure FindVATPostingSetupFromGLAccount(var VATPostingSetup: Record "VAT Posting Setup"; AccountNo: Code[20])
    var
        GLAccount: Record "G/L Account";
    begin
        GLAccount.Get(AccountNo);
        VATPostingSetup.Get(GLAccount."VAT Bus. Posting Group", GLAccount."VAT Prod. Posting Group");
    end;

    local procedure ReleaseCashDocumentCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.ReleaseCashDocumentCZP(CashDocumentHeaderCZP);
    end;

    local procedure PostCashDocumentCZP(var CashDocumentHeaderCZP: Record "Cash Document Header CZP")
    begin
        LibraryCashDocumentCZP.PostCashDocumentCZP(CashDocumentHeaderCZP);
    end;

    local procedure PostSalesDocument(var SalesHeader: Record "Sales Header"): Code[20]
    begin
        exit(LibrarySales.PostSalesDocument(SalesHeader, true, true));
    end;

    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [ModalPageHandler]
    procedure CashDocumentStatisticsCZPModalPageHandler(var CashDocumentStatisticsCZP: TestPage "Cash Document Statistics CZP")
    begin
    end;
}
