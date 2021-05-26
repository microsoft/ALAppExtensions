pageextension 31242 "G/L Entries Preview CZA" extends "G/L Entries Preview"
{
    layout
    {
        addafter("Posting Date")
        {
            field("Closed CZA"; Rec."Closed CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies that the entry is closed.';
            }
        }
    }
}