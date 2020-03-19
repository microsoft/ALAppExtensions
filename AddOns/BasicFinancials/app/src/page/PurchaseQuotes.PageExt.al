pageextension 20633 "Purchase Quotes BF" extends "Purchase Quotes"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}