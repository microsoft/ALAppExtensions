namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Sustainability.Account;
using Microsoft.Sustainability.Setup;
using System.Visualization;

codeunit 6219 "Sustainability Chart Mgmt."
{
    var
        CO2eLbl: Label 'CO2e';
        CH4Lbl: Label 'CH4';
        N2OLbl: Label 'N2O';
        CO2Lbl: Label 'CO2';
        WaterLbl: Label 'Water';
        WasteLbl: Label 'Waste';
        EmissionLbl: Label 'Emission';

    internal procedure GetCO2e(): Text
    begin
        exit(CO2eLbl);
    end;

    internal procedure GetCH4(): Text
    begin
        exit(CH4Lbl);
    end;

    internal procedure GetN2O(): Text
    begin
        exit(N2OLbl);
    end;

    internal procedure GetCO2(): Text
    begin
        exit(CO2Lbl);
    end;

    internal procedure GetWater(): Text
    begin
        exit(WaterLbl);
    end;

    internal procedure GetWaste(): Text
    begin
        exit(WasteLbl);
    end;

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

        BussChartBuffer.AddMeasure('Ratio', 0, BussChartBuffer."Data Type"::Decimal, BussChartBuffer."Chart Type"::Doughnut.AsInteger());

        BussChartBuffer.SetXAxis('Scope', BussChartBuffer."Data Type"::String);
        BussChartBuffer.AddColumn('Scope 1');
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CO2", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn(GetCH4());
        BussChartBuffer.SetValueByIndex(0, Index, GetRatio(SustainabilityCue."Emission CH4", TotalEmission));
        Index += 1;

        BussChartBuffer.AddColumn(GetN2O());
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
        WithdrawnEmission: Decimal;
        DischargedEmission: Decimal;
        ConsumedEmission: Decimal;
        RecycledEmission: Decimal;
        GeneratedEmission: Decimal;
        DisposedEmission: Decimal;
        RecoveredEmission: Decimal;
        Index: Integer;
    begin
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert();

        if (BussChartBuffer."Period Filter Start Date" <> 0D) or (BussChartBuffer."Period Filter End Date" <> 0D) then
            SustainabilityCue.SetRange("Date Filter", BussChartBuffer."Period Filter Start Date", BussChartBuffer."Period Filter End Date");

        TotalEmission := GetEmissionValue(SustainabilityCue, EmissionGas);

        BussChartBuffer.Initialize();
        Index := 0;

        BussChartBuffer.AddMeasure(EmissionGas, 0, BussChartBuffer."Data Type"::Decimal, BussChartBuffer."Chart Type"::Doughnut.AsInteger());

        case EmissionGas of
            GetCH4(), GetCO2(), GetN2O():
                begin
                    Scope1Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 1", EmissionGas);
                    Scope2Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 2", EmissionGas);
                    Scope3Emission := GetEmissionByScope(SustainabilityCue, Enum::"Emission Scope"::"Scope 3", EmissionGas);

                    BussChartBuffer.SetXAxis(EmissionLbl, BussChartBuffer."Data Type"::String);
                    BussChartBuffer.AddColumn(Format(Enum::"Emission Scope"::"Scope 1"));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope1Emission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Emission Scope"::"Scope 2"));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope2Emission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Emission Scope"::"Scope 3"));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(Scope3Emission, TotalEmission));
                    Index += 1;
                end;
            GetWater():
                begin
                    WithdrawnEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Withdrawn, EmissionGas);
                    DischargedEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Discharged, EmissionGas);
                    ConsumedEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Consumed, EmissionGas);
                    RecycledEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Recycled, EmissionGas);

                    BussChartBuffer.SetXAxis(EmissionLbl, BussChartBuffer."Data Type"::String);
                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Withdrawn));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(WithdrawnEmission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Discharged));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(DischargedEmission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Consumed));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(ConsumedEmission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Recycled));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(RecycledEmission, TotalEmission));
                    Index += 1;
                end;
            GetWaste():
                begin
                    GeneratedEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Generated, EmissionGas);
                    DisposedEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Disposed, EmissionGas);
                    RecoveredEmission := GetEmissionByWaterWasteIntensityType(SustainabilityCue, Enum::"Water/Waste Intensity Type"::Recovered, EmissionGas);

                    BussChartBuffer.SetXAxis(EmissionLbl, BussChartBuffer."Data Type"::String);
                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Generated));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(GeneratedEmission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Disposed));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(DisposedEmission, TotalEmission));
                    Index += 1;

                    BussChartBuffer.AddColumn(Format(Enum::"Water/Waste Intensity Type"::Recovered));
                    BussChartBuffer.SetValueByIndex(0, Index, GetRatio(RecoveredEmission, TotalEmission));
                    Index += 1;
                end;
        end;
    end;

    procedure UpdateBarByEmissionGas(var BusChartBuf: Record "Business Chart Buffer"; EmissionGas: Text; WaterType: Boolean)
    var
        SustainabilityCue: Record "Sustainability Cue";
        ToDate: array[12] of Date;
        FromDate: array[12] of Date;
        ColumnNo: Integer;
        Value: Decimal;
    begin
        if not SustainabilityCue.Get() then
            SustainabilityCue.Insert();

        BusChartBuf.Initialize();

        if not WaterType then begin
            BusChartBuf."Period Length" := BusChartBuf."Period Length"::Month;
            BusChartBuf.SetPeriodXAxis();

            BusChartBuf.AddDecimalMeasure(EmissionGas, 0, BusChartBuf."Chart Type"::StackedColumn);

            if CalcPeriods(FromDate, ToDate, BusChartBuf) then begin
                BusChartBuf.AddPeriods(ToDate[1], ToDate[ArrayLen(ToDate)]);

                for ColumnNo := 1 to ArrayLen(ToDate) do begin

                    SustainabilityCue.SetRange("Date Filter", FromDate[ColumnNo], ToDate[ColumnNo]);

                    Value := GetEmissionValue(SustainabilityCue, EmissionGas);
                    BusChartBuf.SetValueByIndex(0, ColumnNo - 1, Value);
                end;
            end;
        end else begin
            BusChartBuf.SetXAxis('Emission', BusChartBuf."Data Type"::String);
            BusChartBuf.AddDecimalMeasure(EmissionGas, 0, BusChartBuf."Chart Type"::StackedColumn);

            BusChartBuf.AddColumn(Format(Enum::"Water Type"::"Ground water"));
            BusChartBuf.SetValueByIndex(0, ColumnNo, GetEmissionByWaterType(SustainabilityCue, Enum::"Water Type"::"Ground water", EmissionGas));
            ColumnNo += 1;

            BusChartBuf.AddColumn(Format(Enum::"Water Type"::"Produced water"));
            BusChartBuf.SetValueByIndex(0, ColumnNo, GetEmissionByWaterType(SustainabilityCue, Enum::"Water Type"::"Produced water", EmissionGas));
            ColumnNo += 1;

            BusChartBuf.AddColumn(Format(Enum::"Water Type"::"Sea water"));
            BusChartBuf.SetValueByIndex(0, ColumnNo, GetEmissionByWaterType(SustainabilityCue, Enum::"Water Type"::"Sea water", EmissionGas));
            ColumnNo += 1;

            BusChartBuf.AddColumn(Format(Enum::"Water Type"::"Surface water"));
            BusChartBuf.SetValueByIndex(0, ColumnNo, GetEmissionByWaterType(SustainabilityCue, Enum::"Water Type"::"Surface water", EmissionGas));
            ColumnNo += 1;

            BusChartBuf.AddColumn(Format(Enum::"Water Type"::"Third party water"));
            BusChartBuf.SetValueByIndex(0, ColumnNo, GetEmissionByWaterType(SustainabilityCue, Enum::"Water Type"::"Third party water", EmissionGas));
            ColumnNo += 1;
        end;
    end;

    local procedure CalcPeriods(var FromDate: array[12] of Date; var ToDate: array[12] of Date; var BusChartBuf: Record "Business Chart Buffer"): Boolean
    var
        MaxPeriodNo: Integer;
        i: Integer;
    begin
        MaxPeriodNo := ArrayLen(ToDate);
        ToDate[MaxPeriodNo] := CalcDate('<CY>', WorkDate());
        if ToDate[MaxPeriodNo] = 0D then
            exit(false);
        for i := MaxPeriodNo downto 1 do
            if i > 1 then begin
                FromDate[i] := BusChartBuf.CalcFromDate(ToDate[i]);
                ToDate[i - 1] := FromDate[i] - 1;
            end else
                FromDate[i] := CalcDate('<-CM>', ToDate[i]);

        exit(true);
    end;

    local procedure GetEmissionByScope(var SustainabilityCue: Record "Sustainability Cue"; Scope: Enum "Emission Scope"; EmissionGas: Text): Decimal
    begin
        SustainabilityCue.SetFilter("Scope Filter", '%1', Scope);
        exit(GetEmissionValue(SustainabilityCue, EmissionGas));
    end;

    local procedure GetEmissionByWaterWasteIntensityType(var SustainabilityCue: Record "Sustainability Cue"; WaterWasteIntensityType: Enum "Water/Waste Intensity Type"; EmissionGas: Text): Decimal
    begin
        SustainabilityCue.SetFilter("Water/Waste Int. Type Filter", '%1', WaterWasteIntensityType);
        exit(GetEmissionValue(SustainabilityCue, EmissionGas));
    end;

    local procedure GetEmissionByWaterType(var SustainabilityCue: Record "Sustainability Cue"; WaterType: Enum "Water Type"; EmissionGas: Text): Decimal
    begin
        SustainabilityCue.SetFilter("Water Type Filter", '%1', WaterType);
        exit(GetEmissionValue(SustainabilityCue, EmissionGas));
    end;

    local procedure GetEmissionValue(var SustainabilityCue: Record "Sustainability Cue"; EmissionGas: Text) Value: Decimal
    begin
        case EmissionGas of
            GetCO2():
                begin
                    SustainabilityCue.CalcFields("Emission CO2");
                    Value := SustainabilityCue."Emission CO2";
                end;
            GetCH4():
                begin
                    SustainabilityCue.CalcFields("Emission CH4");
                    Value := SustainabilityCue."Emission CH4";
                end;
            GetN2O():
                begin
                    SustainabilityCue.CalcFields("Emission N2O");
                    Value := SustainabilityCue."Emission N2O";
                end;
            GetWater():
                begin
                    SustainabilityCue.CalcFields("Water Intensity", "Discharged Into Water");
                    Value := SustainabilityCue."Water Intensity" + SustainabilityCue."Discharged Into Water";
                end;
            GetWaste():
                begin
                    SustainabilityCue.CalcFields("Waste Intensity");
                    Value := SustainabilityCue."Waste Intensity";
                end;
            GetCO2e():
                begin
                    SustainabilityCue.CalcFields("CO2e Emission");
                    Value := SustainabilityCue."CO2e Emission";
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