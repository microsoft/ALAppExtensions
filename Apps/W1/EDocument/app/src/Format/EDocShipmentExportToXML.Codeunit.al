namespace Microsoft.EServices.EDocument.Format;

using Microsoft.Sales.History;
using Microsoft.Sales.Customer;
using Microsoft.Foundation.Company;
using System.Utilities;
using System.Xml;

codeunit 6120 "E-Doc. Shipment Export To XML"
{
    TableNo = "Sales Shipment Header";

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

        this.XMLDOMManagement.AddElement(this.RootNode, 'ID', SalesShipmentHeader."No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(this.RootNode, 'IssueDate', Format(SalesShipmentHeader."Posting Date", 0, 9), '', ChildNode);
        this.XMLDOMManagement.AddElement(this.RootNode, 'DueDate', Format(SalesShipmentHeader."Due Date", 0, 9), '', ChildNode);

        this.XMLDOMManagement.AddElement(this.RootNode, 'SupplierInformation', SalesShipmentHeader."Currency Code", '', ChildNode);
        this.AddCompanyInfoToXML(ChildNode, SalesShipmentHeader);

        this.XMLDOMManagement.AddElement(this.RootNode, 'CustomerInformation', SalesShipmentHeader."Currency Code", '', ChildNode);
        this.AddCustomerdataToXML(ChildNode, SalesShipmentHeader);
    end;

    local procedure AddCompanyInfoToXML(SupplierNode: XmlNode; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        CompanyInformation: Record "Company Information";
        AddressNode: XmlNode;
        ChildNode: XmlNode;
    begin
        CompanyInformation.Get();
        this.XMLDOMManagement.AddElement(SupplierNode, 'Name', CompanyInformation.Name, '', ChildNode);
        this.XMLDOMManagement.AddElement(SupplierNode, 'VATNo', CompanyInformation."VAT Registration No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(SupplierNode, 'Address', '', '', AddressNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'Street', CompanyInformation.Address, '', ChildNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'City', CompanyInformation.City, '', ChildNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'Country', CompanyInformation."Country/Region Code", '', ChildNode);
    end;

    local procedure AddCustomerdataToXML(CustomerNode: XmlNode; SalesShipmentHeader: Record "Sales Shipment Header")
    var
        Customer: Record Customer;
        AddressNode: XmlNode;
        ChildNode: XmlNode;
    begin
        Customer.Get(SalesShipmentHeader."Bill-to Customer No.");
        this.XMLDOMManagement.AddElement(CustomerNode, 'Name', Customer.Name, '', ChildNode);
        this.XMLDOMManagement.AddElement(CustomerNode, 'VATNo', Customer."VAT Registration No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(CustomerNode, 'Address', '', '', AddressNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'Street', Customer.Address, '', ChildNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'City', Customer.City, '', ChildNode);
        this.XMLDOMManagement.AddElement(AddressNode, 'Country', Customer."Country/Region Code", '', ChildNode);
    end;

    local procedure AddLineDataToXML(SalesShpmntLine: Record "Sales Shipment Line")
    var
        LineNode: XmlNode;
        ItemNode: XmlNode;
        ChildNode: XmlNode;
    begin
        this.XMLDOMManagement.AddElement(this.RootNode, 'Line', '', '', LineNode);
        this.XMLDOMManagement.AddElement(LineNode, 'ID', Format(SalesShpmntLine."Line No."), '', ChildNode);
        this.XMLDOMManagement.AddElement(LineNode, 'Item', '', '', ItemNode);
        this.XMLDOMManagement.AddElement(ItemNode, 'ID', SalesShpmntLine."No.", '', ChildNode);
        this.XMLDOMManagement.AddElement(ItemNode, 'Description', SalesShpmntLine.Description, '', ChildNode);
        this.XMLDOMManagement.AddElement(ItemNode, 'Quantity', Format(SalesShpmntLine.Quantity), '', ChildNode);
        this.XMLDOMManagement.AddElement(LineNode, 'ShipmentDate', Format(SalesShpmntLine."Shipment Date", 0, 9), '', ChildNode);
        this.XMLDOMManagement.AddElement(LineNode, 'PlannedDeliveryDate', Format(SalesShpmntLine."Planned Delivery Date", 0, 9), '', ChildNode);
    end;

    internal procedure GetShipmentXml(var TempBlob: Codeunit "Temp Blob")
    var
        OutStream: OutStream;
    begin
        TempBlob.CreateOutStream(OutStream);
        this.ShipmentXML.WriteTo(OutStream);
    end;

    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        ShipmentXML: XmlDocument;
        RootNode: XmlNode;

}
