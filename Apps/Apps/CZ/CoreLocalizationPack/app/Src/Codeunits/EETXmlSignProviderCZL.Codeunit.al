// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance;

using System.Security.Encryption;
using System.Xml;

codeunit 31082 "EET Xml Sign. Provider CZL"
{
    Access = Internal;

    var
        SoapBodyId: Text;
        BinarySecurityTokenId: Text;

    [NonDebuggable]
    procedure SignData(DataInStream: InStream; IsolatedCertificate: Record "Isolated Certificate"; SignatureOutStream: OutStream)
    var
        CertificateManagement: Codeunit "Certificate Management";
        SignatureKey: Codeunit "Signature Key";
    begin
        CertificateManagement.GetCertPrivateKey(IsolatedCertificate, SignatureKey);
        SignData(DataInStream, SignatureKey, SignatureOutStream);
    end;

    [NonDebuggable]
    procedure SignData(DataInStream: InStream; SignatureKey: Codeunit "Signature Key"; SignatureOutStream: OutStream)
    var
        SignedXml: Codeunit SignedXml;
        SigningXmlDocument: XmlDocument;
    begin
        XmlDocument.ReadFrom(DataInStream, SigningXmlDocument);

        SignedXml.InitializeSignedXml(SigningXmlDocument);
        SignedXml.SetSigningKey(SignatureKey);

        // Reference
        SignedXml.InitializeReference(FormatURI(SoapBodyId));
        SignedXml.SetDigestMethod(SignedXml.GetXmlDsigSHA256Url());
        SignedXml.AddXmlDsigExcC14NTransformToReference('');

        // SignedInfo
        SignedXml.SetXmlDsigExcC14NTransformAsCanonicalizationMethod('soap');
        SignedXml.SetSignatureMethod(SignedXml.GetXmlDsigRSASHA256Url());

        // KeyInfo
        SignedXml.InitializeKeyInfo();
        SignedXml.AddClause(GetKeyInfoNodeXmlElement());

        SignedXml.ComputeSignature();
        SignedXml.GetXml().WriteTo(SignatureOutStream);
    end;

    procedure SetSoapBodyId(NewSoapBodyId: Text)
    begin
        SoapBodyId := NewSoapBodyId;
    end;

    procedure SetBinarySecurityTokenId(NewBinarySecurityTokenId: Text)
    begin
        BinarySecurityTokenId := NewBinarySecurityTokenId;
    end;

    local procedure FormatURI(URI: Text): Text[250]
    var
        URITok: Label '#%1', Locked = true;
    begin
        if StrPos(URI, '#') = 0 then
            URI := StrSubstNo(URITok, URI);
        exit(CopyStr(URI, 1, 250));
    end;

    local procedure GetKeyInfoNodeXmlElement(): XmlElement
    var
        XMLDOMManagement: Codeunit "XML DOM Management";
        SecurityTokenReferenceXmlNode: XmlNode;
        ReferenceXmlNode: XmlNode;
        RootXmlDocument: XmlDocument;
        SecurityExtensionNamespaceTxt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd', Locked = true;
        SecurityValueTypeX509V3Txt: Label 'http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-x509-token-profile-1.0#X509v3', Locked = true;
    begin
        RootXmlDocument := XmlDocument.Create();
        XMLDOMManagement.AddRootElementWithPrefix(
            RootXmlDocument, 'SecurityTokenReference', 'wsse', SecurityExtensionNamespaceTxt, SecurityTokenReferenceXmlNode);
        XMLDOMManagement.AddElementWithPrefix(SecurityTokenReferenceXmlNode, 'Reference', '', 'wsse', SecurityExtensionNamespaceTxt, ReferenceXmlNode);
        XMLDOMManagement.AddAttribute(ReferenceXmlNode, 'URI', FormatURI(BinarySecurityTokenId));
        XMLDOMManagement.AddAttribute(ReferenceXmlNode, 'ValueType', SecurityValueTypeX509V3Txt);
        exit(SecurityTokenReferenceXmlNode.AsXmlElement());
    end;
}
