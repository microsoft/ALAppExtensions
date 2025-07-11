codeunit 148109 "SAF-T Export Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [XML]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryUtility: Codeunit "Library - Utility";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        Assert: Codeunit Assert;
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ExportToFolderWithNoZipEnabled()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
    begin
        // [SCENARIO 361285] No zip file generates in the exported folder when "Disable Zip File Generation" option enabled

        Initialize();

        // [GIVEN] SAF-T setup with "Folder Path" = "X" and "Disable Zip File Generation" option enabled
        // TFS ID 398455: Manage files with path's length more than 250 chars
        InitSAFTExportScenario(SAFTExportHeader, CreateLongServerDirectory(), true, false);

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] No file with the "zip" extension exists in the folder "X"
        FileMgt.GetServerDirectoryFilesListInclSubDirs(TempNameValueBuffer, SAFTExportHeader."Folder Path");
        TempNameValueBuffer.Setfilter(Name, '*zip*');
        Assert.RecordCount(TempNameValueBuffer, 0);
        LibraryVariableStorage.AssertEmpty();

        // Remove all files from server folder
        RemoveFilesInDirectory(TempNameValueBuffer);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ExportToFolderWithNoZipDisabled()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
    begin
        // [SCENARIO 361285] A zip file generates in the exported folder when "Disable Zip File Generation" option disabled

        Initialize();

        // [GIVEN] SAF-T setup with "Folder Path" = "X" and "Disable Zip File Generation" option disabled
        // TFS ID 398455: Manage files with path's length more than 250 chars
        InitSAFTExportScenario(SAFTExportHeader, CreateLongServerDirectory(), false, false);

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] One file with the "zip" extension exists in the folder "X"
        FileMgt.GetServerDirectoryFilesListInclSubDirs(TempNameValueBuffer, SAFTExportHeader."Folder Path");
        TempNameValueBuffer.Setfilter(Name, '*zip*');
        Assert.RecordCount(TempNameValueBuffer, 1);
        LibraryVariableStorage.AssertEmpty();

        // Remove all files from server folder
        RemoveFilesInDirectory(TempNameValueBuffer);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure ExportToFolderMultipleZipFiles()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        TempNameValueBuffer: Record "Name/Value Buffer" temporary;
        FileMgt: Codeunit "File Management";
        PostingDate: Date;
        i: integer;
    begin
        // [SCENARIO 361285] Multiple zip file generates in the exported folder when "Create Multiple Zip Files" option enabled

        Initialize();

        // [GIVEN] SAF-T setup with "Folder Path" = "X" and "Create Multiple Zip Files" option enabled
        // TFS ID 398455: Manage files with path's length more than 250 chars
        InitSAFTExportScenario(SAFTExportHeader, CreateLongServerDirectory(), false, true);
        // [GIVEN] Multiple G/L entries posted in each month
        PostingDate := SAFTExportHeader."Starting Date";
        for i := 1 to 12 do begin
            SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(PostingDate, 1);
            PostingDate := CalcDate('<1M>', PostingDate);
        end;

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] 7 files with the "zip" extension exists in the folder "X"
        FileMgt.GetServerDirectoryFilesListInclSubDirs(TempNameValueBuffer, SAFTExportHeader."Folder Path");
        TempNameValueBuffer.Setfilter(Name, '*zip*');
        Assert.RecordCount(TempNameValueBuffer, 7);
        LibraryVariableStorage.AssertEmpty();

        // Remove all files from server folder
        RemoveFilesInDirectory(TempNameValueBuffer);
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure SaveSingleZipFile()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportFile: Record "SAF-T Export File";
        PostingDate: Date;
        i: integer;
    begin
        // [SCENARIO 361285] Single zip file saves when "Create Multiple Zip Files" option disabled

        Initialize();

        // [GIVEN] SAF-T setup with "Folder Path" not specified and "Create Multiple Zip Files" option disabled
        InitSAFTExportScenario(SAFTExportHeader, '', false, false);
        // [GIVEN] Multiple G/L entries posted in each month
        PostingDate := SAFTExportHeader."Starting Date";
        for i := 1 to 12 do begin
            SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(PostingDate, 1);
            PostingDate := CalcDate('<1M>', PostingDate);
        end;

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] One SAF-T export file generated
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportFile, 1);
        SAFTExportFile.FindFirst();
        SAFTExportFile.CalcFields("SAF-T File");
        SAFTExportFile.TestField("SAF-T File");

        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure SaveMultipleZipFiles()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportFile: Record "SAF-T Export File";
        PostingDate: Date;
        i: integer;
    begin
        // [SCENARIO 361285] Multiple zip files saves when "Create Multiple Zip Files" option enabled

        Initialize();

        // [GIVEN] SAF-T setup with "Folder Path" not specified and "Create Multiple Zip Files" option enabled
        InitSAFTExportScenario(SAFTExportHeader, '', false, true);
        // [GIVEN] Multiple G/L entries posted in each month
        PostingDate := SAFTExportHeader."Starting Date";
        for i := 1 to 12 do begin
            SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(PostingDate, 1);
            PostingDate := CalcDate('<1M>', PostingDate);
        end;

        // [WHEN] Run SAF-T Export
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] 7 SAF-T export files generated
        SAFTExportFile.SetRange("Export ID", SAFTExportHeader.ID);
        Assert.RecordCount(SAFTExportFile, 7);
        SAFTExportFile.FindSet();
        repeat
            SAFTExportFile.CalcFields("SAF-T File");
            SAFTExportFile.TestField("SAF-T File");
        until SAFTExportFile.Next() = 0;
        LibraryVariableStorage.AssertEmpty();
    end;

    [Test]
    procedure DatesAreEditableInSAFTExport()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportCard: TestPage "SAF-T Export Card";
    begin
        // [SCENARIO 405028] Stan can change "Starting Date" and "Ending Date" in SAF-T Export

        Initialize();

        // [GIVEN] SAF-T Export created
        InitSAFTExportScenario(SAFTExportHeader, '', false, true);

        // [GIVEN] SAF-T Export Card opened
        SAFTExportCard.OpenEdit();
        SAFTExportCard.Filter.SetFilter(ID, Format(SAFTExportHeader.ID));

        // [WHEN] Change "Starting Date" and "Ending Date"
        Assert.IsTrue(SAFTExportCard.StartingDate.Editable(), 'Starting date is not visible');
        Assert.IsTrue(SAFTExportCard.EndingDate.Editable(), 'Starting date is not visible');

        SAFTExportCard.Close();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Export Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Export Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Export Tests");
    end;

    local procedure InitSAFTExportScenario(var SAFTExportHeader: Record "SAF-T Export Header"; FolderPath: Text; NoZip: Boolean; MultipleZipFiles: Boolean)
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
    begin
        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", 1);
        SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(SAFTMappingRange."Starting Date", 1);
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);
        SAFTExportHeader.Validate("Folder Path", copystr(FolderPath, 1, MaxStrLen(SAFTExportHeader."Folder Path")));
        SAFTExportHeader.Validate("Disable Zip File Generation", NoZip);
        SAFTExportHeader.Validate("Create Multiple Zip Files", MultipleZipFiles);
        SAFTExportHeader.Modify(true);
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
    end;

    local procedure RemoveFilesInDirectory(var TempNameValueBuffer: Record "Name/Value Buffer" temporary)
    var
        FileMgt: Codeunit "File Management";
    begin
        TempNameValueBuffer.Reset();
        TempNameValueBuffer.Findset();
        repeat
            FileMgt.DeleteServerFile(TempNameValueBuffer.Name);
        until TempNameValueBuffer.Next() = 0;
    end;

    local procedure CreateLongServerDirectory() Folder: Text
    var
        FileMgt: Codeunit "File Management";
    begin
        Folder := FileMgt.CombinePath(FileMgt.ServerCreateTempSubDirectory(), LibraryUtility.GenerateRandomAlphabeticText(30, 0));
        FileMgt.ServerCreateDirectory(Folder);
        exit(Folder);
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;
}