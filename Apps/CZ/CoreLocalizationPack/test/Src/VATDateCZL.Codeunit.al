codeunit 148054 "VAT Date CZL"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Core] [VAT Date]
        isInitialized := false;
    end;

    var
        GeneralLedgerSetup: Record "General Ledger Setup";
        SalesReceivablesSetup: Record "Sales & Receivables Setup";
        PurchasesPayablesSetup: Record "Purchases & Payables Setup";
        ServiceMgtSetup: Record "Service Mgt. Setup";
        PurchaseHeader: Record "Purchase Header";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        VATPostingSetup: Record "VAT Posting Setup";
        UserSetup: Record "User Setup";
        VATStatementTemplate: Record "VAT Statement Template";
        VATSetup: Record "VAT Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibraryTaxCZL: Codeunit "Library - Tax CZL";
        PurchPost: Codeunit "Purch.-Post";
        Assert: Codeunit Assert;
        AccountType: Enum "Gen. Journal Account Type";
        isInitialized: Boolean;
        RequestPageXML: Text;
        GLAccountNo: Code[20];
        EmptyOrigDocVATDateErr: Label 'Original Document VAT Date must have a value in Gen. Journal Line';
        VATSettlementDocNoTok: Label 'VAT_SETTL';

    local procedure Initialize();
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"VAT Date CZL");
        LibraryRandom.Init();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"VAT Date CZL");
        UserSetup.ModifyAll(UserSetup."Allow VAT Date From", 0D);
        UserSetup.ModifyAll(UserSetup."Allow VAT Date To", 0D);

        GeneralLedgerSetup.Get();
        GeneralLedgerSetup."VAT Reporting Date Usage" := GeneralLedgerSetup."VAT Reporting Date Usage"::Enabled;
        GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL" := GeneralLedgerSetup."Def. Orig. Doc. VAT Date CZL"::Blank;
        GeneralLedgerSetup.Modify();

        VATSetup.Get();
        VATSetup."Allow VAT Date From" := 0D;
        VATSetup."Allow VAT Date To" := 0D;
        VATSetup.Modify();

        SalesReceivablesSetup.Get();
        SalesReceivablesSetup."Order Nos." := LibraryERM.CreateNoSeriesCode();
        SalesReceivablesSetup.Modify();

        PurchasesPayablesSetup.Get();
        PurchasesPayablesSetup."Order Nos." := LibraryERM.CreateNoSeriesCode();
        PurchasesPayablesSetup.Modify();

        ServiceMgtSetup.Get();
        ServiceMgtSetup."Service Order Nos." := LibraryERM.CreateNoSeriesCode();
        ServiceMgtSetup.Modify();
        VATStatementTemplate.FindFirst();
        GLAccountNo := LibraryERM.CreateGLAccountNoWithDirectPosting();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"VAT Date CZL");
    end;

    [Test]
    procedure GenJnlLineWithoutUseVatDate()
    begin
        // [SCENARIO] Gen. Journal Line without use VAT Date
        Initialize();

        // [GIVEN] General Ledger Setup has been set without Use VAT Date
        LibraryTaxCZL.SetUseVATDate(false);

        // [GIVEN] New Gen. Journal Line has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        Enum::"Gen. Journal Document Type"::" ", AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(1000, 2));

        // [WHEN] Validate Posting Date
        GenJournalLine.Validate("Posting Date", LibraryRandom.RandDate(30));

        // [THEN] VAT Date will be Posting Date
        Assert.AreEqual(GenJournalLine."Posting Date", GenJournalLine."VAT Reporting Date", GenJournalLine.FieldCaption(GenJournalLine."VAT Reporting Date"));
    end;

    [Test]
    procedure GenJnlLineWithUseVatDate()
    begin
        // [SCENARIO] Gen. Journal Line with use VAT Date
        Initialize();

        // [GIVEN] General Ledger Setup with Use VAT Date
        LibraryTaxCZL.SetUseVATDate(true);

        // [GIVEN] New Gen. Journal Line has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        Enum::"Gen. Journal Document Type"::" ", AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(1000, 2));

        // [WHEN] Validate Posting Date
        GenJournalLine.Validate("Posting Date", LibraryRandom.RandDate(30));

        // [THEN] VAT Date is Posting Date
        Assert.AreEqual(GenJournalLine."Posting Date", GenJournalLine."VAT Reporting Date", GenJournalLine.FieldCaption(GenJournalLine."VAT Reporting Date"));
    end;

    [Test]
    procedure GenJnlLinePostWithVatDate()
    var
        VATEntry: Record "VAT Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        TaxCalculationType: Enum "Tax Calculation Type";
        GeneralPostingType: Enum "General Posting Type";
    begin
        // [SCENARIO] Post Gen. Jounal Line with VAT Date
        Initialize();

        // [GIVEN] New VAT Posting Setup has been created
        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, TaxCalculationType::"Normal VAT", 10);

        // [GIVEN] New balanced Gen. Journal Line has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
                        Enum::"Gen. Journal Document Type"::" ", AccountType::"G/L Account",
                        LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, GeneralPostingType::Sale),
                        AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Posting Date has been validated
        GenJournalLine.Validate("Posting Date", LibraryRandom.RandDate(30));

        // [WHEN] Post Gen. Journal Line
        GenJnlPostLine.Run(GenJournalLine);

        // [THEN] VAT Entry will have VAT Date
        VATEntry.FindLast();
        Assert.AreEqual(VatEntry."Posting Date", VatEntry."VAT Reporting Date", VatEntry.FieldCaption(VatEntry."VAT Reporting Date"));
    end;

    [Test]
    procedure GenJnlLinePostWithoutVATToClosedVATPeriod()
    var
        VATPeriodCZL: Record "VAT Period CZL";
        VATEntry: Record "VAT Entry";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
        VATEntriesCount: Integer;
    begin
        // [SCENARIO] If the Gen. Journal Line is posting to closed VAT period without VAT then VAT Date check is not performed
        Initialize();

        // [GIVEN] VAT Period has been closed
        VATPeriodCZL.FindFirst();
        VATPeriodCZL.Validate(Closed, true);
        VATPeriodCZL.Modify();

        // [GIVEN] New balanced Gen. Journal Line created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
            GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::" ",
            AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(),
            AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(),
            LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Gen. Journal Line dates have been modified
        GenJournalLine.Validate("Posting Date", VATPeriodCZL."Starting Date");
        GenJournalLine.Validate("VAT Reporting Date", 0D);
        GenJournalLine.Validate("Gen. Posting Type", Enum::"General Posting Type"::" ");
        GenJournalLine.Validate("Gen. Bus. Posting Group", '');
        GenJournalLine.Validate("Gen. Prod. Posting Group", '');
        GenJournalLine.Modify();

        // [WHEN] Post Gen. Journal Line
        VATEntriesCount := VATEntry.Count();
        GenJnlPostLine.Run(GenJournalLine);

        // [THEN] No VAT Entry will be created
        VATEntry.FindLast();
        Assert.AreEqual(VATEntriesCount, VATEntry.Count(), 'No VAT Entry will be created.');
    end;

    [Test]
    procedure GenJnlLinePostWithVATToClosedVATPeriod()
    var
        VATPeriodCZL: Record "VAT Period CZL";
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        // [SCENARIO] If the Gen. Journal Line is posting to closed VAT period with VAT then VAT Date check is performed
        Initialize();

        // [GIVEN] Close VAT Period
        VATPeriodCZL.FindFirst();
        VATPeriodCZL.Validate(Closed, true);
        VATPeriodCZL.Modify();

        // [GIVEN] New VAT Posting Setup has been created
        LibraryERM.CreateVATPostingSetupWithAccounts(VatPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT", 10);

        // [GIVEN] New balanced Gen. Journal Line has been created
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
            GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::" ",
            AccountType::"G/L Account", LibraryERM.CreateGLAccountWithVATPostingSetup(VATPostingSetup, Enum::"General Posting Type"::Sale),
            AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(), LibraryRandom.RandDec(1000, 2));

        // [GIVEN] Posting Date has been validated
        GenJournalLine.Validate("Posting Date", VATPeriodCZL."Starting Date");

        // [WHEN] Post Gen. Journal Line
        asserterror GenJnlPostLine.Run(GenJournalLine);

        // [THEN] Error will occurs because VAT period must be open
        Assert.ExpectedTestFieldError(VATPeriodCZL.FieldCaption(Closed), Format(false));
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure VATStatementFilteredByPostingDate()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        VATEntries: TestPage "VAT Entries";
    begin
        // [SCENARIO] Check not existing posted purchase invoice in VAT statement
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        VATPeriodCZL.Next();
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [GIVEN] New VAT Statement has been set up
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        SetupVATStatementLineForGLAccount(VATStatementLine, GLAccount);

        // [GIVEN] Page VAT Statement Preview for created line has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [GIVEN] Posting Date and report selections has been set
        VATStatementPreviewCZL.DateFilter.SetValue(PurchaseHeader."Posting Date");
        VATStatementPreviewCZL.Selection.SetValue("VAT Statement Report Selection"::Open);
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");
        VATEntries.Trap();

        // [WHEN] DrillDown to ColumnValue
        VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Drilldown();

        // [THEN] Page "VAT Entries" will not contain posted purchase invoice
        VATEntry.FindLast();
        VATEntries.Filter.SetFilter("Document No.", VATEntry."Document No.");
        asserterror VATEntries.GoToRecord(VATEntry);
        VATEntries.Close();
        VATStatementPreviewCZL.Close();
        VATStatement.Close();
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure VATStatementFilteredByVATDate()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        VATEntries: TestPage "VAT Entries";
    begin
        // [SCENARIO] Check existing posted purchase invoice in VAT statement
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        VATPeriodCZL.Next();
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [GIVEN] New VAT Statement has been set up
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        SetupVATStatementLineForGLAccount(VATStatementLine, GLAccount);

        // [GIVEN] Page VAT Statement Preview for created line has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [GIVEN] VAT Date and report selections has been set
        VATStatementPreviewCZL.DateFilter.SetValue(PurchaseHeader."VAT Reporting Date");
        VATStatementPreviewCZL.Selection.SetValue("VAT Statement Report Selection"::Open);
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");
        VATEntries.Trap();

        // [WHEN] DrillDown to ColumnValue
        VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Drilldown();

        // [THEN] Page "VAT Entries" will contain posted purchase invoice
        VATEntry.FindLast();
        VATEntries.Filter.SetFilter("Document No.", VATEntry."Document No.");
        VATEntries.GoToRecord(VATEntry);
        VATEntries.Close();
        VATStatementPreviewCZL.Close();
        VATStatement.Close();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmYesHandler,CalcPostVATSettlementRequestPageHandlerWithSettlement')]
    procedure VATStatementFilteredBySettlementNo()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
        VATStatementName: Record "VAT Statement Name";
        VATStatementLine: Record "VAT Statement Line";
        VATStatement: TestPage "VAT Statement";
        VATStatementPreviewCZL: TestPage "VAT Statement Preview CZL";
        VATEntries: TestPage "VAT Entries";
    begin
        // [SCENARIO] Check settlement in VAT statement
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindLast();
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [GIVEN] VAT Settlement has been calculated and posted
        Commit();
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Calc. and Post VAT Settl. CZL", '', RequestPageXML);

        // [GIVEN] New VAT Statement has been set up
        LibraryERM.CreateVATStatementName(VATStatementName, VATStatementTemplate.Name);
        LibraryERM.CreateVATStatementLine(VATStatementLine, VATStatementName."Statement Template Name", VATStatementName.Name);
        SetupVATStatementLineForGLAccount(VATStatementLine, GLAccount);

        // [GIVEN] Page VAT Statement Preview for created line has been opened
        VATStatement.OpenEdit();
        VATStatement.CurrentStmtName.SetValue(VATStatementName.Name);
        VATStatementPreviewCZL.Trap();
        VATStatement."P&review CZL".Invoke();

        // [GIVEN] VAT Date and report selections has been set
        VATStatementPreviewCZL.DateFilter.SetValue(PurchaseHeader."VAT Reporting Date");
        VATStatementPreviewCZL.Selection.SetValue("VAT Statement Report Selection"::"Open and Closed");
        VATStatementPreviewCZL.PeriodSelection.SetValue("VAT Statement Report Period Selection"::"Within Period");
        VATStatementPreviewCZL.SettlementNoFilter.SetValue(VATSettlementDocNoTok);
        VATEntries.Trap();

        // [WHEN] DrillDown to ColumnValue
        VATStatementPreviewCZL.VATStatementLineSubForm.ColumnValue.Drilldown();

        // [THEN] Page "VAT Entries" will contain settlement
