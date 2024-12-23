namespace Microsoft.Sustainability.Transfer;

using Microsoft.Inventory.Transfer;

pageextension 6259 "Sust. Transfer Order Subform" extends "Transfer Order Subform"
{
    layout
    {
        addafter(Description)
        {
            field("Sust. Account No."; Rec."Sust. Account No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Sustainability Account No. field.';
            }
        }
        addafter("Receipt Date")
        {
            field("Total CO2e"; Rec."Total CO2e")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the value of the Total CO2e field.';
            }
        }
    }
}