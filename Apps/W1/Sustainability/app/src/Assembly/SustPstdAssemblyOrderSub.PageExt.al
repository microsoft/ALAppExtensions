namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.History;

pageextension 6254 "Sust. Pstd Assembly Order Sub." extends "Posted Assembly Order Subform"
{
    layout
    {
        addafter("Location Code")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Cost Amount")
        {
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}