pageextension 57633 "Purchase Quotes BF" extends "Purchase Quotes"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}