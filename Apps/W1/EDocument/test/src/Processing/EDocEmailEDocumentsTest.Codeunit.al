codeunit 139501 "E-Doc. Email E-Documents Test"
{
    Subtype = Test;
    EventSubscriberInstance = Manual;

    var
        Customer: Record Customer;
        EDocumentService: Record "E-Document Service";
        DocSendingProfile: Record "Document Sending Profile";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        AttachmentName: Text[250];
        IsInitialized: Boolean;
        XMLFileLbl: Label '%1 %2.xml', Locked = true;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationYesModalPageHandler,PostAndSendStrMenuHandler,EmailEditorHandler,SalesShipmentSameActionConfirmHandler')]
    procedure PostAndSendSalesOrder()
    var
        SalesHeader: Record "Sales Header";
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post and send sales order so the email gets created with e-document attached
        Initialize(Enum::"Service Integration"::"Mock");
        BindSubscription(EDocImplState);

        // [GIVEN] Sales order
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, SalesHeader."Document Type"::Order);

        // [WHEN] Post and send
        Codeunit.Run(Codeunit::"Sales-Post and Send", SalesHeader);

        // [THEN] Email is created with attachment
        SalesInvoiceHeader.Get(SalesHeader."Last Posting No.");
        Assert.AreEqual(
            AttachmentName,
            StrSubstNo(XMLFileLbl, ReportDistributionManagement.GetFullDocumentTypeText(SalesInvoiceHeader), SalesInvoiceHeader."No."),
            'Attachment name is incorrect or attachment does not exist.');
        // [THEN] E-Document status is processed
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        EDocument.FindFirst();
        Assert.AreEqual(EDocument.Status, Enum::"E-Document Status"::Processed, 'E-document status different than processed.');

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('PostAndSendConfirmationYesModalPageHandler,PostAndSendStrMenuHandler,EmailEditorHandler')]
    procedure PostAndSendSalesCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EDocument: Record "E-Document";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Post and send sales credit memo so the email gets created with e-document attached
        Initialize(Enum::"Service Integration"::"Mock");
        BindSubscription(EDocImplState);

        // [GIVEN] Sales credit memo
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.CreateSalesHeaderWithItem(Customer, SalesHeader, SalesHeader."Document Type"::"Credit Memo");

        // [WHEN] Post and send
        Codeunit.Run(Codeunit::"Sales-Post and Send", SalesHeader);

        // [THEN] Email is created with attachment
        SalesCrMemoHeader.Get(SalesHeader."Last Posting No.");
        Assert.AreEqual(
            AttachmentName,
            StrSubstNo(XMLFileLbl, ReportDistributionManagement.GetFullDocumentTypeText(SalesCrMemoHeader), SalesCrMemoHeader."No."),
            'Attachment name is incorrect or attachment does not exist.');
        // [THEN] E-Document status is processed
        EDocument.SetRange("Document Record ID", SalesCrMemoHeader.RecordId());
        EDocument.FindFirst();
        Assert.AreEqual(EDocument.Status, Enum::"E-Document Status"::Processed, 'E-document status different than processed.');

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EmailEditorHandler,EmailEditorStrMenuHandler')]
    procedure CreateEDocumentForPostedSalesInvoice()
    var
        SalesInvoiceHeader: Record "Sales Invoice Header";
        EDocument: Record "E-Document";
        CustomerWithoutDocSendingProfile: Record "Customer";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Create e-document for posted sales invoice
        Initialize(Enum::"Service Integration"::"Mock");
        BindSubscription(EDocImplState);

        // [GIVEN] Customer without sending profile specified
        LibraryEDoc.CreateCustomerForSalesScenario(CustomerWithoutDocSendingProfile, '');
        // [GIVEN] Posted sales invoice
        LibraryLowerPermission.SetTeamMember();
        SalesInvoiceHeader := LibraryEDoc.PostInvoice(CustomerWithoutDocSendingProfile);

        // [WHEN] Set up cusotmer document sending profile with e-document extended flow
        CustomerWithoutDocSendingProfile."Document Sending Profile" := DocSendingProfile.Code;
        CustomerWithoutDocSendingProfile.Modify(False);
        // [WHEN] Invoke Create and Email E-Document for posted sales invoice
        SalesInvoiceHeader.CreateAndEmailEDocument();

        // [THEN] Email is created with attachment
        Assert.AreEqual(
            StrSubstNo(XMLFileLbl, ReportDistributionManagement.GetFullDocumentTypeText(SalesInvoiceHeader), SalesInvoiceHeader."No."),
            AttachmentName,
            'Attachment name is incorrect or attachment does not exist.');
        // [THEN] E-Document status is processed
        EDocument.SetRange("Document Record ID", SalesInvoiceHeader.RecordId());
        EDocument.FindFirst();
        Assert.AreEqual(EDocument.Status, Enum::"E-Document Status"::Processed, 'E-document status different than processed.');

        UnbindSubscription(EDocImplState);
    end;

    [Test]
    [HandlerFunctions('EmailEditorHandler,EmailEditorStrMenuHandler')]
    procedure CreateEDocumentForPostedSalesCreditMemo()
    var
        SalesHeader: Record "Sales Header";
        SalesCrMemoHeader: Record "Sales Cr.Memo Header";
        EDocument: Record "E-Document";
        CustomerWithoutDocSendingProfile: Record "Customer";
        LibrarySales: Codeunit "Library - Sales";
        ReportDistributionManagement: Codeunit "Report Distribution Management";
    begin
        // [FEATURE] [E-Document] [Processing]
        // [SCENARIO] Create e-document for posted sales credit memo
        Initialize(Enum::"Service Integration"::"Mock");
        BindSubscription(EDocImplState);

        // [GIVEN] Customer without sending profile specified
        LibraryEDoc.CreateCustomerForSalesScenario(CustomerWithoutDocSendingProfile, '');
        // [GIVEN] Sales credit memo
        LibraryLowerPermission.SetTeamMember();
        LibraryEDoc.CreateSalesHeaderWithItem(CustomerWithoutDocSendingProfile, SalesHeader, SalesHeader."Document Type"::"Credit Memo");
        LibrarySales.PostSalesDocument(SalesHeader, true, true);

        // [WHEN] Set up cusotmer document sending profile with e-document extended flow
        CustomerWithoutDocSendingProfile."Document Sending Profile" := DocSendingProfile.Code;
        CustomerWithoutDocSendingProfile.Modify(False);
        // [WHEN] Invoke Create and Email E-Document for posted sales credit memo
        SalesCrMemoHeader.Get(SalesHeader."Last Posting No.");
        SalesCrMemoHeader.CreateAndEmailEDocument();

        // [THEN] Email is created with attachment
        Assert.AreEqual(
            StrSubstNo(XMLFileLbl, ReportDistributionManagement.GetFullDocumentTypeText(SalesCrMemoHeader), SalesCrMemoHeader."No."),
            AttachmentName,
            'Attachment name is incorrect or attachment does not exist.');
        // [THEN] E-Document status is processed
        EDocument.SetRange("Document Record ID", SalesCrMemoHeader.RecordId());
        EDocument.FindFirst();
        Assert.AreEqual(EDocument.Status, Enum::"E-Document Status"::Processed, 'E-document status different than processed.');

        UnbindSubscription(EDocImplState);
    end;


    local procedure Initialize(Integration: Enum "Service Integration")
    var
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
        EDocumentServiceStatus: Record "E-Document Service Status";
        LibraryWorkflow: Codeunit "Library - Workflow";
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        Clear(EDocImplState);

        if IsInitialized then
            exit;

        EDocument.DeleteAll();
        EDocumentServiceStatus.DeleteAll();
        EDocumentService.DeleteAll();

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::Mock, Integration);
        EDocumentService."Sent Actions Integration" := Enum::"Sent Document Actions"::Mock;
        EDocumentService.Modify();
        DocSendingProfile.Get(Customer."Document Sending Profile");
        DocSendingProfile."E-Mail" := DocSendingProfile."E-Mail"::"Yes (Prompt for Settings)";
        DocSendingProfile."E-Mail Attachment" := DocSendingProfile."E-Mail Attachment"::"E-Document";
        DocSendingProfile.Modify(false);

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();
        LibraryWorkflow.SetUpEmailAccount();

        IsInitialized := true;
    end;

    [ModalPageHandler]
    procedure PostAndSendConfirmationYesModalPageHandler(var PostandSendConfirmation: TestPage "Post and Send Confirmation")
    begin
        PostandSendConfirmation.Yes().Invoke();
    end;

    [StrMenuHandler]
    procedure PostAndSendStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 3; //Ship and Invoice
    end;

    [ModalPageHandler]
    procedure EmailEditorHandler(var EmailDialog: TestPage "Email Editor")
    begin
        AttachmentName := EmailDialog.Attachments.FileName.Value();
    end;

    [ConfirmHandler]
    procedure SalesShipmentSameActionConfirmHandler(Question: Text[1024]; var Reply: Boolean);
    begin
        if Question = 'You can take the same actions for the related Sales - Shipment document.\\Do you want to do that now?' then
            Reply := false;
    end;

    [StrMenuHandler]
    procedure EmailEditorStrMenuHandler(Options: Text[1024]; var Choice: Integer; Instruction: Text[1024])
    begin
        Choice := 2; //Discard
    end;
}
