namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Routing;
using Microsoft.Sustainability.Setup;

pageextension 6278 "Sust. Routing" extends Routing
{
    actions
    {
        addafter("Routing Sheet")
        {
            action("Calculate CO2e")
            {
                Caption = 'Calculate CO2e';
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate CO2e action.';

                trigger OnAction()
                begin
                    RunCalculateCO2e();
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

    local procedure RunCalculateCO2e()
    var
        RoutingHeader: Record "Routing Header";
        CalculateCO2e: Report "Sust. Routing Calculate CO2e";
    begin
        RoutingHeader.SetFilter("No.", Rec."No.");

        CalculateCO2e.SetHideValidation(true);
        CalculateCO2e.SetTableView(RoutingHeader);
        CalculateCO2e.Run();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}