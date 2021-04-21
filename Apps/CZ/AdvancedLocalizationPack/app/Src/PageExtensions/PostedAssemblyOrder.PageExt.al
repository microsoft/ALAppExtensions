pageextension 31255 "Posted Assembly Order CZA" extends "Posted Assembly Order"
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
