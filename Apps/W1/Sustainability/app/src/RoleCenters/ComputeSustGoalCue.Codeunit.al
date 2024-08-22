namespace Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Scorecard;

codeunit 6230 "Compute Sust. Goal Cue"
{
    var
        CalledFromManualRefresh: Boolean;

    procedure GetLatestSustainabilityGoalCue(var SustGoalCue: Record "Sustainability Goal Cue")
    begin
        ComputeValues(SustGoalCue);
    end;

    procedure SetCalledFromManualRefresh(NewCalledFromManualRefresh: Boolean)
    begin
        CalledFromManualRefresh := NewCalledFromManualRefresh;
    end;

    local procedure ComputeValues(var SustGoalCue: Record "Sustainability Goal Cue")
    var
        SustainabilityGoal: Record "Sustainability Goal";
        TotalCurrentCO2: Decimal;
        TotalCurrentCH4: Decimal;
        TotalCurrentN2O: Decimal;
        TotalBaseLineCO2: Decimal;
        TotalBaseLineCH4: Decimal;
        TotalBaseLineN2O: Decimal;
        TotalTargetCO2: Decimal;
        TotalTargetCH4: Decimal;
        TotalTargetN2O: Decimal;
        RealizedPercentCO2: Decimal;
        RealizedPercentCH4: Decimal;
        RealizedPercentN2O: Decimal;
        CO2vsBaseline: Decimal;
        CH4vsBaseline: Decimal;
        N2OvsBaseline: Decimal;
        IsModified: Boolean;
    begin
        if not CanRefreshCueValues(SustGoalCue."Last Refreshed Datetime") then
            exit;

        SustGoalCue."Last Refreshed Datetime" := CurrentDateTime();
        SustGoalCue.Modify();

        if SustainabilityGoal.FindSet() then
            repeat
                SustainabilityGoal.UpdateCurrentDateFilter(SustainabilityGoal."Start Date", SustainabilityGoal."End Date");
                SustainabilityGoal.UpdateBaselineDateFilter(SustainabilityGoal."Baseline Start Date", SustainabilityGoal."Baseline End Date");
                SustainabilityGoal.CalcFields(
                    "Current Value for CO2",
                    "Current Value for CH4",
                    "Current Value for N2O",
                    "Baseline for CO2",
                    "Baseline for CH4",
                    "Baseline for N2O");

                TotalCurrentCO2 += SustainabilityGoal."Current Value for CO2";
                TotalCurrentCH4 += SustainabilityGoal."Current Value for CH4";
                TotalCurrentN2O += SustainabilityGoal."Current Value for N2O";

                TotalBaseLineCO2 += SustainabilityGoal."Baseline for CO2";
                TotalBaseLineCH4 += SustainabilityGoal."Baseline for CH4";
                TotalBaseLineN2O += SustainabilityGoal."Baseline for N2O";

                TotalTargetCO2 += SustainabilityGoal."Target Value for CO2";
                TotalTargetCH4 += SustainabilityGoal."Target Value for CH4";
                TotalTargetN2O += SustainabilityGoal."Target Value for N2O";
            until SustainabilityGoal.Next() = 0;

        if (TotalCurrentCO2 <> 0) and (TotalTargetCO2 <> 0) then
            RealizedPercentCO2 := (TotalCurrentCO2 * 100) / TotalTargetCO2;

        if (TotalCurrentCH4 <> 0) and (TotalTargetCH4 <> 0) then
            RealizedPercentCH4 := (TotalCurrentCH4 * 100) / TotalTargetCH4;

        if (TotalCurrentN2O <> 0) and (TotalTargetN2O <> 0) then
            RealizedPercentN2O := (TotalCurrentN2O * 100) / TotalTargetN2O;

        if (TotalCurrentCO2 <> 0) and (TotalBaseLineCO2 <> 0) then
            CO2vsBaseline := (TotalCurrentCO2 * 100) / TotalBaseLineCO2;

        if (TotalCurrentCH4 <> 0) and (TotalBaseLineCH4 <> 0) then
            CH4vsBaseline := (TotalCurrentCH4 * 100) / TotalBaseLineCH4;

        if (TotalCurrentN2O <> 0) and (TotalBaseLineN2O <> 0) then
            N2OvsBaseline := (TotalCurrentN2O * 100) / TotalBaseLineN2O;

        IsModified := (SustGoalCue."Realized % for CO2" <> RealizedPercentCO2) or (SustGoalCue."Realized % for CH4" <> RealizedPercentCH4) or (SustGoalCue."Realized % for N2O" <> RealizedPercentN2O);

        if not IsModified then
            IsModified := (SustGoalCue."CO2 % vs Baseline" <> CO2vsBaseline) or (SustGoalCue."CH4 % vs Baseline" <> CH4vsBaseline) or (SustGoalCue."N2O % vs Baseline" <> N2OvsBaseline);

        if not IsModified then
            exit;

        SustGoalCue."Realized % for CO2" := RealizedPercentCO2;
        SustGoalCue."Realized % for CH4" := RealizedPercentCH4;
        SustGoalCue."Realized % for N2O" := RealizedPercentN2O;

        SustGoalCue."CO2 % vs Baseline" := CO2vsBaseline;
        SustGoalCue."CH4 % vs Baseline" := CH4vsBaseline;
        SustGoalCue."N2O % vs Baseline" := N2OvsBaseline;
        SustGoalCue.Modify();
    end;

    local procedure CanRefreshCueValues(LastUpdatedDateTime: DateTime): Boolean
    var
        TimeDuration: Duration;
        DateTime2: DateTime;
        TotalHours: Decimal;
        IsHandled: Boolean;
        CanRefresh: Boolean;
    begin
        OnBeforeEvaluateCanRefreshCueValues(LastUpdatedDateTime, CanRefresh, IsHandled);
        if IsHandled then
            exit(CanRefresh);

        if CalledFromManualRefresh then
            exit(true);

        if LastUpdatedDateTime = 0DT then
            exit(true);

        DateTime2 := CurrentDateTime();
        TimeDuration := DateTime2 - LastUpdatedDateTime;
        TotalHours := TimeDuration / 3600000;

        exit(TotalHours >= 1);
    end;

    [IntegrationEvent(false, false)]
    local procedure OnBeforeEvaluateCanRefreshCueValues(var LastUpdatedDateTime: DateTime; var CanRefresh: Boolean; var IsHandled: Boolean)
    begin
    end;
}