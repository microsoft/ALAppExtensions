namespace Microsoft.Sustainability.Account;

using Microsoft.Finance.GeneralLedger.Account;
using Microsoft.Sustainability.Setup;

pageextension 6227 "Sust. G/L Account Card" extends "G/L Account Card"
{
    layout
    {
        addafter("Cost Accounting")
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

        SustainabilityVisible := SustainabilitySetup."G/L Account Emissions";
    end;

    var
        SustainabilityVisible: Boolean;
}