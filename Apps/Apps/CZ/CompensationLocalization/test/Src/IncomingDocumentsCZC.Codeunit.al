codeunit 148110 "Incoming Documents CZC"
{
    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Incoming Document]
        isInitialized := false;
    end;

    [Test]
    [HandlerFunctions('CheckCreatedDocumentStrMenuHandler')]
    procedure TestCompensationOptionInDialog()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] When the CreateManually function is triggered then the compensation option is showed in dialog.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The compensation as expected option has been set
        SetExpectedStrMenu(CompensationTxt);

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The compensation option will be show in dialog
        // Verification in CheckCreatedDocumentStrMenuHandler
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,CompensationCardHandler')]
    procedure CreationCompensationDocument()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The compensation document can be created from incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The compensation has been selected in dialog
        SetStrMenuChoice(6); // 6 - Compensation

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The compensation document will be created
        CompensationHeaderCZC.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsNotEmpty(CompensationHeaderCZC);
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,CompensationCardHandler')]
    procedure TestIfCompensationAlreadyExists()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The error occur when the TestIfAlreadyExists function is triggered and compensation has been already created.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The compensation has been selected in dialog
        SetStrMenuChoice(6); // 6 - Compensation

        // [GIVEN] The compensation has been created
        IncomingDocument.CreateManually();

        // [WHEN] Run TestIfAlreadyExists function
        asserterror IncomingDocument.TestIfAlreadyExists();

        // [THEN] Error will occur
        Assert.ExpectedError(StrSubstNo(AlreadyUsedInCompensationErr, IncomingDocument."Document No."));
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,CompensationCardHandler')]
    procedure DeletionRelatedCompensationDocument()
    var
        CompensationHeaderCZC: Record "Compensation Header CZC";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The related compensation must be deleted After the deletion of incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The compensation has been selected in dialog
        SetStrMenuChoice(6); // 6 - Compensation

        // [GIVEN] The compensation has been created
        IncomingDocument.CreateManually();

        // [WHEN] Delete incoming document
        IncomingDocument.Delete(true);

        // [THEN] Compensation won't be exist
        CompensationHeaderCZC.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsEmpty(CompensationHeaderCZC);
    end;

    var
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryIncomingDocuments: Codeunit "Library - Incoming Documents";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        CompensationTxt: Label 'Compensation';
        AlreadyUsedInCompensationErr: Label 'The incoming document has already been assigned to compensation %1.', Comment = '%1 = Document Number';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Incoming Documents CZC");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Incoming Documents CZC");

        LibraryDialogHandler.ClearVariableStorage();
        LibraryVariableStorage.Clear();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Incoming Documents CZC");
    end;

    local procedure CreateIncomingDocument(var IncomingDocument: Record "Incoming Document")
    begin
        LibraryIncomingDocuments.CreateNewIncomingDocument(IncomingDocument);
    end;

    local procedure SetExpectedStrMenu(Options: Text[1024])
    begin
        LibraryDialogHandler.SetExpectedStrMenu(Options, -1, '');
    end;

    local procedure SetStrMenuChoice(Choice: Integer)
    begin
        LibraryVariableStorage.Enqueue(Choice);
    end;

    [StrMenuHandler]
    procedure CheckCreatedDocumentStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        LibraryDialogHandler.HandleStrMenu(Options, Choice, Instruction);
    end;

    [StrMenuHandler]
    procedure CreatedDocumentStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := LibraryVariableStorage.DequeueInteger();
    end;

    [PageHandler]
    procedure CompensationCardHandler(var CompensationCardCZC: TestPage "Compensation Card CZC")
    begin
    end;
}