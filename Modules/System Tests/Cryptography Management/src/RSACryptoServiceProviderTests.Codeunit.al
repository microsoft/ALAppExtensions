// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132613 RSACryptoServiceProviderTests
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        RSACryptoServiceProvider: Codeunit RSACryptoServiceProvider;
        Base64Convert: Codeunit "Base64 Convert";
        Any: Codeunit Any;
        IsInitialized: Boolean;
        PrivateKeyXmlString: Text;
        PublicKeyXmlString: Text;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;
        PrivateKeyXmlString := '<RSAKeyValue><Modulus>cJ0pi/fAqrSG/Se5+dgsrK263pII/B8bxfrX0h2mZ7EYQhTExXkgzgLpKwEEafuK40UjR136SKCr9Kn4hzOzMsjna1rIErBRs3qNHKSqKrsvHZQ9cDZ7DIUzHvqXtCMJ0Z4rQAfVKqivlfjwtIGVOItJ+DLOQ8KkY62b926c8LLKFPnRSVqBt+/yFlBw3SeAgMc0mitJEHoanKtLWstKW9CMny9g5GUvrvZcL0R4x6JZlYFMS0BpftRMnaknr7Uzq0goZv88xfoR+MmnwVT9gSSFQEmk9TGiWcuEunqMRfxoxmAm3TkwE4LH5C4uM1dePegX34nj2fja9hiQkQxujw==</Modulus><Exponent>AQAB</Exponent><P>sInRlm0HdVy3+RZ448K56ZISCvCP6ULdfI2MtEOz2VvqCvgEajmArBdbf3iEE5IWEhMlKQDbBVKYuS/qmajtNsm6qXT1qbFWHtdPpcfCpLyQGOf4u+Eolg+aHXYHc+Mz7Rv0H9+v5Iqz5V36trMu7D8rQyASLxtv/pXgVCW4iRM=</P><Q>o01zfoE1k0svgaDcsPq35lOi9lWnKUe/706x7cx3DKWkBdxiHNH2EV8lMXgKhkkk6bchqj7usZB/NuPYhDtMdlbwwDGdNafgOj+/xCihPAQhZ7Oyy3MloxNzk+XyYS88V5NtXbJi+zZfHrVmz0Glfs2h4uRgFDel7qPYQnFIEBU=</Q><DP>f7LRhoxLbtuowGc+/xGmRYxBvOQSVVrmt+f0NZkbiUjxXQnWt7fsmY8zwls8vqNXj6+Fm8lgpNMAYkSE4K3PGWiGu3k9EoiSkTCSDosXAu7bFQkHZXATWajjhBgSgAODVip4Rm4Z36ltQ6bdajbm5EE1XBLg1G52bqOfZ375oz0=</DP><DQ>VL/xXIn6IAM5GHE/l6nGnwZw4J77LfVKqwuQU/V1I18jjNcfJA3jQoi6aL3/2ElFmvWrxwr6HbT8EKSWzalouVHNiDE3gY0qVZCYGVlstBUAsS0VcXjE46lIpk0ESWOWUWz1qVbW/8DsBKfoP0+2b+SQS4xyQIvQ1dS6e2EHITE=</DQ><InverseQ>gYo6fmHItlkYpn0YdRPObqTfeDafozZs1id7KiNEdHjLu2Cw6hgdJWV0+QyRtQsd3+i36xW6wqP2h7ATlBBtpHKSifNj6TdRYA/UFlfWlZmrS7hZ7MCqZ2iT55Pf2Vky7EA0tV6kZo8CoG7XEkfSkZw4tChF7SckASIatQ/ZcdM=</InverseQ><D>OlF5WY3FDeINYf53tiY4BHi3pFl2I7KsfFuJ9rr6GQrCKD5/JFC1J1qki2uscIIei9GbEnNdkMz8H+kB1mp0q6EVDyhlIiCDPvIBL8sqgJSNMsE5C+p60KIONkXJ2DSo+g/yD+e+gaf3vi+7346Xyz9+3/TXkomy/hfDBGEZDyCnvg7h2EGsFxx7TQmWgylhOv0y7ZAzyCDfsrDS/t2O+pshZoObJVdeeVSeiQxAVKa3EO7IDqK6niHuvk8N1X2z0AaaViYIP7IgBW2gY5rpq9QknGdxqob6TqoBUxhPR3eUnP/mhg9iWz6b5n6FxlGkRVLR2wciT5gnS31chBwquQ==</D></RSAKeyValue>';
        PublicKeyXmlString := '<RSAKeyValue><Modulus>cJ0pi/fAqrSG/Se5+dgsrK263pII/B8bxfrX0h2mZ7EYQhTExXkgzgLpKwEEafuK40UjR136SKCr9Kn4hzOzMsjna1rIErBRs3qNHKSqKrsvHZQ9cDZ7DIUzHvqXtCMJ0Z4rQAfVKqivlfjwtIGVOItJ+DLOQ8KkY62b926c8LLKFPnRSVqBt+/yFlBw3SeAgMc0mitJEHoanKtLWstKW9CMny9g5GUvrvZcL0R4x6JZlYFMS0BpftRMnaknr7Uzq0goZv88xfoR+MmnwVT9gSSFQEmk9TGiWcuEunqMRfxoxmAm3TkwE4LH5C4uM1dePegX34nj2fja9hiQkQxujw==</Modulus><Exponent>AQAB</Exponent></RSAKeyValue>';
        IsInitialized := true;
    end;

    [Test]
    procedure TestSignDataWithCert()
    var
        TempBlob: Codeunit "Temp Blob";
        CryptographyManagement: Codeunit "Cryptography Management";
        X509Certificate2: Codeunit X509Certificate2;
        SignatureOutStream: OutStream;
        SignatureInStream: InStream;
        CertBase64Value: Text;
    begin
        CertBase64Value := GetTestCertWithPrivateKey();
        TempBlob.CreateInStream(SignatureInStream);
        TempBlob.CreateOutStream(SignatureOutStream);

        LibraryAssert.IsTrue(X509Certificate2.HasPrivateKey(CertBase64Value, 'testcert'), 'Cert must have private key to test signing');
        CryptographyManagement.SignData('Test data', X509Certificate2.GetCertificatePrivateKey(CertBase64Value, 'testcert'), enum::"Hash Algorithm"::SHA256, SignatureOutStream);

        LibraryAssert.IsTrue(CryptographyManagement.VerifyData('Test data', X509Certificate2.GetCertificatePublicKey(CertBase64Value, 'testcert'), enum::"Hash Algorithm"::SHA256, SignatureInStream), 'Failed to verify signed data');
    end;


    [Test]
    procedure DecryptEncryptedTextWithOaepPadding()
    var
        EncryptingTempBlob: Codeunit "Temp Blob";
        EncryptedTempBlob: Codeunit "Temp Blob";
        DecryptingTempBlob: Codeunit "Temp Blob";
        EncryptingInStream: InStream;
        EncryptingOutStream: OutStream;
        EncryptedInStream: InStream;
        EncryptedOutStream: OutStream;
        DecryptedInStream: InStream;
        DecryptedOutStream: OutStream;
        PlainText: Text;
    begin
        // [SCENARIO] Verify decrypted text with OAEP padding encryption.
        Initialize();

        // [GIVEN] With RSA pair of keys, plain text and its encryption stream
        EncryptingTempBlob.CreateOutStream(EncryptingOutStream);
        PlainText := SaveRandomTextToOutStream(EncryptingOutStream);
        EncryptingTempBlob.CreateInStream(EncryptingInStream);
        EncryptedTempBlob.CreateOutStream(EncryptedOutStream);
        RSACryptoServiceProvider.Encrypt(PublicKeyXmlString, EncryptingInStream, true, EncryptedOutStream);
        EncryptedTempBlob.CreateInStream(EncryptedInStream);

        // [WHEN] Decrypt encrypted text stream
        DecryptingTempBlob.CreateOutStream(DecryptedOutStream);
        RSACryptoServiceProvider.Decrypt(PrivateKeyXmlString, EncryptedInStream, true, DecryptedOutStream);
        DecryptingTempBlob.CreateInStream(DecryptedInStream);

        // [THEN] Decrypted text is the same as the plain text
        LibraryAssert.AreEqual(PlainText, Base64Convert.FromBase64(Base64Convert.ToBase64(DecryptedInStream)),
         'Unexpected decrypted text value.');
    end;

    [Test]
    procedure DecryptEncryptedTextWithPKCS1Padding()
    var
        EncryptingTempBlob: Codeunit "Temp Blob";
        EncryptedTempBlob: Codeunit "Temp Blob";
        DecryptingTempBlob: Codeunit "Temp Blob";
        EncryptingInStream: InStream;
        EncryptingOutStream: OutStream;
        EncryptedInStream: InStream;
        EncryptedOutStream: OutStream;
        DecryptedInStream: InStream;
        DecryptedOutStream: OutStream;
        PlainText: Text;
    begin
        // [SCENARIO] Verify decrypted text with PKCS#1 padding encryption.
        Initialize();

        // [GIVEN] With RSA pair of keys, plain text and its encryption stream
        EncryptingTempBlob.CreateOutStream(EncryptingOutStream);
        PlainText := SaveRandomTextToOutStream(EncryptingOutStream);
        EncryptingTempBlob.CreateInStream(EncryptingInStream);
        EncryptedTempBlob.CreateOutStream(EncryptedOutStream);
        RSACryptoServiceProvider.Encrypt(PublicKeyXmlString, EncryptingInStream, false, EncryptedOutStream);
        EncryptedTempBlob.CreateInStream(EncryptedInStream);

        // [WHEN] Decrypt encrypted text stream
        DecryptingTempBlob.CreateOutStream(DecryptedOutStream);
        RSACryptoServiceProvider.Decrypt(PrivateKeyXmlString, EncryptedInStream, false, DecryptedOutStream);
        DecryptingTempBlob.CreateInStream(DecryptedInStream);

        // [THEN] Decrypted text is the same as the plain text
        LibraryAssert.AreEqual(PlainText, Base64Convert.FromBase64(Base64Convert.ToBase64(DecryptedInStream)),
         'Unexpected decrypted text value.');
    end;

    [Test]
    procedure DecryptWithOAEPPaddingTextEncryptedWithPKCS1Padding()
    var
        EncryptingTempBlob: Codeunit "Temp Blob";
        EncryptedTempBlob: Codeunit "Temp Blob";
        DecryptingTempBlob: Codeunit "Temp Blob";
        EncryptingInStream: InStream;
        EncryptingOutStream: OutStream;
        EncryptedInStream: InStream;
        EncryptedOutStream: OutStream;
        DecryptedOutStream: OutStream;
    begin
        // [SCENARIO] Decrypt text encrypted with use of PKCS#1 padding, using OAEP padding.
        Initialize();

        // [GIVEN] With RSA pair of keys, plain text and encryption stream
        EncryptingTempBlob.CreateOutStream(EncryptingOutStream);
        SaveRandomTextToOutStream(EncryptingOutStream);
        EncryptingTempBlob.CreateInStream(EncryptingInStream);
        EncryptedTempBlob.CreateOutStream(EncryptedOutStream);
        RSACryptoServiceProvider.Encrypt(PublicKeyXmlString, EncryptingInStream, false, EncryptedOutStream);
        EncryptedTempBlob.CreateInStream(EncryptedInStream);

        // [WHEN] Decrypt encrypted text stream using OAEP Padding
        DecryptingTempBlob.CreateOutStream(DecryptedOutStream);
        asserterror RSACryptoServiceProvider.Decrypt(PrivateKeyXmlString, EncryptedInStream, true, DecryptedOutStream);

        // [THEN] Error occures
        LibraryAssert.ExpectedError('A call to System.Security.Cryptography.RSACryptoServiceProvider.Decrypt failed with this message: Cryptography_OAEPDecoding');
    end;

    [Test]
    procedure DecryptWithPKCS1PaddingTextEncryptedWithOAEPPadding()
    var
        EncryptingTempBlob: Codeunit "Temp Blob";
        EncryptedTempBlob: Codeunit "Temp Blob";
        DecryptingTempBlob: Codeunit "Temp Blob";
        EncryptingInStream: InStream;
        EncryptingOutStream: OutStream;
        EncryptedInStream: InStream;
        EncryptedOutStream: OutStream;
        DecryptedOutStream: OutStream;
    begin
        // [SCENARIO] Decrypt text encrypted with use of OAEP padding, using PKCS#1 padding.
        Initialize();

        // [GIVEN] With RSA pair of keys, plain text, padding and encryption stream
        EncryptingTempBlob.CreateOutStream(EncryptingOutStream);
        SaveRandomTextToOutStream(EncryptingOutStream);
        EncryptingTempBlob.CreateInStream(EncryptingInStream);
        EncryptedTempBlob.CreateOutStream(EncryptedOutStream);
        RSACryptoServiceProvider.Encrypt(PublicKeyXmlString, EncryptingInStream, true, EncryptedOutStream);
        EncryptedTempBlob.CreateInStream(EncryptedInStream);

        // [WHEN] Decrypt encrypted text stream using PKCS#1 padding.
        DecryptingTempBlob.CreateOutStream(DecryptedOutStream);
        asserterror RSACryptoServiceProvider.Decrypt(PrivateKeyXmlString, EncryptedInStream, false, DecryptedOutStream);

        // [THEN] Error occures
        LibraryAssert.ExpectedError('A call to System.Security.Cryptography.RSACryptoServiceProvider.Decrypt failed with this message: The parameter is incorrect.');
    end;

    local procedure SaveRandomTextToOutStream(OutStream: OutStream) PlainText: Text
    begin
        PlainText := Any.AlphanumericText(Any.IntegerInRange(80));
        OutStream.WriteText(PlainText);
    end;

    local procedure GetTestCertWithPrivateKey(): Text
    begin
        exit('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');
    end;

}