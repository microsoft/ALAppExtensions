namespace Microsoft.Sustainability.FinancialReporting;

using Microsoft.Finance.Analysis;

pageextension 6223 "Sust. Analysis View Entries" extends "Analysis View Entries"
{
    layout
    {
        addafter("Credit Amount")
        {
            field("Emission CO2"; Rec."Emission CO2")
            {
                ApplicationArea = All;
                Caption = 'Emission CO2';
                ToolTip = 'Specifies the value of the Emission CO2 field.';
            }
            field("Emission CH4"; Rec."Emission CH4")
            {
                ApplicationArea = All;
                Caption = 'Emission CH4';
                ToolTip = 'Specifies the value of the Emission CH4 field.';
            }
            field("Emission N2O"; Rec."Emission N2O")
            {
                ApplicationArea = All;
                Caption = 'Emission N2O';
                ToolTip = 'Specifies the value of the Emission N2O field.';
            }
            field("CO2e Emission"; Rec."CO2e Emission")
            {
                ApplicationArea = All;
            }
            field("Carbon Fee"; Rec."Carbon Fee")
            {
                ApplicationArea = All;
            }

        }
    }
}