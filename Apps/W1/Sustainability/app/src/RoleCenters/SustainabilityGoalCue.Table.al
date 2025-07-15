namespace Microsoft.Sustainability.RoleCenters;

using Microsoft.Sustainability.Scorecard;

table 6221 "Sustainability Goal Cue"
{
    Caption = 'Sustainability Goal Cue';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Primary Key"; Code[10])
        {
            Caption = 'Primary Key';
        }
        field(2; "Realized % for CO2"; Decimal)
        {
            Caption = 'Realized % for CO2';
            Editable = false;
        }
        field(3; "Realized % for CH4"; Decimal)
        {
            Caption = 'Realized % for CH4';
            Editable = false;
        }
        field(4; "Realized % for N2O"; Decimal)
        {
            Caption = 'Realized % for N2O';
            Editable = false;
        }
        field(5; "CO2 % vs Baseline"; Decimal)
        {
            Caption = 'CO2 % vs Baseline';
            Editable = false;
        }
        field(6; "CH4 % vs Baseline"; Decimal)
        {
            Caption = 'CH4 % vs Baseline';
            Editable = false;
        }
        field(7; "N2O % vs Baseline"; Decimal)
        {
            Caption = 'N2O % vs Baseline';
            Editable = false;
        }
        field(10; "Realized % for Water"; Decimal)
        {
            Caption = 'Realized % for Water';
            Editable = false;
        }
        field(11; "Realized % for Waste"; Decimal)
        {
            Caption = 'Realized % for Waste';
            Editable = false;
        }
        field(12; "Water % vs Baseline"; Decimal)
        {
            Caption = 'Water % vs Baseline';
            Editable = false;
        }
        field(13; "Waste % vs Baseline"; Decimal)
        {
            Caption = 'Waste % vs Baseline';
            Editable = false;
        }
        field(20; "Date Filter"; Date)
        {
            FieldClass = FlowFilter;
            Caption = 'Date Filter';
        }
        field(30; "Last Refreshed Datetime"; DateTime)
        {
            Caption = 'Last Refreshed Datetime';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(Key1; "Primary Key")
        {
            Clustered = true;
        }
    }

    var
        FavorableStyleLbl: Label 'Favorable';
        AmbiguousStyleLbl: Label 'Ambiguous';
        UnfavorableStyleLbl: Label 'Unfavorable';

    internal procedure ShowMainSustainabilityGoal()
    var
        SustainabilityGoal: Record "Sustainability Goal";
    begin
        SustainabilityGoal.SetRange("Main Goal", true);

        Page.Run(Page::"Sustainability Goals", SustainabilityGoal);
    end;

    internal procedure GetRealizedPerForEmissionStyle(EmissionGas: Text; EmissionValue: Decimal): Text
    var
        SustainabilityChartMgmt: Codeunit "Sustainability Chart Mgmt.";
    begin
        case EmissionGas of
            SustainabilityChartMgmt.GetCH4(), SustainabilityChartMgmt.GetCO2(), SustainabilityChartMgmt.GetN2O(), SustainabilityChartMgmt.GetWater():
                begin
                    if EmissionValue <= 75 then
                        exit(FavorableStyleLbl);

                    if EmissionValue <= 90 then
                        exit(AmbiguousStyleLbl);

                    exit(UnfavorableStyleLbl);
                end;
            SustainabilityChartMgmt.GetWaste():
                begin
                    if EmissionValue <= 60 then
                        exit(FavorableStyleLbl);

                    if EmissionValue <= 80 then
                        exit(AmbiguousStyleLbl);

                    exit(UnfavorableStyleLbl);
                end;
        end;
    end;

    internal procedure GetBaselinePerVsEmissionStyle(EmissionGas: Text; EmissionValue: Decimal): Text
    var
        SustainabilityChartMgmt: Codeunit "Sustainability Chart Mgmt.";
    begin
        case EmissionGas of
            SustainabilityChartMgmt.GetCH4(), SustainabilityChartMgmt.GetCO2(), SustainabilityChartMgmt.GetN2O(), SustainabilityChartMgmt.GetWater():
                begin
                    if EmissionValue <= 65 then
                        exit(FavorableStyleLbl);

                    if EmissionValue <= 85 then
                        exit(AmbiguousStyleLbl);

                    exit(UnfavorableStyleLbl);
                end;
            SustainabilityChartMgmt.GetWaste():
                begin
                    if EmissionValue <= 50 then
                        exit(FavorableStyleLbl);

                    if EmissionValue <= 75 then
                        exit(AmbiguousStyleLbl);

                    exit(UnfavorableStyleLbl);
                end;
        end;
    end;
}