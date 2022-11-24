// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The types of BLOBs supported in Azure Blob Storage.
/// See: https://go.microsoft.com/fwlink/?linkid=2210594
/// </summary>
enum 9047 "ABS Blob Type"
{
    Access = Internal;
    Extensible = false;

    /// <summary>
    /// Optimized for streaming.
    /// </summary>
    value(0; BlockBlob)
    {
        Caption = 'BlockBlob', Locked = true;
    }

    /// <summary>
    /// Optimized for random read/write operations and provides the ability to write to a range of bytes in a blob.
    /// </summary>
    value(1; PageBlob)
    {
        Caption = 'PageBlob', Locked = true;
    }

    /// <summary>
    /// Optimized for append operations.
    /// </summary>
    value(2; AppendBlob)
    {
        Caption = 'AppendBlob', Locked = true;
    }
}