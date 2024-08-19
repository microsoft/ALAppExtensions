namespace Microsoft.Sustainability.Purchase;

using Microsoft.Purchases.History;

pageextension 6213 "Sust. Pstd Cr. Memo. Subform" extends "Posted Purch. Cr. Memo Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Line Amount")
        {
            field("Emission CO2"; Rec."Emission CO2")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CO2 field.';
            }
            field("Emission CH4"; Rec."Emission CH4")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission CH4 field.';
            }
            field("Emission N2O"; Rec."Emission N2O")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Emission N2O field.';
            }
        }
    }
}