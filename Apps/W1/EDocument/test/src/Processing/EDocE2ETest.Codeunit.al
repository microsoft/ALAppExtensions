codeunit 139624 "E-Doc E2E Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryWorkflow: codeunit "Library - Workflow";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        LibraryPurchase: Codeunit "Library - Purchase";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Incorrect value found';
        DocumentSendingProfileWithWorkflowErr: Label 'Workflow %1 defined for %2 in Document Sending Profile %3 is not found.', Comment = '%1 - The workflow code, %2 - Enum value set in Electronic Document, %3 - Document Sending Profile Code';
        FailedToGetBlobErr: Label 'Failed to get exported blob from EDocument %1', Comment = '%1 - E-Document No.';
        SendingErrStateErr: Label 'E-document is Pending response and can not be sent in this state.';
        DeleteNotAllowedErr: Label 'Deletion of Purchase Header linked to E-Document is not allowed.';

    [Test]
    procedure CreateEDocumentBeforeAfterEventsSuccessful()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
        DocumentSendingProfile: Record "Document Sending Profile";
        Variant: Variant;
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check OnBeforeCreatedEDocument and OnAfterCreatedEDocument called successful 

        // [GIVEN] SETUP
        Initialize();
        BindSubscription(EDocImplState);
        LibraryVariableStorage.AssertEmpty();
        EDocImplState.SetVariableStorage(LibraryVariableStorage);

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        SalesInvHeader := LibraryEDoc.PostInvoice(Customer);

        // [THEN] OnBeforeCreatedEDocument is fired and edocument is empty
        EDocImplState.GetVariableStorage(LibraryVariableStorage);
        Assert.AreEqual(2, LibraryVariableStorage.Length(), IncorrectValueErr);
        LibraryVariableStorage.Dequeue(Variant);
        EDocument := Variant;
        Assert.AreEqual('', EDocument."Document No.", 'OnBeforeCreatedEDocument should give empty edocument');

        // [THEN] OnAfterCreatedEDocument event is fired and edocument is populated
        LibraryVariableStorage.Dequeue(Variant);
        EDocument := Variant;
        Assert.AreEqual(SalesInvHeader."No.", EDocument."Document No.", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader.RecordId, EDocument."Document Record ID", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."Posting Date", EDocument."Posting Date", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."Document Date", EDocument."Document Date", IncorrectValueErr);
        Assert.AreEqual(EDocument."Source Type"::Customer, EDocument."Source Type", IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);
        DocumentSendingProfile.GetDefaultForCustomer(Customer."No.", DocumentSendingProfile);
        Assert.AreEqual(EDocument."Document Sending Profile", DocumentSendingProfile.Code, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure CheckEDocumentUnitSucccess()
    var
        SalesHeader, SalesHeader2 : Record "Sales Header";
        EDocService: Record "E-Document Service";
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
        EDocImplState.EnableOnCheckEvent();
        BindSubscription(EDocImplState);
        LibraryVariableStorage.AssertEmpty();
        EDocImplState.SetVariableStorage(LibraryVariableStorage);

        // [WHEN] Team member create invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, Enum::"Sales Document Type"::Invoice);
        RecordRef.GetTable(SalesHeader);

        // [WEHN] Check E-Document is called
        EDocExport.CheckEDocument(RecordRef, Enum::"E-Document Processing Phase"::Create);

        EDocImplState.GetVariableStorage(LibraryVariableStorage);
        Assert.AreEqual(3, LibraryVariableStorage.Length(), IncorrectValueErr);

        LibraryVariableStorage.Dequeue(Variant);
        SalesHeader2 := Variant;
        LibraryVariableStorage.Dequeue(Variant);
        EDocService := Variant;
        LibraryVariableStorage.Dequeue(Variant);
        EDocProcessingPhaseInt := Variant;
        EDocProcessingPhase := EDocProcessingPhaseInt;

        // [THEN] EDocService that was created by test for flow, is the one that is provided by event

        Assert.AreEqual(EDocService.Code, EDocumentService.Code, IncorrectValueErr);

        // [THEN] Sales Header that we created is the one that is provided by event            
        Assert.AreEqual(SalesHeader."No.", SalesHeader2."No.", IncorrectValueErr);

        // [THEN] "E-Document Processing Phase" is provided by event
        Assert.AreEqual(Enum::"E-Document Processing Phase"::Create, EDocProcessingPhase, IncorrectValueErr);
        UnbindSubscription(EDocImplState);
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
        EDocServiceA, EDocServiceB, WorkflowCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check that CheckEDocument is successfull for multiple services

        // [GIVEN] Creating a document and posting it with multi service flow setup
        Initialize();
        LibraryWorkflow.DisableAllWorkflows();
        EDocServiceA := LibraryEDoc.CreateService();
        EDocServiceB := LibraryEDoc.CreateService();
        LibraryEDoc.CreateDocSendingProfile(DocumentSendingProfile);
        WorkflowCode := LibraryEDoc.CreateFlowWithServices(DocumentSendingProfile.Code, EDocServiceA, EDocServiceB);
        DocumentSendingProfile."Electronic Document" := DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := WorkflowCode;
        DocumentSendingProfile.Modify();
        Customer."Document Sending Profile" := DocumentSendingProfile.Code;
        Customer.Modify();

        EDocImplState.EnableOnCheckEvent();
        BindSubscription(EDocImplState);
        LibraryVariableStorage.AssertEmpty();
        EDocImplState.SetVariableStorage(LibraryVariableStorage);

        // [WHEN] Team member create invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, Enum::"Sales Document Type"::Invoice);
        RecordRef.GetTable(SalesHeader);

        // [WEHN] Check E-Document is called
        EDocExport.CheckEDocument(RecordRef, Enum::"E-Document Processing Phase"::Create);

        EDocImplState.GetVariableStorage(LibraryVariableStorage);
        Assert.AreEqual(6, LibraryVariableStorage.Length(), IncorrectValueErr);

        // [THEN] EDocServices that was created by test for flow, is the one that is provided in event
        LibraryVariableStorage.Peek(Variant, 2);
        EDocService := Variant;
        Assert.AreEqual(EDocService.Code, EDocServiceA, IncorrectValueErr);

        LibraryVariableStorage.Peek(Variant, 5);
        EDocService := Variant;
        Assert.AreEqual(EDocService.Code, EDocServiceB, IncorrectValueErr);
        UnbindSubscription(EDocImplState);

        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryWorkflow.DisableAllWorkflows();
        LibraryWorkflow.DeleteAllExistingWorkflows();
        EDocService.SetFilter(Code, '%1|%2', EDocServiceA, EDocServiceB);
        EDocService.DeleteAll();
        IsInitialized := false;
    end;

    [Test]
    procedure CreateEDocumentFailureNoWorkflow()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Check that error is thrown if Document sending profile is defined without Workflow Code

        // [GIVEN] E document is created when posting document with incorrectly setup document sending profile
        Initialize();
        LibraryEDoc.CreateDocSendingProfile(DocumentSendingProfile);
        DocumentSendingProfile."Electronic Document" := DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow";
        DocumentSendingProfile."Electronic Service Flow" := 'NON-WORKFLOW';
        DocumentSendingProfile.Modify();
        Customer."Document Sending Profile" := DocumentSendingProfile.Code;
        Customer.Modify();

        LibraryLowerPermission.SetTeamMember();
        asserterror LibraryEDoc.PostInvoice(Customer);
        // [THEN] Error is thrown when posting   
        //asserterror LibraryEDoc.CreateEDocumentFromSales(EDocument, Customer."No.");
        Assert.AreEqual(StrSubstNo(DocumentSendingProfileWithWorkflowErr, 'NON-WORKFLOW', Format(DocumentSendingProfile."Electronic Document"::"Extended E-Document Service Flow"), DocumentSendingProfile.Code), GetLastErrorText(), IncorrectValueErr);
        IsInitialized := false;
    end;

    [Test]
    procedure InterfaceCheckErrorE2ESuccess()
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in Check implementation, this will block posting

        // [GIVEN] That we log error in Check implementation
        Initialize();
        EDocImplState.EnableOnCheckEvent();
        EDocImplState.SetThrowLoggedError();
        BindSubscription(EDocImplState);
        LibraryLowerPermission.SetTeamMember();

        // [THEN] Error is thrown and posting will be stopped.
        asserterror LibraryEDoc.PostInvoice(Customer);
        Assert.ExpectedError('TEST');

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCheckRuntimeErrorE2ESuccess()
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an runtime error happens in Check implementation, this will block posting

        // [GIVEN] That we throw runtime error in Check implementation
        Initialize();
        EDocImplState.EnableOnCheckEvent();
        EDocImplState.SetThrowRuntimeError();
        BindSubscription(EDocImplState);
        LibraryLowerPermission.SetTeamMember();

        // [THEN] Error is thrown and posting will be stopped.
        asserterror LibraryEDoc.PostInvoice(Customer);
        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in Create implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocImplState.SetThrowLoggedError();
        BindSubscription(EDocImplState);

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        // [WHEN] Posting document is not going to succeed
        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        EDocument.SetFilter("Entry No", '>=%1', EDocument."Entry No");
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateRuntimeErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is thrown in Create implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocImplState.SetThrowRuntimeError();
        BindSubscription(EDocImplState);

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        EDocument.Reset();
        EDocument.SetFilter("Entry No", '>=%1', EDocument."Entry No");
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateWithEmptyBlobE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocLog: Record "E-Document Log";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] 

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocImplState.SetDisableOnCreateOutput();
        BindSubscription(EDocImplState);

        EDocument.FindLast();
        EDocument.SetFilter("Entry No", '>%1', EDocument."Entry No");

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Sending Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] Logs are also correct
        EDocLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocLog.SetRange("Service Code", EDocumentService.Code);
        EDocLog.FindSet();
        Assert.AreEqual(Enum::"E-Document Service Status"::Exported, EDocLog.Status, IncorrectValueErr);
        EDocLog.Next();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Sending Error", EDocLog.Status, IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual(StrSubstNo(FailedToGetBlobErr, EDocument."Entry No"), EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateBatchErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in CreateBatch implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocImplState.SetThrowLoggedError();
        BindSubscription(EDocImplState);

        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 1;
        EDocumentService.Modify();

        EDocument.FindLast();
        EDocument.SetFilter("Entry No", '>%1', EDocument."Entry No");

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateBatchRuntimeErrorE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] If an error is logged with Error Message in CreateBatch implementation, this will NOT block posting

        // [GIVEN] That we log error in Create implementation
        Initialize();
        EDocImplState.SetThrowRuntimeError();
        BindSubscription(EDocImplState);

        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 1;
        EDocumentService.Modify();

        EDocument.FindLast();
        EDocument.SetFilter("Entry No", '>%1', EDocument."Entry No");

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct error status
        Assert.AreEqual(Format(EDocument.Status::Error), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Export Error"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('2', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('Error', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('TEST', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateBatchE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentPage: TestPage "E-Document";
        DocNoA: Code[20];
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post two documents for activating batch. Validate first edocument, before second is posted, then validate both.

        // [GIVEN] Edocument service using 'Threshold' batch mode
        IsInitialized := false;
        Initialize();
        BindSubscription(EDocImplState);

        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 2;
        EDocumentService.Modify();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);

        // [THEN] E-Document has correct status
        Assert.AreEqual(Format(EDocument.Status::"In Progress"), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::"Pending Batch"), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('1', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        DocNoA := EDocument."Document No.";
        EDocument.SetFilter("Entry No", '>=%1', EDocument."Entry No");
        Assert.AreEqual(1, EDocument.Count(), IncorrectValueErr);
        EDocumentPage.Close();

        // [WHEN] Second document is posted
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        EDocumentPage.OpenView();
        EDocumentPage.Last();

        // [THEN] E-Document has correct status
        Assert.AreEqual(Format(EDocument.Status::Processed), EDocumentPage."Electronic Document Status".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(EDocument.Direction::Outgoing), EDocumentPage.Direction.Value(), IncorrectValueErr);
        Assert.AreEqual(EDocument."Document No.", EDocumentPage."Document No.".Value(), IncorrectValueErr);

        // [THEN] E-Document Service Status has correct error status
        Assert.AreEqual(EDocumentService.Code, EDocumentPage.EdocoumentServiceStatus."E-Document Service Code".Value(), IncorrectValueErr);
        Assert.AreEqual(Format(Enum::"E-Document Service Status"::Sent), EDocumentPage.EdocoumentServiceStatus.Status.Value(), IncorrectValueErr);
        Assert.AreEqual('3', EDocumentPage.EdocoumentServiceStatus.Logs.Value(), IncorrectValueErr);

        // [THEN] E-Document Errors and Warnings has correct status
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart."Message Type".Value(), IncorrectValueErr);
        Assert.AreEqual('', EDocumentPage.ErrorMessagesPart.Description.Value(), IncorrectValueErr);

        // [THEN] First edocument was also updated 
        EDocumentPage.Filter.SetFilter("Document No.", DocNoA);
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

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceCreateBatchRecurrentE2ESuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentServicePage: TestPage "E-Document Service";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post two documents for activating batch. Validate first edocument, before second is posted, then validate both.

        // [GIVEN] Edocument service using 'Threshold' batch mode
        Initialize();
        BindSubscription(EDocImplState);

        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Recurrent;
        EDocumentService.Modify();

        EDocumentServicePage.OpenView();
        EDocumentServicePage.Filter.SetFilter(Code, EDocumentService.Code);
        EDocumentServicePage.Close();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.FindLast();

        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Pending Batch", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);

        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentService.RecordId);

        EDocument.FindLast();
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();

        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;


    [Test]
    procedure InterfaceCreateBatchRecurrentE2EFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentServicePage: TestPage "E-Document Service";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document. Nothhing is exported to temp blob so sending fails 

        // [GIVEN] Edocument service using 'Recurrent' batch mode
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetDisableOnCreateBatchOutput();

        EDocumentService.SetRecFilter();
        EDocumentService.FindFirst();
        EDocumentService."Use Batch Processing" := true;
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Recurrent;
        EDocumentService.Modify();

        EDocumentServicePage.OpenView();
        EDocumentServicePage.Filter.SetFilter(Code, EDocumentService.Code);
        EDocumentServicePage.Close();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.FindLast();

        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Pending Batch", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);

        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentService.RecordId);

        EDocument.FindLast();
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();

        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);

        LibraryLowerPermission.SetOutsideO365Scope();
        EDocumentService.FindFirst();
        EDocumentService."Use Batch Processing" := false;
        EDocumentService.Modify();
    end;

    [Test]
    procedure InterfaceAsyncSendingSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Send and GetResponse has been executed.
        // Check that document is pending response after posting and after get response job is run it is sent

        // [GIVEN] Edocument service using 'Recurrent' batch mode
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();

        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Pending Response", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);

        // [WHEN] Executing Get Response succesfully
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Sent on service, and document is processed
        EDocument.FindLast();
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;



    [Test]
    procedure InterfaceSyncSendingSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Interface on-send synchronization success scenario

        // [GIVEN] Edocument service using 'Recurrent' batch mode
        Initialize();
        BindSubscription(EDocImplState);

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();
        EDocument.Get(EDocument."Entry No"); // Get after job queue run

        // [THEN] Verify that document was sent
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::Sent, EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Processed, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnSendSyncRuntimeFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Verifies the system's response to a runtime error within the code implementing an interface for E-Document processing

        // [GIVEN] That we throw runtime error inside code that implements interface
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetThrowIntegrationLoggedError();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();
        EDocument.Get(EDocument."Entry No"); // Get after job queue run

        // [THEN] Verify that document is in error state
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnSendSyncLoggedErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Log error in send and check logs is correct 

        // [GIVEN] That we log an error inside code that implements interface
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetThrowIntegrationLoggedError();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        // [THEN] Status is Error on service, and document is error state
        EDocument.FindLast();
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnSendAsyncRuntimeFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Runtime failure in Send when send is async and check that Get Response is not invoked

        // [GIVEN] That we throw runtime error inside code that implements interface
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetThrowIntegrationRuntimeError();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocument.FindLast(); // Get after job queue run
        EDocumentServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        EDocumentServiceStatus.FindLast();

        // [THEN] Verify that document is in error state
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        // [WHEN] Get Response job queue is not run
        Assert.IsFalse(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnSendAsyncLoggedErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Logged error in Send when send is async and check that Get Response is not invoked

        // [GIVEN] That we log error inside code that implements interface
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetThrowIntegrationLoggedError();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        // [THEN] Verify that document is in error state
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"Error", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Sending Error");

        // [WHEN] Get Response job queue is not run
        Assert.IsFalse(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnGetResponseLoggedErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentLog: Record "E-Document Log";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Get Response implementation logs an error

        // [GIVEN] Setup
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.FindLast();
        EDocumentService.FindLast();
        EDocument.Get(EDocument."Entry No"); // Get after job queue run

        // [WHEN] error is logged inside get response
        EDocImplState.SetThrowIntegrationLoggedError();
        EDocImplState.SetOnGetResponseSuccess();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);
        UnbindSubscription(EDocImplState);

        EDocumentServiceStatus.FindLast();
        EDocumentService.FindLast();
        EDocument.FindLast();

        // [THEN] Document status is error
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        // [THEN] There are x logs
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.SetRange("Service Code", EDocumentService.Code);

        // Exported -> Pending Response -> Get Response -> Sending Error
        EDocumentLog.FindSet();
        Assert.AreEqual(Enum::"E-Document Service Status"::Exported, EDocumentLog.Status, IncorrectValueErr);
        EDocumentLog.Next();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentLog.Status, IncorrectValueErr);
        EDocumentLog.Next();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Sending Error", EDocumentLog.Status, IncorrectValueErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnGetResponseThrowErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentLog: Record "E-Document Log";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Get Response implementation throws a runtime error

        // [GIVEN] Setup
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        EDocumentServiceStatus.FindLast();
        EDocumentService.FindLast();
        EDocument.Get(EDocument."Entry No"); // Get after job queue run

        // [WHEN] error is logged inside get response
        EDocImplState.SetThrowIntegrationRuntimeError();
        EDocImplState.SetOnGetResponseSuccess();
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);
        UnbindSubscription(EDocImplState);

        EDocumentServiceStatus.FindLast();
        EDocumentService.FindLast();
        EDocument.FindLast();

        // [THEN] Document status is error
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentServiceStatus.Status::"Sending Error", EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::Error, EDocument.Status, IncorrectValueErr);

        // [THEN] There are x logs
        EDocumentLog.SetRange("E-Doc. Entry No", EDocument."Entry No");
        EDocumentLog.SetRange("Service Code", EDocumentService.Code);

        // Exported -> Pending Response -> Get Response -> Sending Error
        EDocumentLog.FindSet();
        Assert.AreEqual(Enum::"E-Document Service Status"::Exported, EDocumentLog.Status, IncorrectValueErr);
        EDocumentLog.Next();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Pending Response", EDocumentLog.Status, IncorrectValueErr);
        EDocumentLog.Next();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Sending Error", EDocumentLog.Status, IncorrectValueErr);
    end;

    [Test]
    procedure InterfaceOnGetResponseReturnFalseThenTrueSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Send and GetResponse has been executed.
        // We return false from GetReponse, meaning that we did not get response yet, hence we should continue to have job queue to get response later 
        // Finally we return true and document is marked Sent

        // [GIVEN] That IsASync is true, and OnGetReponse return false, then later true
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        Assert.IsTrue(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Pending Response on service, and document is in progress
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        Assert.IsTrue(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Pending Response on service, and document is in progress
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        EDocImplState.SetOnGetResponseSuccess();

        // [WHEN] Executing Get Response succesfully 
        Assert.IsTrue(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Sent);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure InterfaceOnGetResponseReturnTrueSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Send and GetResponse has been executed.
        // We return true from GetReponse, meaning that we did get response yet, hence we should mark document as sent

        // [GIVEN] That IsASync is true, and OnGetReponse return true 
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Sent");

        // [THEN] We get reponse job queue has been removed
        Assert.IsFalse(JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response"), IncorrectValueErr);
        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
    procedure InterfaceOnGetApprovalReturnFalseSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Get Approval has been executed.

        // [GIVEN] That IsASync is true, and OnGetReponse return true and GetApproval returns false
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Sent);

        // [THEN] User click get approval
        EDocumentService.FindLast();
        LibraryVariableStorage.Enqueue(EDocumentService);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();

        // Impl by EDocServicesPageHandler

        // Currently not checked as fix is needed on get approval when returning false
        // [THEN] Status is Pending Response on service, and document is in progress
        // VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Error, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Rejected);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
    procedure InterfaceOnGetApprovalReturnTrueSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Get Approval has been executed.
        // Get approval returns true. This means that document was approved

        // [GIVEN] That IsASync is true, and OnGetReponse and GetApproval returns true
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();
        EDocImplState.SetOnGetApprovalSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Sent);

        // [THEN] User click get approval
        EDocumentService.FindLast();
        LibraryVariableStorage.Enqueue(EDocumentService);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();

        // Impl by EDocServicesPageHandler

        // [THEN] Status is Processed on service, and document is in Approved
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Approved);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
    procedure InterfaceOnGetApprovalThrowErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Get Approval has been executed when a runtime error occured inside
        // Inside GetApproval an runtime error has been thrown by implementation
        // TODO: We fix that erros should do something

        // [GIVEN] That IsASync is true, and OnGetReponse and GetApproval returns true  
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();
        EDocImplState.SetOnGetApprovalSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Sent);

        // [THEN] User click get approval
        EDocImplState.SetThrowIntegrationLoggedError();
        EDocumentService.FindLast();
        LibraryVariableStorage.Enqueue(EDocumentService);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();

        // Impl by EDocServicesPageHandler

        // [THEN] Status is Processed on service, and document is in Approved
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Approved);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
    procedure InterfaceOnGetApprovalLoggedErrorFailure()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        JobQueueEntry: Record "Job Queue Entry";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document to async service. Test state after Get Approval has been executed.
        // Inside GetApproval an error has been logged by implementation 
        // TODO: We fix that erros should do something

        // [GIVEN] That IsASync is true, and OnGetReponse and GetApproval returns true  
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();
        EDocImplState.SetOnGetApprovalSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        // [WHEN] Executing Get Response succesfully 
        JobQueueEntry.FindJobQueueEntry(JobQueueEntry."Object Type to Run"::Codeunit, Codeunit::"E-Document Get Response");
        LibraryJobQueue.RunJobQueueDispatcher(JobQueueEntry);

        // [THEN] Status is Processed on service, and document is in sent
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Sent);

        // [THEN] User click get approval
        EDocImplState.SetThrowIntegrationLoggedError();
        EDocumentService.FindLast();
        LibraryVariableStorage.Enqueue(EDocumentService);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        EDocumentPage.GetApproval.Invoke();

        // Impl by EDocServicesPageHandler

        // [THEN] Status is Processed on service, and document is in Approved
        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::Processed, EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::Approved);

        UnbindSubscription(EDocImplState);
    end;


    // UI Tests

    [Test]
    [HandlerFunctions('EDocServicesPageHandler')]
    procedure UIClickSendInWhenPendingResponseSuccess()
    var
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPage: TestPage "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Clicking Send on E-Document should only be allowed on "Sending Error" And "Exported".

        // [GIVEN]
        Initialize();
        BindSubscription(EDocImplState);
        EDocImplState.SetIsAsync();
        EDocImplState.SetOnGetResponseSuccess();

        // [WHEN] Team member post invoice
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);
        EDocument.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocument.RecordId);

        VerifyStatusOnDocumentAndService(EDocument, Enum::"E-Document Status"::"In Progress", EDocumentService, EDocumentServiceStatus, Enum::"E-Document Service Status"::"Pending Response");

        EDocumentService.FindLast();
        LibraryVariableStorage.Enqueue(EDocumentService);
        EDocumentPage.OpenView();
        EDocumentPage.GoToRecord(EDocument);
        asserterror EDocumentPage.Send.Invoke();
        Assert.ExpectedError(SendingErrStateErr);

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure PostDocumentNoDefaultOrElectronicProfile()
    var
        DocumentSendingProfile: Record "Document Sending Profile";
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] Post document without having default or Electronic sending profile
        Initialize();

        if EDocument.FindLast() then
            EDocument.SetFilter("Entry No", '>%1', EDocument."Entry No");

        // [GIVEN] No default document sending profile
        DocumentSendingProfile.Reset();
        DocumentSendingProfile.DeleteAll();

        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.PostInvoice(Customer);

        // [THEN] No e-Document is created
        asserterror EDocument.FindLast();
        Assert.AssertNothingInsideFilter();

        // [GIVEN] Default document sending profile is not electronic
        DocumentSendingProfile.GetDefault(DocumentSendingProfile);
        DocumentSendingProfile."Electronic Service Flow" := 'NON-WORKFLOW';
        DocumentSendingProfile.Modify();

        // [THEN] No e-Document is created
        LibraryEDoc.PostInvoice(Customer);
        asserterror EDocument.FindLast();
        Assert.AssertNothingInsideFilter();
    end;

    [Test]
    procedure DeleteLinkedPurchaseHeaderNoAllowedSuccess()
    var
        PurchaseHeader: Record "Purchase Header";
        NullGuid: Guid;
    begin
        // [FEATURE] [E-Document] [Processing] 
        // [SCENARIO] 
        Initialize();

        // [GIVEN] PO with link
        LibraryPurchase.CreatePurchHeader(PurchaseHeader, PurchaseHeader."Document Type"::Invoice, LibraryPurchase.CreateVendorNo());
        PurchaseHeader."E-Document Link" := CreateGuid();
        PurchaseHeader.Modify();
        Commit();

        // [THEN] Fails to delete
        asserterror PurchaseHeader.Delete(true);
        Assert.ExpectedError(DeleteNotAllowedErr);

        // [GIVEN] Reset link 
        PurchaseHeader."E-Document Link" := NullGuid;
        PurchaseHeader.Modify();

        // [THEN] Delete ok
        PurchaseHeader.Delete();
    end;

    [ModalPageHandler]
    internal procedure EDocServicesPageHandler(var EDocServicesPage: TestPage "E-Document Services")
    var
        EDocumentService2: Record "E-Document Service";
        Variant: Variant;
    begin
        LibraryVariableStorage.Dequeue(Variant);
        EDocumentService2 := Variant;
        EDocServicesPage.GoToRecord(EDocumentService2);
        EDocServicesPage.OK().Invoke();
    end;

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        Clear(EDocImplState);

        if IsInitialized then
            exit;

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::Mock, Enum::"E-Document Integration"::Mock);

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
        EDocument.DeleteAll();

        IsInitialized := true;
    end;

    local procedure VerifyStatusOnDocumentAndService(EDocument: Record "E-Document"; EDocStatus: Enum "E-Document Status"; EDocumentService: Record "E-Document Service"; EDocumentServiceStatus: Record "E-Document Service Status"; EDocServiceStatus: Enum "E-Document Service Status")
    begin
        EDocumentServiceStatus.FindLast();
        EDocumentService.FindLast();
        EDocument.FindLast();
        Assert.AreEqual(EDocument."Entry No", EDocumentServiceStatus."E-Document Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocumentServiceStatus."E-Document Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocServiceStatus, EDocumentServiceStatus.Status, IncorrectValueErr);
        Assert.AreEqual(EDocStatus, EDocument.Status, IncorrectValueErr);
    end;


}