// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the types of hash algorithm.
/// </summary>
enum 1445 "Hash Algorithm"
{
    Extensible = true;

    /// <summary>
    /// Specifies the MD5 hash algorithm
    /// </summary>
    value(0; MD5)
    {
    }

    /// <summary>
    /// Specifies the SHA1 hash algorithm
    /// </summary>
    value(1; SHA1)
    {
    }

    /// <summary>
    /// Specifies the SHA256 hash algorithm
    /// </summary>
    value(2; SHA256)
    {
    }

    /// <summary>
    /// Specifies the SHA384 hash algorithm
    /// </summary>
    value(3; SHA384)
    {
    }

    /// <summary>
    /// Specifies the SHA512 hash algorithm
    /// </summary>
    value(4; SHA512)
    {
    }
}