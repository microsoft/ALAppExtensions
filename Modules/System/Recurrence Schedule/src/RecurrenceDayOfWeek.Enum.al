// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// This enum has the day of the week for which the recurrence will occur.
/// </summary>
enum 4690 "Recurrence - Day of Week"
{
    Extensible = false;

    /// <summary>
    /// Specifies that the recurrence to occur on Monday.
    /// </summary>
    value(1; Monday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Tuesday.
    /// </summary>
    value(2; Tuesday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Wednesday.
    /// </summary>
    value(3; Wednesday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Thursday.
    /// </summary>
    value(4; Thursday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Friday.
    /// </summary>
    value(5; Friday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Saturday.
    /// </summary>
    value(6; Saturday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Sunday.
    /// </summary>
    value(7; Sunday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur every day.
    /// </summary>
    value(8; Day)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on all days from Monday to Friday.
    /// </summary>
    value(9; Weekday)
    {
    }

    /// <summary>
    /// Specifies that the recurrence to occur on Saturday and Sunday.
    /// </summary>
    value(10; "Weekend Day")
    {
    }
}