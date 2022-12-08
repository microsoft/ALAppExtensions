permissionset 132979 TimeZoneMgtObjects
{
    Caption = 'Time Zone Management - Objects';
    Assignable = false;
    Permissions = codeunit "DateTime Offset" = X,
        codeunit "DateTime Offset Impl." = X,
        codeunit "Daylight Saving Time Info" = X,
        codeunit "Daylight Saving Time Info Impl" = X,
        codeunit "TimeZoneInfo Initializer" = X;
}