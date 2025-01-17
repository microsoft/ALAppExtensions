namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.History;
using Microsoft.Sustainability.Setup;

pageextension 6237 "Sust. Pstd Sales Cr. Memo. Sub" extends "Posted Sales Cr. Memo Subform"
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
        addafter("Line Amount")
        {
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