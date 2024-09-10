codeunit 139616 "E-Doc Log Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        // [FEATURE] [E-Document]
        IsInitialized := false;
    end;

    var

        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryJobQueue: Codeunit "Library - Job Queue";
        IsInitialized: Boolean;
        IncorrectValueErr: Label 'Incorrect value found';
        FailLastEntryInBatch, ErrorInExport : Boolean;

    [Test]
    procedure CreateEDocumentSuccess()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
        EDocLog: Record "E-Document Log";
        EDocMappingLogs: Record "E-Doc. Mapping Log";
        CustomerNo, DocumentSendingProfile : Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument creation 

        // [GIVEN] Creating a EDocument from Sales Invoice 
        Initialize();
        CustomerNo := LibraryEDoc.CreateCustomerNoWithEDocSendingProfile(DocumentSendingProfile);
        LibraryEDoc.CreateSimpleFlow(DocumentSendingProfile, LibraryEDoc.CreateService());

        LibraryEDoc.CreateEDocumentFromSales(EDocument, CustomerNo);
        EDocLog.SetRange(Status, EDocLog.Status::Created);
        EDocLog.FindLast();
        SalesInvHeader.FindLast();

        // [THEN] Fields on document log is correctly 
        Assert.AreEqual(EDocument."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."No.", EDocLog."Document No.", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Entry No.", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Size", IncorrectValueErr);
        Assert.AreEqual('', EDocLog."Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Service Integration"::"No Integration", EDocLog."Service Integration", IncorrectValueErr);
        Assert.AreEqual(EDocLog.Status::Created, EDocLog.Status, IncorrectValueErr);
        Assert.AreEqual(EDocument.Status::"In Progress", EDocument.Status, IncorrectValueErr);

        // [THEN] No mapping logs are not created
        asserterror EDocMappingLogs.Get(EDocLog."Entry No.");
        Assert.AssertRecordNotFound();
    end;

    [Test]
    procedure ExportEDocNoMappingSuccess()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocExportMgt: Codeunit "E-Doc. Export";
        EDocLogTest: Codeunit "E-Doc Log Test";
        CustomerNo, DocumentSendingProfile, ServiceCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument export without mapping 
        // Expected Outcomes:
        // 1. An E-Document is successfully exported without mapping.
        // 2. Document log fields are correctly populated.
        // 3. E-Document Service Status is updated to "Exported."
        // 4. No mapping logs are created in this scenario.

        // [GIVEN] Exporting E-Document for service without mapping
        Initialize();
        CustomerNo := LibraryEDoc.CreateCustomerNoWithEDocSendingProfile(DocumentSendingProfile);
        ServiceCode := LibraryEDoc.CreateService();
        LibraryEDoc.CreateSimpleFlow(DocumentSendingProfile, ServiceCode);

        LibraryEDoc.CreateEDocumentFromSales(EDocument, CustomerNo);
        EDocumentService.Get(ServiceCode);
        BindSubscription(EDocLogTest);
        EDocExportMgt.ExportEDocument(EDocument, EDocumentService);
        UnbindSubscription(EDocLogTest);
        EDocLog.FindLast();
        SalesInvHeader.FindLast();
        EDocument.Get(EDocument."Entry No");

        // [THEN] Fields on document log is correctly 
        Assert.AreEqual(EDocument."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."No.", EDocLog."Document No.", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
        Assert.AreNotEqual(0, EDocLog."E-Doc. Data Storage Entry No.", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Size", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocLog."Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Service Integration"::Mock, EDocLog."Service Integration", IncorrectValueErr);
        Assert.AreEqual(EDocLog.Status::Exported, EDocLog.Status, IncorrectValueErr);

        // [THEN] EDoc Service Status is updated
        EDocServiceStatus.Get(EDocLog."E-Doc. Entry No", EDocLog."Service Code");
        Assert.AreEqual(EDocLog.Status, EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] No mapping logs are not created
        asserterror EDocMappingLog.Get(EDocLog."Entry No.");
        Assert.AssertRecordNotFound();
    end;

    [Test]
    procedure ExportEDocWithMappingSuccess()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocExportMgt: Codeunit "E-Doc. Export";
        EDocLogTest: Codeunit "E-Doc Log Test";
        CustomerNo, DocumentSendingProfile, ServiceCode : Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument export with mapping 
        // ---------------------------------------------------------------------------
        // [Expected Outcome]
        // [1] An E-Document is exported successfully with mapping.
        // [2] Document log fields are correctly populated.
        // [3] E-Document Service Status is updated to "Exported."
        // [4] A mapping log is correctly created.

        // [GIVEN] Exporting E-Document for service with mapping
        Initialize();
        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        CustomerNo := LibraryEDoc.CreateCustomerNoWithEDocSendingProfile(DocumentSendingProfile);
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule);
        LibraryEDoc.CreateSimpleFlow(DocumentSendingProfile, ServiceCode);

        LibraryEDoc.CreateEDocumentFromSales(EDocument, CustomerNo);
        EDocMapping."Table ID" := Database::"Sales Invoice Header";
        EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Name");
        EDocMapping.Modify();

        EDocumentService.Get(ServiceCode);
        BindSubscription(EDocLogTest);
        EDocExportMgt.ExportEDocument(EDocument, EDocumentService);
        UnBindSubscription(EDocLogTest);

        EDocLog.FindLast();
        SalesInvHeader.FindLast();
        EDocument.Get(EDocument."Entry No");

        // [THEN] Fields on document log is correctly 
        Assert.AreEqual(EDocument."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."No.", EDocLog."Document No.", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
        Assert.AreNotEqual(0, EDocLog."E-Doc. Data Storage Entry No.", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Size", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocLog."Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Service Integration"::Mock, EDocLog."Service Integration", IncorrectValueErr);
        Assert.AreEqual(EDocLog.Status::Exported, EDocLog.Status, IncorrectValueErr);

        // [THEN] EDoc Service Status is updated
        EDocServiceStatus.Get(EDocLog."E-Doc. Entry No", EDocLog."Service Code");
        Assert.AreEqual(EDocLog.Status, EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] Mapping log is correctly created
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        EDocMappingLog.FindSet();
        Assert.AreEqual(1, EDocMappingLog.Count(), IncorrectValueErr);
        Assert.AreEqual(EDocMapping."Table ID", EDocMappingLog."Table ID", IncorrectValueErr);
        Assert.AreEqual(EDocMapping."Field ID", EDocMappingLog."Field ID", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."Bill-to Name", EDocMappingLog."Find Value", IncorrectValueErr);
        Assert.AreEqual(TransformationRule.TransformText(SalesInvHeader."Bill-to Name"), EDocMappingLog."Replace Value", IncorrectValueErr);
    end;

    [Test]
    procedure ExportEDocFailure()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocumentA: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLogTest: Codeunit "E-Doc Log Test";
        ServiceCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument export when Create interface has errors
        // ---------------------------------------------------------------------------
        // [Expected Outcomes]
        // [1] Two logs should be created: one for document creation and another for the export error. 
        // [2] No data storage log entries should be generated.
        // [3] The document log fields should be accurately populated, indicating "Export Failed" status.
        // [4] The E-Doc Service Status should reflect the error status.
        // [5] No mapping logs should be generated as part of this scenario.

        // [GIVEN] Exporting E-Document with errors on edocument
        Initialize();
        BindSubscription(EDocLogTest); // Bind subscription to get events to insert into blobs
        EDocLogTest.SetExportError();

        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule, false);
        LibraryEDoc.CreateSimpleFlow(ServiceCode);
        EDocumentService.Get(ServiceCode);
        EDocumentService."Use Batch Processing" := false;
        EDocumentService.Modify();
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        // [WHEN] Post a documents
        LibraryEDoc.PostSalesDocument();
        EDocumentA.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentA.RecordId());

        // [THEN] Two logs are created and one data storage log is saved 
        EDocumentA.FindSet();
        Assert.RecordCount(EDocumentA, 1);

        // ( Created + Export Error ) * 2
        Assert.AreEqual(2, EDocLog.Count(), IncorrectValueErr);

        asserterror EDocDataStorage.FindSet();
        Assert.AreEqual(0, EDocDataStorage.Count(), IncorrectValueErr);

        EDocLog.FindLast();
        SalesInvHeader.Get(EDocumentA."Document No.");

        // [THEN] Fields on document log is correctly with 'Export Failed'
        Assert.AreEqual(EDocumentA."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
        Assert.AreEqual(SalesInvHeader."No.", EDocLog."Document No.", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Entry No.", IncorrectValueErr);
        Assert.AreEqual(0, EDocLog."E-Doc. Data Storage Size", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocLog."Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Service Integration"::Mock, EDocLog."Service Integration", IncorrectValueErr);
        Assert.AreEqual(EDocLog.Status::"Export Error", EDocLog.Status, IncorrectValueErr);

        // [THEN] EDoc Service Status is updated
        EDocServiceStatus.Get(EDocLog."E-Doc. Entry No", EDocLog."Service Code");
        Assert.AreEqual(EDocLog.Status, EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] Mapping log is not logged
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        asserterror EDocMappingLog.FindSet();
        Assert.AssertNothingInsideFilter();
    end;

    [Test]
    procedure ExportEDocBatchThresholdSuccess()
    var
        SalesInvHeader: Record "Sales Invoice Header";
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocumentA, EDocumentB : Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocLogTest: Codeunit "E-Doc Log Test";
        ServiceCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument batch export with mapping 
        // ---------------------------------------------------------------------------
        // [Expected Outcomes]
        // [1] 8 logs are created: one for each of the two posted documents.
        // [2] One data storage log entry is saved for each document, totaling two.
        // [3] Each log entry contains the correct information related to the document.
        // [4] The E-Doc Service Status is updated to "Sent" for each exported document.
        // [5] Mapping logs are correctly created, capturing mapping details.

        // [GIVEN] Exporting E-Documents for service with mapping
        Initialize();
        BindSubscription(EDocLogTest); // Bind subscription to get events to insert into blobs

        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule, true);
        LibraryEDoc.CreateSimpleFlow(ServiceCode);
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);
        EDocMapping."Table ID" := Database::"Sales Invoice Header";
        EDocMapping."Field ID" := SalesInvHeader.FieldNo("Bill-to Name");
        EDocMapping.Modify();

        LibraryVariableStorage.Clear();
        EDocLogTest.SetVariableStorage(LibraryVariableStorage);

        EDocumentService.Get(ServiceCode);
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 2;
        EDocumentService.Modify();

        // [WHEN] Post two documents
        LibraryEDoc.PostSalesDocument();
        EDocumentA.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentA.RecordId());

        LibraryEDoc.PostSalesDocument();
        EDocumentB.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentB.RecordId());

        // [THEN] 8 logs are created and one data storage log is saved 
        EDocumentA.FindSet();
        Assert.RecordCount(EDocumentA, 2);

        // ( Created + Pending + Exported + Sent ) * 2
        Assert.AreEqual(8, EDocLog.Count(), IncorrectValueErr);

        EDocDataStorage.FindSet();
        Assert.AreEqual(1, EDocDataStorage.Count(), IncorrectValueErr);
        Assert.AreEqual(4, EDocDataStorage."Data Storage Size", IncorrectValueErr);

        // [THEN] Each log contains correct information
        repeat
            EDocLog.SetRange("E-Doc. Entry No", EDocumentA."Entry No");
            EDocLog.SetRange(Status, EDocLog.Status::Exported);
            EDocLog.FindFirst();
            EDocLog.CalcFields("E-Doc. Data Storage Size");
            SalesInvHeader.Get(EDocumentA."Document No.");

            // [THEN] Fields on document log is correctly 
            Assert.AreEqual(EDocumentA."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
            Assert.AreEqual(SalesInvHeader."No.", EDocLog."Document No.", IncorrectValueErr);
            Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
            Assert.AreNotEqual(0, EDocLog."E-Doc. Data Storage Entry No.", IncorrectValueErr);
            Assert.AreEqual(4, EDocLog."E-Doc. Data Storage Size", IncorrectValueErr);
            Assert.AreEqual(EDocumentService.Code, EDocLog."Service Code", IncorrectValueErr);
            Assert.AreEqual(EDocLog."Service Integration"::Mock, EDocLog."Service Integration", IncorrectValueErr);
            Assert.AreEqual(EDocLog.Status::Exported, EDocLog.Status, IncorrectValueErr);

            // [THEN] EDoc Service Status is updated
            EDocServiceStatus.Get(EDocLog."E-Doc. Entry No", EDocLog."Service Code");
            Assert.AreEqual(EDocServiceStatus.Status::Sent, EDocServiceStatus.Status, IncorrectValueErr);

            // [THEN] Mapping log is correctly created
            EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
            EDocMappingLog.FindSet();
            Assert.AreEqual(1, EDocMappingLog.Count(), IncorrectValueErr);
            Assert.AreEqual(EDocMapping."Table ID", EDocMappingLog."Table ID", IncorrectValueErr);
            Assert.AreEqual(EDocMapping."Field ID", EDocMappingLog."Field ID", IncorrectValueErr);
            Assert.AreEqual(SalesInvHeader."Bill-to Name", EDocMappingLog."Find Value", IncorrectValueErr);
            Assert.AreEqual(TransformationRule.TransformText(SalesInvHeader."Bill-to Name"), EDocMappingLog."Replace Value", IncorrectValueErr);
        until EdocumentA.Next() = 0;
    end;

    [Test]
    procedure ExportEDocBatchThresholdFailure()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocumentA, EDocumentB : Record "E-Document";
        EDocumentService, EDocumentService2 : Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocLogTest: Codeunit "E-Doc Log Test";
        ServiceCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument threshold batch export when there is errors during export
        // ---------------------------------------------------------------------------
        // [Expected Outcomes]
        // [1] Initialize the test environment.
        // [2] Simulate an error in batch export by setting the last entry to error.
        // [3] Create E-Documents and a service with batch export settings (threshold: 2).
        // [4] Post two sales documents, both marked as export errors.
        // [5] Validate the state of Document A and B, including its logs and service status.
        // [6] Ensure no mapping logs or data storage is created for either document.

        // [GIVEN] A flow to send to service with threshold batch 
        Initialize();

        BindSubscription(EDocLogTest); // Bind subscription to get events to insert into blobs
        EDocLogTest.SetLastEntryInBatchToError(); // Make sure last entry in create batch fails

        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule, true);
        LibraryEDoc.CreateSimpleFlow(ServiceCode);
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.Get(ServiceCode);
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Threshold;
        EDocumentService."Batch Threshold" := 2;
        EDocumentService.Modify();

        // [WHEN] Post first documents
        LibraryEDoc.PostSalesDocument();
        EDocumentA.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentA.RecordId());

        // [THEN] First documents is pending batch for the service
        EDocServiceStatus.SetRange("E-Document Service Code", ServiceCode);
        EDocServiceStatus.SetRange(Status, EDocServiceStatus.Status::"Pending Batch");
        Assert.RecordCount(EDocServiceStatus, 1);

        // [WHEN] Post second document
        LibraryEDoc.PostSalesDocument();
        EDocumentB.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentB.RecordId());

        // [THEN] All documents are marked as export error
        EDocServiceStatus.SetRange("E-Document Service Code", ServiceCode);
        EDocServiceStatus.SetRange(Status, EDocServiceStatus.Status::"Export Error");
        Assert.RecordCount(EDocServiceStatus, 2);

        // CHECKS FOR DOCUMENT A (Export error)
        EDocumentA.Get(EDocumentA."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocumentA.Status, IncorrectValueErr);

        // [THEN] There are 3 logs for document that was successfully sent
        EDocLog.SetRange("E-Doc. Entry No", EDocumentA."Entry No");
        Assert.RecordCount(EDocLog, 3);

        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Export Error");

        // [THEN] Mapping log is not created
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        asserterror EDocMappingLog.FindSet();
        Assert.AssertNothingInsideFilter();

        // [THEN] No Data Storage created
        asserterror EDocDataStorage.Get(EDocLog."E-Doc. Data Storage Entry No.");

        // CHECKS FOR DOCUMENT B (EXPORT ERROR)
        EDocumentB.Get(EDocumentB."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocumentB.Status, IncorrectValueErr);

        // [THEN] There are 3 logs for document that failed during export
        EDocLog.SetRange("E-Doc. Entry No", EDocumentB."Entry No");
        EDocLog.SetRange(Status);
        Assert.RecordCount(EDocLog, 3);

        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Export Error");

        // [THEN] Mapping log is not created
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        asserterror EDocMappingLog.FindSet();
        Assert.AssertNothingInsideFilter();

        // [THEN] No Data Storage created
        asserterror EDocDataStorage.Get(EDocLog."E-Doc. Data Storage Entry No.");
    end;

    [Test]
    procedure ExportEDocBatchtRecurrentSuccess()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocumentA, EDocumentB : Record "E-Document";
        EDocumentService, EDocumentService2 : Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocLogTest: Codeunit "E-Doc Log Test";
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
        ServiceCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument when send in recurrent batch.
        // There are no errors during export for documents
        // ---------------------------------------------------------------------------
        // [Expected Outcomes]
        // [1] Initialize the test environment.
        // [2] Create E-Documents and a service with recurrent batch settings.
        // [3] Post two sales documents
        // [4] Validate the state of Document A, including logs and service status, after a successful export.
        // [5] Validate logs, data storage, and fields for Document A's successful export.
        // [6] Validate the state of Document A, including logs and service status, after a successful export.
        // [7] Validate logs, data storage, and fields for Document B's successful export.
        // [8] Ensure mapping logs are created.

        // [GIVEN] A flow to send to service with recurrent batch 
        Initialize();

        BindSubscription(EDocLogTest); // Bind subscription to get events to insert into blobs

        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule, true);
        LibraryEDoc.CreateSimpleFlow(ServiceCode);
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.Get(ServiceCode);
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Recurrent;
        EDocumentService."Batch Minutes between runs" := 1;
        EDocumentService."Batch Start Time" := Time();
        EDocumentService.Modify();

        // [WHEN] Post two documents
        LibraryEDoc.PostSalesDocument();
        EDocumentA.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentA.RecordId());

        LibraryEDoc.PostSalesDocument();
        EDocumentB.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentB.RecordId());

        // [THEN] Two documents are pending batch for the service
        EDocServiceStatus.SetRange("E-Document Service Code", ServiceCode);
        EDocServiceStatus.SetRange(Status, EDocServiceStatus.Status::"Pending Batch");
        Assert.RecordCount(EDocServiceStatus, 2);

        // [Given] Run recurrent batch job
        EDocumentBackgroundJobs.HandleRecurrentBatchJob(EDocumentService);
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentService.RecordId());

        // Document A is successfully processed
        EDocumentA.Get(EDocumentA."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocumentA.Status, IncorrectValueErr);

        // [THEN] EDocServiceStatus is set to Sent for Document A
        EDocServiceStatus.SetRange("E-Document Entry No", EDocumentA."Entry No");
        EDocServiceStatus.SetRange(Status);
        EDocServiceStatus.FindFirst();
        Assert.AreEqual(Enum::"E-Document Service Status"::Sent, EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] There are four logs for Document A that was successfully sent
        EDocLog.SetRange("E-Doc. Entry No", EDocumentA."Entry No");
        Assert.RecordCount(EDocLog, 4);

        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Exported");

        // [THEN] Mapping log exists for Exported log
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        EDocMappingLog.FindSet();

        // [THEN] Data storage is created for the exported document, and for temp blob at send
        // [THEN] Exported Blob has size 4
        EDocDataStorage.FindSet();
        Assert.AreEqual(1, EDocDataStorage.Count(), IncorrectValueErr);
        EDocDataStorage.Get(EDocLog."E-Doc. Data Storage Entry No.");
        Assert.AreEqual(4, EDocDataStorage."Data Storage Size", IncorrectValueErr);

        // [THEN] Fields on document log is correctly for Sent log
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Sent");
        EDocLog.SetRange(Status);

        // Document B is processed
        EDocumentB.Get(EDocumentB."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocumentB.Status, IncorrectValueErr);

        // [THEN] EDocServiceStatus is set to sent for Document B
        EDocServiceStatus.SetRange("E-Document Entry No", EDocumentB."Entry No");
        EDocServiceStatus.FindFirst();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Sent", EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] There are 3 logs for document B
        EDocLog.SetRange("E-Doc. Entry No", EDocumentB."Entry No");
        Assert.RecordCount(EDocLog, 4);

        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Exported");

        // [THEN] Mapping log exists for Exported log
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        EDocMappingLog.FindSet();

        // [THEN] Data storage is created for document B, and for temp blob at send
        // [THEN] Exported Blob has size 4
        EDocDataStorage.FindSet();
        Assert.AreEqual(1, EDocDataStorage.Count(), IncorrectValueErr);
        EDocDataStorage.Get(EDocLog."E-Doc. Data Storage Entry No.");
        Assert.AreEqual(4, EDocDataStorage."Data Storage Size", IncorrectValueErr);

        // [THEN] Fields on document B log is correctly for Sent log
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Sent");
        EDocLog.SetRange(Status);
    end;

    [Test]
    procedure ExportEDocBatchtRecurrentFailure()
    var
        EDocMapping: Record "E-Doc. Mapping";
        TransformationRule: Record "Transformation Rule";
        EDocumentA, EDocumentB : Record "E-Document";
        EDocumentService, EDocumentService2 : Record "E-Document Service";
        EDocServiceStatus: Record "E-Document Service Status";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLog: Record "E-Document Log";
        EDocMappingLog: Record "E-Doc. Mapping Log";
        EDocLogTest: Codeunit "E-Doc Log Test";
        EDocumentBackgroundJobs: Codeunit "E-Document Background Jobs";
        ServiceCode: Code[20];
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument recurrent batch when there is errors during export for a document
        // ---------------------------------------------------------------------------
        // [Expected Outcomes]
        // [1] Initialize the test environment.
        // [2] Simulate an error in batch export by setting the last entry to error.
        // [3] Create E-Documents and a service with recurrent batch settings.
        // [4] Post two sales documents, one successfully processed and one marked as an export error.
        // [5] Validate the state of Document A, including logs and service status, after a successful export.
        // [6] Validate logs, data storage, and fields for Document A's successful export.
        // [7] Validate the state of Document B, marked as an export error.
        // [8] Validate logs, data storage, and fields for Document B's export error.
        // [9] Ensure no mapping logs are created.

        // [GIVEN] A flow to send to service with recurrent batch 
        Initialize();

        BindSubscription(EDocLogTest); // Bind subscription to get events to insert into blobs
        EDocLogTest.SetLastEntryInBatchToError(); // Make sure last entry in create batch fails

        TransformationRule.Get(TransformationRule.GetLowercaseCode());
        ServiceCode := LibraryEDoc.CreateServiceWithMapping(EDocMapping, TransformationRule, true);
        LibraryEDoc.CreateSimpleFlow(ServiceCode);
        LibraryJobQueue.SetDoNotHandleCodeunitJobQueueEnqueueEvent(true);

        EDocumentService.Get(ServiceCode);
        EDocumentService."Batch Mode" := EDocumentService."Batch Mode"::Recurrent;
        EDocumentService."Batch Minutes between runs" := 1;
        EDocumentService."Batch Start Time" := Time();
        EDocumentService.Modify();

        // [WHEN] Post two documents
        LibraryEDoc.PostSalesDocument();
        EDocumentA.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentA.RecordId());

        LibraryEDoc.PostSalesDocument();
        EDocumentB.FindLast();
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentB.RecordId());

        // [THEN] Two documents are pending batch for the service
        EDocServiceStatus.SetRange("E-Document Service Code", ServiceCode);
        EDocServiceStatus.SetRange(Status, EDocServiceStatus.Status::"Pending Batch");
        Assert.RecordCount(EDocServiceStatus, 2);

        // [Given] Run recurrent batch job
        EDocumentBackgroundJobs.HandleRecurrentBatchJob(EDocumentService);
        LibraryJobQueue.FindAndRunJobQueueEntryByRecordId(EDocumentService.RecordId());

        // Document A is successfully processed
        EDocumentA.Get(EDocumentA."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Processed, EDocumentA.Status, IncorrectValueErr);

        // [THEN] EDocServiceStatus is set to Sent for Document A
        EDocServiceStatus.SetRange("E-Document Entry No", EDocumentA."Entry No");
        EDocServiceStatus.SetRange(Status);
        EDocServiceStatus.FindFirst();
        Assert.AreEqual(Enum::"E-Document Service Status"::Sent, EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] There are four logs for Document A that was successfully sent
        EDocLog.SetRange("E-Doc. Entry No", EDocumentA."Entry No");
        Assert.RecordCount(EDocLog, 4);

        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Exported");

        // [THEN] Mapping log is correctly created for Exported log
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        EDocMappingLog.FindSet();

        // [THEN] Data storage is created for the exported document, and for temp blob at send
        // [THEN] Exported Blob has size 4
        EDocDataStorage.FindSet();
        Assert.AreEqual(1, EDocDataStorage.Count(), IncorrectValueErr);
        EDocDataStorage.Get(EDocLog."E-Doc. Data Storage Entry No.");
        Assert.AreEqual(4, EDocDataStorage."Data Storage Size", IncorrectValueErr);

        // [THEN] Fields on document log is correctly for Sent log
        AssertEDocLogState(EDocumentA, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Sent");

        // Document B has gotten an error
        EDocumentB.Get(EDocumentB."Entry No");
        Assert.AreEqual(Enum::"E-Document Status"::Error, EDocumentB.Status, IncorrectValueErr);

        // [THEN] EDocServiceStatus is set to Export Error for Document B
        EDocServiceStatus.SetRange("E-Document Entry No", EDocumentB."Entry No");
        EDocServiceStatus.FindFirst();
        Assert.AreEqual(Enum::"E-Document Service Status"::"Export Error", EDocServiceStatus.Status, IncorrectValueErr);

        // [THEN] There are 3 logs for document that failed during export
        EDocLog.SetRange("E-Doc. Entry No", EDocumentB."Entry No");
        EDocLog.SetRange(Status);
        Assert.RecordCount(EDocLog, 3);

        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService2, Enum::"E-Document Service Status"::Created);
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Pending Batch");
        AssertEDocLogState(EDocumentB, EDocLog, EDocumentService, Enum::"E-Document Service Status"::"Export Error");

        // [THEN] Mapping log is not created
        EDocMappingLog.SetRange("E-Doc Log Entry No.", EDocLog."Entry No.");
        asserterror EDocMappingLog.FindSet();
        Assert.AssertNothingInsideFilter();
    end;

    [Test]
    procedure IntegrationLogs()
    var
        EDocument: Record "E-Document";
        EDocumentService: Record "E-Document Service";
        EDocumentLogRec: Record "E-Document Log";
        EDocumentIntegrationLog: Record "E-Document Integration Log";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentLog: Codeunit "E-Document Log";
        TempBlob: Codeunit "Temp Blob";
        HttpRequest: HttpRequestMessage;
        HttpResponse: HttpResponseMessage;
    begin
        // [FEATURE] [E-Document] [Log]
        // [SCENARIO] EDocument Log on EDocument recurrent batch when there is errors during export for a document
        // [GIVEN]
        InitIntegrationData(EDocument, EDocumentService, EDocumentServiceStatus, HttpRequest, HttpResponse);

        // [WHEN] Inserting integration logs
        EDocumentLog.InsertLogWithIntegration(EDocumentServiceStatus, HttpRequest, HttpResponse);

        // [THEN] It should insert EDocumentLog and EDocument integration log.
        Assert.IsTrue(EDocumentLogRec.FindFirst(), 'There should be an edocument log entry');
        Assert.IsTrue(EDocumentIntegrationLog.FindFirst(), 'There should be an edocument integration log entry');
        Assert.AreEqual(EDocumentIntegrationLog."E-Doc. Entry No", EDocument."Entry No", 'EDocument integration log should be linked to edocument');
        Assert.AreEqual(HttpRequest.Method(), EDocumentIntegrationLog.Method, 'Integration log should contain method type from request message');
        Assert.AreEqual(HttpRequest.GetRequestUri(), EDocumentIntegrationLog."Request URL", 'Integration log should contain url from request message');

        EDocumentIntegrationLog.CalcFields("Request Blob");
        EDocumentIntegrationLog.CalcFields("Response Blob");

        TempBlob.FromRecord(EDocumentIntegrationLog, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Request Blob"));
        Assert.AreEqual('Test request', LibraryEDoc.TempBlobToTxt(TempBlob), 'Integration log request blob is not correct');

        Clear(TempBlob);
        TempBlob.FromRecord(EDocumentIntegrationLog, EDocumentIntegrationLog.FieldNo(EDocumentIntegrationLog."Response Blob"));
        Assert.AreEqual('Test response', LibraryEDoc.TempBlobToTxt(TempBlob), 'Integration log response blob is not correct');
    end;

    local procedure InitIntegrationData(var EDocument: Record "E-Document"; var EDocumentService: Record "E-Document Service"; var EDocumentServiceStatus: Record "E-Document Service Status"; HttpRequest: HttpRequestMessage; HttpResponse: HttpResponseMessage)
    var
        EDocumentIntegrationLog: Record "E-Document Integration Log";
    begin
        EDocument.DeleteAll();
        EDocumentService.DeleteAll();
        EDocumentIntegrationLog.DeleteAll();
        HttpRequest.SetRequestUri('http://cronus.test');
        HttpRequest.Method := 'POST';

        HttpRequest.Content.WriteFrom('Test request');
        HttpResponse.Content.WriteFrom('Test response');
        HttpResponse.Headers.Add('Accept', '*');

        EDocument.Insert();
        EDocumentService.Code := 'Test Service 1';
        EDocumentService."Service Integration" := EDocumentService."Service Integration"::Mock;
        EDocumentService.Insert();

        EDocumentServiceStatus."E-Document Entry No" := EDocument."Entry No";
        EDocumentServiceStatus."E-Document Service Code" := EDocumentService.Code;
        EDocumentServiceStatus.Insert();
    end;

    local procedure AssertEDocLogState(var EDocument: Record "E-Document"; var EDocLog: Record "E-Document Log"; var EDocumentService: Record "E-Document Service"; Status: Enum "E-Document Service Status")
    begin
        EDocLog.SetRange(Status, Status);
        Assert.RecordCount(EDocLog, 1);
        EDocLog.FindFirst();
        AssertLogValues(EDocument, EDocLog, EDocumentService, Status);
    end;

    local procedure AssertLogValues(var EDocument: Record "E-Document"; var EDocLog: Record "E-Document Log"; var EDocumentService: Record "E-Document Service"; Status: Enum "E-Document Service Status")
    begin
        Assert.AreEqual(EDocument."Entry No", EDocLog."E-Doc. Entry No", IncorrectValueErr);
        Assert.AreEqual(EDocLog."Document Type"::"Sales Invoice", EDocLog."Document Type", IncorrectValueErr);
        Assert.AreEqual(EDocumentService.Code, EDocLog."Service Code", IncorrectValueErr);
        Assert.AreEqual(EDocumentService."Service Integration", EDocLog."Service Integration", IncorrectValueErr);
        Assert.AreEqual(Status, EDocLog.Status, IncorrectValueErr);
    end;

    local procedure Initialize()
    var
        TransformationRule: Record "Transformation Rule";
        SalesInvHeader: Record "Sales Invoice Header";
    begin
        IsInitialized := true;
        ErrorInExport := false;
        FailLastEntryInBatch := false;
        LibraryEDoc.Initialize();

        LibraryVariableStorage.Clear();
        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();

        SalesInvHeader.DeleteAll();
    end;

    procedure SetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        LibraryVariableStorage := NewLibraryVariableStorage;
    end;

    procedure GetVariableStorage(var NewLibraryVariableStorage: Codeunit "Library - Variable Storage")
    begin
        NewLibraryVariableStorage := LibraryVariableStorage;
    end;

    procedure SetLastEntryInBatchToError()
    begin
        FailLastEntryInBatch := true;
    end;

    procedure SetExportError()
    begin
        ErrorInExport := true;
    end;

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
    begin
        LibraryVariableStorage.Enqueue(SourceDocumentHeader);
        LibraryVariableStorage.Enqueue(EDocService);
        LibraryVariableStorage.Enqueue(EDocumentProcessingPhase);
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreate', '', false, false)]
    local procedure OnCreate(EDocService: Record "E-Document Service"; var EDocument: Record "E-Document"; var SourceDocumentHeader: RecordRef; var SourceDocumentLines: RecordRef; var TempBlob: codeunit "Temp Blob")
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('TEST');
        LibraryVariableStorage.Enqueue(TempBlob.Length());

        if ErrorInExport then
            EDocErrorHelper.LogSimpleErrorMessage(EDocument, 'ERROR');
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"E-Doc. Format Mock", 'OnCreateBatch', '', false, false)]
    local procedure OnCreateBatch(EDocService: Record "E-Document Service"; var EDocuments: Record "E-Document"; var SourceDocumentHeaders: RecordRef; var SourceDocumentsLines: RecordRef; var TempBlob: codeunit "Temp Blob");
    var
        EDocErrorHelper: Codeunit "E-Document Error Helper";
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        OutStream.WriteText('TEST');
        LibraryVariableStorage.Enqueue(TempBlob.Length());

        if FailLastEntryInBatch then begin
            EDocuments.FindLast();
            EDocErrorHelper.LogSimpleErrorMessage(EDocuments, 'ERROR');
        end;
    end;
}