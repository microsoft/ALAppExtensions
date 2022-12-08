codeunit 8721 "DateTime Offset Impl."
{
    Access = Internal;

    procedure GetUtcOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    var
        TimeZoneInfoInitializer: Codeunit "TimeZoneInfo Initializer";
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
}
