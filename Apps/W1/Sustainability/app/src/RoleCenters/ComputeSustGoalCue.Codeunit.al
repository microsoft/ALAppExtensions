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
        TotalCurrentWater: Decimal;
        TotalCurrentWaste: Decimal;
        TotalBaseLineCO2: Decimal;
        TotalBaseLineCH4: Decimal;
        TotalBaseLineN2O: Decimal;
        TotalBaseLineWater: Decimal;
        TotalBaseLineWaste: Decimal;
        TotalTargetCO2: Decimal;
        TotalTargetCH4: Decimal;
        TotalTargetN2O: Decimal;
        TotalTargetWater: Decimal;
        TotalTargetWaste: Decimal;
        RealizedPercentCO2: Decimal;
        RealizedPercentCH4: Decimal;
        RealizedPercentN2O: Decimal;
        RealizedPercentWater: Decimal;
        RealizedPercentWaste: Decimal;
        CO2vsBaseline: Decimal;
        CH4vsBaseline: Decimal;
        N2OvsBaseline: Decimal;
        WatervsBaseline: Decimal;
        WastevsBaseline: Decimal;
        IsModified: Boolean;
    begin
        if not CanRefreshCueValues(SustGoalCue."Last Refreshed Datetime") then
            exit;

        SustGoalCue."Last Refreshed Datetime" := CurrentDateTime();
        SustGoalCue.Modify();

        SustainabilityGoal.SetRange("Main Goal", true);
        if not SustainabilityGoal.FindFirst() then begin
            ClearGoalCueValues(SustGoalCue);
            exit;
        end;

        SustainabilityGoal.UpdateCurrentDateFilter(SustainabilityGoal."Start Date", SustainabilityGoal."End Date");
        SustainabilityGoal.UpdateBaselineDateFilter(SustainabilityGoal."Baseline Start Date", SustainabilityGoal."Baseline End Date");
        SustainabilityGoal.CalcFields(
            "Current Value for CO2",
            "Current Value for CH4",
            "Current Value for N2O",
            "Current Value for Water Int.",
            "Current Value for Waste Int.",
            "Baseline for CO2",
            "Baseline for CH4",
            "Baseline for N2O",
            "Baseline for Water Intensity",
            "Baseline for Waste Intensity");

        TotalCurrentCO2 += SustainabilityGoal."Current Value for CO2";
        TotalCurrentCH4 += SustainabilityGoal."Current Value for CH4";
        TotalCurrentN2O += SustainabilityGoal."Current Value for N2O";
        TotalCurrentWater += SustainabilityGoal."Current Value for Water Int.";
        TotalCurrentWaste += SustainabilityGoal."Current Value for Waste Int.";

        TotalBaseLineCO2 += SustainabilityGoal."Baseline for CO2";
        TotalBaseLineCH4 += SustainabilityGoal."Baseline for CH4";
        TotalBaseLineN2O += SustainabilityGoal."Baseline for N2O";
        TotalBaseLineWater += SustainabilityGoal."Baseline for Water Intensity";
        TotalBaseLineWaste += SustainabilityGoal."Baseline for Waste Intensity";

        TotalTargetCO2 += SustainabilityGoal."Target Value for CO2";
        TotalTargetCH4 += SustainabilityGoal."Target Value for CH4";
        TotalTargetN2O += SustainabilityGoal."Target Value for N2O";
        TotalTargetWater += SustainabilityGoal."Target Value for Water Int.";
        TotalTargetWaste += SustainabilityGoal."Target Value for Waste Int.";

        if (TotalCurrentCO2 <> 0) and (TotalTargetCO2 <> 0) then
            RealizedPercentCO2 := (TotalCurrentCO2 * 100) / TotalTargetCO2;

        if (TotalCurrentCH4 <> 0) and (TotalTargetCH4 <> 0) then
            RealizedPercentCH4 := (TotalCurrentCH4 * 100) / TotalTargetCH4;

        if (TotalCurrentN2O <> 0) and (TotalTargetN2O <> 0) then
            RealizedPercentN2O := (TotalCurrentN2O * 100) / TotalTargetN2O;

        if (TotalCurrentWater <> 0) and (TotalTargetWater <> 0) then
            RealizedPercentWater := (TotalCurrentWater * 100) / TotalTargetWater;

        if (TotalCurrentWaste <> 0) and (TotalTargetWaste <> 0) then
            RealizedPercentWaste := (TotalCurrentWaste * 100) / TotalTargetWaste;

        if (TotalCurrentCO2 <> 0) and (TotalBaseLineCO2 <> 0) then
            CO2vsBaseline := (TotalCurrentCO2 * 100) / TotalBaseLineCO2;

        if (TotalCurrentCH4 <> 0) and (TotalBaseLineCH4 <> 0) then
            CH4vsBaseline := (TotalCurrentCH4 * 100) / TotalBaseLineCH4;

        if (TotalCurrentN2O <> 0) and (TotalBaseLineN2O <> 0) then
            N2OvsBaseline := (TotalCurrentN2O * 100) / TotalBaseLineN2O;

        if (TotalCurrentWater <> 0) and (TotalBaseLineWater <> 0) then
            WatervsBaseline := (TotalCurrentWater * 100) / TotalBaseLineWater;

        if (TotalCurrentWaste <> 0) and (TotalBaseLineWaste <> 0) then
            WastevsBaseline := (TotalCurrentWaste * 100) / TotalBaseLineWaste;

        IsModified := (SustGoalCue."Realized % for CO2" <> RealizedPercentCO2) or (SustGoalCue."Realized % for CH4" <> RealizedPercentCH4) or (SustGoalCue."Realized % for N2O" <> RealizedPercentN2O) or (SustGoalCue."Realized % for Water" <> RealizedPercentWater) or (SustGoalCue."Realized % for Waste" <> RealizedPercentWaste);

        if not IsModified then
            IsModified := (SustGoalCue."CO2 % vs Baseline" <> CO2vsBaseline) or (SustGoalCue."CH4 % vs Baseline" <> CH4vsBaseline) or (SustGoalCue."N2O % vs Baseline" <> N2OvsBaseline) or (SustGoalCue."Water % vs Baseline" <> WatervsBaseline) or (SustGoalCue."Waste % vs Baseline" <> WastevsBaseline);

        if not IsModified then
            exit;

        SustGoalCue."Realized % for CO2" := RealizedPercentCO2;
        SustGoalCue."Realized % for CH4" := RealizedPercentCH4;
        SustGoalCue."Realized % for N2O" := RealizedPercentN2O;
        SustGoalCue."Realized % for Water" := RealizedPercentWater;
        SustGoalCue."Realized % for Waste" := RealizedPercentWaste;

        SustGoalCue."CO2 % vs Baseline" := CO2vsBaseline;
        SustGoalCue."CH4 % vs Baseline" := CH4vsBaseline;
        SustGoalCue."N2O % vs Baseline" := N2OvsBaseline;
        SustGoalCue."Water % vs Baseline" := WatervsBaseline;
        SustGoalCue."Waste % vs Baseline" := WastevsBaseline;
        SustGoalCue.Modify();
    end;

    local procedure ClearGoalCueValues(var SustGoalCue: Record "Sustainability Goal Cue")
    begin
        SustGoalCue."Realized % for CO2" := 0;
        SustGoalCue."Realized % for CH4" := 0;
        SustGoalCue."Realized % for N2O" := 0;
        SustGoalCue."Realized % for Water" := 0;
        SustGoalCue."Realized % for Waste" := 0;

        SustGoalCue."CO2 % vs Baseline" := 0;
        SustGoalCue."CH4 % vs Baseline" := 0;
        SustGoalCue."N2O % vs Baseline" := 0;
        SustGoalCue."Water % vs Baseline" := 0;
        SustGoalCue."Waste % vs Baseline" := 0;
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