codeunit 139624 "E-Doc Processsing Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var

        Assert: Codeunit Assert;
        LibrarySales: Codeunit "Library - Sales";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryWorkflow: codeunit "Library - Workflow";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        EDocProcessingTest: Codeunit "E-Doc Processsing Test";
        IsInitialized: Boolean;
        EnableOnCheck, EnableOnCreate, EnableOnCreateBatch : Boolean;
        ThrowRuntimeError, ThrowLoggedError : Boolean;
        IncorrectValueErr: Label 'Incorrect value found';
        DocumentSendingProfileWithWorkflowErr: Label 'Workflow %1 defined for %2 in Document Sending Profile %3 is not found.', Comment = '%1 - The workflow code, %2 - Enum value set in Electronic Document, %3 - Document Sending Profile Code';

    [Test]
    procedure CreateEDocumentBeforeAfterEventsSuccessful()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        EDocument: Record "E-Document";
        DocumentSendingProfile: Record "Document Sending Profile";

        RecordRef: RecordRef;
        Variant: Variant;
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check OnBeforeCreatedEDocument and OnAfterCreatedEDocument called successful 

        // [GIVEN] Created posting a document
        Initialize();
        BindSubscription(EDocProcessingTest);

        // [WHEN] E document is created
        LibrarySales.CreateSalesInvoice(SalesHeader);
        LibraryVariableStorage.AssertEmpty();
        EDocProcessingTest.SetVariableStorage(LibraryVariableStorage);
        SalesInvHeader.Get(LibrarySales.PostSalesDocument(SalesHeader, true, true));
        RecordRef.GetTable(SalesInvHeader);
        EDocProcessingTest.GetVariableStorage(LibraryVariableStorage);

        // [THEN] OnBeforeCreatedEDocument is fired and edocument is empty
        Assert.AreEqual(2, LibraryVariableStorage.Length(), IncorrectValueErr);
        LibraryVariableStorage.Dequeue(Variant);
        EDocument := Variant;
        Assert.AreEqual('', EDocument."Document No.", IncorrectValueErr);

        // [THEN] OnAfterCreatedEDocument event is fired and edocument is populated
        LibraryVariableStorage.Dequeue(Variant);
        EDocument := Variant;
        Assert.AreEqual(SalesInvHeader."No.", EDocument."Document No.", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader.RecordId, EDocument."Document Record ID", IncorrectValueErr);
        //Assert.AreEqual(SalesInvHeader."Bill-to Customer No.", EDocument., IncorrectValueErr);
        //Assert.AreEqual(SalesInvHeader."Bill-to Name", EDocument."Bill-to/Pay-to Name", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."Posting Date", EDocument."Posting Date", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."Document Date", EDocument."Document Date", IncorrectValueErr);
        Assert.AreEqual(EDocument."Source Type"::Customer, EDocument."Source Type", IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);
        DocumentSendingProfile.GetDefaultForCustomer(SalesInvHeader."Bill-to Customer No.", DocumentSendingProfile);
        Assert.AreEqual(EDocument."Document Sending Profile", DocumentSendingProfile.Code, IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure CheckEDocumentUnitSucccess()
    var
        SalesHeader, SalesHeader2 : Record "Sales Header";
        EDocService, EDocService2 : Record "E-Document Service";
        EDocExport: Codeunit "E-Doc. Export";
        RecordRef: RecordRef;
        EDocProcessingPhase: Enum "E-Document Processing Phase";
        EDocProcessingPhaseInt: Integer;
        Variant: Variant;
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check that CheckEDocument is successfull

        // [GIVEN] Creating a document and posting it with simple flow setup
        Initialize();
        EDocProcessingTest.EnableOnCheckEvent();
        BindSubscription(EDocProcessingTest);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        RecordRef.GetTable(SalesHeader);

        LibraryVariableStorage.AssertEmpty();
        EDocProcessingTest.SetVariableStorage(LibraryVariableStorage);

        // [WEHN] Check E-Document is called
        EDocExport.CheckEDocument(RecordRef, Enum::"E-Document Processing Phase"::Create);

        EDocProcessingTest.GetVariableStorage(LibraryVariableStorage);
        Assert.AreEqual(3, LibraryVariableStorage.Length(), IncorrectValueErr);

        LibraryVariableStorage.Dequeue(Variant);
        SalesHeader2 := Variant;
        LibraryVariableStorage.Dequeue(Variant);
        EDocService := Variant;
        LibraryVariableStorage.Dequeue(Variant);
        EDocProcessingPhaseInt := Variant;
        EDocProcessingPhase := EDocProcessingPhaseInt;

        // [THEN] EDocService that was created by test for flow, is the one that is provided by event
        EDocService2.FindLast();
        Assert.AreEqual(EDocService.Code, EDocService2.Code, IncorrectValueErr);

        // [THEN] Sales Header that we created is the one that is provided by event            
        Assert.AreEqual(SalesHeader."No.", SalesHeader2."No.", IncorrectValueErr);

        // [THEN] "E-Document Processing Phase" is provided by event
        Assert.AreEqual(Enum::"E-Document Processing Phase"::Create, EDocProcessingPhase, IncorrectValueErr);
        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure CheckEDocumentMultiServiceUnitSucccess()
    var
        SalesHeader: Record "Sales Header";
        EDocService: Record "E-Document Service";
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocExport: Codeunit "E-Doc. Export";
        RecordRef: RecordRef;
        Variant: Variant;
        EDocServiceA, EDocServiceB : Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check that CheckEDocument is successfull for multiple services

        // [GIVEN] Creating a document and posting it with multi service flow setup
        Initialize();
        LibraryWorkflow.DisableAllWorkflows();
        EDocServiceA := LibraryEDoc.CreateService();
        EDocServiceB := LibraryEDoc.CreateService();
        DocumentSendingProfile.GetDefault(DocumentSendingProfile);
        DocumentSendingProfile."Electronic Service Flow" := LibraryEDoc.CreateFlowB2G2BForDocumentSendingProfile(DocumentSendingProfile.Code, EDocServiceA, EDocServiceB);
        DocumentSendingProfile.Modify();

        EDocProcessingTest.EnableOnCheckEvent();
        BindSubscription(EDocProcessingTest);
        LibrarySales.CreateSalesInvoice(SalesHeader);
        RecordRef.GetTable(SalesHeader);

        LibraryVariableStorage.AssertEmpty();
        EDocProcessingTest.SetVariableStorage(LibraryVariableStorage);

        // [WEHN] Check E-Document is called
        EDocExport.CheckEDocument(RecordRef, Enum::"E-Document Processing Phase"::Create);

        EDocProcessingTest.GetVariableStorage(LibraryVariableStorage);
        Assert.AreEqual(6, LibraryVariableStorage.Length(), IncorrectValueErr);

        // [THEN] EDocServices that was created by test for flow, is the one that is provided in event
        LibraryVariableStorage.Peek(Variant, 2);
        EDocService := Variant;
        Assert.AreEqual(EDocService.Code, EDocServiceA, IncorrectValueErr);

        LibraryVariableStorage.Peek(Variant, 5);
        EDocService := Variant;
        Assert.AreEqual(EDocService.Code, EDocServiceB, IncorrectValueErr);
        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure CreateEDocumentFailureNoWorkflow()
    var
        EDocument: Record "E-Document";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check that error is thrown if Document sending profile is defined without Workflow Code

        // [GIVEN] E document is created when posting document with incorrectly setup document sending profile
        Initialize();
        DocumentSendingProfile.GetDefault(DocumentSendingProfile);
        DocumentSendingProfile."Electronic Service Flow" := 'NON-WORKFLOW';
        DocumentSendingProfile.Modify();

        // [THEN] Error is thrown when posting   
        asserterror LibraryEDoc.CreateEDocumentFromSales(EDocument);
        Assert.AreEqual(StrSubstNo(DocumentSendingProfileWithWorkflowErr, 'NON-WORKFLOW', Format(DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow"), DocumentSendingProfile.Code), GetLastErrorText(), IncorrectValueErr);
    end;

    [Test]
    procedure InterfaceCheckErrorE2ESuccess()
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in Check implementation, this will block posting

        // [GIVEN] That we log error in Check implementation
        Initialize();
        EDocProcessingTest.EnableOnCheckEvent();
        EDocProcessingTest.ThrowLoggedErrorInEvent();
        BindSubscription(EDocProcessingTest);

        // [THEN] Error is thrown and posting will be stopped.
        asserterror LibraryEDoc.PostSalesDocument();
        Assert.ExpectedError('TEST');

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCheckRuntimeErrorE2ESuccess()
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an runtime error happens in Check implementation, this will block posting

        // [GIVEN] That we throw runtime error in Check implementation
        Initialize();
        EDocProcessingTest.EnableOnCheckEvent();
        EDocProcessingTest.ThrowRuntimeErrorInEvent();
        BindSubscription(EDocProcessingTest);

        // [THEN] Error is thrown and posting will be stopped.
        asserterror LibraryEDoc.PostSalesDocument();
        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        DocNo: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in Create implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocProcessingTest.EnableOnCreateEvent();
        EDocProcessingTest.ThrowLoggedErrorInEvent();
        BindSubscription(EDocProcessingTest);

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        // [WHEN] Posting document is going to succeed
        DocNo := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();
        EDocumentService.FindLast();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNo, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateRuntimeErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        DocNo: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is thrown in Create implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocProcessingTest.EnableOnCreateEvent();
        EDocProcessingTest.ThrowRuntimeErrorInEvent();
        BindSubscription(EDocProcessingTest);

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        // [WHEN] Posting document is going to succeed
        DocNo := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();
        EDocumentService.FindLast();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNo, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateBatchErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        DocNo: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in CreateBatch implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocProcessingTest.EnableOnCreateBatchEvent();
        EDocProcessingTest.ThrowLoggedErrorInEvent();
        BindSubscription(EDocProcessingTest);

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.FindLast();
        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 1;
        EDocumentService.Modify();

        // [WHEN] Posting document is going to succeed
        DocNo := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNo, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateBatchRuntimeErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        DocNo: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in CreateBatch implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocProcessingTest.EnableOnCreateBatchEvent();
        EDocProcessingTest.ThrowRuntimeErrorInEvent();
        BindSubscription(EDocProcessingTest);

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.FindLast();
        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 1;
        EDocumentService.Modify();

        // [WHEN] Posting document is going to succeed
        DocNo := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNo, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateBatchE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentPage: TestPage "E-Document";
        DocNoA, DocNoB : Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post two documents for activating batch. Validate first edocument, before second is posted, then validate both.

        // [GIVEN] Edocument service using 'Threshold' batch mode
        Initialize();
        BindSubscription(EDocProcessingTest);
        EDocProcessingTest.EnableOnCreateBatchEvent();

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.FindLast();
        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 2;
        EDocumentService.Modify();

        // [WHEN] Posting document is going to succeed
        DocNoA := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct status
        Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNoA, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Batch"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Second document is posted
        DocNoB := LibraryEDoc.PostSalesDocument();
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct status
        Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNoB, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        // [THEN] First edocument was also updated 
        EDocumentPage.First();
        Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(DocNoA, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        UnbindSubscription(EDocProcessingTest);
    end;

    [Test]
    procedure InterfaceCreateBatchRecurrentE2ESuccess()
    var
        EDocumentService: Record "E-Document Service";
        DocNoA: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post two documents for activating batch. Validate first edocument, before second is posted, then validate both.

        // [GIVEN] Edocument service using 'Threshold' batch mode
        Initialize();
        BindSubscription(EDocProcessingTest);

        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.FindLast();
        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Recurrent;
        EDocumentService.Modify();

        // [WHEN] Posting document is going to succeed
        DocNoA := LibraryEDoc.PostSalesDocument();
        // LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentService.RecordId);
        // TODO: Fix when recurrent is finished

        // EDocument.FindLast();
        // EDocumentPage.OpenView();
        // EDocumentPage.Last();

        // // [THEN] E-Document has correct status
        // Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        // Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        // Assert.AreEqual(DocNoA, EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // // [THEN] E-Document Service Status has correct error status
        // Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        // Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Batch"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        // Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // // [THEN] E-Document Errors and Warnings has correct status
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        // Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        // EDocument.Reset();
        // Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);
        // EDocumentPage.Close();

        UnbindSubscription(EDocProcessingTest);
    end;

    internal procedure EnableOnCreateEvent()
    begin
        EnableOnCreate := true;
    end;

    internal procedure EnableOnCreateBatchEvent()
    begin
        EnableOnCreateBatch := true;
    end;

    internal procedure EnableOnCheckEvent()
    begin
        EnableOnCheck := true;
    end;

    internal procedure ThrowRuntimeErrorInEvent()
    begin
        ThrowRuntimeError := true;
    end;

    internal procedure ThrowLoggedErrorInEvent()
    begin
        ThrowLoggedError := true;
    end;

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        IsInitialized := true;
        LibraryVariableStorage.Clear();
        Clear(EDocProcessingTest);
        LibraryEDoc.Initialize();
        EnableOnCheck := false;
        EnableOnCreate := false;
        EnableOnCreateBatch := false;
        ThrowRuntimeError := false;
        DocumentSendingProfile.DeleteAll();
        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();

        LibraryEDoc.CreateSimpleFlow(LibraryEDoc.CreateService());
    end;

    procedure SetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        LibraryVariableStorage := NewLibraryVariableStorage;
    end;

    procedure GetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        NewLibraryVariableStorage := LibraryVariableStorage;
    end;


    // [EventSubscriber(ObjectType::Codeunit, Codeunit::"Job Queue - Enqueue", 'OnBeforeJobQueueScheduleTask', '', false, false)]
    // local procedure ManuallyRunJobQueueTask(var JobQueueEntry: Record "Job Queue Entry"; var DoNotScheduleTask: Boolean)
    // begin
    //     DoNotScheduleTask := true; // Scheduling tasks are not possible while executing tests
    //     // Only execute the job queue if it is scheduled to start today
    //     // Avoid executing again jobs that already failed or succeeded
    //     if DT2Date(JobQueueEntry."Earliest Start Date/Time") = Today then
    //         if not (JobQueueEntry.Status in [JobQueueEntry.Status::Error, JobQueueEntry.Status::Finished]) then begin
    //             JobQueueEntry.Validate(Status, JobQueueEntry.Status::Ready);
    //             JobQueueEntry.Modify();
    //             CODEUNIT.Run(CODEUNIT::"Job Queue Dispatcher", JobQueueEntry);
    //         end;
    // end;



    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnAfterCreateEDocument', '', false, false)]
    local procedure OnAfterCreateEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Export", 'OnBeforeCreateEDocument', '', false, false)]
    local procedure OnBeforeCreatedEDocument(var EDocument: Record "E-Document")
    begin
        LibraryVariableStorage.Enqueue(EDocument);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCheck', '', false, false)]
    local procedure OnCheck(var SourceDocumentHeader: RecordRef; EDocService: Record "E-Document Service"; EDocumentProcessingPhase: enum "E-Document Processing Phase")
    var
        ErrorMessageMgt: Codeunit "Error Message Management";
    begin
        if not EnableOnCheck then
            exit;
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            ErrorMessageMgt.LogErrorMessage(4, 'TEST', EDocService, EDocService.FieldNo("Auto Import"), '');

        LibraryVariableStorage.Enqueue(SourceDocumentHeader);
        LibraryVariableStorage.Enqueue(EDocService);
        LibraryVariableStorage.Enqueue(EDocumentProcessingPhase.AsInteger());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreate', '', false, false)]
    local procedure OnCreate(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        if not EnableOnCreate then
            exit;
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            EDocErrorHelper.LogErrorMessage(EDocument, EDocService, EDocService.FieldNo("Auto Import"), 'TEST');

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('TEST');
        LibraryVariableStorage.Enqueue(TempBlob.Length());
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreateBatch', '', false, false)]
    local procedure OnCreateBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        if not EnableOnCreateBatch then
            exit;
        if ThrowRuntimeError then
            Error('TEST');
        if ThrowLoggedError then
            EDocErrorHelper.LogErrorMessage(EDocuments, EDocService, EDocService.FieldNo("Auto Import"), 'TEST');

        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('TEST');
        LibraryVariableStorage.Enqueue(TempBlob.Length());
    end;
}