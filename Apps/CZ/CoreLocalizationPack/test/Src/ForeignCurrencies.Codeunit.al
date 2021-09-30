codeunit 148088 "Foreign Currencies CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        Assert: Codeunit Assert;
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        IsInitialized: Boolean;
        AmountErr: Label 'Amounts must be the same.';
        ExchRateWasAdjustedTxt: Label 'One or more currency exchange rates have been adjusted.';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Foreign Currencies CZL");

        LibraryVariableStorage.Clear();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Foreign Currencies CZL");

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Foreign Currencies CZL");
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler')]
    procedure AdjustExchangeRateSplitToCustomer()
    begin
        AdjustExchangeRateSplit(true, false);
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler')]
    procedure AdjustExchangeRateSplitToVendor()
    begin
        AdjustExchangeRateSplit(false, true);
    end;

    local procedure AdjustExchangeRateSplit(AdjCust: Boolean; AdjVend: Boolean)
    var
        CurrencyCode: Code[10];
        CurrExchRateDate: array[2] of Date;
        DocumentNo: array[3] of Code[20];
    begin
        Initialize();

        // [GIVEN] The currency with exchange rate has been created
        CurrExchRateDate[1] := WorkDate();
        CurrExchRateDate[2] := CalcDate('<1D>', CurrExchRateDate[1]);
        CurrencyCode := CreateCurrency(CurrExchRateDate);

        // [GIVEN] The Customer Ledger Entries with created currency have been created
        DocumentNo[1] := CreateCustomerLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [GIVEN] The Vendor Ledger Entries with created currency have been created
        DocumentNo[2] := CreateVendorLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [WHEN] Run adjust exchnage rates report
        DocumentNo[3] := GenerateDocumentNo(CurrExchRateDate[1]);
        RunAdjustExchangeRates(
          CurrencyCode, CurrExchRateDate[1], CurrExchRateDate[2], DocumentNo[3], AdjCust, AdjVend, false, false);

        // [THEN] The document number in report will be filled from customer/vendor ledger entry
        if AdjCust then
            LibraryReportDataset.AssertElementWithValueExists('CLEDocumentNo_Fld', DocumentNo[1])
        else
            LibraryReportDataset.AssertElementWithValueNotExist('CLEDocumentNo_Fld', DocumentNo[1]);

        if AdjVend then
            LibraryReportDataset.AssertElementWithValueExists('VLEDocumentNo_Fld', DocumentNo[2])
        else
            LibraryReportDataset.AssertElementWithValueNotExist('VLEDocumentNo_Fld', DocumentNo[2]);
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler')]
    procedure AdjustExchangeRateTestReport()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        CurrencyCode: Code[10];
        CurrExchRateDate: array[2] of Date;
        DocumentNo: Code[20];
    begin
        Initialize();

        // [GIVEN] The currency with exchange rate has been created
        CurrExchRateDate[1] := WorkDate();
        CurrExchRateDate[2] := CalcDate('<1D>', CurrExchRateDate[1]);
        CurrencyCode := CreateCurrency(CurrExchRateDate);

        // [GIVEN] The Customer Ledger Entries with created currency have been created
        CreateCustomerLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [GIVEN] The Vendor Ledger Entries with created currency have been created
        CreateVendorLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [WHEN] Run adjust exchange rates report
        DocumentNo := GenerateDocumentNo(CurrExchRateDate[1]);
        RunAdjustExchangeRates(
          CurrencyCode, CurrExchRateDate[1], CurrExchRateDate[2], DocumentNo, true, true, false, false);

        // [THEN] The post parameter on request page will be false
        LibraryReportDataset.AssertElementWithValueExists('PostVar', Format(false));

        // [THEN] The Detail Customer Ledger Entries won't be exist
        DetailedCustLedgEntry.Reset();
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
        DetailedCustLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordIsEmpty(DetailedCustLedgEntry);

        // [THEN] The Detail Vendor Ledger Entries won't be exist
        DetailedVendorLedgEntry.Reset();
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain");
        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordIsEmpty(DetailedVendorLedgEntry);
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler,StatisticsMessageHandler')]
    procedure AdjustExchangeRatePostingByEntries()
    var
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        DetailedVendorLedgEntry: Record "Detailed Vendor Ledg. Entry";
        CurrencyCode: Code[10];
        CurrExchRateDate: array[2] of Date;
        DocumentNo: Code[20];
    begin
        Initialize();

        // [GIVEN] The currency with exchange rate has been created
        CurrExchRateDate[1] := WorkDate();
        CurrExchRateDate[2] := CalcDate('<1D>', CurrExchRateDate[1]);
        CurrencyCode := CreateCurrency(CurrExchRateDate);

        // [GIVEN] The Customer Ledger Entries with created currency have been created
        CreateCustomerLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [GIVEN] The Vendor Ledger Entries with created currency have been created
        CreateVendorLedgerEntries(CurrencyCode, CurrExchRateDate);

        // [WHEN] Run adjust exchange rates report
        DocumentNo := GenerateDocumentNo(CurrExchRateDate[1]);
        RunAdjustExchangeRates(
          CurrencyCode, CurrExchRateDate[1], CurrExchRateDate[2], DocumentNo, true, true, false, true);

        // [THEN] The Detail Customer Ledger Entries will be exist
        DetailedCustLedgEntry.Reset();
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
        DetailedCustLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordIsNotEmpty(DetailedCustLedgEntry);

        // [THEN] The Detail Vendor Ledger Entries will be exist
        DetailedVendorLedgEntry.Reset();
        DetailedVendorLedgEntry.SetRange("Entry Type", DetailedVendorLedgEntry."Entry Type"::"Unrealized Gain");
        DetailedVendorLedgEntry.SetRange("Document No.", DocumentNo);
        Assert.RecordIsNotEmpty(DetailedVendorLedgEntry);
    end;

    [Test]
    [HandlerFunctions('RequestPageAdjustExchangeRatesHandler,StatisticsMessageHandler')]
    procedure AdjustExchangeRateIncrementalPosting()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
        DetailedCustLedgEntry: Record "Detailed Cust. Ledg. Entry";
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        CurrencyCode: Code[10];
        CurrExchRateDate: array[2] of Date;
        DocumentNo: Code[20];
        Amount: Decimal;
        ExchRateAmount: Decimal;
        OriginalAmountLCY: Decimal;
    begin
        Initialize();

        // [GIVEN] The currency with exchange rate has been created
        CurrExchRateDate[1] := WorkDate();
        CurrExchRateDate[2] := CalcDate('<1D>', CurrExchRateDate[1]);
        CurrencyCode := LibraryERM.CreateCurrencyWithGLAccountSetup();

        // [GIVEN] The currency exchange rate for the first date has been created
        ExchRateAmount := LibraryRandom.RandDec(1, 2);
        LibraryERM.CreateExchangeRate(CurrencyCode, CurrExchRateDate[1], ExchRateAmount, ExchRateAmount);

        // [GIVEN] The general journal batch has been selected
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);

        // [GIVEN] The general journal line has been created
        Amount := LibraryRandom.RandDec(1000, 2);
        DocumentNo := CreateJournalLine(
            GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Invoice,
            GenJournalLine."Account Type"::Customer, LibrarySales.CreateCustomerNo(),
            Amount, CurrExchRateDate[2], CurrencyCode);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // [GIVEN] The currency exchange rate for the second date has been created
        LibraryERM.CreateExchangeRate(CurrencyCode, CurrExchRateDate[2], ExchRateAmount * 2, ExchRateAmount * 2);
        Commit();

        // [WHEN] Run adjust exchange rates report
        RunAdjustExchangeRates(
          CurrencyCode, CurrExchRateDate[1], CurrExchRateDate[2], DocumentNo, true, false, false, true);

        // [THEN] The Detail Customer Ledger Entries will be exist
        DetailedCustLedgEntry.Reset();
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::"Initial Entry");
        DetailedCustLedgEntry.SetRange("Document Type", DetailedCustLedgEntry."Document Type"::Invoice);
        DetailedCustLedgEntry.SetRange("Document No.", DocumentNo);
        DetailedCustLedgEntry.FindFirst();
        OriginalAmountLCY := DetailedCustLedgEntry."Amount (LCY)";

        DetailedCustLedgEntry.Reset();
        DetailedCustLedgEntry.SetRange("Entry Type", DetailedCustLedgEntry."Entry Type"::"Unrealized Loss");
        DetailedCustLedgEntry.SetRange("Document No.", DocumentNo);
        DetailedCustLedgEntry.FindFirst();
        Assert.AreEqual(
          Round((1 / CurrencyExchangeRate.GetCurrentCurrencyFactor(CurrencyCode)) * Amount),
          OriginalAmountLCY + DetailedCustLedgEntry."Amount (LCY)", AmountErr);
    end;

    local procedure CreateCurrency(CurrExchRateDate: array[2] of Date): Code[10]
    var
        CurrencyCode: Code[10];
        ExchRateAmount: Decimal;
    begin
        CurrencyCode := LibraryERM.CreateCurrencyWithGLAccountSetup();
        ExchRateAmount := LibraryRandom.RandDec(1, 2);
        LibraryERM.CreateExchangeRate(CurrencyCode, CurrExchRateDate[1], ExchRateAmount, ExchRateAmount);
        LibraryERM.CreateExchangeRate(CurrencyCode, CurrExchRateDate[2], ExchRateAmount * 2, ExchRateAmount * 2);
        exit(CurrencyCode);
    end;

    local procedure CreateCustomerLedgerEntries(CurrencyCode: Code[10]; PostingDate: array[2] of Date): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        exit(CreateLedgerEntries(
            GenJournalLine."Account Type"::Customer, LibrarySales.CreateCustomerNo(), CurrencyCode, PostingDate));
    end;

    local procedure CreateVendorLedgerEntries(CurrencyCode: Code[10]; PostingDate: array[2] of Date): Code[20]
    var
        GenJournalLine: Record "Gen. Journal Line";
    begin
        exit(CreateLedgerEntries(
            GenJournalLine."Account Type"::Vendor, LibraryPurchase.CreateVendorNo(), CurrencyCode, PostingDate));
    end;

    local procedure CreateLedgerEntries(AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; CurrencyCode: Code[10]; PostingDate: array[2] of Date): Code[20]
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        GenJournalLine: Record "Gen. Journal Line";
        DocumentNo: Code[20];
        Amount: Decimal;
    begin
        Amount := LibraryRandom.RandDec(1000, 2);

        if AccountType = GenJournalLine."Account Type"::Vendor then
            Amount := -Amount;

        LibraryERM.SelectGenJnlBatch(GenJournalBatch);

        // create and post invoice
        DocumentNo := CreateJournalLine(
            GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Invoice,
            AccountType, AccountNo, Amount, PostingDate[1], CurrencyCode);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // create and post payment with first currency exchange rate
        CreateJournalLine(
          GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Payment,
          AccountType, AccountNo, -Amount / 2, PostingDate[1], CurrencyCode);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", DocumentNo);
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);

        // create and post payment with second currency exchange rate
        CreateJournalLine(
          GenJournalLine, GenJournalBatch, GenJournalLine."Document Type"::Payment,
          AccountType, AccountNo, -GenJournalLine.Amount - Amount, CalcDate('<+1D>', PostingDate[2]), CurrencyCode);
        GenJournalLine.Validate("Applies-to Doc. Type", GenJournalLine."Applies-to Doc. Type"::Invoice);
        GenJournalLine.Validate("Applies-to Doc. No.", DocumentNo);
        GenJournalLine.Modify();
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
        exit(DocumentNo);
    end;

    local procedure CreateJournalLine(var GenJournalLine: Record "Gen. Journal Line"; GenJournalBatch: Record "Gen. Journal Batch"; DocumentType: Enum "Gen. Journal Document Type"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20]; Amount: Decimal; PostingDate: Date; CurrencyCode: Code[10]): Code[20]
    begin
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine,
          GenJournalBatch."Journal Template Name",
          GenJournalBatch.Name,
          DocumentType,
          AccountType,
          AccountNo,
          Amount);

        // Update journal line currency
        GenJournalLine.Validate("Posting Date", PostingDate);
        GenJournalLine.Validate("Currency Code", CurrencyCode);
        GenJournalLine.Validate(Description, GenJournalLine."Document No.");
        GenJournalLine.Validate("External Document No.", GenJournalLine."Document No.");
        GenJournalLine.Modify(true);

        exit(GenJournalLine."Document No.");
    end;

    local procedure GenerateDocumentNo(PostingDate: Date): Code[20]
    begin
        exit(StrSubstNo('ADJSK%1%2', Date2DMY(PostingDate, 3), Date2DMY(PostingDate, 2)));
    end;

    local procedure RunAdjustExchangeRates(CurrencyCode: Code[10]; StartDate: Date; EndDate: Date; DocumentNo: Code[20]; AdjCust: Boolean; AdjVend: Boolean; AdjBank: Boolean; Post: Boolean)
    var
        Currency: Record Currency;
        XmlParameters: Text;
    begin
        LibraryVariableStorage.Enqueue(StartDate);
        LibraryVariableStorage.Enqueue(EndDate);
        LibraryVariableStorage.Enqueue(DocumentNo);
        LibraryVariableStorage.Enqueue(AdjCust);
        LibraryVariableStorage.Enqueue(AdjVend);
        LibraryVariableStorage.Enqueue(AdjBank);
        LibraryVariableStorage.Enqueue(Post);

        Currency.SetRange(Code, CurrencyCode);
        XmlParameters := Report.RunRequestPage(Report::"Adjust Exchange Rates CZL");
        LibraryReportDataset.RunReportAndLoad(Report::"Adjust Exchange Rates CZL", Currency, XmlParameters);
    end;

    [RequestPageHandler]
    procedure RequestPageAdjustExchangeRatesHandler(var AdjustExchangeRatesCZL: TestRequestPage "Adjust Exchange Rates CZL")
    var
        FieldVariant: Variant;
    begin
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.StartingDate.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.EndingDate.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.DocumentNo.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjCustField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjVendField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.AdjBankField.SetValue(FieldVariant);
        LibraryVariableStorage.Dequeue(FieldVariant);
        AdjustExchangeRatesCZL.PostField.SetValue(FieldVariant);
        AdjustExchangeRatesCZL.OK().Invoke();
    end;

    [MessageHandler]
    procedure StatisticsMessageHandler(Message: Text[1024])
    begin
        Assert.ExpectedMessage(ExchRateWasAdjustedTxt, Message);
    end;
}

