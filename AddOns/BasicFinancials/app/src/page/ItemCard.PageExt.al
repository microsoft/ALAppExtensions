pageextension 20622 "Item Card BF" extends "Item Card"
{
    actions
    {
        modify(Orders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Action83)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}