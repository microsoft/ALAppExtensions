namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Sustainability.Setup;

pageextension 6244 "Sust. Prod. BOM Version Lines" extends "Production BOM Version Lines"
{
    layout
    {
        addafter("Routing Link Code")
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

        SustainabilityVisible := SustainabilitySetup."Item Emissions" and SustainabilitySetup."Enable Value Chain Tracking";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}