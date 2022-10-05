#if not CLEAN19
#pragma warning disable AL0432
pageextension 31193 "Cash Document CZZ" extends "Cash Document CZP"
{
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
#endif