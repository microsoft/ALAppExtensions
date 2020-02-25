// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 132576 "Rfc2898DeriveBytes"
{
    procedure FuncCreateHashWithRfc2898DeriveBytes(Password: Text; InputText: Text; PsuedoRandomNumber: Integer; FillCharacter: Integer) Hash: Text
    var
        ByteArray: DotNet Array;
        Convert: DotNet Convert;
        Encoding: DotNet Encoding;
        Rfc2898DeriveBytes: DotNet Rfc2898DeriveBytes;
        SHA1Managed: DotNet SHA1Managed;
    begin
        if InputText = '' then
            exit;

        //Implement password-based key derivation functionality, PBKDF2, by using a pseudo-random number generator based on HMACSHA1.
        Rfc2898DeriveBytes := Rfc2898DeriveBytes.Rfc2898DeriveBytes(Password, Encoding.ASCII.GetBytes(PadStr(InputText, FillCharacter)));

        //Return a Base64 encoded string of the SHA1 hash of the first X bytes (X = PsuedoRandomNumber) returned from the generator.
        SHA1Managed := SHA1Managed.SHA1Managed;
        ByteArray := SHA1Managed.ComputeHash(Rfc2898DeriveBytes.GetBytes(PsuedoRandomNumber));
        Hash := Convert.ToBase64String(ByteArray);

        //Clear all used variables
        Clear(ByteArray);
        Clear(SHA1Managed);
        Clear(Rfc2898DeriveBytes);
    end;
}