// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for the Advanced Encryption Standard.
/// </summary>

codeunit 50101 "Rfc2898DeriveBytes"
{
    Access = Public;

    /// <summary>
    /// Initializes a new instance of the Rfc2898DeriveBytes class providing the Password, Salt, Saltlength and Psuedorandomnumber.
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="DesiredSaltLength">Represents the desired saltlength, if the Salt is longer or shorter it will change to the specified length</param>
    /// <param name="PsuedoRandomNumber">Represents the PsuedoRandomNumber, which is used to transform Rfc2898DeriveByes with SHA1Managed into a ByteArray</param>

    procedure HashRfc2898DeriveBytes(Password: Text; Salt: Text; DesiredSaltLength: Integer; PsuedoRandomNumber: Integer) Hash: Text
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
        Rfc2898DeriveBytes := Rfc2898DeriveBytes.Rfc2898DeriveBytes(Password, Encoding.ASCII.GetBytes(PadStr(Salt, DesiredSaltLength)));

        //Return a Base64 encoded string of the SHA1 hash of the first X bytes (X = PsuedoRandomNumber) returned from the generator.
        SHA1Managed := SHA1Managed.SHA1Managed;
        ByteArray := SHA1Managed.ComputeHash(Rfc2898DeriveBytes.GetBytes(PsuedoRandomNumber));
        Hash := Convert.ToBase64String(ByteArray);
    end;
}