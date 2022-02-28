// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1461 "SignedXml Impl."
{
    Access = Internal;

    var
        DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm;
        DotNetKeyInfo: DotNet KeyInfo;
        DotNetReference: DotNet Reference;
        DotNetSignedXml: DotNet SignedXml;
        DotNetDataObject: DotNet DataObject;


    #region Constructors
    procedure InitializeSignedXml(SigningXmlDocument: XmlDocument)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        DotNetXmlDocument: DotNet XmlDocument;
    begin
        XmlDotNetConvert.ToDotNet(SigningXmlDocument, DotNetXmlDocument, true);
        DotNetSignedXml := DotNetSignedXml.SignedXml(DotNetXmlDocument);
    end;

    procedure InitializeSignedXml(SigningXmlElement: XmlElement)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        DotNetXmlElement: DotNet XmlElement;
    begin
        XmlDotNetConvert.ToDotNet(SigningXmlElement, DotNetXmlElement, true);
        DotNetSignedXml := DotNetSignedXml.SignedXml(DotNetXmlElement);
    end;
    #endregion

    #region Reference
    procedure InitializeReference(Uri: Text)
    begin
        DotNetReference := DotNetReference.Reference(Uri);
    end;

    procedure SetDigestMethod(DigestMethod: Text)
    begin
        DotNetReference.DigestMethod := DigestMethod;
    end;

    procedure AddXmlDsigExcC14NTransformToReference(InclusiveNamespacesPrefixList: Text)
    var
        DotNetXmlDsigExcC14NTransform: DotNet XmlDsigExcC14NTransform;
    begin
        DotNetXmlDsigExcC14NTransform := DotNetXmlDsigExcC14NTransform.XmlDsigExcC14NTransform(InclusiveNamespacesPrefixList);
        DotNetReference.AddTransform(DotNetXmlDsigExcC14NTransform);
    end;

    procedure AddXmlDsigExcC14NTransformToReference()
    var
        DotNetXmlDsigExcC14NTransform: DotNet XmlDsigExcC14NTransform;
    begin
        DotNetXmlDsigExcC14NTransform := DotNetXmlDsigExcC14NTransform.XmlDsigExcC14NTransform();
        DotNetReference.AddTransform(DotNetXmlDsigExcC14NTransform);
    end;

    procedure AddXmlDsigEnvelopedSignatureTransform()
    var
        DotNetXmlDsigEnvelopedSignatureTransform: DotNet XmlDsigEnvelopedSignatureTransform;
    begin
        DotNetXmlDsigEnvelopedSignatureTransform := DotNetXmlDsigEnvelopedSignatureTransform.XmlDsigEnvelopedSignatureTransform();
        DotNetReference.AddTransform(DotNetXmlDsigEnvelopedSignatureTransform);
    end;
    #endregion

    #region SignedInfo
    procedure SetCanonicalizationMethod(CanonicalizationMethod: Text)
    begin
        DotNetSignedXml.SignedInfo.CanonicalizationMethod := CanonicalizationMethod;
    end;

    procedure SetXmlDsigExcC14NTransformAsCanonicalizationMethod(InclusiveNamespacesPrefixList: Text)
    var
        DotNetXmlDsigExcC14NTransform: DotNet XmlDsigExcC14NTransform;
    begin
        SetCanonicalizationMethod(GetXmlDsigExcC14NTransformUrl());
        DotNetXmlDsigExcC14NTransform := DotNetSignedXml.SignedInfo.CanonicalizationMethodObject;
        DotNetXmlDsigExcC14NTransform.InclusiveNamespacesPrefixList := InclusiveNamespacesPrefixList;
    end;

    procedure SetSignatureMethod(SignatureMethod: Text)
    begin
        DotNetSignedXml.SignedInfo.SignatureMethod := SignatureMethod;
    end;
    #endregion

    #region KeyInfo
    procedure InitializeKeyInfo()
    begin
        DotNetKeyInfo := DotNetKeyInfo.KeyInfo();
    end;

    procedure AddClause(KeyInfoNodeXmlElement: XmlElement)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        DotNetKeyInfoNode: DotNet KeyInfoNode;
        DotNetXmlElement: DotNet XmlElement;
    begin
        XmlDotNetConvert.ToDotNet(KeyInfoNodeXmlElement, DotNetXmlElement, true);
        DotNetKeyInfoNode := DotNetKeyInfoNode.KeyInfoNode(DotNetXmlElement);
        AddClause(DotNetKeyInfoNode);
    end;

    local procedure AddClause(DotNetKeyInfoClause: DotNet KeyInfoClause)
    begin
        DotNetKeyInfo.AddClause(DotNetKeyInfoClause);
    end;
    #endregion

    #region DataObject
    procedure InitializeDataObject()
    begin
        DotNetDataObject := DotNetDataObject.DataObject();
    end;

    procedure AddObject(DataObjectXmlElement: XmlElement)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        DotNetXmlElement: DotNet XmlElement;
    begin
        XmlDotNetConvert.ToDotNet(DataObjectXmlElement, DotNetXmlElement, true);
        DotNetDataObject.LoadXml(DotNetXmlElement);
        DotNetSignedXml.AddObject(DotNetDataObject);
    end;
    #endregion

    procedure LoadXml(SignatureElement: XmlElement)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        DotNetXmlElement: DotNet XmlElement;
    begin
        XmlDotNetConvert.ToDotNet(SignatureElement, DotNetXmlElement, true);
        DotNetSignedXml.LoadXml(DotNetXmlElement);
    end;

#if not CLEAN19
#pragma warning disable AL0432
    [Obsolete('Replaced by SetSigningKey function with XmlString parameter.', '19.1')]
    procedure SetSigningKey(var SignatureKey: Record "Signature Key")
    begin
        if SignatureKey.TryGetInstance(DotNetAsymmetricAlgorithm) then
            DotNetSignedXml.SigningKey := DotNetAsymmetricAlgorithm;
    end;
#pragma warning restore
#endif

    procedure SetSigningKey(XmlString: Text)
    begin
        SetSigningKey(XmlString, Enum::SignatureAlgorithm::RSA);
    end;

    procedure SetSigningKey(XmlString: Text; SignatureAlgorithm: Enum SignatureAlgorithm)
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        ISignatureAlgorithm := SignatureAlgorithm;
        ISignatureAlgorithm.FromXmlString(XmlString);
        ISignatureAlgorithm.GetInstance(DotNetAsymmetricAlgorithm);
        DotNetSignedXml.SigningKey := DotNetAsymmetricAlgorithm;
    end;

    procedure SetSigningKey(SignatureKey: Codeunit "Signature Key")
    begin
        SetSigningKey(SignatureKey.ToXmlString());
    end;

    procedure ComputeSignature()
    begin
        if not IsNull(DotNetReference) then
            DotNetSignedXml.AddReference(DotNetReference);
        if not IsNull(DotNetKeyInfo) then
            DotNetSignedXml.KeyInfo := DotNetKeyInfo;
        DotNetSignedXml.ComputeSignature();
    end;

    procedure GetXml() SignedXmlElement: XmlElement
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
    begin
        XmlDotNetConvert.FromDotNet(DotNetSignedXml.GetXml(), SignedXmlElement);
    end;

    procedure CheckSignature(): Boolean
    begin
        exit(DotNetSignedXml.CheckSignature());
    end;

    procedure CheckSignature(XmlString: Text): Boolean
    var
        ISignatureAlgorithm: Interface SignatureAlgorithm;
    begin
        ISignatureAlgorithm := Enum::SignatureAlgorithm::RSA;
        ISignatureAlgorithm.FromXmlString(XmlString);
        ISignatureAlgorithm.GetInstance(DotNetAsymmetricAlgorithm);
        exit(DotNetSignedXml.CheckSignature(DotNetAsymmetricAlgorithm));
    end;

    procedure CheckSignature(X509CertBase64Value: Text; X509CertPassword: Text; VerifySignatureOnly: Boolean): Boolean
    var
        X509Certificate2Impl: Codeunit "X509Certificate2 Impl.";
        X509Certificate2: DotNet X509Certificate2;
    begin
        X509Certificate2Impl.InitializeX509Certificate(X509CertBase64Value, X509CertPassword, X509Certificate2);
        exit(DotNetSignedXml.CheckSignature(X509Certificate2, VerifySignatureOnly));
    end;

    #region Static Fields
    procedure GetXmlDsigDSAUrl(): Text[250]
    var
        XmlDsigDSAUrlTok: Label 'XmlDsigDSAUrl', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigDSAUrlTok));
    end;

    procedure GetXmlDsigExcC14NTransformUrl(): Text[250]
    var
        XmlDsigExcC14NTransformUrlTok: Label 'XmlDsigExcC14NTransformUrl', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigExcC14NTransformUrlTok));
    end;

    procedure GetXmlDsigHMACSHA1Url(): Text[250]
    var
        XmlDsigHMACSHA1UrlTok: Label 'XmlDsigHMACSHA1Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigHMACSHA1UrlTok));
    end;

    procedure GetXmlDsigRSASHA1Url(): Text[250]
    var
        XmlDsigRSASHA1UrlTok: Label 'XmlDsigRSASHA1Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigRSASHA1UrlTok));
    end;

    procedure GetXmlDsigRSASHA256Url(): Text[250]
    var
        XmlDsigRSASHA256UrlTok: Label 'XmlDsigRSASHA256Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigRSASHA256UrlTok));
    end;

    procedure GetXmlDsigRSASHA384Url(): Text[250]
    var
        XmlDsigRSASHA384UrlTok: Label 'XmlDsigRSASHA384Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigRSASHA384UrlTok));
    end;

    procedure GetXmlDsigRSASHA512Url(): Text[250]
    var
        XmlDsigRSASHA512UrlTok: Label 'XmlDsigRSASHA512Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigRSASHA512UrlTok));
    end;

    procedure GetXmlDsigSHA1Url(): Text[250]
    var
        XmlDsigSHA1UrlTok: Label 'XmlDsigSHA1Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigSHA1UrlTok));
    end;

    procedure GetXmlDsigSHA256Url(): Text[250]
    var
        XmlDsigSHA256UrlTok: Label 'XmlDsigSHA256Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigSHA256UrlTok));
    end;

    procedure GetXmlDsigSHA384Url(): Text[250]
    var
        XmlDsigSHA384UrlTok: Label 'XmlDsigSHA384Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigSHA384UrlTok));
    end;

    procedure GetXmlDsigSHA512Url(): Text[250]
    var
        XmlDsigSHA512UrlTok: Label 'XmlDsigSHA512Url', Locked = true;
    begin
        exit(GetFieldValue(XmlDsigSHA512UrlTok));
    end;
    #endregion

    local procedure GetFieldValue(FieldName: Text): Text[250]
    var
        SignedXmlType: DotNet Type;
    begin
        SignedXmlType := GetDotNetType(DotNetSignedXml);
        exit(CopyStr(SignedXmlType.GetField(FieldName).GetValue(GetDotNetType(DotNetSignedXml)), 1, 250));
    end;
}