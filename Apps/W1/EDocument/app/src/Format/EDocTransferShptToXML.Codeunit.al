namespace Microsoft.EServices.EDocument.Format;

using System.Utilities;
using Microsoft.Inventory.Transfer;
using System.Xml;

codeunit 6120 "E-Doc. Transfer Shpt. To XML"
{
    TableNo = "Transfer Shipment Header";

    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        TransferShipmentXML: XmlDocument;
        RootNode: XmlNode;

    trigger OnRun()
    var
        TransferShipmentLine: Record "Transfer Shipment Line";
    begin
        AddHeaderDataToXML(Rec);
    end;

    local procedure AddHeaderDataToXML(TransferShipmentHeader: Record "Transfer Shipment Header")
    var
        ChildNode: XmlNode;
    begin
        this.TransferShipmentXML := XmlDocument.Create();
        this.XMLDOMManagement.AddRootElement(this.TransferShipmentXML, 'TransferShipment', this.RootNode);

        this.XMLDOMManagement.AddElement(this.RootNode, 'ID', TransferShipmentHeader."No.", '', ChildNode);
    end;

    internal procedure GetTransferShipmentXML(var TempBlob: Codeunit "Temp Blob")
    begin
        this.TransferShipmentXML.WriteTo(TempBlob.CreateOutStream());
    end;

}
