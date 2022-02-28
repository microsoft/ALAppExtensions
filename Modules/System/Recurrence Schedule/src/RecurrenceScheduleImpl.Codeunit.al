// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 4691 "Recurrence Schedule Impl."
{
    Access = Internal;
    Permissions = tabledata Date = r,
                  tabledata "Recurrence Schedule" = ri;

    var
        MinDateTime: DateTime;
        MinDateTimeSet: Boolean;
        RecurrenceDisplayTxt: Label 'Recurring %1 starting %2', Comment = '%1 = it recurrence pattern like Daily, Weekly, Monthly..., %2 = The date the recurrence starts';
        RecurrenceMaximumCalculateLimitTxt: Label 'Exceeded maximum calculation limit for recurrence. Change start date to be today.';

    procedure SetMinDateTime(DateTime: DateTime)
    begin
        MinDateTime := DateTime;
        MinDateTimeSet := true;
    end;

    local procedure GetMinDateTime(): DateTime
    begin
        if MinDateTimeSet then
            exit(MinDateTime);
        exit(CurrentDateTime());
    end;

    local procedure IsAfterOrEqualToMinDateTime(RecurrenceSchedule: Record "Recurrence Schedule"; NextDate: Date): Boolean
    begin
        if NextDate = 0D then
            exit(true);
        exit(CreateDateTime(NextDate, RecurrenceSchedule."Start Time") >= GetMinDateTime());
    end;

    procedure CalculateNextOccurrence(RecurrenceID: Guid; LastOccurrence: DateTime): DateTime
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        NextDate: Date;
        Counter: Integer;
    begin
        RecurrenceSchedule.Get(RecurrenceID);
        NextDate := DT2Date(LastOccurrence);

        repeat
            case RecurrenceSchedule.Pattern of
                RecurrenceSchedule.Pattern::Daily:
                    NextDate := CalculateDaily(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Weekly:
                    NextDate := CalculateWeekly(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Monthly:
                    NextDate := CalculateMonthly(RecurrenceSchedule, NextDate);
                RecurrenceSchedule.Pattern::Yearly:
                    NextDate := CalculateYearly(RecurrenceSchedule, NextDate);
            end;

            Counter := Counter + 1;
            if Counter >= 500 then
                Error(RecurrenceMaximumCalculateLimitTxt);
        until IsAfterOrEqualToMinDateTime(RecurrenceSchedule, NextDate);

        if NextDate = 0D then
            exit(0DT);

        exit(CheckForEndDateTime(RecurrenceSchedule, CREATEDATETIME(NextDate, RecurrenceSchedule."Start Time")));
    end;

    local procedure CalculateDaily(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        NextDate: Date;
    begin
        if LastOccurrence = 0D then
            NextDate := RecurrenceSchedule."Start Date"
        else
            NextDate := LastOccurrence + RecurrenceSchedule."Recurs Every";

        exit(NextDate);
    end;

    local procedure CalculateWeekly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        NextWeekDay: Integer;
        NextDate: Date;
        NextWeekDayDateFormulaLbl: Label '<-CW+%1D>', Comment = '%1 - Next week day in integer', Locked = true;
        NextWeekDayDateFormulaPassedLbl: Label '<-CW+%1D+%2W>', Comment = 'If the weekday has passed, this formula is used instead. %1 - Next week day in integer, %2 - Occurs every number of weeks', Locked = true;
    begin
        if (RecurrenceSchedule."Start Date" = 0D) or (not AnyWeekDaysSelected(RecurrenceSchedule)) then
            exit(0D);

        if LastOccurrence = 0D then begin
            LastOccurrence := RecurrenceSchedule."Start Date";
            NextWeekDay := GetNextWeekDay(RecurrenceSchedule, DATE2DWY(LastOccurrence, 1) - 1)
        end else
            NextWeekDay := GetNextWeekDay(RecurrenceSchedule, DATE2DWY(LastOccurrence, 1));

        if NextWeekDay > 0 then
            NextDate := CalcDate(StrSubstNo(NextWeekDayDateFormulaLbl, NextWeekDay - 1), LastOccurrence)
        else
            NextDate := CalcDate(StrSubstNo(NextWeekDayDateFormulaPassedLbl, GetNextWeekDay(RecurrenceSchedule, 0) - 1, RecurrenceSchedule."Recurs Every"), LastOccurrence);

        exit(NextDate);
    end;

    local procedure AnyWeekDaysSelected(RecurrenceSchedule: Record "Recurrence Schedule"): Boolean
    begin
        with RecurrenceSchedule do
            exit(
              "Recurs on Monday" or
              "Recurs on Tuesday" or
              "Recurs on Wednesday" or
              "Recurs on Thursday" or
              "Recurs on Friday" or
              "Recurs on Saturday" or
              "Recurs on Sunday");
    end;

    local procedure GetNextWeekDay(RecurrenceSchedule: Record "Recurrence Schedule"; CurrentWeekDay: Integer): Integer
    begin
        if CurrentWeekDay < 0 then
            CurrentWeekDay := 0;

        REPEAT
            case CurrentWeekDay of
                0:
                    if RecurrenceSchedule."Recurs on Monday" then
                        exit(CurrentWeekDay + 1);
                1:
                    if RecurrenceSchedule."Recurs on Tuesday" then
                        exit(CurrentWeekDay + 1);
                2:
                    if RecurrenceSchedule."Recurs on Wednesday" then
                        exit(CurrentWeekDay + 1);
                3:
                    if RecurrenceSchedule."Recurs on Thursday" then
                        exit(CurrentWeekDay + 1);
                4:
                    if RecurrenceSchedule."Recurs on Friday" then
                        exit(CurrentWeekDay + 1);
                5:
                    if RecurrenceSchedule."Recurs on Saturday" then
                        exit(CurrentWeekDay + 1);
                6:
                    if RecurrenceSchedule."Recurs on Sunday" then
                        exit(CurrentWeekDay + 1);
            end;
            CurrentWeekDay += 1;
        until CurrentWeekDay >= 7;

        exit(0);
    end;

    local procedure CalculateMonthly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        MonthlyPattern: Enum "Recurrence - Monthly Pattern";
        MonthlySpecificDayFirstTimeDateFormulaLbl: Label '<-CM+%1D>', Comment = '%1 - Occurence day', Locked = true;
        MonthlySpecificDayDateFormulaLbl: Label '<-CM+%1M+%2D>', Comment = '%1 - occurs every number of months, %2 - Occurence day', Locked = true;
        MonthlyByWeekdayDateFormulaLbl: Label '<-CM+%1M>', Comment = '%1 - Occurs every number of months', Locked = true;
    begin
        if LastOccurrence = 0D then begin
            case RecurrenceSchedule."Monthly Pattern" of
                MonthlyPattern::"By Weekday":
                    exit(CalculateMonthlyByWeekDay(RecurrenceSchedule, RecurrenceSchedule."Start Date"));
                MonthlyPattern::"Specific Day":
                    if Date2DMY(RecurrenceSchedule."Start Date", 1) <= RecurrenceSchedule."Recurs on Day" then
                        exit(CalcDate(StrSubstNo(MonthlySpecificDayFirstTimeDateFormulaLbl, RecurrenceSchedule."Recurs on Day" - 1), RecurrenceSchedule."Start Date"));
            end;

            LastOccurrence := RecurrenceSchedule."Start Date";
        end;

        case RecurrenceSchedule."Monthly Pattern" of
            MonthlyPattern::"By Weekday":
                exit(CalculateMonthlyByWeekDay(RecurrenceSchedule, CalcDate(StrSubstNo(MonthlyByWeekdayDateFormulaLbl, RecurrenceSchedule."Recurs Every"), LastOccurrence)));
            MonthlyPattern::"Specific Day":
                exit(CalcDate(StrSubstNo(MonthlySpecificDayDateFormulaLbl, RecurrenceSchedule."Recurs Every", RecurrenceSchedule."Recurs on Day" - 1), LastOccurrence));
        end
    end;

    local procedure CalculateMonthlyByWeekDay(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        DayOfWeek: Enum "Recurrence - Day of Week";
    begin
        case RecurrenceSchedule.Weekday of
            DayOfWeek::Day:
                exit(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Monday.AsInteger(), DayOfWeek::Sunday.AsInteger()));
            DayOfWeek::Weekday:
                exit(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Monday.AsInteger(), DayOfWeek::Friday.AsInteger()));
            DayOfWeek::"Weekend day":
                exit(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.", DayOfWeek::Saturday.AsInteger(), DayOfWeek::Sunday.AsInteger()))
            else
                exit(FindDayInMonth(LastOccurrence, RecurrenceSchedule."Ordinal Recurrence No.",
                    RecurrenceSchedule.Weekday.AsInteger(), RecurrenceSchedule.Weekday.AsInteger()))
        end;
    end;

    local procedure FindDayInMonth(CurrDate: Date; WhatToFind: Enum "Recurrence - Ordinal No."; StartWeekDay: Integer; EndWeekDay: Integer): Date
    var
        DatesInMonth: Record Date;
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
    begin
        DatesInMonth.SetRange("Period Type", DatesInMonth."Period Type"::Date);
        DatesInMonth.SetRange("Period Start", CalcDate('<-CM>', CurrDate), CalcDate('<+CM>', CurrDate));
#pragma warning disable AA0210
        DatesInMonth.SetRange("Period No.", StartWeekDay, EndWeekDay);
#pragma warning restore AA0210

        if WhatToFind = RecurrenceOrdinalNo::Last then begin
            DatesInMonth.FindLast();
            exit(DatesInMonth."Period Start");
        end;

        DatesInMonth.FindSet();
        if WhatToFind = RecurrenceOrdinalNo::First then
            exit(DatesInMonth."Period Start");

        DatesInMonth.Next(WhatToFind.AsInteger());
        exit(DatesInMonth."Period Start");
    end;

    local procedure CalculateYearly(RecurrenceSchedule: Record "Recurrence Schedule"; LastOccurrence: Date): Date
    var
        MonthlyPattern: Enum "Recurrence - Monthly Pattern";
        WeekdayDateFormulaTxt: Label '<-CM+%1Y>', comment = '%1 - Number of years', Locked = true;
        SpecificDateDateFormulaTxt: Label '<-CM+%1Y+%2D>', Comment = '%1 - Number of years, %2 - Number of days', Locked = true;
    begin
        if LastOccurrence = 0D then
            case RecurrenceSchedule."Monthly Pattern" of
                MonthlyPattern::"By Weekday":
                    exit(CalculateMonthlyByWeekDay(RecurrenceSchedule, DMY2DATE(1, RecurrenceSchedule.Month.AsInteger(), Date2DMY(RecurrenceSchedule."Start Date", 3))));
                MonthlyPattern::"Specific Day":
                    exit(DMY2DATE(RecurrenceSchedule."Recurs on Day", RecurrenceSchedule.Month.AsInteger(), Date2DMY(RecurrenceSchedule."Start Date", 3)));
            end;

        case RecurrenceSchedule."Monthly Pattern" of
            MonthlyPattern::"By Weekday":
                exit(CalculateMonthlyByWeekDay(RecurrenceSchedule, CalcDate(StrSubstNo(WeekdayDateFormulaTxt, RecurrenceSchedule."Recurs Every"), LastOccurrence)));
            MonthlyPattern::"Specific Day":
                exit(CalcDate(StrSubstNo(SpecificDateDateFormulaTxt, RecurrenceSchedule."Recurs Every", RecurrenceSchedule."Recurs on Day" - 1), LastOccurrence));
        end;
    end;

    local procedure CheckForEndDateTime(RecurrenceSchedule: Record "Recurrence Schedule"; PlannedDateTime: DateTime): DateTime
    begin
        if RecurrenceSchedule."End Date" <> 0D then
            if PlannedDateTime > CREATEDATETIME(RecurrenceSchedule."End Date", RecurrenceSchedule."Start Time") then
                exit(0DT);

        exit(PlannedDateTime);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
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
        RecurrenceSchedule.Insert(true);
        exit(RecurrenceSchedule.ID);
    end;

    procedure OpenRecurrenceSchedule(var RecurrenceID: Guid)
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
        TempRecurrenceSchedule: Record "Recurrence Schedule" temporary;
    begin
        if not IsNullGuid(RecurrenceID) and RecurrenceSchedule.Get(RecurrenceID) then
            TempRecurrenceSchedule.Copy(RecurrenceSchedule)
        else begin
            TempRecurrenceSchedule."Start Time" := Time();
            TempRecurrenceSchedule."Start Date" := Today();
        end;

        TempRecurrenceSchedule.Insert();

        if Page.RunModal(Page::"Recurrence Schedule Card", TempRecurrenceSchedule) = Action::LookupOK then begin
            RecurrenceSchedule.Copy(TempRecurrenceSchedule);
            if IsNullGuid(RecurrenceID) then
                RecurrenceSchedule.Insert(true)
            else
#pragma warning disable AA0214
                RecurrenceSchedule.Modify(true);
#pragma warning restore            
            RecurrenceID := RecurrenceSchedule.ID;
            exit;
        end;

        if not TempRecurrenceSchedule.Get(RecurrenceID) and RecurrenceSchedule.Get(RecurrenceID) then begin
            RecurrenceSchedule.Delete();
            Clear(RecurrenceID);
        end;
    end;

    procedure RecurrenceDisplayText(RecurrenceID: Guid): Text
    var
        RecurrenceSchedule: Record "Recurrence Schedule";
    begin
        if IsNullGuid(RecurrenceID) or not RecurrenceSchedule.Get(RecurrenceID) then
            exit('');

        exit(StrSubstNo(RecurrenceDisplayTxt, RecurrenceSchedule.Pattern, RecurrenceSchedule."Start Date"));
    end;
}

