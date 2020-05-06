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
        CodDESCryptoServiceProvider: Codeunit DESCryptoServiceProvider;
        EncryptedText: Text;
        ExpectedEncryptedText: Text;
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] With Encryption Key
        ExpectedEncryptedText := GetCodDESCryptoServiceProviderEncryptedText();
        // [WHEN] Encrypt Text 
        EncryptedText := CodDESCryptoServiceProvider.EncryptTextWithDESCryptoServiceProvider('Test', 'Test1234', 'ABitofSalt');
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedEncryptedText, EncryptedText, 'Failed to encrypt and/or decrypt text with DESCryptoServiceProvider');
    end;

    procedure TestDecryptText()
    var
        CodDESCryptoServiceProvider: Codeunit DESCryptoServiceProvider;
        DecryptedText: Text;
        ExpectedEncryptedText: Text;
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] With Encryption Key
        ExpectedEncryptedText := 'Test';
        // [WHEN] Encrypt Text 
        DecryptedText := CodDESCryptoServiceProvider.DecryptTextWithDESCryptoServiceProvider('Test', 'Test1234', 'ABitofSalt');
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedEncryptedText, DecryptedText, 'Failed to encrypt and/or decrypt text with DESCryptoServiceProvider');
    end;


    local procedure GetCodDESCryptoServiceProviderEncryptedText(): Text
    begin
        exit('·lá:Yy');
    end;

}