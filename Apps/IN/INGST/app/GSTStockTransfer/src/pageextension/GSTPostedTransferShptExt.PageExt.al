pageextension 18392 "GST Posted Transfer Shpt. Ext" extends "Posted Transfer Shpt. Subform"
{
    layout
    {
        addafter(Quantity)
        {
            field(Amount; Rec.Amount)
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total amount for the item on the transfer line.';
            }

            field("Custom Duty Amount"; Rec."Custom Duty Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the custom duty amount  on the transfer line.';
            }
            field("GST Assessable Value"; Rec."GST Assessable Value")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the GST assessable value on the transfer line.';
            }
        }
    }
}