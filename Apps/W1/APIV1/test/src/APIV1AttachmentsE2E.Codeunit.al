codeunit 139733 "APIV1 - Attachments E2E"
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
        AttachmentServiceNameTxt: Label 'attachments';
        GLEntryAttachmentServiceNameTxt: Label 'generalLedgerEntryAttachments';
        InvoiceServiceNameTxt: Label 'salesInvoices';
        PurchaseInvoiceServiceNameTxt: Label 'purchaseInvoices';
        ActionPostTxt: Label 'Microsoft.NAV.post';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';
        CreateIncomingDocumentErr: Label 'Cannot create incoming document.';
        CannotChangeIDErr: Label 'The id cannot be changed.', Locked = true;
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetGLEntryAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Incoming Document Attachment table
        CreateGLEntry(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateGLEntryAttachmentsURLWithFilter(FORMAT(GetGLEntryNo(DocumentRecordRef)));
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(DocumentId);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef));
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(DocumentId);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef));
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef));
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            GetDocumentSystemId(DocumentRecordRef), AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoSubpages(GenJournalBatch.SystemId, GetDocumentSystemId(DocumentRecordRef), PAGE::"APIV1 - Journals", JournalServiceNameTxt, JournalLineServiceNameTxt, AttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            FORMAT(GetGLEntryNo(DocumentRecordRef)), AttachmentId, PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            DocumentId, AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            GetDocumentId(DocumentRecordRef), AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            GetDocumentId(DocumentRecordRef), AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The Attachment should exist in the response
        LibraryGraphMgt.VerifyGUIDFieldInJson(ResponseText, 'id', AttachmentId);
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
        COMMIT();

        // [WHEN] A PATCH request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFieldsAndSubpage(
            GetDocumentSystemId(DocumentRecordRef), AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt, 'content');
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
        COMMIT();

        // [WHEN] A PATCH request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFieldsAndSubpage(
            FORMAT(GetGLEntryNo(DocumentRecordRef)),
            AttachmentId, PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt, 'content');
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
        TestCreateAttachment(DocumentRecordRef, DocumentId);
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
    procedure TestCreatePostedPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedPurchaseInvoice(DocumentRecordRef, DocumentId);
        TestCreateAttachment(DocumentRecordRef, DocumentId);
    end;

    [Test]
    procedure TestCreateDraftPurchaseInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseInvoice(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    local procedure TestCreateAttachment(var DocumentRecordRef: RecordRef)
    var
        DocumentId: Guid;
    begin
        DocumentId := GetDocumentSystemId(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef, DocumentId);
    end;

    [Normal]
    local procedure TestCreateAttachment(var DocumentRecordRef: RecordRef; DocumentId: Guid)
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
        AttachmentJSON := GetAttachmentJSON(DocumentId, TempIncomingDocumentAttachment, FALSE);
        COMMIT();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, AttachmentJSON, ResponseText);
        // [WHEN] The user uploads binary content to the attachment
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFieldsAndSubpage(
            DocumentId, AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt, 'content');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment has been created in the database.
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'id');
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);

        IF IncomingDocument.Posted THEN BEGIN
            Assert.AreEqual(IncomingDocument."Document No.", IncomingDocumentAttachment."Document No.", '');
            Assert.AreEqual(IncomingDocument."Posting Date", IncomingDocumentAttachment."Posting Date", '');
        END;
        Assert.AreEqual(GetAttachmentBase64Content(IncomingDocumentAttachment), BlobToBase64String(TempBlob), 'Wrong Content');
    end;

    [Normal]
    local procedure TestCreateGLEAttachment(var DocumentRecordRef: RecordRef)
    var
        TempIncomingDocumentAttachment: Record "Incoming Document Attachment" temporary;
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        IncomingDocument: Record "Incoming Document";
        TempBlob: Codeunit "Temp Blob";
        GLEntryNo: Integer;
        AttachmentId: Text;
        ResponseText: Text;
        TargetURL: Text;
        AttachmentJSON: Text;
    begin
        // [SCENARIO] Create an Attachment through a POST method and check if it was created
        // [GIVEN] The user has constructed an Attachment JSON object to send to the service.
        FindOrCreateIncomingDocument(DocumentRecordRef, IncomingDocument);
        GLEntryNo := GetGLEntryNo(DocumentRecordRef);
        CreateIncomingDocumentAttachment(IncomingDocument, TempIncomingDocumentAttachment);
        TempBlob.FromRecord(TempIncomingDocumentAttachment, TempIncomingDocumentAttachment.FieldNo(Content));
        AttachmentJSON := GetGLEntryAttachmentJSON(GLEntryNo, TempIncomingDocumentAttachment, FALSE);
        COMMIT();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, AttachmentJSON, ResponseText);
        // [WHEN] The user uploads binary content to the attachment
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFieldsAndSubpage(
            FORMAT(GLEntryNo), AttachmentId, PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt, 'content');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment has been created in the database.
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'id');
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);

        IF IncomingDocument.Posted THEN BEGIN
            Assert.AreEqual(IncomingDocument."Document No.", IncomingDocumentAttachment."Document No.", '');
            Assert.AreEqual(IncomingDocument."Posting Date", IncomingDocumentAttachment."Posting Date", '');
        END;
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
        TestDeleteAttachment(DocumentRecordRef, DocumentId);
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
        TestDeleteAttachment(DocumentRecordRef, DocumentId);
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
        TestDeleteAttachment(DocumentRecordRef, DocumentId);
    end;

    [Normal]
    local procedure TestDeleteAttachment(var DocumentRecordRef: RecordRef; DocumentId: Guid)
    var
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete an Attachment by making a DELETE request.
        // [GIVEN] An Attachment exists.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        COMMIT();

        // [WHEN] The user makes a DELETE request to the endpoint for the Attachment.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            DocumentId, AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
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
        GLEntryNo: Integer;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete an Attachment by making a DELETE request.
        // [GIVEN] An Attachment exists.
        GLEntryNo := GetGLEntryNo(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        COMMIT();

        // [WHEN] The user makes a DELETE request to the endpoint for the Attachment.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            FORMAT(GLEntryNo), AttachmentId, PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] The invoice is posted through the Invoices API.
        TargetURL :=
          LibraryGraphMgt.CreateTargetURLWithSubpage(DocumentId, PAGE::"APIV1 - Sales Invoices", InvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] The Attachment exists and is correctly linked to the posted invoice.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        SalesInvoiceHeader.SETRANGE("Draft Invoice SystemId", DocumentId);
        SalesInvoiceHeader.FINDFIRST();
        DocumentRecordRef.GETTABLE(SalesInvoiceHeader);
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(SalesInvoiceHeader."No.", IncomingDocument."Document No.", 'Wrong Document No.');
        Assert.AreEqual(IncomingDocument."Document Type", IncomingDocument."Document Type"::"Sales Invoice", 'Wrong Document Type.');
        Assert.AreEqual(SalesInvoiceHeader.RECORDID(), IncomingDocument."Related Record ID", 'Wrong Related Record ID.');
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
        COMMIT();

        // [WHEN] The invoice is posted through the Invoices API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(
            DocumentId, PAGE::"APIV1 - Purchase Invoices", PurchaseInvoiceServiceNameTxt, ActionPostTxt);
        LibraryGraphMgt.PostToWebServiceAndCheckResponseCode(TargetURL, '', ResponseText, 204);

        // [THEN] The Attachment exists and is correctly linked to the posted invoice.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        PurchInvHeader.SETRANGE("Draft Invoice SystemId", DocumentId);
        PurchInvHeader.FINDFIRST();
        DocumentRecordRef.GETTABLE(PurchInvHeader);
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(PurchInvHeader."No.", IncomingDocument."Document No.", 'Wrong Document No.');
        Assert.AreEqual(IncomingDocument."Document Type", IncomingDocument."Document Type"::"Purchase Invoice", 'Wrong Document Type.');
        Assert.AreEqual(PurchInvHeader.RECORDID(), IncomingDocument."Related Record ID", 'Wrong Related Record ID.');
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
        COMMIT();

        // [WHEN] The user changes the attachment file name by making a PATCH request
        FileName := STRSUBSTNO('%1.txt', FormatGuid(CREATEGUID()));
        JSONBody := STRSUBSTNO('{"fileName":"%1"}', FileName);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            DocumentId, AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
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
        COMMIT();

        // [WHEN] The user changes the attachment content by making a PATCH request
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFieldsAndSubpage(
            DocumentId, AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt, 'content');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The attachment name is not changed in the database.
        IncomingDocumentAttachment.GetBySystemId(AttachmentId);
        NewFileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        Assert.AreEqual(OldFileName, NewFileName, 'Attachment file name has been changed.');

        // [THEN] The attachment remains linked to the correct document.
        DocumentRecordRef.FIND();
        FindIncomingDocument(DocumentRecordRef, IncomingDocument);
        Assert.AreEqual(DocumentRecordRef.RECORDID(), IncomingDocument."Related Record ID", 'The attachment is linked to a wrong document.');
    end;

    [Test]
    procedure TestLinkedAttachmentIdChangeNotAllowed()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
        JSONBody: Text;
    begin
        // [SCENARIO] User cannot change the linked attachment ID by making a PATCH request to the Attachments API
        // [GIVEN] A sales quote exists.
        CreateSalesQuote(DocumentRecordRef);

        // [GIVEN] A linked attachment exists.
        AttachmentId := CreateAttachment(DocumentRecordRef);
        COMMIT();

        // [WHEN] The user changes the attachment ID by making a PATCH request
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            GetDocumentId(DocumentRecordRef), AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
        JSONBody := STRSUBSTNO('{"id":"%1"}', FormatGuid(CREATEGUID()));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, JSONBody, ResponseText);

        // [THEN] Cannot change the attchment ID, expect error 400
        Assert.ExpectedError('400');
        Assert.ExpectedError(CannotChangeIDErr);
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
        COMMIT();

        // [WHEN] The user changes the document ID by making a PATCH request
        TargetURL := LibraryGraphMgt.CreateTargetURLWithTwoKeyFields(
            DocumentId[1], AttachmentId, PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);
        JSONBody := STRSUBSTNO('{"parentId":"%1"}', FormatGuid(DocumentId[2]));
        ASSERTERROR LibraryGraphMgt.PatchToWebService(TargetURL, JSONBody, ResponseText);

        // [THEN] Cannot change the document ID, expect error 400
        Assert.ExpectedError('400');
        Assert.ExpectedError(STRSUBSTNO(CannotModifyKeyFieldErr, 'parentId'));
    end;

    local procedure CreateDraftSalesInvoice(var DocumentRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        DocumentRecordRef.GETTABLE(SalesHeader);
    end;

    local procedure CreatePostedSalesInvoice(var DocumentRecordRef: RecordRef; var DocumentId: Guid)
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        SalesHeader: Record "Sales Header";
        InvoiceCode: Code[20];
    begin
        LibrarySales.CreateSalesInvoice(SalesHeader);
        InvoiceCode := LibrarySales.PostSalesDocument(SalesHeader, FALSE, TRUE);
        SalesInvoiceHeader.GET(InvoiceCode);
        DocumentId := SalesInvoiceHeader."Draft Invoice SystemId";
        DocumentRecordRef.GETTABLE(SalesInvoiceHeader);
    end;

    local procedure CreateDraftPurchaseInvoice(var DocumentRecordRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        DocumentRecordRef.GETTABLE(PurchaseHeader);
    end;

    local procedure CreatePostedPurchaseInvoice(var DocumentRecordRef: RecordRef; var DocumentId: Guid)
    var
        PurchInvHeader: Record "Purch. Inv. Header";
        PurchaseHeader: Record "Purchase Header";
        InvoiceCode: Code[20];
    begin
        LibraryPurchase.CreatePurchaseInvoice(PurchaseHeader);
        InvoiceCode := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, FALSE, TRUE);
        PurchInvHeader.GET(InvoiceCode);
        DocumentId := PurchInvHeader."Draft Invoice SystemId";
        DocumentRecordRef.GETTABLE(PurchInvHeader);
    end;

    local procedure CreateSalesQuote(var DocumentRecordRef: RecordRef)
    var
        SalesHeader: Record "Sales Header";
        Customer: Record "Customer";
    begin
        LibrarySmallBusiness.CreateCustomer(Customer);
        LibrarySmallBusiness.CreateSalesQuoteHeader(SalesHeader, Customer);
        DocumentRecordRef.GETTABLE(SalesHeader);
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
        DocumentRecordRef.GETTABLE(GenJournalLine);
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

    local procedure CreateGLEntry(var DocumentRecordRef: RecordRef)
    var
        GenJournalLine: Record "Gen. Journal Line";
        GLEntry: Record "G/L Entry";
    begin
        LibraryERM.CreateAndPostTwoGenJourLinesWithSameBalAccAndDocNo(GenJournalLine,
          GenJournalLine."Bal. Account Type"::"G/L Account", LibraryERM.CreateGLAccountNoWithDirectPosting(), 1);
        GLEntry.SETCURRENTKEY("Entry No.");
        GLEntry.SETASCENDING("Entry No.", FALSE);
        GLEntry.FINDFIRST();
        DocumentRecordRef.GETTABLE(GLEntry);
    end;


    local procedure CreateAttachments(var DocumentRecordRef: RecordRef; var AttachmentId: array[2] of Guid)
    var
        "Count": Integer;
    begin
        FOR Count := 1 TO 2 DO
            AttachmentId[Count] := CreateAttachment(DocumentRecordRef);
    end;

    local procedure GetDocumentSystemId(DocumentRecordRef: RecordRef): Guid
    var
        Id: Guid;
    begin
        Evaluate(Id, Format(DocumentRecordRef.Field(DocumentRecordRef.SystemIdNo()).Value()));
        exit(Id);
    end;

    local procedure GetDocumentId(var DocumentRecordRef: RecordRef): Guid
    var
        IdFieldRef: FieldRef;
        Id: Guid;
    begin
        IdFieldRef := DocumentRecordRef.Field(DocumentRecordRef.SystemIdNo());
        EVALUATE(Id, FORMAT(IdFieldRef.VALUE()));
        EXIT(Id);
    end;

    local procedure GetGLEntryNo(var DocumentRecordRef: RecordRef): Integer
    var
        DummyGLEntry: Record "G/L Entry";
        DataTypeManagement: Codeunit "Data Type Management";
        EntryNoFieldRef: FieldRef;
        EntryNo: Integer;
    begin
        IF DataTypeManagement.FindFieldByName(DocumentRecordRef, EntryNoFieldRef, DummyGLEntry.FIELDNAME("Entry No.")) THEN
            EVALUATE(EntryNo, FORMAT(EntryNoFieldRef.VALUE()));
        EXIT(EntryNo);
    end;

    local procedure IsPostedDocument(var DocumentRecordRef: RecordRef): Boolean
    begin
        EXIT(
          (DocumentRecordRef.NUMBER() = DATABASE::"Sales Invoice Header") OR (DocumentRecordRef.NUMBER() = DATABASE::"Purch. Inv. Header"));
    end;

    local procedure IsGeneralJournalLine(var DocumentRecordRef: RecordRef): Boolean
    begin
        EXIT(DocumentRecordRef.NUMBER() = DATABASE::"Gen. Journal Line");
    end;

    local procedure IsPurchaseInvoice(var DocumentRecordRef: RecordRef): Boolean
    begin
        IF DocumentRecordRef.NUMBER() = DATABASE::"Purch. Inv. Header" THEN
            EXIT(TRUE);
        IF DocumentRecordRef.NUMBER() = DATABASE::"Purchase Header" THEN
            EXIT(TRUE);
        EXIT(FALSE);
    end;

    local procedure IsGLEntry(var DocumentRecordRef: RecordRef): Boolean
    begin
        EXIT(DocumentRecordRef.NUMBER() = DATABASE::"G/L Entry");
    end;

    local procedure FindIncomingDocument(var DocumentRecordRef: RecordRef; var IncomingDocument: Record "Incoming Document"): Boolean
    begin
        IF IsPostedDocument(DocumentRecordRef) OR IsGLEntry(DocumentRecordRef) THEN
            EXIT(IncomingDocument.FindByDocumentNoAndPostingDate(DocumentRecordRef, IncomingDocument));
        EXIT(IncomingDocument.FindFromIncomingDocumentEntryNo(DocumentRecordRef, IncomingDocument));
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
        IF FindIncomingDocument(DocumentRecordRef, IncomingDocument) THEN
            EXIT(TRUE);

        IncomingDocument.INIT();
        IncomingDocument."Related Record ID" := DocumentRecordRef.RECORDID();

        IF DocumentRecordRef.NUMBER() = DATABASE::"Sales Invoice Header" THEN BEGIN
            DocumentRecordRef.SETTABLE(SalesInvoiceHeader);
            IncomingDocument.Description := COPYSTR(SalesInvoiceHeader."Sell-to Customer Name", 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Sales Invoice";
            IncomingDocument."Document No." := SalesInvoiceHeader."No.";
            IncomingDocument."Posting Date" := SalesInvoiceHeader."Posting Date";
            IncomingDocument.Posted := true;
            IncomingDocument.INSERT(TRUE);
            IncomingDocument.FIND();
            EXIT(TRUE);
        END;

        IF IsGeneralJournalLine(DocumentRecordRef) THEN BEGIN
            DocumentRecordRef.SETTABLE(GenJournalLine);
            IncomingDocument.Description := COPYSTR(GenJournalLine.Description, 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::Journal;
            IncomingDocument.INSERT(TRUE);
            GenJournalLine."Incoming Document Entry No." := IncomingDocument."Entry No.";
            GenJournalLine.MODIFY();
            DocumentRecordRef.GETTABLE(GenJournalLine);
            EXIT(TRUE);
        END;

        IF IsGLEntry(DocumentRecordRef) THEN BEGIN
            DocumentRecordRef.SETTABLE(GLEntry);
            IncomingDocument.Description := COPYSTR(GLEntry.Description, 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document No." := GLEntry."Document No.";
            IncomingDocument."Posting Date" := GLEntry."Posting Date";
            IncomingDocument.Status := IncomingDocument.Status::Posted;
            IncomingDocument.Posted := TRUE;
            IncomingDocument.INSERT(TRUE);
            EXIT(TRUE);
        END;

        IF DocumentRecordRef.NUMBER() = DATABASE::"Sales Header" THEN BEGIN
            DocumentRecordRef.SETTABLE(SalesHeader);
            IncomingDocument.Description := COPYSTR(SalesHeader."Sell-to Customer Name", 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Sales Invoice";
            IncomingDocument."Document No." := SalesHeader."No.";
            IncomingDocument.INSERT(TRUE);
            IncomingDocument.FIND();
            SalesHeader.FIND();
            SalesHeader."Incoming Document Entry No." := IncomingDocument."Entry No.";
            SalesHeader.MODIFY();
            DocumentRecordRef.GETTABLE(SalesHeader);
            EXIT(TRUE);
        END;

        IF IsPurchaseInvoice(DocumentRecordRef) AND IsPostedDocument(DocumentRecordRef) THEN BEGIN
            DocumentRecordRef.SETTABLE(PurchInvHeader);
            IncomingDocument.Description := COPYSTR(PurchInvHeader."Buy-from Vendor Name", 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Purchase Invoice";
            IncomingDocument."Document No." := PurchInvHeader."No.";
            IncomingDocument."Posting Date" := PurchInvHeader."Posting Date";
            IncomingDocument."Posted Date-Time" := CURRENTDATETIME();
            IncomingDocument.Status := IncomingDocument.Status::Posted;
            IncomingDocument.Posted := TRUE;
            IncomingDocument.INSERT(TRUE);
            EXIT(TRUE);
        END;

        IF DocumentRecordRef.NUMBER() = DATABASE::"Purchase Header" THEN BEGIN
            DocumentRecordRef.SETTABLE(PurchaseHeader);
            IncomingDocument.Description := COPYSTR(PurchaseHeader."Buy-from Vendor Name", 1, MAXSTRLEN(IncomingDocument.Description));
            IncomingDocument."Document Type" := IncomingDocument."Document Type"::"Purchase Invoice";
            IncomingDocument."Document No." := PurchaseHeader."No.";
            IncomingDocument.INSERT(TRUE);
            PurchaseHeader.FIND();
            PurchaseHeader."Incoming Document Entry No." := IncomingDocument."Entry No.";
            PurchaseHeader.MODIFY();
            DocumentRecordRef.GETTABLE(PurchaseHeader);
            EXIT(TRUE);
        END;
    end;

    local procedure CreateAttachment(var DocumentRecordRef: RecordRef): Guid
    var
        IncomingDocument: Record "Incoming Document";
        IncomingDocumentAttachment: Record "Incoming Document Attachment";
    begin
        IF NOT FindOrCreateIncomingDocument(DocumentRecordRef, IncomingDocument) THEN
            ERROR(CreateIncomingDocumentErr);

        CreateIncomingDocumentAttachment(IncomingDocument, IncomingDocumentAttachment);
        IncomingDocumentAttachment.INSERT(TRUE);
        EXIT(IncomingDocumentAttachment.SystemId);
    end;

    local procedure CreateIncomingDocumentAttachment(var IncomingDocument: Record "Incoming Document"; var IncomingDocumentAttachment: Record "Incoming Document Attachment")
    var
        LastUsedIncomingDocumentAttachment: Record "Incoming Document Attachment";
        OutStream: OutStream;
        LineNo: Integer;
    begin
        LastUsedIncomingDocumentAttachment.SETRANGE("Incoming Document Entry No.", IncomingDocument."Entry No.");
        IF NOT LastUsedIncomingDocumentAttachment.FINDLAST() THEN
            LineNo := 10000
        ELSE
            LineNo := LastUsedIncomingDocumentAttachment."Line No." + 10000;

        IncomingDocumentAttachment.INIT();
        IncomingDocumentAttachment."Incoming Document Entry No." := IncomingDocument."Entry No.";
        IncomingDocumentAttachment."Line No." := LineNo;
        IncomingDocumentAttachment.Name :=
          COPYSTR(FormatGuid(CREATEGUID()), 1, MAXSTRLEN(IncomingDocumentAttachment.Name));
        IncomingDocumentAttachment.Type := IncomingDocumentAttachment.Type::Other;
        IncomingDocumentAttachment."File Extension" := 'txt';
        IncomingDocumentAttachment.Content.CREATEOUTSTREAM(OutStream, TEXTENCODING::UTF8);
        OutStream.WRITETEXT(FormatGuid(CREATEGUID()));
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

    local procedure GetAttachmentJSON(DocumentId: Guid; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; IncludeID: Boolean) AttachmentJSON: Text
    var
        FileName: Text;
    begin
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON('', 'parentId', FormatGuid(DocumentId));

        IF IncludeID THEN
            AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'id', FormatGuid(IncomingDocumentAttachment.SystemId));

        FileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'fileName', FileName);
    end;

    local procedure GetGLEntryAttachmentJSON(GLEntryNo: Integer; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; IncludeID: Boolean) AttachmentJSON: Text
    var
        FileName: Text;
    begin
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON('', 'generalLedgerEntryNumber', FORMAT(GLEntryNo));

        IF IncludeID THEN
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
        Assert.AreEqual(ExpectedValue, PropertyValue, STRSUBSTNO(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyAttachmentProperties(AttachmentJSON: Text; var IncomingDocumentAttachment: Record "Incoming Document Attachment"; ExpectedBase64Content: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        FileName: Text;
    begin
        Assert.AreNotEqual('', AttachmentJSON, EmptyJSONErr);
        IF NOT ISNULLGUID(IncomingDocumentAttachment.SystemId) THEN
            LibraryGraphMgt.VerifyGUIDFieldInJson(AttachmentJSON, 'id', IncomingDocumentAttachment.SystemId);
        FileName := NameAndExtensionToFileName(IncomingDocumentAttachment.Name, IncomingDocumentAttachment."File Extension");
        VerifyPropertyInJSON(AttachmentJSON, 'fileName', FileName);
        TempBlob.FromRecord(IncomingDocumentAttachment, IncomingDocumentAttachment.FieldNo(Content));
        VerifyPropertyInJSON(AttachmentJSON, 'byteSize', FORMAT(GetBlobLength(TempBlob), 0, 9));
        IF ExpectedBase64Content <> '' THEN
            Assert.AreEqual(ExpectedBase64Content, GetAttachmentBase64Content(IncomingDocumentAttachment), 'Wrong content.');
    end;

    local procedure FormatGuid(Value: Guid): Text
    begin
        EXIT(LOWERCASE(LibraryGraphMgt.StripBrackets(FORMAT(Value, 0, 9))));
    end;

    local procedure GenerateRandomBinaryContent(var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream, TEXTENCODING::UTF8);
        OutStream.WRITETEXT(FormatGuid(CREATEGUID()));
    end;

    local procedure BlobToBase64String(var TempBlob: Codeunit "Temp Blob"): Text
    var
        InStream: InStream;
        Convert: DotNet Convert;
        MemoryStream: DotNet MemoryStream;
        Base64String: Text;
    begin
        IF NOT TempBlob.HasValue() THEN
            EXIT('');
        TempBlob.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        COPYSTREAM(MemoryStream, InStream);
        Base64String := Convert.ToBase64String(MemoryStream.ToArray());
        MemoryStream.Close();
        EXIT(Base64String);
    end;

    local procedure GetBlobLength(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        InStream: InStream;
        MemoryStream: DotNet MemoryStream;
        ContentLength: Integer;
    begin
        IF NOT TempBlob.HasValue() THEN
            EXIT(0);
        TempBlob.CreateInStream(InStream);
        MemoryStream := MemoryStream.MemoryStream();
        COPYSTREAM(MemoryStream, InStream);
        ContentLength := MemoryStream.Length();
        MemoryStream.Close();
        EXIT(ContentLength);
    end;

    local procedure CreateAttachmentsURLWithFilter(DocumentIdFilter: Guid): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - Attachments", AttachmentServiceNameTxt);

        UrlFilter := '$filter=parentId eq ' + LibraryGraphMgt.StripBrackets(FORMAT(DocumentIdFilter));

        IF STRPOS(TargetURL, '?') <> 0 THEN
            TargetURL := TargetURL + '&' + UrlFilter
        ELSE
            TargetURL := TargetURL + '?' + UrlFilter;

        EXIT(TargetURL);
    end;

    local procedure CreateGLEntryAttachmentsURLWithFilter(GLEntryNoFilter: Text): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', PAGE::"APIV1 - G/L Entry Attachments", GLEntryAttachmentServiceNameTxt);

        UrlFilter := '$filter=generalLedgerEntryNumber eq ' + GLEntryNoFilter;

        IF STRPOS(TargetURL, '?') <> 0 THEN
            TargetURL += '&' + UrlFilter
        ELSE
            TargetURL += '?' + UrlFilter;

        EXIT(TargetURL);
    end;

    local procedure NameAndExtensionToFileName(Name: Text[250]; Extension: Text[30]): Text
    begin
        IF Extension <> '' THEN
            EXIT(STRSUBSTNO('%1.%2', Name, Extension));
        EXIT(Name);
    end;
}































































