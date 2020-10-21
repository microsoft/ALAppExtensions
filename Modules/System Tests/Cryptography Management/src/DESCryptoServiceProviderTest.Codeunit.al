// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132588 "DESCryptoServiceProvider Test"
{
    Subtype = Test;

    [Test]
    procedure TestEncryptText()
    var
        DESCryptoServiceProvider: Codeunit DESCryptoServiceProvider;
        LibraryAssert: Codeunit "Library Assert";
        EncryptedText: Text;
        ExpectedEncryptedTextEnding: Text;
        ExpectedEncryptedTextLength: Integer;
    begin
        // [GIVEN] With Encryption Key
        ExpectedEncryptedTextEnding := 'Yy';
        ExpectedEncryptedTextLength := 8;

        // [WHEN] Encrypt Text 
        EncryptedText := DESCryptoServiceProvider.EncryptText('Test', 'Test1234', 'ABitofSalt');

        // [THEN] Verify Result 
        LibraryAssert.IsTrue(EncryptedText.EndsWith(ExpectedEncryptedTextEnding), 'Unexpected value when encrypting text using DESCryptoServiceProvider');
        LibraryAssert.IsTrue((StrLen(EncryptedText) = ExpectedEncryptedTextLength), 'Unexpected value when encrypting text using DESCryptoServiceProvider');
        TestDecryptText(EncryptedText);
    end;

    procedure TestDecryptText(EncryptedText: Text)
    var
        DESCryptoServiceProvider: Codeunit DESCryptoServiceProvider;
        LibraryAssert: Codeunit "Library Assert";
        DecryptedText: Text;
        ExpectedDecryptedText: Text;
    begin
        // [GIVEN] With Encryption Key
        ExpectedDecryptedText := 'Test';

        // [WHEN] Encrypt Text 
        DecryptedText := DESCryptoServiceProvider.DecryptText(EncryptedText, 'Test1234', 'ABitofSalt');

        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedDecryptedText, DecryptedText, 'Unexpected value when decrypting text using DESCryptoServiceProvider');
    end;

    [Test]
    procedure TestEncryptStream()
    var
        TempBlob: Codeunit "Temp Blob";
        DESCryptoServiceProvider: Codeunit "DESCryptoServiceProvider";
        LibraryAssert: Codeunit "Library Assert";
        Base64Convert: Codeunit "Base64 Convert";
        InputInstream: InStream;
        OutputOutstream: Outstream;
        OutputInstream: InStream;
        Pixel: Text;
        ExpectedEncryptedText: Text;
        EncryptedStreamText: Text;
        Password: Text;
        Salt: Text;
    begin
        // [GIVEN] With Encryption Key
        ExpectedEncryptedText := 'xkSRTuW2xetrKER7vZiWFxrUU0I86+69aWshKgRxiLdGI8CvfreYzsBa+OIvneALcgJfZeGp5XTmJ4tFkUUXts5JuzoxFoVn';
        Password := 'Test1234';
        Salt := 'Test1234';
        Pixel := 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';

        TempBlob.CreateOutStream(OutputOutstream);
        Base64Convert.FromBase64(Pixel, OutputOutstream);
        TempBlob.CreateInStream(InputInstream);
        TempBlob.CreateOutStream(OutputOutstream);

        // [WHEN] Encrypt Stream
        DESCryptoServiceProvider.EncryptStream(Password, Salt, InputInstream, OutputOutstream);

        TempBlob.CreateInStream(OutputInstream);
        EncryptedStreamText := Base64Convert.ToBase64(OutputInstream);

        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedEncryptedText, EncryptedStreamText, 'Unexpected value when decrypting stream using DESCryptoServiceProvider');
    end;

    [Test]
    procedure TestDecryptStream()
    var
        TempBlob: Codeunit "Temp Blob";
        DESCryptoServiceProvider: Codeunit "DESCryptoServiceProvider";
        Base64Convert: Codeunit "Base64 Convert";
        LibraryAssert: Codeunit "Library Assert";
        OutputOutstream: Outstream;
        OutputInstream: InStream;
        EncryptedStreamText: Text;
        DecryptedStreamText: Text;
        ExpectedDecryptedStreamText: Text;
        Password: Text;
        Salt: Text;
        InputInstream: InStream;
    begin
        // [GIVEN] With Encryption Key
        EncryptedStreamText := 'xkSRTuW2xetrKER7vZiWFxrUU0I86+69aWshKgRxiLdGI8CvfreYzsBa+OIvneALcgJfZeGp5XTmJ4tFkUUXts5JuzoxFoVn';
        Password := 'Test1234';
        Salt := 'Test1234';
        ExpectedDecryptedStreamText := 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8/5+hHgAHggJ/PchI7wAAAABJRU5ErkJggg==';

        TempBlob.CreateOutStream(OutputOutstream);
        Base64Convert.FromBase64(EncryptedStreamText, OutputOutstream);
        TempBlob.CreateInStream(InputInstream);
        TempBlob.CreateOutStream(OutputOutstream);

        // [WHEN] Decrypt Stream
        DESCryptoServiceProvider.DecryptStream(Password, Salt, InputInstream, OutputOutstream);

        // [THEN] Verify Result 
        TempBlob.CreateInStream(OutputInstream);
        DecryptedStreamText := Base64Convert.ToBase64(OutputInstream);

        LibraryAssert.AreEqual(ExpectedDecryptedStreamText, DecryptedStreamText, 'Unexpected value when decrypting stream text using DESCryptoServiceProvider');
    end;

}