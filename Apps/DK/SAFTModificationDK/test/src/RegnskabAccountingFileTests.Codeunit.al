codeunit 148058 "Regnskab Accounting File Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [Export]
    end;

    var
        Assert: Codeunit Assert;
        LibraryRandom: Codeunit "Library - Random";
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryERM: Codeunit "Library - ERM";
        IsInitialized: Boolean;
        CalcMethod: Enum "Analysis Amount Type";
        SelectMappingErr: Label 'Please select an initialized mapping header with appropriate period first.';
        NoEntriesFoundTxt: Label 'No G/L balance changes were found for the selected date range and mapping.';

    [Test]
    procedure PageUT_NoHeaderSelectedMessage()
    var
        RegnskabBasisAccountingFile: Testpage "RB Accounting File";
    begin
        // [SCENARIO 471277] When no header is selected, "No header selected" error is shown when export is executed
        Initialize();

        // [GIVEN] "Regnskab Basis Accounting File" page is open, and no header is selected
        RegnskabBasisAccountingFile.OpenView();

        // [WHEN] "Generate File" action is executed
        AssertError RegnskabBasisAccountingFile.GenerateFile.Invoke();

        // [THEN] "No header selected" error is shown
        Assert.ExpectedError(SelectMappingErr);
    end;

    [Test]
    [HandlerFunctions('MessageHandler')]
    procedure PageUT_MessageWhenEmpty()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        RegnskabBasisAccountingFile: Testpage "RB Accounting File";
    begin
        // [SCENARIO 471277] When no entries are found, "No balance changes" Message is shown when generating Accounting File
        Initialize();

        // [GIVEN] "Regnskab Basis Accounting File" page is open, and no header is selected
        RegnskabBasisAccountingFile.OpenView();

        // [GIVEN] Mapping Header exists and is selected
        CreateGLAccountMappingHeader(GLAccountMappingHeader);
        RegnskabBasisAccountingFile.Code.SetValue(GLAccountMappingHeader.Code);

        // [WHEN] "Generate File" action is executed
        LibraryVariableStorage.Enqueue(NoEntriesFoundTxt);
        RegnskabBasisAccountingFile.GenerateFile.Invoke();

        // [THEN] "No balance changes" Message is shown
        // UI handled by MessageHandler
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure CodeunitUT_IncomeStatement_NetChange_default()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        TempBlob: Codeunit "Temp Blob";
        TotalAmount: Decimal;
        ExpectedLines: List of [Text];
    begin
        // [SCENARIO 471277] Generate CSV works, simple scenario with one line
        Initialize();

        // [GIVEN] Mapping Header exists and is selected
        CreateGLAccountMappingHeader(GLAccountMappingHeader);

        // [GIVEN] Standard Account with Account No = SSS and description DESC exists
        CreateStandardAccount(StandardAccount, GLAccountMappingHeader."Standard Account Type");

        // [GIVEN] Mapping Line for Account No = XXX (Income Statement) vs Standard Account No = SSS exists
        CreateGLAccountMappingLine(GLAccountMappingLine, GLAccountMappingHeader, StandardAccount."No.", false);

        // [GIVEN] Multiple G/L Entries exists for Account No = XXX with total amount YYY
        TotalAmount := CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate());
        ExpectedLines.Add(StandardAccount."No." + ';' + StandardAccount.Description + ';' + Format(Round(TotalAmount, 1), 0, 9));

        // [WHEN] Generate File is executed
        GenerateCSVTempBlobDefault(TempBlob, GLAccountMappingHeader);

        // [THEN] File contains one line with Standard Account No = SSS amount YYY
        VerifyBlobContent(TempBlob, ExpectedLines);
    end;

    [Test]
    procedure CodeunitUT_IncomeStatement_BalanceAtDate()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        TempBlob: Codeunit "Temp Blob";
        TotalAmount: Decimal;
        ExpectedLines: List of [Text];
    begin
        // [SCENARIO 471277] Generate CSV will use "Balance at Date" method to calculate amount for Income Statement account when "Balance" is selected
        Initialize();

        // [GIVEN] Mapping Header exists and is selected. Starting Date = 01.01.2019, Ending Date = 31.12.2019
        CreateGLAccountMappingHeader(GLAccountMappingHeader);

        // [GIVEN] Mapping Line for Account No = XXX (Income Statement) vs Standard Account No = SSS exists
        CreateStandardAccount(StandardAccount, GLAccountMappingHeader."Standard Account Type");
        CreateGLAccountMappingLine(GLAccountMappingLine, GLAccountMappingHeader, StandardAccount."No.", false);

        // [GIVEN] Multiple G/L Entries exists for Account No = XXX with total amount YYY, Posting Date = 01.05.2019
        TotalAmount := CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate());

        // [GIVEN] Also Multiple G/L Entries exists for Account No = XXX with total amount ZZZ, Posting Date = 01.05.2018, so before Starting Date
        TotalAmount += CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", CalcDate('<-1Y>', WorkDate()));

        // [WHEN] Generate File is executed for Starting Date = 01.01.2019, Ending Date = 31.12.2019
        GenerateCSVTempBlob(TempBlob, GLAccountMappingHeader, GLAccountMappingHeader."Starting Date", GLAccountMappingHeader."Ending Date", CalcMethod::"Balance at Date", CalcMethod::"Balance at Date");

        // [THEN] File contains one line with Standard Account No = SSS amount YYY + ZZZ, because it's calculated as Balance at Date
        ExpectedLines.Add(StandardAccount."No." + ';' + StandardAccount.Description + ';' + Format(Round(TotalAmount, 1), 0, 9));
        VerifyBlobContent(TempBlob, ExpectedLines);
    end;

    [Test]
    procedure CodeunitUT_BalanceSheet_BalanceAtDate_default()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        TempBlob: Codeunit "Temp Blob";
        TotalAmount: Decimal;
        ExpectedLines: List of [Text];
    begin
        // [SCENARIO 471277] Generate CSV will use "Balance at Date" method to calculate amount for Balance sheet account by default
        Initialize();

        // [GIVEN] Mapping Header exists and is selected. Starting Date = 01.01.2019, Ending Date = 31.12.2019
        CreateGLAccountMappingHeader(GLAccountMappingHeader);

        // [GIVEN] Mapping Line for Account No = XXX (Balance Sheet) vs Standard Account No = SSS exists
        CreateStandardAccount(StandardAccount, GLAccountMappingHeader."Standard Account Type");
        CreateGLAccountMappingLine(GLAccountMappingLine, GLAccountMappingHeader, StandardAccount."No.", true);

        // [GIVEN] Multiple G/L Entries exists for Account No = XXX with total amount YYY, Posting Date = 01.05.2019
        TotalAmount := CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate());

        // [GIVEN] Also Multiple G/L Entries exists for Account No = XXX with total amount ZZZ, Posting Date = 01.05.2018, so before Starting Date
        TotalAmount += CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", CalcDate('<-1Y>', WorkDate()));

        // [WHEN] Generate File is executed for Starting Date = 01.01.2019, Ending Date = 31.12.2019
        GenerateCSVTempBlobDefault(TempBlob, GLAccountMappingHeader);

        // [THEN] File contains one line with Standard Account No = SSS amount YYY + ZZZ, because it's calculated as Balance at Date
        ExpectedLines.Add(StandardAccount."No." + ';' + StandardAccount.Description + ';' + Format(Round(TotalAmount, 1), 0, 9));
        VerifyBlobContent(TempBlob, ExpectedLines);
    end;

    [Test]
    procedure CodeunitUT_ChangedDates()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        TempBlob: Codeunit "Temp Blob";
        TotalAmount: Decimal;
        ExpectedLines: List of [Text];
    begin
        // [SCENARIO 471277] Generate CSV respects Starting and Ending date and only includes entries in that period
        Initialize();

        // [GIVEN] Mapping Header exists and is selected. Starting Date = 01.01.2019, Ending Date = 31.12.2019
        CreateGLAccountMappingHeader(GLAccountMappingHeader);

        // [GIVEN] Mapping Line for Account No = XXX (Income Statement) vs Standard Account No = SSS exists
        CreateStandardAccount(StandardAccount, GLAccountMappingHeader."Standard Account Type");
        CreateGLAccountMappingLine(GLAccountMappingLine, GLAccountMappingHeader, StandardAccount."No.", false);

        // [GIVEN] Multiple G/L Entries exists for Account No = XXX with total amount YYY, Posting Date = 01.05.2019
        TotalAmount := CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate());

        // [GIVEN] Also Multiple G/L Entries exists for Account No = XXX with total amount ZZZ, Posting Date = 01.07.2019
        CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate() + 60);

        // [WHEN] Generate File is executed for Starting Date = 01.01.2019, Ending Date = 01.06.2019
        GenerateCSVTempBlob(TempBlob, GLAccountMappingHeader, GLAccountMappingHeader."Starting Date", WorkDate() + 30, CalcMethod::"Net Change", CalcMethod::"Balance at Date");

        // [THEN] File contains one line with Standard Account No = SSS amount YYY, but amount ZZZ is ignored
        ExpectedLines.Add(StandardAccount."No." + ';' + StandardAccount.Description + ';' + Format(Round(TotalAmount, 1), 0, 9));
        VerifyBlobContent(TempBlob, ExpectedLines);
    end;

    [Test]
    procedure CodeunitUT_Multiple_lines()
    var
        GLAccountMappingHeader: Record "G/L Account Mapping Header";
        GLAccountMappingLine: Record "G/L Account Mapping Line";
        StandardAccount: Record "Standard Account";
        TempBlob: Codeunit "Temp Blob";
        TotalAmount: Decimal;
        ExpectedLines: List of [Text];
        i: Integer;
    begin
        // [SCENARIO 471277] Generate CSV works, more complex scenario with several lines
        Initialize();

        // [GIVEN] Mapping Header exists and is selected
        CreateGLAccountMappingHeader(GLAccountMappingHeader);

        // [GIVEN] Create 10 Different Mapping Lines with different GL Entries posted for them
        for i := 1 to 10 do begin
            CreateStandardAccount(StandardAccount, GLAccountMappingHeader."Standard Account Type");
            CreateGLAccountMappingLine(GLAccountMappingLine, GLAccountMappingHeader, StandardAccount."No.", false);
            TotalAmount := CreateMultipleGLEntries(GLAccountMappingLine."G/L Account No.", WorkDate());
            ExpectedLines.Add(StandardAccount."No." + ';' + StandardAccount.Description + ';' + Format(Round(TotalAmount, 1), 0, 9));
        end;

        // [WHEN] Generate File is executed
        GenerateCSVTempBlobDefault(TempBlob, GLAccountMappingHeader);

        // [THEN] File contains all the lines with accounts and amounts from mapping lines and gl entries
        VerifyBlobContent(TempBlob, ExpectedLines);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"Regnskab Accounting File Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"Regnskab Accounting File Tests");
        Commit();

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"Regnskab Accounting File Tests");
    end;

    local procedure CreateGLAccountMappingHeader(var GLAccountMappingHeader: Record "G/L Account Mapping Header")
    begin
        GLAccountMappingHeader.Init();
        GLAccountMappingHeader.Code := LibraryUtility.GenerateGUID();
        GLAccountMappingHeader."Standard Account Type" := GLAccountMappingHeader."Standard Account Type"::"Four Digit Standard Account";
        GLACcountMappingHeader."Audit File Export Format" := GLAccountMappingHeader."Audit File Export Format"::SAFT;
        GLAccountMappingHeader."Period Type" := GLAccountMappingHeader."Period Type"::"Date Range";
        GLAccountMappingHeader."Starting Date" := CalcDate('<-CY>', WorkDate());
        GLAccountMappingHeader."Ending Date" := CalcDate('<CY>', WorkDate());
        GLAccountMappingHeader.Insert();
    end;

    local procedure CreateGLAccountMappingLine(var GLAccountMappingLine: Record "G/L Account Mapping Line"; GLAccountMappingHeader: Record "G/L Account Mapping Header"; StandardAccountNo: Code[20]; BalanceSheet: Boolean)
    begin
        GLAccountMappingLine.Init();
        GLAccountMappingLine."G/L Account Mapping Code" := GLAccountMappingHeader.Code;
        GLAccountMappingLine."Standard Account Type" := GLAccountMappingHeader."Standard Account Type";
        GLAccountMappingLine."G/L Account No." := CreateGLAccounNoWithIncBal(BalanceSheet);
        GLAccountMappingLine."Standard Account No." := StandardAccountNo;
        GLAccountMappingLine.Insert();
    end;

    local procedure CreateGLAccounNoWithIncBal(BalanceSheet: Boolean): Code[20]
    var
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        if BalanceSheet then
            GLAccount."Income/Balance" := GLAccount."Income/Balance"::"Balance Sheet";
        GLAccount.Modify();
        exit(GLAccount."No.");
    end;

    local procedure CreateStandardAccount(var StandardAccount: Record "Standard Account"; AccountType: Enum "Standard Account Type")
    begin
        StandardAccount.Init();
        StandardAccount.Type := AccountType;
        StandardAccount."No." := LibraryUtility.GenerateGUID();
        StandardAccount.Description := LibraryUtility.GenerateGUID();
        StandardAccount.Insert();
    end;

    local procedure CreateMultipleGLEntries(GLAccountNo: Code[20]; PostingDate: Date) TotalAmount: Decimal
    var
        i: Integer;
    begin
        for i := 1 to LibraryRandom.RandIntInRange(3, 20) do
            TotalAmount := TotalAmount + CreateGLEntry(GLAccountNo, PostingDate);
    end;

    local procedure CreateGLEntry(GLAccountNo: Code[20]; PostingDate: Date): Decimal
    var
        GLEntry: Record "G/L Entry";
    begin
        GLEntry.Init();
        GLEntry."Entry No." := GLEntry.GetLastEntryNo() + 1;
        GLEntry.Validate("G/L Account No.", GLAccountNo);
        GLEntry.Validate("Posting Date", PostingDate);
        GLEntry.Amount := LibraryRandom.RandDec(1000, 2);
        GLEntry.Insert();
        exit(GLEntry.Amount);
    end;

    local procedure GenerateCSVTempBlob(var TempBlob: Codeunit "Temp Blob"; GLAccountMappingHeader: Record "G/L Account Mapping Header"; StartingDate: Date; EndingDate: Date; AmountCalcMethod1: Enum "Analysis Amount Type"; AmountCalcMethod2: Enum "Analysis Amount Type")
    var
        RegnskabBasisExport: Codeunit "Regnskab Basis Export";
    begin
        RegnskabBasisExport.Initialize(StartingDate, EndingDate, GLAccountMappingHeader, ';', AmountCalcMethod1, AmountCalcMethod2);
        RegnskabBasisExport.GenerateFileToBlob(TempBlob);
    end;

    local procedure GenerateCSVTempBlobDefault(var TempBlob: Codeunit "Temp Blob"; GLAccountMappingHeader: Record "G/L Account Mapping Header")
    var
        RegnskabBasisExport: Codeunit "Regnskab Basis Export";
    begin
        RegnskabBasisExport.InitializeDefault(GLAccountMappingHeader);
        RegnskabBasisExport.GenerateFileToBlob(TempBlob);
    end;

    local procedure VerifyBlobContent(var TempBlob: Codeunit "Temp Blob"; ExpectedLines: List of [Text])
    var
        FileLines: List of [Text];
        Line: Text;
    begin
        BlobToLines(TempBlob, FileLines);
        foreach Line in ExpectedLines do
            Assert.IsTrue(FileLines.Contains(Line), 'Line not found in file');
    end;


    local procedure BlobToLines(TempBlob: Codeunit "Temp Blob"; var Lines: List of [Text])
    var
        InStr: InStream;
        Line: Text;
    begin
        TempBlob.CreateInStream(InStr);
        while not InStr.EOS() do begin
            InStr.ReadText(Line);
            Lines.Add(Line);
        end;
    end;

    [MessageHandler]
    procedure MessageHandler(Question: Text)
    var
        ExpectedMessage: Text;
    begin
        ExpectedMessage := LibraryVariableStorage.DequeueText();
        Assert.AreEqual(ExpectedMessage, Question, 'Unexpected message');
    end;
}