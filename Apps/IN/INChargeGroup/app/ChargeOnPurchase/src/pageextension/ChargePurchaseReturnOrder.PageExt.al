pageextension 18525 "Charge Purchase Return Order" extends "Purchase Return Order"
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