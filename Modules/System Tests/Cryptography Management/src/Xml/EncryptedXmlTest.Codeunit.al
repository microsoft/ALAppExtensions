// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132614 "EncryptedXml Test"
{
    Subtype = Test;

    var
        EncryptedXml: Codeunit EncryptedXml;
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure EncryptXmlDocument()
    var
        XmlDocumentToEncrypt: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        EncryptedKey: XmlNode;
        EncryptionSignatureKey: Text;
        SignatureAlgorithm: Enum SignatureAlgorithm;
    begin
        // [GIVEN] The XmlDocument to encrypt
        GetXml(XmlDocumentToEncrypt);

        // [GIVEN] The private key used to decrypt to verify the encryption
        EncryptionSignatureKey := GetPrivateKey();

        // [WHEN] Encrypt the document
        EncryptedXml.Encrypt(XmlDocumentToEncrypt, 'Login', GetCertificateData(), '');

        // [THEN] Check that there is a EncryptedKey element present in the encrypted XmlDocument
        NamespaceManager.NameTable := XmlDocumentToEncrypt.NameTable;
        NamespaceManager.AddNamespace('xenc', 'http://www.w3.org/2001/04/xmlenc#');
        LibraryAssert.IsTrue(
            XmlDocumentToEncrypt.SelectSingleNode(
                '//xenc:EncryptedKey', NamespaceManager, EncryptedKey),
            'Could not find EncryptedKey element.');

        // [THEN] Check that the encrypted XmlDocument can be decrypted
        LibraryAssert.IsTrue(
            EncryptedXml.DecryptDocument(
                XmlDocumentToEncrypt, EncryptionSignatureKey, SignatureAlgorithm::RSA),
            'Could not decrypt encrypted xml.');
    end;

    [Test]
    procedure EncryptXmlDocumentTripleDES()
    var
        XmlDocumentToEncrypt: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        EncryptedKey: XmlNode;
        SymmetricAlgorithm: Enum SymmetricAlgorithm;
        SignatureAlgorithm: Enum SignatureAlgorithm;
        EncryptionSignatureKey: Text;
    begin
        // [GIVEN] The XmlDocument to encrypt
        GetXml(XmlDocumentToEncrypt);

        // [GIVEN] The private key used to decrypt to verify the encryption
        EncryptionSignatureKey := GetPrivateKey();

        // [WHEN] Encrypt the document
        EncryptedXml.Encrypt(XmlDocumentToEncrypt, 'Login', GetCertificateData(), '', SymmetricAlgorithm::TripleDES);

        // [THEN] Check that there is a EncryptedKey element present in the encrypted XmlDocument
        NamespaceManager.NameTable := XmlDocumentToEncrypt.NameTable;
        NamespaceManager.AddNamespace('xenc', 'http://www.w3.org/2001/04/xmlenc#');
        LibraryAssert.IsTrue(
            XmlDocumentToEncrypt.SelectSingleNode(
                '//xenc:EncryptedKey', NamespaceManager, EncryptedKey),
            'Could not find EncryptedKey element.');

        // [THEN] Check that the encrypted XmlDocument can be decrypted
        LibraryAssert.IsTrue(
            EncryptedXml.DecryptDocument(
                XmlDocumentToEncrypt, EncryptionSignatureKey, SignatureAlgorithm::RSA),
            'Could not decrypt encrypted xml.');
    end;

    [Test]
    procedure DecryptXmlDocument()
    var
        XmlDocumentToDecrypt: XmlDocument;
        XmlWriteOptions: XmlWriteOptions;
        DecryptedXmlString, ExpectedXmlString : Text;
        Result: Boolean;
        EncryptionSignatureKey: Text;
        SignatureAlgorithm: Enum SignatureAlgorithm;
    begin
        // [GIVEN] The encrypted XmlDocument to decrypt
        GetEncryptedXml(XmlDocumentToDecrypt);

        // [GIVEN] The private key used to decrypt the XmlDocument
        EncryptionSignatureKey := GetPrivateKey();

        // [GIVEN] The expected result
        ExpectedXmlString := GetXmlString();

        // [WHEN] Encrypt the document
        Result := EncryptedXml.DecryptDocument(XmlDocumentToDecrypt, EncryptionSignatureKey, SignatureAlgorithm::RSA);

        // [THEN] Check that the decryption was successful
        LibraryAssert.IsTrue(Result, 'The xml document could not be decrypted.');

        // [THEN] Check the decrypted XmlDocument content
        XmlWriteOptions.PreserveWhitespace := true;
        XmlDocumentToDecrypt.WriteTo(XmlWriteOptions, DecryptedXmlString);

        LibraryAssert.AreEqual(
            ExpectedXmlString, DecryptedXmlString, 'The decrypted document is incorrect.');
    end;

    [Test]
    procedure DecryptKey()
    var
        XmlDocumentToDecrypt: XmlDocument;
        NamespaceManager: XmlNamespaceManager;
        EncryptedKey: XmlNode;
        KeyBase64Value: Text;
        Result: Boolean;
        EncryptionSignatureKey: Text;
        SignatureAlgorithm: Enum SignatureAlgorithm;
    begin
        // [GIVEN] The XmlDocument with the encrypted key to decrypt
        GetEncryptedXml(XmlDocumentToDecrypt);

        // [GIVEN] The private key used to decrypt the XmlDocument
        EncryptionSignatureKey := GetPrivateKey();

        // [GIVEN] Get the encrypted key element
        NamespaceManager.NameTable := XmlDocumentToDecrypt.NameTable;
        NamespaceManager.AddNamespace('xenc', 'http://www.w3.org/2001/04/xmlenc#');
        XmlDocumentToDecrypt.SelectSingleNode('//xenc:EncryptedKey', NamespaceManager, EncryptedKey);

        // [WHEN] Decrypt the key
        Result := EncryptedXml.DecryptKey(
            EncryptedKey.AsXmlElement(), EncryptionSignatureKey, false, KeyBase64Value, SignatureAlgorithm::RSA);

        // [THEN] Check that the decryption was successful
        LibraryAssert.IsTrue(Result, 'Could not decrypt key.');

        // [THEN] Check that the key has the correct value
        LibraryAssert.AreEqual(
            '3kQNj9cC02pUxTE5Cy+2a1wP/5bKYLup', KeyBase64Value, 'Incorrect decrypted key value.');
    end;

    local procedure GetXml(var XmlDoc: XmlDocument)
    var
        XmlReadOptions: XmlReadOptions;
    begin
        XmlReadOptions.PreserveWhitespace := true;
        XmlDocument.ReadFrom(GetXmlString(), XmlReadOptions, XmlDoc);
    end;

    local procedure GetXmlString(): Text
    var
        XmlString: TextBuilder;
    begin
        XmlString.AppendLine('<?xml version="1.0" encoding="utf-8"?>');
        XmlString.AppendLine('<Data xmlns="http://www.example.com/data">');
        XmlString.AppendLine('  <Login>');
        XmlString.AppendLine('    <Username>Name</Username>');
        XmlString.AppendLine('    <Password>p@ssw0rd</Password>');
        XmlString.AppendLine('  </Login>');
        XmlString.Append('</Data>');

        exit(XmlString.ToText());
    end;

    local procedure GetEncryptedXml(var EncryptedXmlDoc: XmlDocument)
    var
        XmlReadOptions: XmlReadOptions;
    begin
        XmlReadOptions.PreserveWhitespace := true;
        XmlDocument.ReadFrom(GetEncryptedXmlString(), XmlReadOptions, EncryptedXmlDoc);
    end;

    local procedure GetEncryptedXmlString(): Text
    var
        XmlString: TextBuilder;
    begin
        XmlString.AppendLine('<?xml version="1.0" encoding="utf-8"?>');
        XmlString.AppendLine('<Data xmlns="http://www.example.com/data">');
        XmlString.Append('  <EncryptedData Type="http://www.w3.org/2001/04/xmlenc#Element" xmlns="http://www.w3.org/2001/04/xmlenc#">');
        XmlString.Append('<EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#tripledes-cbc" />');
        XmlString.Append('<KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">');
        XmlString.Append('<EncryptedKey xmlns="http://www.w3.org/2001/04/xmlenc#">');
        XmlString.Append('<EncryptionMethod Algorithm="http://www.w3.org/2001/04/xmlenc#rsa-1_5" />');
        XmlString.Append('<KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">');
        XmlString.Append('<X509Data>');
        XmlString.Append('<X509Certificate>');
        XmlString.Append(GetCertificateData());
        XmlString.Append('</X509Certificate>');
        XmlString.Append('</X509Data>');
        XmlString.Append('</KeyInfo>');
        XmlString.Append('<CipherData>');
        XmlString.Append('<CipherValue>');
        XmlString.Append('KzQkIwPPcgeAaszBMSihVg7VyI6ZG0Vf0Os8yNVRp1H/+Lo9JsP+eDbW2AG0RlmI/ZBR2FSG/YyI6YKQ9kDe3zHYh23WTpQp7qT7');
        XmlString.Append('YNUTHgfE+Eo4lgJaf3iZ12yxZvH1e4AFUoWyc+D0fDOgKPVhjacssBizkNYEwQjrJZNCJUVBgGfIaus9ODF8RM+mSWvwN6UnigMJ');
        XmlString.Append('k0krLcdt9BZNa8EWokzXVGz8x8eUf7Qm1/2HMKh2Fd9a2Z6f0GfGchMIQAZ33TubXycG73etwyJh4goIxgAmSrHW+v3Y5bcd4Dbh');
        XmlString.Append('nic4Ko+cW9Cvro3qLcupXgzB2ozMoYLBzZMvF5j6ZA==');
        XmlString.Append('</CipherValue>');
        XmlString.Append('</CipherData>');
        XmlString.Append('</EncryptedKey>');
        XmlString.Append('</KeyInfo>');
        XmlString.Append('<CipherData>');
        XmlString.Append('<CipherValue>');
        XmlString.Append('wsiJmFP9Mkko+/za2d2eb8L/dASg3AKWP8lKgAKCU/22XVpmphYpUkxFu/XOH5/OlAoKu4fe6jztP+ve8p6jvLlOMoMOR2Ul/6ah');
        XmlString.Append('bNAJ171LrSsO0YUaD+VQ1Aw40DKho1l7RYK0kNLYZRprph9Z8+Rjj28HLT/24Q3fnMDk+7xdlhI6YjeKCA==');
        XmlString.Append('</CipherValue>');
        XmlString.Append('</CipherData>');
        XmlString.AppendLine('</EncryptedData>');
        XmlString.Append('</Data>');

        exit(XmlString.ToText());
    end;

    local procedure GetCertificateData(): Text
    begin
        exit(
            'MIIC2jCCAkMCAg38MA0GCSqGSIb3DQEBBQUAMIGbMQswCQYDVQQGEwJKUDEOMAwGA1UECBMFVG9r' +
            'eW8xEDAOBgNVBAcTB0NodW8ta3UxETAPBgNVBAoTCEZyYW5rNEREMRgwFgYDVQQLEw9XZWJDZXJ0' +
            'IFN1cHBvcnQxGDAWBgNVBAMTD0ZyYW5rNEREIFdlYiBDQTEjMCEGCSqGSIb3DQEJARYUc3VwcG9y' +
            'dEBmcmFuazRkZC5jb20wHhcNMTIwODIyMDUyNzQxWhcNMTcwODIxMDUyNzQxWjBKMQswCQYDVQQG' +
            'EwJKUDEOMAwGA1UECAwFVG9reW8xETAPBgNVBAoMCEZyYW5rNEREMRgwFgYDVQQDDA93d3cuZXhh' +
            'bXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC0z9FeMynsC8+udvX+LciZ' +
            'xnh5uRj4C9S6tNeeAlIGCfQYk0zUcNFCoCkTknNQd/YEiawDLNbxBqutbMDZ1aarys1a0lYmUeVL' +
            'CIqvzBkPJTSQsCopQQ9V8WuT252zzNzs68dVGNdCJd5JNRQykpwexmnjPPv0mvj7i8XgG379TyW6' +
            'P+WWV5okeUkXJ9eJS2ouDYdR2SM9BoVW+FgxDu6BmXhozW5EfsnajFp7HL8kQClI0QOc79yuKl34' +
            '92rH6bzFsFn2lfwWy9ic7cP8EpCTeFp1tFaD+vxBhPZkeTQ1HKx6hQ5zeHIB5ySJJZ7af2W8r4eT' +
            'GYzbdRW24DDHCPhZAgMBAAEwDQYJKoZIhvcNAQEFBQADgYEAQMv+BFvGdMVzkQaQ3/+2noVz/uAK' +
            'bzpEL8xTcxYyP3lkOeh4FoxiSWqy5pGFALdPONoDuYFpLhjJSZaEwuvjI/TrrGhLV1pRG9frwDFs' +
            'hqD2Vaj4ENBCBh6UpeBop5+285zQ4SI7q4U9oSebUDJiuOx6+tZ9KynmrbJpTSi0+BM=');
    end;

    local procedure GetPrivateKey(): Text
    begin
        exit(
            '<RSAKeyValue>' +
            '<Modulus>tM/RXjMp7AvPrnb1/i3ImcZ4ebkY+AvUurTXngJSBgn0GJNM1HDRQqA' +
            'pE5JzUHf2BImsAyzW8QarrWzA2dWmq8rNWtJWJlHlSwiKr8wZDyU0kLAqKUEPVfF' +
            'rk9uds8zc7OvHVRjXQiXeSTUUMpKcHsZp4zz79Jr4+4vF4Bt+/U8luj/llleaJHl' +
            'JFyfXiUtqLg2HUdkjPQaFVvhYMQ7ugZl4aM1uRH7J2oxaexy/JEApSNEDnO/crip' +
            'd+Pdqx+m8xbBZ9pX8FsvYnO3D/BKQk3hadbRWg/r8QYT2ZHk0NRyseoUOc3hyAec' +
            'kiSWe2n9lvK+HkxmM23UVtuAwxwj4WQ==</Modulus>' +
            '<Exponent>AQAB</Exponent>' +
            '<P>2jxC0a4lGmp1q2aYE1Zyiq0UqjxA92pwFYJg3800MLkf96A+dOhdwDAc5aAKN' +
            '8vQV5g33vKi5+pIHWUCskhTS8/PPGrfeqIvtphCj6b7LKosBOhdzrRDOsr+Az/Si' +
            'R2h5l2lr/v7I8I86RTY7MBk4QcRb601kSagWLDNVzSSdhE=</P>' +
            '<Q>1Bm00sByqkQmFoUNRjwmShPfJeVLTCr1G4clljl6MqHmGyRDHxtcp1+CXlyJJ' +
            'emLQY2AqrM7/T4x2ta6ME2WgDydFe9M8oU3BbefNYovS6YnoyBqxCx7yZ1vO0Jo4' +
            '0rZI8BiKoCi6e0Hugg4xyPRz9TTNLmr/yEC1qQesMhM9ck=</Q>' +
            '<DP>rsT7rfgMdq8zNOSgfTwJ1sztc7d1P67ZvCABfLlVRn+6/hAydGVyTus4+RvF' +
            'kxGB8+RPOhiOJbQVtJSkKCqLqnbtu7DK7+ba1xvwkiJjnE1bm0KLfXIXNQpDik6e' +
            'SHiWo2nzuo/Ne8GeDftIDbG2GBAVAp5v+6I3X0+X4nKTqEE=</DP>' +
            '<DQ>wT4Cj5mjXxnkEdR7eahHwmpEf0RfzC+/TateRXZsrUDwY34wYWEOk7fjEZIB' +
            'qrcTl1ATEHNojpxh096bmHK4UnHnNRrn4nYY4W6g8ajK2oOxzWA1pjJZPiHgO/+P' +
            'jLafC4G2br7wr2y0A3yGLnmmKVLgc0NPP42WBnVVOP/ljnE=</DQ>' +
            '<InverseQ>AZQ3SQgHoQzUr+JnRM2OW3w/lQRXdkLIBNYWIZlGGETZYCHyC/WPHg' +
            'nbqlxSzWfyx3ZrWHpm4FKqzIiU1KnG0qybdupAUMdGs9ywFfidqevD0POSkfWT8j' +
            'dYxJ0aqQMBHcO0vvJdMlcmjZJuunkSPNKfsNwMTW0vYSf+1JVd5Rg=' +
            '</InverseQ>' +
            '<D>TvofR3gtrY8TLe+ET3wMDS8l3HU/NMlmKA9pxvjYfw7F8h4VBw4oOWPfzU7A0' +
            '7syWJUR72kckbcKMfw42G18GbnBrRQG0UIgV3/ppBQQNg9YQILSR6bFXhLPnIvm/' +
            'GxVa58pOEBbdec4it2Gbvie/MpJ4hn3K8atTqKk0djwxQ+bQNBWtVgTkyIqMpUTF' +
            'Di5ECiVXaGWZ5AOVK2TzlLRNQ5Y7US8lmGxVWzt0GONjXSEiO/eBk8A7wI3zknMx' +
            '5o1uZa/hFCPQH33uKeuqU5rmphi3zS0BY7iGY9EoKu/o+BOHPwLQJ3wCDA3O9APZ' +
            '3gmmbHFPMFPr/mVGeAeGP/BAQ==</D>' +
            '</RSAKeyValue>');
    end;
}