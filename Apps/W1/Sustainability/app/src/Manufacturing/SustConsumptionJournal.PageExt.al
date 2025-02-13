namespace Microsoft.Sustainability.Manufacturing;

using Microsoft.Manufacturing.Journal;

pageextension 6251 "Sust. Consumption Journal" extends "Consumption Journal"
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
        addafter("Unit Amount")
        {
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}