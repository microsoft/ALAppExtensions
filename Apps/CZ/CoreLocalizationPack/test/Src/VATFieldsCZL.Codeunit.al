codeunit 148065 "VAT Fields CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Fields]
        isInitialized := false;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        VATPeriodCZL: Record "VAT Period CZL";
        VATStatementTemplate: Record "VAT Statement Template";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibrarySales: Codeunit "Library - Sales";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        PurchPost: Codeunit "Purch.-Post";
        SalesPost: Codeunit "Sales-Post";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        GenJnlPostBatch: Codeunit "Gen. Jnl.-Post Batch";
        Assert: Codeunit Assert;
        PurchaseLineType: Enum "Purchase Line Type";
        isInitialized: Boolean;

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Fields CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Fields CZL");

        LibraryTaxCZL.SetUseVATDate(true);

        LibraryTaxCZL.FindLastOpenVATPeriod(VATPeriodCZL);
        VATStatementTemplate.FindFirst();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Fields CZL");
    end;

    [Test]
    procedure EU3PartyIntermediateRoleCopiedToPurchaseVATEntry()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] EU 3-Party Intermediate Role copied to VAT Entry from Purchase Invoice
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."VAT Date CZL";
#pragma warning restore AL0432
#else
        PurchaseHeader."Original Doc. VAT Date CZL" := PurchaseHeader."VAT Reporting Date";
#endif
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", 1000);
        PurchaseLine.Modify(true);

        // [GIVEN] EU 3-Party Intermediate Role has been set
        PurchaseHeader.Validate("EU 3-Party Intermed. Role CZL", true);
        PurchaseHeader.Modify();

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Find last VAT Entry
        VATEntry.FindLast();

        // [THEN] EU 3-Party Intermediate Role will be true
        Assert.AreEqual(true, VATEntry."EU 3-Party Intermed. Role CZL", VATEntry.FieldCaption("EU 3-Party Intermed. Role CZL"));
    end;

    [Test]
    procedure EU3PartyIntermediateRoleCopiedToSalesVATEntry()
    var
        Customer: Record Customer;
        SalesHeader: Record "Sales Header";
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] EU 3-Party Intermediate Role copied to VAT Entry from Sales Invoice
        Initialize();

        // [GIVEN] New Customer has been created
        LibrarySales.CreateCustomer(Customer);

        // [GIVEN] New Sales Invoice has been created
        LibrarySales.CreateSalesInvoiceForCustomerNo(SalesHeader, Customer."No.");

        // [GIVEN] EU 3-Party Intermediate Role has been set
        SalesHeader.Validate("EU 3-Party Intermed. Role CZL", true);
        SalesHeader.Modify();

        // [GIVEN] Purchase Invoice has been posted
        SalesPost.Run(SalesHeader);

        // [WHEN] Find last VAT Entry
        VATEntry.FindLast();

        // [THEN] EU 3-Party Intermediate Role will be true
        Assert.AreEqual(true, VATEntry."EU 3-Party Intermed. Role CZL", VATEntry.FieldCaption("EU 3-Party Intermed. Role CZL"));
    end;

    [Test]
    procedure OriginalDocumetVATDateGreaterThanVATDate()
    var
        Vendor: Record Vendor;
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
    begin
        // [SCENARIO] Posting error when post Purchase Invoice with wrong Original Document VAT Date
        Initialize();

        // [GIVEN] New Vendor has been created
        LibraryPurchase.CreateVendor(Vendor);

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLineType::"G/L Account",
            LibraryERM.CreateGLAccountWithPurchSetup(), 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Original Document VAT Date has been set
#if not CLEAN22
#pragma warning disable AL0432
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", CalcDate('<+1D>', PurchaseHeader."VAT Date CZL"));
#pragma warning restore AL0432
#else
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", CalcDate('<+1D>', PurchaseHeader."VAT Reporting Date"));
#endif
        PurchaseHeader.Modify();

        // [WHEN] Purchase Invoice has been posted
        asserterror PurchPost.Run(PurchaseHeader);

        // [THEN] Posting error will occurs
        Assert.ExpectedError('Original Document VAT Date must be less or equal to VAT Date');
    end;

    [Test]
    procedure GeneralPostingWithEmptyOriginalDocumentVATDate()
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        // [SCENARIO] Post General Journal Line with empty Original Document VAT Date
        Initialize();

        // [GIVEN] Allow Posting From has been set up in General Ledger Setup
        GeneralLedgerSetup.Validate("Allow Posting From", VATPeriodCZL."Starting Date");
        GeneralLedgerSetup.Modify();

        // [GIVEN] New Gen. Journal Line has been created
        GenJournalLine.Init();
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Document No.", LibraryRandom.RandText(10));
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Account No.", LibraryERM.CreateGLAccountWithPurchSetup());
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", LibraryERM.CreateGLAccountNoWithDirectPosting());
        GenJournalLine.Validate(Amount, 100);
        GenJournalLine.Validate("Posting Date", VATPeriodCZL."Starting Date");
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine.Validate("VAT Date CZL", VATPeriodCZL."Starting Date");
#pragma warning restore AL0432
#else
        GenJournalLine.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
