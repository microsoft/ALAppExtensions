// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8722 "Daylight Saving Time Info"
{
    /// <summary>
    /// Checks whether the indicated time zone supports daylight saving time.
    /// </summary>
    /// <param name="TimeZoneId">The ID of the time zone that you want to check the daylight saving time settings for.</param>
    /// <returns>A boolean indicating whether the requested time zone observes daylight saving time.</returns>
    procedure TimeZoneSupportsDaylightSavingTime(TimeZoneId: Text): Boolean
    begin
        exit(DaylightSavingTimeInfoImpl.TimeZoneSupportsDaylightSavingTime(TimeZoneId))
    end;

    /// <summary>
    /// Checks whether the requested datetime falls within the indicated time zone's daylight saving time period.
    /// </summary>
    /// <param name="DateTimeToCheck">The datetime for which you want to check whether it falls within the time zone's daylight saving time period.</param>
    /// <param name="TimeZoneId">The ID of the time zone against which you want to check the datetime.</param>
    /// <returns>A boolean indicating whether the requested datetime falls within the daylight saving time period for the indicated time zone. If the time zone does not observe daylight saving time, this will always return false.</returns>
    procedure IsDaylightSavingTime(DateTimeToCheck: DateTime; TimeZoneId: Text): Boolean
    begin
        exit(DaylightSavingTimeInfoImpl.IsDaylightSavingTime(DateTimeToCheck, TimeZoneId));
    end;

    var
        DaylightSavingTimeInfoImpl: Codeunit "Daylight Saving Time Info Impl";
}