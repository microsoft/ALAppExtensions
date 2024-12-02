namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.Document;

pageextension 6242 "Sust. Sales Statistics" extends "Sales Statistics"
{
    layout
    {
        addafter(Customer)
        {
            group(Sustainability)
            {
                Visible = EnableSustainability;
                Caption = 'Sustainability';
                field("Total CO2e"; Rec."Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Total CO2e';
                }
                field("Posted Total CO2e"; Rec."Posted Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Total CO2e';
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