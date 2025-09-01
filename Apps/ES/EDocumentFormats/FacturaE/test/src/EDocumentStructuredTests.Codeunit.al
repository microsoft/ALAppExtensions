codeunit 148002 "E-Document Structured Tests"
{
    Subtype = Test;
    TestType = IntegrationTest;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        FacturaEStructValidations: Codeunit "Factura-E Struct. Validations";
        IsInitialized: Boolean;
        EDocumentStatusNotUpdatedErr: Label 'The status of the EDocument was not updated to the expected status after the step was executed.';
        TestFileTok: Label 'factura-e/facturae-invoice-0.xml', Locked = true;
        MockCurrencyCode: Code[10];
        MockDate: Date;

    #region FacturaE 3.0 XML
    [Test]
    procedure TestFacturaEInvoice_ValidDocument()
    var
        EDocument: Record "E-Document";
    begin
        // [FEATURE] [E-Document] [FacturaE] [Import]
        // [SCENARIO] Import and validate a valid FacturaE invoice document

        // [GIVEN] A valid FacturaE XML invoice document
        Initialize(Enum::"Service Integration"::"No Integration");
        SetupFacturaEEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, TestFileTok);

        // [WHEN] The document is processed to read into draft step
        if ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft") then begin
            FacturaEStructValidations.SetMockCurrencyCode(MockCurrencyCode);
            FacturaEStructValidations.SetMockDate(MockDate);

            // [THEN] The document content is fully extracted and validated
            FacturaEStructValidations.AssertFullEDocumentContentExtracted(EDocument."Entry No");
        end else
            Assert.Fail(EDocumentStatusNotUpdatedErr);
    end;

    [Test]
    [HandlerFunctions('EDocumentPurchaseHeaderPageHandler')]
    procedure TestFacturaEInvoice_ValidDocument_ViewExtractedData()
    var
        EDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        // [FEATURE] [E-Document] [FacturaE] [View Data]
        // [SCENARIO] View extracted data from a valid FacturaE invoice document

        // [GIVEN] A valid FacturaE XML invoice document is imported
        Initialize(Enum::"Service Integration"::"No Integration");
        SetupFacturaEEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, TestFileTok);

        // [WHEN] The document is processed to draft status
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft");
        EDocument.Get(EDocument."Entry No");

        // [WHEN] View extracted data is called
        EDocImport.ViewExtractedData(EDocument);

        // [THEN] The extracted data page opens and can be handled properly (verified by page handler)
        // EDocumentPurchaseHeaderPageHandler
    end;

    [Test]
    procedure TestFacturaEInvoice_ValidDocument_PurchaseInvoiceCreated()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        DummyItem: Record Item;
        EDocumentProcessing: Codeunit "E-Document Processing";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        VariantRecord: Variant;
    begin
        // [FEATURE] [E-Document] [FacturaE] [Purchase Invoice Creation]
        // [SCENARIO] Create a purchase invoice from a valid FacturaE invoice document

        // [GIVEN] A valid FacturaE XML invoice document is imported
        Initialize(Enum::"Service Integration"::"No Integration");
        Vendor."VAT Registration No." := 'GB123456789';
        Vendor.Modify(true);

        SetupFacturaEEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, TestFileTok);

        // [WHEN] The document is processed through finish draft step
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Finish draft");
        EDocument.Get(EDocument."Entry No");

        // [WHEN] The created purchase record is retrieved
        EDocumentProcessing.GetRecord(EDocument, VariantRecord);
        DataTypeManagement.GetRecordRef(VariantRecord, RecRef);
        RecRef.SetTable(PurchaseHeader);

        // [THEN] The purchase header is correctly created with FacturaE data
        FacturaEStructValidations.SetMockCurrencyCode(MockCurrencyCode);
        FacturaEStructValidations.SetMockDate(MockDate);
        FacturaEStructValidations.AssertPurchaseDocument(Vendor."No.", PurchaseHeader, DummyItem);
    end;

    [Test]
    procedure TestFacturaEInvoice_ValidDocument_UpdateDraftAndFinalize()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        DataTypeManagement: Codeunit "Data Type Management";
        RecRef: RecordRef;
        EDocPurchaseDraft: TestPage "E-Document Purchase Draft";
        VariantRecord: Variant;
    begin
        // [FEATURE] [E-Document] [FacturaE] [Draft Update]
        // [SCENARIO] Update draft purchase document data and finalize processing

        // [GIVEN] A valid FacturaE XML invoice document is imported and processed to draft preparation
        Initialize(Enum::"Service Integration"::"No Integration");
        Vendor."VAT Registration No." := 'GB123456789';
        Vendor.Modify(true);
        SetupFacturaEEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, TestFileTok);
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Prepare draft");

        // [GIVEN] A generic item is created for manual assignment
        LibraryEDoc.CreateGenericItem(Item, '');

        // [WHEN] The draft document is opened and modified through UI
        EDocPurchaseDraft.OpenEdit();
        EDocPurchaseDraft.GoToRecord(EDocument);
        EDocPurchaseDraft.Lines.First();
        EDocPurchaseDraft.Lines."Line Type".SetValue("Purchase Line Type"::Item);
        EDocPurchaseDraft.Lines."No.".SetValue(Item."No.");
        EDocPurchaseDraft.Lines.Next();

        // [WHEN] The processing is completed to finish draft step
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Finish draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        EDocument.Get(EDocument."Entry No");

        // [WHEN] The final purchase record is retrieved
        EDocumentProcessing.GetRecord(EDocument, VariantRecord);
        DataTypeManagement.GetRecordRef(VariantRecord, RecRef);
        RecRef.SetTable(PurchaseHeader);

        // [THEN] The purchase header contains both imported FacturaE data and manual updates
        FacturaEStructValidations.SetMockCurrencyCode(MockCurrencyCode);
        FacturaEStructValidations.SetMockDate(MockDate);
        FacturaEStructValidations.AssertPurchaseDocument(Vendor."No.", PurchaseHeader, Item);
    end;

    [PageHandler]
    procedure EDocumentPurchaseHeaderPageHandler(var EDocReadablePurchaseDoc: TestPage "E-Doc. Readable Purchase Doc.")
    begin
        EDocReadablePurchaseDoc.Close();
    end;
    #endregion

    local procedure Initialize(Integration: Enum "Service Integration")
    var
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentsSetup: Record "E-Documents Setup";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        DocumentAttachment: Record "Document Attachment";
        Currency: Record Currency;
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        Clear(LibraryVariableStorage);

        if IsInitialized then
            exit;

        EDocument.DeleteAll(false);
        EDocumentServiceStatus.DeleteAll(false);
        EDocumentService.DeleteAll(false);
        EDocDataStorage.DeleteAll(false);
        EDocumentPurchaseHeader.DeleteAll(false);
        EDocumentPurchaseLine.DeleteAll(false);
        DocumentAttachment.DeleteAll(false);

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::"Factura-E 3.2.2", Integration);
        LibraryEDoc.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::"Factura-E 3.2.2", Integration);
        EDocumentService."Import Process" := "E-Document Import Process"::"Version 2.0";
        EDocumentService."Read into Draft Impl." := "E-Doc. Read into Draft"::"Factura-E";
        EDocumentService.Modify(false);
        EDocumentsSetup.InsertNewExperienceSetup();

        // Set a currency that can be used across all localizations
        MockCurrencyCode := 'XYZ';
        Currency.Init();
        Currency.Validate(Code, MockCurrencyCode);
        if Currency.Insert(true) then;
        CreateCurrencyExchangeRate();

        MockDate := DMY2Date(22, 01, 2026);

        TransformationRule.DeleteAll(false);
        TransformationRule.CreateDefaultTransformations();

        IsInitialized := true;
    end;

    local procedure SetupFacturaEEDocumentService()
    begin
        EDocumentService."Read into Draft Impl." := "E-Doc. Read into Draft"::"Factura-E";
        EDocumentService.Modify(false);
    end;

    local procedure CreateInboundEDocumentFromXML(var EDocument: Record "E-Document"; FilePath: Text)
    var
        EDocLogRecord: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
    begin
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. File Format"::XML, NavApp.GetResourceAsText(FilePath));
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Readable);

        EDocument."Structured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify(false);
    end;

    local procedure ProcessEDocumentToStep(var EDocument: Record "E-Document"; ProcessingStep: Enum "Import E-Document Steps"): Boolean
    var
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Readable);
        EDocImportParameters."Step to Run" := ProcessingStep;
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        EDocument.CalcFields("Import Processing Status");

        // Update the exit condition to handle different processing steps
        case ProcessingStep of
            "Import E-Document Steps"::"Read into Draft":
                exit(EDocument."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::"Ready for draft");
            "Import E-Document Steps"::"Finish draft":
                exit(EDocument."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::Processed);
            "Import E-Document Steps"::"Prepare draft":
                exit(EDocument."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::"Draft Ready");
            else
                exit(EDocument."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::"Ready for draft");
        end;
    end;

    local procedure CreateCurrencyExchangeRate()
    var
        CurrencyExchangeRate: Record "Currency Exchange Rate";
    begin
        CurrencyExchangeRate.Init();
        CurrencyExchangeRate."Currency Code" := MockCurrencyCode;
        CurrencyExchangeRate."Starting Date" := WorkDate();
        CurrencyExchangeRate."Exchange Rate Amount" := 10;
        CurrencyExchangeRate."Relational Exch. Rate Amount" := 1.23;
        CurrencyExchangeRate.Insert(true);
    end;
}