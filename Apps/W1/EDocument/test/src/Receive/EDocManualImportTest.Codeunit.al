codeunit 139501 "E-Doc. Manual Import Test"
{
    Subtype = Test;
    TestPermissions = Disabled;
    EventSubscriberInstance = Manual;

    trigger OnRun()
    begin
        IsInitialized := false;
    end;

    var
        PurchaseHeader: Record "Purchase Header";
        VATPostingSetup: Record "VAT Posting Setup";
        LibraryERM: Codeunit "Library - ERM";
        LibraryEDoc: Codeunit "Library - E-Document";
        LibraryPurchase: Codeunit "Library - Purchase";
        LibraryVariableStorage: Codeunit "Library - Variable Storage";
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
        DocumentVendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        DocumentInStream: InStream;
    begin
        // [FEATURE] [E-Document] [Import] [Manual]
        // [SCENARIO] Manually create e-document from stream
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase invoice
        CreateEDocServiceToReceivePurchaseInvoice(EDocService);
        // [GIVEN] Vendor with VAT Posting Setup
        CreateVendorWithVatPostingSetup(DocumentVendor);
        // [GIVEN] Item with item reference
        CreateItemWithReference(Item);
        // [GIVEN] Incoming PEPPOL document stream
        CreateIncomingPEPPOLBlob(DocumentVendor, TempBlob);
        TempBlob.CreateInStream(DocumentInStream, TextEncoding::UTF8);

        // [WHEN] Creating e-document from stream
        Clear(EDocument);
        CreateEDocFromStream(EDocument, EDocService, DocumentInStream, 'test.xml');

        // [THEN] Document and attachments are created correctly
        EDocument.Get(EDocument."Entry No"); // Load the record
        VerifyDocumentCreated(EDocument);
    end;

    [Test]
    procedure ManuallyCreateEDocumentFromStreamTwiceShouldThrowError()
    var
        EDocService: Record "E-Document Service";
        EDocument: Record "E-Document";
        Item: Record Item;
        DocumentVendor: Record Vendor;
        TempBlob: Codeunit "Temp Blob";
        DocumentInStream: InStream;
        DocumentInStream2: InStream;
    begin
        // [FEATURE] [E-Document] [Import] [Manual] [Duplicate]
        // [SCENARIO] Manually create e-document from stream twice should throw error for duplicate document
        Initialize();

        // [GIVEN] e-Document service to receive one single purchase invoice
        CreateEDocServiceToReceivePurchaseInvoice(EDocService);
        // [GIVEN] Vendor with VAT Posting Setup
        CreateVendorWithVatPostingSetup(DocumentVendor);
        // [GIVEN] Item with item reference
        CreateItemWithReference(Item);
        // [GIVEN] Incoming PEPPOL document stream (creating two streams from same blob for two imports)
        CreateIncomingPEPPOLBlob(DocumentVendor, TempBlob);
        TempBlob.CreateInStream(DocumentInStream, TextEncoding::UTF8);
        TempBlob.CreateInStream(DocumentInStream2, TextEncoding::UTF8);

        // [WHEN] Creating first e-document from stream
        Clear(EDocument);
        CreateEDocFromStream(EDocument, EDocService, DocumentInStream, 'test.xml');

        // [THEN] First document should be created successfully
        EDocument.Get(EDocument."Entry No"); // Load the record
        VerifyDocumentCreated(EDocument);

        // [WHEN] Trying to create second e-document from same stream
        Clear(EDocument);
        asserterror CreateEDocFromStream(EDocument, EDocService, DocumentInStream2, 'test2.xml');

        // [THEN] Error should be thrown about duplicate document
        Assert.ExpectedError(GetDuplciateErrorText(EDocument));
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

    local procedure CreateEDocFromStream(
        var EDocument: Record "E-Document";
        var EDocService: Record "E-Document Service";
        var DocumentInStream: InStream;
        FileName: Text)
    var
        EDocImport: Codeunit "E-Doc. Import";
    begin
        EDocImport.SetHideDialogs(true);
        EDocImport.HandleSingleDocumentUpload(DocumentInStream, EDocument, EDocService, FileName);
    end;

    local procedure VerifyDocumentCreated(var EDocument: Record "E-Document")
    begin
        Assert.AreEqual(
            Enum::"E-Document Service Status"::"Imported Document Created",
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
        Clear(PurchaseHeader);
        Clear(LibraryVariableStorage);

        PurchaseHeader.DeleteAll(false);
        DocumentAttachment.DeleteAll(false);

        EDocument.DeleteAll(false);

        if IsInitialized then
            exit;

        LibraryERM.CreateVATPostingSetupWithAccounts(VATPostingSetup, Enum::"Tax Calculation Type"::"Normal VAT", 1);
        IsInitialized := true;
    end;

    local procedure GetLastServiceStatus(EDocument: Record "E-Document"): Enum "E-Document Service Status"
    var
        EDocServiceStatus: Record "E-Document Service Status";
    begin
        EDocServiceStatus.SetRange("E-Document Entry No", EDocument."Entry No");
        if EDocServiceStatus.FindLast() then
            exit(EDocServiceStatus.Status);
    end;

    local procedure HasErrors(EDocument: Record "E-Document"): Boolean
    var
        ErrorMessage: Record "Error Message";
    begin
        ErrorMessage.SetRange("Context Record ID", EDocument.RecordId);
        exit(not ErrorMessage.IsEmpty());
    end;

    local procedure CreateVendorWithVatPostingSetup(var DocumentVendor: Record Vendor)
    begin
        LibraryPurchase.CreateVendorWithVATRegNo(DocumentVendor);
        DocumentVendor."VAT Bus. Posting Group" := VATPostingSetup."VAT Bus. Posting Group";
        DocumentVendor."VAT Registration No." := 'GB123456789';
        DocumentVendor."Receive E-Document To" := Enum::"E-Document Type"::"Purchase Invoice";
        DocumentVendor.Modify(false);
    end;

    local procedure CreateItemWithReference(var Item: Record Item)
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

    local procedure GetDuplciateErrorText(EDocument: Record "E-Document"): Text
    var
        EDocumentAlreadyExistErr: Label 'E-Document with %1 %2, %3 %4 and %5 %6 already exists.', Comment = '%1 - Incoming E-Document No. field caption, %2 - Incoming E-Document No. value, %3 - Bill-to/Pay-to No. field caption, %4 - Bill-to/Pay-to No. value, %5 - Document Date field caption, %6 - Document Date value.';
    begin
        exit(StrSubstNo(EDocumentAlreadyExistErr, EDocument.FieldCaption("Incoming E-Document No."), EDocument."Incoming E-Document No.", EDocument.FieldCaption("Bill-to/Pay-to No."), EDocument."Bill-to/Pay-to No.", EDocument.FieldCaption("Document Date"), EDocument."Document Date"));
    end;
}
