pageextension 27037 "DIOT VAT Entries" extends "VAT Entries"
{
    layout
    {
        addafter("Country/Region Code")
        {
            field("DIOT Type of Operation"; "DIOT Type of Operation")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'DIOT Type of Operation';
                ToolTip = 'Specifies the DIOT operation type for this entry.';
            }
        }
    }
}