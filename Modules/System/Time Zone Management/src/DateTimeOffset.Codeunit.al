// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// Codeunit that calculates the offset for a datetime from either UTC or another time zone
/// </summary>
codeunit 8720 "DateTime Offset"
{
    /// <summary>
    /// Retrieves the offset from the requested time zone at the time of the requested datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <param name="TimeZoneId">The ID of the time zone that you want to calculate the offset for.</param>
    /// <returns>A duration that indicates the offset between UTC and the requested time zone for the provided datetime.</returns>
    procedure GetUtcOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    begin
        exit(DateTimeOffsetImpl.GetUtcOffset(SourceDateTime, TimeZoneId));
    end;

    /// <summary>
    /// Retrieves the offset from the user time zone at the time of the requested datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <returns>A duration that indicates the offset between UTC and the user time zone for the provided datetime.</returns>
    procedure GetUtcOffsetForUserTimeZone(SourceDateTime: DateTime): Duration
    begin
        exit(DateTimeOffsetImpl.GetUtcOffsetForUserTimeZone(SourceDateTime));
    end;

    /// <summary>
    /// Retrieves the offset of the destination time zone from the source time zone for the indicated datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <param name="SourceTimeZoneId">The time zone from which you want to calculate the difference.</param>
    /// <param name="DestinationTimeZoneId">The time zone against which you want to calculate the difference.</param>
    /// <returns>A duration that indicates the offset between the two time zones at the indicated datetime.</returns>
    procedure GetTimeZoneOffset(SourceDateTime: DateTime; SourceTimeZoneId: Text; DestinationTimeZoneId: Text): Duration
    begin
        exit(DateTimeOffsetImpl.GetTimeZoneOffset(SourceDateTime, SourceTimeZoneId, DestinationTimeZoneId));
    end;

    var
        DateTimeOffsetImpl: Codeunit "DateTime Offset Impl.";
}
