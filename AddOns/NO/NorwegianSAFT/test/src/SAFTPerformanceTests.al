codeunit 148106 "SAF-T Performance Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [Performance Profiler]
        TestsBuffer := 5;
        // LibraryPerformanceProfiler.SetProfilerIdentification('299785 - SAF-T Financial');
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        Assert: Codeunit Assert;
        // LibraryPerformanceProfiler: Codeunit "Library - Performance Profiler";
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        // TraceDumpFilePath: Text;
        TestsBuffer: Integer;
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure PerformanceOfSAFTExportRunOf12SeparateFilesPerEachMonth()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        // PerfProfilerEventsTest: Record "Perf Profiler Events Test";
        CurrDate: Date;
    begin
        // [SCENARIO 299785] Estimate performance of SAF-T Export execution which contains of 12 individual files, each per month

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account");
        MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        CurrDate := SAFTExportHeader."Starting Date";
        while CurrDate <= SAFTExportHeader."Ending Date" do begin
            SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(CurrDate, 1);
            CurrDate := CalcDate('<1M>', CurrDate);
        end;

        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        // LibraryPerformanceProfiler.StartProfiler(TRUE);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        // TraceDumpFilePath := LibraryPerformanceProfiler.StopProfiler(
        //     PerfProfilerEventsTest, 'PerformanceOfSAFTExportRunOf12SeparateFilesPerEachMonth',
        //     PerfProfilerEventsTest."Object Type"::Codeunit, CODEUNIT::"Generate SAF-T File", true);
        // No verification yet. The goal is to analyze report and figure out the threshold.
        // TODO: enable performance profiler for Internal testing

        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Performance Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Performance Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Performance Tests");
    end;

    local procedure SetupSAFT(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"): Code[20]
    var
        SAFTMappingHelper: Codeunit "SAF-T Mapping Helper";
    begin
        SAFTTestHelper.SetupMasterData(LibraryRandom.RandInt(5));
        SAFTMappingHelper.MapRestSourceCodesToAssortedJournals();
        SAFTTestHelper.InsertSAFTMappingRangeFullySetup(
            SAFTMappingRange, MappingType,
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()));
        exit(SAFTMappingRange.Code);
    end;

    local procedure MatchGLAccountsFourDigit(MappingRangeCode: Code[20])
    var
        SAFTMapping: Record "SAF-T Mapping";
        SAFTGLAccountMapping: Record "SAF-T G/L Account Mapping";
    begin
        SAFTGLAccountMapping.SetRange("Mapping Range Code", MappingRangeCode);
        SAFTGLAccountMapping.FindSet();
        SAFTMapping.FindSet();
        repeat
            SAFTGLAccountMapping.Validate("Category No.", SAFTMapping."Category No.");
            SAFTGLAccountMapping.Validate("No.", SAFTMapping."No.");
            SAFTGLAccountMapping.Modify(true);
            SAFTMapping.Next();
        until SAFTGLAccountMapping.Next() = 0;
    end;

    local procedure CreateSAFTExportHeader(var SAFTExportHeader: Record "SAF-T Export Header"; MappingRangeCode: Code[20])
    begin
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, MappingRangeCode);
        SAFTExportHeader."Parallel Processing" := false;
        SAFTExportHeader.Modify();
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
