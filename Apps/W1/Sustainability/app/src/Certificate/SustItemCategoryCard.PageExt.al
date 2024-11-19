namespace Microsoft.Sustainability.Certificate;

using Microsoft.Inventory.Item;
using Microsoft.Sustainability.Setup;

pageextension 6228 "Sust. Item Category Card" extends "Item Category Card"
{
    layout
    {
        addafter(Attributes)
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

        SustainabilityVisible := SustainabilitySetup."Item Emissions";
    end;

    var
        SustainabilityVisible: Boolean;
}