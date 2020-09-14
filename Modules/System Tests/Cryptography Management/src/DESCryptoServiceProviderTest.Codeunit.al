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

}