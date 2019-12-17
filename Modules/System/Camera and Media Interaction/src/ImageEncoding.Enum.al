// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies the supported encodings for the Camera Interaction page.
/// </summary>
enum 1908 "Image Encoding"
{
    Extensible = false;

    /// <summary>
    /// JPEG image encoding format.
    /// </summary>
    value(0; JPEG)
    {
        Caption = 'JPEG';
    }

    /// <summary>
    /// PNG image encoding format.
    /// </summary>
    value(1; PNG)
    {
        Caption = 'PNG';
    }
}