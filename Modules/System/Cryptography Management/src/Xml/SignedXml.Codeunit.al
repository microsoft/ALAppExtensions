// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides a functionality to singing an xml document.
/// </summary>
codeunit 1460 SignedXml
{
    Access = Public;

    var
        SignedXmlImpl: Codeunit "SignedXml Impl.";

    /// <summary>
    /// Initializes a new instance of the SignedXml class from the specified XML document.
    /// </summary>
    /// <param name="SigningXmlDocument">The XmlDocument object to use to initialize the new instance of SignedXml.</param>
    procedure InitializeSignedXml(SigningXmlDocument: XmlDocument)
    begin
        SignedXmlImpl.InitializeSignedXml(SigningXmlDocument);
    end;

    /// <summary>
    /// Initializes a new instance of the SignedXml class from the specified XmlElement object.
    /// </summary>
    /// <param name="SigningXmlElement">The XmlElement object to use to initialize the new instance of SignedXml.</param>
    procedure InitializeSignedXml(SigningXmlElement: XmlElement)
    begin
        SignedXmlImpl.InitializeSignedXml(SigningXmlElement);
    end;
#if not CLEAN19
#pragma warning disable AL0432
    /// <summary>
    /// Sets the key used for signing a SignedXml object.
    /// </summary>
    /// <param name="SignatureKey">The key used for signing the SignedXml object.</param>
    [Obsolete('Replaced by SetSigningKey function with XmlString parameter.', '19.1')]
    procedure SetSigningKey(var SignatureKey: Record "Signature Key")
    begin
        SignedXmlImpl.SetSigningKey(SignatureKey);
    end;
#pragma warning restore
#endif

    /// <summary>
    /// Sets the key used for signing a SignedXml object.
    /// </summary>
    /// <param name="XmlString">The XML string containing key information.</param>
    procedure SetSigningKey(XmlString: Text)
    begin
        SignedXmlImpl.SetSigningKey(XmlString);
    end;

    /// <summary>
    /// Sets the key used for signing a SignedXml object.
    /// </summary>
    /// <param name="XmlString">The XML string containing key information.</param>
    /// <param name="SignatureAlgorithm">The type of asymmetric algorithms.</param>
    procedure SetSigningKey(XmlString: Text; SignatureAlgorithm: Enum SignatureAlgorithm)
    begin
        SignedXmlImpl.SetSigningKey(XmlString, SignatureAlgorithm);
    end;

    /// <summary>
    /// Sets the key used for signing a SignedXml object.
    /// </summary>
    /// <param name="SignatureKey">The key used for signing the SignedXml object.</param>
    procedure SetSigningKey(SignatureKey: Codeunit "Signature Key")
    begin
        SignedXmlImpl.SetSigningKey(SignatureKey);
    end;

    /// <summary>
    /// Initializes a new instance of the Reference class with the specified Uri.
    /// </summary>
    /// <param name="Uri">The Uri with which to initialize the new instance of Reference.</param>
    procedure InitializeReference(Uri: Text)
    begin
        SignedXmlImpl.InitializeReference(Uri);
    end;

    /// <summary>
    /// Sets the digest method Uniform Resource Identifier (URI) of the current Reference.
    /// </summary>
    /// <param name="DigestMethod">The digest method URI of the current Reference. The default value is http://www.w3.org/2001/04/xmlenc#sha256.</param>
    procedure SetDigestMethod(DigestMethod: Text)
    begin
        SignedXmlImpl.SetDigestMethod(DigestMethod);
    end;

    /// <summary>
    /// Adds a XmlDsigExcC14NTransform object to the list of transforms to be performed on the data before passing it to the digest algorithm.
    /// </summary>
    /// <param name="InclusiveNamespacesPrefixList">A string that contains namespace prefixes to canonicalize using the standard canonicalization algorithm.</param>
    procedure AddXmlDsigExcC14NTransformToReference(InclusiveNamespacesPrefixList: Text)
    begin
        SignedXmlImpl.AddXmlDsigExcC14NTransformToReference(InclusiveNamespacesPrefixList);
    end;

    /// <summary>
    /// Sets the canonicalization algorithm that is used before signing for the current SignedInfo object.
    /// </summary>
    /// <param name="CanonicalizationMethod">The canonicalization algorithm used before signing for the current SignedInfo object.</param>
    procedure SetCanonicalizationMethod(CanonicalizationMethod: Text)
    begin
        SignedXmlImpl.SetCanonicalizationMethod(CanonicalizationMethod);
    end;

    /// <summary>
    /// Sets the XmlDsigExcC14NTransform as canonicalization algorithm that is used before signing for the current SignedInfo object.
    /// </summary>
    /// <param name="InclusiveNamespacesPrefixList">A string that contains namespace prefixes to canonicalize using the standard canonicalization algorithm.</param>
    procedure SetXmlDsigExcC14NTransformAsCanonicalizationMethod(InclusiveNamespacesPrefixList: Text)
    begin
        SignedXmlImpl.SetXmlDsigExcC14NTransformAsCanonicalizationMethod(InclusiveNamespacesPrefixList);
    end;

    /// <summary>
    /// Sets the name of the algorithm used for signature generation and validation for the current SignedInfo object.
    /// </summary>
    /// <param name="SignatureMethod">The name of the algorithm used for signature generation and validation for the current SignedInfo object.</param>
    procedure SetSignatureMethod(SignatureMethod: Text)
    begin
        SignedXmlImpl.SetSignatureMethod(SignatureMethod);
    end;

    /// <summary>
    /// Initializes a new instance of the KeyInfo class.
    /// </summary>
    procedure InitializeKeyInfo()
    begin
        SignedXmlImpl.InitializeKeyInfo();
    end;

    /// <summary>
    /// Adds a xml element of KeyInfoNode to the collection of KeyInfoClause.
    /// </summary>
    /// <param name="KeyInfoNodeXmlElement">The xml element of KeyInfoNode to add to the collection of KeyInfoClause.</param>
    procedure AddClause(KeyInfoNodeXmlElement: XmlElement)
    begin
        SignedXmlImpl.AddClause(KeyInfoNodeXmlElement);
    end;

    /// <summary>
    /// Loads a SignedXml state from an XML element.
    /// </summary>
    /// <param name="SignatureElement">The XML element to load the SignedXml state from.</param>
    procedure LoadXml(SignatureElement: XmlElement)
    begin
        SignedXmlImpl.LoadXml(SignatureElement);
    end;

    /// <summary>
    /// Initializes a new instance of the DataObject class.
    /// </summary>
    procedure InitializeDataObject()
    begin
        SignedXmlImpl.InitializeDataObject();
    end;

    /// <summary>
    /// Adds a xml element of DataObject object to the list of objects to be signed.
    /// </summary>
    /// <param name="DataObjectXmlElement">The xml element of DataObject to add to the list of objects to be signed.</param>
    procedure AddObject(DataObjectXmlElement: XmlElement)
    begin
        SignedXmlImpl.AddObject(DataObjectXmlElement);
    end;

    /// <summary>
    /// Adds a AddXmlDsigExcC14NTransformToReference object to the list of transforms to be performed on the data before passing it to the digest algorithm.
    /// </summary>
    procedure AddXmlDsigExcC14NTransformToReference()
    begin
        SignedXmlImpl.AddXmlDsigExcC14NTransformToReference();
    end;
    /// <summary>
    /// Adds a AddXmlDsigEnvelopedSignatureTransform object to the list of transforms to be performed on the data before passing it to the digest algorithm.
    /// </summary>
    procedure AddXmlDsigEnvelopedSignatureTransform()
    begin
        SignedXmlImpl.AddXmlDsigEnvelopedSignatureTransform();
    end;

    /// <summary>
    /// Computes an Xml digital signature from Xml document.
    /// </summary>
    procedure ComputeSignature()
    begin
        SignedXmlImpl.ComputeSignature();
    end;

    /// <summary>
    /// Determines whether the signature verifies using the public key in the signature.
    /// </summary>
    /// <returns>true if the signature verifies; otherwise, false.</returns>
    procedure CheckSignature(): Boolean
    begin
        exit(SignedXmlImpl.CheckSignature());
    end;

    /// <summary>
    /// Determines whether the Signature property verifies for the specified key.
    /// </summary>
    /// <param name="XmlString">The XML string containing key information.</param>
    /// <returns>true if the signature verifies; otherwise, false.</returns>
    procedure CheckSignature(XmlString: Text): Boolean
    begin
        exit(SignedXmlImpl.CheckSignature(XmlString));
    end;

    /// <summary>
    /// Determines whether the signature verifies for the specified X509Certificate2 and, optionally, whether the certificate is valid.
    /// </summary>
    /// <param name="X509CertBase64Value">The X509Certificate2 in Base64 format to use to verify the signature.</param>
    /// <param name="X509CertPassword">The password to the X509Certificate2.</param>
    /// <param name="VerifySignatureOnly">true to verify the signature only; false to verify both the signature and certificate.</param>
    /// <returns>true if the signature verifies; otherwise, false.</returns>
    procedure CheckSignature(X509CertBase64Value: Text; X509CertPassword: Text; VerifySignatureOnly: Boolean): Boolean
    begin
        exit(SignedXmlImpl.CheckSignature(X509CertBase64Value, X509CertPassword, VerifySignatureOnly));
    end;

    /// <summary>
    /// Returns the Xml representation of a signature.
    /// </summary>
    /// <returns>The Xml representation of the signature.</returns>
    procedure GetXml(): XmlElement
    begin
        exit(SignedXmlImpl.GetXml());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard DSA algorithm for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2000/09/xmldsig#dsa-sha1.</returns>
    /// <see cref="https://www.w3.org/2000/09/xmldsig#dsa-sha1"/>
    procedure GetXmlDsigDSAUrl(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigDSAUrl());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for exclusive XML canonicalization.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/10/xml-exc-c14n#.</returns>
    /// <see cref="https://www.w3.org/2001/10/xml-exc-c14n"/>
    procedure GetXmlDsigExcC14NTransformUrl(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigExcC14NTransformUrl());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard HMACSHA1 algorithm for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2000/09/xmldsig#hmac-sha1.</returns>
    /// <see cref="https://www.w3.org/2000/09/xmldsig#hmac-sha1"/>
    procedure GetXmlDsigHMACSHA1Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigHMACSHA1Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard RSA signature method for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2000/09/xmldsig#rsa-sha1.</returns>
    /// <see cref="https://www.w3.org/2000/09/xmldsig#rsa-sha1"/>
    procedure GetXmlDsigRSASHA1Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigRSASHA1Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the RSA SHA-256 signature method variation for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha256.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmldsig-more#rsa-sha256"/>
    procedure GetXmlDsigRSASHA256Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigRSASHA256Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the RSA SHA-384 signature method variation for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha384.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmldsig-more#rsa-sha384"/>
    procedure GetXmlDsigRSASHA384Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigRSASHA384Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the RSA SHA-512 signature method variation for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmldsig-more#rsa-sha512.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmldsig-more#rsa-sha512"/>
    procedure GetXmlDsigRSASHA512Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigRSASHA512Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard SHA1 digest method for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2000/09/xmldsig#sha1.</returns>
    /// <see cref="https://www.w3.org/2000/09/xmldsig#sha1"/>
    procedure GetXmlDsigSHA1Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigSHA1Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard SHA256 digest method for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmlenc#sha256.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmlenc#sha256"/>
    procedure GetXmlDsigSHA256Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigSHA256Url());
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard SHA384 digest method for XML digital signatures.
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmldsig-more#sha384.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmldsig-more#sha384"/>
    procedure GetXmlDsigSHA384Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigSHA384Url())
    end;

    /// <summary>
    /// Represents the Uniform Resource Identifier (URI) for the standard SHA512 digest method for XML digital signatures. 
    /// </summary>
    /// <returns>The value http://www.w3.org/2001/04/xmlenc#sha512.</returns>
    /// <see cref="https://www.w3.org/2001/04/xmlenc#sha512"/>
    procedure GetXmlDsigSHA512Url(): Text[250]
    begin
        exit(SignedXmlImpl.GetXmlDsigSHA512Url());
    end;
}