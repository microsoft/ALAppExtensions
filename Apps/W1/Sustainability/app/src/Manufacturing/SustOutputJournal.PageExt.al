namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Journal;

pageextension 6266 "Sust. Output Journal" extends "Output Journal"
{
    layout
    {
        addafter(Description)
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Scrap Quantity")
        {
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                Editable = false;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}