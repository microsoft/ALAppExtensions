pageextension 31024 "VAT Entries CZZ" extends "VAT Entries"
{
    layout
    {
        addlast(Control1)
        {
            field("Advance Letter No. CZZ"; Rec."Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter no.';
                Editable = false;
            }
        }
    }
}
