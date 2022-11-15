#if not CLEAN19
#pragma warning disable AL0432
pageextension 31047 "Sales Statistics CZZ" extends "Sales Statistics"
{
    layout
    {
        modify("Prepayment (Deduct)")
        {
            Visible = false;
        }
        modify("Invoicing (Final)")
        {
            Visible = false;
        }
    }
}
#pragma warning restore AL0432
#endif
