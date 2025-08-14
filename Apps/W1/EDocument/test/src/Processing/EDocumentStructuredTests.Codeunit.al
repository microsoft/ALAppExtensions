codeunit 139891 "E-Document Structured Tests"
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
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        CAPIStructuredValidations: Codeunit "CAPI Structured Validations";
        PEPPOLStructuredValidations: Codeunit "PEPPOL Structured Validations";
        IsInitialized: Boolean;
        EDocumentStatusNotUpdatedErr: Label 'The status of the EDocument was not updated to the expected status after the step was executed.';
        MockCurrencyCode: Code[10];
        MockDate: Date;

    #region CAPI JSON
    [Test]
    procedure TestCAPIInvoice_ValidDocument()
    var
        EDocument: Record "E-Document";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        SetupCAPIEDocumentService();
        CreateInboundEDocumentFromJSON(EDocument, 'capi/capi-invoice-valid-0.json');
        if ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft") then
            CAPIStructuredValidations.AssertFullEDocumentContentExtracted(EDocument."Entry No")
        else
            Assert.Fail(EDocumentStatusNotUpdatedErr);
    end;

    [Test]
    procedure TestCAPIInvoice_UnexpectedFieldValues()
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        SetupCAPIEDocumentService();
        CreateInboundEDocumentFromJSON(EDocument, 'capi/capi-invoice-unexpected-values-0.json');
        if ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft") then begin
            CAPIStructuredValidations.AssertMinimalEDocumentContentParsed(EDocument."Entry No");
            EDocumentPurchaseHeader.Get(EDocument."Entry No");
            // "value_text": null
            Assert.AreEqual('', EDocumentPurchaseHeader."Shipping Address", 'Text field should be empty when JSON value is null');
            // "value_text": 1
            Assert.AreEqual('1', EDocumentPurchaseHeader."Shipping Address Recipient", 'Text field should convert non-text JSON values to their string representation');

            // "value_number": null
            Assert.AreEqual(0, EDocumentPurchaseHeader."Sub Total", 'Number field should be 0 when JSON value is null');
            // "value_number": "10"
            Assert.AreEqual(10, EDocumentPurchaseHeader."Total VAT", 'Number field should parse numeric string values');
            // "value_number": "abc"
            Assert.AreEqual(0, EDocumentPurchaseHeader."Amount Due", 'Number field should be 0 when JSON value is not a valid numeric value');

            // "value_date": null
            Assert.AreEqual(0D, EDocumentPurchaseHeader."Service Start Date", 'Date field should be empty when JSON value is null');
            // "value_date": "aaa"
            Assert.AreEqual(0D, EDocumentPurchaseHeader."Service End Date", 'Date field should be empty when JSON value is not a valid date value');
        end
        else
            Assert.Fail(EDocumentStatusNotUpdatedErr);
    end;
    #endregion

    #region PEPPOL 3.0 XML
    [Test]
    procedure TestPEPPOLInvoice_ValidDocument()
    var
        EDocument: Record "E-Document";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        SetupPEPPOLEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, 'peppol/peppol-invoice-0.xml');
        if ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft") then begin
            PEPPOLStructuredValidations.SetMockCurrencyCode(MockCurrencyCode);
            PEPPOLStructuredValidations.SetMockDate(MockDate);
            PEPPOLStructuredValidations.AssertFullEDocumentContentExtracted(EDocument."Entry No");
        end
        else
            Assert.Fail(EDocumentStatusNotUpdatedErr);
    end;

    [Test]
    [HandlerFunctions('EDocumentPurchaseHeaderPageHandler')]
    procedure TestPEPPOLInvoice_ValidDocument_ViewExtractedData()
    var
        EDocument: Record "E-Document";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        // [FEATURE] [E-Document] [PEPPOL] [View Data]
        // [SCENARIO] View extracted data from a valid PEPPOL invoice document

        // [GIVEN] A valid PEPPOL XML invoice document is imported
        Initialize(Enum::"Service Integration"::"Mock");
        SetupPEPPOLEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, 'peppol/peppol-invoice-0.xml');

        // [WHEN] The document is processed to draft status
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft");
        EDocument.Get(EDocument."Entry No");

        // [WHEN] View extracted data is called
        EDocImport.ViewExtractedData(EDocument);

        // [THEN] The extracted data page opens and can be handled properly (verified by page handler)
       // EDocumentPurchaseHeaderPageHandler
    end;

    [Test]
    procedure TestPEPPOLInvoice_ValidDocument_PurchaseInvoiceCreated()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        EDocumentProcessing: Codeunit "E-Document Processing";
        DataTypeManagement: Codeunit "Data Type Management";
        VariantRecord: Variant;
        RecRef: RecordRef;
    begin
        // [FEATURE] [E-Document] [PEPPOL] [Purchase Invoice Creation]
        // [SCENARIO] Create a purchase invoice from a valid PEPPOL invoice document
        // ---------------------------------------------------------------------------
        // [Expected Outcome]
        // [1] E-Document is successfully processed through all import steps
        // [2] A purchase header record is created and linked to the E-Document
        // [3] Purchase header fields are correctly populated with PEPPOL data
        // [4] All validation assertions pass for the created purchase document

        // [GIVEN] A valid PEPPOL XML invoice document is imported
        Initialize(Enum::"Service Integration"::"Mock");
        SetupPEPPOLEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, 'peppol/peppol-invoice-0.xml');

        // [WHEN] The document is processed through finish draft step
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Finish draft");
        EDocument.Get(EDocument."Entry No");

        // [WHEN] The created purchase record is retrieved
        EDocumentProcessing.GetRecord(EDocument, VariantRecord);
        DataTypeManagement.GetRecordRef(VariantRecord, RecRef);
        RecRef.SetTable(PurchaseHeader);

        // [THEN] The purchase header is correctly created with PEPPOL data
        PEPPOLStructuredValidations.SetMockCurrencyCode(MockCurrencyCode);
        PEPPOLStructuredValidations.SetMockDate(MockDate);
        PEPPOLStructuredValidations.AssertPurchaseHeader(Vendor."No.", PurchaseHeader);
    end;

    [Test]
    procedure TestPEPPOLInvoice_ValidDocument_UpdateDraftAndFinalize()
    var
        EDocument: Record "E-Document";
        PurchaseHeader: Record "Purchase Header";
        Item: Record Item;
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        DataTypeManagement: Codeunit "Data Type Management";
        EDocPurchaseDraftSubform: TestPage "E-Doc. Purchase Draft Subform";
        EDocPurchaseDraft: TestPage "E-Document Purchase Draft";
        VariantRecord: Variant;
        RecRef: RecordRef;
    begin
        // [FEATURE] [E-Document] [PEPPOL] [Draft Update]
        // [SCENARIO] Update draft purchase document data and finalize processing

        // [GIVEN] A valid PEPPOL XML invoice document is imported and processed to draft preparation
        Initialize(Enum::"Service Integration"::"Mock");
        SetupPEPPOLEDocumentService();
        CreateInboundEDocumentFromXML(EDocument, 'peppol/peppol-invoice-0.xml');
        ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Prepare draft");

        // [GIVEN] A generic item is created for manual assignment
        LibraryEDoc.CreateGenericItem(Item);

        // [WHEN] The draft document is opened and modified through UI
        EDocPurchaseDraft.OpenEdit();
        EDocPurchaseDraft.GoToRecord(EDocument);
        EDocPurchaseDraft.Lines.First();
        EDocPurchaseDraft.Lines."No.".SetValue(Item."No.");
        EDocPurchaseDraft.Lines.Next();

        // [WHEN] The processing is completed to finish draft step
        EDocImport.ProcessIncomingEDocument(EDocument, "Import E-Document Steps"::"Finish draft");
        EDocument.Get(EDocument."Entry No");

        // [WHEN] The final purchase record is retrieved
        EDocumentProcessing.GetRecord(EDocument, VariantRecord);
        DataTypeManagement.GetRecordRef(VariantRecord, RecRef);
        RecRef.SetTable(PurchaseHeader);

        // [THEN] The purchase header contains both imported PEPPOL data and manual updates
        PEPPOLStructuredValidations.SetMockCurrencyCode(MockCurrencyCode);
        PEPPOLStructuredValidations.SetMockDate(MockDate);
        PEPPOLStructuredValidations.SetItem(Item);
        PEPPOLStructuredValidations.AssertPurchaseHeader(Vendor."No.", PurchaseHeader);
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
        Clear(EDocImplState);
        Clear(LibraryVariableStorage);

        if IsInitialized then
            exit;

        EDocument.DeleteAll();
        EDocumentServiceStatus.DeleteAll();
        EDocumentService.DeleteAll();
        EDocDataStorage.DeleteAll();
        EDocumentPurchaseHeader.DeleteAll();
        EDocumentPurchaseLine.DeleteAll();
        DocumentAttachment.DeleteAll();

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::Mock, Integration);
        LibraryEDoc.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::Mock, Integration);
        EDocumentService."Import Process" := "E-Document Import Process"::"Version 2.0";
        EDocumentService."Read into Draft Impl." := "E-Doc. Read into Draft"::"PDF Mock";
        EDocumentService.Modify();
        EDocumentsSetup.InsertNewExperienceSetup();

        // Set a currency that can be used across all localizations
        MockCurrencyCode := 'XYZ';
        Currency.Init();
        Currency.Validate(Code, MockCurrencyCode);
        if Currency.Insert(true) then;
        CreateCurrencyExchangeRate();

        MockDate := DMY2Date(22, 01, 2026);

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();

        IsInitialized := true;
    end;

    local procedure SetupCAPIEDocumentService()
    begin
        EDocumentService."Read into Draft Impl." := "E-Doc. Read into Draft"::ADI;
        EDocumentService.Modify();
    end;

    local procedure SetupPEPPOLEDocumentService()
    begin
        EDocumentService."Read into Draft Impl." := "E-Doc. Read into Draft"::PEPPOL;
        EDocumentService.Modify();
    end;

    local procedure CreateInboundEDocumentFromJSON(var EDocument: Record "E-Document"; FilePath: Text)
    var
        EDocLogRecord: Record "E-Document Log";
        EDocumentLog: Codeunit "E-Document Log";
    begin
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. File Format"::JSON, NavApp.GetResourceAsText(FilePath));
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Readable);

        EDocument."Structured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();
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
        EDocument.Modify();
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
