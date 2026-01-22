codeunit 148102 "SAF-T Unit Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;
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

    [Test]
    procedure GLEntriesExistanceForAccountThatDoesNotExist()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
        GLAccount: Record "G/L Account";
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        // [SCENARIO 422814] A function UpdateGLEntriesExistStateForGLAccMapping correctly works even when G/L account does not exist

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
        GLAccount.Delete();
        SAFTMappingHelper.UpdateGLEntriesExistStateForGLAccMapping(SAFTMappingRange.Code);

        SAFTGLAccountMapping.Get(SAFTMappingRange.Code, GLAccount."No.");
        SAFTGLAccountMapping.TestField("G/L Entries Exists", false);
    end;

    [Test]
    procedure ImportGroupingCodeWithShortCategory()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Import single grouping code with category code <= 20 characters via ImportFromMappingSource

        // [GIVEN] SAF-T Mapping Source "S" with Source Type = "Income Statement" and tenant media containing XML with one Account: CategoryCode = "REV01", Description = "Revenue", GroupingCode = "3000", GroupingDescription = "Sales Revenue"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('REV01', 'Revenue', '3000', 'Sales Revenue', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" is created with Mapping Type = "Income Statement", No. = "REV01", Description = "Revenue", Extended No. = ''
        VerifySAFTMappingCategory('REV01', 'Revenue', '');
        // [THEN] SAF-T Mapping "M1" is created with Category No. = "REV01", No. = "3000", Description = "Sales Revenue"
        VerifySAFTMapping('REV01', '3000', 'Sales Revenue');
        // [THEN] SAF-T Mapping "NA" is created with Description = "Not applicable"
        VerifySAFTMapping('NA', 'NA', 'Not applicable');
    end;

    [Test]
    procedure ImportGroupingCodeWithExtendedCategory()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Import grouping code with category code > 20 characters triggers auto-increment via ImportFromMappingSource

        // [GIVEN] SAF-T Mapping Source "S" with tenant media containing XML with one Account: CategoryCode = "VERY_LONG_CATEGORY_CODE_EXCEEDS_20" (35 chars), Description = "Extended Cat", GroupingCode = "4001", GroupingDescription = "Extended Item"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('VERY_LONG_CATEGORY_CODE_EXCEEDS_20', 'Extended Cat', '4001', 'Extended Item', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" is created with No. = "CAT000001", Extended No. = "VERY_LONG_CATEGORY_CODE_EXCEEDS_20", Description = "Extended Cat"
        VerifySAFTMappingCategory('CAT000001', 'Extended Cat', 'VERY_LONG_CATEGORY_CODE_EXCEEDS_20');
        // [THEN] SAF-T Mapping "M1" is created with Category No. = "CAT000001", No. = "4001"
        VerifySAFTMapping('CAT000001', '4001', 'Extended Item');
    end;

    [Test]
    procedure ImportMultipleAccountsSameCategory()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Multiple accounts with same category code creates category once

        // [GIVEN] SAF-T Mapping Source "S" with XML containing two Accounts with same CategoryCode = "ASSET": first with GroupingCode = "1000", second with GroupingCode = "1001"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(
                BuildGroupingCodeAccountXML('ASSET', 'Assets', '1000', 'Asset One', false) +
                BuildGroupingCodeAccountXML('ASSET', 'Assets', '1001', 'Asset Two', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category count for "Income Statement" = 2 (ASSET + NA)
        SAFTMappingCategory.SetRange("Mapping Type", SAFTMappingCategory."Mapping Type"::"Income Statement");
        Assert.RecordCount(SAFTMappingCategory, 2);
        // [THEN] SAF-T Mapping count for "Income Statement" = 3 (1000, 1001, NA)
        SAFTMapping.SetRange("Mapping Type", SAFTMapping."Mapping Type"::"Income Statement");
        Assert.RecordCount(SAFTMapping, 3);
    end;

    [Test]
    procedure ImportMultipleAccountsDifferentCategories()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Multiple accounts with different category codes creates multiple categories

        // [GIVEN] SAF-T Mapping Source "S" with XML containing two Accounts: first with CategoryCode = "ASSET", GroupingCode = "1000"; second with CategoryCode = "LIAB", GroupingCode = "2000"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(
                BuildGroupingCodeAccountXML('ASSET', 'Assets', '1000', 'Asset Account', false) +
                BuildGroupingCodeAccountXML('LIAB', 'Liabilities', '2000', 'Liability Account', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" with No. = "ASSET" exists
        VerifySAFTMappingCategory('ASSET', 'Assets', '');
        // [THEN] SAF-T Mapping Category "C2" with No. = "LIAB" exists
        VerifySAFTMappingCategory('LIAB', 'Liabilities', '');
        // [THEN] SAF-T Mapping Category "C3" with No. = "NA" exists
        VerifySAFTMappingCategory('NA', 'Not applicable', '');
        // [THEN] SAF-T Mapping "M1" with No. = "1000" under "ASSET", "M2" with No. = "2000" under "LIAB", "M3" = "NA"
        VerifySAFTMapping('ASSET', '1000', 'Asset Account');
        VerifySAFTMapping('LIAB', '2000', 'Liability Account');
        VerifySAFTMapping('NA', 'NA', 'Not applicable');
    end;

    [Test]
    procedure ImportMultipleExtendedCategoriesAutoIncrement()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Multiple extended category codes (>20 chars) get sequential CAT numbers

        // [GIVEN] SAF-T Mapping Source "S" with XML containing two Accounts: first with CategoryCode = "EXTENDED_CATEGORY_ONE_VERY_LONG", GroupingCode = "5001"; second with CategoryCode = "EXTENDED_CATEGORY_TWO_VERY_LONG", GroupingCode = "5002"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(
                BuildGroupingCodeAccountXML('EXTENDED_CATEGORY_ONE_VERY_LONG', 'Extended One', '5001', 'Item One', false) +
                BuildGroupingCodeAccountXML('EXTENDED_CATEGORY_TWO_VERY_LONG', 'Extended Two', '5002', 'Item Two', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" = "CAT000001" with Extended No. = "EXTENDED_CATEGORY_ONE_VERY_LONG"
        VerifySAFTMappingCategory('CAT000001', 'Extended One', 'EXTENDED_CATEGORY_ONE_VERY_LONG');
        // [THEN] SAF-T Mapping Category "C2" = "CAT000002" with Extended No. = "EXTENDED_CATEGORY_TWO_VERY_LONG"
        VerifySAFTMappingCategory('CAT000002', 'Extended Two', 'EXTENDED_CATEGORY_TWO_VERY_LONG');
        // [THEN] SAF-T Mapping "M1" with Category No. = "CAT000001", "M2" with Category No. = "CAT000002"
        VerifySAFTMapping('CAT000001', '5001', 'Item One');
        VerifySAFTMapping('CAT000002', '5002', 'Item Two');
    end;

    [Test]
    procedure ImportGroupingCodeWithCategoryDescElement()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Optional CategoryDescription element is properly skipped

        // [GIVEN] SAF-T Mapping Source "S" with XML containing Account with CategoryDescription element between Description and GroupingCode
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('REV', 'Revenue', '3000', 'Sales', true)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping "M1" is created with No. = "3000", Description = "Sales"
        VerifySAFTMapping('REV', '3000', 'Sales');
        // [THEN] CategoryDescription element is skipped without error
    end;

    [Test]
    procedure ImportGroupingCodeUpdatesExistingCategory()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Existing category is modified when import attempts to insert duplicate

        // [GIVEN] SAF-T Mapping Category "C1" exists with Mapping Type = "Income Statement", No. = "ASSET", Description = "Old Description"
        Initialize();
        CleanupIncomeStatementMappingData();
        SAFTMappingCategory.Init();
        SAFTMappingCategory."Mapping Type" := SAFTMappingCategory."Mapping Type"::"Income Statement";
        SAFTMappingCategory."No." := 'ASSET';
        SAFTMappingCategory.Description := 'Old Description';
        SAFTMappingCategory.Insert();
        // [GIVEN] SAF-T Mapping Source "S" with XML containing Account: CategoryCode = "ASSET", Description = "New Description", GroupingCode = "1000"
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('ASSET', 'New Description', '1000', 'Account', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" with No. = "ASSET" has Description = "New Description" (modified)
        VerifySAFTMappingCategory('ASSET', 'New Description', '');
    end;

    [Test]
    procedure ImportGroupingCodeUpdatesExistingMapping()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Existing mapping is modified when import attempts to insert duplicate

        // [GIVEN] SAF-T Mapping Category "C1" with No. = "ASSET" exists
        Initialize();
        CleanupIncomeStatementMappingData();
        SAFTMappingCategory.Init();
        SAFTMappingCategory."Mapping Type" := SAFTMappingCategory."Mapping Type"::"Income Statement";
        SAFTMappingCategory."No." := 'ASSET';
        SAFTMappingCategory.Description := 'Assets';
        SAFTMappingCategory.Insert();
        // [GIVEN] SAF-T Mapping "M1" exists with Mapping Type = "Income Statement", Category No. = "ASSET", No. = "1000", Description = "Old Desc"
        SAFTMapping.Init();
        SAFTMapping."Mapping Type" := SAFTMapping."Mapping Type"::"Income Statement";
        SAFTMapping."Category No." := 'ASSET';
        SAFTMapping."No." := '1000';
        SAFTMapping.Description := 'Old Desc';
        SAFTMapping.Insert();
        // [GIVEN] SAF-T Mapping Source "S" with XML containing Account: CategoryCode = "ASSET", GroupingCode = "1000", GroupingDescription = "New Desc"
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('ASSET', 'Assets', '1000', 'New Desc', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping "M1" with No. = "1000" has Description = "New Desc" (modified)
        VerifySAFTMapping('ASSET', '1000', 'New Desc');
    end;

    [Test]
    procedure ImportGroupingCodeAddsNotApplicableMapping()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] "NA" Not Applicable mapping is always added at end of import

        // [GIVEN] SAF-T Mapping Source "S" with XML containing one Account: CategoryCode = "REV", GroupingCode = "3000"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('REV', 'Revenue', '3000', 'Sales', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category with No. = "NA", Description = "Not applicable" exists
        SAFTMappingCategory.Get(SAFTMappingCategory."Mapping Type"::"Income Statement", 'NA');
        Assert.AreEqual('Not applicable', SAFTMappingCategory.Description, 'Wrong NA category description');
        // [THEN] SAF-T Mapping with Category No. = "NA", No. = "NA", Description = "Not applicable" exists
        SAFTMapping.Get(SAFTMapping."Mapping Type"::"Income Statement", 'NA', 'NA');
        Assert.AreEqual('Not applicable', SAFTMapping.Description, 'Wrong NA mapping description');
    end;

    [Test]
    procedure ImportGroupingCodeFailsWhenXPathNotFound()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Error when XML does not contain expected XPath /GroupingCategoryCode/Account

        // [GIVEN] SAF-T Mapping Source "S" with XML containing wrong root element: "<WrongRoot><Account><Code>1</Code></Account></WrongRoot>"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(SAFTMappingSource, '<WrongRoot><Account><Code>1</Code></Account></WrongRoot>');

        // [WHEN] ImportFromMappingSource is called with "S"
        asserterror SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] Error "Not possible to parse XML file with SAF-T Grouping Codes for mapping" is thrown
        Assert.ExpectedError('Not possible to parse XML file with SAF-T Grouping Codes for mapping');
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure ImportGroupingCodeFailsWhenNoChildElements()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Error when Account element has no child elements

        // [GIVEN] SAF-T Mapping Source "S" with XML containing empty Account: "<GroupingCategoryCode><Account/></GroupingCategoryCode>"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(SAFTMappingSource, '<GroupingCategoryCode><Account/></GroupingCategoryCode>');

        // [WHEN] ImportFromMappingSource is called with "S"
        asserterror SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] Error "Not possible to parse XML file with SAF-T Grouping Codes for mapping" is thrown
        Assert.ExpectedError('Not possible to parse XML file with SAF-T Grouping Codes for mapping');
        Assert.ExpectedErrorCode('Dialog');
    end;

    [Test]
    procedure ImportGroupingCodeCategoryCodeExactly20Chars()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [SCENARIO] Category code exactly 20 characters uses value directly without auto-increment

        // [GIVEN] SAF-T Mapping Source "S" with XML containing Account with CategoryCode of exactly 20 characters: "12345678901234567890"
        Initialize();
        CleanupIncomeStatementMappingData();
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('12345678901234567890', 'Twenty Char Category', '7000', 'Account', false)));

        // [WHEN] ImportFromMappingSource is called with "S"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "C1" is created with No. = "12345678901234567890", Extended No. = ''
        VerifySAFTMappingCategory('12345678901234567890', 'Twenty Char Category', '');
        // [THEN] No auto-increment CAT number is generated
    end;

    [Test]
    procedure ImportExtendedCategoriesSecondImportContinuesFromLastCATNumber()
    var
        SAFTMappingSource: Record "SAF-T Mapping Source";
        TenantMedia: Record "Tenant Media";
        SAFTXMLImport: Codeunit "SAF-T XML Import";
    begin
        // [FEATURE] [AI test]
        // [SCENARIO] Second import with extended category codes continues auto-increment from last existing CAT number

        Initialize();
        CleanupIncomeStatementMappingData();

        // [GIVEN] SAF-T Mapping Source "S1" with XML containing Account: CategoryCode = "EXTENDED_CATEGORY_ONE_VERY_LONG", GroupingCode = "5001"
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('EXTENDED_CATEGORY_ONE_VERY_LONG', 'Extended One', '5001', 'Item One', false)));

        // [GIVEN] First import is run, creating category "CAT000001"
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);
        VerifySAFTMappingCategory('CAT000001', 'Extended One', 'EXTENDED_CATEGORY_ONE_VERY_LONG');

        // [GIVEN] Cleanup mapping source and tenant media to simulate separate import
        SAFTMappingSource.Delete();
        TenantMedia.SetRange("Company Name", CompanyName());
        TenantMedia.SetRange("File Name", 'TESTGROUPINGCODES.XML');
        TenantMedia.DeleteAll();

        // [GIVEN] SAF-T Mapping Source "S2" with XML containing Account: CategoryCode = "EXTENDED_CATEGORY_TWO_VERY_LONG", GroupingCode = "5002"
        CreateMappingSourceWithXML(
            SAFTMappingSource,
            BuildGroupingCodeXML(BuildGroupingCodeAccountXML('EXTENDED_CATEGORY_TWO_VERY_LONG', 'Extended Two', '5002', 'Item Two', false)));

        // [WHEN] Second import is run
        SAFTXMLImport.ImportFromMappingSource(SAFTMappingSource);

        // [THEN] SAF-T Mapping Category "CAT000002" is created (continues from last CAT number, not restarting at CAT000001)
        VerifySAFTMappingCategory('CAT000002', 'Extended Two', 'EXTENDED_CATEGORY_TWO_VERY_LONG');

        // [THEN] Original category "CAT000001" still exists with original data
        VerifySAFTMappingCategory('CAT000001', 'Extended One', 'EXTENDED_CATEGORY_ONE_VERY_LONG');
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

    local procedure CreateMappingSourceWithXML(var SAFTMappingSource: Record "SAF-T Mapping Source"; XMLText: Text)
    var
        TenantMedia: Record "Tenant Media";
        TempBlob: Codeunit "Temp Blob";
        RecRef: RecordRef;
        OutStream: OutStream;
        SourceFileName: Code[50];
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(XMLText);

        SourceFileName := 'TESTGROUPINGCODES.XML';
        TenantMedia.Init();
        TenantMedia.ID := CreateGuid();
        TenantMedia."Company Name" := CopyStr(CompanyName(), 1, MaxStrLen(TenantMedia."Company Name"));
        TenantMedia."File Name" := SourceFileName;
        RecRef.GetTable(TenantMedia);
        TempBlob.ToRecordRef(RecRef, TenantMedia.FieldNo(Content));
        RecRef.SetTable(TenantMedia);
        TenantMedia.Insert();

        SAFTMappingSource.Init();
        SAFTMappingSource."Source Type" := SAFTMappingSource."Source Type"::"Income Statement";
        SAFTMappingSource."Source No." := SourceFileName;
        SAFTMappingSource.Insert();
    end;

    local procedure BuildGroupingCodeAccountXML(CategoryCode: Text; CategoryDesc: Text; GroupingCode: Code[20]; GroupingDesc: Text; IncludeCategoryDescription: Boolean): Text
    var
        Result: Text;
    begin
        Result := '<Account>';
        Result += '<CategoryCode>' + CategoryCode + '</CategoryCode>';
        Result += '<Description>' + CategoryDesc + '</Description>';
        if IncludeCategoryDescription then
            Result += '<CategoryDescription>Extra</CategoryDescription>';
        Result += '<GroupingCode>' + GroupingCode + '</GroupingCode>';
        Result += '<GroupingDescription>' + GroupingDesc + '</GroupingDescription>';
        Result += '</Account>';
        exit(Result);
    end;

    local procedure BuildGroupingCodeXML(AccountsXML: Text): Text
    begin
        exit('<GroupingCategoryCode>' + AccountsXML + '</GroupingCategoryCode>');
    end;

    local procedure VerifySAFTMappingCategory(ExpectedNo: Code[20]; ExpectedDesc: Text[250]; ExpectedExtendedNo: Text[500])
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
    begin
        SAFTMappingCategory.Get(SAFTMappingCategory."Mapping Type"::"Income Statement", ExpectedNo);
        Assert.AreEqual(ExpectedDesc, SAFTMappingCategory.Description, 'Wrong category description for ' + ExpectedNo);
        Assert.AreEqual(ExpectedExtendedNo, SAFTMappingCategory."Extended No.", 'Wrong extended no. for ' + ExpectedNo);
    end;

    local procedure VerifySAFTMapping(ExpectedCategoryNo: Code[20]; ExpectedNo: Code[20]; ExpectedDesc: Text[250])
    var
        SAFTMapping: Record "SAF-T Mapping";
    begin
        SAFTMapping.Get(SAFTMapping."Mapping Type"::"Income Statement", ExpectedCategoryNo, ExpectedNo);
        Assert.AreEqual(ExpectedDesc, SAFTMapping.Description, 'Wrong mapping description for ' + ExpectedNo);
    end;

    local procedure CleanupIncomeStatementMappingData()
    var
        SAFTMappingCategory: Record "SAF-T Mapping Category";
        SAFTMapping: Record "SAF-T Mapping";
        SAFTMappingSource: Record "SAF-T Mapping Source";
        TenantMedia: Record "Tenant Media";
    begin
        SAFTMapping.SetRange("Mapping Type", SAFTMapping."Mapping Type"::"Income Statement");
        SAFTMapping.DeleteAll();

        SAFTMappingCategory.SetRange("Mapping Type", SAFTMappingCategory."Mapping Type"::"Income Statement");
        SAFTMappingCategory.DeleteAll();

        SAFTMappingSource.SetRange("Source Type", SAFTMappingSource."Source Type"::"Income Statement");
        if SAFTMappingSource.FindSet() then
            repeat
                TenantMedia.SetRange("Company Name", CompanyName());
                TenantMedia.SetRange("File Name", SAFTMappingSource."Source No.");
                TenantMedia.DeleteAll();
            until SAFTMappingSource.Next() = 0;
        SAFTMappingSource.DeleteAll();
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
