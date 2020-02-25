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
    /// Initializes a new instance of the Rfc2898DeriveBytes class providing the Password, Salt and NoOfBytes.
    /// </summary>
    /// <param name="Password">Represents the password to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="Salt">Represents the salt to be used to initialize a new instance of Rfc2898DeriveBytes</param>
    /// <param name="NoOfBytes">Represents the NoOfBytes, which is used to transform Rfc2898DeriveByes with SHA1Managed into a ByteArray</param>
    procedure HashRfc2898DeriveBytes(Password: Text; Salt: Text; NoOfBytes: Integer) Hash: Text
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        CryptographyManagementImpl.HashRfc2898DeriveBytes(Password, Salt, NoOfBytes);
    end;
}