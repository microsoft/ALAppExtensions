namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Capacity;

pageextension 6265 "Sust. Capacity Ledger Entries" extends "Capacity Ledger Entries"
{
    layout
    {
        addafter("No.")
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Overhead Cost")
        {
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