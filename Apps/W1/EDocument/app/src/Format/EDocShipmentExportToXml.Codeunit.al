namespace Microsoft.EServices.EDocument.Format;

using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using System.Utilities;
using System.Xml;
using Microsoft.eServices.EDocument;
using System.Text;
using Microsoft.Foundation.Reporting;

codeunit 6130 "E-Doc. Shipment Export To XML"
{
    TableNo = "Sales Shipment Header";

    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ShipmentXML: XmlDocument;
        RootNode: XmlNode;
        GeneratePDF: Boolean;

    trigger OnRun()
    var
        SalesShipmentLine: Record "Sales Shipment Line";
    begin
        this.AddHeaderDataToXML(Rec);

        SalesShipmentLine.SetRange("Document No.", Rec."No.");
        if SalesShipmentLine.FindSet() then
            repeat
                this.AddLineDataToXML(SalesShipmentLine);
            until SalesShipmentLine.Next() = 0;
    end;

    local procedure AddHeaderDataToXML(SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ChildNode: XmlNode;
    begin
        this.ShipmentXML := xmlDocument.Create();
        this.XMLDOMManagement.AddRootElement(this.ShipmentXML, 'Shipment', this.RootNode);

        this.AddNonEmptyNode(this.RootNode, 'ID', SalesShipmentHeader."No.", '', ChildNode);
        this.AddNonEmptyNode(this.RootNode, 'IssueDate', Format(SalesShipmentHeader."Posting Date", 0, 9), '', ChildNode);
        this.AddNonEmptyNode(this.RootNode, 'DueDate', Format(SalesShipmentHeader."Due Date", 0, 9), '', ChildNode);

        if this.GeneratePDF then
            this.AddPdf(ChildNode, SalesShipmentHeader);

        this.XMLDOMManagement.AddElement(this.RootNode, 'SupplierInformation', '', '', ChildNode);

        this.AddCompanyInfoToXML(ChildNode);

        this.XMLDOMManagement.AddElement(this.RootNode, 'CustomerInformation', '', '', ChildNode);
        this.AddCustomerDataToXML(ChildNode, SalesShipmentHeader);

        this.XMLDOMManagement.AddElement(this.RootNode, 'DeliveryInformation', '', '', ChildNode);
        this.AddDeliveryInfoToXML(ChildNode, SalesShipmentHeader);
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

    local procedure AddCustomerDataToXML(CustomerNode: XmlNode; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        Customer: Record Customer;
        AddressNode: XmlNode;
        ChildNode: XmlNode;
    begin
        Customer.Get(SalesShipmentHeader."Bill-to Customer No.");
        this.AddNonEmptyNode(CustomerNode, 'Name', Customer.Name, '', ChildNode);
        this.AddNonEmptyNode(CustomerNode, 'VATNo', Customer."VAT Registration No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(CustomerNode, 'Address', '', '', AddressNode);
        this.AddNonEmptyNode(AddressNode, 'Street', Customer.Address, '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'City', Customer.City, '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'Country', Customer."Country/Region Code", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'PostalCode', Customer."Post Code", '', ChildNode);
        this.AddNonEmptyNode(CustomerNode, 'Contact', Customer."Contact", '', ChildNode);
    end;

    local procedure AddDeliveryInfoToXML(DeliveryNode: XmlNode; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        AddressNode: XmlNode;
        ShipmentMethodNode: XmlNode;
        ChildNode: XmlNode;
    begin
        this.XMLDOMManagement.AddElement(DeliveryNode, 'DeliveryAddress', '', '', AddressNode);
        this.AddNonEmptyNode(AddressNode, 'Street', SalesShipmentHeader."Ship-to Address", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'City', SalesShipmentHeader."Ship-to City", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'Country', SalesShipmentHeader."Ship-to Country/Region Code", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'PostalCode', SalesShipmentHeader."Ship-to Post Code", '', ChildNode);
        this.AddNonEmptyNode(AddressNode, 'Contact', SalesShipmentHeader."Ship-to Contact", '', ChildNode);
        this.XMLDOMManagement.AddElement(DeliveryNode, 'ShipmentMethod', '', '', ShipmentMethodNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'Code', SalesShipmentHeader."Shipment Method Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'AgentCode', SalesShipmentHeader."Shipping Agent Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'AgentService', SalesShipmentHeader."Shipping Agent Service Code", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'TrackingNo', SalesShipmentHeader."Package Tracking No.", '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'ShipmentDate', Format(SalesShipmentHeader."Shipment Date", 0, 9), '', ChildNode);
        this.AddNonEmptyNode(ShipmentMethodNode, 'ShippingTime', Format(SalesShipmentHeader."Shipping Time", 0, 9), '', ChildNode);
    end;

    local procedure AddLineDataToXML(SalesShpmntLine: Record "Sales Shipment Line")
    var
        LineNode: XmlNode;
        ItemNode: XmlNode;
        ChildNode: XmlNode;
    begin
        this.XMLDOMManagement.AddElement(this.RootNode, 'Line', '', '', LineNode);
        this.AddNonEmptyNode(LineNode, 'ID', Format(SalesShpmntLine."Line No."), '', ChildNode);
        this.XMLDOMManagement.AddElement(LineNode, 'Item', '', '', ItemNode);
        this.AddNonEmptyNode(ItemNode, 'ID', SalesShpmntLine."No.", '', ChildNode);
        this.AddNonEmptyNode(ItemNode, 'Description', SalesShpmntLine.Description, '', ChildNode);
        this.AddNonEmptyNode(ItemNode, 'Quantity', Format(SalesShpmntLine.Quantity), '', ChildNode);
        this.AddNonEmptyNode(LineNode, 'ShipmentDate', Format(SalesShpmntLine."Shipment Date", 0, 9), '', ChildNode);
        this.AddNonEmptyNode(LineNode, 'PlannedDeliveryDate', Format(SalesShpmntLine."Planned Delivery Date", 0, 9), '', ChildNode);
    end;

    local procedure AddNonEmptyNode(Node: XmlNode; NodeName: Text; NodeValue: Text; Namespace: Text; var ChildNode: XmlNode)
    begin
        if NodeValue <> '' then
            this.XMLDOMManagement.AddElement(Node, NodeName, NodeValue, Namespace, ChildNode);
    end;

    local procedure AddPdf(AttachmentNode: XmlNode; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        ChildNode: XmlNode;
        AdditionalDocumentReferenceID: Text;
        Filename: Text;
        MimeCode: Text;
        EmbeddedDocumentBinaryObject: Text;
    begin
        if not this.GeneratePDFAttachmentAsAdditionalDocRef(
            SalesShipmentHeader,
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
        SalesShipmentHeader: Record "Sales Shipment Header";
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

        if not this.GeneratePDFAsTempBlob(SalesShipmentHeader, TempBlob) then
            exit(false);

        Filename := StrSubstNo(FileNameTok, Enum::"E-Document Type"::"Sales Shipment", SalesShipmentHeader."No.");
        AdditionalDocumentReferenceID := SalesShipmentHeader."No.";
        EmbeddedDocumentBinaryObject := Base64Convert.ToBase64(TempBlob.CreateInStream());
        MimeCode := 'application/pdf';
        exit(true);
    end;

    local procedure GeneratePDFAsTempBlob(SalesShipmentHeader: Record "Sales Shipment Header"; var TempBlob: Codeunit "Temp Blob"): Boolean
    var
        ReportSelections: Record "Report Selections";
    begin
        SalesShipmentHeader.SetRecFilter();
        ReportSelections.GetPdfReportForCust(
            TempBlob,
            "Report Selection Usage"::"S.Shipment",
             SalesShipmentHeader,
             SalesShipmentHeader."Bill-to Customer No.");

        exit(TempBlob.HasValue());
    end;

    /// <summary>
    /// Gets the XML document as a temporary blob.
    /// </summary>
    /// <param name="TempBlob">Return value: Temp Blob codeunit containing the document.</param>
    internal procedure GetShipmentXml(var TempBlob: Codeunit "Temp Blob")
    begin
        this.ShipmentXML.WriteTo(TempBlob.CreateOutStream());
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