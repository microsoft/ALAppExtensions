pageextension 18604 "Gate Entry Sales Order" extends "Sales Order"
{
    layout
    {
        addlast("Shipping and Billing")
        {
            field("LR/RR No."; Rec."LR/RR No.")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt number of the document.';
            }
            field("LR/RR Date"; Rec."LR/RR Date")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the lorry receipt date.';
            }
        }
    }
}