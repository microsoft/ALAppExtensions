namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Helpers;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Purchases.Vendor;
using System.Utilities;

codeunit 28008 "E-Document PINT A-NZ Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        GLNSchemeIdTok: Label '0088', Locked = true;

    /// <summary>
    /// Reads a PINT A-NZ format XML document and converts it into a draft purchase document.
    /// This procedure processes both Invoice and CreditNote document types and populates the E-Document Purchase Header with the extracted data.
    /// </summary>
    /// <param name="EDocument">The E-Document record that contains the document metadata and information.</param>
    /// <param name="TempBlob">A temporary blob containing the XML document stream to be processed.</param>
    /// <returns>Returns an enum indicating that the process resulted in a purchase document draft.</returns>
    internal procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        PINTANZXml: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        CommonAggregateComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        CommonBasicComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
        DefaultInvoiceTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
        DefaultCreditNoteTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2', Locked = true;
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        XmlDocument.ReadFrom(TempBlob.CreateInStream(TextEncoding::UTF8), PINTANZXml);
        XmlNamespaces.AddNamespace('cac', CommonAggregateComponentsTok);
        XmlNamespaces.AddNamespace('cbc', CommonBasicComponentsTok);
        XmlNamespaces.AddNamespace('inv', DefaultInvoiceTok);
        XmlNamespaces.AddNamespace('cn', DefaultCreditNoteTok);

        PINTANZXml.GetRoot(XmlElement);
        case UpperCase(XmlElement.LocalName()) of
            'INVOICE':
                PopulateEDocumentForInvoice(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
            'CREDITNOTE':
                PopulateEDocumentForCreditNote(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
        end;

        EDocumentPurchaseHeader.Modify(false);
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    /// <summary>
    /// Displays a readable view of the processed E-Document purchase information.
    /// This procedure opens a page showing the purchase header and lines in a user-friendly format for review.
    /// </summary>
    /// <param name="EDocument">The E-Document record that contains the document to be displayed.</param>
    /// <param name="TempBlob">A temporary blob containing the document data (not used in current implementation).</param>
    internal procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    var
        EDocPurchaseHeader: Record "E-Document Purchase Header";
        EDocPurchaseLine: Record "E-Document Purchase Line";
        EDocReadablePurchaseDoc: Page "E-Doc. Readable Purchase Doc.";
    begin
        EDocPurchaseHeader.GetFromEDocument(EDocument);
        EDocPurchaseLine.SetRange("E-Document Entry No.", EDocPurchaseHeader."E-Document Entry No.");
        EDocReadablePurchaseDoc.SetBuffer(EDocPurchaseHeader, EDocPurchaseLine);
        EDocReadablePurchaseDoc.Run();
    end;

#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
    local procedure PopulateEDocumentForInvoice(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Invoice";
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
        EDocumentXMLHelper.SetDateValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetNumberValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(PINTANZXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader.Total);
        EDocumentPurchaseHeader."Amount Due" := EDocumentPurchaseHeader.Total;
        VendorNo := ParseAccountingSupplierPartyForPurchaseHeader(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'inv:Invoice');
        ParseAccountingCustomerPartyForPurchaseHeader(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, 'inv:Invoice');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertPINTANZPurchaseInvoiceLines(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.");
    end;

    local procedure PopulateEDocumentForCreditNote(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Credit Memo";
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
        EDocumentXMLHelper.SetDateValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cac:PaymentMeans/cbc:PaymentDueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetNumberValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(PINTANZXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader.Total);
        EDocumentPurchaseHeader."Amount Due" := EDocumentPurchaseHeader.Total;
        VendorNo := ParseAccountingSupplierPartyForPurchaseHeader(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'cn:CreditNote');
        ParseAccountingCustomerPartyForPurchaseHeader(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, 'cn:CreditNote');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertPINTANZPurchaseInvoiceLines(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.");
    end;
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField

    local procedure ParseAccountingSupplierPartyForPurchaseHeader(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document"; DocumentType: Text) VendorNo: Code[20]
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorName, VendorAddress, VendorParticipantId : Text;
        VATRegistrationNo: Text[20];
        GLN: Code[13];
        ABN: Code[11];
        XMLNode: XmlNode;
        ABNSchemeIdTok: Label '0151', Locked = true;
        BasePathTxt: Text;
    begin
        BasePathTxt := '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), EDocumentPurchaseHeader."Vendor Address");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:Contact/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Contact Name"), EDocumentPurchaseHeader."Vendor Contact Name");
        if PINTANZXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            if XMLNode.AsXmlAttribute().Value() = ABNSchemeIdTok then
                ABN := CopyStr(EDocumentXMLHelper.GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID'), 1, MaxStrLen(ABN));
            if XMLNode.AsXmlAttribute().Value() = GLNSchemeIdTok then begin
                GLN := CopyStr(EDocumentXMLHelper.GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID'), 1, MaxStrLen(GLN));
                EDocumentPurchaseHeader."Vendor GLN" := GLN;
            end;
            VendorParticipantId := XMLNode.AsXmlAttribute().Value() + ':' + EDocumentXMLHelper.GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
        end;
        VATRegistrationNo := EDocumentPurchaseHeader."Vendor VAT Id";
        VendorName := EDocumentPurchaseHeader."Vendor Company Name";
        VendorAddress := EDocumentPurchaseHeader."Vendor Address";
        if not FindVendorByABN(VendorNo, ABN) then
            if not FindVendorByVATRegNoOrGLN(VendorNo, VATRegistrationNo, GLN) then
                if not FindVendorByParticipantId(VendorNo, EDocument, VendorParticipantId) then
                    VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
    end;

    local procedure ParseAccountingCustomerPartyForPurchaseHeader(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; DocumentType: Text)
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        ReceivingId: Text[250];
        SchemaId, CompanyIdentifierValue : Text;
        BasePathTxt: Text;
        XMLNode: XmlNode;
    begin
        BasePathTxt := '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), EDocumentPurchaseHeader."Customer Company Name");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), EDocumentPurchaseHeader."Customer Address");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), EDocumentPurchaseHeader."Customer VAT Id");
        if PINTANZXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemaId := XMLNode.AsXmlAttribute().Value();
            CompanyIdentifierValue := EDocumentXMLHelper.GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            if SchemaId = GLNSchemeIdTok then
                EDocumentPurchaseHeader."Customer GLN" := CopyStr(CompanyIdentifierValue, 1, MaxStrLen(EDocumentPurchaseHeader."Customer GLN"));
            ReceivingId := CopyStr(SchemaId, 1, (MaxStrLen(EDocumentPurchaseHeader."Customer Company Id") - 1)) + ':';
            ReceivingId += CopyStr(CompanyIdentifierValue, 1, MaxStrLen(EDocumentPurchaseHeader."Customer Company Id") - StrLen(ReceivingId));
            EDocumentPurchaseHeader."Customer Company Id" := ReceivingId;
        end;
        if (EDocumentPurchaseHeader."Customer GLN" = '') and PINTANZXml.SelectSingleNode(BasePathTxt + '/cac:PartyIdentification/cbc:ID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemaId := XMLNode.AsXmlAttribute().Value();
            CompanyIdentifierValue := EDocumentXMLHelper.GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyIdentification/cbc:ID');
            if SchemaId = GLNSchemeIdTok then
                EDocumentPurchaseHeader."Customer GLN" := CopyStr(CompanyIdentifierValue, 1, MaxStrLen(EDocumentPurchaseHeader."Customer GLN"));
        end;
    end;

    local procedure InsertPINTANZPurchaseInvoiceLines(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        NewLineXML: XmlDocument;
        LineXMLList: XmlNodeList;
        LineXMLNode: XmlNode;
        i: Integer;
        InvoiceLinePathTok: Label '/inv:Invoice/cac:InvoiceLine', Locked = true;
        CreditNoteLinePathTok: Label '/cn:CreditNote/cac:CreditNoteLine', Locked = true;
    begin
        if not PINTANZXml.SelectNodes(InvoiceLinePathTok, XmlNamespaces, LineXMLList) then
            if not PINTANZXml.SelectNodes(CreditNoteLinePathTok, XmlNamespaces, LineXMLList) then
                exit;

        i := 0;
        foreach LineXMLNode in LineXMLList do begin
            i += 1;
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Init();
            EDocumentPurchaseLine."E-Document Entry No." := EDocumentEntryNo;
            EDocumentPurchaseLine."Line No." := i * 10000;
            Clear(NewLineXML);
            NewLineXML := XmlDocument.Create();
            NewLineXML.Add(LineXMLNode.AsXmlElement());
            PopulatePINTANZPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert(false);
        end;
    end;

    local procedure PopulatePINTANZPurchaseLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
    begin
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        if EDocumentPurchaseLine."Product Code" = '' then
            EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cac:Item/cac:SellersItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cac:Item/cbc:Name', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        if EDocumentPurchaseLine.Description = '' then
            EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cac:Item/cbc:Name', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cbc:InvoicedQuantity', EDocumentPurchaseLine.Quantity);
        if EDocumentPurchaseLine.Quantity = 0 then
            EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cbc:CreditedQuantity', EDocumentPurchaseLine.Quantity);
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), EDocumentPurchaseLine."Unit of Measure");
        if EDocumentPurchaseLine."Unit of Measure" = '' then
            EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cbc:CreditedQuantity/@unitCode', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), EDocumentPurchaseLine."Unit of Measure");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cac:Price/cbc:PriceAmount', EDocumentPurchaseLine."Unit Price");
        if EDocumentPurchaseLine."Unit Price" = 0 then
            EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cac:Price/cbc:PriceAmount', EDocumentPurchaseLine."Unit Price");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cbc:LineExtensionAmount', EDocumentPurchaseLine."Sub Total");
        if EDocumentPurchaseLine."Sub Total" = 0 then
            EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cbc:LineExtensionAmount', EDocumentPurchaseLine."Sub Total");
        EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cbc:LineExtensionAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        if EDocumentPurchaseLine."Currency Code" = '' then
            EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, 'cac:CreditNoteLine/cbc:LineExtensionAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
    end;

    local procedure FindVendorByABN(var VendorNo: Code[20]; InputABN: Code[11]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if InputABN = '' then
            exit(false);

        Vendor.SetLoadFields(ABN);
        Vendor.SetRange(ABN, InputABN);
        if Vendor.FindFirst() then
            VendorNo := Vendor."No.";
        exit(VendorNo <> '');
    end;

    local procedure FindVendorByVATRegNoOrGLN(var VendorNo: Code[20]; VATRegistrationNo: Text[20]; InputGLN: Code[13]): Boolean
    begin
        VendorNo := EDocumentImportHelper.FindVendor('', InputGLN, VATRegistrationNo);
        exit(VendorNo <> '');
    end;

    local procedure FindVendorByParticipantId(var VendorNo: Code[20]; EDocument: Record "E-Document"; VendorParticipantId: Text): Boolean
    var
        EDocumentService: Record "E-Document Service";
        ServiceParticipant: Record "Service Participant";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        if VendorParticipantId = '' then
            exit(false);

        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        ServiceParticipant.SetRange("Participant Type", ServiceParticipant."Participant Type"::Vendor);
        ServiceParticipant.SetRange("Participant Identifier", VendorParticipantId);
        ServiceParticipant.SetRange(Service, EDocumentService.Code);
        if not ServiceParticipant.FindFirst() then begin
            ServiceParticipant.SetRange(Service);
            if ServiceParticipant.FindFirst() then;
        end;

        VendorNo := ServiceParticipant.Participant;
        exit(VendorNo <> '');
    end;

    procedure ResetDraft(EDocument: Record "E-Document")
    var
        EDocPurchaseHeader: Record "E-Document Purchase Header";
    begin
        EDocPurchaseHeader.GetFromEDocument(EDocument);
        EDocPurchaseHeader.Delete(true);
    end;
}