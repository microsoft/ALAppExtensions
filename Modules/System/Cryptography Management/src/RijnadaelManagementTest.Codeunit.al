// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50102 "Rijnadael Management Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        LibraryRandom: Codeunit "Library Random";

    [Test]
    procedure "WithEncryptionKey.EncryptText.VerifyExpectedResult"()
    var
        RijndaelMgt: Codeunit "Rijndael Management";
        EncryptedText: Text;
    begin
        // [GIVEN] With Encryption Key 
        RijndaelMgt.InitRijndaelProvider(GetECP256BitEncryptionKey(), 256, 'ECB', 'None');
        // [WHEN] Encrypt Text 
        EncryptedText := RijndaelMgt.Encrypt(GetECP256BitPlainText());
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(GetECP256BitCryptedText(), EncryptedText, 'Failed to encrypt text with ECB');
    end;

    [Test]
    procedure "WithEncryptionKey.DecryptText.VerifyExpectedResult"()
    var
        RijndaelMgt: Codeunit "Rijndael Management";
        PlainText: Text;
    begin
        // [GIVEN] With Encryption Key 
        RijndaelMgt.InitRijndaelProvider(GetECP256BitEncryptionKey(), 256, 'ECB', 'None');
        // [WHEN] Plain Text
        PlainText := RijndaelMgt.Decrypt(GetECP256BitCryptedText());
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(GetECP256BitPlainText(), PlainText, 'Failed to decrypt text with ECB');
    end;

    [Test]
    procedure "DefaultEncryption.EncryptAndDecrypt.VerifyResult"()
    var
        RijndaelMgt: Codeunit "Rijndael Management";
        PlainText: Text;
        ResultText: Text;
    begin
        // [GIVEN] Default Encryption         
        PlainText := LibraryRandom.RandText(50);
        // [WHEN] Encrypt And Decrypt 
        ResultText := RijndaelMgt.Decrypt(RijndaelMgt.Encrypt(PlainText));
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(PlainText, ResultText, 'Decrypting an encrypted text failed.');
    end;

    [Test]
    procedure "DefaultEncryption.GetMinKeySize.ExpectedToBeValid"()
    var
        RijndaelMgt: Codeunit "Rijndael Management";
        MinSize: Integer;
        MaxSize: Integer;
        SkipSize: Integer;
    begin
        // [GIVEN] Default Encryption
        RijndaelMgt.InitRijndaelProvider();
        // [WHEN] Min Key Size Allowed 
        RijndaelMgt.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
        // [THEN] Expected to be valid
        LibraryAssert.AreEqual(true, RijndaelMgt.IsValidKeySize(MinSize), 'Minimum Key Size failed to verify');
    end;

    [Test]
    procedure "DefaultEncryption.GetMaxKeySize.ExpectedToBeValid"()
    var
        RijndaelMgt: Codeunit "Rijndael Management";
        MinSize: Integer;
        MaxSize: Integer;
        SkipSize: Integer;
    begin
        // [GIVEN] Default Encryption
        RijndaelMgt.InitRijndaelProvider();
        // [WHEN] Min Key Size Allowed 
        RijndaelMgt.GetLegalKeySizeValues(MinSize, MaxSize, SkipSize);
        // [THEN] Expected to be valid
        LibraryAssert.AreEqual(true, RijndaelMgt.IsValidKeySize(MaxSize), 'Minimum Key Size failed to verify');
    end;

    [Test]
    procedure "DefaultEncryption.CreatedEncryptionKey.ValidateDecryption"()
    var
        RijndaelMgt1: Codeunit "Rijndael Management";
        RijndaelMgt2: Codeunit "Rijndael Management";
        KeyAsBase64: Text;
        VectorAsBase64: Text;
        PlainText: Text;
        CryptedText: Text;
    begin
        // [GIVEN] Default Encryption        
        RijndaelMgt1.InitRijndaelProvider();
        PlainText := LibraryRandom.RandText(50);

        // [WHEN] Get Created Encryption Data
        RijndaelMgt1.GetEncryptionData(KeyAsBase64, VectorAsBase64);
        CryptedText := RijndaelMgt1.Encrypt(PlainText);

        // [THEN] Validate Decryption With Generated Key
        RijndaelMgt2.SetEncryptionData(KeyAsBase64, VectorAsBase64);
        LibraryAssert.AreEqual(PlainText, RijndaelMgt2.Decrypt(CryptedText), 'Set Encryption Datay and Decrypt failed');
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