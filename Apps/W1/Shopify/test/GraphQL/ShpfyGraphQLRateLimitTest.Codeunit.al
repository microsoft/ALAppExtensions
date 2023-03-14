/// <summary>
/// Codeunit Shpfy GraphQL Rate Limit Test (ID 135611).
/// </summary>
codeunit 139571 "Shpfy GraphQL Rate Limit Test"
{
    Subtype = Test;

    var
        LibraryAssert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestWaitForRequestAvailable()
    var
        ShpfyGraphQLRateLimit: codeunit "Shpfy GraphQL Rate Limit";
        EndTime: DateTime;
        StartTime: DateTime;
        WaitTime: Duration;
        JThrottleStatus: JsonObject;
        JThrottleStatusTxt: Label '{"maximumAvailable": 1000, "restoreRate": 50, "currentlyAvailable": %1}', Comment = '%1 = currentAvailable', Locked = true;
    begin
        // [SCENARIO] Set the availability to 1000. Then wait for the availability.
        // [GIVEN] Set currentAvailable = 1000 in the JThottleStatus
        JThrottleStatus.ReadFrom(StrSubstNo(JThrottleStatusTxt, 1000));
        ShpfyGraphQLRateLimit.SetQueryCost(JThrottleStatus.AsToken());
        // [WHEN] Invoke WaitFromRequestAvailable(0)
        StartTime := CurrentDateTime;
        ShpfyGraphQLRateLimit.WaitForRequestAvailable(0);
        EndTime := CurrentDateTime;
        WaitTime := EndTime - StartTime;
        // [THEN] WaitTime < 1000 (less then 1 sec.)
        LibraryAssert.IsTrue(WaitTime < 1000, 'currentlyAvailable = 1000, WaitForRequestAvailable(0)');

        // [SCENARIO] Set the availability to 50. Then wait for the availability for an expected cost of 150.
        // [GIVEN] Set currentAvailable = 50 in the JThottleStatus
        JThrottleStatus.ReadFrom(StrSubstNo(JThrottleStatusTxt, 50));
        ShpfyGraphQLRateLimit.SetQueryCost(JThrottleStatus.AsToken());
        // [WHEN] Invoke WaitFromRequestAvailable(150)
        StartTime := CurrentDateTime;
        ShpfyGraphQLRateLimit.WaitForRequestAvailable(150);
        EndTime := CurrentDateTime;
        WaitTime := EndTime - StartTime;
        // [THEN] Waittime is about 2 sec.
        LibraryAssert.AreNearlyEqual(2000, WaitTime, 200, 'currentlyAvailable = 50, WaitForRequestAvailable(150)');
    end;
}
