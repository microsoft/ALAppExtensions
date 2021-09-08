// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the occurrence patterns for the recurrence.
/// </summary>
enum 4692 "Recurrence - Pattern"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the recurrence will occur daily.
    /// </summary>
    value(0; Daily)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur weekly.
    /// </summary>
    value(1; Weekly)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur monthly.
    /// </summary>
    value(2; Monthly)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur yearly.
    /// </summary>
    value(3; Yearly)
    {
    }
}