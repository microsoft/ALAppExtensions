pageextension 31274 "Payment Journal CZC" extends "Payment Journal"
{
    layout
    {
        addafter("Applies-to ID")
        {
            field("Compensation CZC"; Rec."Compensation CZC")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies to suggest compensation of entries in the same currency for the general journal lines';
            }
        }
    }
}
