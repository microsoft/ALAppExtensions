pageextension 27036 "DIOT Payment Journal" extends "Payment Journal"
{
    layout
    {
        addafter(Description)
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