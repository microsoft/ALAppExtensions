// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum contains the Image format types.
/// </summary>
enum 3971 "Image Format"
{
    Extensible = false;

    /// <summary>
    /// Bmp image format
    /// </summary>
    value(0; Bmp) { Caption = 'BMP', Locked = true; }

    /// <summary>
    /// Emf image format
    /// </summary>
    value(1; Emf) { Caption = 'EMF', Locked = true; }

    /// <summary>
    /// Exif image format
    /// </summary>
    value(2; Exif) { Caption = 'EXIF', Locked = true; }

    /// <summary>
    /// Gif image format
    /// </summary>
    value(3; Gif) { Caption = 'GIF', Locked = true; }

    /// <summary>
    /// Icon image format
    /// </summary>
    value(5; Icon) { Caption = 'ICON', Locked = true; }

    /// <summary>
    /// Jpeg image format
    /// </summary>
    value(6; Jpeg) { Caption = 'JPEG', Locked = true; }

    /// <summary>
    /// Png image format
    /// </summary>
    value(7; Png) { Caption = 'PNG', Locked = true; }

    /// <summary>
    /// Tiff image format
    /// </summary>
    value(8; Tiff) { Caption = 'TIFF', Locked = true; }

    /// <summary>
    /// Wmf image format
    /// </summary>
    value(9; Wmf) { Caption = 'WMF', Locked = true; }
}