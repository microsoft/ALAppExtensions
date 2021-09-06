// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides functionality for encrypting and decrypting xml documents.
/// </summary>
codeunit 1465 EncryptedXml
{
    Access = Public;

    var
        EncryptedXmlImpl: Codeunit "EncryptedXml Impl.";

    /// <summary>
    /// Creates a symmetric session key to encrypt an XML document and then 
    /// uses the X.509 certificate to embed an encrypted version of the session key in the XML document.
    /// </summary>
    /// <param name="XmlDocument">The XmlDocument to encrypt.</param>
    /// <param name="ElementToEncrypt">The name of the element to encrypt.</param>
    /// <param name="X509CertBase64Value">The X509Certificate2 to use for the asymmetric encryption.</param>
    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text)
    begin
        EncryptedXmlImpl.Encrypt(XmlDocument, ElementToEncrypt, X509CertBase64Value);
    end;

    /// <summary>
    /// Like the Encrypt(var XmlDocument, ElementToEncrypt, X509CertBase64Value) procedure but with
    /// the possibility to use another symmetric algorithm than the Advanced Encryption Standard (AES).
    /// </summary>
    /// <param name="XmlDocument">The XmlDocument to encrypt.</param>
    /// <param name="ElementToEncrypt">The name of the element to encrypt.</param>
    /// <param name="SymmetricAlgorithm">The symmetric algorithm to be used when encrypting.</param>
    /// <param name="X509CertBase64Value">The X509Certificate2 to use for the asymmetric encryption.</param>
    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text; SymmetricAlgorithm: Enum SymmetricAlgorithm)
    begin
        EncryptedXmlImpl.Encrypt(XmlDocument, ElementToEncrypt, X509CertBase64Value, SymmetricAlgorithm);
    end;

    /// <summary>
    /// Decrypts all EncryptedData elements of the XML document using the specified asymetric key.
    /// </summary>
    /// <param name="EncryptedDocument">The XML dcoument to decrypt.</param>
    /// <param name="EncryptionKey">The asymmtric key to use to decrypt the symmetric keys in the document.</param>
    /// <returns>Returns true if decryption was successful, otherwise false.</returns>
    procedure DecryptDocument(var EncryptedDocument: XmlDocument; EncryptionKey: Record "Signature Key"): Boolean
    begin
        exit(EncryptedXmlImpl.DecryptDocument(EncryptedDocument, EncryptionKey));
    end;

    /// <summary>
    /// Decrypts an EncryptedKey XML element using an asymmetric algorithm.
    /// </summary>
    /// <param name="EncryptedKey">The EncryptedKey XML element with the key to be decrypted.</param>
    /// <param name="EncryptionKey">The asymmetric key used to decrypt the symmetric key.</param>
    /// <param name="UseOAEP">A value that specifies whether to use Optimal Asymmetric Encryption Padding (OAEP).</param>
    /// <param name="KeyBase64Value">The Base64 encoded decrypted key value.</param>
    /// <returns>Returns true if decryption was successful, otherwise false.</returns>
    procedure DecryptKey(EncryptedKey: XmlElement; EncryptionKey: Record "Signature Key"; UseOAEP: Boolean; var KeyBase64Value: Text): Boolean
    begin
        exit(EncryptedXmlImpl.DecryptKey(EncryptedKey, EncryptionKey, UseOAEP, KeyBase64Value));
    end;
}
