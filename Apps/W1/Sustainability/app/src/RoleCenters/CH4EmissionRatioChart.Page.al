namespace Microsoft.Sustainability.RoleCenters;

using System.Visualization;
using System.Integration;

page 6246 "CH4 Emission Ratio Chart"
{
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    Caption = 'CH4 Emission Ratio Chart';

    layout
    {
        area(Content)
        {
            usercontrol(BusinessChart; BusinessChart)
            {
                ApplicationArea = Basic, Suite;

                trigger AddInReady()
                begin
                    UpdateChartData();
                end;

                trigger Refresh()
                begin
                    UpdateChartData();
                end;
            }
        }
    }

    var
        SustainabilityChartMgmt: Codeunit "Sustainability Chart Mgmt.";

    local procedure UpdateChartData()
    begin
        SustainabilityChartMgmt.GenerateChartByEmissionGas(Rec, 'CH4');
        Rec.UpdateChart(CurrPage.BusinessChart);
    end;
}