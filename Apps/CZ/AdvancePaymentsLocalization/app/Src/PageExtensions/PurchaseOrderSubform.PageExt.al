pageextension 31038 "Purchase Order Subform CZZ" extends "Purchase Order Subform"
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
        modify("Prepmt Amt Deducted")
        {
            Visible = false;
        }
    }
}
