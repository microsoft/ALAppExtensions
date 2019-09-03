// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Calculates when the next event will occur. Events can recur daily, weekly, monthly or yearly.
/// </summary>
codeunit 4690 "Recurrence Schedule"
{
    Access = Public;

    /// <summary>
    /// Sets the earliest date to be returned from CalculateNextOccurrence.
    /// The default MinDateTime is today at the start time set in recurrence.
    /// </summary>
    /// <param name="DateTime">The minimum datetime.</param>
    /// See <see cref="Recurrence.CalculateNextOccurrence"/> to calculate next occurrence.
    /// <example>
    /// To start calculating recurrence from January 1st, 2000,
    /// call SetMinDateTime(CREATEDATETIME(DMY2DATE(1, 1, 2000), 0T)).
    /// </example>
    procedure SetMinDateTime(DateTime: DateTime)
    begin
        RecurrenceScheduleImpl.SetMinDateTime(DateTime);
    end;

    /// <summary>
    /// Calculates the time and date for the next occurrence.
    /// </summary>
    /// <param name="RecurrenceID">The recurrence ID.</param>
    /// <param name="LastOccurrence">The time of the last scheduled occurrence.</param>
    /// <returns>Returns the DateTime value for the next occurrence. If there is no next occurrence, it returns the default value 0DT.</returns>
    /// <example>
    /// To calculate the first occurrence (this is using the datatime provided in SetMinDateTime as a minimum datetime to return),
    /// call CalculateNextOccurrence(RecurrenceID, 0DT)), the RecurrenceID is the ID returned from one of the create functions.
    /// </example>
    procedure CalculateNextOccurrence(RecurrenceID: Guid; LastOccurrence: DateTime): DateTime
    begin
        EXIT(RecurrenceScheduleImpl.CalculateNextOccurrence(RecurrenceID, LastOccurrence));
    end;

    /// <summary>
    /// Creates a daily recurrence.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="DaysBetween">The number of days between each occurrence, starting with 1.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a recurrence that starts today, repeats every third day, and does not have an end date,
    /// call RecurrenceID := CreateDaily(now, today, 0D , 3).
    /// </example>
    procedure CreateDaily(StartTime: Time; StartDate: Date; EndDate: Date; DaysBetween: Integer): Guid
    begin
        EXIT(RecurrenceScheduleImpl.CreateDaily(StartTime, StartDate, EndDate, DaysBetween));
    end;

    /// <summary>
    /// Creates a weekly recurrence.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="WeeksBetween">The number of weeks between each occurrence, starting with 1.</param>
    /// <param name="Monday">Occur on Mondays.</param>
    /// <param name="Tuesday">Occur on Tuesdays.</param>
    /// <param name="Wednesday">Occur on Wednesdays.</param>
    /// <param name="Thursday">Occur on Thursdays.</param>
    /// <param name="Friday">Occur on Fridays.</param>
    /// <param name="Saturday">Occur on Saturdays.</param>
    /// <param name="Sunday">Occur on Sundays.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a weekly recurrence that starts today, repeats every Monday and Wednesday, and does not have an end date,
    /// call RecurrenceID := CreateWeekly(now, today, 0D , 1, true, false, true, false, false, false, false).
    /// </example>
    procedure CreateWeekly(StartTime: Time; StartDate: Date; EndDate: Date; WeeksBetween: Integer; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Guid
    begin
        EXIT(
          RecurrenceScheduleImpl.CreateWeekly(StartTime, StartDate, EndDate, WeeksBetween, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday));
    end;

    /// <summary>
    /// Creates a monthly recurrence by day.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="MonthsBetween">The number of months between each occurrence, starting with 1.</param>
    /// <param name="DayOfMonth">The day of the month.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a monthly recurrence that repeats on the fourth day of every month,
    /// call RecurrenceID := CreateMonthlyByDay(now, today, 0D , 1, 4).
    /// </example>
    procedure CreateMonthlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; DayOfMonth: Integer): Guid
    begin

        EXIT(RecurrenceScheduleImpl.CreateMonthlyByDay(StartTime, StartDate, EndDate, MonthsBetween, DayOfMonth));
    end;

    /// <summary>
    /// Creates a monthly recurrence by the day of the week.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="MonthsBetween">The number of months between each occurrence, starting with 1.</param>
    /// <param name="InWeek">The week of the month.</param>
    /// <param name="DayOfWeek">The day of the week.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a monthly recurrence that calculates every last Friday of every month,
    /// call RecurrenceID := CreateMonthlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Friday).
    /// </example>
    procedure CreateMonthlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"): Guid
    begin
        EXIT(RecurrenceScheduleImpl.CreateMonthlyByDayOfWeek(StartTime, StartDate, EndDate, MonthsBetween, InWeek, DayOfWeek));
    end;

    /// <summary>
    /// Creates a yearly recurrence by day.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="YearsBetween">The number of years between each occurrence, starting with 1.</param>
    /// <param name="DayOfMonth">The day of the month.</param>
    /// <param name="Month">The month of the year.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a yearly recurrence that repeats on the first day of December,
    /// call RecurrenceID := CreateYearlyByDay(now, today, 0D , 1, 1, RecurrenceMonth::December).
    /// </example>
    procedure CreateYearlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; DayOfMonth: Integer; Month: Enum "Recurrence - Month"): Guid
    begin
        EXIT(RecurrenceScheduleImpl.CreateYearlyByDay(StartTime, StartDate, EndDate, YearsBetween, DayOfMonth, Month));
    end;

    /// <summary>
    /// Creates a yearly recurrence by day of week of a given month.
    /// </summary>
    /// <param name="StartTime">The start time of the recurrence.</param>
    /// <param name="StartDate">The start date of the recurrence.</param>
    /// <param name="EndDate">The end date of the recurrence.</param>
    /// <param name="YearsBetween">The number of years between each occurrence, starting with 1.</param>
    /// <param name="InWeek">The week of the month.</param>
    /// <param name="DayOfWeek">The day of the week.</param>
    /// <param name="Month">The month of the year.</param>
    /// <returns>The ID used to reference this recurrence.</returns>
    /// <example>
    /// To create a yearly recurrence that repeats on the last Friday of every month,
    /// call RecurrenceID := CreateYearlyByDayOfWeek(now, today, 0D , 1, RecurrenceOrdinalNo::Last, RecurrenceDayofWeek::Weekday, RecurrenceMonth::December).
    /// </example>
    procedure CreateYearlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"; Month: Enum "Recurrence - Month"): Guid
    begin
        EXIT(RecurrenceScheduleImpl.CreateYearlyByDayOfWeek(StartTime, StartDate, EndDate, YearsBetween, InWeek, DayOfWeek, Month));
    end;

    /// <summary>
    /// Opens the card for the recurrence.
    /// </summary>
    /// <param name="RecurrenceID">The recurrence ID.</param>
    procedure OpenRecurrenceSchedule(var RecurrenceID: Guid)
    begin
        RecurrenceScheduleImpl.OpenRecurrenceSchedule(RecurrenceID);
    end;

    /// <summary>
    /// Returns a short text description of the recurrence.
    /// </summary>
    /// <param name="RecurrenceID">The recurrence ID.</param>
    /// <returns>The short text to display.</returns>
    procedure RecurrenceDisplayText(RecurrenceID: Guid): Text
    begin
        EXIT(RecurrenceScheduleImpl.RecurrenceDisplayText(RecurrenceID));
    end;

    var
        RecurrenceScheduleImpl: Codeunit "Recurrence Schedule Impl.";
}

