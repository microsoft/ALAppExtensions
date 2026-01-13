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
            field("Unit for Sust. Formulas"; Rec."Unit for Sust. Formulas")
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the unit of measure used for formulas to calculate total emissions based on inbound information.';
            }
            field("Fuel/Electricity"; Rec."Fuel/Electricity")
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the fuel or electricity of the purchase line.';
            }
            field(Distance; Rec.Distance)
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the distance of the purchase line.';
            }
            field("Custom Amount"; Rec."Custom Amount")
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the custom amount of the purchase line.';
            }
            field("Installation Multiplier"; Rec."Installation Multiplier")
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the installation multiplier of the purchase line.';
            }
            field("Time Factor"; Rec."Time Factor")
            {
                Visible = SustainabilityFormulasFieldVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the time factor of the purchase line.';
            }
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
        SustainabilitySetup.GetRecordOnce();

        SustainabilityVisible := SustainabilitySetup."Use Emissions In Purch. Doc.";
        SustainabilityFormulasFieldVisible := SustainabilitySetup."Use Formulas In Purch. Docs";
    end;

    var
        SustainabilityVisible: Boolean;
        SustainabilityFormulasFieldVisible: Boolean;
}