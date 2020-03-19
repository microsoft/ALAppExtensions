pageextension 20617 "Customer Statistics FactBox BF" extends "Customer Statistics FactBox"
{
    layout
    {
        modify("Outstanding Orders (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Shipped Not Invoiced (LCY)")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
