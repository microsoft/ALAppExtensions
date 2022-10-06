#if not CLEAN19
#pragma warning disable AL0432
pageextension 31051 "IC General Journal CZZ" extends "IC General Journal"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
        modify("Prepayment Type")
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
