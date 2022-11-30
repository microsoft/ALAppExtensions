codeunit 50110 "DateTime Offset"
{
    /// <summary>
    /// Retrieves the offset from the requested time zone at the time of the requested datetime. This takes into account any daylight saving time conditions that may apply.
    /// </summary>
    /// <param name="SourceDateTime">The datetime that will be used as the basis for the difference calculation.</param>
    /// <param name="TimeZoneId">The ID of the time zone that you want to calculate the offset for.</param>
    /// <returns>A duration that indicates the offset between UTC and the requested time zone for the provided datetime.</returns>
    procedure GetUtcOffset(SourceDateTime: DateTime; TimeZoneId: Text): Duration
    begin
        exit(DateTimeConversionImpl.GetUtcOffset(SourceDateTime, TimeZoneId));
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
        exit(DateTimeConversionImpl.GetTimeZoneOffset(SourceDateTime, SourceTimeZoneId, DestinationTimeZoneId));
    end;

    var
        DateTimeConversionImpl: Codeunit "DateTime Offset Impl.";
}
