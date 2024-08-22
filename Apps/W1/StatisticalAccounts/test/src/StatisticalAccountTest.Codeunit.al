codeunit 139683 "Statistical Account Test"
{
    // [FEATURE] [Statistical Accounts]
    Subtype = Test;
    TestPermissions = Disabled;

    var
        Any: Codeunit Any;
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        Initialized: Boolean;
        EMPLOYEESLbl: Label 'EMPLOYEES';
        OFFICESPACELbl: Label 'OFFICESPACE';
        DEPARTMENTLbl: Label 'DEPARTMENT';
        DemoDataSetupCompleteMsg: Label 'The setup was completed successfully.';
        DeleteSetupDataQst: Label 'This action will delete all setup data.';
        REVEMPLLbl: Label 'REV_EMPL';
        EmployeesExpectedAmount: Integer;
        FirstDimensionEmployeeAmount: Integer;
        SecondDimensionEmployeeAmount: Integer;
        ThirdDimensionEmployeeAmount: Integer;
        OfficeSpaceExpectedAmount: Integer;
        TotalNumberOfOfficeSpaceLedgerEntries: Integer;
        TotalNumberOfEmployeeLedgerEntries: Integer;
        BalanceMustBeEqualErr: Label 'Balance must be equal to %1.', Comment = '%1 = Field Value';

    local procedure Initialize()
    var
        AnalysisView: Record "Analysis View";
        StatisticalAccount: Record "Statistical Account";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        StatisticalAccJournalLine: Record "Statistical Acc. Journal Line";
    begin
        StatisticalAccount.DeleteAll();
        StatisticalLedgerEntry.DeleteAll();
        StatisticalAccJournalLine.DeleteAll();
        AnalysisView.DeleteAll(true);
        LibraryVariableStorage.AssertEmpty();

        if Initialized then
            exit;

        EmployeesExpectedAmount := 70;
        OfficeSpaceExpectedAmount := 2820;
        TotalNumberOfEmployeeLedgerEntries := 6;
        TotalNumberOfOfficeSpaceLedgerEntries := 7;
        FirstDimensionEmployeeAmount := 33;
        SecondDimensionEmployeeAmount := 14;
        ThirdDimensionEmployeeAmount := 23;

        Commit();
        Initialized := true;
    end;

    [Test]
    procedure TestCreateStatisticalAccount()
    var
        StatisticalAccount: Record "Statistical Account";
        DimensionValue1: Record "Dimension Value";
        DimensionValue2: Record "Dimension Value";
        DefaultDimension: Record "Default Dimension";
        StatisticalAccountCard: TestPage "Statistical Account Card";
        DefaultDimensions: TestPage "Default Dimensions";
        AccountNo: Code[20];
    begin
        Initialize();

        // [GIVEN] - Dimensions exist
        LibraryDimension.CreateDimWithDimValue(DimensionValue1);
        LibraryDimension.CreateDimWithDimValue(DimensionValue2);

        // [WHEN] A user creates a statistical account with dimensions
        StatisticalAccountCard.OpenNew();
#pragma warning disable AA0139
        AccountNo := UpperCase(Any.AlphabeticText(MaxStrLen(AccountNo)));
#pragma warning restore AA0139

        StatisticalAccountCard."No.".SetValue(AccountNo);
        DefaultDimensions.Trap();
        StatisticalAccountCard.Dimensions.Invoke();

        DefaultDimensions.New();
        DefaultDimensions."Dimension Code".SetValue(DimensionValue1."Dimension Code");
        DefaultDimensions."Dimension Value Code".SetValue(DimensionValue1.Code);
        DefaultDimensions.New();
        DefaultDimensions."Dimension Code".SetValue(DimensionValue2."Dimension Code");
        DefaultDimensions."Dimension Value Code".SetValue(DimensionValue2.Code);
        DefaultDimensions.Close();
        StatisticalAccountCard.Close();

        // [THEN] A New statistical account is created with dimensions
        Assert.IsTrue(StatisticalAccount.Get(AccountNo), 'Statistical account was not created');
        Assert.IsTrue(DefaultDimension.Get(Database::"Statistical Account", StatisticalAccount."No.", DimensionValue1."Dimension Code"), 'Could not get the first dimension');
        Assert.AreEqual(DefaultDimension."Dimension Value Code", DimensionValue1.Code, 'Wrong value for the first dimension');

        Assert.IsTrue(DefaultDimension.Get(Database::"Statistical Account", StatisticalAccount."No.", DimensionValue2."Dimension Code"), 'Could not get the second dimension');
        Assert.AreEqual(DefaultDimension."Dimension Value Code", DimensionValue2.Code, 'Wrong value for the second dimension');
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure TestPostTransactionsToStatisticalAccount()
    var
        StatisticalAccount: Record "Statistical Account";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
        TempStatisticalAccJournalLine: Record "Statistical Acc. Journal Line" temporary;
        StatisticalAccountsJournal: TestPage "Statistical Accounts Journal";
    begin
        Initialize();

        // [GIVEN] - Statistical Account 
        CreateStatisticalAccountWithDimensions(StatisticalAccount);

        // [GIVEN] User creates journal with lines
        StatisticalAccountsJournal.OpenEdit();
        TempStatisticalAccJournalLine."Posting Date" := DT2Date(CurrentDateTime());
        TempStatisticalAccJournalLine."Statistical Account No." := StatisticalAccount."No.";
        TempStatisticalAccJournalLine."Amount" := Any.DecimalInRange(1000, 2);

        StatisticalAccountsJournal."Posting Date".SetValue(TempStatisticalAccJournalLine."Posting Date");
        StatisticalAccountsJournal.StatisticalAccountNo.SetValue(TempStatisticalAccJournalLine."Statistical Account No.");
        StatisticalAccountsJournal.Amount.SetValue(TempStatisticalAccJournalLine.Amount);

        // [WHEN] User posts the journal
        RegisterJournal(StatisticalAccountsJournal);

        // [THEN] Journal and transactions are posted correctly
        StatisticalLedgerEntry.SetRange("Statistical Account No.", StatisticalAccount."No.");
        Assert.AreEqual(1, StatisticalLedgerEntry.Count(), 'Wrong number of posting entries');
        StatisticalLedgerEntry.FindFirst();

        Assert.AreEqual(TempStatisticalAccJournalLine."Posting Date", StatisticalLedgerEntry."Posting Date", 'Wrong posting date');
        Assert.AreEqual(TempStatisticalAccJournalLine."Statistical Account No.", StatisticalLedgerEntry."Statistical Account No.", 'Wrong Statistical Account No.');
        Assert.AreEqual(TempStatisticalAccJournalLine.Amount, StatisticalLedgerEntry.Amount, 'Wrong amount');
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure TestBalancesAreShownCorrectlyOnStatisticalAccount()
    var
        StatisticalAccount: Record "Statistical Account";
        TempStatisticalAccountLedgerEntries: Record "Statistical Ledger Entry" temporary;
        StatisticalAccountsJournal: TestPage "Statistical Accounts Journal";
        StatisticalAccountCard: TestPage "Statistical Account Card";
        StatAccountBalance: TestPage "Stat. Account Balance";
    begin
        Initialize();
        // [GIVEN] - Statistical Account with transactions 
        CreateStatisticalAccountWithDimensions(StatisticalAccount);
        CreateTransactions(StatisticalAccount, 4, TempStatisticalAccountLedgerEntries);
        CreateJournal(StatisticalAccountsJournal, TempStatisticalAccountLedgerEntries);

        RegisterJournal(StatisticalAccountsJournal);
        StatisticalAccountsJournal.Close();

        StatisticalAccountCard.OpenEdit();
        StatisticalAccountCard.GoToRecord(StatisticalAccount);

        // [WHEN] User opens balances with net view
        StatAccountBalance.Trap();
        StatisticalAccountCard.StatisticalAccountBalance.Invoke();
        // [THEN] Balances are show correctly
        VerifyStatisticalAccountBalances(StatAccountBalance, TempStatisticalAccountLedgerEntries);
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure TestDemoDataIsCreatedOnTheFly()
    var
        StatisticalAccount: Record "Statistical Account";
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        // [GIVEN] - A system without any demodata
        Initialize();

        // [WHEN] User invokes create demo data
        CreateDemoData();

        // [THEN] Demodata is generated successfully for Employees
        Assert.AreEqual(2, StatisticalAccount.Count(), 'The statistical accounts are not created correctly');
        Assert.IsTrue(StatisticalAccount.Get(EMPLOYEESLbl), 'Employees account was not created');
        StatisticalAccount.CalcFields(Balance);
        Assert.AreEqual(EmployeesExpectedAmount, StatisticalAccount.Balance, StrSubstNo('Wrong balance on the statistical account %1', StatisticalAccount."No."));
        StatisticalLedgerEntry.SetRange("Statistical Account No.", StatisticalAccount."No.");
        Assert.AreEqual(TotalNumberOfEmployeeLedgerEntries, StatisticalLedgerEntry.Count(), 'Wrong number of statistical account ledger entries');
        StatisticalLedgerEntry.SetRange("Global Dimension 1 Code", '');
        Assert.AreEqual(0, StatisticalLedgerEntry.Count(), 'Global dimension should be assigned to all values.');
        Clear(StatisticalLedgerEntry);

        // [THEN] Demodata is generated successfully for Office Space
        Assert.IsTrue(StatisticalAccount.Get(OFFICESPACELbl), 'Employees account was not created');
        StatisticalAccount.CalcFields(Balance);
        Assert.AreEqual(OfficeSpaceExpectedAmount, StatisticalAccount.Balance, StrSubstNo('Wrong balance on the statistical account %1', StatisticalAccount."No."));
        StatisticalLedgerEntry.SetRange("Statistical Account No.", StatisticalAccount."No.");
        Assert.AreEqual(TotalNumberOfOfficeSpaceLedgerEntries, StatisticalLedgerEntry.Count(), 'Wrong number of statistical account ledger entries');
        StatisticalLedgerEntry.SetRange("Global Dimension 1 Code", '');
        Assert.AreEqual(0, StatisticalLedgerEntry.Count(), 'Global dimension should be assigned to all values.');
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure TestFinancialReportsForStatisticalAccounts()
    var
        FinancialReport: Record "Financial Report";
        FinancialReports: TestPage "Financial Reports";
        AccScheduleOverview: TestPage "Acc. Schedule Overview";
    begin
        // [GIVEN] - A system with demodata
        Initialize();
        SetupFinancialReport();
        CreateFinancialReport(REVEMPLLbl, EMPLOYEESLbl);

        // [WHEN] User invokes show Financial Reports action
        FinancialReport.Get(REVEMPLLbl);
        FinancialReports.OpenEdit();
        FinancialReports.GoToRecord(FinancialReport);
        AccScheduleOverview.Trap();
        FinancialReports.ViewFinancialReport.Invoke();

        // [THEN] Financial Report shows the correct data
        VerifyDemoDataFinancialReport(AccScheduleOverview);
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure TestFinancialReportsForStatisticalAccountsWithAnalysisView()
    var
        FinancialReport: Record "Financial Report";
        AnalysisView: Record "Analysis View";
        AnalysisViewCard: TestPage "Analysis View Card";
        FinancialReports: TestPage "Financial Reports";
        AccScheduleOverview: TestPage "Acc. Schedule Overview";
    begin
        // [GIVEN] A system with financial report
        Initialize();
        SetupFinancialReport();
        CreateFinancialReport(REVEMPLLbl, EMPLOYEESLbl);

        // [GIVEN] Analysis view record for Statistical account 
        CreateAnalysisViewForStatisticalAccount(AnalysisViewCard, AnalysisView);

        // [GIVEN] Analysis view record is setup for the Financial report
        FinancialReport.Get(REVEMPLLbl);
        FinancialReports.OpenEdit();
        FinancialReports.GoToRecord(FinancialReport);
        FinancialReports.AnalysisViewRow.SetValue(AnalysisView.Code);

        // [WHEN] User invokes show Financial Reports action
        AccScheduleOverview.Trap();
        FinancialReports.ViewFinancialReport.Invoke();

        // [THEN] Financial Report shows the correct data
        VerifyDemoDataFinancialReport(AccScheduleOverview);
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler,DimOvervMatrixVerifyCountPageHandler')]
    procedure TestStatisticalAccountsAnalysisView()
    var
        AnalysisView: Record "Analysis View";
        AnalysisViewCard: TestPage "Analysis View Card";
        AnalysisViewList: TestPage "Analysis View List";
        AnalysisbyDimensions: TestPage "Analysis by Dimensions";
        AnalysisAmountType: Enum "Analysis Amount Type";
    begin
        // [GIVEN] A system with financial report
        Initialize();
        SetupFinancialReport();

        // [GIVEN] Analysis view record for Statistical account 
        CreateAnalysisViewForStatisticalAccount(AnalysisViewCard, AnalysisView);
        AnalysisViewCard.Close();

        // [WHEN] User invokes show matrix
        AnalysisViewList.OpenEdit();
        AnalysisViewList.GoToRecord(AnalysisView);
        AnalysisbyDimensions.Trap();
        AnalysisViewList.EditAnalysis.Invoke();
        AnalysisbyDimensions.ColumnDimCode.SetValue(DEPARTMENTLbl);
        AnalysisbyDimensions.QtyType.SetValue(AnalysisAmountType::"Balance at Date");
        LibraryVariableStorage.Enqueue(EMPLOYEESLbl);
        LibraryVariableStorage.Enqueue(EmployeesExpectedAmount);
        LibraryVariableStorage.Enqueue(FirstDimensionEmployeeAmount);
        LibraryVariableStorage.Enqueue(SecondDimensionEmployeeAmount);
        LibraryVariableStorage.Enqueue(ThirdDimensionEmployeeAmount);
        AnalysisbyDimensions.ShowMatrix.Invoke();

        // [THEN] The values are shown correctly
        // Verified in DimOvervMatrixVerifyCountPageHandler
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler,DimOvervMatrixVerifyCountPageHandler')]
    procedure TestGLAndStatisticalAccountsAnalysisView()
    var
        AnalysisView: Record "Analysis View";
        AnalysisViewCard: TestPage "Analysis View Card";
        AnalysisViewList: TestPage "Analysis View List";
        AnalysisbyDimensions: TestPage "Analysis by Dimensions";
        StatisticalAnalysisbyDimensions: TestPage "Analysis by Dimensions";
        AnalysisAmountType: Enum "Analysis Amount Type";
    begin
        // [GIVEN] A system with financial report
        Initialize();
        SetupFinancialReport();

        // [GIVEN] Analysis view record for Statistical account 
        CreateAnalysisViewForGLAndStatisticalAccount(AnalysisViewCard, AnalysisView);
        AnalysisViewCard.Close();

        // [WHEN] User invokes show matrix
        AnalysisViewList.OpenEdit();
        AnalysisViewList.GoToRecord(AnalysisView);
        AnalysisbyDimensions.Trap();
        AnalysisViewList.EditAnalysis.Invoke();

        StatisticalAnalysisbyDimensions.Trap();
        AnalysisbyDimensions.OpenAnalysisByDimensionStatisticalAccounts.Invoke();

        StatisticalAnalysisbyDimensions.ColumnDimCode.SetValue(DEPARTMENTLbl);
        StatisticalAnalysisbyDimensions.QtyType.SetValue(AnalysisAmountType::"Balance at Date");
        LibraryVariableStorage.Enqueue(EMPLOYEESLbl);
        LibraryVariableStorage.Enqueue(EmployeesExpectedAmount);
        LibraryVariableStorage.Enqueue(FirstDimensionEmployeeAmount);
        LibraryVariableStorage.Enqueue(SecondDimensionEmployeeAmount);
        LibraryVariableStorage.Enqueue(ThirdDimensionEmployeeAmount);
        StatisticalAnalysisbyDimensions.ShowMatrix.Invoke();

        // [THEN] The values are shown correctly
        // Verified in DimOvervMatrixVerifyCountPageHandler
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure VerifyBalanceIfThereIsADimensionFilterInStatisticalAccount()
    var
        ColumnLayout: Record "Column Layout";
        DimensionValue: Record "Dimension Value";
        ColumnLayoutName: Record "Column Layout Name";
        AccScheduleName: Record "Acc. Schedule Name";
        AccScheduleLine: Record "Acc. Schedule Line";
        FinancialReport: Record "Financial Report";
        FinancialReports: TestPage "Financial Reports";
        AccScheduleOverview: TestPage "Acc. Schedule Overview";
        ExpectedAmount: Decimal;
        DateFilter: Text;
    begin
        // [SCENARIO 476816] Verify Balance should be shown correctly filtered by Global Dim 1 Department = ADM in the Financial Reports.
        Initialize();

        // [GIVEN] Find the Global Dimension 1.
        LibraryDimension.GetGlobalDimCodeValue(1, DimensionValue);

        // [GIVEN] Setup Demo Data.
        SetupFinancialReport();

        // [GIVEN] Create a Column Name and Column Layout.
        LibraryERM.CreateColumnLayoutName(ColumnLayoutName);

        LibraryERM.CreateColumnLayout(ColumnLayout, ColumnLayoutName.Name);
        ColumnLayout.Validate("Column Type", "Column Layout Type"::"Balance at Date");
        ColumnLayout.Modify();

        // [GIVEN] Create a Account Schedule Name and Line with "Statistical Account" and Dimension.
        LibraryERM.CreateAccScheduleName(AccScheduleName);

        LibraryERM.CreateAccScheduleLine(AccScheduleLine, AccScheduleName.Name);
        AccScheduleLine.Validate("Dimension 1 Totaling", DimensionValue.Code);
        AccScheduleLine.Validate("Totaling Type", "Acc. Schedule Line Totaling Type"::"Statistical Account");
        AccScheduleLine.Validate(Totaling, OFFICESPACELbl);
        AccScheduleLine.Modify();

        // [GIVEN] Update "Financial Report Column Group" in Financial report.
        FinancialReport.Get(AccScheduleLine."Schedule Name");
        FinancialReport.Validate("Financial Report Column Group", ColumnLayout."Column Layout Name");
        FinancialReport.Modify();

        // [WHEN] Run Account Schedule Overview with "Period Type" as year.
        FinancialReports.OpenEdit();
        FinancialReports.Filter.SetFilter(Name, AccScheduleName.Name);
        AccScheduleOverview.Trap();
        FinancialReports.Overview.Invoke();
        AccScheduleOverview.PeriodType.SetValue("Analysis Period Type"::Year);

        // [GIVEN] Save the Date Filter.
        DateFilter := Format(AccScheduleOverview.DateFilter);
        ExpectedAmount := GetExpectedStatisticalLedgerEntryValue(
                            AccScheduleLine,
                            CopyStr(DateFilter, StrPos(DateFilter, '.')), DimensionValue.Code);

        // [VERIFY] Verify Balance should be shown correctly filtered by Global Dim 1 Department = ADM in the Financial Reports.
        Assert.AreEqual(
            ExpectedAmount,
            AccScheduleOverview.ColumnValues1.AsDecimal(),
            StrSubstNo(BalanceMustBeEqualErr, ExpectedAmount));
    end;

    [Test]
    [HandlerFunctions('MessageDialogHandler,ConfirmationDialogHandler')]
    procedure VerifyShortcutDimensionsInTheStatisticalAccountsJournal()
    var
        DimensionValue: array[8] of Record "Dimension Value";
        StatisticalAccount: Record "Statistical Account";
    begin
        // [SCENARIO 484054] Verify that the Shortcut Dimensions in the Statistical Accounts Journal.
        Initialize();

        // [GIVEN] Setup Demo Data.
        CreateDemoData();

        // [GIVEN] Update ShortCut Dimension.
        UpdateShortcutDimensionSetup(DimensionValue);

        // [GIVEN] Create a Statistical Account.
        CreateStatisticalAccount(StatisticalAccount);

        // [GIVEN] Create a Statistical Account Journal Lines.
        CreateStatisticalAccountsJournal(DimensionValue, StatisticalAccount, LibraryRandom.RandInt(10));

        // [VERIFY] Verify that the Shortcut Dimensions in the Statistical Accounts Journal.
        VerifyShortcutDimensionsInStatisticalAccountsJournal(DimensionValue, StatisticalAccount);
    end;

    [Test]
    procedure VerifyShortcutDimensionClearWhenNewLineSetupOnStatisticalAccountJournal()
    var
        StatisticalAccount: Record "Statistical Account";
        DimensionValue: Record "Dimension Value";
        StatisticalAccountsJournal: TestPage "Statistical Accounts Journal";
    begin
        // [SCENARIO 487974] Issues with manually entering the lines on the Statistical Account Journal with Dimensions as well as copying & pasting into the journal.
        Initialize();

        // [GIVEN] - Create Statistical Account with Dimension
        CreateStatisticalAccountWithDimensions(StatisticalAccount);

        // [GIVEN] Create new Shortcut Dimensiona and update ShortCut Dimension.
        LibraryDimension.CreateDimWithDimValue(DimensionValue);
        LibraryERM.SetShortcutDimensionCode(3, DimensionValue."Dimension Code");

        // [THEN] Create Statistical Account Journal Lines on Page, set defaults and Shortcut Dimension 3
        StatisticalAccountsJournal.OpenEdit();
        StatisticalAccountsJournal.New();
        StatisticalAccountsJournal."Posting Date".SetValue(WorkDate());
        StatisticalAccountsJournal."Document No.".SetValue(LibraryRandom.RandText(10));
        StatisticalAccountsJournal.StatisticalAccountNo.SetValue(StatisticalAccount."No.");
        StatisticalAccountsJournal.Amount.SetValue(LibraryRandom.RandInt(20));
        StatisticalAccountsJournal.ShortcutDimCode3.SetValue(DimensionValue.Code);

        // [WHEN] Move to Next Line
        StatisticalAccountsJournal.Next();

        // [VERIFY] Verify: Moving to next line the shortcut dimension 3 should blank
        StatisticalAccountsJournal.ShortcutDimCode3.AssertEquals('');
        StatisticalAccountsJournal.Close();
    end;

    [Test]
    [HandlerFunctions('StatAccJnlBatcheModalPageHandler')]
    procedure SwitchBatchNameOnStatAccJnl()
    var
        StatisticalAccount: Record "Statistical Account";
        StatAccJnlBatch: array[2] of Record "Statistical Acc. Journal Batch";
        StatAccJnlLine: Record "Statistical Acc. Journal Line";
        StatAccJnlPage: TestPage "Statistical Accounts Journal";
        i: Integer;
    begin
        // [SCENARIO 544841] Switching the batch name on the Statistical Account Journal works correctly

        Initialize();
        CreateStatisticalAccount(StatisticalAccount);
        // [GIVEN] Two statistical Account Journal Batches - "X" and "Y"
        for i := 1 to ArrayLen(StatAccJnlBatch) do begin
            StatAccJnlBatch[i].Validate(Name, LibraryUtility.GenerateGUID());
            StatAccJnlBatch[i].Insert(true);
        end;
        // [GIVEN] Statistical Account Journal Line for batch "X"
        StatAccJnlLine.Validate("Journal Batch Name", StatAccJnlBatch[1].Name);
        StatAccJnlLine.Validate("Statistical Account No.", StatisticalAccount."No.");
        StatAccJnlLine.Insert(true);

        // [GIVEN] Statistical account opened for the batch "X"
        StatAccJnlPage.OpenEdit();
        StatAccJnlPage.CurrentJnlBatchName.SetValue(StatAccJnlBatch[1].Name);

        LibraryVariableStorage.Enqueue(StatAccJnlBatch[2].Name); // for StatAccJnlBatcheModalPageHandler
        // [WHEN] Stan switches the batch to "Y" via lookup
        StatAccJnlPage.CurrentJnlBatchName.Lookup();

        // [THEN] No statistical account journal lines shown for this batch
        StatAccJnlPage.StatisticalAccountNo.AssertEquals('');
        LibraryVariableStorage.AssertEmpty();

        // Tear down
        StatAccJnlPage.Close();
    end;

    local procedure SetupFinancialReport()
    var
        AccScheduleLine: Record "Acc. Schedule Line";
        AccScheduleLineTotalingType: Enum "Acc. Schedule Line Totaling Type";
    begin
        CreateDemoData();
        AccScheduleLine.SetRange("Schedule Name", REVEMPLLbl);
        AccScheduleLine.SetFilter("Totaling Type", '<>%1', AccScheduleLineTotalingType::"Statistical Account");
        AccScheduleLine.DeleteAll();
    end;

    local procedure CreateDemoData()
    var
        StatisticalAccountList: TestPage "Statistical Account List";
    begin
        StatisticalAccountList.OpenEdit();
        LibraryVariableStorage.Enqueue(DeleteSetupDataQst);
        LibraryVariableStorage.Enqueue(true);
        StatisticalAccountList.CleanupDemoData.Invoke();

        LibraryVariableStorage.Enqueue(DemoDataSetupCompleteMsg);
        StatisticalAccountList.SetupDemoData.Invoke();
    end;

    local procedure CreateAnalysisViewForStatisticalAccount(var AnalysisViewCard: TestPage "Analysis View Card"; var AnalysisView: Record "Analysis View")
    var
        AnalysisViewCode: Code[10];
    begin
        AnalysisViewCard.OpenNew();
        AnalysisViewCode := CopyStr(Any.AlphabeticText(10), 1, 10);
        AnalysisViewCard.Code.SetValue(AnalysisViewCode);
        AnalysisViewCard."Account Source".SetValue(AnalysisView."Account Source"::"Statistical Account");
        AnalysisViewCard."Account Filter".SetValue(EMPLOYEESLbl);
        AnalysisViewCard."Dimension 1 Code".SetValue(DEPARTMENTLbl);
        AnalysisViewCard."&Update".Invoke();
        AnalysisView.Get(AnalysisViewCode);
    end;

    local procedure CreateAnalysisViewForGLAndStatisticalAccount(var AnalysisViewCard: TestPage "Analysis View Card"; var AnalysisView: Record "Analysis View")
    var
        GLAccount: Record "G/L Account";
        AnalysisViewCode: Code[10];
    begin
        AnalysisViewCard.OpenNew();
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        GLAccount.FindFirst();

        AnalysisViewCode := CopyStr(Any.AlphabeticText(10), 1, 10);
        AnalysisViewCard.Code.SetValue(AnalysisViewCode);
        AnalysisViewCard."Account Source".SetValue(AnalysisView."Account Source"::"G/L Account");
        AnalysisViewCard."Account Filter".SetValue(GLAccount."No.");
        AnalysisViewCard.StatisticalAccountFilter.SetValue(EMPLOYEESLbl);
        AnalysisViewCard."Dimension 1 Code".SetValue(DEPARTMENTLbl);
        AnalysisViewCard."&Update".Invoke();
        AnalysisView.Get(AnalysisViewCode);
    end;

    local procedure RegisterJournal(var StatisticalAccountsJournal: TestPage "Statistical Accounts Journal")
    begin
        LibraryVariableStorage.Enqueue('register');
        LibraryVariableStorage.Enqueue(true);
        LibraryVariableStorage.Enqueue('successfully');
        StatisticalAccountsJournal.Register.Invoke();
    end;

    local procedure VerifyStatisticalAccountBalances(var StatAccountBalance: TestPage "Stat. Account Balance"; var TempStatisticalAccountLedgerEntries: Record "Statistical Ledger Entry" temporary)
    var
        AnalysisPeriodType: Enum "Analysis Period Type";
    begin
        StatAccountBalance.PeriodType.SetValue(AnalysisPeriodType::Day);

        TempStatisticalAccountLedgerEntries.Reset();
        TempStatisticalAccountLedgerEntries.FindSet();
        repeat
            StatAccountBalance.StatisticalAccountBalanceLines.Filter.SetFilter("Period Start", Format(TempStatisticalAccountLedgerEntries."Posting Date"));
            Assert.AreEqual(StatAccountBalance.StatisticalAccountBalanceLines.Amount.AsDecimal(), TempStatisticalAccountLedgerEntries.Amount, 'Wrong amount was set.');
        until TempStatisticalAccountLedgerEntries.Next() = 0;
    end;

    local procedure CreateTransactions(var StatisticalAccount: Record "Statistical Account"; NumberOfTransactions: Integer; var TempStatisticalAccountLedgerEntries: Record "Statistical Ledger Entry" temporary)
    var
        I: Integer;
        CurrentDate: Date;
    begin
        CurrentDate := CalcDate(StrSubstNo('<-%1D>', NumberOfTransactions + 5), DT2Date(CurrentDateTime()));
        for I := 1 to NumberOfTransactions do begin
            TempStatisticalAccountLedgerEntries."Entry No." := TempStatisticalAccountLedgerEntries."Entry No." + 1;
            TempStatisticalAccountLedgerEntries."Posting Date" := CurrentDate;
            TempStatisticalAccountLedgerEntries."Statistical Account No." := StatisticalAccount."No.";
            TempStatisticalAccountLedgerEntries."Amount" := Any.DecimalInRange(1000, 2);
            TempStatisticalAccountLedgerEntries.Insert();
            CurrentDate := CalcDate('<+1D>', CurrentDate);
        end;
    end;

    local procedure CreateJournal(var StatisticalAccountsJournal: TestPage "Statistical Accounts Journal"; var TempStatisticalAccountLedgerEntries: Record "Statistical Ledger Entry" temporary)
    begin
        StatisticalAccountsJournal.OpenEdit();

        TempStatisticalAccountLedgerEntries.Reset();
        TempStatisticalAccountLedgerEntries.FindSet();
        repeat
            StatisticalAccountsJournal.New();
            StatisticalAccountsJournal."Posting Date".SetValue(TempStatisticalAccountLedgerEntries."Posting Date");
            StatisticalAccountsJournal.StatisticalAccountNo.SetValue(TempStatisticalAccountLedgerEntries."Statistical Account No.");
            StatisticalAccountsJournal.Amount.SetValue(TempStatisticalAccountLedgerEntries.Amount);
        until TempStatisticalAccountLedgerEntries.Next() = 0;
    end;

    local procedure CreateStatisticalAccountWithDimensions(var StatisticalAccount: Record "Statistical Account")
    var
        DefaultDimension: Record "Default Dimension";
        DefaultDimensionValuePostingType: Enum "Default Dimension Value Posting Type";
    begin
        CreateStatisticalAccount(StatisticalAccount);
        LibraryDimension.CreateDefaultDimensionWithNewDimValue(DefaultDimension, Database::"Statistical Account", StatisticalAccount."No.", DefaultDimensionValuePostingType::" ");
        LibraryDimension.CreateDefaultDimensionWithNewDimValue(DefaultDimension, Database::"Statistical Account", StatisticalAccount."No.", DefaultDimensionValuePostingType::" ");
    end;

    local procedure CreateStatisticalAccount(var StatisticalAccount: Record "Statistical Account")
    begin
#pragma warning disable AA0139
        StatisticalAccount."No." := Any.AlphabeticText(MaxStrLen(StatisticalAccount."No."));
        StatisticalAccount.Name := Any.AlphabeticText(MaxStrLen(StatisticalAccount.Name));
#pragma warning restore AA0139

        StatisticalAccount.Insert();
    end;

    local procedure VerifyDemoDataFinancialReport(var AccScheduleOverview: TestPage "Acc. Schedule Overview")
    begin
        Assert.AreEqual(EmployeesExpectedAmount, AccScheduleOverview.ColumnValues1.AsInteger(), 'Wrong value for the first column');
        Assert.AreNotEqual(AccScheduleOverview.ColumnValues2.AsInteger(), 0, 'Wrong value for the second column');
        Assert.AreNotEqual(AccScheduleOverview.ColumnValues3.AsInteger(), 0, 'Wrong value for the third column');
    end;

    [MessageHandler]
    procedure MessageDialogHandler(Message: Text[1024])
    var
        ExpectedMsg: Variant;
    begin
        LibraryVariableStorage.Dequeue(ExpectedMsg);
        Assert.IsTrue(StrPos(Message, ExpectedMsg) > 0, Message);
    end;

    [ConfirmHandler]
    procedure ConfirmationDialogHandler(Question: Text[1024]; var Reply: Boolean)
    var
        ExpectedQuestion: Text;
    begin
        ExpectedQuestion := LibraryVariableStorage.DequeueText();
        Assert.IsTrue(StrPos(Question, ExpectedQuestion) > 0, 'Expected ' + Question);
        Reply := LibraryVariableStorage.DequeueBoolean();
    end;

    [ModalPageHandler]
    [Scope('OnPrem')]
    procedure DimOvervMatrixVerifyCountPageHandler(var AnalysisbyDimensionsMatrix: TestPage "Analysis by Dimensions Matrix")
    begin
        AnalysisbyDimensionsMatrix.First();
        Assert.AreEqual(AnalysisbyDimensionsMatrix.Code.Value(), LibraryVariableStorage.DequeueText(), 'Code value is incorrect');
        Assert.AreEqual(AnalysisbyDimensionsMatrix.TotalAmount.AsInteger(), LibraryVariableStorage.DequeueInteger(), 'Wrong value for Total Amount');
        Assert.AreEqual(AnalysisbyDimensionsMatrix.Field1.AsInteger(), LibraryVariableStorage.DequeueInteger(), 'Wrong value for first entry');
        Assert.AreEqual(AnalysisbyDimensionsMatrix.Field2.AsInteger(), LibraryVariableStorage.DequeueInteger(), 'Wrong value for second entry');
        Assert.AreEqual(AnalysisbyDimensionsMatrix.Field3.AsInteger(), LibraryVariableStorage.DequeueInteger(), 'Wrong value for third entry');
    end;

    local procedure CreateFinancialReport(FinancialReportName: Code[10]; TotalingFilter: Text[250])
    var
        RevenuePerEmpAccScheduleName: Record "Acc. Schedule Name";
        RevenuePerEmpAccScheduleLine: Record "Acc. Schedule Line";
        RevenuePerEmpFinancialReport: Record "Financial Report";
        ColumnLayoutName: Record "Column Layout Name";
    begin
        if RevenuePerEmpFinancialReport.Get(FinancialReportName) then
            RevenuePerEmpFinancialReport.Delete();

        Clear(RevenuePerEmpFinancialReport);
        RevenuePerEmpFinancialReport.Name := FinancialReportName;
        RevenuePerEmpFinancialReport.Description := FinancialReportName;
        RevenuePerEmpFinancialReport.Insert();

        RevenuePerEmpAccScheduleLine.SetRange("Schedule Name", FinancialReportName);
        RevenuePerEmpAccScheduleLine.DeleteAll();

        if RevenuePerEmpAccScheduleName.Get(FinancialReportName) then
            RevenuePerEmpAccScheduleName.Delete();

        RevenuePerEmpAccScheduleName.Name := FinancialReportName;
        RevenuePerEmpAccScheduleName.Description := FinancialReportName;
        RevenuePerEmpAccScheduleName."Analysis View Name" := '';
        RevenuePerEmpAccScheduleName.Insert();

        RevenuePerEmpAccScheduleLine.Init();
        RevenuePerEmpAccScheduleLine."Schedule Name" := FinancialReportName;
        RevenuePerEmpAccScheduleLine."Line No." := 10000;
        RevenuePerEmpAccScheduleLine."Totaling Type" := RevenuePerEmpAccScheduleLine."Totaling Type"::"Statistical Account";
        RevenuePerEmpAccScheduleLine.Totaling := TotalingFilter;
        RevenuePerEmpAccScheduleLine."Row No." := '20';
        RevenuePerEmpAccScheduleLine.Description := FinancialReportName;
        RevenuePerEmpAccScheduleLine."Row Type" := RevenuePerEmpAccScheduleLine."Row Type"::"Balance at Date";
        RevenuePerEmpAccScheduleLine.Bold := true;
        RevenuePerEmpAccScheduleLine.Insert();

        LibraryERM.CreateColumnLayoutName(ColumnLayoutName);
        CreateColumnLayout(ColumnLayoutName.Name, '10', 'Current Period', 10000, '');
        CreateColumnLayout(ColumnLayoutName.Name, '20', 'Period - 1', 20000, '-1P');
        CreateColumnLayout(ColumnLayoutName.Name, '30', 'Period - 2', 30000, '-2P');

        RevenuePerEmpFinancialReport.Find();
        RevenuePerEmpFinancialReport."Financial Report Row Group" := RevenuePerEmpAccScheduleName.Name;
        RevenuePerEmpFinancialReport."Financial Report Column Group" := ColumnLayoutName.Name;
        RevenuePerEmpFinancialReport.Modify();
    end;

    local procedure CreateColumnLayout(ColumnLayoutName: Code[10]; ColumnNo: Code[10]; ColumnHeader: Code[30]; LineNo: Integer; ComparisonPeriodFormula: Text[10])
    var
        ColumnLayout: Record "Column Layout";
    begin
        ColumnLayout.Validate("Column Layout Name", ColumnLayoutName);
        ColumnLayout.Validate("Line No.", LineNo);
        ColumnLayout.Validate("Column No.", ColumnNo);
        ColumnLayout.Validate("Column Header", ColumnHeader);
        ColumnLayout.Validate("Comparison Period Formula", ComparisonPeriodFormula);
        ColumnLayout.Insert();
    end;

    local procedure GetExpectedStatisticalLedgerEntryValue(
        AccScheduleLine: Record "Acc. Schedule Line";
        DateFilter: Text;
        DimensionCode: Code[20]): Decimal
    var
        StatisticalLedgerEntry: Record "Statistical Ledger Entry";
    begin
        StatisticalLedgerEntry.SetFilter("Statistical Account No.", AccScheduleLine.Totaling);
        StatisticalLedgerEntry.SetFilter("Posting Date", DateFilter);
        StatisticalLedgerEntry.SetRange("Global Dimension 1 Code", DimensionCode);
        StatisticalLedgerEntry.CalcSums(Amount);

        exit(StatisticalLedgerEntry.Amount);
    end;

    local procedure UpdateShortcutDimensionSetup(var DimensionValue: array[8] of Record "Dimension Value")
    var
        i: Integer;
    begin
        for i := 3 to ArrayLen(DimensionValue) do begin
            LibraryDimension.CreateDimWithDimValue(DimensionValue[i]);
            LibraryERM.SetShortcutDimensionCode(i, DimensionValue[i]."Dimension Code");
        end;
    end;

    local procedure CreateStatisticalAccountsJournal(
        var DimensionValue: array[8] of Record "Dimension Value";
        StatisticalAccount: Record "Statistical Account";
        NoOfLines: Integer)
    var
        StatisticalAccountsJournal: TestPage "Statistical Accounts Journal";
        i: Integer;
    begin
        for i := 1 to NoOfLines do begin
            StatisticalAccountsJournal.OpenEdit();
            StatisticalAccountsJournal.New();
            StatisticalAccountsJournal."Posting Date".SetValue(WorkDate());
            StatisticalAccountsJournal."Document No.".SetValue(LibraryRandom.RandText(10));
            StatisticalAccountsJournal.StatisticalAccountNo.SetValue(StatisticalAccount."No.");
            StatisticalAccountsJournal.Amount.SetValue(LibraryRandom.RandInt(20));
            StatisticalAccountsJournal.ShortcutDimCode3.SetValue(DimensionValue[3].Code);
            StatisticalAccountsJournal.ShortcutDimCode4.SetValue(DimensionValue[4].Code);
            StatisticalAccountsJournal.ShortcutDimCode5.SetValue(DimensionValue[5].Code);
            StatisticalAccountsJournal.ShortcutDimCode6.SetValue(DimensionValue[6].Code);
            StatisticalAccountsJournal.ShortcutDimCode7.SetValue(DimensionValue[7].Code);
            StatisticalAccountsJournal.ShortcutDimCode8.SetValue(DimensionValue[8].Code);
            StatisticalAccountsJournal.Close();
        end;
    end;

    local procedure VerifyShortcutDimensionsInStatisticalAccountsJournal(
        DimensionValue: array[8] of Record "Dimension Value";
        StatisticalAccount: Record "Statistical Account")
    var
        StatisticalAccountJournalLine: Record "Statistical Acc. Journal Line";
        StatisticalAccountsJournal: TestPage "Statistical Accounts Journal";
    begin
        StatisticalAccountJournalLine.Reset();
        StatisticalAccountJournalLine.SetRange("Statistical Account No.", StatisticalAccount."No.");
        if StatisticalAccountJournalLine.FindSet() then
            repeat
                StatisticalAccountsJournal.OpenView();
                StatisticalAccountsJournal.GoToRecord(StatisticalAccountJournalLine);
                StatisticalAccountsJournal.ShortcutDimCode3.AssertEquals(DimensionValue[3].Code);
                StatisticalAccountsJournal.ShortcutDimCode4.AssertEquals(DimensionValue[4].Code);
                StatisticalAccountsJournal.ShortcutDimCode5.AssertEquals(DimensionValue[5].Code);
                StatisticalAccountsJournal.ShortcutDimCode6.AssertEquals(DimensionValue[6].Code);
                StatisticalAccountsJournal.ShortcutDimCode7.AssertEquals(DimensionValue[7].Code);
                StatisticalAccountsJournal.ShortcutDimCode8.AssertEquals(DimensionValue[8].Code);
                StatisticalAccountsJournal.Close();
            until StatisticalAccountJournalLine.Next() = 0;
    end;

    [ModalPageHandler]
    procedure StatAccJnlBatcheModalPageHandler(var StatBatch: TestPage "Statistical Acc. Journal Batch")
    begin
        StatBatch.Filter.SetFilter(Name, LibraryVariableStorage.DequeueText());
        StatBatch.OK().Invoke();
    end;

}