// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace System.DateTime;

/// <summary>
/// Codeunit that provides data on offsets and daylight saving time for a time zone.
/// </summary>
codeunit 8720 "Time Zone"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    /// <summary>
    /// Retrieves the offset from the requested time zone at the time of the requested datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <param name="TimeZoneId">The ID of the time zone that you want to calculate the offset for.</param>
    /// <returns>A duration that indicates the offset between UTC and the requested time zone for the provided datetime.</returns>
    procedure GetTimezoneOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    var
        TimeZoneImpl: Codeunit "Time Zone Impl.";
    begin
        exit(TimeZoneImpl.GetUtcOffset(SourceDateTime, TimeZoneId));
    end;

    /// <summary>
    /// Retrieves the offset from the user time zone at the time of the requested datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <returns>A duration that indicates the offset between UTC and the user time zone for the provided datetime.</returns>
    procedure GetTimezoneOffset(SourceDateTime: DateTime): Duration
    var
        TimeZoneImpl: Codeunit "Time Zone Impl.";
    begin
        exit(TimeZoneImpl.GetUtcOffsetForUserTimeZone(SourceDateTime));
    end;

    /// <summary>
    /// Retrieves the offset of the destination time zone from the source time zone for the indicated datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <param name="SourceTimeZoneId">The time zone from which you want to calculate the difference.</param>
    /// <param name="DestinationTimeZoneId">The time zone against which you want to calculate the difference.</param>
    /// <returns>A duration that indicates the offset between the two time zones at the indicated datetime.</returns>
    procedure GetTimezoneOffset(SourceDateTime: DateTime; SourceTimeZoneId: Text; DestinationTimeZoneId: Text): Duration
    var
        TimeZoneImpl: Codeunit "Time Zone Impl.";
    begin
        exit(TimeZoneImpl.GetTimeZoneOffset(SourceDateTime, SourceTimeZoneId, DestinationTimeZoneId));
    end;

    /// <summary>
    /// Checks whether the indicated time zone supports daylight saving time.
    /// </summary>
    /// <param name="TimeZoneId">The ID of the time zone that you want to check the daylight saving time settings for.</param>
    /// <returns>A boolean indicating whether the requested time zone observes daylight saving time.</returns>
    procedure TimeZoneSupportsDaylightSavingTime(TimeZoneId: Text): Boolean
    var
        TimeZoneImpl: Codeunit "Time Zone Impl.";
    begin
        exit(TimeZoneImpl.TimeZoneSupportsDaylightSavingTime(TimeZoneId))
    end;

    /// <summary>
    /// Checks whether the requested datetime falls within the indicated time zone's daylight saving time period.
    /// </summary>
    /// <param name="DateTimeToCheck">The datetime for which you want to check whether it falls within the time zone's daylight saving time period.</param>
    /// <param name="TimeZoneId">The ID of the time zone against which you want to check the datetime.</param>
    /// <returns>A boolean indicating whether the requested datetime falls within the daylight saving time period for the indicated time zone. If the time zone does not observe daylight saving time, this will always return false.</returns>
    procedure IsDaylightSavingTime(DateTimeToCheck: DateTime; TimeZoneId: Text): Boolean
    var
        TimeZoneImpl: Codeunit "Time Zone Impl.";
    begin
        exit(TimeZoneImpl.IsDaylightSavingTime(DateTimeToCheck, TimeZoneId));
    end;
}
