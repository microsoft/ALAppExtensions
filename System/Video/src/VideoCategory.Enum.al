// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>This enum is the category under which videos can be classified.</summary>
/// <remarks>Extensions can extend this enum to add custom categories.</remarks>
enum 3710 "Video Category"
{
    Extensible = true;

    /// <summary>
    /// A default category, specifying that the video is not categorized.
    /// </summary>
    value(0; Uncategorized)
    {
        Caption = 'Uncategorized';
    }
}