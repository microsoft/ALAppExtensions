// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.eServices.EDocument.Format.FacturaE;

using Microsoft.eServices.EDocument.Helpers;
using Microsoft.eServices.EDocument;
using Microsoft.eServices.EDocument.Format;
using Microsoft.eServices.EDocument.Processing.Import;
using Microsoft.eServices.EDocument.Processing.Import.Purchase;
using Microsoft.eServices.EDocument.Processing.Interfaces;
using Microsoft.eServices.EDocument.Service.Participant;
using Microsoft.Purchases.Vendor;
using Microsoft.Foundation.UOM;
using System.Utilities;
using System.IO;

codeunit 10776 "E-Document Factura-E Handler" implements IStructuredFormatReader
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        EDocumentImportHelper: Codeunit "E-Document Import Helper";

    /// <summary>
    /// Reads a Factura-E XML document and converts it into a draft purchase document.
    /// </summary>
    /// <param name="EDocument">The E-Document record containing the document information.</param>
    /// <param name="TempBlob">The temporary blob containing the XML content to be processed.</param>
    /// <returns>Returns the type of draft document that was created (Purchase Document).</returns>
    internal procedure ReadIntoDraft(EDocument: Record "E-Document"; TempBlob: Codeunit "Temp Blob"): Enum "E-Doc. Process Draft"
    var
        EDocumentPurchaseHeader: Record "E-Document Purchase Header";
        FacturaEXML: XmlDocument;
        XmlNamespaces: XmlNamespaceManager;
        XmlElement: XmlElement;
        FacturaENamespaceLbl: Label 'http://www.facturae.gob.es/formato/Versiones/Facturaev3_2_2.xml';
        DigitalSignatureNamespaceLbl: Label 'http://www.w3.org/2000/09/xmldsig#';
        ETSINamespaceLbl: Label 'http://uri.etsi.org/01903/v1.2.2#';
        XMLNode: XmlNode;
    begin
        EDocumentPurchaseHeader.InsertForEDocument(EDocument);

        XmlDocument.ReadFrom(TempBlob.CreateInStream(TextEncoding::UTF8), FacturaEXML);
        XmlNamespaces.AddNamespace('namespace', FacturaENamespaceLbl);
        XmlNamespaces.AddNamespace('ds', DigitalSignatureNamespaceLbl);
        XmlNamespaces.AddNamespace('etsi', ETSINamespaceLbl);

        FacturaEXML.GetRoot(XmlElement);
        EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Invoice";
        if FacturaEXML.SelectSingleNode('/namespace:Facturae/Invoices/Invoice/InvoiceHeader/Corrective', XmlNamespaces, XMLNode) then
            EDocumentPurchaseHeader."E-Document Type" := "E-Document Type"::"Purchase Credit Memo";

        PopulateFacturaEPurchaseInvoiceHeader(FacturaEXML, XmlNamespaces, EDocumentPurchaseHeader, EDocument);
        InsertFacturaEPurchaseInvoiceLines(FacturaEXML, XmlNamespaces, EDocumentPurchaseHeader."E-Document Entry No.");
        EDocumentPurchaseHeader.Modify(false);
        EDocument.Direction := EDocument.Direction::Incoming;
        exit(Enum::"E-Doc. Process Draft"::"Purchase Document");
    end;

    /// <summary>
    /// Displays a readable view of the E-Document by opening the purchase document page.
    /// </summary>
    /// <param name="EDocument">The E-Document record to be displayed.</param>
    /// <param name="TempBlob">The temporary blob containing the document content (not used in this implementation).</param>
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
    /// <summary>
    /// Populates the purchase invoice header with data extracted from the Factura-E XML document.
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the invoice data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="EDocumentPurchaseHeader">The E-Document Purchase Header record to be populated.</param>
    /// <param name="EDocument">The E-Document record containing document information.</param>
    local procedure PopulateFacturaEPurchaseInvoiceHeader(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header"; var EDocument: Record "E-Document")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        VendorNo: Code[20];
    begin
        EDocumentXMLHelper.SetStringValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceHeader/InvoiceNumber', MaxStrLen(EDocumentPurchaseHeader."Sales Invoice No."), EDocumentPurchaseHeader."Sales Invoice No.");
        EDocumentXMLHelper.SetDateValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceIssueData/IssueDate', EDocumentPurchaseHeader."Document Date");
        EDocumentXMLHelper.SetCurrencyValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceIssueData/InvoiceCurrencyCode', MaxStrLen(EDocumentPurchaseHeader."Currency Code"), EDocumentPurchaseHeader."Currency Code");
        VendorNo := ParseSellerParty(FacturaEXML, XmlNamespaces, EDocument, EDocumentPurchaseHeader);
        ParseBuyerParty(FacturaEXML, XmlNamespaces, EDocumentPurchaseHeader);
        EDocumentXMLHelper.SetNumberValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceTotals/TotalGrossAmountBeforeTaxes', EDocumentPurchaseHeader."Sub Total");
        EDocumentXMLHelper.SetNumberValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceTotals/TotalTaxOutputs', EDocumentPurchaseHeader."Total VAT");
        EDocumentXMLHelper.SetNumberValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceTotals/InvoiceTotal', EDocumentPurchaseHeader.Total);
        EDocumentXMLHelper.SetNumberValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceTotals/TotalOutstandingAmount', EDocumentPurchaseHeader."Amount Due");
        EDocumentXMLHelper.SetDateValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceHeader/InvoiceDocumentReference/ReferencedDocumentDate', EDocumentPurchaseHeader."Due Date");
        EDocumentXMLHelper.SetStringValueInField(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Invoices/Invoice/InvoiceHeader/Corrective/InvoiceNumber', MaxStrLen(EDocumentPurchaseHeader."Purchase Order No."), EDocumentPurchaseHeader."Purchase Order No.");

        if VendorNo <> '' then
            EDocumentPurchaseHeader."[BC] Vendor No." := VendorNo;
    end;
#pragma warning restore AA0139

    /// <summary>
    /// Inserts purchase invoice lines extracted from the Factura-E XML document.
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the invoice line data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="EDocumentEntryNo">The E-Document entry number to associate with the lines.</param>
    local procedure InsertFacturaEPurchaseInvoiceLines(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; EDocumentEntryNo: Integer)
    var
        EDocumentPurchaseLine: Record "E-Document Purchase Line";
        NewLineXML: XmlDocument;
        LineXMLList: XmlNodeList;
        LineXMLNode: XmlNode;
        InvoiceLinePathLbl: Label '/namespace:Facturae/Invoices/Invoice/Items/InvoiceLine';
    begin
        if not FacturaEXML.SelectNodes(InvoiceLinePathLbl, XmlNamespaces, LineXMLList) then
            exit;

        foreach LineXMLNode in LineXMLList do begin
            Clear(EDocumentPurchaseLine);
            EDocumentPurchaseLine.Validate("E-Document Entry No.", EDocumentEntryNo);
            EDocumentPurchaseLine."Line No." := EDocumentPurchaseLine.GetNextLineNo(EDocumentEntryNo);
            NewLineXML.ReplaceNodes(LineXMLNode);
            PopulateFacturaEPurchaseLine(NewLineXML, XmlNamespaces, EDocumentPurchaseLine);
            EDocumentPurchaseLine.Insert(false);
        end;
    end;

#pragma warning disable AA0139 // false positive: overflow handled by SetStringValueInField
    /// <summary>
    /// Populates a single purchase line with data extracted from the Factura-E XML line.
    /// </summary>
    /// <param name="LineXML">The XML document containing a single invoice line.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="EDocumentPurchaseLine">The E-Document Purchase Line record to be populated.</param>
    local procedure PopulateFacturaEPurchaseLine(LineXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseLine: Record "E-Document Purchase Line")
    var
        EDocumentXMLHelper: Codeunit "EDocument XML Helper";
        UOMCode: Text;
        XMLNode: XmlNode;
    begin
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'InvoiceLine/ArticleCode', MaxStrLen(EDocumentPurchaseLine."Product Code"), EDocumentPurchaseLine."Product Code");
        EDocumentXMLHelper.SetStringValueInField(LineXML, XmlNamespaces, 'InvoiceLine/ItemDescription', MaxStrLen(EDocumentPurchaseLine.Description), EDocumentPurchaseLine.Description);
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'InvoiceLine/Quantity', EDocumentPurchaseLine.Quantity);
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'InvoiceLine/UnitPriceWithoutTax', EDocumentPurchaseLine."Unit Price");
        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'InvoiceLine/TotalCost', EDocumentPurchaseLine."Sub Total");
        EDocumentXMLHelper.SetCurrencyValueInField(LineXML, XmlNamespaces, 'InvoiceLine/TotalCost/@currencyID', MaxStrLen(EDocumentPurchaseLine."Currency Code"), EDocumentPurchaseLine."Currency Code");

        // Handle Unit of Measure like in legacy system
        if LineXML.SelectSingleNode('InvoiceLine/UnitOfMeasure', XmlNamespaces, XMLNode) then begin
            UOMCode := XMLNode.AsXmlElement().InnerText();
            EDocumentPurchaseLine."Unit of Measure" := CopyStr(UOMCode, 1, MaxStrLen(EDocumentPurchaseLine."Unit of Measure"));
            EDocumentPurchaseLine."[BC] Unit of Measure" := TryGetUOMCodeFromInternationalCode(UOMCode);
        end;

        EDocumentXMLHelper.SetNumberValueInField(LineXML, XmlNamespaces, 'InvoiceLine/TaxesOutputs/Tax/TaxRate', EDocumentPurchaseLine."VAT Rate");
    end;