#endif
        GenJournalLine.Validate("Original Doc. VAT Date CZL", 0D);

        // [WHEN] Gen. Journal Line has been posted
        GenJnlPostLine.Run(GenJournalLine);

        // [THEN] No error will occurs
    end;

    [Test]
    procedure CopyVATDateToPostedGenJournalLine()
#pragma warning disable AA0210
    var
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        PostedGenJournalLine: Record "Posted Gen. Journal Line";
        DocumentNo: Code[20];
    begin
        // [SCENARIO] Copy VAT Date to Posted General Journal Line
        Initialize();

        // [GIVEN] Gen. Journal Template has been set up
        GenJournalTemplate.SetRange(Type, GenJournalTemplate.Type::General);
        GenJournalTemplate.SetRange(Recurring, false);
        GenJournalTemplate.FindFirst();

        // [GIVEN] New Gen. Journal Batch has been created
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch."Copy to Posted Jnl. Lines" := true;
        GenJournalBatch.Modify();

        // [GIVEN] Neww Gen. Journal Line has been created
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                       GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account", LibraryERM.CreateGLAccountWithPurchSetup(),
                       GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), 100);
        DocumentNo := GenJournalLine."Document No.";
        GenJournalLine.Validate("Posting Date", VATPeriodCZL."Starting Date");
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine.Validate("VAT Date CZL", VATPeriodCZL."Starting Date");
#pragma warning restore AL0432
#else
        GenJournalLine.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
#endif
        GenJournalLine.Modify();

        // [WHEN] Gen. Journal Line has been posted
        GenJnlPostBatch.Run(GenJournalLine);

        // [THEN] Posted Gen. Journal Line will have VAT Date
        PostedGenJournalLine.SetCurrentKey("Journal Template Name", "Journal Batch Name");
        PostedGenJournalLine.SetRange("Journal Template Name", GenJournalTemplate.Name);
        PostedGenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        PostedGenJournalLine.SetRange("Document No.", DocumentNo);
        PostedGenJournalLine.FindLast();
        Assert.AreEqual(VATPeriodCZL."Starting Date", PostedGenJournalLine."VAT Date CZL", PostedGenJournalLine.FieldCaption("VAT Date CZL"));
