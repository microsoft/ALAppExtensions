pageextension 57605 "Item Card BF" extends "Item Card"
{
    actions
    {
        modify(Orders)
        {
            ApplicationArea = BFOrders;
        }
        modify(Action83)
        {
            ApplicationArea = BFOrders;
        }
    }
}