pageextension 27032 "DIOT General Journal" extends "General Journal"
{
    layout
    {
        addafter("Gen. Prod. Posting Group")
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