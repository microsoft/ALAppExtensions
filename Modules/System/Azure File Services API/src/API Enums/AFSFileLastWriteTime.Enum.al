// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Describes possible values for File Last Write Time header.
/// </summary>
enum 8952 "AFS File Last Write Time"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    /// The file last write time is set to the current time.
    /// </summary>
    value(0; Now)
    {
        Caption = 'now', Locked = true;
    }
    /// <summary>
    /// The file last write time is preserved.
    /// </summary>
    value(1; Preserve)
    {
        Caption = 'preserve', Locked = true;
    }
}