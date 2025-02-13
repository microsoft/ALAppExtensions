namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Document;

pageextension 6248 "Sust. Prod. Order Routing" extends "Prod. Order Routing"
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