// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format;

using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using System.Utilities;
using Microsoft.Finance.GeneralLedger.Setup;

codeunit 6173 "E-Document PEPPOL Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        DocStream: InStream;
        PeppolXML: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        CommonAggregateComponentsLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
        CommonBasicComponentsLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        DocumentationLbl: Label 'urn:un:unece:uncefact:documentation:2';
        QualifiedDatatypesLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:QualifiedDatatypes-2';
        UnqualifiedDataTypesSchemaModuleLbl: Label 'urn:un:unece:uncefact:data:specification:UnqualifiedDataTypesSchemaModule:2';
        DefaultInvoiceLbl: Label 'urn:oasis:names:specification:ubl:schema:xsd:Invoice-2';
        CreditNoteNotSupportedLbl: Label 'Credit notes are not supported';
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        TempBlob.CreateInStream(DocStream, TextEncoding::UTF8);
        XmlDocument.ReadFrom(DocStream, PeppolXML);
        XmlNamespaces.AddNamespace('cac', CommonAggregateComponentsLbl);
        XmlNamespaces.AddNamespace('cbc', CommonBasicComponentsLbl);
        XmlNamespaces.AddNamespace('ccts', DocumentationLbl);
        XmlNamespaces.AddNamespace('qdt', QualifiedDatatypesLbl);
        XmlNamespaces.AddNamespace('udt', UnqualifiedDataTypesSchemaModuleLbl);
        XmlNamespaces.AddNamespace('inv', DefaultInvoiceLbl);

        PeppolXML.GetRoot(XmlElement);
        case UpperCase(XmlElement.LocalName()) of
            'INVOICE':
                begin
                    PopulatePurchaseInvoiceHeader(PeppolXML, XmlNamespaces, EDocumentPurchaseHeader);
                    InsertPurchaseInvoiceLines(PeppolXML, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.");
                end;
            'CREDITNOTE':
                Error(CreditNoteNotSupportedLbl);
        end;
        EDocumentPurchaseHeader.Modify();
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    local procedure InsertPurchaseInvoiceLines(PeppolXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        NewLineXML: XmlDocument;
        LineXMLList: XmlNodeList;
        LineXMLNode: XmlNode;
        i: Integer;
        InvoiceLinePathLbl: Label '/inv:Invoice/cac:InvoiceLine';
    begin
        if not PeppolXML.SelectNodes(InvoiceLinePathLbl, XmlNamespaces, LineXMLList) then
            exit;

        for i := 1 to LineXMLList.Count do begin
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            EDocumentPurchaseLine."Line No." := EDocumentPurchaseLine.GetNextLineNo(EDocumentEntryNo);
            LineXMLList.Get(i, LineXMLNode);
            NewLineXML.ReplaceNodes(LineXMLNode);
            PopulateEDocumentPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert();
        end;
    end;

#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
    local procedure PopulatePurchaseInvoiceHeader(PeppolXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    var
        XMLNode: XmlNode;
    begin
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:OrderReference/cbc:ID', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        // Line below, using PayeeParty, shall be used when the Payee is different from the Seller. Otherwise, it will not be shown in the XML.
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:PayeeParty/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"), EDocumentPurchaseHeader."Vendor Company Name");
        SetNumberValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:AllowanceTotalAmount', EDocumentPurchaseHeader."Total Discount");
        SetNumberValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader."Amount Due");
        SetNumberValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:PayableAmount', EDocumentPurchaseHeader.Total);
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:Contact/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Vendor Contact Name"), EDocumentPurchaseHeader."Vendor Contact Name");
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Vendor Address"), EDocumentPurchaseHeader."Vendor Address");
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyLegalEntity/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), EDocumentPurchaseHeader."Customer VAT Id");
        // Line below, using PayeeParty, shall be used when the Payee is different from the Seller. Otherwise, it will not be shown in the XML.
        SetStringValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:PayeeParty/cac:PartyLegalEntity/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        SetNumberValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cac:LegalMonetaryTotal/cbc:TaxExclusiveAmount', EDocumentPurchaseHeader."Sub Total");
        EDocumentPurchaseHeader."Total VAT" := EDocumentPurchaseHeader."Total" - EDocumentPurchaseHeader."Sub Total" - EDocumentPurchaseHeader."Total Discount";
        SetDateValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cbc:DueDate', EDocumentPurchaseHeader."Due Date");
        SetDateValueInField(PeppolXML, XMLNamespaces, '/inv:Invoice/cbc:IssueDate', EDocumentPurchaseHeader."Document Date");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Vendor VAT Id"), EDocumentPurchaseHeader."Vendor VAT Id");
        SetCurrencyValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cbc:DocumentCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyName/cbc:Name', MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"), EDocumentPurchaseHeader."Customer Company Name");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PartyTaxScheme/cbc:CompanyID', MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"), EDocumentPurchaseHeader."Customer VAT Id");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cac:PostalAddress/cbc:StreetName', MaxStrLen(EDocumentPurchaseHeader."Customer Address"), EDocumentPurchaseHeader."Customer Address");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID', MaxStrLen(EDocumentPurchaseHeader."Customer GLN"), EDocumentPurchaseHeader."Customer GLN");
        SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingCustomerParty/cac:Party/cbc:EndpointID/@schemeID', MaxStrLen(EDocumentPurchaseHeader."Customer Company Id"), EDocumentPurchaseHeader."Customer Company Id");

        if PeppolXML.SelectSingleNode('/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID/@schemeID', XmlNamespaces, XMLNode) then
            if XMLNode.AsXmlAttribute().Value() = '0088' then // GLN
                SetStringValueInField(PeppolXML, XmlNamespaces, '/inv:Invoice/cac:AccountingSupplierParty/cac:Party/cbc:EndpointID', MaxStrLen(EDocumentPurchaseHeader."Vendor GLN"), EDocumentPurchaseHeader."Vendor GLN");
    end;

    local procedure PopulateEDocumentPurchaseLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    begin
        SetNumberValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cbc:InvoicedQuantity', EDocumentPurchaseLine.Quantity);
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cbc:InvoicedQuantity/@unitCode', MaxStrLen(EDocumentPurchaseLine."Unit of Measure"), EDocumentPurchaseLine."Unit of Measure");
        SetNumberValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cbc:LineExtensionAmount', EDocumentPurchaseLine."Sub Total");
        SetCurrencyValueInField(LineXML, XmlNamespaces, 'cac:InvoiceLine/cbc:LineExtensionAmount/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");
        SetNumberValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:AllowanceCharge/cbc:Amount', EDocumentPurchaseLine."Total Discount");
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cbc:Note', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Item/cbc:Name', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Item/cbc:Description', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Item/cac:SellersItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        SetStringValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Item/cac:StandardItemIdentification/cbc:ID', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        SetNumberValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Item/cac:ClassifiedTaxCategory/cbc:Percent', EDocumentPurchaseLine."VAT Rate");
        SetNumberValueInField(LineXML, XMLNamespaces, 'cac:InvoiceLine/cac:Price/cbc:PriceAmount', EDocumentPurchaseLine."Unit Price");
    end;

    local procedure SetCurrencyValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; MaxLength: Integer; var CurrencyField: Code[10])
    var
        GLSetup: Record "General Ledger Setup";
        XMLNode: XmlNode;
        CurrencyCode: Code[10];
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        GLSetup.Get();

        if XMLNode.IsXmlElement() then begin
            CurrencyCode := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxLength);
            if GLSetup."LCY Code" <> CurrencyCode then
                CurrencyField := CurrencyCode;
            exit;
        end;

        if XMLNode.IsXmlAttribute() then begin
            CurrencyCode := CopyStr(XMLNode.AsXmlAttribute().Value, 1, MaxLength);
            if GLSetup."LCY Code" <> CurrencyCode then
                CurrencyField := CurrencyCode;
            exit;
        end;
    end;
#pragma warning restore AA0139

    local procedure SetStringValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; MaxLength: Integer; var Field: Text)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.IsXmlElement() then begin
            Field := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxLength);
            exit;
        end;

        if XMLNode.IsXmlAttribute() then begin
            Field := CopyStr(XMLNode.AsXmlAttribute().Value(), 1, MaxLength);
            exit;
        end;
    end;

    local procedure SetNumberValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; var DecimalValue: Decimal)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.AsXmlElement().InnerText() <> '' then
            Evaluate(DecimalValue, XMLNode.AsXmlElement().InnerText(), 9);
    end;

    local procedure SetDateValueInField(XMLDocument: XmlDocument; XMLNamespaces: XmlNamespaceManager; Path: Text; var DateValue: Date)
    var
        XMLNode: XmlNode;
    begin
        if not XMLDocument.SelectSingleNode(Path, XMLNamespaces, XMLNode) then
            exit;

        if XMLNode.AsXmlElement().InnerText() <> '' then
            Evaluate(DateValue, XMLNode.AsXmlElement().InnerText(), 9);
    end;

    procedure View(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob")
    begin
        Error('A view is not implemented for this handler.');
    end;
}