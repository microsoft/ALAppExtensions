// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the Status of the BCPT Header.
/// </summary>
enum 149000 "BCPT Header Status"
{
    Extensible = false;

    /// <summary>
    /// Specifies the initial state.
    /// </summary>
    value(0; " ")
    {
    }

    /// <summary>
    /// Specifies that the BCPT Header state is Running.
    /// </summary>
    value(20; Running)
    {
    }

    /// <summary>
    /// Specifies that the BCPT Header state is Completed.
    /// </summary>
    value(30; Completed)
    {
    }

    /// <summary>
    /// Specifies that the BCPT Header state is Cancelled.
    /// </summary>
    value(40; Cancelled)
    {
    }
}