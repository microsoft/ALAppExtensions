namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;

pageextension 6247 "Sust. Prod. Order Components" extends "Prod. Order Components"
{
    layout
    {
        addafter("Routing Link Code")
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