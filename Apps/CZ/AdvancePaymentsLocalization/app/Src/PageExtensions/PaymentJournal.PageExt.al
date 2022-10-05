pageextension 31049 "Payment Journal CZZ" extends "Payment Journal"
{
    layout
    {
#if not CLEAN19
#pragma warning disable AL0432
        modify(Prepayment)
        {
            Visible = false;
        }
        modify("Prepayment Type")
        {
            Visible = false;
        }
        modify("Advance VAT Base Amount")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
        addlast(Control1)
        {
            field("Advance Letter No. CZZ"; Rec."Advance Letter No. CZZ")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies advance letter no.';
            }
        }
    }
#if not CLEAN19
#pragma warning disable AL0432
    actions
    {
        modify("Link Advance Letters")
        {
            Visible = false;
        }
        modify("Link Whole Advance Letter")
        {
            Visible = false;
        }
        modify("UnLink Linked Advance Letters")
        {
            Visible = false;
        }
    }
#pragma warning restore AL0432
#endif
}
