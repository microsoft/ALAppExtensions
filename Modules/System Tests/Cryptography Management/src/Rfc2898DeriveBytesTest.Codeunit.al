// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132576 "Rfc2898DeriveBytes"
{
    Subtype = Test;

    [Test]
    procedure TestDeriveBytes()
    var
        CodRfc2898DeriveBytes: Codeunit Rfc2898DeriveBytes;
        EncryptedText: Text;
        ExpectedEncryptedText: Label 'RgIsn9T5fqPK8bsXjzlmWqinRxg=';
    begin
        // Encrypt Text 
        EncryptedText := CodRfc2898DeriveBytes.FuncCreateHashWithRfc2898DeriveBytes('Test', 'Test123', 23, 10);
        // Verify Result 
        IF (EncryptedText <> ExpectedEncryptedText) THEN
            ERROR('Failed to encrypt text');
    end;
}