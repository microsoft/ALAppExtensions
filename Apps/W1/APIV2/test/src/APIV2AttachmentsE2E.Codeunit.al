codeunit 139833 "APIV2 - Attachments E2E"
{
    // version Test,ERM,W1,All

    Subtype = Test;
    TestPermissions = Disabled;

    trigger OnRun()
    begin
        // [FEATURE] [Graph] [Attachment]
    end;

    var
        Assert: Codeunit "Assert";
        LibraryGraphMgt: Codeunit "Library - Graph Mgt";
        LibrarySales: Codeunit "Library - Sales";
        LibrarySmallBusiness: Codeunit "Library - Small Business";
        LibraryERM: Codeunit "Library - ERM";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryUtility: Codeunit "Library - Utility";
        LibraryAPIGeneralJournal: Codeunit "Library API - General Journal";
        GraphMgtJournal: Codeunit "Graph Mgt - Journal";
        AttachmentEntityBufferDocumentType: Enum "Attachment Entity Buffer Document Type";
        AttachmentServiceNameTxt: Label 'attachments';
        InvoiceServiceNameTxt: Label 'salesInvoices';
        PurchaseInvoiceServiceNameTxt: Label 'purchaseInvoices';
        ActionPostTxt: Label 'Microsoft.NAV.post';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';
        CreateIncomingDocumentErr: Label 'Cannot create incoming document.';
        CannotModifyKeyFieldErr: Label 'You cannot change the value of the key field %1.', Locked = true;
        JournalServiceNameTxt: Label 'journals';
        JournalLineServiceNameTxt: Label 'journalLines';

    [Test]
    procedure TestGetJournalLineAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateGenJournalLine(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Journal));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetGLEntryAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        GLEntryGuid: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        GLEntryGuid := CreateGLEntry(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GLEntryGuid, Format(AttachmentEntityBufferDocumentType::Journal));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetPostedInvoiceAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(DocumentId, Format(AttachmentEntityBufferDocumentType::"Sales Invoice"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetDraftInvoiceAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateDraftSalesInvoice(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Sales Invoice"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetDraftOrderAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateDraftSalesOrder(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Sales Order"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;


    [Test]
    procedure TestGetPostedPurchaseInvoiceAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreatePostedPurchaseInvoice(DocumentRecordRef, DocumentId);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(DocumentId, Format(AttachmentEntityBufferDocumentType::"Purchase Invoice"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetDraftPurchaseInvoiceAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateDraftPurchaseInvoice(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Purchase Invoice"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetQuoteAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateSalesQuote(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Sales Quote"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachment should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetJournalLineAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreateGenJournalLine(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetJournalAttachment()
    var
        GenJournalBatch: Record "Gen. Journal Batch";
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        JournalName: Code[10];
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        JournalName := LibraryUtility.GenerateRandomCode(GenJournalBatch.FieldNo(Name), Database::"Gen. Journal Batch");
        LibraryAPIGeneralJournal.EnsureGenJnlBatchExists(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName);
        GenJournalBatch.Get(GraphMgtJournal.GetDefaultJournalLinesTemplateName(), JournalName);

        CreateGenJournalLine(GenJournalBatch, DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoSubpages(Format(GenJournalBatch.SystemId), GetDocumentSystemId(DocumentRecordRef), Page::"APIV2 - Journals", JournalServiceNameTxt, JournalLineServiceNameTxt, AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachment should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetGLEntryAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreateGLEntry(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetPostedInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetDraftInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreateDraftSalesInvoice(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetDraftOrderAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreateDraftSalesOrder(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetQuoteAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Incoming Document Attachment table
        CreateSalesQuote(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
    end;

    [Test]
    procedure TestGetDraftPurchaseOrderAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateDraftPurchaseOrder(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Purchase Order"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestUpdateGenJournalLineAttachmentBinaryContent()
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        ExpectedBase64Content: Text;
        ActualBase64Content: Text;
    begin
        // [SCENARIO] User can update linked attachment binary content through the Attachment API.
        // [GIVEN] A linked attachment exists
        CreateGenJournalLine(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        GenerateRandomBinaryContent(TempBlob);
        ExpectedBase64Content := BlobToBase64String(TempBlob);
        Commit();

        // [WHEN] A PATCH request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment should exist in the response
        Assert.AreEqual('', ResponseText, 'Response should be empty');

        // [THEN] The content is correctly updated.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        ActualBase64Content := GetAttachmentBase64Content(IncomingDocumentAttachment);
        Assert.AreEqual(ExpectedBase64Content, ActualBase64Content, 'Wrong content');
    end;

    [Test]
    procedure TestUpdateGLEntryAttachmentBinaryContent()
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        ExpectedBase64Content: Text;
        ActualBase64Content: Text;
    begin
        // [SCENARIO] User can update linked attachment binary content through the Attachment API.
        // [GIVEN] A linked attachment exists
        CreateGLEntry(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        GenerateRandomBinaryContent(TempBlob);
        ExpectedBase64Content := BlobToBase64String(TempBlob);
        Commit();

        // [WHEN] A PATCH request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment should exist in the response
        Assert.AreEqual('', ResponseText, 'Response should be empty');

        // [THEN] The content is correctly updated.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        ActualBase64Content := GetAttachmentBase64Content(IncomingDocumentAttachment);
        Assert.AreEqual(ExpectedBase64Content, ActualBase64Content, 'Wrong content');
    end;

    [Test]
    procedure TestCreateJournalLineAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateGenJournalLine(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateGLEntryAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateGLEntry(DocumentRecordRef);
        TestCreateGLEAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreatePostedInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateDraftInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftSalesInvoice(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateDraftOrderAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftSalesOrder(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreatePostedPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedPurchaseInvoice(DocumentRecordRef, DocumentId);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateDraftPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseInvoice(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateDraftPurchaseOrderAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseOrder(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    local procedure TestCreateAttachment(var DocumentRecordRef: RecordRef)
    var
        DocumentId: Guid;
        DocumentType: Text;
    begin
        DocumentId := GetDocumentSystemId(DocumentRecordRef);
        DocumentType := GetDocumentType(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef, DocumentId, DocumentType);
    end;

    [Normal]
    local procedure TestCreateAttachment(var DocumentRecordRef: RecordRef; DocumentId: Guid; DocumentType: Text)
    var
        TempIncomingDocumentAttachment: Record "Incoming Document Attachment" temporary;
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        TempBlob: Codeunit "Temp Blob";
        AttachmentId: Text;
        ResponseText: Text;
        TargetURL: Text;
        AttachmentJSON: Text;
    begin
        // [SCENARIO] Create an Attachment through a POST method and check if it was created
        // [GIVEN] The user has constructed an Attachment JSON object to send to the service.
        FindOrCreateIncomingDocument(DocumentRecordRef, IncomingDocument);
        CreateIncomingDocumentAttachment(IncomingDocument, TempIncomingDocumentAttachment);
        TempBlob.FromRecord(TempIncomingDocumentAttachment, TempIncomingDocumentAttachment.FieldNo(Content));
        AttachmentJSON := GetAttachmentJSON(DocumentId, DocumentType, TempIncomingDocumentAttachment, false);
        Commit();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, AttachmentJSON, ResponseText);
        // [WHEN] The user uploads binary content to the attachment
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment has been created in the database.
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'id');
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);

        if IncomingDocument.Posted then begin
            Assert.AreEqual(IncomingDocument."Document No.", IncomingDocumentAttachment."Document No.", '');
            Assert.AreEqual(IncomingDocument."Posting Date", IncomingDocumentAttachment."Posting Date", '');
        end;
        Assert.AreEqual(GetAttachmentBase64Content(IncomingDocumentAttachment), BlobToBase64String(TempBlob), 'Wrong Content');
    end;

    [Normal]
    local procedure TestCreateGLEAttachment(var DocumentRecordRef: RecordRef)
    var
        TempIncomingDocumentAttachment: Record "Incoming Document Attachment" temporary;
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        TempBlob: Codeunit "Temp Blob";
        GLEntryId: Guid;
        AttachmentId: Text;
        ResponseText: Text;
        TargetURL: Text;
        AttachmentJSON: Text;
    begin
        // [SCENARIO] Create an Attachment through a POST method and check if it was created
        // [GIVEN] The user has constructed an Attachment JSON object to send to the service.
        FindOrCreateIncomingDocument(DocumentRecordRef, IncomingDocument);
        GLEntryId := GetDocumentSystemId(DocumentRecordRef);
        CreateIncomingDocumentAttachment(IncomingDocument, TempIncomingDocumentAttachment);
        TempBlob.FromRecord(TempIncomingDocumentAttachment, TempIncomingDocumentAttachment.FieldNo(Content));
        AttachmentJSON := GetAttachmentJSON(GLEntryId, Format(AttachmentEntityBufferDocumentType::"Journal"), TempIncomingDocumentAttachment, false);
        Commit();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, AttachmentJSON, ResponseText);
        // [WHEN] The user uploads binary content to the attachment
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment has been created in the database.
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'id');
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);

        if IncomingDocument.Posted then begin
            Assert.AreEqual(IncomingDocument."Document No.", IncomingDocumentAttachment."Document No.", '');
            Assert.AreEqual(IncomingDocument."Posting Date", IncomingDocumentAttachment."Posting Date", '');
        end;
        Assert.AreEqual(GetAttachmentBase64Content(IncomingDocumentAttachment), BlobToBase64String(TempBlob), 'Wrong Content');
    end;

    [Test]
    procedure TestCreateQuoteAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateSalesQuote(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteJournalLineAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateGenJournalLine(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteGLEntryAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateGLEntry(DocumentRecordRef);
        TestDeleteGLEAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeletePostedInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        TestDeleteAttachment2(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteDraftInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftSalesInvoice(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeletePostedPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedPurchaseInvoice(DocumentRecordRef, DocumentId);
        TestDeleteAttachment2(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteDraftPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseInvoice(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteQuoteAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateSalesQuote(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    local procedure TestDeleteAttachment(var DocumentRecordRef: RecordRef)
    var
        DocumentId: Guid;
    begin
        DocumentId := GetDocumentSystemId(DocumentRecordRef);
        TestDeleteAttachment2(DocumentRecordRef);
    end;

    [Normal]
    local procedure TestDeleteAttachment2(var DocumentRecordRef: RecordRef)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete an Attachment by making a DELETE request.
        // [GIVEN] An Attachment exists.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] The user makes a DELETE request to the endpoint for the Attachment.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'DELETE response should be empty.');

        // [THEN] The Attachment is no longer in the database.
        Assert.IsFalse(IncomingDocumentAttachment.GetBySystemId(AttachmentId), 'The attachment should be deleted.');
    end;

    [Normal]
    local procedure TestDeleteGLEAttachment(var DocumentRecordRef: RecordRef)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        GLEntryId: Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete an Attachment by making a DELETE request.
        // [GIVEN] An Attachment exists.
        GLEntryId := GetDocumentSystemId(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] The user makes a DELETE request to the endpoint for the Attachment.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'DELETE response should be empty.');

        // [THEN] The Attachment is no longer in the database.
        Assert.IsFalse(IncomingDocumentAttachment.GetBySystemId(AttachmentId), 'The attachment should be deleted.');
    end;

    [Test]
    procedure TestTransferAttachmentFromDraftToPostedInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] The Attachment is transferred from a Draft Invoice the to Posted Invoice after posting.
        // [GIVEN] A draft sales invoice exists.
        CreateDraftSalesInvoice(DocumentRecordRef);
        DocumentId := GetDocumentId(DocumentRecordRef);

        // [GIVEN] An attacment is linked to the draft invoice.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] The invoice is posted through the Invoices API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, Page::"APIV2 - Sales Invoices", InvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] The Attachment exists and is correctly linked to the posted invoice.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        SalesInvoiceHeader.SetRange("Draft Invoice SystemId", DocumentId);
        SalesInvoiceHeader.FindFirst();
        DocumentRecordRef.GetTable(SalesInvoiceHeader);
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(SalesInvoiceHeader."No.", IncomingDocument."Document No.", 'Wrong Document No.');
        Assert.AreEqual(IncomingDocument."Document Type", IncomingDocument."Document Type"::"Sales Invoice", 'Wrong Document Type.');
        Assert.AreEqual(SalesInvoiceHeader.RecordId(), IncomingDocument."Related Record ID", 'Wrong Related Record ID.');
        Assert.AreEqual(IncomingDocument."Entry No.", IncomingDocumentAttachment."Incoming Document Entry No.", 'Wrong Entry No.');
    end;

    [Test]
    procedure TestTransferAttachmentFromDraftToPostedPurchaseInvoice()
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] The Attachment is transferred from a Draft Invoice the to Posted Invoice after posting.
        // [GIVEN] A draft sales invoice exists.
        CreateDraftPurchaseInvoice(DocumentRecordRef);
        DocumentId := GetDocumentId(DocumentRecordRef);

        // [GIVEN] An attacment is linked to the draft invoice.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] The invoice is posted through the Invoices API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, Page::"APIV2 - Purchase Invoices", PurchaseInvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] The Attachment exists and is correctly linked to the posted invoice.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        PurchInvHeader.SetRange("Draft Invoice SystemId", DocumentId);
        PurchInvHeader.FindFirst();
        DocumentRecordRef.GetTable(PurchInvHeader);
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(PurchInvHeader."No.", IncomingDocument."Document No.", 'Wrong Document No.');
        Assert.AreEqual(IncomingDocument."Document Type", IncomingDocument."Document Type"::"Purchase Invoice", 'Wrong Document Type.');
        Assert.AreEqual(PurchInvHeader.RecordId(), IncomingDocument."Related Record ID", 'Wrong Related Record ID.');
        Assert.AreEqual(IncomingDocument."Entry No.", IncomingDocumentAttachment."Incoming Document Entry No.", 'Wrong Entry No.');
    end;

    [Test]
    procedure TestLinkedAttachmentFileNameChangeKeepsOtherFieldsUnchanged()
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        JSONBody: Text;
        FileName: Text;
        OldBase64Content: Text;
        NewBase64Content: Text;
    begin
        // [SCENARIO] Changing an attachment file name keeps other fields unchanged
        // [GIVEN] A sales quote exists.
        CreateSalesQuote(DocumentRecordRef);
        DocumentId := GetDocumentId(DocumentRecordRef);

        // [GIVEN] A linked attachment exists.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        OldBase64Content := GetAttachmentBase64Content(IncomingDocumentAttachment);
        Commit();

        // [WHEN] The user changes the attachment file name by making a PATCH request
        FileName := StrSubstNo('%1.txt', FormatGuid(CreateGuid()));
        JSONBody := StrSubstNo('{"fileName":"%1"}', FileName);
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.PatchToWebService(TargetURL, JSONBody, ResponseText);

        // [THEN] The response text contains the new file name, other fields are not changed.
        VerifyPropertyInJSON(ResponseText, 'fileName', FileName);
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'parentId', DocumentId);

        // [THEN] The attachment content is not changed.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        NewBase64Content := GetAttachmentBase64Content(IncomingDocumentAttachment);
        Assert.AreEqual(OldBase64Content, NewBase64Content, 'Attachment content has been changed.');

        // [THEN] The response matches the attachment record in the database.
        VerifyAttachmentProperties(ResponseText, IncomingDocumentAttachment, NewBase64Content);
    end;

    [Test]
    procedure TestLinkedAttachmentContentChangeKeepsOtherFieldsUnchanged()
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        OldFileName: Text;
        NewFileName: Text;
    begin
        // [SCENARIO] Changing an attachment content keeps other fields unchanged
        // [GIVEN] A draft sales invoice exists.
        CreateDraftSalesInvoice(DocumentRecordRef);
        DocumentId := GetDocumentId(DocumentRecordRef);

        // [GIVEN] A linked attachment exists.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        OldFileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        IncomingDocumentAttachment.CALCFIELDS(Content);
        TempBlob.FromRecord(IncomingDocumentAttachment, IncomingDocumentAttachment.FieldNo(Content));
        Commit();

        // [WHEN] The user changes the attachment content by making a PATCH request
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The attachment name is not changed in the database.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        NewFileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        Assert.AreEqual(OldFileName, NewFileName, 'Attachment file name has been changed.');

        // [THEN] The attachment remains linked to the correct document.
        DocumentRecordRef.Find();
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(DocumentRecordRef.RecordId(), IncomingDocument."Related Record ID", 'The attachment is linked to a wrong document.');
    end;

    [Test]
    procedure TestLinkedAttachmentDocumentIdChangeNotAllowed()
    var
        DocumentRecordRef: array[2] of RecordRef;
        DocumentId: array[2] of Guid;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        JSONBody: Text;
    begin
        // [SCENARIO] User cannot change the attachment ID by making a PATCH request to the Attachments API
        // [GIVEN] Two documents exist.
        CreateSalesQuote(DocumentRecordRef[1]);
        CreateDraftSalesInvoice(DocumentRecordRef[2]);
        DocumentId[1] := GetDocumentId(DocumentRecordRef[1]);
        DocumentId[2] := GetDocumentId(DocumentRecordRef[2]);

        // [GIVEN] An attachment is linked to the first document.
        AttachmentId := CreateAttachment(DocumentRecordRef[1]);
        Commit();

        // [WHEN] The user changes the document ID by making a PATCH request
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Attachments", AttachmentServiceNameTxt);
        JSONBody := StrSubstNo('{"parentId":"%1"}', FormatGuid(DocumentId[2]));
        asserterror LibraryGraphMgt.PatchToWebService(TargetURL, JSONBody, ResponseText);

        // [THEN] Cannot change the document ID, expect error 400
        Assert.ExpectedError('400');
        Assert.ExpectedError(StrSubstNo(CannotModifyKeyFieldErr, 'parentId'));
    end;

    local procedure CreateDraftSalesInvoice(var DocumentRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);
    end;

    local procedure CreateDraftPurchaseOrder(var DocumentRecordRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseOrder(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);
    end;

    local procedure CreateDraftSalesOrder(var DocumentRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesOrder(SalesHeader);
        DocumentRecordRef.GetTable(SalesHeader);
    end;

    local procedure CreatePostedSalesInvoice(var DocumentRecordRef: RecordRef; var DocumentId: Guid)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        InvoiceCode: Code[20];
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        InvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, false, true);
        SalesInvoiceHeader.Get(InvoiceCode);
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";
        DocumentRecordRef.GetTable(SalesInvoiceHeader);
    end;

    local procedure CreateDraftPurchaseInvoice(var DocumentRecordRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);
    end;

    local procedure CreatePostedPurchaseInvoice(var DocumentRecordRef: RecordRef; var DocumentId: Guid)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        InvoiceCode: Code[20];
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        InvoiceCode := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        PurchInvHeader.Get(InvoiceCode);
        DocumentId := PurchInvHeader."Draft Invoice SystemId";
        DocumentRecordRef.GetTable(PurchInvHeader);
    end;

    local procedure CreateSalesQuote(var DocumentRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
    begin
        LibrarySmallBusiness.CreateCustomer(Customer);
        LibrarySmallBusiness.CreateSalesQuoteHeader(SalesHeader, Customer);
        DocumentRecordRef.GetTable(SalesHeader);
    end;

    local procedure CreateGenJournalLine(var DocumentRecordRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GenJournalTemplate: Record "Gen. Journal Template";
        GenJournalBatch: Record "Gen. Journal Batch";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.FindGenJournalTemplateWithGenName(GenJournalTemplate);
        LibraryERM.FindGenJournalBatch(GenJournalBatch, GenJournalTemplate.Name);
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalTemplate.Name, GenJournalBatch.Name,
          GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", 1);
        DocumentRecordRef.GetTable(GenJournalLine);
    end;

    local procedure CreateGenJournalLine(GenJournalBatch: Record "Gen. Journal Batch"; var DocumentRecordRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLAccount: Record "G/L Account";
    begin
        LibraryERM.CreateGLAccount(GLAccount);
        LibraryERM.CreateGeneralJnlLine(GenJournalLine, GenJournalBatch."Journal Template Name", GenJournalBatch.Name,
          GenJournalLine."Document Type"::" ", GenJournalLine."Account Type"::"G/L Account", GLAccount."No.", 1);
        DocumentRecordRef.GetTable(GenJournalLine);
    end;

    local procedure CreateGLEntry(var DocumentRecordRef: RecordRef): Guid
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        LibraryERM.CreateAndPostTwoGenJourLinesWithSameBalAccAndDocNo(GenJournalLine,
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), 1);
        GLEntry.SetCurrentKey("Entry No.");
        GLEntry.SetAscending("Entry No.", false);
        GLEntry.FindFirst();
        DocumentRecordRef.GetTable(GLEntry);
        exit(GLEntry.SystemId);
    end;


    local procedure CreateAttachments(var DocumentRecordRef: RecordRef; var AttachmentId: array[2] of Guid)
    var
        "Count": Integer;
    begin
        for Count := 1 to 2 do
            AttachmentId[Count] := CreateAttachment(DocumentRecordRef);
    end;

    local procedure GetDocumentSystemId(DocumentRecordRef: RecordRef): Guid
    var
        Id: Guid;
    begin
        Evaluate(Id, Format(DocumentRecordRef.Field(DocumentRecordRef.SystemIdNo()).Value()));
        exit(Id);
    end;

    local procedure GetDocumentType(DocumentRecordRef: RecordRef): Text
    var
        PurchaseHeader: Record "Purchase Header";
        SalesHeader: Record "Sales Header";
    begin
        case DocumentRecordRef.Number() of
            Database::"Sales Invoice Header":
                exit(Format(AttachmentEntityBufferDocumentType::"Sales Invoice"));
            Database::"Sales Header":
                begin
                    DocumentRecordRef.SetTable(SalesHeader);
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Quote then
                        exit(Format(AttachmentEntityBufferDocumentType::"Sales Quote"));
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Order then
                        exit(Format(AttachmentEntityBufferDocumentType::"Sales Order"));
                    if SalesHeader."Document Type" = SalesHeader."Document Type"::Invoice then
                        exit(Format(AttachmentEntityBufferDocumentType::"Sales Invoice"));
                end;
            Database::"Purch. Inv. Header":
                exit(Format(AttachmentEntityBufferDocumentType::"Purchase Invoice"));
            Database::"Purchase Header":
                begin
                    DocumentRecordRef.SetTable(PurchaseHeader);

                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
                        exit(Format(AttachmentEntityBufferDocumentType::"Purchase Invoice"));
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
                        exit(Format(AttachmentEntityBufferDocumentType::"Purchase Order"));
                end;
            Database::"Gen. Journal Line", Database::"G/L Entry":
                exit(Format(AttachmentEntityBufferDocumentType::"Journal"));
        end;
    end;


    local procedure GetDocumentId(var DocumentRecordRef: RecordRef): Guid
    var
        IdFieldRef: FieldRef;
        Id: Guid;
    begin
        IdFieldRef := DocumentRecordRef.Field(DocumentRecordRef.SystemIdNo());
        Evaluate(Id, Format(IdFieldRef.Value()));
        exit(Id);
    end;

    local procedure IsPostedDocument(var DocumentRecordRef: RecordRef): Boolean
    begin
        exit(
          (DocumentRecordRef.Number() = Database::"Sales Invoice Header") or (DocumentRecordRef.Number() = Database::"Purch. Inv. Header"));
    end;

    local procedure IsGeneralJournalLine(var DocumentRecordRef: RecordRef): Boolean
    begin
        exit(DocumentRecordRef.Number() = Database::"Gen. Journal Line");
    end;

    local procedure IsPurchaseInvoice(var DocumentRecordRef: RecordRef): Boolean
    begin
        if DocumentRecordRef.Number() = Database::"Purch. Inv. Header" then
            exit(true);
        if DocumentRecordRef.Number() = Database::"Purchase Header" then
            exit(true);
        exit(false);
    end;

    local procedure IsGLEntry(var DocumentRecordRef: RecordRef): Boolean
    begin
        exit(DocumentRecordRef.Number() = Database::"G/L Entry");
    end;

    local procedure FindIncomingDocument(var DocumentRecordRef: RecordRef; var IncomingDocument: Record "Incoming Document"): Boolean
    begin
        if IsPostedDocument(DocumentRecordRef) or IsGLEntry(DocumentRecordRef) then
            exit(IncomingDocument.FindByDocumentNoAndPostingDate(DocumentRecordRef, IncomingDocument));
        exit(IncomingDocument.FindFromIncomingDocumentEntryNo(DocumentRecordRef, IncomingDocument));
    end;

    local procedure FindOrCreateIncomingDocument(var DocumentRecordRef: RecordRef; var IncomingDocument: Record "Incoming Document"): Boolean
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
        PurchaseHeader: Record "Purchase Header";
        PurchInvHeader: Record "Purch. Inv. Header";
    begin
        if FindIncomingDocument(DocumentRecordRef, IncomingDocument) then
            exit(true);

        IncomingDocument.Init();
        IncomingDocument."Related Record ID" := DocumentRecordRef.RecordId();

        if DocumentRecordRef.Number() = Database::"Sales Invoice Header" then begin
            DocumentRecordRef.SetTable(SalesInvoiceHeader);
            IncomingDocument.Description := CopyStr(SalesInvoiceHeader."Sell-to Customer Name", 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Sales Invoice";
            IncomingDocument."Document No." := SalesInvoiceHeader."No.";
            IncomingDocument."Posting Date" := SalesInvoiceHeader."Posting Date";
            IncomingDocument.Posted := true;
            IncomingDocument.Insert(true);
            IncomingDocument.Find();
            exit(true);
        end;

        if IsGeneralJournalLine(DocumentRecordRef) then begin
            DocumentRecordRef.SetTable(GenJournalLine);
            IncomingDocument.Description := CopyStr(GenJournalLine.Description, 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::Journal;
            IncomingDocument.Insert(true);
            GenJournalLine."Incoming Document Entry No." := IncomingDocument."Entry No.";
            GenJournalLine.Modify();
            DocumentRecordRef.GetTable(GenJournalLine);
            exit(true);
        end;

        if IsGLEntry(DocumentRecordRef) then begin
            DocumentRecordRef.SetTable(GLEntry);
            IncomingDocument.Description := CopyStr(GLEntry.Description, 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument."Document No." := GLEntry."Document No.";
            IncomingDocument."Posting Date" := GLEntry."Posting Date";
            IncomingDocument.Status := IncomingDocument.Status::Posted;
            IncomingDocument.Posted := true;
            IncomingDocument.Insert(true);
            exit(true);
        end;

        if DocumentRecordRef.Number() = Database::"Sales Header" then begin
            DocumentRecordRef.SetTable(SalesHeader);
            IncomingDocument.Description := CopyStr(SalesHeader."Sell-to Customer Name", 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Sales Invoice";
            IncomingDocument."Document No." := SalesHeader."No.";
            IncomingDocument.Insert(true);
            IncomingDocument.Find();
            SalesHeader.Find();
            SalesHeader."Incoming Document Entry No." := IncomingDocument."Entry No.";
            SalesHeader.Modify();
            DocumentRecordRef.GetTable(SalesHeader);
            exit(true);
        end;

        if IsPurchaseInvoice(DocumentRecordRef) and IsPostedDocument(DocumentRecordRef) then begin
            DocumentRecordRef.SetTable(PurchInvHeader);
            IncomingDocument.Description := CopyStr(PurchInvHeader."Buy-from Vendor Name", 1, MaxStrLen(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Purchase Invoice";
            IncomingDocument."Document No." := PurchInvHeader."No.";
            IncomingDocument."Posting Date" := PurchInvHeader."Posting Date";
            IncomingDocument."Posted Date-Time" := CurrentDateTime();
            IncomingDocument.Status := IncomingDocument.Status::Posted;
            IncomingDocument.Posted := true;
            IncomingDocument.Insert(true);
            exit(true);
        end;

        if DocumentRecordRef.Number() = Database::"Purchase Header" then begin
            DocumentRecordRef.SetTable(PurchaseHeader);
            IncomingDocument.Description := CopyStr(PurchaseHeader."Buy-from Vendor Name", 1, MaxStrLen(IncomingDocument.Description));
            if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
                IncomingDocument."Document Type" := IncomingDocument."Document Type"::" ";
            if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
                IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Purchase Invoice";
            IncomingDocument."Document No." := PurchaseHeader."No.";
            IncomingDocument.Insert(true);
            PurchaseHeader.Find();
            PurchaseHeader."Incoming Document Entry No." := IncomingDocument."Entry No.";
            PurchaseHeader.Modify();
            DocumentRecordRef.GetTable(PurchaseHeader);
            exit(true);
        end;
    end;

    local procedure CreateAttachment(var DocumentRecordRef: RecordRef): Guid
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        if not FindOrCreateIncomingDocument(DocumentRecordRef, IncomingDocument) then
            Error(CreateIncomingDocumentErr);

        CreateIncomingDocumentAttachment(IncomingDocument, IncomingDocumentAttachment);
        IncomingDocumentAttachment.Insert(true);
        exit(IncomingDocumentAttachment.SystemId);
    end;

    local procedure CreateIncomingDocumentAttachment(var IncomingDocument: Record "Incoming Document"; var IncomingDocumentAttachment: Record "Incoming Document Attachment")
    var
        LastUsedIncomingDocumentAttachment: Record "Incoming Document Attachment";
        OutStream: OutStream;
        LineNo: Integer;
    begin
        LastUsedIncomingDocumentAttachment.SetRange("Incoming Document Entry No.", IncomingDocument."Entry No.");
        if not LastUsedIncomingDocumentAttachment.FindLast() then
            LineNo := 10000
        else
            LineNo := LastUsedIncomingDocumentAttachment."Line No." + 10000;

        IncomingDocumentAttachment.Init();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment."Line No." := LineNo;
        IncomingDocumentAttachment.Name :=
          CopyStr(FormatGuid(CreateGuid()), 1, MaxStrLen(IncomingDocumentAttachment.Name));
        IncomingDocumentAttachment.Type := IncomingDocumentAttachment.Type::Other;
        IncomingDocumentAttachment."File Extension" := 'txt';
        IncomingDocumentAttachment.Content.CREATEOUTSTREAM(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(FormatGuid(CreateGuid()));
    end;

    [Normal]
    local procedure GetAndVerifyIDFromJSON(ResponseText: Text; Id: array[2] of Guid)
    var
        JSON: array[2] of Text;
    begin
        Assert.IsTrue(
          LibraryGraphMgt
          .GetObjectsFromJSONResponse(
            ResponseText, 'id', FormatGuid(Id[1]), FormatGuid(Id[2]), JSON[1], JSON[2]),
          'Could not find the Attachment in JSON');
    end;

    local procedure GetAttachmentJSON(DocumentId: Guid; DocumentType: Text; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; IncludeID: Boolean) AttachmentJSON: Text
    var
        FileName: Text;
    begin
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON('', 'parentId', FormatGuid(DocumentId));
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'parentType', DocumentType);

        if IncludeID then
            AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'id', FormatGuid(IncomingDocumentAttachment.SystemId));

        FileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'fileName', FileName);
    end;

    local procedure GetAttachmentBase64Content(var IncomingDocumentAttachment: Record "Incoming Document Attachment") Base64Content: Text
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        TempBlob.FromRecord(IncomingDocumentAttachment, IncomingDocumentAttachment.FieldNo(Content));
        Base64Content := BlobToBase64String(TempBlob);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyAttachmentProperties(AttachmentJSON: Text; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; ExpectedBase64Content: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
    begin
        Assert.AreNotEqual('', AttachmentJSON, EmptyJSONErr);
        if not IsNullGuid(IncomingDocumentAttachment.SystemId) then
            LibraryGraphMgt.VerifyGUIDFieldInJson(AttachmentJSON, 'id', IncomingDocumentAttachment.SystemId);
        FileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        VerifyPropertyInJSON(AttachmentJSON, 'fileName', FileName);
        TempBlob.FromRecord(IncomingDocumentAttachment, IncomingDocumentAttachment.FieldNo(Content));
        VerifyPropertyInJSON(AttachmentJSON, 'byteSize', Format(GetBlobLength(TempBlob), 0, 9));
        if ExpectedBase64Content <> '' then
            Assert.AreEqual(ExpectedBase64Content, GetAttachmentBase64Content(IncomingDocumentAttachment), 'Wrong content.');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        exit(LowerCase(LibraryGraphMgt.StripBrackets(Format(Value, 0, 9))));
    end;

    local procedure GenerateRandomBinaryContent(var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TextEncoding::UTF8);
        OutStream.WriteText(FormatGuid(CreateGuid()));
    end;

    local procedure BlobToBase64String(var TempBlob: Codeunit "Temp Blob"): Text
    var
        InStream: InStream;
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        Base64String: Text;
    begin
        if not TempBlob.HasValue() then
            exit('');
        TempBlob.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        COPYSTREAM(MemoryStream, InStream);
        Base64String := Convert.ToBase64String(MemoryStream.ToArray());
        MemoryStream.Close();
        exit(Base64String);
    end;

    local procedure GetBlobLength(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        InStream: InStream;
        MemoryStream: DotNet MemoryStream;
        ContentLength: Integer;
    begin
        if not TempBlob.HasValue() then
            exit(0);
        TempBlob.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        COPYSTREAM(MemoryStream, InStream);
        ContentLength := MemoryStream.Length();
        MemoryStream.Close();
        exit(ContentLength);
    end;

    local procedure CreateAttachmentsURLWithFilter(DocumentIdFilter: Guid; DocumentTypeFilter: Text): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Attachments", AttachmentServiceNameTxt);

        UrlFilter := '$filter=parentId eq ' + LibraryGraphMgt.StripBrackets(Format(DocumentIdFilter)) + ' and parentType eq ''' + DocumentTypeFilter + '''';

        if StrPos(TargetURL, '?') <> 0 then
            TargetURL := TargetURL + '&' + UrlFilter
        else
            TargetURL := TargetURL + '?' + UrlFilter;

        exit(TargetURL);
    end;

    local procedure NameAndExtensionToFileName(Name: Text[250]; Extension: Text[30]): Text
    begin
        if Extension <> '' then
            exit(StrSubstNo('%1.%2', Name, Extension));
        exit(Name);
    end;
}































































