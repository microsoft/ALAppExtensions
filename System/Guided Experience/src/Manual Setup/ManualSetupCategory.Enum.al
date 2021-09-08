// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>The category enum is used to navigate the setup page, which can have many records. It is encouraged to extend this enum and use the newly defined options.</summary>
enum 1875 "Manual Setup Category"
{
    Extensible = true;

    /// <summary>
    /// A default category, specifying that the manual setup is not categorized.
    /// </summary>
    value(0; Uncategorized)
    {
        Caption = 'Uncategorized';
    }
}