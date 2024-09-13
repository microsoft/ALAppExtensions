namespace Microsoft.Sustainability.RoleCenters;
using Microsoft.Sustainability.Setup;

codeunit 6222 "RC Headline Page Sust."
{
    procedure GetFootPrintText(): Text
    begin
        CalculateValues();
        exit(CarbonFootprintTxt);
    end;

    procedure CanShowFootPrint(): Boolean
    begin
        CalculateValues();
        exit(ShowFootPrintText);
    end;

    local procedure CalculateValues()
    var
        SustainabilityCue: Record "Sustainability Cue";
        SustainabilitySetup: Record "Sustainability Setup";
        YesterdaysTotalEmission: Decimal;
        TodaysTotalEmission: Decimal;
        Percent: Decimal;
    begin
        if Initialized then
            exit;

        SustainabilitySetup.Get();
        CarbonFootprintTxt := '';
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert(true);

        SustainabilityCue.SetFilter("Date Filter", '%1', WorkDate() - 1);
        SustainabilityCue.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");
        YesterdaysTotalEmission := SustainabilityCue."Emission CO2" + SustainabilityCue."Emission CH4" + SustainabilityCue."Emission N2O";

        SustainabilityCue.SetFilter("Date Filter", '%1', WorkDate());
        SustainabilityCue.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");
        TodaysTotalEmission := SustainabilityCue."Emission CO2" + SustainabilityCue."Emission CH4" + SustainabilityCue."Emission N2O";
        TodaysTotalEmission := Round(TodaysTotalEmission, 1, '=');

        ShowFootPrintText := (TodaysTotalEmission <> 0) or (YesterdaysTotalEmission <> 0);
        if ShowFootPrintText then
            if YesterdaysTotalEmission <> 0 then
                Percent := abs(Round(((TodaysTotalEmission - YesterdaysTotalEmission) / YesterdaysTotalEmission) * 100, 1, '='))
            else
                Percent := 100;

        if TodaysTotalEmission > YesterdaysTotalEmission then
            CarbonFootprintTxt := StrSubstNo(CarbonFootprintLbl, TodaysTotalEmission, SustainabilitySetup."Emission Unit of Measure Code", MoreTxt, Percent)
        else
            CarbonFootprintTxt := StrSubstNo(CarbonFootprintLbl, TodaysTotalEmission, SustainabilitySetup."Emission Unit of Measure Code", LessTxt, Percent);

        Initialized := true;
    end;

    var
        Initialized: Boolean;
        ShowFootPrintText: Boolean;
        MoreTxt: Label '+';
        LessTxt: Label '-';
        CarbonFootprintLbl: Label 'Today carbon footprint is %1 %2 (%3%4 % from yesterday)', Comment = '%1 - Todays Emission,%2 - UOM ,%3 - More or less, %3 - yesterdays comparison';
        CarbonFootprintTxt: Text;
}