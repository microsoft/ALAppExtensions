namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.ProductionBOM;
using Microsoft.Sustainability.Setup;

pageextension 6273 "Sust. Production BOM" extends "Production BOM"
{
    actions
    {
        addafter(DocAttach)
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

        SustainabilityVisible := SustainabilitySetup."Item Emissions" and SustainabilitySetup."Enable Value Chain Tracking";
    end;

    local procedure RunCalculateCO2e()
    var
        ProductionBOMHeader: Record "Production BOM Header";
        CalculateCO2e: Report "Sust. Prod. BOM Calculate CO2e";
    begin
        ProductionBOMHeader.SetFilter("No.", Rec."No.");

        CalculateCO2e.SetHideValidation(true);
        CalculateCO2e.SetTableView(ProductionBOMHeader);
        CalculateCO2e.Run();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}