// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 134691 "Recurrence Schedule Test"
{
    Subtype = Test;

    trigger OnRun()
    begin
    end;

    var
        Assert: Codeunit "Library Assert";
        Any: Codeunit Any;
        PermissionsMock: Codeunit "Permissions Mock";

    [Test]
    [Scope('OnPrem')]
    procedure TestMissingRecurrenceError()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
    begin
        // [SCENARIO] Proper Error when Recurance is missing.
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A missing Recurrence
        // [WHEN] Next occurrence is calculated with the first occurrence as last
        ASSERTERROR RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);

        // [THEN] Next occurrence is equal to start time and start date + 1
        Assert.ExpectedMessage('The Recurrence Schedule does not exist', GetLastErrorText());
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyFutureStartDateNoEndDate1D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with a start date in the future and without an end date
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the future
        StartTime := RandTime();
        StartDay := Today() + 5;
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay - 5, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, 0D, 1);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 1
        Assert.AreEqual(CREATEDATETIME(StartDay + 1, StartTime), NextOccurrence, 'No. 2 Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyFutureStartDateAndEndDate1D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with a start date in the future and an end date
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the future
        StartTime := RandTime();
        StartDay := Today() + 5;
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay - 5, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 1, 1);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 1
        Assert.AreEqual(CREATEDATETIME(StartDay + 1, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyPresentStartDate1D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with today as start date and an end date. Recurs everyday
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the today
        StartTime := RandTime();
        StartDay := Today();
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 2, 1);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyPresentStartDate2D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with today as start date and an end date. Recurs every other day
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the today
        StartTime := RandTime();
        StartDay := Today();
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 4, 2);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 2
        Assert.AreEqual(CREATEDATETIME(StartDay + 2, StartTime), NextOccurrence, 'No. 2 Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyPresentStartDate123D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with today as start date and an end date. Recurs every 123 days
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the today
        StartTime := RandTime();
        StartDay := Today();
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 500, 223);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 223
        Assert.AreEqual(CREATEDATETIME(StartDay + 223, StartTime), NextOccurrence, 'No. 2 Day');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 446
        Assert.AreEqual(CREATEDATETIME(StartDay + 446, StartTime), NextOccurrence, 'No. 3 Day');

        // [WHEN] Next occurrence is calculated with the fourth occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyPastStartDateTime1D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with 10 days before today as start date and an end date. Recurs every day
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date in the past
        StartTime := RandTime();
        StartDay := Today() - 10;
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay + 10, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 11, 1);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to today, because the start date is in the past
        Assert.AreEqual(CREATEDATETIME(StartDay + 10, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to today + 1
        Assert.AreEqual(CREATEDATETIME(StartDay + 11, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestDailyPastStartDateTime21D()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Get the next few daily recurrences with 10 days before today as start date and an end date. Recurs every 21 days
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := Today() - 10;
        // [GIVEN] A we are running now
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay + 10, StartTime));

        // [WHEN] Create daily recurrence
        RecurrenceID := RecurrenceSchedule.CreateDaily(StartTime, StartDay, StartDay + 43, 21);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to today + 11, because the start date is in the past
        Assert.AreEqual(CREATEDATETIME(StartDay + 21, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to today + 32, because the start date is in the past
        Assert.AreEqual(CREATEDATETIME(StartDay + 42, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyNoTimeAndNoDatesAndDaysWillNotRun()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence with no time, date or days and calculate next occurrence.
        PermissionsMock.Set('Recurrence View');

        // [WHEN] Create weekly recurrence no date and time
        RecurrenceID := RecurrenceSchedule.CreateWeekly(0T, 0D, 0D, 0, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal empty DateTime
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyTimeAndNoDatesAndDaysWillNotRun()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence with start time but no date or days and calculate next occurrence
        PermissionsMock.Set('Recurrence View');

        // [WHEN] Create weekly recurrence no date
        RecurrenceID := RecurrenceSchedule.CreateWeekly(Time(), 0D, 0D, 0, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal empty DateTime
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyTimeAndDatesAndNoDaysWillNotRun()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence with start time, date and end date but no days and calculate next occurrence
        PermissionsMock.Set('Recurrence View');

        // [WHEN] Create weekly recurrence no days
        RecurrenceID := RecurrenceSchedule.CreateWeekly(Time(), Today(), Today() + 10, 1, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal empty DateTime
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMonday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(1);
        // [GIVEN] A we are running Monday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Monday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 7, 1, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 7
        Assert.AreEqual(CREATEDATETIME(StartDay + 7, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMondaySunday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday and Sunday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date tuesday
        StartTime := RandTime();
        StartDay := DWY2DATE(2);
        // [GIVEN] A we are running Tuesday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Tuesday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 7, 1, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date + 5
        Assert.AreEqual(CREATEDATETIME(StartDay + 5, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 6
        Assert.AreEqual(CREATEDATETIME(StartDay + 6, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMondaySundayStartDayInPast()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday and Sunday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date tuesday
        StartTime := RandTime();
        StartDay := DWY2DATE(2);
        // [GIVEN] A we are running Tuesday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Tuesday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay - 14, StartDay + 7, 1, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, TRUE);
        // [THEN] A recurrence GUID ID is returned
        Assert.IsFalse(ISNULLGUID(RecurrenceID), 'ID was empty');

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date + 5
        Assert.AreEqual(CREATEDATETIME(StartDay + 5, StartTime), NextOccurrence, 'First Day');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 6
        Assert.AreEqual(CREATEDATETIME(StartDay + 6, StartTime), NextOccurrence, 'Last Day');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMondayWednesDaySundayStartMonday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday, Wednesday and Sunday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(1);
        // [GIVEN] A we are running Monday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Monday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 7, 1, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'Monday');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 2
        Assert.AreEqual(CREATEDATETIME(StartDay + 2, StartTime), NextOccurrence, 'Wednesday');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 6
        Assert.AreEqual(CREATEDATETIME(StartDay + 6, StartTime), NextOccurrence, 'Sunday');

        // [WHEN] Next occurrence is calculated with the third occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 7
        Assert.AreEqual(CREATEDATETIME(StartDay + 7, StartTime), NextOccurrence, 'Monday next week');

        // [WHEN] Next occurrence is calculated with the fourth occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMondayWednesDaySundayStartTuesday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday, Wednesday and Sunday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(2);
        // [GIVEN] A we are running Tuesday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Tuesday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 7, 1, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date + 1
        Assert.AreEqual(CREATEDATETIME(StartDay + 1, StartTime), NextOccurrence, 'Wednesday');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 5
        Assert.AreEqual(CREATEDATETIME(StartDay + 5, StartTime), NextOccurrence, 'Sunday');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 6
        Assert.AreEqual(CREATEDATETIME(StartDay + 6, StartTime), NextOccurrence, 'Monday');

        // [WHEN] Next occurrence is calculated with the third occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyMondayWednesDaySundayStartSunday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday, Wednesday and Sunday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(7);
        // [GIVEN] A we are running Tuesday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Sunday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 7, 1, TRUE, FALSE, TRUE, FALSE, FALSE, FALSE, TRUE);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'Sunday');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 1
        Assert.AreEqual(CREATEDATETIME(StartDay + 1, StartTime), NextOccurrence, 'Monday');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 3
        Assert.AreEqual(CREATEDATETIME(StartDay + 3, StartTime), NextOccurrence, 'Wednesday');

        // [WHEN] Next occurrence is calculated with the third occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 7
        Assert.AreEqual(CREATEDATETIME(StartDay + 7, StartTime), NextOccurrence, 'Sunday next week');

        // [WHEN] Next occurrence is calculated with the fourth occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyEveryThirdMondayStartMonday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(1);
        // [GIVEN] A we are running Monday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Monday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 21, 3, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'Monday');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 21
        Assert.AreEqual(CREATEDATETIME(StartDay + 21, StartTime), NextOccurrence, 'Monday in 3 weeks');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestWeeklyEveryThirdMondayStartTuesday()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a weekly recurrence to repeat weekly on Monday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DWY2DATE(2);
        // [GIVEN] A we are running Tuesday
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create weekly recurrence starting on Tuesday
        RecurrenceID := RecurrenceSchedule.CreateWeekly(StartTime, StartDay, StartDay + 41, 3, TRUE, FALSE, FALSE, FALSE, FALSE, FALSE, FALSE);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date + 20
        Assert.AreEqual(CREATEDATETIME(StartDay + 20, StartTime), NextOccurrence, 'Monday in 3 weeks');

        // [WHEN] Next occurrence is calculated with the first occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal to start time and start date + 41
        Assert.AreEqual(CREATEDATETIME(StartDay + 41, StartTime), NextOccurrence, 'Monday in 6 weeks');

        // [WHEN] Next occurrence is calculated with the second occurrence as last
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is equal empty DateTime as it has ended
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMonthlyByDayFirstInMonthStartDay1()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a monthly recurrence to repeat weekly on Monday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1);
        // [GIVEN] A we are running first day of month
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create monthly recurrence starting on 1th day of the month
        RecurrenceID := RecurrenceSchedule.CreateMonthlyByDay(StartTime, StartDay, StartDay, 1, 1);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and start date
        Assert.AreEqual(CREATEDATETIME(StartDay, StartTime), NextOccurrence, 'First Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMonthlyByDayFirstInMonthStartDay2()
    var
        RecurrenceSchedule: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a monthly recurrence to repeat weekly on Monday and calculate next occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(2, 4);
        // [GIVEN] A we are running 2nd of April
        RecurrenceSchedule.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [WHEN] Create monthly recurrence starting on the 1st of every month
        RecurrenceID := RecurrenceSchedule.CreateMonthlyByDay(StartTime, StartDay, StartDay + 30, 1, 1);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceSchedule.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is equal to start time and 1st of May
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(1, 5), StartTime), NextOccurrence, 'First day next month');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMonthlyByDayOfWeekFirstOccurrenceForward()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
        RecurrenceDayOfWeek: Enum "Recurrence - Day of Week";
        StartTime: Time;
        StartDay: Date;
    begin
        // [SCENARIO] Create a monthly recurrence to with different weak and day  occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] A ordinal recurrence X
        // [GIVEN] A weekday Y
        // [WHEN] When calculating next occurrence
        // [THEN] Date = Z
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Weekday, DMY2DATE(1, 5, 2019), 'First Weekday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::"Weekend day", DMY2DATE(4, 5, 2019), 'First Weekend day');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Monday, DMY2DATE(6, 5, 2019), 'First Monday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Tuesday, DMY2DATE(14, 5, 2019), 'Second Tuesday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Saturday, DMY2DATE(11, 5, 2019), 'Second Saturday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Wednesday, DMY2DATE(15, 5, 2019), 'Third Wednesday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Sunday, DMY2DATE(19, 5, 2019), 'Third Sunday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Fourth, RecurrenceDayOfWeek::Friday, DMY2DATE(24, 5, 2019), 'Fourth Friday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Day, DMY2DATE(31, 5, 2019), 'Last Day');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Weekday, DMY2DATE(31, 5, 2019), 'Last Weekday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::"Weekend day", DMY2DATE(26, 5, 2019), 'Last Weekend day');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Friday, DMY2DATE(31, 5, 2019), 'Last Friday');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMonthlyByDayOfWeekFirstOccurrenceWithStartDayInPast()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
        RecurrenceDayOfWeek: Enum "Recurrence - Day of Week";
        StartTime: Time;
        StartDay: Date;
    begin
        // [SCENARIO] Create a monthly recurrence to with different weak and day occurrences where statday is in the past
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);

        // [GIVEN] A ordinal recurrence X
        // [GIVEN] A weekday Y
        // [WHEN] When calculating next occurrence
        // [THEN] Date = Z

        // [GIVEN] We are running 1st of June 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(CALCDATE('<+1M>', StartDay), StartTime));
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Weekday, DMY2DATE(3, 6, 2019), 'First Weekday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 2, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::"Weekend day", DMY2DATE(6, 7, 2019), 'First Weekend day');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 3, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Monday, DMY2DATE(5, 8, 2019), 'First Monday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 4, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Tuesday, DMY2DATE(10, 9, 2019), 'Second Tuesday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 5, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Saturday, DMY2DATE(12, 10, 2019), 'Second Saturday');

        // [GIVEN] We are running 17th of May 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(CALCDATE('<+16D>', StartDay), StartTime));
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 6, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Wednesday, DMY2DATE(20, 11, 2019), 'Third Wednesday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 7, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Sunday, DMY2DATE(19, 5, 2019), 'Third Sunday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 8, RecurrenceOrdinalNo::Fourth, RecurrenceDayOfWeek::Friday, DMY2DATE(24, 5, 2019), 'Fourth Friday');
        SetMonthlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 9, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Day, DMY2DATE(31, 5, 2019), 'Last Day');
    end;

    local procedure SetMonthlyByDayOfWeekAndVerify(Recurrence: Codeunit "Recurrence Schedule"; StartTime: Time; StartDate: Date; MonthsBetween: Integer; OrdinalNumber: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day Of Week"; ExpectedDate: Date; AssertText: Text)
    var
        RecurrenceID: Guid;
        FirstOccurrence: DateTime;
    begin
        RecurrenceID := Recurrence.CreateMonthlyByDayOfWeek(StartTime, StartDate, 0D, MonthsBetween, OrdinalNumber, DayOfWeek);

        FirstOccurrence := Recurrence.CalculateNextOccurrence(RecurrenceID, 0DT);
        Assert.AreEqual(CREATEDATETIME(ExpectedDate, StartTime), FirstOccurrence, AssertText);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestMonthlyByDayOfWeekMultipleOccurrences()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
        RecurrenceDayOfWeek: Enum "Recurrence - Day of Week";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a monthly recurrence that last for a long time
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);

        // [GIVEN] We are running 1st of May 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] Create monthly recurrence starting on the 1st of May 2019 and ends 16 months later
        RecurrenceID :=
          RecurrenceMgt.CreateMonthlyByDayOfWeek(
            StartTime, StartDay, CALCDATE('<+16M>', StartDay), 5, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Tuesday);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(14, 5, 2019), StartTime), NextOccurrence, 'Second Tuesday in May');

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(8, 10, 2019), StartTime), NextOccurrence, 'Second Tuesday 5 months later');

        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(10, 3, 2020), StartTime), NextOccurrence, 'Second Tuesday 10 months later');

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(11, 8, 2020), StartTime), NextOccurrence, 'Second Tuesday 15 months later');

        // [GIVEN] We are running 1st of May 2019
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is 0DT as it expired
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestYearlyByDayFirstInMonthStartDayBeforePlanedDay()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceMonth: Enum "Recurrence - Month";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a yearly recurrence that will start this year
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);

        // [GIVEN] We are running 1st of May 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] Create yearly recurrence at 5th of July
        RecurrenceID := RecurrenceMgt.CreateYearlyByDay(StartTime, StartDay, 0D, 1, 5, RecurrenceMonth::July);

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is this year
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(5, 7, 2019), StartTime), NextOccurrence, 'First Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestYearlyByDayFirstInMonthStartDayAfterPlanedDay()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceMonth: Enum "Recurrence - Month";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a monthly recurrence that will start next year
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);

        // [GIVEN] We are running 1st of May 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] Create yearly recurrence at 5th of March
        RecurrenceID := RecurrenceMgt.CreateYearlyByDay(StartTime, StartDay, 0D, 1, 5, RecurrenceMonth::March);

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is next year
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(5, 3, 2020), StartTime), NextOccurrence, 'First Day');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestYearlyByDayOfWeekFirstOccurrenceForwardAndBackwords()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
        RecurrenceDayOfWeek: Enum "Recurrence - Day of Week";
        RecurrenceMonth: Enum "Recurrence - Month";
        StartTime: Time;
        StartDay: Date;
    begin
        // [SCENARIO] Create a Yearly recurrence to with different weak and day occurrences
        PermissionsMock.Set('Recurrence View');

        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 5, 2019);

        // [GIVEN] A we are running 1st of May 2019
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] A ordinal recurrence X
        // [GIVEN] A weekday Y
        // [WHEN] When calculating next occurrence
        // [THEN] Date = Z
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Weekday, RecurrenceMonth::April, DMY2DATE(1, 4, 2020),
          'First Weekday April next year');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::"Weekend day", RecurrenceMonth::August, DMY2DATE(3, 8, 2019),
          'First Weekend day August');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::First, RecurrenceDayOfWeek::Monday, RecurrenceMonth::December, DMY2DATE(2, 12, 2019),
          'First Monday December');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Tuesday, RecurrenceMonth::February, DMY2DATE(11, 2, 2020),
          'Second Tuesday Febrary next year');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Saturday, RecurrenceMonth::January, DMY2DATE(11, 1, 2020),
          'Second Saturday January next year');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Wednesday, RecurrenceMonth::July, DMY2DATE(17, 7, 2019),
          'Third Wednesday July');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Third, RecurrenceDayOfWeek::Sunday, RecurrenceMonth::June, DMY2DATE(16, 6, 2019), 'Third Sunday June');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Fourth, RecurrenceDayOfWeek::Friday, RecurrenceMonth::March, DMY2DATE(27, 3, 2020),
          'Fourth Friday March next year');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Day, RecurrenceMonth::May, DMY2DATE(31, 5, 2019), 'Last Day May');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Weekday, RecurrenceMonth::November, DMY2DATE(29, 11, 2019),
          'Last Weekday November');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::"Weekend day", RecurrenceMonth::October, DMY2DATE(27, 10, 2019),
          'Last Weekend day Oktober');
        SetYearlyByDayOfWeekAndVerify(
          RecurrenceMgt, StartTime, StartDay, 1, RecurrenceOrdinalNo::Last, RecurrenceDayOfWeek::Friday, RecurrenceMonth::September, DMY2DATE(27, 9, 2019),
          'Last Friday September');
    end;

    local procedure SetYearlyByDayOfWeekAndVerify(Recurrence: Codeunit "Recurrence Schedule"; StartTime: Time; StartDate: Date; YearsBetween: Integer; OrdinalNumber: Enum "Recurrence - Ordinal No."; DayOfWeek: Enum "Recurrence - Day Of Week"; InMonth: Enum "Recurrence - Month"; ExpectedDate: Date; AssertText: Text)
    var
        RecurrenceID: Guid;
        FirstOccurrence: DateTime;
    begin
        RecurrenceID := Recurrence.CreateYearlyByDayOfWeek(StartTime, StartDate, 0D, YearsBetween, OrdinalNumber, DayOfWeek, InMonth);

        FirstOccurrence := Recurrence.CalculateNextOccurrence(RecurrenceID, 0DT);
        Assert.AreEqual(CREATEDATETIME(ExpectedDate, StartTime), FirstOccurrence, AssertText);
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestYearlyByDayOfWeekMultipleOccurrences()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceOrdinalNo: Enum "Recurrence - Ordinal No.";
        RecurrenceDayOfWeek: Enum "Recurrence - Day of Week";
        RecurrenceMonth: Enum "Recurrence - Month";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
    begin
        // [SCENARIO] Create a yearly recurrence that last for a long time
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 6, 2018);

        // [GIVEN] We are running 1st of June 2018
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] A Yearly recurrence starting in 2018
        RecurrenceID :=
          RecurrenceMgt.CreateYearlyByDayOfWeek(
            StartTime, StartDay, CALCDATE('<+11Y>', StartDay), 5, RecurrenceOrdinalNo::Second, RecurrenceDayOfWeek::Tuesday,
            RecurrenceMonth::May);

        // [WHEN] Next occurrence is calculated with no last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, 0DT);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(9, 5, 2023), StartTime), NextOccurrence, 'Second Tuesday in May');

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is returned
        Assert.AreEqual(CREATEDATETIME(DMY2DATE(9, 5, 2028), StartTime), NextOccurrence, 'Second Tuesday May next year');

        // [WHEN] Next occurrence is calculated with last occurrence
        NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
        // [THEN] Next occurrence is returned as 0DT
        Assert.AreEqual(0DT, NextOccurrence, 'No more dates expected');
    end;

    [Test]
    [Scope('OnPrem')]
    procedure TestYearlyFeb31()
    var
        RecurrenceMgt: Codeunit "Recurrence Schedule";
        RecurrenceID: Guid;
        StartTime: Time;
        StartDay: Date;
        NextOccurrence: DateTime;
        Counter: Integer;
    begin
        // [SCENARIO] Create a yearly recurrence that last for a long time
        PermissionsMock.Set('Recurrence View');
        // [GIVEN] A start time and date
        StartTime := RandTime();
        StartDay := DMY2DATE(1, 6, 2018);

        // [GIVEN] We are running 1st of June 2018
        RecurrenceMgt.SetMinDateTime(CREATEDATETIME(StartDay, StartTime));

        // [GIVEN] A Yearly recurrence starting in 2018
        RecurrenceID := RecurrenceMgt.CreateMonthlyByDay(StartTime, StartDay, CalcDate('<+11Y>', StartDay), 1, 31);

        // [WHEN] Next occurrence is calculated with no last occurrence
        repeat
            NextOccurrence := RecurrenceMgt.CalculateNextOccurrence(RecurrenceID, NextOccurrence);
            Counter += 1;
        until NextOccurrence = 0DT;

        // [THEN] The number of occurrences counted 
        Assert.AreEqual(78, Counter, 'It should calculate 78 occurrences which total to 11 years of months with 31 days.');
    end;

    [Scope('OnPrem')]
    procedure RandTime(): Time
    begin
        EXIT(000000T + ROUND(Any.IntegerInRange(235959.999T - 000000T + 1) - 1, 10));
    end;
}

