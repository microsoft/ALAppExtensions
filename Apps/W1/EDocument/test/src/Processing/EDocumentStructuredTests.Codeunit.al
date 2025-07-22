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
        if ProcessEDocumentToStep(EDocument, "Import E-Document Steps"::"Read into Draft") then
            PEPPOLStructuredValidations.AssertFullEDocumentContentExtracted(EDocument."Entry No")
        else
            Assert.Fail(EDocumentStatusNotUpdatedErr);
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
        Currency.Init();
        Currency.Validate(Code, 'XYZ');
        if Currency.Insert(true) then;

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
        exit(EDocument."Import Processing Status" = Enum::"Import E-Doc. Proc. Status"::"Ready for draft");
    end;
}
