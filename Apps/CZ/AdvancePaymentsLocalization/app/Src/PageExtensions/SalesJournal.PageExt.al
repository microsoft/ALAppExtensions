#if not CLEAN19
#pragma warning disable AL0432
pageextension 31041 "Sales Journal CZZ" extends "Sales Journal"
{
    layout
    {
        modify("Prepayment Type")
        {
            Visible = false;
        }
        modify(Prepayment)
        {
            Visible = false;
        }
    }

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
}
#pragma warning restore AL0432
#endif
