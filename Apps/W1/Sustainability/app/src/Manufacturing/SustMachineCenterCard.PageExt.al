namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.MachineCenter;
using Microsoft.Sustainability.Setup;

pageextension 6232 "Sust. Machine Center Card" extends "Machine Center Card"
{
    layout
    {
        addafter(Warehouse)
        {
            group("Sustainability")
            {
                Caption = 'Sustainability';
                Visible = SustainabilityVisible;

                field("Default Sust. Account"; Rec."Default Sust. Account")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Default Sust. Account field.';
                }
                field("Default CO2 Emission"; Rec."Default CO2 Emission")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Default CO2 Emission field.';
                }
                field("Default CH4 Emission"; Rec."Default CH4 Emission")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Default CH4 Emission field.';
                }
                field("Default N2O Emission"; Rec."Default N2O Emission")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the Default N2O Emission field.';
                }
                field("CO2e per Unit"; Rec."CO2e per Unit")
                {
                    ApplicationArea = Basic, Suite;
                    ToolTip = 'Specifies the value of the CO2e per Unit field.';
                }
            }
        }
    }

    actions
    {
        addafter("Capacity Ledger E&ntries")
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
        MachineCenter: Record "Machine Center";
        CalculateCO2e: Report "Sust. Calculate CO2e";
    begin
        MachineCenter.SetFilter("No.", Rec."No.");
        CalculateCO2e.Initialize(1, true);
        CalculateCO2e.SetTableView(MachineCenter);
        CalculateCO2e.Run();
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}