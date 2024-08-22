codeunit 139899 "APIV2 - Document Attach. E2E"
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
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryHumanResources: Codeunit "Library - Human Resource";
        LibraryJob: Codeunit "Library - Job";
        ImageAsBase64Txt: Label 'iVBORw0KGgoAAAANSUhEUgAAAAoAAAAFCAYAAAB8ZH1oAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAAhSURBVBhXYwCC/0RirILYMIIDAtjYUIzCwYexCqJhhv8AD/M3yc4WsFgAAAAASUVORK5CYII=', Locked = true;
        AttachmentEntityBufferDocumentType: Enum "Attachment Entity Buffer Document Type";
        AttachmentServiceNameTxt: Label 'documentAttachments';
        EmptyJSONErr: Label 'The JSON should not be blank.';
        WrongPropertyValueErr: Label 'Incorrect property value for %1.', Comment = '%1=Property name';

    [Test]
    procedure TestGetCustomerAttachments()
    var
        Customer: Record Customer;
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        LibrarySales.CreateCustomer(Customer);
        DocumentRecordRef.GetTable(Customer);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Customer));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetItemAttachments()
    var
        Item: Record Item;
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        LibrarySmallBusiness.CreateItem(Item);
        DocumentRecordRef.GetTable(Item);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Item));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetEmployeeAttachments()
    var
        Employee: Record Employee;
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        LibraryHumanResources.CreateEmployee(Employee);
        DocumentRecordRef.GetTable(Employee);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Employee));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetJobAttachments()
    var
        Job: Record Job;
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        LibraryJob.CreateJob(Job);
        DocumentRecordRef.GetTable(Job);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Job));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetVendorAttachments()
    var
        Vendor: Record Vendor;
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        LibrarySmallBusiness.CreateVendor(Vendor);
        DocumentRecordRef.GetTable(Vendor);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentSystemId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::Vendor));
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
        // [GIVEN] 2 Attachments in the Document Attachment table
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
        // [GIVEN] 2 Attachments in the Document Attachment table
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
    procedure TestGetPostedPurchaseInvoiceAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
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
        // [GIVEN] 2 Attachments in the Document Attachment table
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
        // [GIVEN] 2 Attachments in the Document Attachment table
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
    procedure TestGetPostedInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve the Attachment record from the Attachment API.
        // [GIVEN] Attachment exists in the Document Attachment table
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
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
        // [GIVEN] Attachment exists in the Document Attachment table
        CreateDraftSalesInvoice(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
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
        // [GIVEN] Attachment exists in the Document Attachment table
        CreateDraftSalesOrder(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
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
        // [GIVEN] Attachment exists in the Document Attachment table
        CreateSalesQuote(DocumentRecordRef);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
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
        // [GIVEN] 2 Attachments in the Document Attachment table
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
    procedure TestUpdateCustomerAttachmentBinaryContent()
    var
        DocumentAttachment: Record "Document Attachment";
        Customer: Record Customer;
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
        LibrarySmallBusiness.CreateCustomer(Customer);
        DocumentRecordRef.GetTable(Customer);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        GenerateRandomBinaryContent(TempBlob);
        ExpectedBase64Content := BlobToBase64String(TempBlob);
        Commit();

        // [WHEN] A PATCH request is made to the Attachment API.
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment should exist in the response
        Assert.AreEqual('', ResponseText, 'Response should be empty');

        // [THEN] The content is correctly updated.
        DocumentAttachment.GetBySystemId(AttachmentId);
        ActualBase64Content := GetAttachmentBase64Content(DocumentAttachment);
        Assert.AreEqual(ExpectedBase64Content, ActualBase64Content, 'Wrong content');
    end;

    [Test]
    procedure TestCreateCustomerAttachment()
    var
        Customer: Record Customer;
        DocumentRecordRef: RecordRef;
    begin
        LibrarySmallBusiness.CreateCustomer(Customer);
        DocumentRecordRef.GetTable(Customer);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreateVendorAttachment()
    var
        Vendor: Record Vendor;
        DocumentRecordRef: RecordRef;
    begin
        LibrarySmallBusiness.CreateVendor(Vendor);
        DocumentRecordRef.GetTable(Vendor);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreatePostedInvoiceAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentType: Text;
    begin
        CreatePostedSalesInvoice(DocumentRecordRef, DocumentId);
        DocumentType := GetDocumentType(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef, DocumentId, DocumentType);
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
        DocumentType: Text;
    begin
        CreatePostedPurchaseInvoice(DocumentRecordRef, DocumentId);
        DocumentType := GetDocumentType(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef, DocumentId, DocumentType);
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
        DocumentAttachment: Record "Document Attachment";
        TempBlob: Codeunit "Temp Blob";
        AttachmentId: Text;
        ResponseText: Text;
        TargetURL: Text;
        AttachmentJSON: Text;
    begin
        // [SCENARIO] Create an Attachment through a POST method and check if it was created
        // [GIVEN] The user has constructed an Attachment JSON object to send to the service.
        DocumentAttachment.GetBySystemId(CreateAttachment(DocumentRecordRef, TempBlob));

        AttachmentJSON := GetAttachmentJSON(DocumentId, DocumentType, DocumentAttachment, false);
        Commit();

        // [WHEN] The user posts the JSON to the service.
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.PostToWebService(TargetURL, AttachmentJSON, ResponseText);
        // [WHEN] The user uploads binary content to the attachment
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        TargetURL := LibraryGraphMgt.CreateTargetURLWithSubpage(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt, 'attachmentContent');
        LibraryGraphMgt.BinaryUpdateToWebServiceAndCheckResponseCode(TargetURL, TempBlob, 'PATCH', ResponseText, 204);

        // [THEN] The Attachment has been created in the database.
        LibraryGraphMgt.VerifyIDFieldInJson(ResponseText, 'id');
        LibraryGraphMgt.GetObjectIDFromJSON(ResponseText, 'id', AttachmentId);
        DocumentAttachment.GetBySystemId(AttachmentId);
        Assert.AreEqual(GetAttachmentBase64Content(DocumentAttachment), BlobToBase64String(TempBlob), 'Wrong Content');
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
    procedure TestDeleteVendorAttachment()
    var
        Vendor: Record Vendor;
        DocumentRecordRef: RecordRef;
    begin
        LibrarySmallBusiness.CreateVendor(Vendor);
        DocumentRecordRef.GetTable(Vendor);
        CreateAttachment(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteEmployeeAttachment()
    var
        Employee: Record Employee;
        DocumentRecordRef: RecordRef;
    begin
        LibraryHumanResources.CreateEmployee(Employee);
        DocumentRecordRef.GetTable(Employee);
        CreateAttachment(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeleteJobAttachment()
    var
        Job: Record Job;
        DocumentRecordRef: RecordRef;
    begin
        LibraryJob.CreateJob(Job);
        DocumentRecordRef.GetTable(Job);
        CreateAttachment(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
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

    [Test]
    procedure TestGetDraftPurchaseCreditMemoAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        CreateDraftPurchaseCreditMemo(DocumentRecordRef);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(GetDocumentId(DocumentRecordRef), Format(AttachmentEntityBufferDocumentType::"Purchase Credit Memo"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestGetPostedPurchaseCreditMemoAttachments()
    var
        DocumentRecordRef: RecordRef;
        AttachmentId: array[2] of Guid;
        DocumentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can retrieve all records from the Attachments API.
        // [GIVEN] 2 Attachments in the Document Attachment table
        CreatePostedPurchaseCreditMemo(DocumentRecordRef, DocumentId);
        CreateAttachments(DocumentRecordRef, AttachmentId);
        Commit();

        // [WHEN] A GET request is made to the Attachment API.
        TargetURL := CreateAttachmentsURLWithFilter(DocumentId, Format(AttachmentEntityBufferDocumentType::"Purchase Credit Memo"));
        LibraryGraphMgt.GetFromWebService(ResponseText, TargetURL);

        // [THEN] The 2 Attachments should exist in the response
        GetAndVerifyIDFromJSON(ResponseText, AttachmentId);
    end;

    [Test]
    procedure TestCreateDraftPurchaseCreditMemoAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseCreditMemo(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestCreatePostedPurchaseCreditMemoAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
        DocumentType: Text;
    begin
        CreatePostedPurchaseCreditMemo(DocumentRecordRef, DocumentId);
        DocumentType := GetDocumentType(DocumentRecordRef);
        TestCreateAttachment(DocumentRecordRef, DocumentId, DocumentType);
    end;

    [Test]
    procedure TestDeleteDraftPurchaseCreditMemoAttachment()
    var
        DocumentRecordRef: RecordRef;
    begin
        CreateDraftPurchaseCreditMemo(DocumentRecordRef);
        TestDeleteAttachment(DocumentRecordRef);
    end;

    [Test]
    procedure TestDeletePostedPurchaseCreditMemoAttachment()
    var
        DocumentRecordRef: RecordRef;
        DocumentId: Guid;
    begin
        CreatePostedPurchaseCreditMemo(DocumentRecordRef, DocumentId);
        TestDeleteAttachment2(DocumentRecordRef);
    end;

    local procedure CreatePostedPurchaseCreditMemo(var DocumentRecordRef: RecordRef; var DocumentId: Guid)
    var
        PurchCrMemoHdr: Record "Purch. Cr. Memo Hdr.";
        PurchaseHeader: Record "Purchase Header";
        InvoiceCode: Code[20];
    begin
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        InvoiceCode := LibraryPurchase.PostPurchaseDocument(PurchaseHeader, false, true);
        PurchCrMemoHdr.Get(InvoiceCode);
        DocumentId := PurchCrMemoHdr."Draft Cr. Memo SystemId";
        DocumentRecordRef.GetTable(PurchCrMemoHdr);
    end;

    local procedure CreateDraftPurchaseCreditMemo(var DocumentRecordRef: RecordRef)
    var
        PurchaseHeader: Record "Purchase Header";
    begin
        LibraryPurchase.CreatePurchaseCreditMemo(PurchaseHeader);
        DocumentRecordRef.GetTable(PurchaseHeader);
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
        Customer: Record Customer;
        DocumentAttachment: Record "Document Attachment";
        AttachmentId: Guid;
        ResponseText: Text;
        TargetURL: Text;
    begin
        // [SCENARIO] User can delete an Attachment by making a DELETE request.
        // [GIVEN] An Attachment exists.
        LibrarySmallBusiness.CreateCustomer(Customer);
        DocumentRecordRef.GetTable(Customer);
        AttachmentId := CreateAttachment(DocumentRecordRef);
        Commit();

        // [WHEN] The user makes a DELETE request to the endpoint for the Attachment.
        TargetURL := LibraryGraphMgt.CreateTargetURL(AttachmentId, Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);
        LibraryGraphMgt.DeleteFromWebService(TargetURL, '', ResponseText);

        // [THEN] The response is empty.
        Assert.AreEqual('', ResponseText, 'DELETE response should be empty.');

        // [THEN] The Attachment is no longer in the database.
        Assert.IsFalse(DocumentAttachment.GetBySystemId(AttachmentId), 'The attachment should be deleted.');
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
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::"Credit Memo" then
                        exit(Format(AttachmentEntityBufferDocumentType::"Purchase Credit Memo"));
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Invoice then
                        exit(Format(AttachmentEntityBufferDocumentType::"Purchase Invoice"));
                    if PurchaseHeader."Document Type" = PurchaseHeader."Document Type"::Order then
                        exit(Format(AttachmentEntityBufferDocumentType::"Purchase Order"));
                end;
            Database::"Purch. Cr. Memo Hdr.":
                exit(Format(AttachmentEntityBufferDocumentType::"Purchase Credit Memo"));
            Database::"Gen. Journal Line", Database::"G/L Entry":
                exit(Format(AttachmentEntityBufferDocumentType::"Journal"));
            Database::Customer:
                exit(Format(AttachmentEntityBufferDocumentType::"Customer"));
            Database::Vendor:
                exit(Format(AttachmentEntityBufferDocumentType::"Vendor"));
            Database::Employee:
                exit(Format(AttachmentEntityBufferDocumentType::"Employee"));
            Database::Item:
                exit(Format(AttachmentEntityBufferDocumentType::"Item"));
            Database::Job:
                exit(Format(AttachmentEntityBufferDocumentType::"Job"));
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

    local procedure CreateAttachment(var DocumentRecordRef: RecordRef): Guid
    var
        TempBlob: Codeunit "Temp Blob";
    begin
        exit(CreateAttachment(DocumentRecordRef, TempBlob));
    end;

    local procedure CreateAttachment(var DocumentRecordRef: RecordRef; var TempBlob: Codeunit "Temp Blob"): Guid
    var
        DocumentAttachment: Record "Document Attachment";
        LastUsedDocumentAttachment: Record "Document Attachment";
        DummySalesInvoiceHeader: Record "Sales Invoice Header";
        DataTypeManagement: Codeunit "Data Type Management";
        NoFieldRef: FieldRef;
        LineNo: Integer;
    begin
        if not LastUsedDocumentAttachment.FindLast() then
            LineNo := 10000
        else
            LineNo := LastUsedDocumentAttachment."Line No." + 10000;

        DocumentAttachment.InitFieldsFromRecRef(DocumentRecordRef);
        DocumentAttachment."Line No." := LineNo;
        DocumentAttachment."Table ID" := DocumentRecordRef.Number;
        DataTypeManagement.FindFieldByName(DocumentRecordRef, NoFieldRef, DummySalesInvoiceHeader.FieldName("No."));
        DocumentAttachment."No." := NoFieldRef.Value;
        DocumentAttachment.Validate("File Name", CopyStr(FormatGuid(CreateGuid()), 1, MaxStrLen(DocumentAttachment."File Name")));
        DocumentAttachment.Validate("File Extension", 'txt');

        CreateDocumentAttachmentContent(DocumentAttachment, TempBlob);
        DocumentAttachment.Insert(true);
        exit(DocumentAttachment.SystemId);
    end;

    local procedure CreateDocumentAttachmentContent(var DocumentAttachment: Record "Document Attachment"; var TempBlob: Codeunit "Temp Blob")
    var
        Base64Convert: Codeunit "Base64 Convert";
        ContentOutStream: OutStream;
        ContentInStream: InStream;
    begin
        TempBlob.CreateOutStream(ContentOutStream);
        Base64Convert.FromBase64(ImageAsBase64Txt, ContentOutStream);
        TempBlob.CreateInStream(ContentInStream);
        DocumentAttachment."Document Reference ID".ImportStream(ContentInStream, '', '', DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension");
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

    local procedure GetAttachmentJSON(DocumentId: Guid; DocumentType: Text; var DocumentAttachment: Record "Document Attachment"; IncludeID: Boolean) AttachmentJSON: Text
    var
        FileName: Text;
    begin
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON('', 'parentId', FormatGuid(DocumentId));
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'parentType', DocumentType);

        if IncludeID then
            AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'id', FormatGuid(DocumentAttachment.SystemId));

        FileName := NameAndExtensionToFileName(CopyStr(DocumentAttachment."File Name" + '.' + DocumentAttachment."File Extension", 1, 250), DocumentAttachment."File Extension");
        AttachmentJSON := LibraryGraphMgt.AddPropertytoJSON(AttachmentJSON, 'fileName', FileName);
    end;

    local procedure GetAttachmentBase64Content(var DocumentAttachment: Record "Document Attachment") Base64Content: Text
    var
        TempBlob: Codeunit "Temp Blob";
        ContentOutStream: OutStream;
    begin
        TempBlob.CreateOutStream(ContentOutStream);
        DocumentAttachment."Document Reference ID".ExportStream(ContentOutStream);
        Base64Content := BlobToBase64String(TempBlob);
    end;

    local procedure VerifyPropertyInJSON(JSON: Text; PropertyName: Text; ExpectedValue: Text)
    var
        PropertyValue: Text;
    begin
        LibraryGraphMgt.GetObjectIDFromJSON(JSON, PropertyName, PropertyValue);
        Assert.AreEqual(ExpectedValue, PropertyValue, StrSubstNo(WrongPropertyValueErr, PropertyName));
    end;

    local procedure VerifyAttachmentProperties(AttachmentJSON: Text; var DocumentAttachment: Record "Document Attachment"; ExpectedBase64Content: Text)
    var
        TempBlob: Codeunit "Temp Blob";
        ContentOutStream: OutStream;
        FileName: Text;
    begin
        Assert.AreNotEqual('', AttachmentJSON, EmptyJSONErr);
        if not IsNullGuid(DocumentAttachment.SystemId) then
            LibraryGraphMgt.VerifyGUIDFieldInJson(AttachmentJSON, 'id', DocumentAttachment.SystemId);
        FileName := NameAndExtensionToFileName(DocumentAttachment."File Name", DocumentAttachment."File Extension");
        VerifyPropertyInJSON(AttachmentJSON, 'fileName', FileName);
        TempBlob.CreateOutStream(ContentOutStream);
        DocumentAttachment."Document Reference ID".ExportStream(ContentOutStream);

        VerifyPropertyInJSON(AttachmentJSON, 'byteSize', Format(GetBlobLength(TempBlob), 0, 9));
        if ExpectedBase64Content <> '' then
            Assert.AreEqual(ExpectedBase64Content, GetAttachmentBase64Content(DocumentAttachment), 'Wrong content.');
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
        "System.Convert": DotNet Convert;
        "System.IO.MemoryStream": DotNet MemoryStream;
        Base64String: Text;
    begin
        if not TempBlob.HasValue() then
            exit('');
        TempBlob.CreateInStream(InStream);
        "System.IO.MemoryStream" := "System.IO.MemoryStream".MemoryStream();
        COPYSTREAM("System.IO.MemoryStream", InStream);
        Base64String := "System.Convert".ToBase64String("System.IO.MemoryStream".ToArray());
        "System.IO.MemoryStream".Close();
        exit(Base64String);
    end;

    local procedure GetBlobLength(var TempBlob: Codeunit "Temp Blob"): Integer
    var
        InStream: InStream;
        "System.IO.MemoryStream": DotNet MemoryStream;
        ContentLength: Integer;
    begin
        if not TempBlob.HasValue() then
            exit(0);
        TempBlob.CreateInStream(InStream);
        "System.IO.MemoryStream" := "System.IO.MemoryStream".MemoryStream();
        COPYSTREAM("System.IO.MemoryStream", InStream);
        ContentLength := "System.IO.MemoryStream".Length();
        "System.IO.MemoryStream".Close();
        exit(ContentLength);
    end;

    local procedure CreateAttachmentsURLWithFilter(DocumentIdFilter: Guid; DocumentTypeFilter: Text): Text
    var
        TargetURL: Text;
        UrlFilter: Text;
    begin
        TargetURL := LibraryGraphMgt.CreateTargetURL('', Page::"APIV2 - Document Attachments", AttachmentServiceNameTxt);

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