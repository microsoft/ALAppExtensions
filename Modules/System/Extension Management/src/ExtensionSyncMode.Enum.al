// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Specifies how to sync the extension.
/// </summary>
enum 2505 "Extension Sync Mode"
{
    Extensible = false;
    AssignmentCompatibility = true;

    /// <summary>
    /// Modifies the database schema by creating or extending the tables required to
    /// satisfy the app's metadata. This mode considers existing versions of the specified
    /// app in its calculations.
    /// </summary>
    value(0; "Add")
    {
        Caption = 'Add';
    }

    /// <summary>
    /// A destructive sync mode which makes the resulting schema match the extension in question
    /// regardless of its starting state. This means no change is off limits. This also means
    /// that changes which delete things (tables, fields, etc.) also delete the data they contain.
    /// </summary>
    /// <remarks>
    /// This mode is intended for use when e.g. renaming tables. It can lead to data loss if used
    /// without caution.
    /// </remarks>
    value(3; "Force Sync")
    {
        Caption = 'Force';
    }
}