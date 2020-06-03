// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 4691 "Recurrence Schedule Impl."
{
    Access = Internal;

    var
        MinDateTime: DateTime;
        MinDateTimeSet: Boolean;
        RecurrenceDisplayTxt: Label 'Recurring %1 starting %2', Comment = '%1 = it recurrence pattern like Daily, Weekly, Monthly..., %2 = The date the recurrence starts';
        RecurrenceMaximumCalculateLimitTxt: Label 'Exceeded maximum calculation limit for recurrence. Change start date to be today.';

    procedure SetMinDateTime(DateTime: DateTime)
    begin
        MinDateTime := DateTime;
        MinDateTimeSet := TRUE;
    end;

    local procedure GetMinDateTime(): DateTime
    begin
        IF MinDateTimeSet THEN
            EXIT(MinDateTime);
        EXIT(CURRENTDATETIME());
    end;

    local procedure IsAfterOrEqualToMinDateTime(RecurrenceSchedule: Record "Recurrence Schedule"; NextDate: Date): Boolean
    begin
        IF NextDate = 0D THEN
            EXIT(TRUE);
        EXIT(CREATEDATETIME(NextDate, RecurrenceSchedule."Start Time") >= GetMinDateTime());
    end;

    procedure CalculateNextOccurrence(RecurrenceID: Guid; LastOccurrence: DateTime): DateTime
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        NextDate: Date;
        Counter: Integer;
    begin
        RecurrenceSchedule.GET(RecurrenceID);
        NextDate := DT2DATE(LastOccurrence);

        REPEAT
            CASE RecurrenceSchedule.Pattern OF
                RecurrenceSchedule.Pattern::Daily:
                    NextDate := CalculateDaily(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Weekly:
                    NextDate := CalculateWeekly(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Monthly:
                    NextDate := CalculateMonthly(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Yearly:
                    NextDate := CalculateYearly(RecurrenceSchedule, NextDate);
            END;

            Counter := Counter + 1;
            if Counter >= 500 then
                Error(RecurrenceMaximumCalculateLimitTxt);
        UNTIL IsAfterOrEqualToMinDateTime(RecurrenceSchedule, NextDate);

        IF NextDate = 0D THEN
            EXIT(0DT);

        EXIT(CheckForEndDateTime(RecurrenceSchedule, CREATEDATETIME(NextDate, RecurrenceSchedule."Start Time")));
    end;

    local procedure CalculateDaily(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        NextDate: Date;
    begin
        IF LastOccurrence = 0D THEN
            NextDate := RecurrenceSchedule."Start Date"
        ELSE
            NextDate := LastOccurrence + RecurrenceSchedule."Recurs Every";

        EXIT(NextDate);
    end;

    local procedure CalculateWeekly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        NextWeekDay: Integer;
        NextDate: Date;
        NextWeekDayDateFormulaLbl: Label '<-CW+%1D>', Comment = '%1 - Next week day in integer', Locked = true;
        NextWeekDayDateFormulaPassedLbl: Label '<-CW+%1D+%2W>', Comment = 'If the weekday has passed, this formula is used instead. %1 - Next week day in integer, %2 - Occurs every number of weeks', Locked = true;
    begin
        IF (RecurrenceSchedule."Start Date" = 0D) OR (NOT AnyWeekDaysSelected(RecurrenceSchedule)) THEN
            EXIT(0D);

        IF LastOccurrence = 0D THEN BEGIN
            LastOccurrence := RecurrenceSchedule."Start Date";
            NextWeekDay := GetNextWeekDay(RecurrenceSchedule, DATE2DWY(LastOccurrence, 1) - 1)
        END ELSE
            NextWeekDay := GetNextWeekDay(RecurrenceSchedule, DATE2DWY(LastOccurrence, 1));

        IF NextWeekDay > 0 THEN
            NextDate := CALCDATE(STRSUBSTNO(NextWeekDayDateFormulaLbl, NextWeekDay - 1), LastOccurrence)
        ELSE
            NextDate := CALCDATE(STRSUBSTNO(NextWeekDayDateFormulaPassedLbl, GetNextWeekDay(RecurrenceSchedule, 0) - 1, RecurrenceSchedule."Recurs Every"), LastOccurrence);

        EXIT(NextDate);
    end;

    local procedure AnyWeekDaysSelected(RecurrenceSchedule: Record "Recurrence Schedule"): Boolean
    begin
        WITH RecurrenceSchedule DO
            EXIT(
              "Recurs on Monday" OR
              "Recurs on Tuesday" OR
              "Recurs on Wednesday" OR
              "Recurs on Thursday" OR
              "Recurs on Friday" OR
              "Recurs on Saturday" OR
              "Recurs on Sunday");
    end;

    local procedure GetNextWeekDay(RecurrenceSchedule: Record "Recurrence Schedule"; CurrentWeekDay: Integer): Integer
    begin
        if CurrentWeekDay < 0 then
            CurrentWeekDay := 0;

        REPEAT
            CASE CurrentWeekDay OF
                0:
                    IF RecurrenceSchedule."Recurs on Monday" THEN
                        EXIT(CurrentWeekDay + 1);
                1:
                    IF RecurrenceSchedule."Recurs on Tuesday" THEN
                        EXIT(CurrentWeekDay + 1);
                2:
                    IF RecurrenceSchedule."Recurs on Wednesday" THEN
                        EXIT(CurrentWeekDay + 1);
                3:
                    IF RecurrenceSchedule."Recurs on Thursday" THEN
                        EXIT(CurrentWeekDay + 1);
                4:
                    IF RecurrenceSchedule."Recurs on Friday" THEN
                        EXIT(CurrentWeekDay + 1);
                5:
                    IF RecurrenceSchedule."Recurs on Saturday" THEN
                        EXIT(CurrentWeekDay + 1);
                6:
                    IF RecurrenceSchedule."Recurs on Sunday" THEN
                        EXIT(CurrentWeekDay + 1);
            END;
            CurrentWeekDay += 1;
        UNTIL CurrentWeekDay >= 7;

        EXIT(0);
    end;

    local procedure CalculateMonthly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        MonthlyPattern: Enum "Recurrence - Monthly Pattern";
        MonthlySpecificDayFirstTimeDateFormulaLbl: Label '<-CM+%1D>', Comment = '%1 - Occurence day', Locked = true;
        MonthlySpecificDayDateFormulaLbl: Label '<-CM+%1M+%2D>', Comment = '%1 - occurs every number of months, %2 - Occurence day', Locked = true;
        MonthlyByWeekdayDateFormulaLbl: Label '<-CM+%1M>', Comment = '%1 - Occurs every number of months', Locked = true;
    begin
        IF LastOccurrence = 0D THEN BEGIN
            CASE RecurrenceSchedule."Monthly Pattern" OF
                MonthlyPattern::"By Weekday":
                    EXIT(CalculateMonthlyByWeekDay(RecurrenceSchedule, RecurrenceSchedule."Start Date"));
                MonthlyPattern::"Specific Day":
                    IF DATE2DMY(RecurrenceSchedule."Start Date", 1) <= RecurrenceSchedule."Recurs on Day" THEN
                        EXIT(CALCDATE(STRSUBSTNO(MonthlySpecificDayFirstTimeDateFormulaLbl, RecurrenceSchedule."Recurs on Day" - 1), RecurrenceSchedule."Start Date"));
            END;

            LastOccurrence := RecurrenceSchedule."Start Date";
        END;

        CASE RecurrenceSchedule."Monthly Pattern" OF
            MonthlyPattern::"By Weekday":
                EXIT(CalculateMonthlyByWeekDay(RecurrenceSchedule, CALCDATE(STRSUBSTNO(MonthlyByWeekdayDateFormulaLbl, RecurrenceSchedule."Recurs Every"), LastOccurrence)));
            MonthlyPattern::"Specific Day":
                EXIT(CALCDATE(STRSUBSTNO(MonthlySpecificDayDateFormulaLbl, RecurrenceSchedule."Recurs Every", RecurrenceSchedule."Recurs on Day" - 1), LastOccurrence));
        END
    end;

    local procedure CalculateMonthlyByWeekDay(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        DayOfWeek: Enum "Recurrence - Day of Week";
    begin
        CASE RecurrenceSchedule.Weekday OF
            DayOfWeek::Day:
                EXIT(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Monday.AsInteger(), DayOfWeek::Sunday.AsInteger()));
            DayOfWeek::Weekday:
                EXIT(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Monday.AsInteger(), DayOfWeek::Friday.AsInteger()));
            DayOfWeek::"Weekend day":
                EXIT(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Saturday.AsInteger(), DayOfWeek::Sunday.AsInteger()))
            ELSE
                EXIT(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.",
                    RecurrenceSchedule.Weekday.AsInteger(), RecurrenceSchedule.Weekday.AsInteger()))
        END;
    end;

    local procedure FindDayInMonth(CurrDate: Date; WhatToFind: Enum "Recurrence - Ordinal No."; StartWeekDay: Integer; EndWeekDay: Integer): Date
    var
        DatesInMonth: Record Date;
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
    begin
        DatesInMonth.SETRANGE("Period Type", DatesInMonth."Period Type"::Date);
        DatesInMonth.SETRANGE("Period Start", CALCDATE('<-CM>', CurrDate), CALCDATE('<+CM>', CurrDate));
        DatesInMonth.SETRANGE("Period No.", StartWeekDay, EndWeekDay);

        IF WhatToFind = RecurrenceOrdinalNo::Last THEN BEGIN
            DatesInMonth.FINDLAST();
            EXIT(DatesInMonth."Period Start");
        END;

        DatesInMonth.FindSet();
        IF WhatToFind = RecurrenceOrdinalNo::First THEN
            EXIT(DatesInMonth."Period Start");

        DatesInMonth.Next(WhatToFind.AsInteger());
        EXIT(DatesInMonth."Period Start");
    end;

    local procedure CalculateYearly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        MonthlyPattern: Enum "Recurrence - Monthly Pattern";
        WeekdayDateFormulaTxt: Label '<-CM+%1Y>', comment = '%1 - Number of years', Locked = true;
        SpecificDateDateFormulaTxt: Label '<-CM+%1Y+%2D>', Comment = '%1 - Number of years, %2 - Number of days', Locked = true;
    begin
        IF LastOccurrence = 0D THEN
            CASE RecurrenceSchedule."Monthly Pattern" OF
                MonthlyPattern::"By Weekday":
                    EXIT(CalculateMonthlyByWeekDay(RecurrenceSchedule, DMY2DATE(1, RecurrenceSchedule.Month.AsInteger(), DATE2DMY(RecurrenceSchedule."Start Date", 3))));
                MonthlyPattern::"Specific Day":
                    EXIT(DMY2DATE(RecurrenceSchedule."Recurs on Day", RecurrenceSchedule.Month.AsInteger(), Date2DMY(RecurrenceSchedule."Start Date", 3)));
            END;

        CASE RecurrenceSchedule."Monthly Pattern" OF
            MonthlyPattern::"By Weekday":
                EXIT(CalculateMonthlyByWeekDay(RecurrenceSchedule, CALCDATE(STRSUBSTNO(WeekdayDateFormulaTxt, RecurrenceSchedule."Recurs Every"), LastOccurrence)));
            MonthlyPattern::"Specific Day":
                EXIT(CALCDATE(STRSUBSTNO(SpecificDateDateFormulaTxt, RecurrenceSchedule."Recurs Every", RecurrenceSchedule."Recurs on Day" - 1), LastOccurrence));
        END;
    end;

    local procedure CheckForEndDateTime(RecurrenceSchedule: Record "Recurrence Schedule"; PlannedDateTime: DateTime): DateTime
    begin
        IF RecurrenceSchedule."End Date" <> 0D THEN
            IF PlannedDateTime > CREATEDATETIME(RecurrenceSchedule."End Date", RecurrenceSchedule."Start Time") THEN
                EXIT(0DT);

        EXIT(PlannedDateTime);
    end;

    procedure CreateDaily(StartTime: Time; StartDate: Date; EndDate: Date; DaysBetween: Integer): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Daily;
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := DaysBetween;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure CreateWeekly(StartTime: Time; StartDate: Date; EndDate: Date; WeeksBetween: Integer; Monday: Boolean; Tuesday: Boolean; Wednesday: Boolean; Thursday: Boolean; Friday: Boolean; Saturday: Boolean; Sunday: Boolean): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Weekly;
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := WeeksBetween;
        RecurrenceSchedule."Recurs on Monday" := Monday;
        RecurrenceSchedule."Recurs on Tuesday" := Tuesday;
        RecurrenceSchedule."Recurs on Wednesday" := Wednesday;
        RecurrenceSchedule."Recurs on Thursday" := Thursday;
        RecurrenceSchedule."Recurs on Friday" := Friday;
        RecurrenceSchedule."Recurs on Saturday" := Saturday;
        RecurrenceSchedule."Recurs on Sunday" := Sunday;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure CreateMonthlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; DayOfMonth: Integer): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Monthly;
        RecurrenceSchedule."Monthly Pattern" := RecurrenceMonthlyPattern::"Specific Day";
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := MonthsBetween;
        RecurrenceSchedule."Recurs on Day" := DayOfMonth;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure CreateMonthlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; MonthsBetween: Integer; InWeek: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Monthly;
        RecurrenceSchedule."Monthly Pattern" := RecurrenceMonthlyPattern::"By Weekday";
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := MonthsBetween;
        RecurrenceSchedule."Ordinal Recurrence No." := InWeek;
        RecurrenceSchedule.Weekday := DayOfWeek;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure CreateYearlyByDay(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; DayOfMonth: Integer; Month: Enum "Recurrence - Month"): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Yearly;
        RecurrenceSchedule."Monthly Pattern" := RecurrenceMonthlyPattern::"Specific Day";
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := YearsBetween;
        RecurrenceSchedule."Recurs on Day" := DayOfMonth;
        RecurrenceSchedule.Month := Month;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure CreateYearlyByDayOfWeek(StartTime: Time; StartDate: Date; EndDate: Date; YearsBetween: Integer; OrdinalNumber: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day of Week"; Month: Enum "Recurrence - Month"): Guid
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        RecurrenceMonthlyPattern: Enum "Recurrence - Monthly Pattern";
        RecurrencePattern: Enum "Recurrence - Pattern";
    begin
        RecurrenceSchedule.Pattern := RecurrencePattern::Yearly;
        RecurrenceSchedule."Monthly Pattern" := RecurrenceMonthlyPattern::"By Weekday";
        RecurrenceSchedule."Start Time" := StartTime;
        RecurrenceSchedule."Start Date" := StartDate;
        RecurrenceSchedule."End Date" := EndDate;
        RecurrenceSchedule."Recurs Every" := YearsBetween;
        RecurrenceSchedule."Ordinal Recurrence No." := OrdinalNumber;
        RecurrenceSchedule.Weekday := DayOfWeek;
        RecurrenceSchedule.Month := Month;
        RecurrenceSchedule.INSERT(TRUE);
        EXIT(RecurrenceSchedule.ID);
    end;

    procedure OpenRecurrenceSchedule(var RecurrenceID: Guid)
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        TempRecurrenceSchedule: Record "Recurrence Schedule" temporary;
    begin
        IF NOT ISNULLGUID(RecurrenceID) AND RecurrenceSchedule.GET(RecurrenceID) THEN
            TempRecurrenceSchedule.COPY(RecurrenceSchedule)
        ELSE BEGIN
            TempRecurrenceSchedule."Start Time" := TIME();
            TempRecurrenceSchedule."Start Date" := TODAY();
        END;

        TempRecurrenceSchedule.INSERT();

        IF PAGE.RUNMODAL(PAGE::"Recurrence Schedule Card", TempRecurrenceSchedule) = ACTION::LookupOK THEN BEGIN
            RecurrenceSchedule.COPY(TempRecurrenceSchedule);
            IF ISNULLGUID(RecurrenceID) THEN
                RecurrenceSchedule.INSERT(TRUE)
            ELSE
                RecurrenceSchedule.MODIFY(TRUE);
            RecurrenceID := RecurrenceSchedule.ID;
            EXIT;
        END;

        IF NOT TempRecurrenceSchedule.GET(RecurrenceID) AND RecurrenceSchedule.GET(RecurrenceID) THEN BEGIN
            RecurrenceSchedule.DELETE();
            CLEAR(RecurrenceID);
        END;
    end;

    procedure RecurrenceDisplayText(RecurrenceID: Guid): Text
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
    begin
        IF ISNULLGUID(RecurrenceID) OR NOT RecurrenceSchedule.GET(RecurrenceID) THEN
            EXIT('');

        EXIT(STRSUBSTNO(RecurrenceDisplayTxt, RecurrenceSchedule.Pattern, RecurrenceSchedule."Start Date"));
    end;
}

