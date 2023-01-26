pageextension 18523 "Charge Purchase Order Ext" extends "Purchase Order"
{
    layout
    {
        addafter("Responsibility Center")
        {
            field("Charge Group Code"; Rec."Charge Group Code")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the charge group code is assigned to the document';
            }
        }
    }
}