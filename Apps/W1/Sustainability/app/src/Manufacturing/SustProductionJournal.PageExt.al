namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Journal;

pageextension 6250 "Sust. Production Journal" extends "Production Journal"
{
    layout
    {
        addafter("Scrap Quantity")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
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