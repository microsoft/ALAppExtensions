pageextension 20664 "Vendor Statistics FactBox BF" extends "Vendor Statistics FactBox"
{
    layout
    {
        modify("Outstanding Orders (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Amt. Rcd. Not Invoiced (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}