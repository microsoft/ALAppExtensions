namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.Document;

pageextension 6218 "Sust. Purch. Statistics" extends "Purchase Statistics"
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
                    ToolTip = 'Specifies the C02 emissions.';
                }
                field("Emission CH4"; Rec."Emission CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission CH4';
                    ToolTip = 'Specifies the CH4 emissions.';
                }
                field("Emission N2O"; Rec."Emission N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission N2O';
                    ToolTip = 'Specifies the N2O emissions.';
                }
                field("Energy Consumption"; Rec."Energy Consumption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Emission N2O';
                    ToolTip = 'Specifies the Energy Consumption.';
                }
                field("Posted Emission C02"; Rec."Posted Emission C02")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission C02';
                    ToolTip = 'Specifies the posted C02 emissions.';
                }
                field("Posted Emission CH4"; Rec."Posted Emission CH4")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission CH4';
                    ToolTip = 'Specifies the posted CH4 emissions.';
                }
                field("Posted Emission N2O"; Rec."Posted Emission N2O")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Emission N2O';
                    ToolTip = 'Specifies the posted N2O emissions.';
                }
                field("Posted Energy Consumption"; Rec."Posted Energy Consumption")
                {
                    ApplicationArea = Basic, Suite;
                    Caption = 'Posted Energy Consumption';
                    ToolTip = 'Specifies the posted Energy Consumption.';
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