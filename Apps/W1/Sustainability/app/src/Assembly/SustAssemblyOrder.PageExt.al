namespace Microsoft.Sustainability.Assembly;

using Microsoft.Assembly.Document;

pageextension 6258 "Sust. Assembly Order" extends "Assembly Order"
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
            field("CO2e per Unit"; Rec."CO2e per Unit")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the CO2e per Unit field.';
            }
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}