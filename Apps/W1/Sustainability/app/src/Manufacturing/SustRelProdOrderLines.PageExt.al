namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;

pageextension 6249 "Sust. Rel. Prod. Order Lines" extends "Released Prod. Order Lines"
{
    layout
    {
        addafter("Cost Amount")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}