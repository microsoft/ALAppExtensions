// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies media type for the Media Interaction page.
/// </summary>
enum 1909 "Media Type"
{
    Extensible = false;

    /// <summary>
    /// Choose from either pictures or videos.
    /// </summary>
    value(0; "All Media")
    {
        Caption = 'All Media';
    }

    /// <summary>
    /// Choose from pictures.
    /// </summary>
    value(1; Picture)
    {
        Caption = 'Picture';
    }

    /// <summary>
    /// Choose from videos.
    /// </summary>
    value(2; Video)
    {
        Caption = 'Video';
    }
}