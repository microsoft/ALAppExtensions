codeunit 148069 "Balance Sheet Reports CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryFiscalYear: Codeunit "Library - Fiscal Year";
        LibraryRandom: Codeunit "Library - Random";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        AmountErr: Label '%1 must be %2 in %3.', Comment = '%1=FIELDCAPTION,%2=Amount,%3=TABLECAPTION';
        FiscalPostingDateTok: Label 'C%1', Locked = true;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Balance Sheet Reports CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Balance Sheet Reports CZL");

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Balance Sheet Reports CZL");
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageCloseBalanceSheetHandler,MessageHandler')]
    procedure FiscalYearAdditionalCurrency()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
        GenJournalLine: Record "Gen. Journal Line";
        CurrencyCode: Code[10];
        PostingDate: Date;
        AdditionalCurrencyAmount: Decimal;
    begin
        // [SCENARIO] Check Amount on GL Entry After Running Close Balance Sheet with Closing Fiscal Year.
        Initialize();

        // [GIVEN] The already opened fiscal year has been closed
        LibraryFiscalYear.CloseFiscalYear();

        // [GIVEN] The new fiscal year has been created.
        LibraryFiscalYear.CreateFiscalYear();

        // [GIVEN] The currency with random exchange rates has been created and set to general ledger setup.
        CurrencyCode := LibraryERM.CreateCurrencyWithRandomExchRates();
        LibraryERM.SetAddReportingCurrency(CurrencyCode);

        // [GIVEN] The general journal line has been created with random values.
        PostingDate := LibraryFiscalYear.GetFirstPostingDate(false);
        SelectGenJournalBatch(GenJournalBatch);
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify();
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, GenJournalLine."Document Type"::" ",
          GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", -LibraryRandom.RandDec(100, 2));
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Modify(true);
        AdditionalCurrencyAmount := Round(LibraryERM.ConvertCurrency(GenJournalLine.Amount, '', CurrencyCode, WorkDate()));

        // [GIVEN] The created general journal line has been posted.
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] The newly created fiscal year has been closed.
        LibraryFiscalYear.CloseFiscalYear();

        // [GIVEN] The date formula required to calculate fiscal ending date has been customized.
        PostingDate := CalcDate('<1M-1D>', LibraryFiscalYear.GetLastPostingDate(true));

        // [WHEN] Run close balance sheet batch report.
        RunCloseBalanceSheetBatchJob(GenJournalLine, PostingDate);

        // [THEN] The general ledger entry for fiscal year ending date will be created.
        Evaluate(PostingDate, StrSubstNo(FiscalPostingDateTok, PostingDate));
        VerifyGLEntryForFiscalYear(PostingDate, GenJournalLine."Account No.", -GenJournalLine.Amount, -AdditionalCurrencyAmount);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageOpenBalanceSheetHandler')]
    procedure OpeningBalanceSheet()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
    begin
        Initialize();

        // [GIVEN] The general journal batch has been selected.
        SelectGenJournalBatch(GenJournalBatch);

        // [WHEN] Run open balance sheet batch report.
        RunOpenBalanceSheetBatchJob(GenJournalBatch);

        // [THEN] The general journal line won't be exist in the selected batch.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        Assert.RecordIsEmpty(GenJournalLine);
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageCloseIncomeStatementReportHandler,MessageHandler')]
    procedure NotRequiredMandatoryDimensionsForCloseIncome()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        PostingDate: Date;
    begin
        Initialize();

        // [GIVEN] The G/L account has been created.
        CreateGLAccountWithDefaultDimensions(GLAccount);

        // [GIVEN] The fiscal year has been closed.
        LibraryFiscalYear.CloseFiscalYear();
        PostingDate := CalcDate('<1M-1D>', LibraryFiscalYear.GetLastPostingDate(true));

        // [GIVEN] The general journal lines have been created.
        MakeGenJournalLine(GenJournalLine, GenJournalBatch);

        // [GIVEN] Close income statement batch report has been ran.
        RunCloseIncomeStatementBatchJob(GenJournalLine, PostingDate);

        // [WHEN] Post general journal lines.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] The posting will be successfull.
    end;

    [Test]
    [HandlerFunctions('YesConfirmHandler,RequestPageCloseBalanceSheetHandler,MessageHandler')]
    procedure NotRequiredMandatoryDimensionsForCloseBalance()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        PostingDate: Date;
    begin
        Initialize();

        // [GIVEN] The G/L account has been created.
        CreateGLAccountWithDefaultDimensions(GLAccount);

        // [GIVEN] The fiscal year has been closed.
        LibraryFiscalYear.CloseFiscalYear();
        PostingDate := CalcDate('<1M-1D>', LibraryFiscalYear.GetLastPostingDate(true));

        // [GIVEN] The general journal lines have been created.
        MakeGenJournalLine(GenJournalLine, GenJournalBatch);

        // [GIVEN] Close balance sheet batch report has been ran.
        RunCloseBalanceSheetBatchJob(GenJournalLine, PostingDate);

        // [WHEN] Post general journal lines.
        GenJournalLine.SetRange("Journal Template Name", GenJournalBatch."Journal Template Name");
        GenJournalLine.SetRange("Journal Batch Name", GenJournalBatch.Name);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [THEN] The posting will be successfull.
    end;

    local procedure CreateGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        LibraryERM.CreateGenJournalTemplate(GenJournalTemplate);
        LibraryERM.CreateGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        GenJournalBatch.Validate("No. Series", LibraryERM.CreateNoSeriesCode());
        GenJournalBatch.Modify();
    end;

    local procedure CreateGLAccountWithDefaultDimensions(var GLAccount: Record "G/L Account")
    var
        DefaultDimension: Record "Default Dimension";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryDimension.CreateDefaultDimensionGLAcc(DefaultDimension, GLAccount."No.", GetDimensionCode(1), '');
        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Code Mandatory");
        DefaultDimension.Modify();
    end;

    local procedure GetAmountRoundingPrecision(): Decimal
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        exit(GeneralLedgerSetup."Amount Rounding Precision");
    end;

    local procedure GetDimensionCode(DimensionNo: Integer): Code[20]
    var
        GeneralLedgerSetup: Record "General Ledger Setup";
    begin
        GeneralLedgerSetup.Get();
        case DimensionNo of
            1:
                exit(GeneralLedgerSetup."Shortcut Dimension 1 Code");
            2:
                exit(GeneralLedgerSetup."Shortcut Dimension 2 Code");
        end;
    end;

    local procedure MakeGenJournalLine(var GenJournalLine: Record "Gen. Journal Line"; var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        CreateGenJournalBatch(GenJournalBatch);
        GenJournalLine.Init();
        GenJournalLine."Journal Template Name" := GenJournalBatch."Journal Template Name";
        GenJournalLine."Journal Batch Name" := GenJournalBatch.Name;
        GenJournalLine."Document No." :=
          LibraryUtility.GenerateRandomCode(GenJournalLine.FieldNo("Document No."), DATABASE::"Gen. Journal Line");
    end;

    local procedure RunCloseBalanceSheetBatchJob(GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date)
    var
        GLAccount: Record "G/L Account";
        CloseBalanceSheetCZL: Report "Close Balance Sheet CZL";
    begin
        LibraryVariableStorage.Enqueue(PostingDate);
        LibraryVariableStorage.Enqueue(GenJournalLine."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalLine."Journal Batch Name");
        LibraryVariableStorage.Enqueue(IncStr(GenJournalLine."Document No."));
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryVariableStorage.Enqueue(GLAccount."No.");
        Commit();  // Required to commit changes done.
        Clear(CloseBalanceSheetCZL);
        CloseBalanceSheetCZL.Run();
    end;

    local procedure RunCloseIncomeStatementBatchJob(GenJournalLine: Record "Gen. Journal Line"; PostingDate: Date)
    var
        GLAccount: Record "G/L Account";
        CloseIncomeStatementCZL: Report "Close Income Statement CZL";
    begin
        LibraryVariableStorage.Enqueue(PostingDate);
        LibraryVariableStorage.Enqueue(GenJournalLine."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalLine."Journal Batch Name");
        LibraryVariableStorage.Enqueue(IncStr(GenJournalLine."Document No."));
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryVariableStorage.Enqueue(GLAccount."No.");
        Commit();  // Required to commit changes done.
        Clear(CloseIncomeStatementCZL);
        CloseIncomeStatementCZL.Run();
    end;

    local procedure RunOpenBalanceSheetBatchJob(GenJournalBatch: Record "Gen. Journal Batch")
    var
        GLAccount: Record "G/L Account";
        OpenBalanceSheetCZL: Report "Open Balance Sheet CZL";
    begin
        LibraryVariableStorage.Enqueue(GenJournalBatch."Journal Template Name");
        LibraryVariableStorage.Enqueue(GenJournalBatch.Name);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryVariableStorage.Enqueue(GLAccount."No.");
        Commit();  // Required to commit changes done.
        Clear(OpenBalanceSheetCZL);
        OpenBalanceSheetCZL.Run();
    end;

    local procedure SelectGenJournalBatch(var GenJournalBatch: Record "Gen. Journal Batch")
    begin
        // Select General Journal Batch and clear General Journal Lines to make sure that no line exits before creating
        // General Journal Lines.
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch)
    end;

    local procedure VerifyAdditionalCurrencyAmount(var GLEntry: Record "G/L Entry"; AdditionalCurrencyAmount: Decimal)
    begin
        GLEntry.FindFirst();
        Assert.AreNearlyEqual(
          AdditionalCurrencyAmount, GLEntry."Additional-Currency Amount", GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, GLEntry.FieldCaption("Additional-Currency Amount"), AdditionalCurrencyAmount, GLEntry.TableCaption));
    end;

    local procedure VerifyGLEntryForFiscalYear(PostingDate: Date; GLAccountNo: Code[20]; Amount: Decimal; AdditionalCurrencyAmount: Decimal)
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.SetRange("G/L Account No.", GLAccountNo);
        GLEntry.SetRange("Posting Date", PostingDate);
        VerifyAdditionalCurrencyAmount(GLEntry, AdditionalCurrencyAmount);
        Assert.AreNearlyEqual(
          Amount, GLEntry.Amount, GetAmountRoundingPrecision(),
          StrSubstNo(AmountErr, GLEntry.FieldCaption(Amount), Amount, GLEntry.TableCaption));
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text[1024])
    begin
        // Message Handler
    end;

    [RequestPageHandler]
    procedure RequestPageCloseBalanceSheetHandler(var CloseBalanceSheetCZL: TestRequestPage "Close Balance Sheet CZL")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseBalanceSheetCZL.FiscalYearEndingDateFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseBalanceSheetCZL.GenJnlTemplateName.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseBalanceSheetCZL.GenJnlBatchName.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseBalanceSheetCZL.DocNoFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseBalanceSheetCZL.ClosingBalanceSheetGLAccNo.SetValue(FieldVariant);
        CloseBalanceSheetCZL.PostingDescriptionFld.SetValue('Test');
        CloseBalanceSheetCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageCloseIncomeStatementReportHandler(var CloseIncomeStatementCZL: TestRequestPage "Close Income Statement CZL")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseIncomeStatementCZL.FiscalYearEndingDateFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseIncomeStatementCZL.GenJournalTemplateFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseIncomeStatementCZL.GenJournalBatchFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseIncomeStatementCZL.DocumentNoFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        CloseIncomeStatementCZL.RetainedEarningsAccFld.SetValue(FieldVariant);
        CloseIncomeStatementCZL.PostingDescriptionFld.SetValue('Test');
        CloseIncomeStatementCZL.OK().Invoke();
    end;

    [RequestPageHandler]
    procedure RequestPageOpenBalanceSheetHandler(var OpenBalanceSheetCZL: TestRequestPage "Open Balance Sheet CZL")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        OpenBalanceSheetCZL.GenJournalTemplateFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        OpenBalanceSheetCZL.GenJournalBatchFld.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        OpenBalanceSheetCZL.OpeningBalanceSheetAccFld.SetValue(FieldVariant);
        OpenBalanceSheetCZL.PostingDescriptionFld.SetValue('Test');
        OpenBalanceSheetCZL.OK().Invoke();
    end;

    [ConfirmHandler]
    procedure YesConfirmHandler(Question: Text[1024]; var Reply: Boolean)
    begin
        Reply := true;
    end;
}

