// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Provides helper functions for the Advanced Encryption Standard.
/// </summary>
codeunit 1378 "Rfc2898DeriveBytes"
{
    Access = Public;

    /// <summary>
    /// Generates a base64 encoded hash from a string based on the provided hash algorithm.
    /// </summary>
    /// <param name="InputString">Represents the input to be hashed</param>
    /// <param name="Salt">The salt used to derive the key</param>
    /// <param name="NoOfBytes">The number of pseudo-random key bytes to generate</param>
    /// <param name="HashAlgorithmType">Represents the HashAlgorithmType, which returns the encrypted hash in the desired algorithm type</param>
    /// <returns>Hash of input</returns>
    /// <error>If generating the hash fails, it throws a dotnet error.</error>
    procedure HashRfc2898DeriveBytes(InputString: Text; Salt: Text; NoOfBytes: Integer; HashAlgorithmType: Option MD5,SHA1,SHA256,SHA384,SHA512): Text
    var
        CryptographyManagementImpl: Codeunit "Cryptography Management Impl.";
    begin
        exit(CryptographyManagementImpl.HashRfc2898DeriveBytes(InputString, Salt, NoOfBytes, HashAlgorithmType));
    end;
}