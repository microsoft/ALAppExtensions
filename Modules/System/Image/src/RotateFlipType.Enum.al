// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies how much an image is rotated and the axis used to flip the image.
/// </summary>
enum 3972 "Rotate Flip Type"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// Specifies no clockwise rotation and no flipping.
    /// </summary>
    value(0; RotateNoneFlipNone) { Caption = 'RotateNoneFlipNone', Locked = true; }

    /// <summary>
    /// Specifies a 90-degree clockwise rotation without flipping.
    /// </summary>
    value(1; Rotate90FlipNone) { Caption = 'Rotate90FlipNone', Locked = true; }

    /// <summary>
    /// Specifies a 180-degree clockwise rotation without flipping.
    /// </summary>
    value(2; Rotate180FlipNone) { Caption = 'Rotate180FlipNone', Locked = true; }

    /// <summary>
    /// Specifies a 270-degree clockwise rotation without flipping.
    /// </summary>
    value(3; Rotate270FlipNone) { Caption = 'Rotate270FlipNone', Locked = true; }

    /// <summary>
    /// Specifies no clockwise rotation followed by a horizontal flip.
    /// </summary>
    value(4; RotateNoneFlipX) { Caption = 'RotateNoneFlipX', Locked = true; }

    /// <summary>
    /// Specifies a 90-degree clockwise rotation followed by a horizontal flip.
    /// </summary>
    value(5; Rotate90FlipX) { Caption = 'Rotate90FlipX', Locked = true; }

    /// <summary>
    /// Specifies a 180-degree clockwise rotation followed by a horizontal flip.
    /// </summary>
    value(6; Rotate180FlipX) { Caption = 'Rotate180FlipX', Locked = true; }

    /// <summary>
    /// Specifies a 270-degree clockwise rotation followed by a horizontal flip.
    /// </summary>
    value(7; Rotate270FlipX) { Caption = 'Rotate270FlipX', Locked = true; }
}