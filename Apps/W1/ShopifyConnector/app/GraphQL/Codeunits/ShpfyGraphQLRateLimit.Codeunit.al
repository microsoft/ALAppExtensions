/// <summary>
/// Codeunit Shpfy GraphQL Rate Limit (ID 30153).
/// </summary>
codeunit 30153 "Shpfy GraphQL Rate Limit"
{
    Access = Internal;
    SingleInstance = true;

    var
        JHelper: Codeunit "Shpfy Json Helper";
        NextRequestAfter: DateTime;
        LastRequestedOn: DateTime;
        MaximumAvailable: Decimal;
        RestoreRate: Decimal;
        LastAvailable: Decimal;


    /// <summary> 
    /// Set Query Cost.
    /// </summary>
    /// <param name="JThrottleStatus">Parameter of type JsonToken.</param>
    internal procedure SetQueryCost(JThrottleStatus: JsonToken)
    var
        WaitTime: Duration;
    begin
        if JThrottleStatus.IsObject then begin
            MaximumAvailable := JHelper.GetValueAsDecimal(JThrottleStatus, 'maximumAvailable');
            RestoreRate := JHelper.GetValueAsDecimal(JThrottleStatus, 'restoreRate');
            LastAvailable := JHelper.GetValueAsDecimal(JThrottleStatus, 'currentlyAvailable');
            LastRequestedOn := CurrentDateTime;
            WaitTime := CalcWaitTime();
        end;
        NextRequestAfter := CurrentDateTime + WaitTime;
    end;

    /// <summary> 
    /// Wait For Request Available.
    /// </summary>
    internal procedure WaitForRequestAvailable()
    begin
        if NextRequestAfter = 0DT then
            exit;

        GoToSleep()
    end;

    /// <summary> 
    /// Description for WaitForRequestAvailable.
    /// </summary>
    /// <param name="ExpectedCost">Parameter of type Decimal.</param>
    internal procedure WaitForRequestAvailable(ExpectedCost: Decimal)
    var
        WaitTime: Duration;
    begin
        if LastRequestedOn = 0DT then
            LastRequestedOn := CurrentDateTime - 1000;
        if (ExpectedCost = 0) or (ExpectedCost > LastAvailable) then begin
            NextRequestAfter := CurrentDateTime;
            WaitTime := CalcWaitTime(ExpectedCost);
            NextRequestAfter := LastRequestedOn + WaitTime;
            WaitForRequestAvailable();
        end;
    end;

    local procedure CalcWaitTime(): Duration
    var
        WaitTime: Duration;
    begin
        if TryCalcWaitTime(WaitTime) then
            exit(WaitTime);
        WaitTime := 0;
        exit(WaitTime);
    end;

    local procedure CalcWaitTime(ExpectedCost: Decimal): Duration
    var
        WaitTime: Duration;
    begin
        if ExpectedCost = 0 then
            exit(CalcWaitTime());
        if LastAvailable > (2 * ExpectedCost) then begin
            WaitTime := 0;
            exit(WaitTime);
        end;
        if TryCalcWaitTime(ExpectedCost, WaitTime) then
            exit(WaitTime);
        WaitTime := 0;
        exit(WaitTime);
    end;

    [TryFunction]
    local procedure TryCalcWaitTime(ExpectedCost: Decimal; var WaitTime: Duration)
    var
        Math: Codeunit Math;
    begin
        if RestoreRate = 0 then
            RestoreRate := 50;
        WaitTime := (Math.Max(2 * ExpectedCost - LastAvailable, 250) / RestoreRate * 1000) - (CurrentDateTime - LastRequestedOn);
        if WaitTime < 0 then
            WaitTime := 0;
    end;

    [TryFunction]
    local procedure TryCalcWaitTime(var WaitTime: Duration)
    begin
        WaitTime := (MaximumAvailable - LastAvailable) / RestoreRate * 1000;
        if WaitTime < 0 then
            WaitTime := 0;
        if WaitTime > (MaximumAvailable * 1000) then
            WaitTime := MaximumAvailable * 1000;
    end;

    local procedure GoToSleep(): Duration

    begin
        if not TryGoToSleep() then
            Sleep(100);
    end;

    [TryFunction]
    local procedure TryGoToSleep()
    var
        SleepTime: Duration;
    begin
        SleepTime := NextRequestAfter - CurrentDateTime;
        if SleepTime > 0 then
            Sleep(SleepTime);
    end;
}