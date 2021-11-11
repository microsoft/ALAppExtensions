// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for encrypting and decrypting XML documents.
/// </summary>
codeunit 1465 EncryptedXml
{
    Access = Public;

    var
        EncryptedXmlImpl: Codeunit "EncryptedXml Impl.";

    /// <summary>
    /// Creates a symmetric session key to encrypt the outer XML of an element using the specified X.509 certificate.     
    /// </summary>
    /// <param name="XmlDocument">The XmlDocument to encrypt.</param>
    /// <param name="ElementToEncrypt">The name of the element to encrypt.</param>
    /// <param name="X509CertBase64Value">The X509Certificate2 to use for the asymmetric encryption.</param>
    /// <param name="X509CertPassword">Password to the X509Certificate2.</param>
    [NonDebuggable]
    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text; X509CertPassword: Text)
    begin
        EncryptedXmlImpl.Encrypt(XmlDocument, ElementToEncrypt, X509CertBase64Value, X509CertPassword);
    end;

    /// <summary>
    /// Creates a symmetric session key using the specified SymmetricAlgorithm 
    /// to encrypt the outer XML of an element using the specified X.509 certificate.
    /// </summary>
    /// <param name="XmlDocument">The XmlDocument to encrypt.</param>
    /// <param name="ElementToEncrypt">The name of the element to encrypt.</param>
    /// <param name="X509CertBase64Value">The X509Certificate2 to use for the asymmetric encryption.</param>
    /// <param name="X509CertPassword">Password to the X509Certificate2.</param>
    /// <param name="SymmetricAlgorithm">The symmetric algorithm to be used when encrypting.</param>
    [NonDebuggable]
    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text; X509CertPassword: Text; SymmetricAlgorithm: Enum SymmetricAlgorithm)
    begin
        EncryptedXmlImpl.Encrypt(XmlDocument, ElementToEncrypt, X509CertBase64Value, X509CertPassword, SymmetricAlgorithm);
    end;

    /// <summary>
    /// Decrypts all EncryptedData elements of the XML document using the specified asymmetric key.
    /// </summary>
    /// <param name="EncryptedDocument">The XML document to decrypt.</param>
    /// <param name="EncryptionKey">The asymmetric key to use to decrypt the symmetric keys in the document.</param>
    /// <param name="SignatureAlgorithm">The asymmetric algorithm used to decrypt the symmetric key.</param>
    /// <returns>Returns true if decryption was successful, otherwise false.</returns>     
    [NonDebuggable]
    procedure DecryptDocument(var EncryptedDocument: XmlDocument; EncryptionKey: Text; SignatureAlgorithm: Enum SignatureAlgorithm): Boolean
    begin
        exit(EncryptedXmlImpl.DecryptDocument(EncryptedDocument, EncryptionKey, SignatureAlgorithm));
    end;

    /// <summary>
    /// Decrypts an EncryptedKey XML element using an asymmetric algorithm.
    /// </summary>
    /// <param name="EncryptedKey">The EncryptedKey XML element with the key to be decrypted.</param>
    /// <param name="EncryptionKey">The asymmetric key used to decrypt the symmetric key.</param>
    /// <param name="UseOAEP">A value that specifies whether to use Optimal Asymmetric Encryption Padding (OAEP).</param>
    /// <param name="KeyBase64Value">The Base64 encoded decrypted key value.</param>
    /// <param name="SignatureAlgorithm">The asymmetric algorithm used to decrypt the symmetric key.</param>
    /// <returns>Returns true if decryption was successful, otherwise false.</returns>
    [NonDebuggable]
    procedure DecryptKey(EncryptedKey: XmlElement; EncryptionKey: Text; UseOAEP: Boolean; var KeyBase64Value: Text; SignatureAlgorithm: Enum SignatureAlgorithm): Boolean
    begin
        exit(EncryptedXmlImpl.DecryptKey(EncryptedKey, EncryptionKey, UseOAEP, KeyBase64Value, SignatureAlgorithm));
    end;
}
