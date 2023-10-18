// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.Test.DateTime;

using System.DateTime;
using System.TestLibraries.Utilities;

codeunit 132979 "Date and Time Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";
        IsInitialized: Boolean;
        DSTTimeZoneData: Dictionary of [Text, Decimal];
        NonDSTTimeZoneData: Dictionary of [Text, Decimal];

    [Test]
    procedure CalculateUTCOffsetOutsideDaylightSavingTime()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        Offset: Duration;
        TimeZoneId: Text;
    begin
        // [SCENARIO #0001] Calculate UTC offset outside daylight saving time
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();
        // [GIVEN]  DateTime outside daylight saving time period
        DateTimeToTest := CreateDateTimeOutsideDaylightSavingTimePeriod();

        // [WHEN] Request UTC offset
        Offset := TimeZone.GetTimeZoneOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, false));
    end;

    [Test]
    procedure CalculateUTCOffsetInsideDaylightSavingTime()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        Offset: Duration;
        TimeZoneId: Text;
    begin
        // [SCENARIO #0002] Calculate UTC offset inside daylight saving time
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();
        // [GIVEN]  DateTime inside daylight saving time period
        DateTimeToTest := CreateDateTimeInsideDaylightSavingTimePeriod();

        // [WHEN] Request UTC offset
        Offset := TimeZone.GetTimeZoneOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, true));
    end;

    [Test]
    procedure CalculateUTCOffsetInsideDaylightSavingTimeForNonDSTTimeZone()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        Offset: Duration;
        TimeZoneId: Text;
    begin
        // [SCENARIO #0003] Calculate UTC offset inside daylight saving time for non-DST time zone
        Initialize();

        // [GIVEN] Time zone that does not have daylight saving time
        TimeZoneId := CreateTimeZoneThatDoesNotHaveDaylightSavingTime();
        // [GIVEN]  DateTime inside daylight saving time period
        DateTimeToTest := CreateDateTimeInsideDaylightSavingTimePeriod();

        // [WHEN] Request UTC offset
        Offset := TimeZone.GetTimeZoneOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, true));
    end;

    [Test]
    procedure CalculateOffsetBetweenTwoTimeZones()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        Offset: Duration;
        SourceTimeZoneId: Text;
        DestinationTimeZoneId: Text;
    begin
        // [SCENARIO #0004] Calculate offset between two time zones
        Initialize();

        // [GIVEN] Source time zone
        SourceTimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();
        // [GIVEN] Destination time zone
        DestinationTimeZoneId := CreateTimeZoneThatDoesNotHaveDaylightSavingTime();
        // [GIVEN]  DateTime inside daylight saving time period
        DateTimeToTest := CreateDateTimeInsideDaylightSavingTimePeriod();

        // [WHEN] Request offset between time zones
        Offset := TimeZone.GetTimeZoneOffset(DateTimeToTest, SourceTimeZoneId, DestinationTimeZoneId);

        // [THEN] Offset between time zones is correct
        VerifyOffsetBetweenTimeZonesIsCorrect(Offset, GetExpectedOffset(SourceTimeZoneId, true), GetExpectedOffset(DestinationTimeZoneId, true));
    end;

    [Test]
    procedure CheckDaylightSavingTimeIndicatorForTimeZoneWithDST()
    var
        TimeZone: Codeunit "Time Zone";
        TimeZoneId: Text;
        SupportsDST: Boolean;
    begin
        // [SCENARIO #0005] Check daylight saving time indicator for time zone with DST
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();

        // [WHEN] Check whether time zone supports daylight saving time
        SupportsDST := TimeZone.TimeZoneSupportsDaylightSavingTime(TimeZoneId);

        // [THEN] Daylight saving time is supported
        VerifyDaylightSavingTimeIsSupported(SupportsDST);
    end;

    [Test]
    procedure CheckDaylightSavingTimeIndicatorForTimeZoneWithoutDST()
    var
        TimeZone: Codeunit "Time Zone";
        TimeZoneId: Text;
        SupportsDST: Boolean;
    begin
        // [SCENARIO #0006] Check daylight saving time indicator for time zone without DST
        Initialize();

        // [GIVEN] Time zone that does not have daylight saving time
        TimeZoneId := CreateTimeZoneThatDoesNotHaveDaylightSavingTime();

        // [WHEN] Check whether time zone supports daylight saving time
        SupportsDST := TimeZone.TimeZoneSupportsDaylightSavingTime(TimeZoneId);

        // [THEN] Daylight saving time is not supported
        VerifyDaylightSavingTimeIsNotSupported(SupportsDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsInDST()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        TimeZoneId: Text;
        DateTimeIsInDST: Boolean;
    begin
        // [SCENARIO #0007] Check whether datetime is in DST
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();
        // [GIVEN] DateTime inside daylight saving time period
        DateTimeToTest := CreateDateTimeInsideDaylightSavingTimePeriod();

        // [WHEN] Check whether datetime falls within DST for the time zone
        DateTimeIsInDST := TimeZone.IsDaylightSavingTime(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as being in DST
        VerifyDateTimeShowsAsBeingInDST(DateTimeIsInDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsNotInDST()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        TimeZoneId: Text;
        DateTimeIsInDST: Boolean;
    begin
        // [SCENARIO #0008] Check whether datetime is not in DST
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();
        // [GIVEN] DateTime outside daylight saving time period
        DateTimeToTest := CreateDateTimeOutsideDaylightSavingTimePeriod();

        // [WHEN] Check whether datetime falls within DST for the time zone
        DateTimeIsInDST := TimeZone.IsDaylightSavingTime(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as not being in DST
        VerifyDateTimeShowsAsNotBeingInDST(DateTimeIsInDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsInDSTForTimeZoneWithoutDST()
    var
        TimeZone: Codeunit "Time Zone";
        DateTimeToTest: DateTime;
        TimeZoneId: Text;
        DateTimeIsInDST: Boolean;
    begin
        // [SCENARIO #0009] Check whether datetime is in DST for time zone without DST
        Initialize();

        // [GIVEN] Time zone that does not have daylight saving time
        TimeZoneId := CreateTimeZoneThatDoesNotHaveDaylightSavingTime();
        // [GIVEN] DateTime inside daylight saving time period
        DateTimeToTest := CreateDateTimeInsideDaylightSavingTimePeriod();

        // [WHEN] Check whether datetime falls within DST for the time zone
        DateTimeIsInDST := TimeZone.IsDaylightSavingTime(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as not being in DST
        VerifyDateTimeShowsAsNotBeingInDST(DateTimeIsInDST);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        InitTimeZoneDictionaries();

        IsInitialized := true;
        Commit();
    end;

    local procedure CreateTimeZoneThatHasDaylightSavingTime(): Text
    begin
        exit(GetTimeZoneIdForDSTTimeZone());
    end;

    local procedure CreateTimeZoneThatDoesNotHaveDaylightSavingTime(): Text
    begin
        exit(GetTimeZoneIdForNonDSTTimeZone());
    end;

    local procedure CreateDateTimeOutsideDaylightSavingTimePeriod(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(26, 12, Date2DMY(Today(), 3)), 140000T));
    end;

    local procedure CreateDateTimeInsideDaylightSavingTimePeriod(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(2, 6, Date2DMY(Today(), 3)), 140000T));
    end;

    local procedure VerifyOffsetIsCorrectForSelectedTimeZone(Offset: Duration; ExpectedOffsetInHours: Decimal)
    var
        ExpectedOffset: Duration;
        OffsetMismatchErr: Label 'Offset did not match expected offset.', Locked = true;
    begin
        ExpectedOffset := ExpectedOffsetInHours * GetHourConversionFactor();
        LibraryAssert.AreEqual(ExpectedOffset, Offset, OffsetMismatchErr);
    end;

    local procedure VerifyOffsetBetweenTimeZonesIsCorrect(Offset: Duration; SourceUTCOffset: Decimal; DestinationUTCOffset: Decimal)
    var
        OffsetMismatchErr: Label 'Offset between time zones did not match expected offset.', Locked = true;
        ExpectedOffset: Duration;
    begin
        ExpectedOffset := (DestinationUTCOffset - SourceUTCOffset) * GetHourConversionFactor();
        LibraryAssert.AreEqual(ExpectedOffset, Offset, OffsetMismatchErr);
    end;

    local procedure VerifyDaylightSavingTimeIsNotSupported(SupportsDST: Boolean)
    var
        IncorrectDSTSupportErr: Label 'Time zone was not expected to support daylight saving time.', Locked = true;
    begin
        LibraryAssert.IsFalse(SupportsDST, IncorrectDSTSupportErr);
    end;

    local procedure VerifyDaylightSavingTimeIsSupported(SupportsDST: Boolean)
    var
        IncorrectDSTSupportErr: Label 'Time zone was expected to support daylight saving time.', Locked = true;
    begin
        LibraryAssert.IsTrue(SupportsDST, IncorrectDSTSupportErr);
    end;

    local procedure VerifyDateTimeShowsAsBeingInDST(DateTimeIsInDST: Boolean)
    var
        IncorrectDSTSupportErr: Label 'DateTime was expected to show as being in daylight saving time.', Locked = true;
    begin
        LibraryAssert.IsTrue(DateTimeIsInDST, IncorrectDSTSupportErr);
    end;

    local procedure VerifyDateTimeShowsAsNotBeingInDST(DateTimeIsInDST: Boolean)
    var
        IncorrectDSTSupportErr: Label 'DateTime was not expected to show as being in daylight saving time.', Locked = true;
    begin
        LibraryAssert.IsFalse(DateTimeIsInDST, IncorrectDSTSupportErr);
    end;

    local procedure GetExpectedOffset(TimeZoneId: Text; InDaylightSavingPeriod: Boolean): Decimal
    var
        BaseOffset: Decimal;
        IsDSTTimeZone: Boolean;
    begin
        IsDSTTimeZone := DSTTimeZoneData.Get(TimeZoneId, BaseOffset);
        if not IsDSTTimeZone then
            BaseOffset := NonDSTTimeZoneData.Get(TimeZoneId);

        if IsDSTTimeZone then
            if InDaylightSavingPeriod then
                exit(BaseOffset + 1);
        exit(BaseOffset);
    end;

    local procedure GetTimeZoneIdForNonDSTTimeZone(): Text
    var
        Index: Integer;
        SelectedTimeZone: Text;
    begin
        Index := GetRandomDictionaryIndex(NonDSTTimeZoneData.Count());
        SelectedTimeZone := NonDSTTimeZoneData.Keys.Get(Index);
        exit(SelectedTimeZone);
    end;

    local procedure GetTimeZoneIdForDSTTimeZone(): Text
    var
        Index: Integer;
        SelectedTimeZone: Text;
    begin
        Index := GetRandomDictionaryIndex(DSTTimeZoneData.Count());
        SelectedTimeZone := DSTTimeZoneData.Keys.Get(Index);
        exit(SelectedTimeZone);
    end;

    local procedure GetHourConversionFactor(): Decimal
    begin
        exit(3600000);
    end;

    local procedure InitTimeZoneDictionaries()
    begin
        InitDSTTimeZoneData();
        InitNonDSTTimeZoneData();
    end;

    local procedure InitDSTTimeZoneData()
    begin
        Clear(DSTTimeZoneData);

        //Dictionary of time zones that use DST with their base UTC offsets
        DSTTimeZoneData.Add('Mountain Standard Time', -7);
        DSTTimeZoneData.Add('W. Europe Standard Time', 1);
        DSTTimeZoneData.Add('Russian Standard Time', 3);
        DSTTimeZoneData.Add('Tasmania Standard Time', 8);
    end;

    local procedure InitNonDSTTimeZoneData()
    begin
        //Dictionary of time zones that do not use with their base UTC offsets
        NonDSTTimeZoneData.Add('Hawaiian Standard Time', -10);
        NonDSTTimeZoneData.Add('US Mountain Standard Time', -7);
        NonDSTTimeZoneData.Add('W. Central Africa Standard Time', 1);
        NonDSTTimeZoneData.Add('China Standard Time', 8);
    end;

    local procedure GetRandomDictionaryIndex(DictionaryLength: Integer): Integer
    var
        Any: Codeunit Any;
    begin
        exit(Any.IntegerInRange(1, DictionaryLength));
    end;
}
