pageextension 31045 "Sales Order Statistics CZZ" extends "Sales Order Statistics"
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
