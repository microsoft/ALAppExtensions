// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 50101 "Rfc2898DeriveBytes"
{
    procedure FuncCreateHashWithRfc2898DeriveBytes(Password: Text; InputText: Text; PsuedoRandomNumber: Integer) Hash: Text
    var
        ByteArray: DotNet Array; // System.Array
        Convert: DotNet Convert; // System.Convert
        Encoding: DotNet Encoding; // System.Text.Encoding
        Rfc2898DeriveBytes: DotNet Rfc2898DeriveBytes; //System.Security.Cryptography.Rfc2898DeriveBytes
        SHA1Managed: DotNet SHA1Managed; // System.Security.Cryptography.SHA1Managed
    begin
        if InputText = '' then
            exit;

        Rfc2898DeriveBytes := Rfc2898DeriveBytes.Rfc2898DeriveBytes(Password, Encoding.ASCII.GetBytes(InputText));
        SHA1Managed := SHA1Managed.SHA1Managed;
        ByteArray := SHA1Managed.ComputeHash(Rfc2898DeriveBytes.GetBytes(PsuedoRandomNumber));
        Hash := Convert.ToBase64String(ByteArray);

        Clear(ByteArray);
        Clear(SHA1Managed);
        Clear(Rfc2898DeriveBytes);
    end;
}