#pragma warning disable AA0210
        VATEntry.SetRange("VAT Settlement No. CZL", VATSettlementDocNoTok);
#pragma warning restore AA0210
        VATEntry.FindFirst();
        VATEntries.GoToRecord(VATEntry);
        VATEntries.Close();
        VATStatementPreviewCZL.Close();
        VATStatement.Close();
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CalcPostVATSettlementRequestPageHandlerPenultimatePeriod')]
    procedure CalcAndPostVATByPostingDate()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] Check not existing posted purchase invoice in Calc and Post VAT report
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        VATPeriodCZL.Next();
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Report run
        Commit();
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Calc. and Post VAT Settl. CZL", '', RequestPageXML);

        // [THEN] Report Dataset will not contain Purchase Invoice
        VATEntry.FindLast();
        LibraryReportDataset.AssertElementWithValueNotExist('DocumentNo_VATEntry', VATEntry."Document No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,CalcPostVATSettlementRequestPageHandlerLastPeriod')]
    procedure CalcAndPostVATByVATDate()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] Check existing posted purchase invoice in Calc and Post VAT report
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        VATPeriodCZL.Next();
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Report run
        Commit();
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Calc. and Post VAT Settl. CZL", '', RequestPageXML);

        // [THEN] Report Dataset will contain Purchase Invoice
        VATEntry.FindLast();
        LibraryReportDataset.AssertElementWithValueExists('DocumentNo_VATEntry', VATEntry."Document No.");
    end;

    [Test]
    [HandlerFunctions('MessageHandler,ConfirmYesHandler,CalcPostVATSettlementRequestPageHandlerWithSettlement')]
    procedure CalcAndPostVATBySettlementNo()
    var
        Vendor: Record Vendor;
        PurchaseLine: Record "Purchase Line";
        VATPeriodCZL: Record "VAT Period CZL";
        GLAccount: Record "G/L Account";
        VATEntry: Record "VAT Entry";
    begin
        // [SCENARIO] Check existing posted purchase invoice in Calc and Post VAT report
        Initialize();

        // [GIVEN] New G/L Account has been created
        GLAccount.Get(LibraryERM.CreateGLAccountWithPurchSetup());

        // [GIVEN] New Purchase Invoice has been created
        LibraryPurchase.CreatePurchaseInvoiceForVendorNo(PurchaseHeader, Vendor."No.");

        // [GIVEN] Dates have been validated
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181
        PurchaseHeader.Validate("Posting Date", VATPeriodCZL."Starting Date");
        VATPeriodCZL.Next();
        PurchaseHeader.Validate("VAT Reporting Date", VATPeriodCZL."Starting Date");
        PurchaseHeader.Validate("Original Doc. VAT Date CZL", PurchaseHeader."VAT Reporting Date");
        PurchaseHeader.Modify();

        // [GIVEN] New Purchase Invoice line has been created
        LibraryPurchase.CreatePurchaseLine(PurchaseLine, PurchaseHeader, PurchaseLine.Type::"G/L Account", GLAccount."No.", 1);
        PurchaseLine.Validate("Direct Unit Cost", 100);
        PurchaseLine.Modify(true);

        // [GIVEN] Purchase Invoice has been posted
        PurchPost.Run(PurchaseHeader);

        // [WHEN] Report run
        Commit();
        RequestPageXML := Report.RunRequestPage(Report::"Calc. and Post VAT Settl. CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Calc. and Post VAT Settl. CZL", '', RequestPageXML);

        // [THEN] Last VAT entry will have Settlement No.
        VATEntry.FindLast();
        Assert.AreEqual(VATSettlementDocNoTok, VATEntry."VAT Settlement No. CZL", VATEntry.FieldCaption("VAT Settlement No. CZL"));
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForFinanceChargeMemo()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must not cause an error if the type of document is Finance Charge Memo
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::"Finance Charge Memo", -LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        PostGenJournalLine(GenJournalLine);

        // [THEN] Any error regarding empty Original Doc. VAT Date will occur
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForPayment()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must not cause an error if the type of document is Payment
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::Payment, LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        PostGenJournalLine(GenJournalLine);

        // [THEN] Any error regarding empty Original Doc. VAT Date will occur
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForRefund()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must not cause an error if the type of document is Refund
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::Refund, -LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        PostGenJournalLine(GenJournalLine);

        // [THEN] Any error regarding empty Original Doc. VAT Date will occur
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForReminder()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must not cause an error if the type of document is Reminder
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::Reminder, -LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        PostGenJournalLine(GenJournalLine);

        // [THEN] Any error regarding empty Original Doc. VAT Date will occur
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForCreditMemo()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must cause an error if the type of document is Credit Memo
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::"Credit Memo", LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        asserterror PostGenJournalLine(GenJournalLine);

        // [THEN] An error regarding empty Original Doc. VAT Date will occur
        Assert.ExpectedError(EmptyOrigDocVATDateErr);
    end;

    [Test]
    procedure CheckGenJnlLineWithoutOriginalDocVATDateForInvoice()
    begin
        // [SCENARIO] The posting of Gen. Journal Line without the Original Doc. VAT Date filled in must cause an error if the type of document is Invoice
        Initialize();

        // [GIVEN] The Gen. Journal Line without Original Doc. VAT Date has been created
        CreateGenJournalLineWithoutOriginalDocVATDate(Enum::"Gen. Journal Document Type"::Invoice, -LibraryRandom.RandDec(1000, 2), GenJournalLine);

        // [WHEN] Post created Gen. Journal Line
        asserterror PostGenJournalLine(GenJournalLine);

        // [THEN] An error regarding empty Original Doc. VAT Date will occur
        Assert.ExpectedError(EmptyOrigDocVATDateErr);
    end;

    local procedure CreateGenJournalLineWithoutOriginalDocVATDate(DocumentType: Enum "Gen. Journal Document Type"; Amount: Decimal; var GenJournalLine2: Record "Gen. Journal Line")
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGeneralJnlLineWithBalAcc(
            GenJournalLine2, GenJournalTemplate.Name, GenJournalBatch.Name, DocumentType,
            AccountType::Vendor, LibraryPurchase.CreateVendorNo(),
            AccountType::"G/L Account", LibraryERM.CreateGLAccountNo(), Amount);

        GenJournalLine2.Validate("Original Doc. VAT Date CZL", 0D);
        GenJournalLine2.Modify();
    end;

    local procedure PostGenJournalLine(GenJournalLine2: Record "Gen. Journal Line")
    var
        GenJnlPostLine: Codeunit "Gen. Jnl.-Post Line";
    begin
        GenJnlPostLine.Run(GenJournalLine2);
    end;

    local procedure SetupVATStatementLineForGLAccount(var VATStatementLine: Record "VAT Statement Line"; GLAccount: Record "G/L Account")
    begin
        VATStatementLine."Row No." := '1';
        VATStatementLine.Type := VATStatementLine.Type::"VAT Entry Totaling";
        VATStatementLine."Gen. Posting Type" := VATStatementLine."Gen. Posting Type"::Purchase;
        VATStatementLine."VAT Bus. Posting Group" := GLAccount."VAT Bus. Posting Group";
        VATStatementLine."VAT Prod. Posting Group" := GLAccount."VAT Prod. Posting Group";
        VATStatementLine."Amount Type" := VATStatementLine."Amount Type"::Base;
        VATStatementLine.Modify();
    end;

    [MessageHandler]
    procedure MessageHandler(Msg: Text[1024])
    begin
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Reply := true;
    end;

    [RequestPageHandler]
    procedure CalcPostVATSettlementRequestPageHandlerPenultimatePeriod(var CalcAndPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetRange(Closed, false);
#pragma warning disable AA0233, AA0181
        VATPeriodCZL.FindLast();
        VATPeriodCZL.Next(-1);
#pragma warning restore AA0233, AA0181

        CalcAndPostVATSettlCZL.StartingDate.SetValue(VATPeriodCZL."Starting Date");
        CalcAndPostVATSettlCZL.EndingDate.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.PostingDt.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.SettlementAcc.SetValue(GLAccountNo);
        CalcAndPostVATSettlCZL.DocumentNo.SetValue(CopyStr(LibraryRandom.RandText(20), 1, 20));
        CalcAndPostVATSettlCZL.ShowVATEntries.SetValue(true);
        CalcAndPostVATSettlCZL.Post.SetValue(false);
        CalcAndPostVATSettlCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure CalcPostVATSettlementRequestPageHandlerLastPeriod(var CalcAndPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindLast();

        CalcAndPostVATSettlCZL.StartingDate.SetValue(VATPeriodCZL."Starting Date");
        CalcAndPostVATSettlCZL.EndingDate.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.PostingDt.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.SettlementAcc.SetValue(GLAccountNo);
        CalcAndPostVATSettlCZL.DocumentNo.SetValue(CopyStr(LibraryRandom.RandText(20), 1, 20));
        CalcAndPostVATSettlCZL.ShowVATEntries.SetValue(true);
        CalcAndPostVATSettlCZL.Post.SetValue(false);
        CalcAndPostVATSettlCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure CalcPostVATSettlementRequestPageHandlerWithSettlement(var CalcAndPostVATSettlCZL: TestRequestPage "Calc. and Post VAT Settl. CZL")
    var
        VATPeriodCZL: Record "VAT Period CZL";
    begin
        VATPeriodCZL.SetRange(Closed, false);
        VATPeriodCZL.FindLast();

        CalcAndPostVATSettlCZL.StartingDate.SetValue(VATPeriodCZL."Starting Date");
        CalcAndPostVATSettlCZL.EndingDate.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.PostingDt.SetValue(CalcDate('<CM>', VATPeriodCZL."Starting Date"));
        CalcAndPostVATSettlCZL.SettlementAcc.SetValue(GLAccountNo);
        CalcAndPostVATSettlCZL.DocumentNo.SetValue(VATSettlementDocNoTok);
        CalcAndPostVATSettlCZL.ShowVATEntries.SetValue(false);
        CalcAndPostVATSettlCZL.Post.SetValue(true);
        CalcAndPostVATSettlCZL.OK().Invoke();
    end;
}