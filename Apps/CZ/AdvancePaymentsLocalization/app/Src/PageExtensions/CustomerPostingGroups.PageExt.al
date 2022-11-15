#if not CLEAN19
#pragma warning disable AL0432
pageextension 31191 "Customer Posting Groups CZZ" extends "Customer Posting Groups"
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
