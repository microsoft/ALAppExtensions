namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Sustainability.Setup;
using System.Visualization;

codeunit 6219 "Sustainability Chart Mgmt."
{
    procedure GenerateDate(var BussChartBuffer: Record "Business Chart Buffer")
    var
        SustainabilityCue: Record "Sustainability Cue";
        TotalEmission: Decimal;
        Index: Integer;
    begin
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert();

        if (BussChartBuffer."Period Filter Start Date" <> 0D) or (BussChartBuffer."Period Filter End Date" <> 0D) then
            SustainabilityCue.SetRange("Date Filter", BussChartBuffer."Period Filter Start Date", BussChartBuffer."Period Filter End Date");

        SustainabilityCue.CalcFields("Emission CO2", "Emission CH4", "Emission N2O");
        TotalEmission := SustainabilityCue."Emission CO2" + SustainabilityCue."Emission CH4" + SustainabilityCue."Emission N2O";

        BussChartBuffer.Initialize();
        Index := 0;

        BussChartBuffer.AddMeasure('Ratio', 0, BussChartBuffer."Data Type"::Decimal, BussChartBuffer."Chart Type"::Doughnut);

        BussChartBuffer.SetXAxis('EmissionType', BussChartBuffer."Data Type"::String);
        BussChartBuffer.AddColumn('CO2');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CO2", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('CH4');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CH4", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('N2O');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission N2O", TotalEmission));
        Index += 1;
    end;

    local procedure GetRatio(EmissionValue: Decimal; TotalEmission: Decimal): Decimal
    var
        SustainabilitySetup: Record "Sustainability Setup";
        Ratio: Decimal;
    begin
        SustainabilitySetup.Get();

        if (EmissionValue <> 0) and (TotalEmission <> 0) then
            Ratio := EmissionValue / TotalEmission * 100;

        exit(Round(Ratio, 0.00001, '='));
    end;
}