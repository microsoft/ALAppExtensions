// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

codeunit 8723 "Daylight Saving Time Info Impl"
{
    Access = Internal;

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

    var
        TimeZoneInfoInitializer: Codeunit "Time Zone Info Initializer";
        TimeZoneInfoDotNet: DotNet TimeZoneInfo;
}