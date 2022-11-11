#if not CLEAN19
#pragma warning disable AL0432
pageextension 31040 "Purch. Invoice Subform CZZ" extends "Purch. Invoice Subform"
{
    layout
    {
        modify("Prepayment %")
        {
            Visible = false;
        }
        modify("Prepmt. Line Amount")
        {
            Visible = false;
        }
        modify("Prepmt. Amt. Inv.")
        {
            Visible = false;
        }
        modify("Prepmt Amt to Deduct")
        {
            Visible = false;
        }
    }
}
#pragma warning restore AL0432
#endif
