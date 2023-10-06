// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.Security.Encryption;

using System.Security.Encryption;

codeunit 132615 "Cryptography Management Test"
{
    Subtype = Test;

    [Test]
    procedure TestEncryptInputLengthOk()
    var
        CryptographyManagement: Codeunit "Cryptography Management";
        Input: Text[215];
    begin

        // [GIVEN] Normal input of size < 215
        Input := CopyStr('ABCD', 1, 215);
        if not CryptographyManagement.IsEncryptionPossible() then
            CryptographyManagement.EnableEncryption(true);

        // [WHEN] Encrypt is called
        // [THEN] No errors occured
        CryptographyManagement.EncryptText(Input);
    end;
}