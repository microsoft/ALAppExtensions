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
            field("Energy Source Code"; Rec."Energy Source Code")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Energy Source Code field.';
            }
        }
        addafter("Qty. Assigned")
        {
            field("Renewable Energy"; Rec."Renewable Energy")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Renewable Energy field.';
            }
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
            field("Energy Consumption"; Rec."Energy Consumption")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Energy Consumption field.';
            }
            field("Source of Emission Data"; Rec."Source of Emission Data")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Source of Emission Data field.';
            }
            field("Emission Verified"; Rec."Emission Verified")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission Verified field.';
            }
            field("CBAM Compliance"; Rec."CBAM Compliance")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the CBAM Compliance field.';
            }
            field("Total Emission Cost"; Rec."Total Emission Cost")
            {
                Visible = false and SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total Emission Cost field.';
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