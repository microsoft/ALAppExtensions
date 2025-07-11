namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Setup;

pageextension 6271 "Sust. Item List" extends "Item List"
{
    actions
    {
        addafter(PrintLabel)
        {
            action("Calculate CO2e")
            {
                Caption = 'Calculate CO2e';
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible and not SustainabilityAllGasesAsCO2eVisible;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate CO2e action.';

                trigger OnAction()
                var
                    CalculateCO2e: Report "Sust. Item Calculate CO2e";
                begin
                    CalculateCO2e.Run();
                end;
            }
            action("Calculate Total CO2e")
            {
                Caption = 'Calculate Total CO2e';
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible and SustainabilityAllGasesAsCO2eVisible;
                Image = Calculate;
                Promoted = true;
                PromotedCategory = Process;
                ToolTip = 'Executes the Calculate Total CO2e action.';

                trigger OnAction()
                var
                    CalculateCO2e: Report "Sust. Item Calculate CO2e";
                begin
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
    var
        SustainabilitySetup: Record "Sustainability Setup";
    begin
        SustainabilitySetup.Get();

        SustainabilityVisible := SustainabilitySetup."Item Emissions";
        SustainabilityAllGasesAsCO2eVisible := SustainabilitySetup."Use All Gases As CO2e";
    end;

    var
        SustainabilityVisible: Boolean;
        SustainabilityAllGasesAsCO2eVisible: Boolean;
}