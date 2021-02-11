// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the types of asymmetric algorithms.
/// </summary>
enum 1446 SignatureAlgorithm implements SignatureAlgorithm
{
    Extensible = false;

    /// <summary>
    /// Specifies the RSA algorithm implemented by RSACryptoServiceProvider
    /// </summary>
    value(0; RSA)
    {
        Implementation = SignatureAlgorithm = "RSACryptoServiceProvider Impl.";
    }

    /// <summary>
    /// Specifies the DSA algorithm implemented by DSACryptoServiceProvider
    /// </summary>
    value(1; DSA)
    {
        Implementation = SignatureAlgorithm = "DSACryptoServiceProvider Impl.";
    }
}