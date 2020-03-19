pageextension 20652 "Sales Quotes BF" extends "Sales Quotes"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}