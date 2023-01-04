codeunit 132979 "Time Zone Management Test"
{
    Subtype = Test;

    var
        PermissionsMock: Codeunit "Permissions Mock";
        TimeZone: Codeunit "Time Zone";
        LibraryAssert: Codeunit "Library Assert";
        IsInitialized: Boolean;

    [Test]
    procedure CalculateUTCOffsetOutsideDaylightSavingTime()
    var
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
        Offset := RequestUTCOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, false));
    end;

    [Test]
    procedure CalculateUTCOffsetInsideDaylightSavingTime()
    var
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
        Offset := RequestUTCOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, true));
    end;

    [Test]
    procedure CalculateUTCOffsetInsideDaylightSavingTimeForNonDSTTimeZone()
    var
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
        Offset := RequestUTCOffset(DateTimeToTest, TimeZoneId);

        // [THEN] UTC offset is correct for selected time zone
        VerifyOffsetIsCorrectForSelectedTimeZone(Offset, GetExpectedOffset(TimeZoneId, true));
    end;

    [Test]
    procedure CalculateOffsetBetweenTwoTimeZones()
    var
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
        Offset := RequestOffsetBetweenTimeZones(DateTimeToTest, SourceTimeZoneId, DestinationTimeZoneId);

        // [THEN] Offset between time zones is correct
        VerifyOffsetBetweenTimeZonesIsCorrect(Offset);
    end;

    [Test]
    procedure CheckDaylightSavingTimeIndicatorForTimeZoneWithDST()
    var
        TimeZoneId: Text;
        SupportsDST: Boolean;
    begin
        // [SCENARIO #0005] Check daylight saving time indicator for time zone with DST
        Initialize();

        // [GIVEN] Time zone that has daylight saving time
        TimeZoneId := CreateTimeZoneThatHasDaylightSavingTime();

        // [WHEN] Check whether time zone supports daylight saving time
        SupportsDST := CheckWhetherTimeZoneSupportsDaylightSavingTime(TimeZoneId);

        // [THEN] Daylight saving time is supported
        VerifyDaylightSavingTimeIsSupported(SupportsDST);
    end;

    [Test]
    procedure CheckDaylightSavingTimeIndicatorForTimeZoneWithoutDST()
    var
        TimeZoneId: Text;
        SupportsDST: Boolean;
    begin
        // [SCENARIO #0006] Check daylight saving time indicator for time zone without DST
        Initialize();

        // [GIVEN] Time zone that does not have daylight saving time
        TimeZoneId := CreateTimeZoneThatDoesNotHaveDaylightSavingTime();

        // [WHEN] Check whether time zone supports daylight saving time
        SupportsDST := CheckWhetherTimeZoneSupportsDaylightSavingTime(TimeZoneId);

        // [THEN] Daylight saving time is not supported
        VerifyDaylightSavingTimeIsNotSupported(SupportsDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsInDST()
    var
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
        DateTimeIsInDST := CheckWhetherDateTimeFallsWithinDSTForTheTimeZone(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as being in DST
        VerifyDateTimeShowsAsBeingInDST(DateTimeIsInDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsNotInDST()
    var
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
        DateTimeIsInDST := CheckWhetherDateTimeFallsWithinDSTForTheTimeZone(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as not being in DST
        VerifyDateTimeShowsAsNotBeingInDST(DateTimeIsInDST);
    end;

    [Test]
    procedure CheckWhetherDateTimeIsInDSTForTimeZoneWithoutDST()
    var
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
        DateTimeIsInDST := CheckWhetherDateTimeFallsWithinDSTForTheTimeZone(DateTimeToTest, TimeZoneId);

        // [THEN] DateTime shows as not being in DST
        VerifyDateTimeShowsAsNotBeingInDST(DateTimeIsInDST);
    end;

    local procedure Initialize()
    begin
        if IsInitialized then
            exit;

        PermissionsMock.Set('TimeZoneMgt-Objects');

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
        exit(CreateDateTime(DMY2Date(26, 12, 2022), 140000T));
    end;

    local procedure CreateDateTimeInsideDaylightSavingTimePeriod(): DateTime
    begin
        exit(CreateDateTime(DMY2Date(2, 6, 2022), 140000T));
    end;

    local procedure RequestUTCOffset(DateTimeToTest: DateTime; TimeZoneId: Text): Duration
    begin
        exit(TimeZone.GetUtcOffset(DateTimeToTest, TimeZoneId));
    end;

    local procedure VerifyOffsetIsCorrectForSelectedTimeZone(Offset: Duration; ExpectedOffsetInHours: Decimal)
    var
        ExpectedOffset: Duration;
        OffsetMismatchErr: Label 'Offset did not match expected offset.', Locked = true;
    begin
        ExpectedOffset := ExpectedOffsetInHours * GetHourConversionFactor();
        LibraryAssert.AreEqual(ExpectedOffset, Offset, OffsetMismatchErr);
    end;

    local procedure VerifyOffsetBetweenTimeZonesIsCorrect(Offset: Duration)
    var
        OffsetMismatchErr: Label 'Offset between time zones did not match expected offset.', Locked = true;
        ExpectedOffset: Duration;
    begin
        ExpectedOffset := -9 * GetHourConversionFactor();
        LibraryAssert.AreEqual(ExpectedOffset, Offset, OffsetMismatchErr);
    end;

    local procedure CheckWhetherTimeZoneSupportsDaylightSavingTime(TimeZoneId: Text): Boolean
    begin
        exit(TimeZone.TimeZoneSupportsDaylightSavingTime(TimeZoneId));
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

    local procedure CheckWhetherDateTimeFallsWithinDSTForTheTimeZone(DateTimeToTest: DateTime; TimeZoneId: Text): Boolean
    begin
        exit(TimeZone.IsDaylightSavingTime(DateTimeToTest, TimeZoneId));
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
    begin
        case TimeZoneId of
            GetTimeZoneIdForNonDSTTimeZone():
                exit(-7);
            GetTimeZoneIdForDSTTimeZone():
                begin
                    if InDaylightSavingPeriod then
                        exit(2);
                    exit(1);
                end;
        end;
    end;

    local procedure GetTimeZoneIdForNonDSTTimeZone(): Text
    begin
        exit('US Mountain Standard Time');
    end;

    local procedure GetTimeZoneIdForDSTTimeZone(): Text
    begin
        exit('W. Europe Standard Time');
    end;

    local procedure GetHourConversionFactor(): Decimal
    begin
        exit(3600000);
    end;

    local procedure RequestOffsetBetweenTimeZones(DateTimeToTest: DateTime; SourceTimeZoneId: Text; DestinationTimeZoneId: Text): Duration
    begin
        exit(TimeZone.GetTimeZoneOffset(DateTimeToTest, SourceTimeZoneId, DestinationTimeZoneId));
    end;
}
