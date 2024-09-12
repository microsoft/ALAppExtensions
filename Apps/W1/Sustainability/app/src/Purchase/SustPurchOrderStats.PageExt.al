namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;

pageextension 6217 "Sust. Purch. Order Stats." extends "Purchase Order Statistics"
{
    layout
    {
        addafter(Vendor)
        {
            group(Sustainability)
            {
                Visible = EnableSustainability;
                Caption = 'Sustainability';

                field("Emission C02"; Rec."Emission C02")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission C02';
                    ToolTip = 'Specifies the Emission C02 for Purchase Order';
                }
                field("Emission CH4"; Rec."Emission CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission CH4';
                    ToolTip = 'Specifies the Emission CH4 for Purchase Order';
                }
                field("Emission N2O"; Rec."Emission N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission N2O';
                    ToolTip = 'Specifies the Emission N2O for Purchase Order';
                }
                field("Posted Emission C02"; Rec."Posted Emission C02")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission C02';
                    ToolTip = 'Specifies the Posted Emission C02 for Purchase Order';
                }
                field("Posted Emission CH4"; Rec."Posted Emission CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission CH4';
                    ToolTip = 'Specifies the Posted Emission CH4 for Purchase Order';
                }
                field("Posted Emission N2O"; Rec."Posted Emission N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission N2O';
                    ToolTip = 'Specifies the Posted Emission N2O for Purchase Order';
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