pageextension 31029 "Sales Order Subform CZZ" extends "Sales Order Subform"
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
