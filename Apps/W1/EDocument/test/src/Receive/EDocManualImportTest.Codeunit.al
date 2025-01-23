codeunit 139501 "E-Doc. Manual Import Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    var
        PurchaseHeader: Record "Purchase Header";
        LibraryERM: Codeunit "Library - ERM";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
        EDocImplState: Codeunit "E-Doc. Impl. State";
        Assert: Codeunit Assert;
        EDocReceiveFiles: Codeunit "E-Doc. Receive Files";
        LibraryRandom: Codeunit "Library - Random";
        IsInitialized: Boolean;

    [Test]
    procedure ManuallyCreateEDocumentFromStream()
    var
        EDocService: Record "E-Document Service";
        EDocument: Record "E-Document";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        DocumentVendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        DocumentInStream: InStream;
        DuplicateExists: Boolean;
        NotProcessedDocuments: Integer;
    begin
        // [FEATURE] [E-Document] [Import] [Manual]
        // [SCENARIO] Manually create e-document from stream
        Initialize();
        BindSubscription(EDocImplState);

        // [GIVEN] e-Document service to receive one single purchase invoice
        CreateEDocServiceToReceivePurchaseInvoice(EDocService);
        // [GIVEN] Vendor with VAT Posting Setup
        CreateVendorWithVatPostingSetup(DocumentVendor, VATPostingSetup);
        // [GIVEN] Item with item reference
        CreateItemWithReference(Item, VATPostingSetup);
        // [GIVEN] Incoming PEPPOL document stream
        CreateIncomingPEPPOLBlob(DocumentVendor, TempBlob);
        TempBlob.CreateInStream(DocumentInStream, TextEncoding::UTF8);

        // [WHEN] Creating e-document from stream
        Clear(EDocument);
        CreateEDocFromStream(EDocument, EDocService, DocumentInStream, false, DuplicateExists, NotProcessedDocuments);

        // [THEN] Document and attachments are created correctly
        VerifyDocumentCreated(EDocument);

        // Cleanup
        UnbindSubscription(EDocImplState);
    end;

    [Test]
    procedure ManuallyCreateTwoEDocumentsFromStreamWithDuplicate()
    var
        EDocService: Record "E-Document Service";
        EDocument: Record "E-Document";
        Item: Record Item;
        VATPostingSetup: Record "VAT Posting Setup";
        DocumentVendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        DocumentInStream, DocumentInStream2 : InStream;
        DuplicateExists: Boolean;
        NotProcessedDocuments: Integer;
    begin
        // [FEATURE] [E-Document] [Import] [Manual]
        // [SCENARIO] Manually create two e-documents from stream where second one will be duplicate
        Initialize();
        BindSubscription(EDocImplState);

        // [GIVEN] e-Document service to receive invoices
        CreateEDocServiceToReceivePurchaseInvoice(EDocService);
        // [GIVEN] Vendor with VAT Posting Setup
        CreateVendorWithVatPostingSetup(DocumentVendor, VATPostingSetup);
        // [GIVEN] Item with item reference
        CreateItemWithReference(Item, VATPostingSetup);
        // [GIVEN] Two incoming PEPPOL document streams with same document number
        CreateIncomingPEPPOLBlob(DocumentVendor, TempBlob);
        TempBlob.CreateInStream(DocumentInStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DocumentInStream2, TextEncoding::UTF8);

        // [WHEN] Creating first e-document from stream
        Clear(EDocument);
        CreateEDocFromStream(EDocument, EDocService, DocumentInStream, true, DuplicateExists, NotProcessedDocuments);

        // [THEN] Document and attachments are created correctly for first document
        VerifyDocumentCreated(EDocument);
        Assert.IsFalse(DuplicateExists, 'First document should not be duplicate');
        Assert.AreEqual(0, NotProcessedDocuments, 'Wrong number of not processed documents');

        // [WHEN] Creating second e-document from stream (duplicate)
        Clear(EDocument);
        CreateEDocFromStream(EDocument, EDocService, DocumentInStream2, true, DuplicateExists, NotProcessedDocuments);

        // [THEN] Second document is skipped as duplicate 
        Assert.IsTrue(DuplicateExists, 'Second document should be marked as duplicate');
        Assert.AreEqual(1, NotProcessedDocuments, 'Wrong number of not processed documents');
        Assert.AreEqual(0, EDocument."Entry No", 'Duplicate document should not be created');

        // Cleanup
        UnbindSubscription(EDocImplState);
    end;

    local procedure CreateEDocServiceToReceivePurchaseInvoice(var EDocService: Record "E-Document Service")
    begin
        LibraryEDoc.CreateTestReceiveServiceForEDoc(EDocService, Enum::"Service Integration"::"Mock");
        EDocService."Document Format" := "E-Document Format"::"PEPPOL BIS 3.0";
        SetDefaultEDocServiceValues(EDocService);
    end;

    local procedure CreateIncomingPEPPOLBlob(DocumentVendor: Record Vendor; var TempBlob: Codeunit "Temp Blob"): Text
    var
        TempXMLBuffer: Record "XML Buffer" temporary;
        IncommingDocNo: Text[20];
        DocInstream: InStream;
    begin
        TempXMLBuffer.LoadFromText(EDocReceiveFiles.GetDocument1());
        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Type, TempXMLBuffer.Type::Element);
        TempXMLBuffer.SetRange(Path, '/Invoice/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID');
        TempXMLBuffer.FindFirst();
        TempXMLBuffer.Value := DocumentVendor."VAT Registration No.";
        TempXMLBuffer.Modify(false);

        TempXMLBuffer.Reset();
        TempXMLBuffer.SetRange(Path, '/Invoice/cbc:ID');
        TempXMLBuffer.FindFirst();
        IncommingDocNo := LibraryRandom.RandText(20);
        TempXMLBuffer.Value := IncommingDocNo;
        TempXMLBuffer.Modify(false);

        TempXMLBuffer.Reset();
        TempXMLBuffer.FindFirst();
        TempXMLBuffer.Save(TempBlob);
        TempBlob.CreateInStream(DocInstream, TextEncoding::UTF8);
        exit(IncommingDocNo);
    end;

    local procedure CreateEDocFromStream(var EDocument: Record "E-Document"; var EDocService: Record "E-Document Service"; var DocumentInStream: InStream; MultipleDocuments: Boolean; var DuplicateExists: Boolean; var NotProcessedDocuments: Integer)
    var
        EDocumentReceive: Codeunit "E-Doc. Import";
    begin
        EDocumentReceive.CreateEDocumentFromStream(
            EDocument,
            EDocService,
            DocumentInStream,
            MultipleDocuments,
            DuplicateExists,
            NotProcessedDocuments);
    end;

    local procedure VerifyDocumentCreated(var EDocument: Record "E-Document")
    begin
        Assert.AreEqual(
            Format(Enum::"E-Document Service Status"::"Imported Document Created"),
            GetLastServiceStatus(EDocument),
            'Wrong service status for processed document');
        Assert.IsFalse(HasErrors(EDocument), 'Document should not have errors');

        // Verify purchase invoice is created
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange("No.", EDocument."Document No.");
        PurchaseHeader.FindFirst();
        Assert.RecordCount(PurchaseHeader, 1);
    end;

    local procedure Initialize()
    var
        DocumentAttachment: Record "Document Attachment";
        EDocument: Record "E-Document";
    begin
        Clear(EDocImplState);
        Clear(PurchaseHeader);
        Clear(LibraryVariableStorage);

        PurchaseHeader.DeleteAll(false);
        DocumentAttachment.DeleteAll(false);

        EDocument.DeleteAll();

        if IsInitialized then
            exit;

        IsInitialized := true;
    end;

    local procedure GetLastServiceStatus(EDocument: Record "E-Document"): Text
    var
        EDocServiceStatus: Record "E-Document Service Status";
    begin
        EDocServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        if EDocServiceStatus.FindLast() then
            exit(Format(EDocServiceStatus.Status));
    end;

    local procedure HasErrors(EDocument: Record "E-Document"): Boolean
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", EDocument.RecordId);
        exit(not ErrorMessage.IsEmpty());
    end;

    local procedure CreateVendorWithVatPostingSetup(var DocumentVendor: Record Vendor; var VATPostingSetup: Record "VAT Posting Setup")
    begin
        LibraryPurchase.CreateVendorWithVATRegNo(DocumentVendor);
        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT", 1);
        DocumentVendor."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        DocumentVendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        DocumentVendor.Modify(false);
    end;

    local procedure CreateItemWithReference(var Item: Record Item; var VATPostingSetup: Record "VAT Posting Setup")
    var
        ItemReference: Record "Item Reference";
        GenProductPostingGroup: Record "Gen. Product Posting Group";
        InventoryPostingGroup: Record "Inventory Posting Group";
        UnitofMeasure: Record "Unit of Measure";
        ItemUnitofMeasure: Record "Item Unit of Measure";
        LibraryInventory: Codeunit "Library - Inventory";
    begin
        Item.Init();
        Item."No." := '1000';
        LibraryERM.CreateGenProdPostingGroup(GenProductPostingGroup);
        Item."Gen. Prod. Posting Group" := GenProductPostingGroup."Code";
        Item."VAT Prod. Posting Group" := VATPostingSetup."VAT Prod. Posting Group";
        LibraryInventory.CreateInventoryPostingGroup(InventoryPostingGroup);
        Item."Inventory Posting Group" := InventoryPostingGroup."Code";
        if not Item.Insert(false) then
            Item.Modify(false);
        ItemReference.DeleteAll(false);
        ItemReference."Item No." := Item."No.";
        ItemReference."Reference No." := '1000';
        ItemReference.Insert(false);
        if not UnitofMeasure.Get('PCS') then begin
            UnitofMeasure.Init();
            UnitofMeasure."Code" := 'PCS';
            UnitofMeasure.Insert(false);
        end;
        if not ItemUnitofMeasure.Get(Item."No.", 'PCS') then begin
            ItemUnitofMeasure.Init();
            ItemUnitofMeasure."Item No." := Item."No.";
            ItemUnitofMeasure.Code := UnitofMeasure."Code";
            ItemUnitofMeasure.Insert(false);
        end;
    end;

    local procedure SetDefaultEDocServiceValues(var EDocService: Record "E-Document Service")
    begin
        EDocService."Document Format" := "E-Document Format"::"PEPPOL BIS 3.0";
        EDocService."Lookup Account Mapping" := false;
        EDocService."Lookup Item GTIN" := false;
        EDocService."Lookup Item Reference" := false;
        EDocService."Resolve Unit Of Measure" := false;
        EDocService."Validate Line Discount" := false;
        EDocService."Verify Totals" := false;
        EDocService."Use Batch Processing" := false;
        EDocService."Validate Receiving Company" := false;
        EDocService.Modify(false);
    end;
}
