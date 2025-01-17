namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Setup;

pageextension 6229 "Sust. Item Charges" extends "Item Charges"
{
    layout
    {
        addafter("VAT Prod. Posting Group")
        {
            field("Default Sust. Account"; Rec."Default Sust. Account")
            {
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the value of the Default Sust. Account field.';
            }
            field("Default CO2 Emission"; Rec."Default CO2 Emission")
            {
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the value of the Default CO2 Emission field.';
            }
            field("Default CH4 Emission"; Rec."Default CH4 Emission")
            {
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the value of the Default CH4 Emission field.';
            }
            field("Default N2O Emission"; Rec."Default N2O Emission")
            {
                ApplicationArea = Basic, Suite;
                Visible = SustainabilityVisible;
                ToolTip = 'Specifies the value of the Default N2O Emission field.';
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

        SustainabilityVisible := SustainabilitySetup."Item Charge Emissions";
    end;

    var
        SustainabilityVisible: Boolean;
}