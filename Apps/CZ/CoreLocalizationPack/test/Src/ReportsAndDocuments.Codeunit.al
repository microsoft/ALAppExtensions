codeunit 148096 "Reports and Documents CZL"
{
    Subtype = Test;
    TestPermissions = NonRestrictive;

    var
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryRandom: Codeunit "Library - Random";
        LibraryReportDataset: Codeunit "Library - Report Dataset";
        LibrarySales: Codeunit "Library - Sales";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        RowNotFoundErr: Label 'There is no dataset row corresponding to Element Name %1 with value %2.', Comment = '%1=Field Caption,%2=Field Value;';

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Reports and Documents CZL");

        LibraryRandom.SetSeed(1);  // Use Random Number Generator to generate the seed for RANDOM function.
        LibraryVariableStorage.Clear();
        LibraryReportDataset.Reset();

        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Reports and Documents CZL");

        UpdateGenJournalTemplate();

        IsInitialized := true;
        Commit();

        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Reports and Documents CZL");
    end;

    [Test]
    [HandlerFunctions('RequestPageCustBalReconHandler')]
    procedure PrintingCustomerBalReconciliation()
    var
        GenJournalLine: Record "Gen. Journal Line";
        CustomerNo: Code[20];
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The customer has been created.
        CustomerNo := LibrarySales.CreateCustomerNo();

        // [GIVEN] The general journal line with customer has been created.
        CreateAndPostGenJnlLineWithCustomer(GenJournalLine, CustomerNo);

        // [WHEN] Print customer balance reconciliation report.
        PrintCustBalReconciliation(CalcDate('<+1M>', GenJournalLine."Posting Date"), GenJournalLine."Posting Date", true, CustomerNo);

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('CVLedgEntryDocumentNo', GenJournalLine."Document No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'CVLedgEntryDocumentNo', GenJournalLine."Document No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('CVLedgEntryAmount', GenJournalLine.Amount);
    end;

    [Test]
    [HandlerFunctions('RequestPageVendBalReconHandler')]
    procedure PrintingVendorBalReconciliation()
    var
        GenJournalLine: Record "Gen. Journal Line";
        VendorNo: Code[20];
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The vendor has been created.
        VendorNo := LibraryPurchase.CreateVendorNo();

        // [GIVEN] The general journal line with vendor has been created.
        CreateAndPostGenJnlLineWithVendor(GenJournalLine, VendorNo);

        // [WHEN] Print vendor balance reconciliation report.
        PrintVendorBalReconciliation(CalcDate('<+1M>', GenJournalLine."Posting Date"), GenJournalLine."Posting Date", true, VendorNo);

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('CVLedgEntryDocumentNo', GenJournalLine."Document No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'CVLedgEntryDocumentNo', GenJournalLine."Document No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('CVLedgEntryAmount', GenJournalLine.Amount);
    end;

    [Test]
    [HandlerFunctions('RequestPageGeneralJournalHandler')]
    procedure PrintingGeneralJournal()
    var
        GenJournalLine: Record "Gen. Journal Line";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The general journal line with g/l account has been created.
        CreateAndPostGenJnlLineWithGLAccount(GenJournalLine, LibraryERM.CreateGLAccountNo());

        // [WHEN] Print general journal report.
        PrintGeneralJournal(GenJournalLine."Posting Date", GenJournalLine."Posting Date");

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('TempGLEntry_DocumentNo', GenJournalLine."Document No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'TempGLEntry_DocumentNo', GenJournalLine."Document No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('TempGLEntry_DebitAmount', GenJournalLine.Amount);
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.AssertCurrentRowValueEquals('TempGLEntry_CreditAmount', GenJournalLine.Amount);
    end;

    [Test]
    [HandlerFunctions('RequestPageGeneralLedgerHandler')]
    procedure PrintingGeneralLedgerLevel1()
    begin
        PrintingGeneralLedgerLevel(900000, 999999, 1, false);
    end;

    [Test]
    [HandlerFunctions('RequestPageGeneralLedgerHandler')]
    procedure PrintingGeneralLedgerLevel2()
    begin
        PrintingGeneralLedgerLevel(990000, 999999, 2, true);
    end;

    local procedure PrintingGeneralLedgerLevel(MinGLAccountNo: Integer; MaxGLAccountNo: Integer; Level: Integer; PrintEntries: Boolean)
    var
        GenJournalLine1: Record "Gen. Journal Line";
        GenJournalLine2: Record "Gen. Journal Line";
        GLAccount1: Record "G/L Account";
        GLAccount2: Record "G/L Account";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The first g/l account has been created.
        CreateGLAccount(GLAccount1, GetNextGLAccountNo(MinGLAccountNo, MaxGLAccountNo));

        // [GIVEN] The general journal line with the first g/l account has been created and posted.
        CreateAndPostGenJnlLineWithGLAccount(GenJournalLine1, GLAccount1."No.");

        // [GIVEN] The second g/l account has been created.
        CreateGLAccount(GLAccount2, GetNextGLAccountNo(MinGLAccountNo, MaxGLAccountNo));

        // [GIVEN] The general journal line with the second g/l account has been created and posted.
        CreateAndPostGenJnlLineWithGLAccount(GenJournalLine2, GLAccount2."No.");

        // [WHEN] Print general ledger report.
        PrintGeneralLedger(Level, PrintEntries, GenJournalLine1."Posting Date");

        // [THEN] The report will correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('GLAccountNo', CopyStr(GLAccount1."No.", 1, Level));
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'GLAccountNo', CopyStr(GLAccount1."No.", 1, Level));
            Error(ErrorMessage);
        end;
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.GetNextRow();
        LibraryReportDataset.AssertCurrentRowValueEquals('TotalAccount_EndDebit', GenJournalLine1.Amount + GenJournalLine2.Amount);
        LibraryReportDataset.AssertElementWithValueExists('Entries', PrintEntries);
    end;

    [Test]
    [HandlerFunctions('RequestPageTurnoverReportByGlobDimHandler')]
    procedure PrintingTurnoverReportByGlobDim1()
    begin
        PrintingTurnoverReportByGlobDim(1);
    end;

    [Test]
    [HandlerFunctions('RequestPageTurnoverReportByGlobDimHandler')]
    procedure PrintingTurnoverReportByGlobDim2()
    begin
        PrintingTurnoverReportByGlobDim(2);
    end;

    local procedure PrintingTurnoverReportByGlobDim(DimensionNo: Integer)
    var
        DefaultDimension: Record "Default Dimension";
        DimensionValue: Record "Dimension Value";
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
        ErrorMessage: Text;
    begin
        Initialize();

        // [GIVEN] The g/l account has been created.
        LibraryERM.CreateGLAccount(GLAccount);

        // [GIVEN] The default dimension of g/l account has been created.
        LibraryDimension.FindDimensionValue(DimensionValue, GetDimensionCode(DimensionNo));
        LibraryDimension.CreateDefaultDimensionGLAcc(
          DefaultDimension, GLAccount."No.", DimensionValue."Dimension Code", DimensionValue.Code);

        // [GIVEN] The general journal line with created g/l account has been created.
        CreateAndPostGenJnlLineWithGLAccount(GenJournalLine, GLAccount."No.");

        // [WHEN] Print turnover report by global dimension.
        PrintTurnoverReportByGlobDim(DimensionNo, GenJournalLine."Posting Date");

        // [THEN] The report will be correctly printed.
        LibraryReportDataset.LoadDataSetFile();
        LibraryReportDataset.SetRange('AccountNo', GLAccount."No.");
        if not LibraryReportDataset.GetNextRow() then begin
            ErrorMessage := StrSubstNo(RowNotFoundErr, 'AccountNo', GLAccount."No.");
            Error(ErrorMessage);
        end;
        LibraryReportDataset.AssertCurrentRowValueEquals('DimCodeText', DimensionValue.Code);
    end;

    local procedure CreateAndPostGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    begin
        CreateGenJnlLine(GenJournalLine, AccountType, AccountNo);
        LibraryERM.PostGeneralJnlLine(GenJournalLine);
    end;

    local procedure CreateAndPostGenJnlLineWithCustomer(var GenJournalLine: Record "Gen. Journal Line"; CustomerNo: Code[20])
    begin
        CreateAndPostGenJnlLine(GenJournalLine, GenJournalLine."Account Type"::Customer, CustomerNo);
    end;

    local procedure CreateAndPostGenJnlLineWithVendor(var GenJournalLine: Record "Gen. Journal Line"; VendorNo: Code[20])
    begin
        CreateAndPostGenJnlLine(GenJournalLine, GenJournalLine."Account Type"::Vendor, VendorNo);
    end;

    local procedure CreateAndPostGenJnlLineWithGLAccount(var GenJournalLine: Record "Gen. Journal Line"; GLAccountNo: Code[20])
    begin
        CreateAndPostGenJnlLine(GenJournalLine, GenJournalLine."Account Type"::"G/L Account", GLAccountNo);
    end;

    local procedure CreateGenJnlLine(var GenJournalLine: Record "Gen. Journal Line"; AccountType: Enum "Gen. Journal Account Type"; AccountNo: Code[20])
    var
        GenJournalBatch: Record "Gen. Journal Batch";
    begin
        LibraryERM.SelectGenJnlBatch(GenJournalBatch);
        LibraryERM.ClearGenJournalLines(GenJournalBatch);
        LibraryERM.CreateGeneralJnlLine(
          GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name, Enum::"Gen. Journal Document Type"::" ",
          AccountType, AccountNo, LibraryRandom.RandDec(1000, 2));
    end;

    local procedure CreateGLAccount(var GLAccount: Record "G/L Account"; GLAccountNo: Code[20])
    begin
        GLAccount.Init();
        GLAccount.Validate("No.", GLAccountNo);
        GLAccount.Validate(Name, GLAccountNo);
        GLAccount.Insert(true);
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

    local procedure GetNextGLAccountNo("Min": Integer; "Max": Integer): Code[20]
    begin
        exit(Format(LibraryRandom.RandIntInRange(Min, Max)));
    end;

    local procedure PrintCustBalReconciliation(ReturnDate: Date; ReconciliationDate: Date; PrintDetail: Boolean; CustomerNo: Code[20])
    begin
        LibraryVariableStorage.Enqueue(ReturnDate);
        LibraryVariableStorage.Enqueue(ReconciliationDate);
        LibraryVariableStorage.Enqueue(PrintDetail);
        LibraryVariableStorage.Enqueue(CustomerNo);

        Report.Run(Report::"Cust.- Bal. Reconciliation CZL", true, false);
    end;

    local procedure PrintGeneralJournal(FromDate: Date; ToDate: Date)
    begin
        LibraryVariableStorage.Enqueue(FromDate);
        LibraryVariableStorage.Enqueue(ToDate);
        Report.Run(Report::"General Journal CZL", true, false);
    end;

    local procedure PrintGeneralLedger(Level: Integer; PrintEntries: Boolean; PostingDate: Date)
    begin
        LibraryVariableStorage.Enqueue(Level);
        LibraryVariableStorage.Enqueue(PrintEntries);
        LibraryVariableStorage.Enqueue(PostingDate);

        Report.Run(Report::"General Ledger CZL", true, false);
    end;

    local procedure PrintTurnoverReportByGlobDim(DimensionNo: Integer; PostingDate: Date)
    begin
        LibraryVariableStorage.Enqueue(DimensionNo);
        LibraryVariableStorage.Enqueue(PostingDate);

        Report.Run(Report::"Turnover Rpt. by Gl. Dim. CZL", true, false);
    end;

    local procedure PrintVendorBalReconciliation(ReturnDate: Date; ReconciliationDate: Date; PrintDetail: Boolean; VendorNo: Code[20])
    begin
        LibraryVariableStorage.Enqueue(ReturnDate);
        LibraryVariableStorage.Enqueue(ReconciliationDate);
        LibraryVariableStorage.Enqueue(PrintDetail);
        LibraryVariableStorage.Enqueue(VendorNo);

        Report.Run(Report::"Vendor-Bal. Reconciliation CZL", true, false);
    end;

    local procedure UpdateGenJournalTemplate()
    var
        GenJournalTemplate: Record "Gen. Journal Template";
    begin
        GenJournalTemplate.Reset();
        GenJournalTemplate.Get(LibraryERM.SelectGenJnlTemplate());
        GenJournalTemplate."Posting Report ID" := Report::"General Ledger Document CZL";
        GenJournalTemplate.Modify();
    end;

    [RequestPageHandler]
    procedure RequestPageCustBalReconHandler(var CustBalReconciliationCZL: TestRequestPage "Cust.- Bal. Reconciliation CZL")
    begin
        CustBalReconciliationCZL.ReturnDateField.SetValue(LibraryVariableStorage.DequeueDate());
        CustBalReconciliationCZL.ReconcileDateField.SetValue(LibraryVariableStorage.DequeueDate());
        CustBalReconciliationCZL.PrintDetailsField.SetValue(LibraryVariableStorage.DequeueBoolean());
        CustBalReconciliationCZL.Customer.SetFilter("No.", LibraryVariableStorage.DequeueText());
        CustBalReconciliationCZL.SaveAsXml(
            LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageVendBalReconHandler(var VendorBalReconciliationCZL: TestRequestPage "Vendor-Bal. Reconciliation CZL")
    begin
        VendorBalReconciliationCZL.ReturnDateField.SetValue(LibraryVariableStorage.DequeueDate());
        VendorBalReconciliationCZL.ReconcileDateField.SetValue(LibraryVariableStorage.DequeueDate());
        VendorBalReconciliationCZL.PrintDetailsField.SetValue(LibraryVariableStorage.DequeueBoolean());
        VendorBalReconciliationCZL.Vendor.SetFilter("No.", LibraryVariableStorage.DequeueText());
        VendorBalReconciliationCZL.SaveAsXml(
            LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageGeneralJournalHandler(var GeneralJournalCZL: TestRequestPage "General Journal CZL")
    begin
        GeneralJournalCZL.FromDateField.SetValue(LibraryVariableStorage.DequeueDate());
        GeneralJournalCZL.ToDateField.SetValue(LibraryVariableStorage.DequeueDate());
        GeneralJournalCZL.SaveAsXml(
            LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageGeneralLedgerHandler(var GeneralLedgerCZL: TestRequestPage "General Ledger CZL")
    begin
        GeneralLedgerCZL.LevelField.SetValue(LibraryVariableStorage.DequeueInteger());
        GeneralLedgerCZL.EntriesField.SetValue(LibraryVariableStorage.DequeueBoolean());
        GeneralLedgerCZL.GLAccount.SetFilter("Date Filter", LibraryVariableStorage.DequeueText());
        GeneralLedgerCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;

    [RequestPageHandler]
    procedure RequestPageTurnoverReportByGlobDimHandler(var TurnoverRptbyGlDimCZL: TestRequestPage "Turnover Rpt. by Gl. Dim. CZL")
    begin
        TurnoverRptbyGlDimCZL.DetailField.SetValue(LibraryVariableStorage.DequeueInteger());
        TurnoverRptbyGlDimCZL."G/L Account".SetFilter("Date Filter", Format(LibraryVariableStorage.DequeueText()));
        TurnoverRptbyGlDimCZL.SaveAsXml(
          LibraryReportDataset.GetParametersFileName(), LibraryReportDataset.GetFileName());
    end;
}

