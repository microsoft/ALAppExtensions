// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Formats;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Helpers;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Purchases.Vendor;
using System.Telemetry;
using System.Utilities;

/// <summary>
/// Handler for processing XRechnung electronic documents.
/// Implements structured format reader interface for importing XRechnung invoices and credit memos.
/// </summary>
codeunit 13921 "E-Document XRechnung Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTok: Label 'E-document XRechnung Format', Locked = true;
        StartEventNameTok: Label 'E-document XRechnung import started. Parsing basic information.', Locked = true;
        InvoiceLbl: Label 'INVOICE', Locked = true;
        CreditNoteLbl: Label 'CREDITNOTE', Locked = true;

    /// <summary>
    /// Reads an XRechnung electronic document into a draft purchase document.
    /// Parses XML content and populates purchase header and lines based on document type (Invoice or Credit Note).
    /// </summary>
    /// <param name="EDocument">The E-Document record to process.</param>
    /// <param name="TempBlob">The temporary blob containing the XML content to parse.</param>
    /// <returns>Returns the process draft type indicating a Purchase Document was created.</returns>
    internal procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        XRechnungXml: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        CommonAggregateComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2', Locked = true;
        CommonBasicComponentsTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2', Locked = true;
        DefaultInvoiceTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2', Locked = true;
        DefaultCreditNoteTok: Label 'urn:oasis:names:specification:ubl:schema:xsd:CreditNote-2', Locked = true;
    begin
        FeatureTelemetry.LogUsage('0000EXH', FeatureNameTok, StartEventNameTok);
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        XmlDocument.ReadFrom(TempBlob.CreateInStream(TextEncoding::UTF8), XRechnungXml);

        // Setup XML namespaces for XRechnung (UBL 2.1 based)
        XmlNamespaces.AddNamespace('cac', CommonAggregateComponentsTok);
        XmlNamespaces.AddNamespace('cbc', CommonBasicComponentsTok);
        XmlNamespaces.AddNamespace('inv', DefaultInvoiceTok);
        XmlNamespaces.AddNamespace('cn', DefaultCreditNoteTok);

        XRechnungXml.GetRoot(XmlElement);
        case UpperCase(XmlElement.LocalName()) of
            InvoiceLbl:
                PopulateEDocumentForInvoice(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
            CreditNoteLbl:
                PopulateEDocumentForCreditNote(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
        end;

        EDocumentPurchaseHeader.Modify(false);
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    /// <summary>
    /// Opens a page to view the readable purchase document content for the specified E-Document.
    /// Displays purchase header and line information in a user-friendly format.
    /// </summary>
    /// <param name="EDocument">The E-Document record to view.</param>
    /// <param name="TempBlob">The temporary blob containing the document content (not used in current implementation).</param>
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

    local procedure PopulateEDocumentForInvoice(XRechnungXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Invoice";
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
#pragma warning restore AA0139
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', EDocumentPurchaseHeader.Total);
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader."Amount Due");
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader.Total - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        VendorNo := ParseAccountingSupplierParty(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'inv:Invoice');
        ParseAccountingCustomerParty(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, 'inv:Invoice');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertXRechnungPurchaseLines(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.", EDocumentPurchaseHeader."E-Document Type");
    end;

    local procedure PopulateEDocumentForCreditNote(XRechnungXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Credit Memo";
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetDateValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetCurrencyValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
#pragma warning restore AA0139
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:TaxInclusiveAmount', EDocumentPurchaseHeader.Total);
        EDocumentXMLHelper.SetNumberValueInField(XRechnungXml, XmlNamespaces, '/cn:CreditNote/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader."Amount Due");
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader.Total - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        VendorNo := ParseAccountingSupplierParty(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, EDocument, 'cn:CreditNote');
        ParseAccountingCustomerParty(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader, 'cn:CreditNote');
        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
        InsertXRechnungPurchaseLines(XRechnungXml, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.", EDocumentPurchaseHeader."E-Document Type");
    end;

    local procedure ParseAccountingSupplierParty(XRechnungXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document"; DocumentType: Text) VendorNo: Code[20]
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorName, VendorAddress, VendorParticipantId : Text;
        VATRegistrationNo: Text[20];
        EndpointID, SchemeID : Text;
        GLN: Code[13];
        BasePathTxt: Text;
        XMLNode: XmlNode;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        BasePathTxt := '/' + DocumentType + '/cac:AccountingSupplierParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), EDocumentPurchaseHeader."Vendor Address");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:AdditionalStreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address Recipient"), EDocumentPurchaseHeader."Vendor Address Recipient");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:Contact/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Contact Name"), EDocumentPurchaseHeader."Vendor Contact Name");
#pragma warning restore AA0139
        if XRechnungXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemeID := XMLNode.AsXmlAttribute().Value();
            EndpointID := EDocumentXMLHelper.GetNodeValue(XRechnungXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            case SchemeID of
                'EM', '0198', '9930':
                    VATRegistrationNo := CopyStr(EndpointID, 1, MaxStrLen(VATRegistrationNo));
                '0088':
                    begin
                        GLN := CopyStr(EndpointID, 1, MaxStrLen(GLN));
                        EDocumentPurchaseHeader."Vendor GLN" := GLN;
                    end;
            end;
            VendorParticipantId := SchemeID + ':' + EndpointID;
        end;
        VATRegistrationNo := CopyStr(EDocumentPurchaseHeader."Vendor VAT Id", 1, 20);
        VendorName := EDocumentPurchaseHeader."Vendor Company Name";
        VendorAddress := EDocumentPurchaseHeader."Vendor Address";
        if not FindVendorByVATRegNoOrGLN(VendorNo, VATRegistrationNo, GLN) then
            if not FindVendorByParticipantId(VendorNo, EDocument, VendorParticipantId) then
                VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
    end;

    local procedure ParseAccountingCustomerParty(XRechnungXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; DocumentType: Text)
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        BasePathTxt: Text;
        XMLNode: XmlNode;
        SchemeID, EndpointID : Text;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        BasePathTxt := '/' + DocumentType + '/cac:AccountingCustomerParty/cac:Party';
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), EDocumentPurchaseHeader."Customer Company Name");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PartyLegalEntity/cbc:RegistrationName', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), EDocumentPurchaseHeader."Customer Company Name");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), EDocumentPurchaseHeader."Customer Address");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PostalAddress/cbc:AdditionalStreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address Recipient"), EDocumentPurchaseHeader."Customer Address Recipient");
        EDocumentXMLHelper.SetStringValueInField(XRechnungXml, XmlNamespaces, BasePathTxt + '/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), EDocumentPurchaseHeader."Customer VAT Id");
#pragma warning restore AA0139
        if XRechnungXml.SelectSingleNode(BasePathTxt + '/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then begin
            SchemeID := XMLNode.AsXmlAttribute().Value();
            EndpointID := EDocumentXMLHelper.GetNodeValue(XRechnungXml, XmlNamespaces, BasePathTxt + '/cbc:EndpointID');
            if SchemeID = '0088' then
                EDocumentPurchaseHeader."Customer GLN" := CopyStr(EndpointID, 1, MaxStrLen(EDocumentPurchaseHeader."Customer GLN"));
        end;
    end;

    local procedure InsertXRechnungPurchaseLines(XRechnungXml: XmlDocument; XmlNamespaces: XmlNamespaceManager; EDocumentEntryNo: Integer; DocumentType: Enum "E-Document Type")
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        NewLineXML: XmlDocument;
        LineXMLList: XmlNodeList;
        LineXMLNode: XmlNode;
        LineXPath: Text;
        LineElementName: Text;
    begin
        case DocumentType of
            "E-Document Type"::"Purchase Invoice":
                begin
                    LineElementName := 'cac:InvoiceLine';
                    LineXPath := '//inv:Invoice/cac:InvoiceLine';
                end;
            "E-Document Type"::"Purchase Credit Memo":
                begin
                    LineElementName := 'cac:CreditNoteLine';
                    LineXPath := '//cn:CreditNote/cac:CreditNoteLine';
                end;
        end;

        if not XRechnungXml.SelectNodes(LineXPath, XmlNamespaces, LineXMLList) then
            exit;

        foreach LineXMLNode in LineXMLList do begin
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            EDocumentPurchaseLine."Line No." := EDocumentPurchaseLine.GetNextLineNo(EDocumentEntryNo);
            NewLineXML.ReplaceNodes(LineXMLNode);
            PopulateXRechnungPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine, LineElementName);
            EDocumentPurchaseLine.Insert(false);
        end;
    end;

    local procedure PopulateXRechnungPurchaseLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line"; LineElementName: Text)
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        QuantityFieldName: Text;
    begin
#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
        case LineElementName of
            'cac:InvoiceLine':
                QuantityFieldName := 'cac:InvoiceLine/cbc:InvoicedQuantity';
            'cac:CreditNoteLine':
                QuantityFieldName := 'cac:CreditNoteLine/cbc:CreditedQuantity';
        end;
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cbc:Name', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:SellersItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:StandardItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, QuantityFieldName, EDocumentPurchaseLine.Quantity);
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, QuantityFieldName + '/@unitCode', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), EDocumentPurchaseLine."Unit of Measure");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Price/cbc:PriceAmount', EDocumentPurchaseLine."Unit Price");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cbc:LineExtensionAmount', EDocumentPurchaseLine."Sub Total");
        EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, LineElementName + '/cbc:LineExtensionAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, LineElementName + '/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', EDocumentPurchaseLine."VAT Rate");
#pragma warning restore AA0139
    end;

    local procedure FindVendorByVATRegNoOrGLN(var VendorNo: Code[20]; VATRegistrationNo: Text[20]; GLN: Code[13]): Boolean
    var
        Vendor: Record Vendor;
    begin
        // Try to find vendor by VAT Registration Number
        if VATRegistrationNo <> '' then begin
            Vendor.Reset();
            Vendor.SetLoadFields("VAT Registration No.");
            Vendor.SetRange("VAT Registration No.", VATRegistrationNo);
            if Vendor.FindFirst() then begin
                VendorNo := Vendor."No.";
                exit(true);
            end;
        end;

        // Try to find vendor by GLN
        if GLN <> '' then begin
            Vendor.Reset();
            Vendor.SetLoadFields("GLN");
            Vendor.SetRange("GLN", GLN);
            if Vendor.FindFirst() then begin
                VendorNo := Vendor."No.";
                exit(true);
            end;
        end;

        exit(false);
    end;

    local procedure FindVendorByParticipantId(var VendorNo: Code[20]; EDocument: Record "E-Document"; ParticipantId: Text): Boolean
    var
        EDocServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocumentHelper: Codeunit "E-Document Helper";
    begin
        if ParticipantId = '' then
            exit(false);

        EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
        EDocServiceParticipant.SetRange("Participant Type", EDocServiceParticipant."Participant Type"::Vendor);
        EDocServiceParticipant.SetRange("Participant Identifier", ParticipantId);
        EDocServiceParticipant.SetRange(Service, EDocumentService.Code);
        if not EDocServiceParticipant.FindFirst() then begin
            EDocServiceParticipant.SetRange(Service);
            if not EDocServiceParticipant.FindFirst() then
                exit(false);
        end;

        VendorNo := EDocServiceParticipant.Participant;
        exit(true);
    end;
}
