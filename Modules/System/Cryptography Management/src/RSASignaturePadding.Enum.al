// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Enum that specifies all of the available padding modes. For more details check .NET RSASignaturePadding Class 
/// </summary>
enum 1285 "RSA Signature Padding"
{
    Extensible = false;

    /// <summary>
    /// Specifies PKCS #1 v1.5 padding mode.
    /// </summary>
    value(0; Pkcs1)
    {
        Caption = 'Pkcs1', Locked = true;
    }

    /// <summary>
    /// Specifies PSS padding mode.
    /// </summary>
    value(1; Pss)
    {
        Caption = 'Pss', Locked = true;
    }
}