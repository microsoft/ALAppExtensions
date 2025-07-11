namespace Microsoft.Finance.VAT.Reporting;

using System.Security.Encryption;
using System.Utilities;
using System.Xml;

codeunit 13618 "Elec. VAT Decl. Xml"
{
    Access = Internal;

    var
        XMLDomManagement: Codeunit "XML DOM Management";
        ReferenceList: List of [Text];
        BinarySecurityTokenId: Text;
        DeeplinkNotFoundErr: Label 'Deeplink for draft VAT Return not found in response';
        ResponseTransactionIDNotFoundErr: Label 'Response from SKAT does not contain a transaction ID.';
        DeeplinkXPathTok: Label '//%1:UrlIndicator', Locked = true;
        VATReturnStatusTok: Label '//%1:AdvisIdentifikator', Locked = true;
        ResponseTransactionIDXPathTok: Label '//%1:TransaktionIdentifier', Locked = true;
        DueDateXPathTok: Label '//%1:AngivelseFristKalenderBetalingDato', Locked = true;
        Error200XPathTok: Label '//%1:FejlIdentifikator', Locked = true;
        EncodingTypeTok: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-soap-message-security-1.0#Base64Binary', Locked = true;
        X509TokenTypeTok: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3', Locked = true;
        PrefixTok: Label 'ns', Locked = true;
        SoapNamespaceTok: Label 'http://schemas.xmlsoap.org/soap/envelope/', Locked = true;
        WsseNamespaceTok: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', Locked = true;
        WsuNamespaceTok: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd', Locked = true;
        SkatNamespace1Tok: Label 'urn:oio:skat:nemvirksomhed:ws:1.0.0', Locked = true;
        SkatNamespace2Tok: Label 'http://rep.oio.dk/skat.dk/basis/kontekst/xml/schemas/2006/09/01/', Locked = true;
        SkatNamespace3Tok: Label 'http://rep.oio.dk/skat.dk/motor/class/virksomhed/xml/schemas/20080401/', Locked = true;
        SkatNamespace4Tok: Label 'urn:oio:skat:nemvirksomhed:1.0.0', Locked = true;

    procedure PrepareRequest(ElecVATDeclRequestType: Enum "Elec. VAT Decl. Request Type"; ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var SignedDocument: XmlDocument; var TransactionID: Code[100])
    var
        ElecVATDeclCryptography: Codeunit "Elec. VAT Decl. Cryptography";
        SignatureKey: Codeunit "Signature Key";
        UnSignedDocument: XmlDocument;
        ClientCertificateBase64: Text;
    begin
        ElecVATDeclCryptography.InitClientCertificate(ClientCertificateBase64, SignatureKey);
        UnSignedDocument := CreateUnsignedDocument(ClientCertificateBase64, ElecVATDeclRequestType, ElecVATDeclParameters, TransactionID);
        SignedDocument := ElecVATDeclCryptography.SignXmlDocument(UnSignedDocument, SignatureKey, ReferenceList, BinarySecurityTokenId);
    end;

    procedure XmlDocumentOuterXmlToStream(DataXmlDocument: XmlDocument; var DataOutStream: OutStream)
    var
        XmlTempBlob: Codeunit "Temp Blob";
        DotNetXmlDocument: Codeunit DotNet_XmlDocument;
        XmlInStream: InStream;
        XmlOutStream: OutStream;
    begin
        XmlTempBlob.CreateOutStream(XmlOutStream);
        DataXmlDocument.WriteTo(XmlOutStream);
        DotNetXmlDocument.InitXmlDocument();
        XmlTempBlob.CreateInStream(XmlInStream);
        DotNetXmlDocument.Load(XmlInStream);
        DataOutStream.WriteText(DotNetXmlDocument.OuterXml());
    end;

    local procedure CreateUnsignedDocument(ClientCertificateBase64: Text; ElecVATDeclRequestType: Enum "Elec. VAT Decl. Request Type"; ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var TransactionID: Code[100]) UnsignedRequestDocument: XmlDocument
    var
        Envelope: XmlNode;
        Header: XmlNode;
        Body: XmlNode;
        Security: XmlNode;
        BinarySecurityToken: XmlNode;
        Timestamp: XmlNode;
        TimestampCreated: XmlNode;
        TimestampExpires: XmlNode;
        BodyReferenceList: List of [Text];
        Reference: Text;
        TimeStampId: Text;
    begin
        BinarySecurityTokenId := GetBinarySecurityTokenId();
        ReferenceList.Add(BinarySecurityTokenId);
        TimeStampId := GetTimestampId();
        ReferenceList.Add(TimeStampId);

        // Envelope
        XMLDomManagement.AddRootElementWithPrefix(UnsignedRequestDocument, 'Envelope', 'soapenv', GetSoapNamespace(), Envelope);

        // Header
        XMLDomManagement.AddElement(Envelope, 'Header', '', GetSoapNamespace(), Header);

        // Security
        XMLDomManagement.AddElement(Header, 'Security', '', GetWsseNamespace(), Security);
        XMLDomManagement.AddNamespaceDeclaration(Security, 'wsu', GetWsuNamespace());

        // BinarySecurityToken
        XMLDomManagement.AddElement(Security, 'BinarySecurityToken', ClientCertificateBase64, GetWsseNamespace(), BinarySecurityToken);
        XMLDomManagement.AddAttribute(BinarySecurityToken, 'EncodingType', EncodingTypeTok);
        XMLDomManagement.AddAttribute(BinarySecurityToken, 'ValueType', GetX509TokenType());
        XMLDomManagement.AddAttribute(BinarySecurityToken, 'Id', BinarySecurityTokenId);

        // Timestamp
        XMLDomManagement.AddElement(Security, 'Timestamp', '', GetWsuNamespace(), Timestamp);
        XMLDomManagement.AddAttribute(Timestamp, 'Id', TimeStampId);
        XMLDomManagement.AddElement(Timestamp, 'Created', GetTimeStamp(0), GetWsuNamespace(), TimestampCreated);
        XMLDomManagement.AddElement(Timestamp, 'Expires', GetTimeStamp(1), GetWsuNamespace(), TimestampExpires);

        // Body
        GetRequestBodyAndReferencesForType(ElecVATDeclRequestType, ElecVATDeclParameters, Body, BodyReferenceList, TransactionID);
        foreach Reference in BodyReferenceList do
            ReferenceList.Add(Reference);
        Envelope.AsXmlElement().Add(Body);
    end;

    local procedure GetRequestBodyAndReferencesForType(ElecVATDeclPayloadBuilder: Interface "Elec. VAT Decl. Payload Builder"; ElecVATDeclParameters: Record "Elec. VAT Decl. Parameters"; var Body: XmlNode; var BodyReferenceList: List of [Text]; var TransactionID: Code[100])
    begin
        ElecVATDeclPayloadBuilder.BuildPayload(ElecVATDeclParameters, Body, BodyReferenceList, TransactionID);
    end;

    procedure GetDeeplinkNodeFromResponseText(ResponseText: Text) DeeplinkNode: XmlNode
    begin
        if not XMLDomManagement.FindNodeWithNamespace(TextToXmlNode(ResponseText), StrSubstNo(DeeplinkXPathTok, PrefixTok), PrefixTok, GetSkatNamespace4(), DeeplinkNode) then
            Error(DeeplinkNotFoundErr);
    end;

    procedure GetResponseTransactionNodeFromResponseText(ResponseText: Text) TransactionIDNode: XmlNode
    begin
        if not XMLDomManagement.FindNodeWithNamespace(TextToXmlNode(ResponseText), StrSubstNo(ResponseTransactionIDXPathTok, PrefixTok), PrefixTok, GetSkatNamespace4(), TransactionIDNode) then
            Error(ResponseTransactionIDNotFoundErr);
    end;

    procedure GetVATReturnStatusNodeFromResponseText(ResponseText: Text) VATReturnStatusNode: XmlNode
    begin
        XmlDOMManagement.FindNodeWithNamespace(TextToXmlNode(ResponseText), StrSubstNo(VATReturnStatusTok, PrefixTok), PrefixTok, GetSkatNamespace2(), VATReturnStatusNode);
    end;

    procedure TryGetDueDateNodesFromResponseText(ResponseText: Text) DueDateNodes: XmlNodeList
    begin
        XmlDOMManagement.FindNodesWithNamespace(TextToXmlNode(ResponseText), StrSubstNo(DueDateXPathTok, PrefixTok), PrefixTok, GetSkatNamespace4(), DueDateNodes);
    end;

    procedure TryGetErrorNodeFromResponseText(ResponseText: Text; var ErrorNode: XmlNode) NodeFound: Boolean
    begin
        exit(XMLDomManagement.FindNodeWithNamespace(TextToXmlNode(ResponseText), StrSubstNo(Error200XPathTok, PrefixTok), PrefixTok, GetSkatNamespace2(), ErrorNode));
    end;

    local procedure TextToXmlNode(InputText: Text) OutputXmlNode: XmlNode
    var
        XmlDoc: XmlDocument;
    begin
        XmlDocument.ReadFrom(InputText, XmlDoc);
        OutputXmlNode := XmlDoc.AsXmlNode();
    end;

    procedure GetSoapNamespace(): Text
    begin
        exit(SoapNamespaceTok);
    end;

    procedure GetWsseNamespace(): Text
    begin
        exit(WsseNamespaceTok);
    end;

    local procedure GetWsuNamespace(): Text
    begin
        exit(WsuNamespaceTok);
    end;

    procedure GetX509TokenType(): Text
    begin
        exit(X509TokenTypeTok);
    end;

    procedure GetSkatNamespace1(): Text
    begin
        exit(SkatNamespace1Tok);
    end;

    procedure GetSkatNamespace2(): Text
    begin
        exit(SkatNamespace2Tok);
    end;

    procedure GetSkatNamespace3(): Text
    begin
        exit(SkatNamespace3Tok);
    end;

    procedure GetSkatNamespace4(): Text
    begin
        exit(SkatNamespace4Tok);
    end;

    procedure GetTimeStamp(AddedHours: Integer) XmlTimeStamp: Text
    var
        TimeStampTime: DateTime;
    begin
        TimeStampTime := CurrentDateTime();
        TimeStampTime += AddedHours * 60 * 60 * 1000;
        XmlTimeStamp := Format(TimeStampTime, 0, 9)
    end;

    procedure GetTransactionID(): Code[100]
    begin
        exit(CopyStr(CreateXMLGuid(), 1, 100));
    end;

    procedure GetCompanyID(): Text
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
    begin
        exit(ElecVATDeclSetup.GetSeeNumber());
    end;

    procedure Date_AsXMLText(DateToConvert: Date): Text
    begin
        exit(Format(DateToConvert, 0, 9));
    end;

    procedure GetBodyIdTok(): Text
    begin
        exit('Body-' + CreateXMLGuid());
    end;

    local procedure GetBinarySecurityTokenId(): Text
    begin
        exit('X509-' + CreateXMLGuid());
    end;

    local procedure GetTimeStampId(): Text
    begin
        exit('TS-' + CreateXMLGuid());
    end;

    local procedure CreateXMLGuid() Guid: Text
    begin
        Guid := CreateGuid();
        Guid := DelChr(Guid, '=', '{}');
    end;
}
