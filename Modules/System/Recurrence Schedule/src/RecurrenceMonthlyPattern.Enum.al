// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the monthly occurrence patterns for the recurrence.
/// </summary>
enum 4694 "Recurrence - Monthly Pattern"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the recurrence will occur on a specific day.
    /// </summary>
    value(0; "Specific Day")
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur on a weekday. This is used in conjuction with the "Recurrence - Day Of Week" enums.
    /// </summary>
    value(1; "By Weekday")
    {
    }
}