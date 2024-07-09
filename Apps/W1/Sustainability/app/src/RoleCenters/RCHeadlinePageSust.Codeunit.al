namespace Microsoft.Sustainability.RoleCenters;

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
        YesterdaysTotalEmission: Decimal;
        TodaysTotalEmission: Decimal;
        Percent: Decimal;
    begin
        if Initialized then
            exit;

        CarbonFootprintTxt := '';
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert(true);

        SustainabilityCue.SetFilter("Date Filter", '%1', WorkDate() - 1);
        SustainabilityCue.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");
        YesterdaysTotalEmission := SustainabilityCue."Emission CO2" + SustainabilityCue."Emission CH4" + SustainabilityCue."Emission N2O";

        SustainabilityCue.SetFilter("Date Filter", '%1', WorkDate());
        SustainabilityCue.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");
        TodaysTotalEmission := SustainabilityCue."Emission CO2" + SustainabilityCue."Emission CH4" + SustainabilityCue."Emission N2O";
        TodaysTotalEmission := Round(TodaysTotalEmission, 0.001, '=');

        ShowFootPrintText := (TodaysTotalEmission <> 0) or (YesterdaysTotalEmission <> 0);
        if ShowFootPrintText then
            if YesterdaysTotalEmission <> 0 then
                Percent := abs(Round(((TodaysTotalEmission - YesterdaysTotalEmission) / YesterdaysTotalEmission) * 100, 0.001, '='))
            else
                Percent := 100;

        if TodaysTotalEmission > YesterdaysTotalEmission then
            CarbonFootprintTxt := StrSubstNo(CarbonFootprintLbl, TodaysTotalEmission, Percent, MoreTxt)
        else
            CarbonFootprintTxt := StrSubstNo(CarbonFootprintLbl, TodaysTotalEmission, Percent, LessTxt);

        Initialized := true;
    end;

    var
        Initialized: Boolean;
        ShowFootPrintText: Boolean;
        MoreTxt: Label 'more';
        LessTxt: Label 'less';
        CarbonFootprintLbl: Label 'Your today''s carbon footprint is %1 and this is %2 % %3 than yesterday.', Comment = '%1 - Todays Emission, %2 - yesterdays comparison, %3 - More or less';
        CarbonFootprintTxt: Text;
}