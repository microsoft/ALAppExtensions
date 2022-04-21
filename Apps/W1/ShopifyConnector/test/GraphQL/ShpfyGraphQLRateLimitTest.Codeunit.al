/// <summary>
/// Codeunit Shpfy GraphQL Rate Limit Test (ID 30516).
/// </summary>
codeunit 30516 "Shpfy GraphQL Rate Limit Test"
{
    Subtype = Test;

    var
        Assert: Codeunit "Library Assert";

    [Test]
    procedure UnitTestWaitForRequestAvailable()
    var
        StartTime: DateTime;
        EndTime: DateTime;
        WaitTime: Duration;
        JThrottleStatus: JsonObject;
        ShpfyGrapQLRateLimit: codeunit "Shpfy GraphQL Rate Limit";
        JThrottleStatusTxt: Label '{"maximumAvailable": 1000, "restoreRate": 50, "currentlyAvailable": %1}', Comment = '%1 = currentAvailable', Locked = true;
    begin
        // [SCENARIO] Set the availability to 1000. Then wait for the availability.
        // [GIVEN] Set currentAvailable = 1000 in the JThottleStatus
        JThrottleStatus.ReadFrom(StrSubstNo(JThrottleStatusTxt, 1000));
        ShpfyGrapQLRateLimit.SetQueryCost(JThrottleStatus.AsToken());
        // [WHEN] Invoke WaitFromRequestAvailable(0)
        StartTime := CurrentDateTime;
        ShpfyGrapQLRateLimit.WaitForRequestAvailable(0);
        EndTime := CurrentDateTime;
        WaitTime := EndTime - StartTime;
        // [THEN] WaitTime < 1000 (less then 1 sec.)
        Assert.IsTrue(WaitTime < 1000, 'currentlyAvailable = 1000, WaitForRequestAvailable(0)');

        // [SCENARIO] Set the availability to 50. Then wait for the availability for an expected cost of 250.
        // [GIVEN] Set currentAvailable = 50 in the JThottleStatus
        JThrottleStatus.ReadFrom(StrSubstNo(JThrottleStatusTxt, 50));
        ShpfyGrapQLRateLimit.SetQueryCost(JThrottleStatus.AsToken());
        // [WHEN] Invoke WaitFromRequestAvailable(150)
        StartTime := CurrentDateTime;
        ShpfyGrapQLRateLimit.WaitForRequestAvailable(150);
        EndTime := CurrentDateTime;
        WaitTime := EndTime - StartTime;
        // [THEN] Waittime is about 2 sec.
        Assert.AreNearlyEqual(2000, WaitTime, 100, 'currentlyAvailable = 50, WaitForRequestAvailable(150)');
    end;
}
