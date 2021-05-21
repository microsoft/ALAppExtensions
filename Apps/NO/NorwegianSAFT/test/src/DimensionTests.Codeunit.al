codeunit 148108 "SAF-T Dimension Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T] [XML] [Dimension]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryRandom: Codeunit "Library - Random";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryDimension: Codeunit "Library - Dimension";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        Assert: Codeunit Assert;
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        GenerateSAFTFileImmediatelyQst: Label 'Since you did not schedule the SAF-T file generation, it will be generated immediately which can take a while. Do you want to continue?';

    [Test]
    [HandlerFunctions('ConfirmYesHandler')]
    procedure GLEntryOnlyExportsWithDimensionsMarkedForExport()
    var
        SAFTMappingRange: Record "SAF-T Mapping Range";
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTExportLine: Record "SAF-T Export Line";
        TempXMLBuffer: Record "XML Buffer" temporary;
        GLAccount: Record "G/L Account";
        Customer: Record Customer;
        GLEntry: Record "G/L Entry";
        Dimension: array[2] of Record Dimension;
        DimensionValue: array[2] of Record "Dimension Value";
        DocNo: Code[20];
        DimSetID: Integer;
    begin
        // [SCENARIO 361600] A G/L Entry only exports with dimension which are marked for export

        Initialize();

        SAFTTestHelper.SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account", LibraryRandom.RandInt(5));
        SAFTTestHelper.MatchGLAccountsFourDigit(SAFTMappingRange.Code);
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        DocNo := LibraryUtility.GenerateGUID();
        GLAccount.SetRange("Income/Balance", GLAccount."Income/Balance"::"Balance Sheet");
        GLAccount.FindFirst();
        Customer.FindFirst();
        SAFTTestHelper.IncludesNoSourceCodeToTheFirstSAFTSourceCode();

        // [GIVEN] Two dimension values "A" and "B", both include into the dimension set "X" but only "A" has the option "Export to SAF-T" enabled
        CreteDimensionWithValueForExport(Dimension[1], DimensionValue[1], true);
        CreteDimensionWithValueForExport(Dimension[2], DimensionValue[2], false);
        DimSetID :=
            LibraryDimension.CreateDimSet(
                LibraryDimension.CreateDimSet(0, DimensionValue[1]."Dimension Code", DimensionValue[1].Code),
                DimensionValue[2]."Dimension Code", DimensionValue[2].Code);

        // [GIVEN] Two G/L Entries with the same document/transaction, one  with "Gen. Posting Type" = Sales, one with blank value
        SAFTTestHelper.MockGLEntry(
            SAFTExportHeader."Ending Date", DocNo, GLAccount."No.",
            1, DimSetID, GLEntry."Gen. Posting Type"::Sale, '',
            '', GLEntry."Source Type"::Customer, Customer."No.", '', LibraryRandom.RandDec(100, 2), 0);

        // [WHEN] Export G/L Entries to the XML file
        LibraryVariableStorage.Enqueue(GenerateSAFTFileImmediatelyQst);
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);
        SAFTExportLine.SetRange("Master Data", false);
        SAFTTestHelper.FindSAFTExportLine(SAFTExportLine, SAFTExportHeader.ID);
        SAFTTestHelper.LoadXMLBufferFromSAFTExportLine(TempXMLBuffer, SAFTExportLine);

        // [THEN] Only dimension "A" of the dimension set "X" was exported
        Assert.IsTrue(
            TempXMLBuffer.FindNodesByXPath(TempXMLBuffer,
                '/n1:AuditFile/n1:GeneralLedgerEntries/n1:Journal/n1:Transaction/n1:Line/n1:Analysis'),
                'No dimension xml nodes are exported.');
        Assert.RecordCount(TempXMLBuffer, 1);
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisType', Dimension[1]."SAF-T Analysis Type");
        SAFTTestHelper.AssertElementValue(TempXMLBuffer, 'n1:AnalysisID', DimensionValue[1].Code);
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Dimension Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Dimension Tests");

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Dimension Tests");
    end;

    local procedure CreteDimensionWithValueForExport(var Dimension: Record Dimension; var DimensionValue: Record "Dimension Value"; ExportToSAFT: Boolean)
    begin
        LibraryDimension.CreateDimension(Dimension);
        Dimension.Validate("Export to SAF-T", ExportToSAFT);
        Dimension.Modify(true);
        LibraryDimension.CreateDimensionValue(DimensionValue, Dimension.Code);
    end;

    [ConfirmHandler]
    procedure ConfirmYesHandler(Question: Text; var Reply: Boolean)
    begin
        Assert.ExpectedMessage(LibraryVariableStorage.DequeueText(), Question);
        Reply := true;
    end;
}