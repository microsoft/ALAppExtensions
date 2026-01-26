namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;

pageextension 6263 "Sust. Transfer Shpt. Stats." extends "Transfer Shipment Statistics"
{
    layout
    {
        addafter(General)
        {
            group(Sustainability)
            {
                Visible = EnableSustainability;
                Caption = 'Sustainability';

                field("Total CO2e"; Rec."Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total CO2e';
                    ToolTip = 'Specifies the value of the Total CO2e field.';
                }
            }
        }
    }

    trigger OnOpenPage()
    begin
        EnableSustainabilityControl();
    end;

    trigger OnAfterGetCurrRecord()
    begin
        EnableSustainabilityControl();
    end;

    trigger OnAfterGetRecord()
    begin
        EnableSustainabilityControl();
    end;

    local procedure EnableSustainabilityControl()
    begin
        Rec.CalcFields("Sustainability Lines Exist");
        EnableSustainability := Rec."Sustainability Lines Exist";
    end;

    var
        EnableSustainability: Boolean;
}