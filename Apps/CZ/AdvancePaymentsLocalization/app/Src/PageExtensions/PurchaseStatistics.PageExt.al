#if not CLEAN19
#pragma warning disable AL0432
pageextension 31048 "Purchase Statistics CZZ" extends "Purchase Statistics"
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
