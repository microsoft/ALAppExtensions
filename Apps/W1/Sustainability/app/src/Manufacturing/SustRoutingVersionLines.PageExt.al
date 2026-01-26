namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Routing;
using Microsoft.Sustainability.Setup;

pageextension 6246 "Sust. Routing Version Lines" extends "Routing Version Lines"
{
    layout
    {
        addafter("Unit Cost per")
        {
            field("CO2e per Unit"; Rec."CO2e per Unit")
            {
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the value of the CO2e per Unit field.';
            }
        }
    }

    trigger OnOpenPage()
    begin
        VisibleSustainabilityControls();
    end;

    local procedure VisibleSustainabilityControls()
    begin
        SustainabilitySetup.GetRecordOnce();

        SustainabilityVisible := SustainabilitySetup."Work/Machine Center Emissions" and SustainabilitySetup."Enable Value Chain Tracking";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}