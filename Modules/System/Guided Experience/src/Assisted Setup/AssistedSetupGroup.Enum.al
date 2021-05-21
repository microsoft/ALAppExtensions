// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>The group to which the setup belongs. Please extend this enum to add your own group to classify the setups being added by your extension.</summary>
enum 1815 "Assisted Setup Group"
{
    Extensible = true;

    /// <summary>
    /// A default group, specifying that the assisted setup is not categorized.
    /// </summary>
    value(0; Uncategorized)
    {
        Caption = 'Uncategorized';
    }
}