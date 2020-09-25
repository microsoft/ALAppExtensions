// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the Delay Type of the BCPT Line.
/// </summary>
enum 149002 "BCPT Line Delay Type"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the BCPT Line Delay Type Fixed.
    /// </summary>
    value(10; Fixed)
    {
    }
    /// <summary>
    /// Specifies that the BCPT Line Delay Type is Random.
    /// </summary>
    value(20; Random)
    {
    }
}