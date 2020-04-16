codeunit 132587 "X509Certificate2 Crypto. Test"
{
    Subtype = Test;

    var
        X509CertificateCryptography: Codeunit "X509Certificate2 Cryptography";
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure VerifyCertificateIsInitialized()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
        CertificateVerified: Boolean;
    begin
        // [SCENARIO 001] Verify X509 Certificate from Base64 value
        // [GIVEN] Get Test Certificate Base64
        CertBase64Value := GetCertificateBase64();

        // [WHEN] Verify Certificate from Base64 value 
        CertificateVerified := X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [THEN] Verify that certificate is created
        LibraryAssert.IsTrue(CertificateVerified, 'Failed to verify certificate.');
    end;

    [Test]
    procedure VerifyCertificateDetailsFromBase64Cert()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
        FriendlyName: Text;
        Thumbprint: Text;
        Issuer: Text;
        Expiration: DateTime;
    begin
        // [SCENARIO 002] Create certificate from Base64, and verify properties from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [GIVEN] Verify Certificate
        X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [WHEN]  Get Certificate Details
        X509CertificateCryptography.GetCertificateDetails(CertBase64Value, FriendlyName, Thumbprint, Issuer, Expiration);

        // [THEN] Verify Results
        LibraryAssert.AreEqual(FriendlyName, GetFriendlyName(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(Thumbprint, GetThumbprint(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(Issuer, GetIssuer(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(Expiration, GetExpirationDate(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyJsonProperiesWithCertificate()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
        CertPropertyJson: Text;
    begin
        // [SCENARIO 003] Create certificate from Base64, and verify certificate properties from json object
        // [GIVEN] Get Test Certificate Base64
        CertBase64Value := GetCertificateBase64();

        // [GIVEN] Verify Certificate
        X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [WHEN] Return Json object with certificate properties
        CertPropertyJson := X509CertificateCryptography.GetCertificatePropertiesAsJson(CertBase64Value);

        // [THEN] Verify Results
        LibraryAssert.AreEqual(ReturnJsonTokenValue(CertPropertyJson, 'FriendlyName'), GetFriendlyName(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenValue(CertPropertyJson, 'Thumbprint'), GetThumbprint(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenValue(CertPropertyJson, 'Issuer'), GetIssuer(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenValue(CertPropertyJson, 'NotAfter'), GetJsonExpirationDate(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateIsNotInitialized()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
    begin
        // [SCENARIO 004] Try to initialize X509 Certificate from not valid Base64 and catch an error
        // [GIVEN] Get Not Valid Test Certificate Base64
        CertBase64Value := GetNotValidCertificateBase64();

        // [WHEN] Verify Certificate from Base64             
        asserterror X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [THEN] Verify that certificate is not created
        LibraryAssert.ExpectedError('Unable to initialize certificate!');
    end;

    local procedure ReturnJsonTokenValue(CertPropertyJson: Text; PropertyName: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(CertPropertyJson);
        JObject.Get(PropertyName, JToken);
        exit(JToken.AsValue().AsText());
    end;

    local procedure GetCertificateBase64(): Text
    begin
        exit(
            'MIICYzCCAcygAwIBAgIBADANBgkqhkiG9w0BAQUFADAuMQswCQYDVQQGEwJVUzEM' +
            'MAoGA1UEChMDSUJNMREwDwYDVQQLEwhMb2NhbCBDQTAeFw05OTEyMjIwNTAwMDBa' +
            'Fw0wMDEyMjMwNDU5NTlaMC4xCzAJBgNVBAYTAlVTMQwwCgYDVQQKEwNJQk0xETAP' +
            'BgNVBAsTCExvY2FsIENBMIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQD2bZEo' +
            '7xGaX2/0GHkrNFZvlxBou9v1Jmt/PDiTMPve8r9FeJAQ0QdvFST/0JPQYD20rH0b' +
            'imdDLgNdNynmyRoS2S/IInfpmf69iyc2G0TPyRvmHIiOZbdCd+YBHQi1adkj17ND' +
            'cWj6S14tVurFX73zx0sNoMS79q3tuXKrDsxeuwIDAQABo4GQMIGNMEsGCVUdDwGG' +
            '+EIBDQQ+EzxHZW5lcmF0ZWQgYnkgdGhlIFNlY3VyZVdheSBTZWN1cml0eSBTZXJ2' +
            'ZXIgZm9yIE9TLzM5MCAoUkFDRikwDgYDVR0PAQH/BAQDAgAGMA8GA1UdEwEB/wQF' +
            'MAMBAf8wHQYDVR0OBBYEFJ3+ocRyCTJw067dLSwr/nalx6YMMA0GCSqGSIb3DQEB' +
            'BQUAA4GBAMaQzt+zaj1GU77yzlr8iiMBXgdQrwsZZWJo5exnAucJAEYQZmOfyLiM' +
            'D6oYq+ZnfvM0n8G/Y79q8nhwvuxpYOnRSAXFp6xSkrIOeZtJMY1h00LKp/JX3Ng1' +
            'svZ2agE126JHsQ0bhzN5TKsYfbwfTwfjdWAGy6Vf1nYi/rO+ryMO');
    end;

    local procedure GetNotValidCertificateBase64(): Text
    begin
        exit('svZ2agE126JHsQ0bhzN5TKsYfbwfTwfjdWAGy6Vf1nYi/rO+ryMO');
    end;

    local procedure GetFriendlyName(): Text
    begin
        exit('');
    end;

    local procedure GetThumbprint(): Text
    begin
        exit('4B1C775072024EECBFE13957251661F1D82A1589');
    end;

    local procedure GetIssuer(): Text
    begin
        exit('OU=Local CA, O=IBM, C=US');
    end;

    local procedure GetExpirationDate(): DateTime
    begin
        exit(CreateDateTime(20001223D, 055959T));
    end;

    local procedure GetJsonExpirationDate(): Text
    begin
        exit('2000-12-23T04:59:59Z');
    end;
}