pageextension 31046 "Purchase Order Statistics CZZ" extends "Purchase Order Statistics"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
#if not CLEAN19
#pragma warning disable AL0432
        modify("Prepayment (Deduct)")
        {
            Visible = false;
        }
        modify("Invoicing (Final)")
        {
            Visible = false;
        }
#pragma warning restore AL0432
#endif
    }
}
