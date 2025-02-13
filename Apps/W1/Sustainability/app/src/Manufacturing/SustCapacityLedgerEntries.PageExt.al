namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Capacity;
using Microsoft.Sustainability.Setup;

pageextension 6265 "Sust. Capacity Ledger Entries" extends "Capacity Ledger Entries"
{
    layout
    {
        addafter("No.")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Overhead Cost")
        {
            field("CO2e per Unit"; Rec."CO2e per Unit")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the CO2e per Unit field.';
            }
            field("Total CO2e"; Rec."Total CO2e")
            {
                Visible = SustainabilityVisible;
                ApplicationArea = Basic, Suite;
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