// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the ordinal numbers for which the recurrence will occur.
/// </summary>
enum 4693 "Recurrence - Ordinal No."
{
    Extensible = false;

    /// <summary>
    /// Specifies that the recurrence will occur in the first week of the month.
    /// </summary>
    value(0; First)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur in the second week of the month.
    /// </summary>
    value(1; Second)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur in the third week of the month.
    /// </summary>
    value(2; Third)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur in the fourth week of the month.
    /// </summary>
    value(3; Fourth)
    {
    }

    /// <summary>
    /// Specifies that the recurrence will occur in the last week of the month.
    /// In months with four weeks, the "Last" enum is the same as "Fourth" enum.
    /// </summary>
    value(4; Last)
    {
    }
}