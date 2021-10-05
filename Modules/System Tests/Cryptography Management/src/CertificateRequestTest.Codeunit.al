// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132611 "CertificateRequestTest"
{
    Subtype = Test;
    TestPermissions = Disabled;

    var
        CertificateRequest: Codeunit CertificateRequest;
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        BeginCertReqTok: Label '-----BEGIN CERTIFICATE REQUEST-----';
        EndCertReqTok: Label '-----END CERTIFICATE REQUEST-----';
        DepricatedHashAlgorithmsMsg: Label 'In compliance with the Microsoft Secure Hash Algorithm deprecation policy SHA1 and MD5 hash alghoritms have been deprecated.';


    [Test]
    procedure InitializeKeys()
    var
        KeyXml: XmlDocument;
        Root: XmlElement;
        Node: XmlNode;
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        Assert.IsTrue(XmlDocument.ReadFrom(KeyXmlText, KeyXml), 'RSA key is not valid xml data.');
        Assert.IsTrue(KeyXml.GetRoot(Root), 'Could not get Root element of key.');

        Assert.IsTrue(Root.SelectSingleNode('Modulus', Node), 'Could not find <Modulus> in key.');
        Assert.IsTrue(Root.SelectSingleNode('DQ', Node), 'Could not find <DQ> in key.');
    end;

    [Test]
    procedure AddX509BasicConstraintToCertificateRequest()
    var
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertificateRequest.AddX509BasicConstraintToCertificateRequest(false, false, 0, true);
        Assert.AreEqual(1, CertificateRequest.GetX509CertificateRequestExtensionCount(), 'Adding a X509BasicConstraint to the Certificate Signing Request failed.');
    end;

    [Test]
    procedure AddX509KeyUsageToCertificateRequest()
    var
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertificateRequest.AddX509KeyUsageToCertificateRequest(16 + 128, false);
        Assert.AreEqual(1, CertificateRequest.GetX509CertificateRequestExtensionCount(), 'Adding a X509BasicConstraint to the Certificate Signing Request failed.');
    end;

    [Test]
    procedure AddX509KeyUsageToCertificateRequestDeprecatedHashMD5()
    var
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        asserterror CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::MD5, RSASignaturePadding::Pkcs1);
        Assert.ExpectedError(DepricatedHashAlgorithmsMsg);
    end;

    [Test]
    procedure AddX509KeyUsageToCertificateRequestDeprecatedHashSHA1()
    var
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        asserterror CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA1, RSASignaturePadding::Pkcs1);
        Assert.ExpectedError(DepricatedHashAlgorithmsMsg);
    end;

    [Test]
    procedure AddX509EnhancedKeyUsageToCertificateRequest()
    var
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
        Oids: List of [Text];
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        Oids.Add('1.3.6.1.5.5.7.3.2');
        CertificateRequest.AddX509EnhancedKeyUsageToCertificateRequest(Oids, false);

        Assert.AreEqual(1, CertificateRequest.GetX509CertificateRequestExtensionCount(), 'Adding a X509BasicConstraint to the Certificate Signing Request failed.');
    end;

    [Test]
    procedure CreateCertificateSigningRequest()
    var
        SigningRequestPem: Text;
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        KeyXmlText: Text;
    begin
        CertificateRequest.InitializeRSA(2048, true, KeyXmlText);

        CertificateRequest.InitializeCertificateRequestUsingRSA(
            GetSubjectName(), HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertificateRequest.CreateSigningRequest(SigningRequestPem);

        Assert.IsTrue(SigningRequestPem.StartsWith(BeginCertReqTok), 'Invalid PEM certificate signing request.');
        Assert.IsTrue(SigningRequestPem.EndsWith(EndCertReqTok), 'Invalid PEM certificate signing request.');

        SigningRequestPem := SigningRequestPem.Substring(StrLen(BeginCertReqTok) + 1).Trim();
        Assert.AreEqual('MII', SigningRequestPem.Substring(1, 3), 'Invalid PEM certificate signing request.');
    end;

    [Test]
    procedure CreateSelfSignedCertificate()
    var
        CertSigningRequest: Codeunit CertificateRequest;
        X509Certificate2: Codeunit X509Certificate2;
        KeyXmlText, CertBase64Value, Subject : Text;
        HashAlgorithm: Enum "Hash Algorithm";
        RSASignaturePadding: Enum "RSA Signature Padding";
        X509ContentType: Enum "X509 Content Type";
        SubjectName: Text;
    begin
        CertSigningRequest.InitializeRSA(2048, true, KeyXmlText);

        SubjectName := GetSubjectName();

        CertSigningRequest.InitializeCertificateRequestUsingRSA(
            SubjectName, HashAlgorithm::SHA256, RSASignaturePadding::Pkcs1);

        CertSigningRequest.AddX509BasicConstraintToCertificateRequest(false, false, 0, true);

        CertSigningRequest.CreateSelfSigned(
            CreateDateTime(Today, 000000T), CreateDateTime(Today + 365, 000000T), X509ContentType::Cert, CertBase64Value);

        X509Certificate2.GetCertificateSubject(CertBase64Value, '', Subject);
        Assert.AreEqual(SubjectName, Subject, 'Self signed certificate generation failed.');
    end;

    local procedure GetSubjectName(): Text
    begin
        exit(StrSubstNo('CN=www.%1.com, C=US', Any.AlphabeticText(8)));
    end;
}