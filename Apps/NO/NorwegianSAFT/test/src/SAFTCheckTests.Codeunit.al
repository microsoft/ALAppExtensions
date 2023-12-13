codeunit 148104 "SAF-T Check Tests"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [SAF-T]
    end;

    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        SAFTTestHelper: Codeunit "SAF-T Test Helper";
        LibraryDimension: Codeunit "Library - Dimension";
        LibraryERM: Codeunit "Library - ERM";
        LibraryRandom: Codeunit "Library - Random";
        SAFTMappingType: Enum "SAF-T Mapping Type";
        IsInitialized: Boolean;
        MappingNotDoneErr: Label 'One or more G/L accounts do not have a mapping setup. Open the SAF-T Mapping Setup page for the selected mapping range and map each G/L account either to the  standard account or the grouping code.';
        DimensionWithoutAnalysisCodeErr: Label 'One or more dimensions do not have a SAF-T analysis code. Open the Dimensions page and specify a SAF-T analysis code for each dimension.';
        VATPostingSetupWithoutTaxCodeErr: Label 'One or more VAT posting setup do not have a %1. Open the VAT Posting Setup page and specify %1 for each VAT posting setup combination.', Comment = '%1 = Tax Code Field Caption';
        SourceCodeWithoutSAFTCodeErr: Label 'One or more source codes do not have a SAF-T source code. Open the Source Codes page and specify a SAF-T source code for each source code.';
        FieldValueIsNotSpecifiedErr: Label '%1 is not specified', Comment = '%1 = Field Caption';

    [Test]
    [HandlerFunctions('ErrorLogPageHandler')]
    procedure ErrorLogShownOnFailedSAFTExportRun()
    var
        SAFTExportHeader: Record "SAF-T Export Header";
        SAFTMappingRange: Record "SAF-T Mapping Range";
        Dimension: Record Dimension;
        VATPostingSetup: Record "VAT Posting Setup";
        SourceCode: Record "Source Code";
        CompanyInformation: Record "Company Information";
    begin
        // [FEATURE] [UI]
        // [SCENARIO 309923] Error Messages page shown with errors on SAF-T file generation

        Initialize();
        SetupSAFT(SAFTMappingRange, SAFTMappingType::"Four Digit Standard Account");
        SAFTTestHelper.CreateSAFTExportHeader(SAFTExportHeader, SAFTMappingRange.Code);

        // [GIVEN] Post G/L entries in SAF-T Export period for G/L Account without mapping
        SAFTTestHelper.PostRandomAmountForNumberOfMasterDataRecords(SAFTExportHeader."Starting Date", 1);

        // [GIVEN] Dimension without SAF-T Analysis Type
        LibraryDimension.CreateDimension(Dimension);
        Dimension.Validate("SAF-T Analysis Type", '');
        Dimension.Modify(true);

        // [GIVEN] VAT Posting Setup without Sales and Purchase SAF-T Tax codes
        LibraryERM.FindVATPostingSetup(VATPostingSetup, VATPostingSetup."VAT Calculation Type"::"Normal VAT");
        VATPostingSetup.Validate("Sales SAF-T Tax Code", 0);
        VATPostingSetup.Validate("Purchase SAF-T Tax Code", 0);
        VATPostingSetup.Modify(true);

        // [GIVEN] Source code without SAF-T Source Code
        LibraryERM.CreateSourceCode(SourceCode);
        SourceCode.Validate("SAF-T Source Code", '');
        SourceCode.Modify(true);

        // [GIVEN] SAF-T Contact No. is not specified in Company Information
        CompanyInformation.Get();
        CompanyInformation.Validate("SAF-T Contact No.", '');
        CompanyInformation.Modify(true);

        LibraryVariableStorage.Enqueue(MappingNotDoneErr);
        LibraryVariableStorage.Enqueue(DimensionWithoutAnalysisCodeErr);
        LibraryVariableStorage.Enqueue(
            StrSubstNo(VATPostingSetupWithoutTaxCodeErr, VATPostingSetup.FieldCaption("Sales SAF-T Tax Code")));
        LibraryVariableStorage.Enqueue(
            StrSubstNo(VATPostingSetupWithoutTaxCodeErr, VATPostingSetup.FieldCaption("Purchase SAF-T Tax Code")));
        LibraryVariableStorage.Enqueue(SourceCodeWithoutSAFTCodeErr);
        LibraryVariableStorage.Enqueue(StrSubstNo(FieldValueIsNotSpecifiedErr, CompanyInformation.FieldCaption("SAF-T Contact No.")));

        // [WHEN] Generate SAF-T File
        SAFTTestHelper.RunSAFTExport(SAFTExportHeader);

        // [THEN] Error log shown with all the missed information
        // Handles by ErrorLogPageHandler 
        LibraryVariableStorage.AssertEmpty();
    end;

    local procedure Initialize()
    begin
        LibraryTestInitialize.OnTestInitialize(CODEUNIT::"SAF-T Check Tests");
        if IsInitialized then
            exit;

        LibraryTestInitialize.OnBeforeTestSuiteInitialize(CODEUNIT::"SAF-T Check Tests");
        BindSubscription(LibraryJobQueue);

        IsInitialized := true;
        LibraryTestInitialize.OnAfterTestSuiteInitialize(CODEUNIT::"SAF-T Check Tests");
    end;

    local procedure SetupSAFT(var SAFTMappingRange: Record "SAF-T Mapping Range"; MappingType: Enum "SAF-T Mapping Type"): Code[20]
    begin
        SAFTTestHelper.SetupMasterData(LibraryRandom.RandInt(5));
        SAFTTestHelper.InsertSAFTMappingRangeFullySetup(
            SAFTMappingRange, MappingType,
            CalcDate('<-CY>', WorkDate()), CalcDate('<CY>', WorkDate()));
        exit(SAFTMappingRange.Code);
    end;

    [PageHandler]
    procedure ErrorLogPageHandler(var ErrorMessages: TestPage "Error Messages")
    begin
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // mapping not done
        ErrorMessages.Next();
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // dimension
        ErrorMessages.Next();
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // sales VAT Posting Setup
        ErrorMessages.Next();
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // purchase VAT Posting Setup
        ErrorMessages.Next();
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // Source Code
        ErrorMessages.Next();
        ErrorMessages.Description.AssertEquals(LibraryVariableStorage.DequeueText()); // Company Information
        ErrorMessages.Next();
    end;

}