#pragma warning restore AA0210
    end;

    [Test]
    procedure VATStatementTotaling()
    var
        GLAccount: array[3] of Record "G/L Account";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        LineValue: array[3] of Decimal;
    begin
        // [SCENARIO] Preview VAT Statement and check totaling lines
        Initialize();

        // [GIVEN] New G/L Accounts have been created
        GLAccount[1].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[2].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[3].Get(LibraryERM.CreateGLAccountNoWithDirectPosting());

        // [GIVEN] New Gen. Journal Lines has been created and posted
        CreateAndPostGenJnlLine(GLAccount[1]."No.", GLAccount[3]."No.");
        CreateAndPostGenJnlLine(GLAccount[2]."No.", GLAccount[3]."No.");

        // [GIVEN] New VAT Statement has been created
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '1';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[1]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[1]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '2';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[2]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[2]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '3';
        VATStatementLine.Type := VATStatementLine.Type::"Row Totaling";
        VATStatementLine."Row Totaling" := '1|2';
        VATStatementLine.Modify();

        // [GIVEN] Page VAT Statement Preview for created lines has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [WHEN] Dates has been set
        VATStatementPreviewCZL.VATPeriodStartDate.SetValue(VATPeriodCZL."Starting Date");
        VATStatementPreviewCZL.VATPeriodEndDate.SetValue(CalcDate('<+1M-1D>', VATPeriodCZL."Starting Date"));
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");

        // [THEN] Total Line value will be sum of VAT Lines values
        VATStatementPreviewCZL.VATStatementLineSubForm.First();
        Evaluate(LineValue[1], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        VATStatementPreviewCZL.VATStatementLineSubForm.Next();
        Evaluate(LineValue[2], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        VATStatementPreviewCZL.VATStatementLineSubForm.Next();
        Evaluate(LineValue[3], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        Assert.AreEqual(LineValue[1] + LineValue[2], LineValue[3], 'VAT Statement totaling');
        VATStatement.Close();
        VATStatementPreviewCZL.Close();
    end;

    [Test]
    procedure VATStatementTotalingPositiveZero()
    var
        GLAccount: array[3] of Record "G/L Account";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
    begin
        // [SCENARIO] Preview VAT Statement and check totaling lines when Show zero if positive
        Initialize();

        // [GIVEN] New G/L Accounts have been created
        GLAccount[1].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[2].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[3].Get(LibraryERM.CreateGLAccountNoWithDirectPosting());

        // [GIVEN] New Gen. Journal Lines has been created and posted
        CreateAndPostGenJnlLine(GLAccount[1]."No.", GLAccount[3]."No.");
        CreateAndPostGenJnlLine(GLAccount[2]."No.", GLAccount[3]."No.");

        // [GIVEN] New VAT Statement has been created
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '1';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[1]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[1]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '2';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[2]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[2]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '3';
        VATStatementLine.Type := VATStatementLine.Type::"Row Totaling";
        VATStatementLine."Row Totaling" := '1|2';
        VATStatementLine."Show CZL" := VATStatementLine."Show CZL"::"Zero If Positive";
        VATStatementLine.Modify();

        // [GIVEN] Page VAT Statement Preview for created lines has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [WHEN] Dates has been set
        VATStatementPreviewCZL.VATPeriodStartDate.SetValue(VATPeriodCZL."Starting Date");
        VATStatementPreviewCZL.VATPeriodEndDate.SetValue(CalcDate('<+1M-1D>', VATPeriodCZL."Starting Date"));
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");

        // [THEN] Total Line value will be sum of VAT Lines values
        VATStatementPreviewCZL.VATStatementLineSubForm.Last();
        Assert.AreEqual('', VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value(), 'VAT Statement positive totaling');
        VATStatement.Close();
        VATStatementPreviewCZL.Close();
    end;

    [Test]
    procedure VATStatementTotalingNegativeZero()
    var
        GLAccount: array[3] of Record "G/L Account";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        LineValue: array[3] of Decimal;
    begin
        // [SCENARIO] Preview VAT Statement and check totaling lines when Show zero if negative
        Initialize();

        // [GIVEN] New G/L Accounts have been created
        GLAccount[1].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[2].Get(LibraryERM.CreateGLAccountWithPurchSetup());
        GLAccount[3].Get(LibraryERM.CreateGLAccountNoWithDirectPosting());

        // [GIVEN] New Gen. Journal Lines has been created and posted
        CreateAndPostGenJnlLine(GLAccount[1]."No.", GLAccount[3]."No.");
        CreateAndPostGenJnlLine(GLAccount[2]."No.", GLAccount[3]."No.");

        // [GIVEN] New VAT Statement has been created
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '1';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[1]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[1]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '2';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount[2]."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount[2]."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();

        // [GIVEN] New VAT Statement Line has been created
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        VATStatementLine."Row No." := '3';
        VATStatementLine.Type := VATStatementLine.Type::"Row Totaling";
        VATStatementLine."Row Totaling" := '1|2';
        VATStatementLine."Show CZL" := VATStatementLine."Show CZL"::"Zero If Negative";
        VATStatementLine.Modify();

        // [GIVEN] Page VAT Statement Preview for created lines has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [WHEN] Dates has been set
        VATStatementPreviewCZL.VATPeriodStartDate.SetValue(VATPeriodCZL."Starting Date");
        VATStatementPreviewCZL.VATPeriodEndDate.SetValue(CalcDate('<+1M-1D>', VATPeriodCZL."Starting Date"));
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");

        // [THEN] Total Line value will be sum of VAT Lines values
        VATStatementPreviewCZL.VATStatementLineSubForm.First();
        Evaluate(LineValue[1], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        VATStatementPreviewCZL.VATStatementLineSubForm.Next();
        Evaluate(LineValue[2], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        VATStatementPreviewCZL.VATStatementLineSubForm.Next();
        Evaluate(LineValue[3], VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Value());
        Assert.AreEqual(LineValue[1] + LineValue[2], LineValue[3], 'VAT Statement negative totaling');
        VATStatement.Close();
        VATStatementPreviewCZL.Close();
    end;

    local procedure CreateAndPostGenJnlLine(AccNo: Code[20]; BalAccNo: Code[20])
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        GenJournalLine.Init();
        GenJournalLine.Validate("Document Type", GenJournalLine."Document Type"::Payment);
        GenJournalLine.Validate("Document No.", LibraryRandom.RandText(10));
        GenJournalLine.Validate("Account Type", GenJournalLine."Account Type"::"G/L Account");
        GenJournalLine.Validate("Account No.", AccNo);
        GenJournalLine.Validate("Bal. Account Type", GenJournalLine."Bal. Account Type"::"G/L Account");
        GenJournalLine.Validate("Bal. Account No.", BalAccNo);
        GenJournalLine.Validate(Amount, 100);
        GenJournalLine.Validate("Posting Date", VATPeriodCZL."Starting Date");
#if not CLEAN22
#pragma warning disable AL0432
        GenJournalLine.Validate("VAT Date CZL", VATPeriodCZL."Starting Date");
#pragma warning restore AL0432
#else
        GenJournalLine.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
#endif
        GenJournalLine.Validate("Original Doc. VAT Date CZL", 0D);
        Clear(GenJnlPostLine);
        GenJnlPostLine.Run(GenJournalLine);
    end;
}
