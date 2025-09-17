// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocument.Format;

using System.Utilities;
using Microsoft.Inventory.Transfer;
using System.Xml;
using Microsoft.Foundation.Company;
using System.Text;
using Microsoft.eServices.EDocument;
using Microsoft.Foundation.Reporting;

codeunit 6127 "E-Doc. Transfer Shpt. To XML"
{
    TableNo = "Transfer Shipment Header";

    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        TransferShipmentXML: XmlDocument;
        RootNode: XmlNode;
        GeneratePDF: Boolean;

    trigger OnRun()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        this.AddHeaderDataToXML(Rec);

        TransferShipmentLine.SetRange("Document No.", Rec."No.");
        if TransferShipmentLine.FindSet() then
            repeat
                this.AddLineInfoToXML(TransferShipmentLine);
            until TransferShipmentLine.Next() = 0;
    end;

    local procedure AddHeaderDataToXML(TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        ChildNode: XmlNode;
    begin
        this.TransferShipmentXML := XmlDocument.Create();
        this.XMLDOMManagement.AddRootElement(this.TransferShipmentXML, 'TransferShipment', this.RootNode);

        this.XMLDOMManagement.AddElement(this.RootNode, 'ID', TransferShipmentHeader."No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(this.RootNode, 'IssueDate', Format(TransferShipmentHeader."Posting Date", 0, 9), '', ChildNode);
        this.XMLDOMManagement.AddElement(this.RootNode, 'SupplierInformation', '', '', ChildNode);

        if this.GeneratePDF then
            this.AddPdf(ChildNode, TransferShipmentHeader);

        this.AddCompanyInfoToXML(ChildNode);

        this.XMLDOMManagement.AddElement(this.RootNode, 'DeliveryInformation', '', '', ChildNode);
        this.AddDeliveryInfoToXML(ChildNode, TransferShipmentHeader);
    end;

    local procedure AddCompanyInfoToXML(SupplierNode: XmlNode)
    var
        CompanyInformation: Record "Company Information";
        AddressNode: XmlNode;
        ChildNode: XmlNode;
    begin
        CompanyInformation.Get();
        this.AddNonEmptyNode(SupplierNode, 'Name', CompanyInformation.Name, '', ChildNode);
        this.AddNonEmptyNode(SupplierNode, 'VATNo', CompanyInformation."VAT Registration No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(SupplierNode, 'Address', '', '', AddressNode);
        this.AddNonEmptyNode(AddressNode, 'Street', CompanyInformation.Address, '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'City', CompanyInformation.City, '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'Country', CompanyInformation."Country/Region Code", '', ChildNode);
        this.AddNonEmptyNode(SupplierNode, 'PostalCode', CompanyInformation."Post Code", '', ChildNode);
    end;

    local procedure AddDeliveryInfoToXML(DeliveryNode: XmlNode; TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        AddressNode: XmlNode;
        ShipmentMethodNode: XmlNode;
        ChildNode: XmlNode;
    begin
        this.XMLDOMManagement.AddElement(DeliveryNode, 'DeliveryAddress', '', '', AddressNode);
        this.AddNonEmptyNode(AddressNode, 'Street', TransferShipmentHeader."Transfer-to Address", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'City', TransferShipmentHeader."Transfer-to City", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'County', TransferShipmentHeader."Transfer-to County", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'PostalCode', TransferShipmentHeader."Transfer-to Post Code", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'Contact', TransferShipmentHeader."Transfer-from Contact", '', ChildNode);
        this.XMLDOMManagement.AddElement(DeliveryNode, 'ShipmentMethod', '', '', ShipmentMethodNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'Code', TransferShipmentHeader."Shipment Method Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'AgentCode', TransferShipmentHeader."Shipping Agent Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'AgentService', TransferShipmentHeader."Shipping Agent Service Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'ShipmentDate', Format(TransferShipmentHeader."Shipment Date", 0, 9), '', ChildNode);
    end;

    local procedure AddLineInfoToXML(TransferShipmentLine: Record "Transfer Shipment Line")
    var
        LineNode: XmlNode;
        ItemNode: XmlNode;
        ChildNode: XmlNode;
    begin
        this.XMLDOMManagement.AddElement(LineNode, 'Line', '', '', LineNode);
        this.AddNonEmptyNode(LineNode, 'ID', Format(TransferShipmentLine."Line No."), '', ChildNode);
        this.XMLDOMManagement.AddElement(LineNode, 'Item', '', '', ItemNode);
        this.AddNonEmptyNode(ItemNode, 'ID', TransferShipmentLine."Item No.", '', ChildNode);
        this.AddNonEmptyNode(ItemNode, 'Description', TransferShipmentLine.Description, '', ChildNode);
        this.AddNonEmptyNode(ItemNode, 'UnitOfMeasure', TransferShipmentLine."Unit of Measure Code", '', ChildNode);
        this.AddNonEmptyNode(ItemNode, 'Quantity', Format(TransferShipmentLine.Quantity), '', ChildNode);
        this.AddNonEmptyNode(LineNode, 'ShipmentDate', Format(TransferShipmentLine."Shipment Date", 0, 9), '', ChildNode);
    end;

    local procedure AddNonEmptyNode(Node: XmlNode; NodeName: Text; NodeValue: Text; Namespace: Text; var ChildNode: XmlNode)
    begin
        if NodeValue <> '' then
            this.XMLDOMManagement.AddElement(Node, NodeName, NodeValue, Namespace, ChildNode);
    end;

    local procedure AddPdf(AttachmentNode: XmlNode; TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        ChildNode: XmlNode;
        AdditionalDocumentReferenceID: Text;
        Filename: Text;
        MimeCode: Text;
        EmbeddedDocumentBinaryObject: Text;
    begin
        if not this.GeneratePDFAttachmentAsAdditionalDocRef(
            TransferShipmentHeader,
            AdditionalDocumentReferenceID,
            Filename,
            MimeCode,
            EmbeddedDocumentBinaryObject)
        then
            exit;

        this.XMLDOMManagement.AddElement(this.RootNode, 'Attachment', '', '', AttachmentNode);
        this.XMLDOMManagement.AddElement(AttachmentNode, 'EmbeddedDocumentBinaryObject', EmbeddedDocumentBinaryObject, '', ChildNode);
        this.XMLDOMManagement.AddAttribute(ChildNode, 'filename', Filename);
        this.XMLDOMManagement.AddAttribute(ChildNode, 'mimeCode', MimeCode);
    end;

    local procedure GeneratePDFAttachmentAsAdditionalDocRef(
        TransferShipmentHeader: Record "Transfer Shipment Header";
        var AdditionalDocumentReferenceID: Text;
        var Filename: Text;
        var MimeCode: Text;
        var EmbeddedDocumentBinaryObject: Text): Boolean
    var
        Base64Convert: Codeunit "Base64 Convert";
        TempBlob: Codeunit "Temp Blob";
        FileNameTok: Label '%1_%2.pdf', Comment = '%1 - Document Type, %2 - Document No', Locked = true;
    begin
        AdditionalDocumentReferenceID := '';
        MimeCode := '';
        EmbeddedDocumentBinaryObject := '';
        Filename := '';

        if not this.GeneratePDFAsTempBlob(TransferShipmentHeader, TempBlob) then
            exit(false);

        Filename := StrSubstNo(FileNameTok, Enum::"E-Document Type"::"Transfer Shipment", TransferShipmentHeader."No.");
        AdditionalDocumentReferenceID := TransferShipmentHeader."No.";
        EmbeddedDocumentBinaryObject := Base64Convert.ToBase64(TempBlob.CreateInStream());
        MimeCode := 'application/pdf';
        exit(true);
    end;

    local procedure GeneratePDFAsTempBlob(TransferShipmentHeader: Record "Transfer Shipment Header"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportSelections: Record "Report Selections";
    begin
        TransferShipmentHeader.SetRecFilter();
        ReportSelections.GetPdfReportForCust(
            TempBlob,
            "Report Selection Usage"::Inv2, // Transfer Shipment
             TransferShipmentHeader,
             '');

        exit(TempBlob.HasValue());
    end;

    /// <summary>
    /// Gets the XML document as a temporary blob.
    /// </summary>
    /// <param name="TempBlob">Return value: Temp Blob codeunit containing the document.</param>
    internal procedure GetTransferShipmentXML(var TempBlob: Codeunit "Temp Blob")
    begin
        this.TransferShipmentXML.WriteTo(TempBlob.CreateOutStream());
    end;

    /// <summary>
    /// Controls whether a PDF document should be generated and included as an additional document reference.
    /// </summary>
    /// <param name="GeneratePDFValue">If true, generates a PDF based on Report Selection settings.</param>
    internal procedure SetGeneratePDF(GeneratePDFValue: Boolean)
    begin
        this.GeneratePDF := GeneratePDFValue;
    end;
}