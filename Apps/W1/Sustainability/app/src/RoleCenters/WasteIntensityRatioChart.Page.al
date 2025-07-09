namespace Microsoft.Sustainability.RoleCenters;

using System.Integration;
using System.Visualization;

page 6281 "Waste Intensity Ratio Chart"
{
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    Caption = 'Waste Intensity Ratio Chart';

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
        SustainabilityChartMgmt.GenerateChartByEmissionGas(Rec, SustainabilityChartMgmt.GetWaste());
        Rec.UpdateChart(CurrPage.BusinessChart);
    end;
}