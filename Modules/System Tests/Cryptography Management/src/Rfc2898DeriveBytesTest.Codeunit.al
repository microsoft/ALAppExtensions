// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132576 "Rfc2898DeriveBytes Test"
{
    Subtype = Test;

    [Test]
    procedure TestDeriveBytes()
    var
        CodRfc2898DeriveBytes: Codeunit Rfc2898DeriveBytes;
        EncryptedText: Text;
        ExpectedEncryptedText: Label 'fzBagIx5+suJx7TQ/wLi98ZQHik=';
    begin
        // Encrypt Text 
        EncryptedText := CodRfc2898DeriveBytes.HashRfc2898DeriveBytes('Test', 'Test1234', 23);
        // Verify Result 
        IF (EncryptedText <> ExpectedEncryptedText) THEN
            ERROR('Failed to encrypt text');
    end;
}