codeunit 139883 "E-Doc Process Test"
{
    Subtype = Test;

    var
        Customer: Record Customer;
        Vendor: Record Vendor;
        EDocumentService: Record "E-Document Service";
        Assert: Codeunit Assert;
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        LibraryEDoc: Codeunit "Library - E-Document";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        LibraryLowerPermission: Codeunit "Library - Lower Permissions";
        LibraryPurchase: Codeunit "Library - Purchase";
        IsInitialized: Boolean;


    [Test]
    procedure ProcessStructureReceivedData()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocLogRecord: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentLog: Codeunit "E-Document Log";
        IBlobType: Interface IBlobType;
        InStream: InStream;
        Text: Text;
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. Data Storage Blob Type"::"PDF Mock", 'Data');
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Unprocessed);

        EDocument."Unstructured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Unprocessed);
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Structure received data";

        Assert.AreEqual(Enum::"Import E-Doc. Proc. Status"::Unprocessed, EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        Assert.AreEqual(Enum::"Import E-Doc. Proc. Status"::Readable, EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');

        EDocDataStorage.FindLast();
        EDocDataStorage.CalcFields("Data Storage");
        EDocDataStorage."Data Storage".CreateInStream(InStream);
        InStream.Read(Text);
        Assert.AreEqual('Mocked content', Text, 'The data should be read from the mock converter.');
        Assert.AreEqual(Enum::"E-Doc. Data Storage Blob Type"::JSON, EDocDataStorage."Data Type", 'The data type should be updated to JSON.');
        IBlobType := EDocDataStorage."Data Type";
        Assert.IsTrue(IBlobType.IsStructured(), 'New entry should always be structured');
    end;

    [Test]
    procedure ProcessingDoesSequenceOfSteps()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocLogRecord: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentLog: Codeunit "E-Document Log";
        ImportEDocumentProcess: Codeunit "Import E-Document Process";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. Data Storage Blob Type"::"PDF Mock", 'Data');
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Unprocessed);

        EDocument."Unstructured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Unprocessed);
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        Assert.AreEqual(ImportEDocumentProcess.GetStatusForStep(EDocImportParameters."Step to Run", false), EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');
    end;

    [Test]
    procedure ProcessingUndoesSteps()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocLogRecord: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentLog: Codeunit "E-Document Log";
        ImportEDocumentProcess: Codeunit "Import E-Document Process";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. Data Storage Blob Type"::"PDF Mock", 'Data');
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Unprocessed);

        EDocument."Unstructured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Unprocessed);
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        Assert.AreEqual(ImportEDocumentProcess.GetStatusForStep(EDocImportParameters."Step to Run", false), EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');

        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Structure received data";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        Assert.AreEqual(ImportEDocumentProcess.GetStatusForStep(EDocImportParameters."Step to Run", false), EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');
    end;

    [Test]
    procedure PreparingPurchaseDraftFindsPurchaseOrderWhenSpecified()
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        PurchaseHeader."Document Type" := PurchaseHeader."Document Type"::Order;
        PurchaseHeader."No." := 'EDOC-001';
        PurchaseHeader.Insert();
        EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
        EDocumentPurchaseHeader."Purchase Order No." := PurchaseHeader."No.";
        EDocumentPurchaseHeader."Vendor VAT Id" := '13124234';
        EDocumentPurchaseHeader.Insert();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::"Ready for draft");
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        EDocumentHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        Assert.AreEqual(PurchaseHeader."No.", EDocumentHeaderMapping."Purchase Order No.", 'The purchase order should be found when explicitly specified in the E-Document.');
        EDocument.SetRecFilter();
        EDocument.FindFirst();
        Assert.AreEqual("E-Document Type"::"Purchase Order", EDocument."Document Type", 'The document type should be set to Purchase Order after preparing the draft.');

        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Structure received data";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        EDocumentHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        Assert.AreEqual(0, EDocumentHeaderMapping."E-Document Entry No.", 'There should be no assignments after undoing the Prepare draft step.');

        PurchaseHeader.SetRecFilter();
        PurchaseHeader.Delete();
    end;

    [Test]
    procedure PreparingPurchaseDraftFindsVendorByTaxId()
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        Vendor: Record Vendor;
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        Vendor."No." := 'EDOC001';
        Vendor."VAT Registration No." := 'EDOCTESTTAXID001';
        Vendor.Insert();
        EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
        EDocumentPurchaseHeader."Vendor VAT Id" := Vendor."VAT Registration No.";
        EDocumentPurchaseHeader.Insert();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::"Ready for draft");
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        EDocumentHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        Assert.AreEqual(Vendor."No.", EDocumentHeaderMapping."Vendor No.", 'The vendor should be found when the tax id is specified and it matches the one in BC.');

        Vendor.SetRecFilter();
        Vendor.Delete();
    end;

    [Test]
    procedure PreparingPurchaseDraftFindsAccountConfiguredWithTextToAccountMapping()
    var
        EDocument: Record "E-Document";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        Vendor: Record Vendor;
        GLAccount: Record "G/L Account";
        TextToAccountMapping: Record "Text-to-Account Mapping";
        EDocumentHeaderMapping: Record "E-Document Header Mapping";
        EDocumentLineMapping: Record "E-Document Line Mapping";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocImport: Codeunit "E-Doc. Import";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);
        GLAccount."No." := 'EDOC001';
        GLAccount.Insert();

        Vendor."No." := 'EDOC001';
        Vendor."VAT Registration No." := 'EDOCTESTTAXID001';
        Vendor.Insert();

        TextToAccountMapping."Debit Acc. No." := GLAccount."No.";
        TextToAccountMapping."Vendor No." := Vendor."No.";
        TextToAccountMapping."Mapping Text" := 'Test description';
        TextToAccountMapping.Insert();

        EDocumentPurchaseHeader."E-Document Entry No." := EDocument."Entry No";
        EDocumentPurchaseHeader."Vendor VAT Id" := Vendor."VAT Registration No.";
        EDocumentPurchaseHeader.Insert();
        EDocumentPurchaseLine."E-Document Entry No." := EDocument."Entry No";
        EDocumentPurchaseLine.Description := 'Test description';
        EDocumentPurchaseLine.Insert();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::"Ready for draft");
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        EDocumentHeaderMapping := EDocument.GetEDocumentHeaderMapping();
        Assert.AreEqual(Vendor."No.", EDocumentHeaderMapping."Vendor No.", 'The vendor should be found when the tax id is specified and it matches the one in BC.');
        EDocumentLineMapping.Get(EDocument."Entry No", EDocumentPurchaseLine."Line No.");
        Assert.AreEqual("Purchase Line Type"::"G/L Account", EDocumentLineMapping."Purchase Line Type", 'The purchase line type should be set to G/L Account.');
        Assert.AreEqual(GLAccount."No.", EDocumentLineMapping."Purchase Type No.", 'The G/L Account configured in the Text-to-Account Mapping should be found.');

        Vendor.SetRecFilter();
        Vendor.Delete();
        GLAccount.SetRecFilter();
        GLAccount.Delete();
        TextToAccountMapping.SetRecFilter();
        TextToAccountMapping.Delete();
    end;

    [Test]
    procedure FinishDraftCanBeUndone()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);
        EDocument."Document Type" := "E-Document Type"::"Purchase Invoice";
        EDocument.Modify();
        EDocumentService."Import Process" := "E-Document Import Process"::"Version 2.0";
        EDocumentService.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::"Draft Ready");
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Finish draft";
        EDocImportParameters."Processing Customizations" := "E-Doc. Proc. Customizations"::"Mock Create Purchase Invoice";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        PurchaseHeader.SetRange("E-Document Link", EDocument.SystemId);
        PurchaseHeader.FindFirst();

        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Structure received data";
        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);

        Assert.RecordIsEmpty(PurchaseHeader);
    end;

    #region HistoricalMatchingTest

    [Test]
    procedure ProcessingInboundDocumentCreatesLinks()
    var
        EDocument: Record "E-Document";
        EDocImportParams: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        PurchaseLine: Record "Purchase Line";
        EDocRecordLink: Record "E-Doc. Record Link";
    begin
        // [SCENARIO] A incoming e-document purchase invoice is received and processed, links should be created between the e-document and the purchase header and lines.
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PEPPOL BIS 3.0";
        EDocumentService.Modify();

        EDocRecordLink.DeleteAll();

        // [GIVEN] An inbound e-document is received and fully processed
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Finish draft";
        Assert.IsTrue(LibraryEDoc.CreateInboundPEPPOLDocumentToState(EDocument, EDocumentService, 'peppol/peppol-invoice-0.xml', EDocImportParams), 'The e-document should be processed');

        EDocument.Get(EDocument."Entry No");
        PurchaseHeader.Get(EDocument."Document Record ID");

        // [THEN] The e-document is linked to the purchase header and lines
        EDocRecordLink.SetRange("Target Table No.", Database::"Purchase Header");
        EDocRecordLink.SetRange("Target SystemId", PurchaseHeader.SystemId);
        Assert.RecordCount(EDocRecordLink, 1);

        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindSet();
        repeat
            EDocRecordLink.SetRange("Target Table No.", Database::"Purchase Line");
            EDocRecordLink.SetRange("Target SystemId", PurchaseLine.SystemId);
            Assert.RecordCount(EDocRecordLink, 1);
        until PurchaseLine.Next() = 0;
    end;

    [Test]
    procedure PostingInboundDocumentCreatesHistoricalRecords()
    var
        EDocument: Record "E-Document";
        EDocImportParams: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoiceHeader: Record "Purch. Inv. Header";
        EDocVendorAssignmentHistory: Record "E-Doc. Vendor Assign. History";
        EDocPurchaseLineHistory: Record "E-Doc. Purchase Line History";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        EDocRecordLink: Record "E-Doc. Record Link";
    begin
        // [SCENARIO] A incoming e-document purchase invoice is received, processed, and posted. Historical records should be created.
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PEPPOL BIS 3.0";
        EDocumentService.Modify();

        // [GIVEN] An inbound e-document is received and fully processed
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Finish draft";
        Assert.IsTrue(LibraryEDoc.CreateInboundPEPPOLDocumentToState(EDocument, EDocumentService, 'peppol/peppol-invoice-0.xml', EDocImportParams), 'The e-document should be processed');

        EDocument.Get(EDocument."Entry No");
        PurchaseHeader.Get(EDocument."Document Record ID");
        // [GIVEN] The received purchase invoice is modified for posting
        LibraryEDoc.EditPurchaseDocumentFromEDocumentForPosting(PurchaseHeader, EDocument);

        // [WHEN] The received purchase invoice is posted
        LibraryPurchase.PostPurchaseDocument(PurchaseHeader, true, true);
        PurchaseInvoiceHeader.SetRange("Pre-Assigned No.", PurchaseHeader."No.");
        PurchaseInvoiceHeader.FindFirst();

        // [THEN] The historical records are created
        EDocVendorAssignmentHistory.SetRange("Purch. Inv. Header SystemId", PurchaseInvoiceHeader.SystemId);
        Assert.RecordCount(EDocVendorAssignmentHistory, 1);
        PurchaseInvoiceLine.SetRange("Document No.", PurchaseInvoiceHeader."No.");
        PurchaseInvoiceLine.FindSet();
        repeat
            EDocPurchaseLineHistory.SetRange("Purch. Inv. Line SystemId", PurchaseInvoiceLine.SystemId);
            Assert.RecordCount(EDocPurchaseLineHistory, 1);
        until PurchaseInvoiceLine.Next() = 0;
        // [THEN] The links should be deleted, these are there momentarily while the purchase invoice is not yet posted
        EDocRecordLink.SetRange("E-Document Entry No.", EDocument."Entry No");
        Assert.RecordCount(EDocRecordLink, 0);
    end;
    #endregion

    [Test]
    procedure AdditionalFieldsAreConsideredWhenCreatingPurchaseInvoice()
    var
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        EDocument: Record "E-Document";
        EDocImportParams: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        EDocPurchLineField: Record "E-Document Line - Field";
        EDocPurchaseLine: Record "E-Document Purchase Line";
        Location: Record Location;
        EDocImport: Codeunit "E-Doc. Import";
    begin
        // [SCENARIO] Additional fields are configured for the e-document, and an incoming e-document is received. When creating a purchase invoice, the configured fields should be considered.
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PEPPOL BIS 3.0";
        EDocumentService.Modify();
        // [GIVEN] Additional fields are configured
        EDocPurchLineFieldSetup."Field No." := PurchaseInvoiceLine.FieldNo("Location Code");
        EDocPurchLineFieldSetup.Insert();
        EDocPurchLineFieldSetup."Field No." := PurchaseInvoiceLine.FieldNo("IC Partner Code");
        EDocPurchLineFieldSetup.Insert();
        // [GIVEN] An inbound e-document is received and a draft created
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        Assert.IsTrue(LibraryEDoc.CreateInboundPEPPOLDocumentToState(EDocument, EDocumentService, 'peppol/peppol-invoice-0.xml', EDocImportParams), 'The draft for the e-document should be created');

        // [WHEN] Storing custom values for the additional fields of the first line
        EDocPurchLineField."E-Document Entry No." := EDocument."Entry No";
        EDocPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocPurchaseLine.FindFirst();
        EDocPurchLineField."Line No." := EDocPurchaseLine."Line No.";
        EDocPurchLineField."Field No." := PurchaseInvoiceLine.FieldNo("Location Code");
        Location.Code := 'TESTLOC';
        if Location.Insert() then;
        EDocPurchLineField."Code Value" := Location.Code;
        EDocPurchLineField.Insert();

        // [WHEN] Creating a purchase invoice from the draft
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Finish draft";
        Assert.IsTrue(EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParams), 'The e-document should be processed');

        // [THEN] The additional fields should be set on the purchase invoice line
        EDocument.Get(EDocument."Entry No");
        PurchaseHeader.Get(EDocument."Document Record ID");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindFirst();
        Assert.AreEqual(Location.Code, PurchaseLine."Location Code", 'The location code should be set on the purchase line.');
    end;

    [Test]
    procedure AdditionalFieldsShouldNotBeConsideredIfNotConfigured()
    var
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
        PurchaseLine: Record "Purchase Line";
        PurchaseInvoiceLine: Record "Purch. Inv. Line";
        EDocument: Record "E-Document";
        EDocImportParams: Record "E-Doc. Import Parameters";
        PurchaseHeader: Record "Purchase Header";
        EDocPurchLineField: Record "E-Document Line - Field";
        EDocPurchaseLine: Record "E-Document Purchase Line";
        Location: Record Location;
        EDocImport: Codeunit "E-Doc. Import";
    begin
        // [SCENARIO] Additional fields are configured for the e-document, but the general setup is not configured. When creating a purchase invoice, the configured fields should not be considered.
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PEPPOL BIS 3.0";
        EDocumentService.Modify();
        // [GIVEN] Additional fields are configured
        EDocPurchLineFieldSetup."Field No." := PurchaseInvoiceLine.FieldNo("Location Code");
        EDocPurchLineFieldSetup.Insert();
        EDocPurchLineFieldSetup."Field No." := PurchaseInvoiceLine.FieldNo("IC Partner Code");
        EDocPurchLineFieldSetup.Insert();
        // [GIVEN] An inbound e-document is received and a draft created
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Prepare draft";
        Assert.IsTrue(LibraryEDoc.CreateInboundPEPPOLDocumentToState(EDocument, EDocumentService, 'peppol/peppol-invoice-0.xml', EDocImportParams), 'The draft for the e-document should be created');

        // [GIVEN] Custom values for the additional fields of the first line are configured
        EDocPurchLineField."E-Document Entry No." := EDocument."Entry No";
        EDocPurchaseLine.SetRange("E-Document Entry No.", EDocument."Entry No");
        EDocPurchaseLine.FindFirst();
        EDocPurchLineField."Line No." := EDocPurchaseLine."Line No.";
        EDocPurchLineField."Field No." := PurchaseInvoiceLine.FieldNo("Location Code");
        Location.Code := 'TESTLOC';
        if Location.Insert() then;
        EDocPurchLineField."Code Value" := Location.Code;
        EDocPurchLineField.Insert();

        // [WHEN] Removing the general setup for the additional fields
        EDocPurchLineFieldSetup.DeleteAll();
        // [WHEN] Creating a purchase invoice from the draft
        EDocImportParams."Step to Run" := "Import E-Document Steps"::"Finish draft";
        Assert.IsTrue(EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParams), 'The e-document should be processed');

        // [THEN] The additional fields should not be set on the purchase invoice line
        EDocument.Get(EDocument."Entry No");
        PurchaseHeader.Get(EDocument."Document Record ID");
        PurchaseLine.SetRange("Document No.", PurchaseHeader."No.");
        PurchaseLine.SetRange("Document Type", PurchaseHeader."Document Type");
        PurchaseLine.FindFirst();
        Assert.AreNotEqual(Location.Code, PurchaseLine."Location Code", 'The location code should not be set on the purchase line.');
    end;

    local procedure Initialize(Integration: Enum "Service Integration")
    var
        TransformationRule: Record "Transformation Rule";
        EDocument: Record "E-Document";
        EDocDataStorage: Record "E-Doc. Data Storage";
        EDocumentsSetup: Record "E-Documents Setup";
        EDocumentServiceStatus: Record "E-Document Service Status";
        EDocPurchLineFieldSetup: Record "EDoc. Purch. Line Field Setup";
    begin
        LibraryLowerPermission.SetOutsideO365Scope();
        LibraryVariableStorage.Clear();
        Clear(EDocImplState);
        EDocPurchLineFieldSetup.DeleteAll();

        if IsInitialized then
            exit;

        EDocument.DeleteAll();
        EDocumentServiceStatus.DeleteAll();
        EDocumentService.DeleteAll();
        EDocDataStorage.DeleteAll();

        LibraryEDoc.SetupStandardVAT();
        LibraryEDoc.SetupStandardSalesScenario(Customer, EDocumentService, Enum::"E-Document Format"::Mock, Integration);
        LibraryEDoc.SetupStandardPurchaseScenario(Vendor, EDocumentService, Enum::"E-Document Format"::Mock, Integration);
        EDocumentService."Import Process" := "E-Document Import Process"::"Version 2.0";
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PDF Mock";
        EDocumentService.Modify();
        EDocumentsSetup.InsertNewExperienceSetup();

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();

        IsInitialized := true;
    end;


}
