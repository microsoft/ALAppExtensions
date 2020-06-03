// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132587 "X509Certificate2 Test"
{
    Subtype = Test;

    var
        X509CertificateCryptography: Codeunit "X509Certificate2";
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure VerifyCertificateIsInitialized()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
        CertificateVerified: Boolean;
    begin
        // [SCENARIO] Verify X509 Certificate from Base64 value
        // [GIVEN] Get Test Certificate Base64
        CertBase64Value := GetCertificateBase64();

        // [WHEN] Verify Certificate from Base64 value 
        CertificateVerified := X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [THEN] Verify that certificate is created
        LibraryAssert.IsTrue(CertificateVerified, 'Failed to verify certificate.');
    end;

    [Test]
    procedure VerifyCertificateFriendlyNameFromBase64Cert()
    var
        CertBase64Value: Text;
        FriendlyName: Text;
    begin
        // [SCENARIO] Create certificate from Base64, and verify FriendlyName from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate FriendlyName
        X509CertificateCryptography.GetCertificateFriendlyName(CertBase64Value, '', FriendlyName);

        // [THEN] Certificate Friendly Name is retrieved
        LibraryAssert.AreEqual(FriendlyName, GetFriendlyName(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateSubjectFromBase64Cert()
    var
        CertBase64Value: Text;
        Subject: Text;
    begin
        // [SCENARIO] Create certificate from Base64, and verify Subject from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate Subject
        X509CertificateCryptography.GetCertificateSubject(CertBase64Value, '', Subject);

        // [THEN] Certificate Subject is retrieved
        LibraryAssert.AreEqual(Subject, GetSubject(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateThumbprintFromBase64Cert()
    var
        CertBase64Value: Text;
        Thumbprint: Text;
    begin
        // [SCENARIO] Create certificate from Base64, and verify Thumbprint from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate Thumbprint
        X509CertificateCryptography.GetCertificateThumbprint(CertBase64Value, '', Thumbprint);

        // [THEN] Certificate Thumbprint is retrieved  
        LibraryAssert.AreEqual(Thumbprint, GetThumbprint(), 'Failed to create certificate.');
    end;

    procedure VerifyCertificateIssuerFromBase64Cert()
    var
        CertBase64Value: Text;
        Issuer: Text;
    begin
        // [SCENARIO] Create certificate from Base64, and verify Issuer from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate Issuer
        X509CertificateCryptography.GetCertificateIssuer(CertBase64Value, '', Issuer);

        // [THEN] Certificate Issuer is retrieved        
        LibraryAssert.AreEqual(Issuer, GetIssuer(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateExpirationFromBase64Cert()
    var
        CertBase64Value: Text;
        Expiration: DateTime;
    begin
        // [SCENARIO] Create certificate from Base64, and verify Expiration Date from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate Expiration
        X509CertificateCryptography.GetCertificateExpiration(CertBase64Value, '', Expiration);

        // [THEN] Certificate Expiration Date is retrieved        
        LibraryAssert.AreEqual(Expiration, GetExpirationDate(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateNotBeforeFromBase64Cert()
    var
        CertBase64Value: Text;
        NotBefore: DateTime;
    begin
        // [SCENARIO] Create certificate from Base64, and verify NotBefore Date from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate NotBefore
        X509CertificateCryptography.GetCertificateNotBefore(CertBase64Value, '', NotBefore);

        // [THEN] Certificate NotBefore Date is retrieved        
        LibraryAssert.AreEqual(NotBefore, GetNotBeforeDate(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateHasPrivateKeyFromBase64Cert()
    var
        CertBase64Value: Text;
        HasPrivateKey: Boolean;
    begin
        // [SCENARIO] Create certificate from Base64, and verify HasPrivateKey from certificate
        // [GIVEN] Get Test Certificate Base64 value
        CertBase64Value := GetCertificateBase64();

        // [WHEN]  Get Certificate HasPrivateKey property value
        HasPrivateKey := X509CertificateCryptography.HasPrivateKey(CertBase64Value, '');

        // [THEN] Certificate HasPrivateKey property is retrieved
        LibraryAssert.AreEqual(HasPrivateKey, GetHasPrivateKey(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyJsonPropertiesWithCertificate()
    var
        CertBase64Value: Text;
        CertPropertyJson: Text;
    begin
        // [SCENARIO] Create certificate from Base64, and verify certificate properties from json object
        // [GIVEN] Get Test Certificate Base64
        CertBase64Value := GetCertificateBase64();

        // [WHEN] Return Json object with certificate properties
        X509CertificateCryptography.GetCertificatePropertiesAsJson(CertBase64Value, '', CertPropertyJson);

        // [THEN] Certificate properties are retrieved
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'FriendlyName'), GetFriendlyName(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'Subject'), GetSubject(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'Thumbprint'), GetThumbprint(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'Issuer'), GetIssuer(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'NotAfter'), GetJsonExpirationDate(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenTextValue(CertPropertyJson, 'NotBefore'), GetJsonNotBeforeDate(), 'Failed to create certificate.');
        LibraryAssert.AreEqual(ReturnJsonTokenBoolValue(CertPropertyJson, 'HasPrivateKey'), GetHasPrivateKey(), 'Failed to create certificate.');
    end;

    [Test]
    procedure VerifyCertificateIsNotInitialized()
    var
        X509ContentType: Enum "X509 Content Type";
        CertBase64Value: Text;
    begin
        // [SCENARIO] Try to initialize X509 Certificate from not valid Base64 and catch an error
        // [GIVEN] Get Not Valid Test Certificate Base64
        CertBase64Value := GetNotValidCertificateBase64();

        // [WHEN] Verify Certificate from Base64             
        asserterror X509CertificateCryptography.VerifyCertificate(CertBase64Value, '', X509ContentType::Pkcs12);

        // [THEN] Verify that certificate is not created
        LibraryAssert.ExpectedError('Unable to initialize certificate!');
    end;

    local procedure ReturnJsonTokenTextValue(CertPropertyJson: Text; PropertyName: Text): Text
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(CertPropertyJson);
        JObject.Get(PropertyName, JToken);
        exit(JToken.AsValue().AsText());
    end;

    local procedure ReturnJsonTokenBoolValue(CertPropertyJson: Text; PropertyName: Text): Boolean
    var
        JObject: JsonObject;
        JToken: JsonToken;
    begin
        JObject.ReadFrom(CertPropertyJson);
        JObject.Get(PropertyName, JToken);
        exit(JToken.AsValue().AsBoolean());
    end;

    local procedure GetCertificateBase64(): Text
    begin
        exit(
            'MIICngIBAzCCAloGCSqGSIb3DQEHAaCCAksEggJHMIICQzCCAj8GCSqGSIb3' +
            'DQEHBqCCAjAwggIsAgEAMIICJQYJKoZIhvcNAQcBMBwGCiqGSIb3DQEMAQMw' +
            'DgQIW/ELQaGSk90CAgfQgIIB+JzlK5d/9oejtAXHFrQI/coOxX+QDr7WJ99R' +
            'x3NzO1WOBhlUGiAm+IdPBKsgxKr1IALPh5RFaJ57LxD9AyCysPq+OgVeiISz' +
            '7FNxVxaBwE3dz46ybcqagCFvVfka9fOTJa2PsFTEI+ILYJeYZM4rwebdE+nU' +
            'yQgYOUfnzOnNgvDdnEspMpOJoWLQzFowD1fsZfbEebsegWE//qTEOj1cVQa6' +
            'IFNP5DP+vqLPv8meYcohp0IRfSYOfSWmdK60HHfFPVi4xJBNGdEw+DIsQeEa' +
            'OJdDLjMY/dUcBVLEnmSBAehTLDiM6nnEgIdLzVw4GUpRiS4cKo5sHRj9f9lY' +
            'juW0HXapF7WxfDaNGLGg72MzkMUUPBpfCg0mv+agZbIE/XDTTOcn6Y0GxxYI' +
            'eoZvijinLiauURz6drZ+ygenCwwLNX+r/RWqY9CxI5J0TT4Xr3MNAagzF9ux' +
            'C14+j1Ym3tok6CY51NojFsI9iugYmNghkRTUCCx2Y1cEVmYdO+3FWYacUax1' +
            'G3bLOIDMqMV8pMXq6UxUPbWFq2Latl180cchF1gD/Ag2O6FNz0uawogboknp' +
            'lC+v1MrLJlt4t2WTXMpeF+hgV2oGI7fyGMJLlPZPRpfBbdRpiJiRytA/ekM9' +
            'FY+52y81f3tp1jzFnmpw7t281UOcUxH8akRnnDA7MB8wBwYFKw4DAhoEFDZv' +
            'N1bsFHxc5ROOhtks5GjPfx15BBT7Wsk8zUbkmHIStc4+1HIP57RRGgICB9A=');
    end;

    local procedure GetNotValidCertificateBase64(): Text
    begin
        exit('svZ2agE126JHsQ0bhzN5TKsYfbwfTwfjdWAGy6Vf1nYi/rO+ryMO');
    end;

    local procedure GetFriendlyName(): Text
    begin
        exit('');
    end;

    local procedure GetSubject(): Text
    begin
        exit('CN=Joe''s-Software-Emporium');
    end;

    local procedure GetThumbprint(): Text
    begin
        exit('55A0AE83959E7245E0A04FA1BA5F4024AE0D1235');
    end;

    local procedure GetIssuer(): Text
    begin
        exit('CN=Root Agency');
    end;

    local procedure GetExpirationDate(): DateTime
    begin
        exit(CreateDateTime(20291231D, 230000T));
    end;

    local procedure GetNotBeforeDate(): DateTime
    begin
        exit(CreateDateTime(20191231D, 230000T));
    end;

    local procedure GetHasPrivateKey(): Boolean
    begin
        exit(false);
    end;

    local procedure GetJsonExpirationDate(): Text
    begin
        exit('2029-12-31T22:00:00Z');
    end;

    local procedure GetJsonNotBeforeDate(): Text
    begin
        exit('2019-12-31T22:00:00Z');
    end;
}
