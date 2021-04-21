// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132575 "Rijndael Cryptography Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryAny: Codeunit "Any";

    [Test]
    procedure VerifyEncryptText()
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        EncryptedText: Text;
    begin
        // [GIVEN] With Encryption Key 
        RijndaelCryptography.InitRijndaelProvider(GetECP256BitEncryptionKey(), 256, 'ECB', 'None');
        // [WHEN] Encrypt Text 
        EncryptedText := RijndaelCryptography.Encrypt(GetECP256BitPlainText());
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(GetECP256BitCryptedText(), EncryptedText, 'Failed to encrypt text with ECB');
    end;

    [Test]
    procedure VerifyDecryptText()
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        PlainText: Text;
    begin
        // [GIVEN] With Encryption Key 
        RijndaelCryptography.InitRijndaelProvider(GetECP256BitEncryptionKey(), 256, 'ECB', 'None');
        // [WHEN] Plain Text
        PlainText := RijndaelCryptography.Decrypt(GetECP256BitCryptedText());
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(GetECP256BitPlainText(), PlainText, 'Failed to decrypt text with ECB');
    end;

    [Test]
    procedure VerifyEncryptAndDecryptText()
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        PlainText: Text;
        ResultText: Text;
    begin
        // [GIVEN] Default Encryption         
        PlainText := LibraryAny.AlphanumericText(50);
        // [WHEN] Encrypt And Decrypt 
        ResultText := RijndaelCryptography.Decrypt(RijndaelCryptography.Encrypt(PlainText));
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(PlainText, ResultText, 'Decrypting an encrypted text failed.');
    end;

    [Test]
    procedure VerifyMinimumKeySize()
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        MinSize: Integer;
        MaxSize: Integer;
        SkipSize: Integer;
    begin
        // [GIVEN] Default Encryption
        RijndaelCryptography.InitRijndaelProvider();
        // [WHEN] Min Key Size Allowed 
        RijndaelCryptography.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
        // [THEN] Expected to be valid
        LibraryAssert.IsTrue(RijndaelCryptography.IsValidKeySize(MinSize), 'Minimum Key Size failed to verify');
    end;

    [Test]
    procedure VerifyMaximumKeySize()
    var
        RijndaelCryptography: Codeunit "Rijndael Cryptography";
        MinSize: Integer;
        MaxSize: Integer;
        SkipSize: Integer;
    begin
        // [GIVEN] Default Encryption
        RijndaelCryptography.InitRijndaelProvider();
        // [WHEN] Min Key Size Allowed 
        RijndaelCryptography.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
        // [THEN] Expected to be valid
        LibraryAssert.IsTrue(RijndaelCryptography.IsValidKeySize(MaxSize), 'Minimum Key Size failed to verify');
    end;

    [Test]
    procedure VerifyCreateEncryptionKeyAndDecryption()
    var
        RijndaelCryptography1: Codeunit "Rijndael Cryptography";
        RijndaelCryptography2: Codeunit "Rijndael Cryptography";
        KeyAsBase64: Text;
        VectorAsBase64: Text;
        PlainText: Text;
        CryptedText: Text;
    begin
        // [GIVEN] Default Encryption        
        RijndaelCryptography1.InitRijndaelProvider();
        PlainText := LibraryAny.AlphanumericText(50);

        // [WHEN] Get Created Encryption Data
        RijndaelCryptography1.GetEncryptionData(KeyAsBase64, VectorAsBase64);
        CryptedText := RijndaelCryptography1.Encrypt(PlainText);

        // [THEN] Validate Decryption With Generated Key
        RijndaelCryptography2.SetEncryptionData(KeyAsBase64, VectorAsBase64);
        LibraryAssert.AreEqual(PlainText, RijndaelCryptography2.Decrypt(CryptedText), 'Set Encryption Datay and Decrypt failed');
    end;

    local procedure GetECP256BitCryptedText(): Text
    begin
        exit('ABEilKub5kv1gBSG06y5Xf002feelEUmP3GPGnxTlZY=');
    end;

    local procedure GetECP256BitPlainText(): Text
    begin
        exit('afa1beac1c9f236cf678c392963c4716');
    end;

    local procedure GetECP256BitEncryptionKey(): Text
    begin
        exit('hYRCHMB9TPHu7lIcRsiQ6WmqtaaFGlnF');
    end;

}