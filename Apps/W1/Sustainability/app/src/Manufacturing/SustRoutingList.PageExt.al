namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Routing;
using Microsoft.Sustainability.Setup;

pageextension 6279 "Sust. Routing List" extends "Routing List"
{
    actions
    {
        addafter("Routing Sheet")
        {
            action("Calculate CO2e")
            {
                Caption = 'Calculate CO2e';
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate CO2e action.';

                trigger OnAction()
                var
                    CalculateCO2e: Report "Sust. Routing Calculate CO2e";
                begin
                    CalculateCO2e.SetHideValidation(true);
                    CalculateCO2e.Run();
                end;
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