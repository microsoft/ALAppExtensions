namespace Microsoft.Sustainability.RoleCenters;

using System.Integration;
using System.Visualization;

page 6283 "Water Intensity Bar Chart"
{
    PageType = CardPart;
    SourceTable = "Business Chart Buffer";
    Caption = 'Water Intensity Bar Chart';

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
        SustainabilityChartMgmt.UpdateBarByEmissionGas(Rec, SustainabilityChartMgmt.GetWater(), false);
        Rec.UpdateChart(CurrPage.BusinessChart);
    end;
}