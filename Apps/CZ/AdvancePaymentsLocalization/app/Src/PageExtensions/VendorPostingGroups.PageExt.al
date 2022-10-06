#if not CLEAN19
#pragma warning disable AL0432
pageextension 31192 "Vendor Posting Groups CZZ" extends "Vendor Posting Groups"
{
    layout
    {
        modify("Advance Account")
        {
            Visible = false;
        }
    }
}
#pragma warning restore AL0432
#endif
