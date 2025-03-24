codeunit 139891 "E-Document Structured Tests"
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
        IsInitialized: Boolean;

    #region ADI JSON
    [Test]
    procedure ProcessADIInvoiceReceivedData()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocLogRecord: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentLog: Codeunit "E-Document Log";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"Azure Document Intelligence";
        EDocumentService.Modify();
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. Data Storage Blob Type"::"JSON", NavApp.GetResourceAsText('capi-invoice-0.json'));
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Readable);

        EDocument."Structured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Readable);
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Read into IR";

        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        Assert.AreEqual(Enum::"Import E-Doc. Proc. Status"::"Ready for draft", EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');

        ValidateADICreatedEDocumentPurchaseInvoice(EDocument."Entry No");
    end;

    local procedure ValidateADICreatedEDocumentPurchaseInvoice(EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        EDocumentPurchaseHeader.Get(EDocumentEntryNo);

        Assert.AreEqual('MICROSOFT CORPORATION', EDocumentPurchaseHeader."Customer Company Name", 'The customer company name does not allign with the mock data.');
        Assert.AreEqual('CID-12345', EDocumentPurchaseHeader."Customer Company Id", 'The customer company id does not allign with the mock data.');
        Assert.AreEqual('PO-3333', EDocumentPurchaseHeader."Purchase Order No.", 'The purchase order number does not allign with the mock data.');
        Assert.AreEqual('INV-100', EDocumentPurchaseHeader."Sales Invoice No.", 'The sales invoice number does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(15, 12, 2019), EDocumentPurchaseHeader."Due Date", 'The due date does not allign with the mock data.');
        Assert.AreEqual('CONTOSO LTD.', EDocumentPurchaseHeader."Vendor Company Name", 'The vendor name does not allign with the mock data.');
        Assert.AreEqual('123 456th St New York, NY, 10001', EDocumentPurchaseHeader."Vendor Address", 'The vendor address does not allign with the mock data.');
        Assert.AreEqual('Contoso Headquarters', EDocumentPurchaseHeader."Vendor Address Recipient", 'The vendor address recipient does not allign with the mock data.');
        Assert.AreEqual('123 Other St, Redmond WA, 98052', EDocumentPurchaseHeader."Customer Address", 'The customer address does not allign with the mock data.');
        Assert.AreEqual('Microsoft Corp', EDocumentPurchaseHeader."Customer Address Recipient", 'The customer address recipient does not allign with the mock data.');
        Assert.AreEqual('123 Bill St, Redmond WA, 98052', EDocumentPurchaseHeader."Billing Address", 'The billing address does not allign with the mock data.');
        Assert.AreEqual('Microsoft Finance', EDocumentPurchaseHeader."Billing Address Recipient", 'The billing address recipient does not allign with the mock data.');
        Assert.AreEqual('123 Ship St, Redmond WA, 98052', EDocumentPurchaseHeader."Shipping Address", 'The shipping address does not allign with the mock data.');
        Assert.AreEqual('Microsoft Delivery', EDocumentPurchaseHeader."Shipping Address Recipient", 'The shipping address recipient does not allign with the mock data.');
        Assert.AreEqual(100, EDocumentPurchaseHeader."Sub Total", 'The sub total does not allign with the mock data.');
        Assert.AreEqual(10, EDocumentPurchaseHeader."Total VAT", 'The total tax does not allign with the mock data.');
        Assert.AreEqual(110, EDocumentPurchaseHeader.Total, 'The total does not allign with the mock data.');
        Assert.AreEqual(610, EDocumentPurchaseHeader."Amount Due", 'The amount due does not allign with the mock data.');
        Assert.AreEqual(500, EDocumentPurchaseHeader."Previous Unpaid Balance", 'The previous unpaid balance does not allign with the mock data.');
        Assert.AreEqual('123 Remit St New York, NY, 10001', EDocumentPurchaseHeader."Remittance Address", 'The remittance address does not allign with the mock data.');
        Assert.AreEqual('Contoso Billing', EDocumentPurchaseHeader."Remittance Address Recipient", 'The remittance address recipient does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(14, 10, 2019), EDocumentPurchaseHeader."Service Start Date", 'The service start date does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(14, 11, 2019), EDocumentPurchaseHeader."Service End Date", 'The service end date does not allign with the mock data.');

#pragma warning disable AA0210
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
#pragma warning restore AA0210
        EDocumentPurchaseLine.FindFirst();
        Assert.AreEqual(60, EDocumentPurchaseLine."Sub Total", 'The amount does not allign with the mock data.');
        Assert.AreEqual('Consulting Services', EDocumentPurchaseLine.Description, 'The description does not allign with the mock data.');
        Assert.AreEqual(30, EDocumentPurchaseLine."Unit Price", 'The unit price does not allign with the mock data.');
        Assert.AreEqual(2, EDocumentPurchaseLine.Quantity, 'The quantity does not allign with the mock data.');
        Assert.AreEqual('A123', EDocumentPurchaseLine."Product Code", 'The product code does not allign with the mock data.');
        Assert.AreEqual('hours', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(4, 3, 2021), EDocumentPurchaseLine.Date, 'The date does not allign with the mock data.');
        Assert.AreEqual(6, EDocumentPurchaseLine."VAT Rate", 'The amount does not allign with the mock data.');

#pragma warning disable AA0210
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
#pragma warning restore AA0210
        EDocumentPurchaseLine.SetRange("E-Document Line Id", EDocumentPurchaseLine."E-Document Line Id" + 1);
        EDocumentPurchaseLine.FindFirst();
        Assert.AreEqual(30, EDocumentPurchaseLine."Sub Total", 'The amount does not allign with the mock data.');
        Assert.AreEqual('Document Fee', EDocumentPurchaseLine.Description, 'The description does not allign with the mock data.');
        Assert.AreEqual(10, EDocumentPurchaseLine."Unit Price", 'The unit price does not allign with the mock data.');
        Assert.AreEqual(3, EDocumentPurchaseLine.Quantity, 'The quantity does not allign with the mock data.');
        Assert.AreEqual('B456', EDocumentPurchaseLine."Product Code", 'The product code does not allign with the mock data.');
        Assert.AreEqual('', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(5, 3, 2021), EDocumentPurchaseLine.Date, 'The date does not allign with the mock data.');
        Assert.AreEqual(3, EDocumentPurchaseLine."VAT Rate", 'The amount does not allign with the mock data.');

#pragma warning disable AA0210
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
#pragma warning restore AA0210
        EDocumentPurchaseLine.SetRange("E-Document Line Id", EDocumentPurchaseLine."E-Document Line Id" + 1);
        EDocumentPurchaseLine.FindFirst();
        Assert.AreEqual(10, EDocumentPurchaseLine."Sub Total", 'The amount does not allign with the mock data.');
        Assert.AreEqual('Printing Fee', EDocumentPurchaseLine.Description, 'The description does not allign with the mock data.');
        Assert.AreEqual(1, EDocumentPurchaseLine."Unit Price", 'The unit price does not allign with the mock data.');
        Assert.AreEqual(10, EDocumentPurchaseLine.Quantity, 'The quantity does not allign with the mock data.');
        Assert.AreEqual('C789', EDocumentPurchaseLine."Product Code", 'The product code does not allign with the mock data.');
        Assert.AreEqual('pages', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(6, 3, 2021), EDocumentPurchaseLine.Date, 'The date does not allign with the mock data.');
        Assert.AreEqual(1, EDocumentPurchaseLine."VAT Rate", 'The amount does not allign with the mock data.');
    end;
    #endregion

    #region PEPPOL 3.0 XML
    [Test]
    procedure ProcessPEPPOLInvoiceReceivedData()
    var
        EDocument: Record "E-Document";
        EDocImportParameters: Record "E-Doc. Import Parameters";
        EDocLogRecord: Record "E-Document Log";
        EDocImport: Codeunit "E-Doc. Import";
        EDocumentProcessing: Codeunit "E-Document Processing";
        EDocumentLog: Codeunit "E-Document Log";
    begin
        Initialize(Enum::"Service Integration"::"Mock");
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PEPPOL BIS 3.0";
        EDocumentService.Modify();
        LibraryEDoc.CreateInboundEDocument(EDocument, EDocumentService);

        EDocumentLog.SetBlob('Test', Enum::"E-Doc. Data Storage Blob Type"::"XML", NavApp.GetResourceAsText('peppol-invoice-0.xml'));
        EDocumentLog.SetFields(EDocument, EDocumentService);
        EDocLogRecord := EDocumentLog.InsertLog(Enum::"E-Document Service Status"::Imported, Enum::"Import E-Doc. Proc. Status"::Readable);

        EDocument."Structured Data Entry No." := EDocLogRecord."E-Doc. Data Storage Entry No.";
        EDocument.Modify();

        EDocumentProcessing.ModifyEDocumentProcessingStatus(EDocument, "Import E-Doc. Proc. Status"::Readable);
        EDocImportParameters."Step to Run" := "Import E-Document Steps"::"Read into IR";

        EDocImport.ProcessIncomingEDocument(EDocument, EDocImportParameters);
        Assert.AreEqual(Enum::"Import E-Doc. Proc. Status"::"Ready for draft", EDocument.GetEDocumentImportProcessingStatus(), 'The status should be updated to the one after the step executed.');

        ValidatePEPPOLCreatedEDocumentPurchaseInvoice(EDocument."Entry No");
    end;

    local procedure ValidatePEPPOLCreatedEDocumentPurchaseInvoice(EDocumentEntryNo: Integer)
    var
        GLSetup: Record "General Ledger Setup";
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
    begin
        GLSetup.Get();
        EDocumentPurchaseHeader.Get(EDocumentEntryNo);
        Assert.AreEqual('103033', EDocumentPurchaseHeader."Sales Invoice No.", 'The sales invoice number does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(22, 01, 2026), EDocumentPurchaseHeader."Document Date", 'The invoice date does not allign with the mock data.');
        Assert.AreEqual(DMY2Date(22, 02, 2026), EDocumentPurchaseHeader."Due Date", 'The due date does not allign with the mock data.');
        if GLSetup."LCY Code" = 'GBP' then
            Assert.AreEqual('', EDocumentPurchaseHeader."Currency Code", 'The currency code should be empty because we are working with LCY (GBP).')
        else
            Assert.AreEqual('GBP', EDocumentPurchaseHeader."Currency Code", 'The currency code does not allign with the mock data.');

        Assert.AreEqual('2', EDocumentPurchaseHeader."Purchase Order No.", 'The purchase order number does not allign with the mock data.');
        // Assert.AreEqual('', EDocumentPurchaseHeader."Vendor GLN", 'The endpoint schema is not provided to populate the GLN.');
        Assert.AreEqual('CRONUS International', EDocumentPurchaseHeader."Vendor Company Name", 'The vendor name does not allign with the mock data.');
        Assert.AreEqual('Main Street, 14', EDocumentPurchaseHeader."Vendor Address", 'The vendor street does not allign with the mock data.');
        Assert.AreEqual('GB123456789', EDocumentPurchaseHeader."Vendor VAT Id", 'The vendor VAT id does not allign with the mock data.');
        Assert.AreEqual('Jim Olive', EDocumentPurchaseHeader."Vendor Contact Name", 'The vendor contact name does not allign with the mock data.');
        Assert.AreEqual('The Cannon Group PLC', EDocumentPurchaseHeader."Customer Company Name", 'The customer name does not allign with the mock data.');
        Assert.AreEqual('GB789456278', EDocumentPurchaseHeader."Customer VAT Id", 'The customer VAT id does not allign with the mock data.');
        Assert.AreEqual('192 Market Square', EDocumentPurchaseHeader."Customer Address", 'The customer address does not allign with the mock data.');

#pragma warning disable AA0210
        EDocumentPurchaseLine.SetRange("E-Document Entry No.", EDocumentEntryNo);
#pragma warning restore AA0210
        EDocumentPurchaseLine.FindFirst();
        Assert.AreEqual(1, EDocumentPurchaseLine."Quantity", 'The quantity in the purchase line does not allign with the mock data.');
        Assert.AreEqual('PCS', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure in the purchase line does not allign with the mock data.');
        Assert.AreEqual(4000, EDocumentPurchaseLine."Sub Total", 'The total amount before taxes in the purchase line does not allign with the mock data.');
        if GLSetup."LCY Code" = 'GBP' then
            Assert.AreEqual('', EDocumentPurchaseHeader."Currency Code", 'The currency code in the purchase line should be empty because we are working with LCY (GBP).')
        else
            Assert.AreEqual('GBP', EDocumentPurchaseHeader."Currency Code", 'The currency code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", 'The total discount in the purchase line does not allign with the mock data.');
        Assert.AreEqual('Bicycle', EDocumentPurchaseLine.Description, 'The product description in the purchase line does not allign with the mock data.');
        Assert.AreEqual('1000', EDocumentPurchaseLine."Product Code", 'The product code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", 'The VAT rate in the purchase line does not allign with the mock data.');
        Assert.AreEqual(4000, EDocumentPurchaseLine."Unit Price", 'The unit price in the purchase line does not allign with the mock data.');

        EDocumentPurchaseLine.SetRange("E-Document Line Id", EDocumentPurchaseLine."E-Document Line Id" + 1);
        EDocumentPurchaseLine.FindFirst();
        Assert.AreEqual(2, EDocumentPurchaseLine."Quantity", 'The quantity in the purchase line does not allign with the mock data.');
        Assert.AreEqual('PCS', EDocumentPurchaseLine."Unit of Measure", 'The unit of measure in the purchase line does not allign with the mock data.');
        Assert.AreEqual(10000, EDocumentPurchaseLine."Sub Total", 'The total amount before taxes in the purchase line does not allign with the mock data.');
        if GLSetup."LCY Code" = 'GBP' then
            Assert.AreEqual('', EDocumentPurchaseHeader."Currency Code", 'The currency code in the purchase line should be empty because we are working with LCY (GBP).')
        else
            Assert.AreEqual('GBP', EDocumentPurchaseHeader."Currency Code", 'The currency code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(0, EDocumentPurchaseLine."Total Discount", 'The total discount in the purchase line does not allign with the mock data.');
        Assert.AreEqual('Bicycle v2', EDocumentPurchaseLine.Description, 'The product description in the purchase line does not allign with the mock data.');
        Assert.AreEqual('2000', EDocumentPurchaseLine."Product Code", 'The product code in the purchase line does not allign with the mock data.');
        Assert.AreEqual(25, EDocumentPurchaseLine."VAT Rate", 'The VAT rate in the purchase line does not allign with the mock data.');
        Assert.AreEqual(5000, EDocumentPurchaseLine."Unit Price", 'The unit price in the purchase line does not allign with the mock data.');

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
        EDocumentService."E-Document Structured Format" := "E-Document Structured Format"::"PDF Mock";
        EDocumentService.Modify();
        EDocumentsSetup.InsertNewExperienceSetup();

        TransformationRule.DeleteAll();
        TransformationRule.CreateDefaultTransformations();

        IsInitialized := true;
    end;
}