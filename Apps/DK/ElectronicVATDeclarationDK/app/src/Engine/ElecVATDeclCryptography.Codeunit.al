namespace Microsoft.Finance.VAT.Reporting;

using System.Security.Encryption;
using System.Telemetry;
using System.Xml;

codeunit 13607 "Elec. VAT Decl. Cryptography"
{
    Access = Internal;

    var
        XMLDomManagement: Codeunit "XML DOM Management";
        ElecVATDeclXml: Codeunit "Elec. VAT Decl. Xml";
        FeatureTelemetry: Codeunit "Feature Telemetry";
        FeatureNameTxt: Label 'Electronic VAT Declaration DK', Locked = true;
        CertificatesInitiatedFromAKVTxt: Label 'Certificates initiated. Value of "Use Azure Key Vault" is %1', Locked = true;
        UploadClientCertificateErr: Label 'Upload client certificate on Certificates page and select code in the Electronic VAT Declaration Setup page';
        UploadServerCertificateErr: Label 'Upload server certificate on Certificates page and select code in the Electronic VAT Declaration Setup page';
        C14CanonicalizationTok: Label 'http://www.w3.org/2001/10/xml-exc-c14n#', Locked = true;
        SecurityXPathTok: Label '//wsse:Security', Locked = true;

    procedure SignXmlDocument(InputXmlDocument: XmlDocument; SignatureKey: Codeunit "Signature Key"; ReferenceList: List of [Text]; BinarySecurityTokenId: Text) SignedXmlDocument: XmlDocument
    var
        SignedXml: Codeunit SignedXml;
        SignatureXmlElement: XmlElement;
        SecurityXmlNode: XmlNode;
        Reference: Text;
    begin
        SignedXml.InitializeSignedXml(InputXmlDocument);
        SignedXml.SetSigningKey(SignatureKey);

        // References
        foreach Reference in ReferenceList do
            AddReference(SignedXml, Reference);

        // SignedInfo
        SignedXml.SetCanonicalizationMethod(C14CanonicalizationTok);
        SignedXml.SetSignatureMethod(SignedXml.GetXmlDsigRSASHA1Url());

        // KeyInfo
        SignedXml.InitializeKeyInfo();
        SignedXml.AddClause(GetKeyInfoNodeXmlElement(BinarySecurityTokenId));
        // KeyInfo is added on compute automatically

        SignedXml.ComputeSignature();
        SignatureXmlElement := SignedXml.GetXml();
        SignedXmlDocument := InputXmlDocument;
        XMLDOMManagement.FindNodeWithNamespace(SignedXmlDocument.AsXmlNode(), SecurityXPathTok, 'wsse', ElecVATDeclXml.GetWsseNamespace(), SecurityXmlNode);
        SecurityXmlNode.AsXmlElement().Add(SignatureXmlElement);
    end;

    procedure InitClientCertificate(var ClientCertificateBase64: Text; var SignatureKey: Codeunit "Signature Key")
    var
        ElecVATDeclSetup: Record "Elec. VAT Decl. Setup";
    begin
        ElecVATDeclSetup.Get();
        if ElecVATDeclSetup."Use Azure Key Vault" then
            InitClientCertificateFromAKV(ClientCertificateBase64, SignatureKey)
        else
            InitClientCertificateLocally(ClientCertificateBase64, SignatureKey);
        FeatureTelemetry.LogUsage('0000M89', FeatureNameTxt, CertificatesInitiatedFromAKVTxt);
    end;

    local procedure InitClientCertificateLocally(var ClientCertificateBase64: Text; var SignatureKey: Codeunit "Signature Key")
    var
        IsolatedCertificate: Record "Isolated Certificate";
        VATReturnESubmissionSetup: Record "Elec. VAT Decl. Setup";
        CertificateManagement: Codeunit "Certificate Management";
    begin
        if VATReturnESubmissionSetup.Get() then;
        if VATReturnESubmissionSetup."Client Certificate Code" = '' then
            Error(UploadClientCertificateErr);
        IsolatedCertificate.Get(VATReturnESubmissionSetup."Client Certificate Code");
        ClientCertificateBase64 := CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate);
        CertificateManagement.GetCertPrivateKey(IsolatedCertificate, SignatureKey);
    end;

    [NonDebuggable]
    local procedure InitClientCertificateFromAKV(var ClientPublicKeyBase64: Text; var SignatureKey: Codeunit "Signature Key")
    var
        ElecVATDeclAzKeyVault: Codeunit "Elec. VAT Decl. Az. Key Vault";
        CertificateManagement: Codeunit "Certificate Management";
        FullCertificateBase64: Text;
    begin
        FullCertificateBase64 := ElecVATDeclAzKeyVault.GetClientCertificateBase64FromAKV();
        SignatureKey.FromBase64String(FullCertificateBase64, '', true);
        ClientPublicKeyBase64 := CertificateManagement.GetPublicKeyAsBase64String(FullCertificateBase64, '');
    end;


    procedure InitServerSertificate(var ServerCertificateBase64: Text)
    var
        IsolatedCertificate: Record "Isolated Certificate";
        VATReturnESubmissionSetup: Record "Elec. VAT Decl. Setup";
        CertificateManagement: Codeunit "Certificate Management";
    begin
        if VATReturnESubmissionSetup.Get() then;
        if VATReturnESubmissionSetup."Server Certificate Code" = '' then
            Error(UploadServerCertificateErr);
        IsolatedCertificate.Get(VATReturnESubmissionSetup."Server Certificate Code");
        ServerCertificateBase64 := CertificateManagement.GetRawCertDataAsBase64String(IsolatedCertificate);
    end;

    local procedure AddReference(var SignedXml: Codeunit SignedXml; ReferenceId: Text)
    begin
        SignedXml.InitializeReference(FormatURI(ReferenceId));
        SignedXml.SetDigestMethod(SignedXml.GetXmlDsigSHA1Url());
        SignedXml.AddXmlDsigExcC14NTransformToReference();
        SignedXml.AddReferenceToSignedXML();
    end;

    local procedure GetKeyInfoNodeXmlElement(BinarySecurityTokenId: Text): XmlElement
    var
        SecurityTokenReferenceXmlNode: XmlNode;
        ReferenceXmlNode: XmlNode;
        RootXmlDocument: XmlDocument;
    begin
        RootXmlDocument := XmlDocument.Create();
        XMLDOMManagement.AddRootElementWithPrefix(RootXmlDocument, 'SecurityTokenReference', 'wsse', ElecVATDeclXml.GetWsseNamespace(), SecurityTokenReferenceXmlNode);
        XMLDOMManagement.AddElement(SecurityTokenReferenceXmlNode, 'Reference', '', ElecVATDeclXml.GetWsseNamespace(), ReferenceXmlNode);
        XMLDOMManagement.AddAttribute(ReferenceXmlNode, 'URI', FormatURI(BinarySecurityTokenId));
        XMLDOMManagement.AddAttribute(ReferenceXmlNode, 'ValueType', ElecVATDeclXml.GetX509TokenType());
        exit(SecurityTokenReferenceXmlNode.AsXmlElement());
    end;

    local procedure FormatURI(URI: Text): Text[250]
    var
        URITok: Label '#%1', Locked = true;
    begin
        if StrPos(URI, '#') = 0 then
            URI := StrSubstNo(URITok, URI);
        exit(CopyStr(URI, 1, 250));
    end;
}