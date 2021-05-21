codeunit 148102 "SAF-T Unit Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [UT]
    end;

    var
        LibraryERM: Codeunit "Library - ERM";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryRandom: Codeunit "Library - Random";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        Assert: Codeunit Assert;
        IsInitialized: Boolean;
        MatchChartOfAccountsQst: Label 'Do you want to match a chart of accounts with SAF-T standard account codes?';
        CreateChartOfAccountsQst: Label 'Do you want to create a chart of accounts based on SAF-T standard account codes?';
        StandardAccountsMatchedMsg: Label '%1 of %2 standard accounts have been automatically matched to the chart of accounts.', Comment = '%1,%2 = both integer values';
        OverwriteMappingQst: Label 'Do you want to change the already defined G/L account mapping to the new mapping?';
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';

    [Test]
    procedure VATPostingSetupHasTaxCodesOnInsert()
    var
        VATBusinessPostingGroup: Record "VAT Business Posting Group";
        VATProductPostingGroup: Record "VAT Product Posting Group";
        VATPostingSetup: Record "VAT Posting Setup";
    begin
        // [FEATURE] [VAT]
        // [SCENARIO 309923] A newly inserted VAT Posting Setup has "Sales SAF-T Tax Code" and "Purchase SAF-T Tax Code" 
        Initialize();
        LibraryERM.CreateVATBusinessPostingGroup(VATBusinessPostingGroup);
        LibraryERM.CreateVATProductPostingGroup(VATProductPostingGroup);
        LibraryERM.CreateVATPostingSetup(VATPostingSetup, VATBusinessPostingGroup.Code, VATProductPostingGroup.Code);
        VATPostingSetup.TestField("Sales SAF-T Tax Code");
        VATPostingSetup.TestField("Purchase SAF-T Tax Code");
        // Tear down
        VATPostingSetup.Delete();
    end;

    [Test]
    procedure DimensionHasSAFTCodeAndExportToSAFTByDefaultOnInsert()
    var
        Dimension: Record Dimension;
    begin
        // [FEATURE] [Dimension]
        // [SCENARIO 309923] A newly inserted Dimension has "SAF-T Analysis Type" and "Export-To SAF-T" on

        Initialize();
        LibraryDimension.CreateDimension(Dimension);
        Dimension.TestField("SAF-T Analysis Type");
        Dimension.TestField("Export to SAF-T");
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure MatchChartOfAccounts()
    var
        GLAccount: Record "G/L Account";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        AccountsToBeMatched: Integer;
        i: Integer;
    begin
        // [SCENARIO 309923] G/L accounts with numbers same as SAF-T Standard Account are matched automatically

        Initialize();
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        GLAccount.DeleteAll();
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindSet();
        AccountsToBeMatched := LibraryRandom.RandIntInRange(3, 5);
        for i := 1 to AccountsToBeMatched do begin
            GLAccount.Init();
            GLAccount."No." := SAFTMapping."No.";
            GLAccount."Account Type" := GLAccount."Account Type"::Posting;
            GLAccount.Insert();
            SAFTMapping.Next();
        end;
        LibraryERM.CreateGLAccountNo();
        LibraryVariableStorage.Enqueue(MatchChartOfAccountsQst);
        LibraryVariableStorage.Enqueue(StrSubstNo(StandardAccountsMatchedMsg, AccountsToBeMatched, GLAccount.Count()));
        SAFTMappingHelper.MatchChartOfAccounts(SAFTMappingRange);
        SAFTGLAccountMapping.SetRange("Mapping Range Code", SAFTMappingRange.Code);
        SAFTGLAccountMapping.SetFilter("No.", '<>%1', '');
        Assert.RecordCount(SAFTGLAccountMapping, AccountsToBeMatched);
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler,MessageHandler')]
    procedure CreateChartOfAccounts()
    var
        GLAccount: Record "G/L Account";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 309923] G/L accounts creates from SAF-T Standard Accounts

        Initialize();
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        GLAccount.DeleteAll();
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        LibraryVariableStorage.Enqueue(CreateChartOfAccountsQst);
        LibraryVariableStorage.Enqueue(StrSubstNo(StandardAccountsMatchedMsg, SAFTMapping.Count(), SAFTMapping.Count()));
        SAFTMappingHelper.CreateChartOfAccounts(SAFTMappingRange);
        SAFTMappingHelper.Run(SAFTMappingRange);
        Assert.AreEqual(SAFTMapping.Count(), GLAccount.Count(), 'Accounts are not matched');
        SAFTGLAccountMapping.SetRange("Mapping Range Code", SAFTMappingRange.Code);
        Assert.AreEqual(SAFTMapping.Count(), SAFTGLAccountMapping.Count(), 'Accounts are not matched');
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CopyMappingNoReplace()
    var
        GLAccount: Record "G/L Account";
        FromSAFTMappingRange: Record "SAF-T Mapping Range";
        ToSAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 309923] Copy SAF-T Mapping from one range to another without replace

        Initialize();
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            FromSAFTMappingRange, FromSAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        LibraryERM.CreateGLAccountNo();
        SAFTMappingHelper.Run(FromSAFTMappingRange);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            ToSAFTMappingRange, ToSAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));

        SAFTMappingHelper.CopyMapping(FromSAFTMappingRange.Code, ToSAFTMappingRange.Code, false);

        SAFTGLAccountMapping.SetRange("Mapping Range Code", ToSAFTMappingRange.Code);
        GLAccount.SetRange("Account Type", GLAccount."Account Type"::Posting);
        Assert.RecordCount(SAFTGLAccountMapping, GLAccount.Count());
    end;

    [Test]
    procedure CopyMappingReplace()
    var
        FromSAFTMappingRange: Record "SAF-T Mapping Range";
        ToSAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
        GLAccNo: Code[20];
    begin
        // [SCENARIO 309923] Copy SAF-T Mapping from one range to another with replace

        Initialize();
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            FromSAFTMappingRange, FromSAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        GLAccNo := LibraryERM.CreateGLAccountNo();
        SAFTMappingHelper.Run(FromSAFTMappingRange);
        SAFTMapping.SetRange("Mapping Type", FromSAFTMappingRange."Mapping Type");
        SAFTMapping.FindFirst();
        SAFTGLAccountMapping.Get(FromSAFTMappingRange.Code, GLAccNo);
        SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
        SAFTGLAccountMapping.Validate("No.", SAFTMapping."No.");
        SAFTGLAccountMapping.Modify();

        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            ToSAFTMappingRange, ToSAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(ToSAFTMappingRange);

        SAFTMappingHelper.CopyMapping(FromSAFTMappingRange.Code, ToSAFTMappingRange.Code, true);

        SAFTGLAccountMapping.Get(ToSAFTMappingRange.Code, GLAccNo);
        SAFTGLAccountMapping.TestField("No.", SAFTMapping."No.");
    end;

    [Test]
    procedure ExportLinesWithActivityLogDeletsOnExportHeaderDeletion()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        ActivityLog: Record "Activity Log";
    begin
        // [SCENARIO 309923] SAF-T Export Lines and activity log related to SAF-T Export Header are remove on Header's deletion

        Initialize();
        SAFTExportHeader.Init();
        SAFTExportHeader.Insert();
        SAFTExportLine.Init();
        SAFTExportLine.ID := SAFTExportHeader.ID;
        SAFTExportLine.Insert();
        ActivityLog.Init();
        ActivityLog."Record ID" := SAFTExportLine.RecordId();
        ActivityLog.Insert();

        SAFTExportHeader.Delete(true);

        Assert.IsTrue(SAFTExportLine.IsEmpty(), 'SAF-T Export Line stil exist');
        Assert.IsTrue(ActivityLog.IsEmpty(), 'Activity log stil exist');
    end;

    [Test]
    procedure GLEntriesExistsIncomeStatementAccount()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 326720] A function UpdateGLEntriesExistStateForGLAccMapping correctly enables field "G/L Entries Exists" for G/L Account with type "Income Statement"
        // if there are G/L Entries posted withing reported period

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date", GLAccount."No.", 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists");
    end;

    [Test]
    procedure GLEntriesDoesNotExistIncomeStatementAccount()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 326720] A function UpdateGLEntriesExistStateForGLAccMapping correctly disables field "G/L Entries Exists" for G/L Account with type "Income Statement"
        // if there are no G/L Entries posted withing reported period

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Income Statement");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date" - 1, GLAccount."No.", 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists", false);
    end;

    [Test]
    procedure GLEntriesExistsBalanceSheetAccount()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 326720] A function UpdateGLEntriesExistStateForGLAccMapping correctly enables field "G/L Entries Exists" for G/L Account with type "Balance Sheet"
        // if there are G/L Entries posted withing reported period

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date", GLAccount."No.", 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists");
    end;

    [Test]
    procedure GLEntriesDoesNotExistBalanceSheetAccount()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 326720] A function UpdateGLEntriesExistStateForGLAccMapping correctly disables field "G/L Entries Exists" for G/L Account with type "Balance Sheet"
        // if there are not G/L Entries posted withing reported period

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date" - 1, GLAccount."No.", 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists", false);
    end;

    [Test]
    procedure GLEntriesExistsBalanceSheetAccountIncludeIncomingBalance()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 326720] A function UpdateGLEntriesExistStateForGLAccMapping correctly enables field "G/L Entries Exists" for G/L Account with type "Balance Sheet"
        // if there are not G/L Entries posted withing reported period but there are G/L entries posted before the reporting period

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingRange.Validate("Include Incoming Balance", true);
        SAFTMappingRange.Modify(true);
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date" - 1, GLAccount."No.", 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists");
    end;

    [Test]
    procedure MappingNoClearsOnCategoryNoValidateInSAFTGLAccountMappingTable()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMapping: Record "SAF-T Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 352458] Stan gets the blank "No." after validation of "Category No." in the "SAF-T G/L Account Mapping" table

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindSet();
        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
        SAFTGLAccountMapping.Validate("No.", SAFTMapping."No.");
        SAFTMapping.SetFilter("Category No.", '<>%1', SAFTMapping."Category No.");
        SAFTMapping.Next();
        SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
        SAFTGLAccountMapping.TestField("No.", '');
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure MappingNosInSAFTMappingRangeTable()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        SAFTMapping: Record "SAF-T Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 352458] Stan can specify the mapping nos. in the "SAF-T Mapping Range" table and it reflects on the "SAF-T G/L Account Mapping" table

        Initialize();
        LibraryERM.CreateGLAccount(GLAccount);
        GLAccount.Validate("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.Modify(true);
        SAFTTestHelper.InsertSAFTMappingRangeWithSource(
            SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account",
            CalcDate('<-CY>', WorkDate()), CalcDate('<-CY>', WorkDate()));
        SAFTMappingHelper.Run(SAFTMappingRange);
        SAFTMapping.SetRange("Mapping Type", SAFTMappingRange."Mapping Type");
        SAFTMapping.FindSet();

        LibraryVariableStorage.Enqueue(OverwriteMappingQst);
        SAFTMappingRange.Validate("Mapping Category No.", SAFTGLAccountMapping."Category No.");
        LibraryVariableStorage.Enqueue(OverwriteMappingQst);
        SAFTMappingRange.Validate("Mapping No.", SAFTGLAccountMapping."No.");

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("Category No.", SAFTMappingRange."Mapping Category No.");
        SAFTGLAccountMapping.TestField("No.", SAFTMappingRange."Mapping No.");

        LibraryVariableStorage.Enqueue(OverwriteMappingQst);
        SAFTMappingRange.Validate("Mapping Category No.", '');
        SAFTGLAccountMapping.Find();
        SAFTGLAccountMapping.TestField("Category No.", '');
        SAFTGLAccountMapping.TestField("No.", '');

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure SAFTExportLineCountWhenSplitByDate()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
    begin
        // [SCENARIO 361285] Multiple SAF-T Export Line creates for each date when "Split By Date" option is enabled

        Initialize();

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingRange."Mapping Type"::"Four Digit Standard Account", 1);
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        // [GIVEN] Two G/L entries posted on January 1 and January 2        
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date", LibraryERM.CreateGLAccountNo(), 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);
        SAFTTestHelper.MockGLEntryNoVAT(
            SAFTMappingRange."Starting Date" + 1, LibraryERM.CreateGLAccountNo(), 0, 0, 0, '', '', LibraryRandom.RandDec(100, 2), 0);

        // [GIVEN] SAF-T Export with "Split By Date" option enabled
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        SAFTExportHeader.Validate("Split By Date", true);
        SAFTExportHeader.Modify(true);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Two SAF-T Export lines created for each G/L Entry
        SAFTExportLine.SetRange("Master Data", false);
        SAFTExportLine.SetRange(Status, SAFTExportLine.Status::Completed);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportLine, 2);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Unit Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Unit Tests");
        IsInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Unit Tests");
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;

    [MessageHandler]
    procedure MessageHandler(Message: Text)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Message);
    end;

}
