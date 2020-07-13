// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 132576 "Test DESCryptoServiceProvider"
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
        EncryptedText := DESCryptoServiceProvider.EncryptTextWithDESCryptoServiceProvider('Test', 'Test1234', 'ABitofSalt');
        // [THEN] Verify Result 
        LibraryAssert.IsTrue(EncryptedText.EndsWith(ExpectedEncryptedTextEnding), 'Unexpected value when encrypting text using DESCryptoServiceProvider');
        LibraryAssert.IsTrue((StrLen(EncryptedText) = ExpectedEncryptedTextLength), 'Unexpected value when encrypting text using DESCryptoServiceProvider');
    end;

    procedure TestDecryptText()
    var
        DESCryptoServiceProvider: Codeunit DESCryptoServiceProvider;
        LibraryAssert: Codeunit "Library Assert";
        DecryptedText: Text;
        ExpectedEncryptedText: Text;
    begin
        // [GIVEN] With Encryption Key
        ExpectedEncryptedText := 'Test';
        // [WHEN] Encrypt Text 
        DecryptedText := DESCryptoServiceProvider.DecryptTextWithDESCryptoServiceProvider('Test', 'Test1234', 'ABitofSalt');
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedEncryptedText, DecryptedText, 'Unexpected value when encrypting text using DESCryptoServiceProvider');
    end;

}