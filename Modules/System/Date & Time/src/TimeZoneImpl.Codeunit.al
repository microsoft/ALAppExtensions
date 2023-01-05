// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8721 "Time Zone Impl."
{
    Access = Internal;

    var
        TimeZoneInfoInitializer: Codeunit "Time Zone Info Initializer";
        TimeZoneInfoDotNet: DotNet TimeZoneInfo;

    procedure GetUtcOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    var
        TimeZoneInfoInitializer: Codeunit "Time Zone Info Initializer";
        Offset: Duration;
        TimeZoneInfoDotNet: DotNet TimeZoneInfo;
    begin
        TimeZoneInfoInitializer.InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
        Offset := TimeZoneInfoDotNet.GetUtcOffset(SourceDateTime);
        exit(Offset);
    end;

    procedure GetUtcOffsetForUserTimeZone(SourceDateTime: DateTime): Duration
    var
        Session: SessionSettings;
    begin
        Session.Init();
        if Session.TimeZone <> '' then
            exit(GetUtcOffset(SourceDateTime, Session.TimeZone));
    end;

    procedure GetTimeZoneOffset(SourceDateTime: DateTime; SourceTimeZoneId: Text; DestinationTimeZoneId: Text): Duration
    var
        SourceUtcOffset: Duration;
        DestinationUtcOffset: Duration;
        TotalOffset: Duration;
    begin
        SourceUtcOffset := GetUtcOffset(SourceDateTime, SourceTimeZoneId);
        DestinationUtcOffset := GetUtcOffset(SourceDateTime, DestinationTimeZoneId);

        TotalOffset := DestinationUtcOffset - SourceUtcOffset;
        exit(TotalOffset);
    end;

    procedure TimeZoneSupportsDaylightSavingTime(TimeZoneId: Text): Boolean
    begin
        TimeZoneInfoInitializer.InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
        exit(TimeZoneInfoDotNet.SupportsDaylightSavingTime);
    end;

    procedure IsDaylightSavingTime(DateTimeToCheck: DateTime; TimeZoneId: Text): Boolean
    begin
        TimeZoneInfoInitializer.InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
        exit(TimeZoneInfoDotNet.IsDaylightSavingTime(DateTimeToCheck))
    end;
}
