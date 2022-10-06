#if not CLEAN19
#pragma warning disable AL0432
pageextension 31057 "VAT Statement CZZ" extends "VAT Statement"
{
    layout
    {
        modify("Prepayment Type")
        {
            Visible = false;
        }
    }
}
#pragma warning restore AL0432
#endif
