namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.eServices.EDocument.Helpers;
using Microsoft.Purchases.Vendor;
using Microsoft.Finance.GeneralLedger.Setup;
using System.Utilities;
using Microsoft.eServices.EDocument;

codeunit 28008 "PINT A-NZ Read Draft Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        DocStream: InStream;
        PINTANZXml: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        CommonAggregateComponentsLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
        CommonBasicComponentsLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        DefaultInvoiceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';
        DefaultCreditNoteLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2';
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(DocStream, PINTANZXml);
        XmlNamespaces.AddNamespace('cac', CommonAggregateComponentsLbl);
        XmlNamespaces.AddNamespace('cbc', CommonBasicComponentsLbl);
        XmlNamespaces.AddNamespace('inv', DefaultInvoiceLbl);
        XmlNamespaces.AddNamespace('cn', DefaultCreditNoteLbl);

        PINTANZXml.GetRoot(XmlElement);
        case UpperCase(XmlElement.LocalName()) of
            'INVOICE':
                PopulateEDocumentForInvoice(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
            'CREDITNOTE':
                PopulateEDocumentForCreditNote(PINTANZXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
        end;

        EDocumentPurchaseHeader.Modify();
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
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
        GLNSchemeIdTok: Label '0088', Locked = true;
        BasePathTxt: Text;
    begin
        BasePathTxt := '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), EDocumentPurchaseHeader."Vendor Address");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        EDocumentXMLHelper.SetStringValueInField(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:Contact/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Contact Name"), EDocumentPurchaseHeader."Vendor Contact Name");
        if PINTANZXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            if XMLNode.AsXmlAttribute().Value() = ABNSchemeIdTok then
                ABN := CopyStr(GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID'), 1, MaxStrLen(ABN));
            if XMLNode.AsXmlAttribute().Value() = GLNSchemeIdTok then begin
                GLN := CopyStr(GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID'), 1, MaxStrLen(GLN));
                EDocumentPurchaseHeader."Vendor GLN" := GLN;
            end;

            VendorParticipantId := XMLNode.AsXmlAttribute().Value() + ':' + GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
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
            CompanyIdentifierValue := GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            if SchemaId = '0088' then
                EDocumentPurchaseHeader."Customer GLN" := CopyStr(CompanyIdentifierValue, 1, MaxStrLen(EDocumentPurchaseHeader."Customer GLN"));
            ReceivingId := CopyStr(SchemaId, 1, (MaxStrLen(EDocumentPurchaseHeader."Customer Company Id") - 1)) + ':';
            ReceivingId += CopyStr(CompanyIdentifierValue, 1, MaxStrLen(EDocumentPurchaseHeader."Customer Company Id") - StrLen(ReceivingId));
            EDocumentPurchaseHeader."Customer Company Id" := ReceivingId;
        end;
        if (EDocumentPurchaseHeader."Customer GLN" = '') and PINTANZXml.SelectSingleNode(BasePathTxt + '/cac:PartyIdentification/cbc:ID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemaId := XMLNode.AsXmlAttribute().Value();
            CompanyIdentifierValue := GetNodeValue(PINTANZXml, XmlNamespaces, BasePathTxt + '/cac:PartyIdentification/cbc:ID');
            if SchemaId = '0088' then
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
        InvoiceLinePathLbl: Label '/inv:Invoice/cac:InvoiceLine';
        CreditNoteLinePathLbl: Label '/cn:CreditNote/cac:CreditNoteLine';
    begin
        if not PINTANZXml.SelectNodes(InvoiceLinePathLbl, XmlNamespaces, LineXMLList) then
            if not PINTANZXml.SelectNodes(CreditNoteLinePathLbl, XmlNamespaces, LineXMLList) then
                exit;

        for i := 1 to LineXMLList.Count do begin
            LineXMLList.Get(i, LineXMLNode);
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Init();
            EDocumentPurchaseLine."E-Document Entry No." := EDocumentEntryNo;
            EDocumentPurchaseLine."Line No." := i * 10000;
            Clear(NewLineXML);
            NewLineXML := XmlDocument.Create();
            NewLineXML.Add(LineXMLNode.AsXmlElement());
            PopulatePINTANZPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert();
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

    local procedure GetNodeValue(PINTANZXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; XPath: Text): Text
    var
        XMLNode: XmlNode;
    begin
        if PINTANZXml.SelectSingleNode(XPath, XmlNamespaces, XMLNode) then
            exit(XMLNode.AsXmlElement().InnerText());
        exit('');
    end;

    local procedure FindVendorByABN(var VendorNo: Code[20]; InputABN: Code[11]): Boolean
    var
        Vendor: Record Vendor;
    begin
        if InputABN = '' then
            exit(false);

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
}