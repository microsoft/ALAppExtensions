// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the types of RSA Encryption Padding.
/// </summary>
enum 1448 RSAEncryptionPadding
{
    Extensible = true;

    /// <summary>
    /// Specifies the OaepSHA1 RSA Encryption Padding.
    /// </summary>
    value(0; OaepSHA1)
    {
    }
    /// <summary>
    /// Specifies the OaepSHA256 RSA Encryption Padding.
    /// </summary>
    value(1; OaepSHA256)
    {
    }
    /// <summary>
    /// Specifies the OaepSHA384 RSA Encryption Padding.
    /// </summary>
    value(2; OaepSHA384)
    {
    }
    /// <summary>
    /// Specifies the OaepSHA512 RSA Encryption Padding.
    /// </summary>
    value(3; OaepSHA512)
    {
    }
    /// <summary>
    /// Specifies the Pkcs1 RSA Encryption Padding.
    /// </summary>
    value(4; Pkcs1)
    {
    }
}