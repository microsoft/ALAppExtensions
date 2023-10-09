// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.FileSystem;

/// <summary>
/// Indicator of what type the resource is.
/// </summary>
enum 70002 "File Type"
{
    Access = Public;
    Extensible = false;

    /// <summary>
    ///  Indicates if entry is a directory.
    /// </summary>
    value(0; Directory)
    {
        Caption = 'Directory', Locked = true;
    }

    /// <summary>
    ///  Indicates if entry is a file type.
    /// </summary>
    value(1; File)
    {
        Caption = 'File', Locked = true;
    }
}