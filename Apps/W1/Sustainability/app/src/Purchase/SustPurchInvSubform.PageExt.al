namespace Microsoft.Sustainability.Purchase;

using Microsoft.Sustainability.Setup;
using Microsoft.Purchases.Document;

pageextension 6214 "Sust. Purch. Inv. Subform" extends "Purch. Invoice Subform"
{
    layout
    {
        addafter("Bin Code")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Qty. Assigned")
        {
            field("Emission CO2 Per Unit"; Rec."Emission CO2 Per Unit")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CO2 Per Unit field.';
            }
            field("Emission CH4 Per Unit"; Rec."Emission CH4 Per Unit")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CH4 Per Unit field.';
            }
            field("Emission N2O Per Unit"; Rec."Emission N2O Per Unit")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission N2O Per Unit field.';
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

        SustainabilityVisible := SustainabilitySetup."Use Emissions In Purch. Doc.";
    end;

    var
        SustainabilityVisible: Boolean;
}