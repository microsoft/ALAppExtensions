// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 11111567 "Test Rfc2898DeriveBytes"
{
    Subtype = Test;

    [Test]
    procedure TestDeriveBytes()
    var
        CodRfc2898DeriveBytes: Codeunit Rfc2898DeriveBytes;
        EncryptedText: Text;
        ExpectedEncryptedText: Text;
        LibraryAssert: Codeunit "Library Assert";
    begin
        // [GIVEN] With Encryption Key 
        ExpectedEncryptedText := GetRfc2898DeriveBytesEncryptedText();
        // [WHEN] Encrypt Text 
        EncryptedText := CodRfc2898DeriveBytes.HashRfc2898DeriveBytes('Test', 'Test1234', 23);
        // [THEN] Verify Result 
        LibraryAssert.AreEqual(ExpectedEncryptedText, EncryptedText, 'Failed to encrypt text with Rfc2898DeriveBytes');
    end;

    local procedure GetRfc2898DeriveBytesEncryptedText(): Text
    begin
        exit('fzBagIx5+suJx7TQ/wLi98ZQHik=');
    end;
}