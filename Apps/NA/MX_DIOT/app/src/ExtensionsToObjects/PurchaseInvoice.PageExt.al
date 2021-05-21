pageextension 27033 "DIOT Purchase Invoice" extends "Purchase Invoice"
{
    layout
    {
        addafter("Purchaser Code")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type for this document.';
            }
        }
    }
}