#pragma warning restore AA0139

    /// <summary>
    /// Parses the seller party information from the Factura-E XML and attempts to find the corresponding vendor.
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the seller party data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="EDocument">The E-Document record containing document information.</param>
    /// <param name="EDocumentPurchaseHeader">The E-Document Purchase Header record to be updated with vendor information.</param>
    /// <returns>Returns the vendor number if found, otherwise returns empty string.</returns>
    local procedure ParseSellerParty(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocument: Record "E-Document"; var EDocumentPurchaseHeader: Record "E-Document Purchase Header") VendorNo: Code[20]
    var
        Vendor: Record Vendor;
        ServiceParticipant: Record "Service Participant";
        EDocumentService: Record "E-Document Service";
        EDocumentHelper: Codeunit "E-Document Helper";
        VendorName, VendorAddress : Text;
        VATRegistrationNo: Text[20];
        VendorId: Text;
        XMLNode: XmlNode;
    begin
        // Extract VAT registration number
        if FacturaEXML.SelectSingleNode('/namespace:Facturae/Parties/SellerParty/TaxIdentification/TaxIdentificationNumber', XmlNamespaces, XMLNode) then
            VATRegistrationNo := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxStrLen(VATRegistrationNo));

        // Try to find vendor by VAT registration number first
        VendorNo := EDocumentImportHelper.FindVendor('', '', VATRegistrationNo);

        // If vendor not found, try to find by Service Participant
        if VendorNo = '' then begin
            if FacturaEXML.SelectSingleNode('/namespace:Facturae/Parties/SellerParty/PartyIdentification', XmlNamespaces, XMLNode) then
                VendorId := XMLNode.AsXmlElement().InnerText();

            if VendorId <> '' then begin
                EDocumentHelper.GetEdocumentService(EDocument, EDocumentService);
                ServiceParticipant.SetRange("Participant Type", ServiceParticipant."Participant Type"::Vendor);
                ServiceParticipant.SetRange("Participant Identifier", VendorId);
                ServiceParticipant.SetRange(Service, EDocumentService.Code);
                if not ServiceParticipant.FindFirst() then begin
                    ServiceParticipant.SetRange(Service);
                    if ServiceParticipant.FindFirst() then;
                end;
            end;

            VendorNo := ServiceParticipant.Participant;
        end;

        // If vendor still not found, try to find by name and address
        if VendorNo = '' then begin
            VendorName := GetNameDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/SellerParty/');
            VendorAddress := GetAddressDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/SellerParty/');
            VendorNo := EDocumentImportHelper.FindVendorByNameAndAddress(VendorName, VendorAddress);
            EDocumentPurchaseHeader."Vendor Company Name" := CopyStr(VendorName, 1, MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"));
        end;

        // Set vendor information in E-Document Purchase Header
        Vendor := EDocumentImportHelper.GetVendor(EDocument, VendorNo);
        if Vendor."No." <> '' then begin
            EDocumentPurchaseHeader."Vendor Company Name" := Vendor.Name;
            EDocumentPurchaseHeader."Vendor VAT Id" := VATRegistrationNo;
            EDocumentPurchaseHeader."Vendor Address" := CopyStr(GetAddressDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/SellerParty/'), 1, MaxStrLen(EDocumentPurchaseHeader."Vendor Address"));
        end else begin
            // Set extracted information even if vendor not found
            VendorName := GetNameDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/SellerParty/');
            if VendorName <> '' then
                EDocumentPurchaseHeader."Vendor Company Name" := CopyStr(VendorName, 1, MaxStrLen(EDocumentPurchaseHeader."Vendor Company Name"));
            EDocumentPurchaseHeader."Vendor VAT Id" := VATRegistrationNo;
            EDocumentPurchaseHeader."Vendor Address" := CopyStr(GetAddressDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/SellerParty/'), 1, MaxStrLen(EDocumentPurchaseHeader."Vendor Address"));
        end;
    end;

    /// <summary>
    /// Parses the buyer party information from the Factura-E XML and updates the purchase header with customer details.
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the buyer party data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="EDocumentPurchaseHeader">The E-Document Purchase Header record to be updated with customer information.</param>
    local procedure ParseBuyerParty(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; var EDocumentPurchaseHeader: Record "E-Document Purchase Header")
    var
        BuyerName, BuyerAddress : Text;
        XMLNode: XmlNode;
    begin
        BuyerName := GetNameDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/BuyerParty/');
        BuyerAddress := GetAddressDependingOnType(FacturaEXML, XmlNamespaces, '/namespace:Facturae/Parties/BuyerParty/');

        EDocumentPurchaseHeader."Customer Company Name" := CopyStr(BuyerName, 1, MaxStrLen(EDocumentPurchaseHeader."Customer Company Name"));
        EDocumentPurchaseHeader."Customer Address" := CopyStr(BuyerAddress, 1, MaxStrLen(EDocumentPurchaseHeader."Customer Address"));

        if FacturaEXML.SelectSingleNode('/namespace:Facturae/Parties/BuyerParty/TaxIdentification/TaxIdentificationNumber', XmlNamespaces, XMLNode) then
            EDocumentPurchaseHeader."Customer VAT Id" := CopyStr(XMLNode.AsXmlElement().InnerText(), 1, MaxStrLen(EDocumentPurchaseHeader."Customer VAT Id"));
    end;

    /// <summary>
    /// Extracts the name from a party (seller or buyer) depending on the person type (individual or corporate).
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the party data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="PathPrefix">The XML path prefix to the party node (e.g., '/namespace:Facturae/Parties/SellerParty/').</param>
    /// <returns>Returns the formatted name based on the person type.</returns>
    local procedure GetNameDependingOnType(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; PathPrefix: Text) Name: Text
    var
        XMLNode: XmlNode;
        PersonTypeCode: Text;
        IndividualTok: Label 'F', Locked = true;
    begin
        if FacturaEXML.SelectSingleNode(PathPrefix + 'TaxIdentification/PersonTypeCode', XmlNamespaces, XMLNode) then
            PersonTypeCode := XMLNode.AsXmlElement().InnerText();

        if PersonTypeCode = IndividualTok then begin
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/Name', XmlNamespaces, XMLNode) then
                Name := XMLNode.AsXmlElement().InnerText();
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/FirstSurname', XmlNamespaces, XMLNode) then
                Name += ' ' + XMLNode.AsXmlElement().InnerText();
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/SecondSurname', XmlNamespaces, XMLNode) then
                Name += ' ' + XMLNode.AsXmlElement().InnerText();
        end else
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/CorporateName', XmlNamespaces, XMLNode) then
                Name := XMLNode.AsXmlElement().InnerText();
    end;

    /// <summary>
    /// Extracts the address from a party (seller or buyer) depending on the residence type (Spain or overseas).
    /// </summary>
    /// <param name="FacturaEXML">The Factura-E XML document containing the party data.</param>
    /// <param name="XmlNamespaces">The XML namespace manager for handling XML namespaces.</param>
    /// <param name="PathPrefix">The XML path prefix to the party node (e.g., '/namespace:Facturae/Parties/SellerParty/').</param>
    /// <returns>Returns the address based on the residence type.</returns>
    local procedure GetAddressDependingOnType(FacturaEXML: XmlDocument; XmlNamespaces: XmlNamespaceManager; PathPrefix: Text) Address: Text
    var
        XMLNode: XmlNode;
        ResidenceTypeCode: Text;
        ResidenceTok: Label 'R', Locked = true;
    begin
        if FacturaEXML.SelectSingleNode(PathPrefix + 'TaxIdentification/ResidenceTypeCode', XmlNamespaces, XMLNode) then
            ResidenceTypeCode := XMLNode.AsXmlElement().InnerText();

        if ResidenceTypeCode = ResidenceTok then begin
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/AddressInSpain/Address', XmlNamespaces, XMLNode) then
                Address := XMLNode.AsXmlElement().InnerText();
        end else
            if FacturaEXML.SelectSingleNode(PathPrefix + 'LegalEntity/OverseasAddress/Address', XmlNamespaces, XMLNode) then
                Address := XMLNode.AsXmlElement().InnerText();
    end;

    /// <summary>
    /// Attempts to convert an international unit of measure code to the corresponding Business Central unit of measure code.
    /// </summary>
    /// <param name="ImportedUOMCode">The international unit of measure code as text.</param>
    /// <returns>Returns the Business Central unit of measure code if found, otherwise returns empty string.</returns>
    local procedure TryGetUOMCodeFromInternationalCode(ImportedUOMCode: Text) UOMCode: Code[10]
    var
        UnitOfMeasure: Record "Unit of Measure";
        Code: Integer;
    begin
        if ImportedUOMCode <> '' then begin
            Evaluate(Code, ImportedUOMCode, 9);
            UnitOfMeasure.SetRange("International Standard Code", Enum::"Factura-E Units of Measure".Names().Get(Code));
            if UnitOfMeasure.FindFirst() then
                UOMCode := UnitOfMeasure.Code;
        end;
    end;
}
