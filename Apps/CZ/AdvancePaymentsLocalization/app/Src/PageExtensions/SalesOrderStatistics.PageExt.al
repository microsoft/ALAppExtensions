pageextension 31045 "Sales Order Statistics CZZ" extends "Sales Order Statistics"
{
    layout
    {
        modify(Prepayment)
        {
            Visible = false;
        }
    }
}
