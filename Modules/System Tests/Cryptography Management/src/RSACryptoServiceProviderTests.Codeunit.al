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
        LibraryAssert.ExpectedError('A call to System.Security.Cryptography.RSACryptoServiceProvider.Decrypt failed with this message: Error occurred while decoding OAEP padding.');
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
        LibraryAssert.ExpectedError('A call to System.Security.Cryptography.RSACryptoServiceProvider.Decrypt failed with this message: The parameter is incorrect.\');
    end;

    local procedure SaveRandomTextToOutStream(OutStream: OutStream) PlainText: Text
    begin
        PlainText := Any.AlphanumericText(Any.IntegerInRange(80));
        OutStream.WriteText(PlainText);
    end;

}