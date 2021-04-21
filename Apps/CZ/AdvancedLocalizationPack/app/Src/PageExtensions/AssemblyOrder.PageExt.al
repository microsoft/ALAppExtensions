pageextension 31253 "Assembly Order CZA" extends "Assembly Order"
{
    layout
    {
        addlast(Posting)
        {
            field("Gen. Bus. Posting Group CZA"; Rec."Gen. Bus. Posting Group CZA")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the code for the General Business Posting Group that applies to the entry.';
            }
        }
    }
}
