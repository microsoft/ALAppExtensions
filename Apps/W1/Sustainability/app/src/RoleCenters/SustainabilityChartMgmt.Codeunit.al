namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Sustainability.Setup;
using System.Visualization;
using Microsoft.Sustainability.Account;

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

        BussChartBuffer.SetXAxis('Scope', BussChartBuffer."Data Type"::String);
        BussChartBuffer.AddColumn('Scope 1');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CO2", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('CH4');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CH4", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('N2O');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission N2O", TotalEmission));
        Index += 1;
    end;

    procedure GenerateChartByEmissionGas(var BussChartBuffer: Record "Business Chart Buffer"; EmissionGas: Text)
    var
        SustainabilityCue: Record "Sustainability Cue";
        TotalEmission: Decimal;
        Scope1Emission: Decimal;
        Scope2Emission: Decimal;
        Scope3Emission: Decimal;
        Index: Integer;
    begin
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert();

        if (BussChartBuffer."Period Filter Start Date" <> 0D) or (BussChartBuffer."Period Filter End Date" <> 0D) then
            SustainabilityCue.SetRange("Date Filter", BussChartBuffer."Period Filter Start Date", BussChartBuffer."Period Filter End Date");

        TotalEmission := GetEmissionValue(SustainabilityCue, EmissionGas);

        Scope1Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 1", EmissionGas);
        Scope2Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 2", EmissionGas);
        Scope3Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 3", EmissionGas);

        BussChartBuffer.Initialize();
        Index := 0;

        BussChartBuffer.AddMeasure(EmissionGas, 0, BussChartBuffer."Data Type"::Decimal, BussChartBuffer."Chart Type"::Doughnut);

        BussChartBuffer.SetXAxis('Emission', BussChartBuffer."Data Type"::String);
        BussChartBuffer.AddColumn('Scope 1');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope1Emission, TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('Scope 2');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope2Emission, TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn('Scope 3');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope3Emission, TotalEmission));
        Index += 1;
    end;

    local procedure GetEmissionByScope(var SustainabilityCue: Record "Sustainability Cue"; Scope: Enum "Emission Scope"; EmissionGas: Text): Decimal
    begin
        SustainabilityCue.SetFilter("Scope Filter", '%1', Scope);
        exit(GetEmissionValue(SustainabilityCue, EmissionGas));
    end;

    local procedure GetEmissionValue(var SustainabilityCue: Record "Sustainability Cue"; EmissionGas: Text) Value: Decimal
    begin
        case EmissionGas of
            'CO2':
                begin
                    SustainabilityCue.CalcFields("Emission CO2");
                    Value := SustainabilityCue."Emission CO2";
                end;
            'CH4':
                begin
                    SustainabilityCue.CalcFields("Emission CH4");
                    Value := SustainabilityCue."Emission CH4";
                end;
            'N2O':
                begin
                    SustainabilityCue.CalcFields("Emission N2O");
                    Value := SustainabilityCue."Emission N2O";
                end;
        end;
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