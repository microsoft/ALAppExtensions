// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum SymmetricAlgorithm (ID 1465) implements Interface SymmetricAlgorithm.
/// </summary>
enum 1465 SymmetricAlgorithm implements SymmetricAlgorithm
{
    Extensible = false;
    DefaultImplementation = SymmetricAlgorithm = "AesCryptoServiceProvider Impl.";
    UnknownValueImplementation = SymmetricAlgorithm = "AesCryptoServiceProvider Impl.";

    value(0; Aes)
    {
        Implementation = SymmetricAlgorithm = "AesCryptoServiceProvider Impl.";
    }

    value(1; TripleDES)
    {
        Implementation = SymmetricAlgorithm = "TripleDESCryptoSvcProv. Impl.";
    }
}