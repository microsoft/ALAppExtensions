namespace Microsoft.Sustainability.Sales;

using Microsoft.Sales.Document;

pageextension 6239 "Sust. Sales Order Stats." extends "Sales Order Statistics"
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
                    ToolTip = 'Specifies the Total CO2e for Purchase Order';
                }
                field("Posted Total CO2e"; Rec."Posted Total CO2e")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Total CO2e';
                    ToolTip = 'Specifies the Posted Total CO2e for Purchase Order';
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