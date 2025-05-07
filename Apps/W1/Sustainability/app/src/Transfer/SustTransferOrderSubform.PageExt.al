namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;
using Microsoft.Sustainability.Setup;

pageextension 6259 "Sust. Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Receipt Date")
        {
            field("Total CO2e"; Rec."Total CO2e")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                Editable = not Rec."Completely Shipped";
                ToolTip = 'Specifies the value of the Total CO2e field.';
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

        SustainabilityVisible := SustainabilitySetup."Enable Value Chain Tracking";
    end;

    var
        SustainabilitySetup: Record "Sustainability Setup";
        SustainabilityVisible: Boolean;
}