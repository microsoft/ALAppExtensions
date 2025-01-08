namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;

pageextension 6276 "Sust. Fin. Prod. Order Lines" extends "Finished Prod. Order Lines"
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