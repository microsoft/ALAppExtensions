// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DateTime;

using System;

codeunit 8721 "Time Zone Impl."
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        TimeZoneInfoDotNet: DotNet TimeZoneInfo;
        InvalidTimeZoneIdErr: Label 'You have passed an invalid timezone ID (%1). Please reference the time zone list for supported time zone IDs.', Comment = '%1 = The invalid time zone ID passed to the procedure.';

    procedure GetUtcOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    var
        Offset: Duration;
    begin
        InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
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
        InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
        exit(TimeZoneInfoDotNet.SupportsDaylightSavingTime);
    end;

    procedure IsDaylightSavingTime(DateTimeToCheck: DateTime; TimeZoneId: Text): Boolean
    begin
        InitializeTimeZoneInfo(TimeZoneId, TimeZoneInfoDotNet);
        exit(TimeZoneInfoDotNet.IsDaylightSavingTime(DateTimeToCheck))
    end;

    procedure InitializeTimeZoneInfo(TimeZoneId: Text; var TimeZoneInfo: DotNet TimeZoneInfo)
    begin
        if not TryInstantiateTimeZoneInfo(TimeZoneId, TimeZoneInfo) then
            ThrowInvalidTimeZoneIdError(TimeZoneId);
    end;

    [TryFunction]
    local procedure TryInstantiateTimeZoneInfo(TimeZoneId: Text; var TimeZoneInfo: DotNet TimeZoneInfo)
    begin
        TimeZoneInfo := TimeZoneInfo.FindSystemTimeZoneById(TimeZoneId);
    end;

    local procedure ThrowInvalidTimeZoneIdError(TimeZoneId: Text)
    begin
        Error(InvalidTimeZoneIdErr, TimeZoneId);
    end;
}
