pageextension 20650 "Sales Quote BF" extends "Sales Quote"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}