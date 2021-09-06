// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 1466 "EncryptedXml Impl."
{
    Access = Internal;

    var
        ElementNotFoundErr: Label 'The "%1" element was not found.', Comment = '%1: The name of the xml element that could not be found.';
        XmlEncElementUrlTok: Label 'http://www.w3.org/2001/04/xmlenc#Element', Locked = true;
        XmlEncRSA15UrlTok: Label 'http://www.w3.org/2001/04/xmlenc#rsa-1_5', Locked = true;
        XmlEncUrlTok: Label 'http://www.w3.org/2001/04/xmlenc#', Locked = true;

    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        X509CertificateImpl: Codeunit "X509Certificate2 Impl.";
        DotNetEncryptedXml: DotNet EncryptedXml;
        DotNetX509Certificate2: DotNet X509Certificate2;
        DotNetXmlDocument: DotNet XmlDocument;
        DotNetXmlElementToEncrypt: DotNet XmlElement;
        DotNetEncryptedData: DotNet EncryptedData;
    begin
        //Initialize EncryptedXml
        DotNetEncryptedXml := DotNetEncryptedXml.EncryptedXml();

        //Convert XmlDocument to DotNet XmlDocument preserving whitespace
        XmlDotNetConvert.ToDotNet(XmlDocument, DotNetXmlDocument, true);

        //Get the DotNet XML element to encrypt
        DotNetXmlElementToEncrypt := DotNetXmlDocument.GetElementsByTagName(ElementToEncrypt).Item(0);
        if IsNull(DotNetXmlElementToEncrypt) then
            Error(ElementNotFoundErr, ElementToEncrypt);

        //Initialize a X509Certificate2.
        X509CertificateImpl.InitializeX509Certificate(X509CertBase64Value, '', DotNetX509Certificate2);

        //Encrypt the element
        DotNetEncryptedData := DotNetEncryptedXml.Encrypt(DotNetXmlElementToEncrypt, DotNetX509Certificate2);
        DotNetEncryptedXml.ReplaceElement(DotNetXmlElementToEncrypt, DotNetEncryptedData, false);

        //Convert the encrypted DotNet XmlDocument to a XmlDocument.
        XmlDotNetConvert.FromDotNet(DotNetXmlDocument, XmlDocument);
    end;

    procedure Encrypt(var XmlDocument: XmlDocument; ElementToEncrypt: Text; X509CertBase64Value: Text; SymmetricAlgorithm: Enum SymmetricAlgorithm)
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        X509CertificateImpl: Codeunit "X509Certificate2 Impl.";
        SymmetricAlgorithmInterface: Interface SymmetricAlgorithm;
        DotNetEncryptedXml: DotNet EncryptedXml;
        DotNetXmlDocument: DotNet XmlDocument;
        DotNetXmlElementToEncrypt: DotNet XmlElement;
        DotNetEncryptedDataBytes, DotNetEncryptedKeyBytes : DotNet Array;
        DotNetEncryptedData: DotNet EncryptedData;
        DotNetEncryptionMethod: DotNet EncryptionMethod;
        DotNetEncryptedKey: DotNet EncryptedKey;
        DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
        DotNetX509Certificate2: DotNet X509Certificate2;
        DotNetCipherData: DotNet CipherData;
        DotNetRSA: Dotnet RSA;
        DotNetKeyInfo: DotNet KeyInfo;
        DotNetKeyInfoX509Data: DotNet KeyInfoX509Data;
        DotNetKeyInfoEncryptedKey: DotNet KeyInfoEncryptedKey;
    begin
        //Initialize EncryptedXml
        DotNetEncryptedXml := DotNetEncryptedXml.EncryptedXml();

        //Convert the XML document to a DotNet XML document and preserve whitespace
        XmlDotNetConvert.ToDotNet(XmlDocument, DotNetXmlDocument, true);

        //Get the DotNet XML element to encrypt
        DotNetXmlElementToEncrypt := DotNetXmlDocument.GetElementsByTagName(ElementToEncrypt).Item(0);
        if IsNull(DotNetXmlElementToEncrypt) then
            Error(ElementNotFoundErr, ElementToEncrypt);

        //Initialize an instance of a DotNet symmetric algorithm
        SymmetricAlgorithmInterface := SymmetricAlgorithm;
        SymmetricAlgorithmInterface.GetInstance(DotNetSymmetricAlgorithm);

        //Encrypt the data using the asymetric algorithm
        DotNetEncryptedDataBytes :=
            DotNetEncryptedXml.EncryptData(DotNetXmlElementToEncrypt, DotNetSymmetricAlgorithm, false);

        //Create a EncryptedData XML element
        DotNetEncryptedData := DotNetEncryptedData.EncryptedData();
        DotNetEncryptedData.CipherData().CipherValue := DotNetEncryptedDataBytes;
        DotNetEncryptedData.Type := XmlEncElementUrlTok;
        DotNetEncryptedData.EncryptionMethod :=
            DotNetEncryptionMethod.EncryptionMethod(SymmetricAlgorithmInterface.XmlEncrypmentMethodUrl());

        //Encrypt the symmetric algorithm key using the public key from a X509Certificate2.
        X509CertificateImpl.InitializeX509Certificate(X509CertBase64Value, '', DotNetX509Certificate2);
        DotNetRSA := DotNetX509Certificate2.PublicKey."Key"();
        DotNetEncryptedKeyBytes := DotNetEncryptedXml.EncryptKey(DotNetSymmetricAlgorithm."Key", DotNetRSA, false);

        //Create an EncryptedKey XML element
        DotNetEncryptedKey := DotNetEncryptedKey.EncryptedKey();
        DotNetEncryptedKey.CipherData := DotNetCipherData.CipherData(DotNetEncryptedKeyBytes);
        DotNetEncryptedKey.EncryptionMethod := DotNetEncryptionMethod.EncryptionMethod(XmlEncRSA15UrlTok);
        DotNetKeyInfoX509Data := DotNetKeyInfoX509Data.KeyInfoX509Data(DotNetX509Certificate2.RawData);
        DotNetEncryptedKey.KeyInfo.AddClause(DotNetKeyInfoX509Data);

        //Create a KeyInfo XML element and add the EncryptedKey to it
        DotNetKeyInfo := DotNetKeyInfo.KeyInfo();
        DotNetKeyInfoEncryptedKey := DotNetKeyInfoEncryptedKey.KeyInfoEncryptedKey(DotNetEncryptedKey);
        DotNetKeyInfo.AddClause(DotNetKeyInfoEncryptedKey);
        DotNetEncryptedData.KeyInfo := DotNetKeyInfo;

        //Replace the original XML element with the encypted one
        DotNetEncryptedXml.ReplaceElement(DotNetXmlElementToEncrypt, DotNetEncryptedData, false);

        //Convert the encrypted DotNet XML Document to an XML document
        XmlDotNetConvert.FromDotNet(DotNetXmlDocument, XmlDocument);
    end;

    procedure DecryptDocument(var EncryptedDocument: XmlDocument; EncryptionKey: Record "Signature Key"): Boolean
    var
        XmlDotNetConvert: Codeunit "Xml DotNet Convert";
        SymmetricAlgorithmInterface: Interface SymmetricAlgorithm;
        NamespaceManager: DotNet XmlNamespaceManager;
        DotNetXmlDocument: DotNet XmlDocument;
        DotNetEncryptedNodes: DotNet XmlNodeList;
        DotNetEncryptedNode: DotNet XmlNode;
        DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm;
    begin
        //Convert the XmlDocument to a DotNet XmlDocument
        XmlDotNetConvert.ToDotNet(EncryptedDocument, DotNetXmlDocument, true);

        //Get the assymtric algorithm instance to be used for decrypting the symmetric session key
        if not EncryptionKey.TryGetInstance(DotNetAsymmetricAlgorithm) then
            exit(false);

        //Find all encrypted data elements and decrypt them
        NamespaceManager := NamespaceManager.XmlNamespaceManager(DotNetXmlDocument.NameTable);
        NamespaceManager.AddNamespace('xenc', XmlEncUrlTok);
        DotNetEncryptedNodes := DotNetXmlDocument.SelectNodes('//xenc:EncryptedData', NamespaceManager);
        foreach DotNetEncryptedNode in DotNetEncryptedNodes do
            DecryptDataElement(DotNetEncryptedNode, DotNetAsymmetricAlgorithm);

        //Convert the decrypted DotNet XML document to an XML document
        XmlDotNetConvert.FromDotNet(DotNetXmlDocument, EncryptedDocument, true);

        exit(true);
    end;

    local procedure DecryptDataElement(DotNetXmlElement: DotNet XmlElement; DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm): Boolean
    var
        SymmetricAlgorithmInterface: Interface SymmetricAlgorithm;
        DotNetEncryptedXml: DotNet EncryptedXml;
        DotNetEncryptedData: DotNet EncryptedData;
        DotNetKeyInfoClause: DotNet KeyInfoClause;
        DotNetKeyInfoEncryptedKey: DotNet KeyInfoEncryptedKey;
        DotNetEncryptedKey: DotNet EncryptedKey;
        DotNetCipherBytes, DotNetKeyBytes, DecryptedData : DotNet Array;
        DotNetSymmetricAlgorithm: DotNet "Cryptography.SymmetricAlgorithm";
        Ordinal: Integer;
    begin
        //Initialize a instance of the DotNet EncryptedData class.
        DotNetEncryptedData := DotNetEncryptedData.EncryptedData();
        DotNetEncryptedData.LoadXml(DotNetXmlElement);

        //Get the symmetric algorithm implementation from the KeyAlgorithm URL.
        foreach Ordinal in Enum::SymmetricAlgorithm.Ordinals() do begin
            SymmetricAlgorithmInterface := Enum::SymmetricAlgorithm.FromInteger(Ordinal);
            if SymmetricAlgorithmInterface.XmlEncrypmentMethodUrl() = DotNetEncryptedData.EncryptionMethod.KeyAlgorithm then begin
                SymmetricAlgorithmInterface.GetInstance(DotNetSymmetricAlgorithm);
                break;
            end;
        end;

        if IsNull(DotNetSymmetricAlgorithm) then
            Error('Unsupported symmetric algorithm.');

        //Find EncryptedKey KeyInfo
        foreach DotNetKeyInfoClause in DotNetEncryptedData.KeyInfo do begin
            DotNetKeyInfoEncryptedKey := DotNetKeyInfoClause;
            if not IsNull(DotNetKeyInfoEncryptedKey) then begin
                DotNetEncryptedKey := DotNetKeyInfoEncryptedKey.EncryptedKey();
                DotNetCipherBytes := DotNetEncryptedKey.CipherData.CipherValue;
                //Decrypt the embedded symmetric key using the specified asymmetric key
                DotNetKeyBytes := DotNetEncryptedXml.DecryptKey(DotNetCipherBytes, DotNetAsymmetricAlgorithm, false);
                DotNetSymmetricAlgorithm."Key" := DotNetKeyBytes;
                break;
            end;
        end;

        //Decrypt the actual data using the symmetric key
        DotNetEncryptedXml := DotNetEncryptedXml.EncryptedXml();
        DecryptedData := DotNetEncryptedXml.DecryptData(DotNetEncryptedData, DotNetSymmetricAlgorithm);

        //Replace the encrypted data with the decrypted XML
        DotNetEncryptedXml.ReplaceData(DotNetXmlElement, DecryptedData);

        exit(true);
    end;

    procedure DecryptKey(EncryptedKey: XmlElement; EncryptionKey: Record "Signature Key"; UseOAEP: Boolean; var KeyBase64Value: Text): Boolean
    var
        X509CertificateImpl: Codeunit "X509Certificate2 Impl.";
        XmlDocument: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        CipherValue: XmlNode;
        DotNetEncryptedXml: DotNet EncryptedXml;
        DotNetCipherBytes, DotNetKeyBytes : DotNet Array;
        DotNetConvert: Dotnet Convert;
        DotNetX509Certificate2: Dotnet X509Certificate2;
        DotNetAsymmetricAlgorithm: DotNet AsymmetricAlgorithm;
    begin
        //Get the asymtric algorithm instance to be used for decrypting the key
        if not EncryptionKey.TryGetInstance(DotNetAsymmetricAlgorithm) then
            exit(false);

        //Get the XML document of the XML element
        if not EncryptedKey.GetDocument(XmlDocument) then
            exit(false);

        //Create a XmlNamespaceManager and find the CipherValue (the Base64 encoded encrypted key)
        NamespaceManager.NameTable := XmlDocument.NameTable;
        NamespaceManager.AddNamespace('xenc', XmlEncUrlTok);
        if not EncryptedKey.SelectSingleNode('//xenc:CipherValue', NamespaceManager, CipherValue) then
            exit(false);

        //Get key bytes
        DotNetCipherBytes := DotNetConvert.FromBase64String(CipherValue.AsXmlElement().InnerText);

        //Decrypt the key
        DotNetKeyBytes := DotNetEncryptedXml.DecryptKey(DotNetCipherBytes, DotNetAsymmetricAlgorithm, UseOAEP);

        //Convert the key bytes to Base64
        KeyBase64Value := DotNetConvert.ToBase64String(DotNetKeyBytes);

        exit(true);
    end;
}
