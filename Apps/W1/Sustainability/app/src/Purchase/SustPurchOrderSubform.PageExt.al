namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;
using Microsoft.Sustainability.Setup;

pageextension 6211 "Sust. Purch. Order Subform" extends "Purchase Order Subform"
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
        addafter("Quantity Invoiced")
        {
            field("Emission CO2"; Rec."Emission CO2")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CO2 field.';
            }
            field("Emission CH4"; Rec."Emission CH4")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CH4 field.';
            }
            field("Emission N2O"; Rec."Emission N2O")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission N2O field.';
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