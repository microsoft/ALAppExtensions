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

        SustainabilityVisible := SustainabilitySetup."Work/Machine Center Emissions";
    end;

    var
        SustainabilityVisible: Boolean;
}