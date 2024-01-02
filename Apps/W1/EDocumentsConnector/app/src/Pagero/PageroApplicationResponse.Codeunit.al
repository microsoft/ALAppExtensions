// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.EServices.EDocumentConnector;

using Microsoft.Foundation.Company;
using System.Utilities;
using Microsoft.Purchases.Vendor;

codeunit 6367 "Pagero Application Response"
{
    Access = Internal;

    procedure PrepareResponse(var TempBlob: Codeunit "Temp Blob"; Parameters: Dictionary of [Text, Text])
    var
        XMLDocOut: XmlDocument;
        XMLCurrNode: XmlElement;
        FileOutstream: Outstream;
    begin
        XmlDocument.ReadFrom(GetAppResponseHeader(), XMLDocOut);
        XMLDocOut.GetRoot(XMLCurrNode);
        InitResponse(DocNameSpace, DocNameSpace2, DocNameSpace3, DocNameSpace4);

        XMLCurrNode.Add(XmlElement.Create('CustomizationID', DocNameSpace, 'urn:pagero.com:puf:invoice_response:1.0'));
        XMLCurrNode.Add(XmlElement.Create('ProfileID', DocNameSpace, 'urn:pagero.com:puf:invoice_response:1.0'));
        XMLCurrNode.Add(XmlElement.Create('ID', DocNameSpace, GetParameter(Parameters, 'ResponseId'))); // Response Identifier
        XMLCurrNode.Add(XmlElement.Create('IssueDate', DocNameSpace, FormatDate(WorkDate())));
        XMLCurrNode.Add(XmlElement.Create('IssueTime', DocNameSpace, '12:00:00'));
        XMLCurrNode.Add(XmlElement.Create('Note', DocNameSpace, GetParameter(Parameters, 'Note'))); // Response Note

        // SenderParty
        InsertSenderParty(XMLCurrNode);

        // ReceiverParty
        InsertReceiverParty(XMLCurrNode, GetParameter(Parameters, 'VendorNo'));

        // DocumentResponse
        InsertDocumentResponse(
            XMLCurrNode,
            GetParameter(Parameters, 'documentId'), GetParameter(Parameters, 'DocumentReference'), GetParameter(Parameters, 'Approve') = 'true', GetParameter(Parameters, 'RejectReason'));

        TempBlob.CreateOutStream(FileOutStream);
        XMLDocOut.WriteTo(FileOutstream);
    end;

    local procedure InsertSenderParty(var SenderPartyElement: XmlElement);
    var
        CompanyInformation: Record "Company Information";
        ChildElement: XmlElement;
    begin
        CompanyInformation.Get();
        ChildElement := XmlElement.Create('SenderParty', DocNameSpaceCAC);
        if CompanyInformation.GLN = '' then
            ChildElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC, CompanyInformation."VAT Registration No."))
        else
            ChildElement.Add(
                XmlElement.Create('EndpointID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', '0088'), CompanyInformation.GLN));
        InsertPartyIdentification(ChildElement, CompanyInformation."VAT Registration No.");
        InsertPartyLegalEntity(ChildElement, CompanyInformation.Name);

        SenderPartyElement.Add(ChildElement);
    end;

    local procedure InsertReceiverParty(var ReceiverPartyElement: XmlElement; VendorNo: Text);
    var
        Vendor: Record Vendor;
        ChildElement: XmlElement;
    begin
        VendorNo := CopyStr(VendorNo, 1, MaxStrLen(Vendor."No."));
        Vendor.Get(VendorNo);

        ChildElement := XmlElement.Create('ReceiverParty', DocNameSpaceCAC);
        if Vendor.GLN = '' then
            ChildElement.Add(XmlElement.Create('EndpointID', DocNameSpaceCBC, Vendor."VAT Registration No."))
        else
            ChildElement.Add(
                XmlElement.Create('EndpointID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', '0088'), Vendor.GLN));
        InsertPartyIdentification(ChildElement, Vendor."VAT Registration No.");
        InsertPartyLegalEntity(ChildElement, Vendor.Name);

        ReceiverPartyElement.Add(ChildElement);
    end;

    local procedure InsertPartyIdentification(var ParentElement: XmlElement; PartyID: Text);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('PartyIdentification', DocNameSpaceCAC);
        ChildElement.Add(
            XmlElement.Create('ID', DocNameSpaceCBC, XmlAttribute.Create('schemeID', '0184'), PartyID));

        ParentElement.Add(ChildElement);
    end;

    local procedure InsertPartyLegalEntity(var ParentElement: XmlElement; Name: Text);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('PartyLegalEntity', DocNameSpaceCAC);
        ChildElement.Add(XmlElement.Create('RegistrationName', DocNameSpaceCBC, Name));

        ParentElement.Add(ChildElement);
    end;

    local procedure InsertDocumentResponse(var ParentElement: XmlElement; DocumentId: Text; DocumentReference: Text; Approve: Boolean; RejectReason: Text);
    var
        ChildElement: XmlElement;
        ExtensionElement: XmlElement;
        ReasonCodeElement: XmlElement;
        PufElement: XmlElement;
        ChildElement1, ChildElement2, ChildElement3, ChildElement4 : XmlElement;
    begin
        ChildElement := XmlElement.Create('DocumentResponse', DocNameSpaceCAC);
        ParentElement.Add(ChildElement);

        ChildElement1 := XmlElement.Create('Response', DocNameSpaceCAC);
        ChildElement.Add(ChildElement1);

        ChildElement2 := XmlElement.Create('UBLExtensions', DocNameSpaceExt);
        ChildElement1.Add(ChildElement2);

        if Approve then
            ChildElement1.Add(XmlElement.Create('ResponseCode', DocNameSpaceCBC, 'AP')) // Invoice status code (UNCL4343 Subset)
        else begin
            ChildElement1.Add(XmlElement.Create('ResponseCode', DocNameSpaceCBC, 'RE'));  // Invoice status code (UNCL4343 Subset)
            ReasonCodeElement := XmlElement.Create('Status', DocNameSpaceCAC);
            ReasonCodeElement.Add(
                XmlElement.Create('StatusReasonCode', DocNameSpace, XmlAttribute.Create('listID', 'OPStatusReason'), 'OTH')); // Status Clarification Reason (OpenPEPPOL)
            ReasonCodeElement.Add(XmlElement.Create('StatusReason', DocNameSpaceCBC, RejectReason));
            ChildElement1.Add(ReasonCodeElement);
        end;

        ChildElement3 := XmlElement.Create('UBLExtension', DocNameSpaceExt);
        ChildElement2.Add(ChildElement3);
        ChildElement3.Add(XmlElement.Create('ExtensionURI', DocNameSpaceExt, 'urn:pagero:ExtensionComponent:1.0:PageroExtension:ResponseExtension'));

        ChildElement4 := XmlElement.Create('ExtensionContent', DocNameSpaceExt);
        ChildElement3.Add(ChildElement4);

        InsertResponseExtension(ExtensionElement, PufElement, DocumentId);
        ChildElement4.Add(PufElement);


        InsertDocReference(ChildElement, DocumentReference);
    end;

    local procedure InsertResponseExtension(var ParentElement: XmlElement; var ChildElement: XmlElement; DocumentId: Text);
    var
        ExtensionElement: XmlElement;
        DocumentMatchingID: XmlElement;
    begin

        ParentElement := ParentElement;
        ChildElement := XmlElement.Create('PageroExtension', DocNameSpacePuf);

        ExtensionElement := XmlElement.Create('ResponseExtension', DocNameSpacePuf);
        ChildElement.Add(ExtensionElement);

        DocumentMatchingID := XmlElement.Create('DocumentMatchingID', DocNameSpacePuf);
        ExtensionElement.Add(DocumentMatchingID);

        DocumentMatchingID.Add(XmlElement.Create('UUID', DocNameSpaceCBC, DocumentId));

    end;

    local procedure InsertDocReference(var ParentElement: XmlElement; DocumentReference: Text);
    var
        ChildElement: XmlElement;
    begin
        ChildElement := XmlElement.Create('DocumentReference', DocNameSpaceCAC);
        ChildElement.Add(XmlElement.Create('ID', DocNameSpaceCBC, DocumentReference));
        ChildElement.Add(XmlElement.Create('DocumentTypeCode', DocNameSpaceCBC, '380'));

        ParentElement.Add(ChildElement);
    end;

    procedure GetAppResponseHeader(): Text;
    begin
        exit('<?xml version="1.0" encoding="UTF-8" ?>' +
        '<ApplicationResponse xmlns="urn:oasis:names:specification:ubl:schema:xsd:ApplicationResponse-2" ' +
        'xmlns:cac="urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2" ' +
        'xmlns:cbc="urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2" ' +
        'xmlns:ext="urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2" ' +
        'xmlns:puf="urn:pagero:ExtensionComponent:1.0"' +
        '/>');
    end;

    procedure InitResponse(var XmlNameSpaceCBC: Text[250]; var XmlNameSpaceCAC: Text[250]; var XmlNameSpaceExt: Text[250]; var XmlNameSpacePuf: Text[250]);
    begin
        DocNameSpaceCBC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonBasicComponents-2';
        DocNameSpaceCAC := 'urn:oasis:names:specification:ubl:schema:xsd:CommonAggregateComponents-2';
        DocNameSpaceExt := 'urn:oasis:names:specification:ubl:schema:xsd:CommonExtensionComponents-2';
        DocNameSpacePuf := 'urn:pagero:ExtensionComponent:1.0';

        XmlNSAttributeCBC := XmlAttribute.CreateNamespaceDeclaration('cbc', DocNameSpaceCBC);
        XmlNSAttributeCAC := XmlAttribute.CreateNamespaceDeclaration('cac', DocNameSpaceCAC);
        XmlNSAttributeExt := XmlAttribute.CreateNamespaceDeclaration('ext', DocNameSpaceExt);
        XmlNSAttributePuf := XmlAttribute.CreateNamespaceDeclaration('puf', DocNameSpacePuf);

        XmlNameSpaceCBC := DocNameSpaceCBC;
        XmlNameSpaceCAC := DocNameSpaceCAC;
        XmlNameSpaceExt := DocNameSpaceExt;
        XmlNameSpacePuf := DocNameSpacePuf;
    end;


    local procedure GetParameter(Parameters: Dictionary of [Text, Text]; ParameterName: Text) ParameterValue: Text;
    begin
        if Parameters.Keys.Contains(ParameterName) then
            Parameters.Get(ParameterName, ParameterValue);
        exit(ParameterValue);
    end;

    local procedure FormatDate(InputDate: Date): Text;
    begin
        if InputDate = 0D then
            exit('');
        exit(Format(InputDate, 0, 9));
    end;

    var
        XmlNSAttributeCBC: XmlAttribute;
        XmlNSAttributeCAC: XmlAttribute;
        XmlNSAttributeExt: XmlAttribute;
        XmlNSAttributePuf: XmlAttribute;
        DocNameSpaceCBC: Text[250];
        DocNameSpaceCAC: Text[250];
        DocNameSpaceExt: Text[250];
        DocNameSpacePuf: Text[250];
        DocNameSpace, DocNameSpace2, DocNameSpace3, DocNameSpace4 : Text[250];
}