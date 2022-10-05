codeunit 148113 "Incoming Documents CZZ"
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
    procedure TestPurchaseAdvanceOptionInDialog()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] When the CreateManually function is triggered then the purchase advance option is showed in dialog.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The purchase advance as expected option has been set
        SetExpectedStrMenu(PurchaseAdvanceTxt);

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The purchase advance option will be show in dialog
        // Verification in CheckCreatedDocumentStrMenuHandler
    end;

    [Test]
    [HandlerFunctions('CheckCreatedDocumentStrMenuHandler')]
    procedure TestSalesAdvanceOptionInDialog()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] When the CreateManually function is triggered then the sales advance option is showed in dialog.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The sales advance as expected option has been set
        SetExpectedStrMenu(SalesAdvanceTxt);

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The sales advance option will be show in dialog
        // Verification in CheckCreatedDocumentStrMenuHandler
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,PurchAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure CreationPurchaseAdvanceDocument()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The purchase advance letter document can be created from incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The purchase advance letter has been selected in dialog
        SetStrMenuChoice(7); // 7 - Purchase Advance

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The purchase advance letter document will be created
        PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsNotEmpty(PurchAdvLetterHeaderCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,SalesAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure CreationSalesAdvanceDocument()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The sales advance letter document can be created from incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The sales advance letter has been selected in dialog
        SetStrMenuChoice(8); // 8 - Sales Advance

        // [WHEN] Run CreateManually function
        IncomingDocument.CreateManually();

        // [THEN] The sales advance letter document will be created
        SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsNotEmpty(SalesAdvLetterHeaderCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,PurchAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure TestIfPurchaseAdvanceLetterAlreadyExists()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The error occur when the TestIfAlreadyExists function is triggered and purchase advance letter has been already created.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The purchase advance letter has been selected in dialog
        SetStrMenuChoice(7); // 7 - Purchase Advance

        // [GIVEN] The purchase advance letter has been created
        IncomingDocument.CreateManually();

        // [WHEN] Run TestIfAlreadyExists function
        asserterror IncomingDocument.TestIfAlreadyExists();

        // [THEN] Error will occur
        Assert.ExpectedError(StrSubstNo(AlreadyUsedInPurchaseAdvanceErr, IncomingDocument."Document No."));
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,SalesAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure TestIfSalesAdvanceLetterAlreadyExists()
    var
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The error occur when the TestIfAlreadyExists function is triggered and sales advance letter has been already created.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The sales advance letter has been selected in dialog
        SetStrMenuChoice(8); // 8 - Sales Advance

        // [GIVEN] The sales advance letter has been created
        IncomingDocument.CreateManually();

        // [WHEN] Run TestIfAlreadyExists function
        asserterror IncomingDocument.TestIfAlreadyExists();

        // [THEN] Error will occur
        Assert.ExpectedError(StrSubstNo(AlreadyUsedInSalesAdvanceErr, IncomingDocument."Document No."));
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,PurchAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure DeletionRelatedPurchaseAdvanceLetterDocument()
    var
        PurchAdvLetterHeaderCZZ: Record "Purch. Adv. Letter Header CZZ";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The related purchase advance letter must be deleted after the deletion of incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The purchase advance letter has been selected in dialog
        SetStrMenuChoice(7); // 7 - Purchase Advance

        // [GIVEN] The purchase advance letter has been created
        IncomingDocument.CreateManually();

        // [WHEN] Delete incoming document
        IncomingDocument.Delete(true);

        // [THEN] Purchase advance letter won't be exist
        PurchAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsEmpty(PurchAdvLetterHeaderCZZ);
    end;

    [Test]
    [HandlerFunctions('CreatedDocumentStrMenuHandler,SalesAdvanceLetterHandler,AdvanceLetterTemplatesHandler')]
    procedure DeletionRelatedSalesAdvanceLetterDocument()
    var
        SalesAdvLetterHeaderCZZ: Record "Sales Adv. Letter Header CZZ";
        IncomingDocument: Record "Incoming Document";
    begin
        // [SCENARIO] The related sales advance letter must be deleted after the deletion of incoming document.
        Initialize();

        // [GIVEN] Incoming document has been created
        CreateIncomingDocument(IncomingDocument);

        // [GIVEN] The sales advance letter has been selected in dialog
        SetStrMenuChoice(8); // 8 - Sales Advance

        // [GIVEN] The sales advance letter has been created
        IncomingDocument.CreateManually();

        // [WHEN] Delete incoming document
        IncomingDocument.Delete(true);

        // [THEN] Sales advance letter won't be exist
        SalesAdvLetterHeaderCZZ.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        Assert.RecordIsEmpty(SalesAdvLetterHeaderCZZ);
    end;

    var
        Assert: Codeunit Assert;
        LibraryDialogHandler: Codeunit "Library - Dialog Handler";
        LibraryIncomingDocuments: Codeunit "Library - Incoming Documents";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        isInitialized: Boolean;
        PurchaseAdvanceTxt: Label 'Purchase Advance';
        SalesAdvanceTxt: Label 'Sales Advance';
        AlreadyUsedInPurchaseAdvanceErr: Label 'The incoming document has already been assigned to purchase advance %1.', Comment = '%1 = Document Number';
        AlreadyUsedInSalesAdvanceErr: Label 'The incoming document has already been assigned to sales advance %1.', Comment = '%1 = Document Number';

    local procedure Initialize()
    var
        LibraryTestInitialize: Codeunit "Library - Test Initialize";
    begin
        LibraryTestInitialize.OnTestInitialize(Codeunit::"Incoming Documents CZZ");
        if isInitialized then
            exit;
        LibraryTestInitialize.OnBeforeTestSuiteInitialize(Codeunit::"Incoming Documents CZZ");

        LibraryDialogHandler.ClearVariableStorage();
        LibraryVariableStorage.Clear();

        isInitialized := true;
        Commit();
        LibraryTestInitialize.OnAfterTestSuiteInitialize(Codeunit::"Incoming Documents CZZ");
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
    procedure PurchAdvanceLetterHandler(var PurchAdvanceLetterCZZ: TestPage "Purch. Advance Letter CZZ")
    begin
    end;

    [PageHandler]
    procedure SalesAdvanceLetterHandler(var SalesAdvanceLetterCZZ: TestPage "Sales Advance Letter CZZ")
    begin
    end;

    [ModalPageHandler]
    procedure AdvanceLetterTemplatesHandler(var AdvanceLetterTemplatesCZZ: TestPage "Advance Letter Templates CZZ")
    begin
        AdvanceLetterTemplatesCZZ.First();
        AdvanceLetterTemplatesCZZ.Ok().Invoke();
    end;
}