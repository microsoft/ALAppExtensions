pageextension 57607 "Sales Quote BF" extends "Sales Quote"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = BFOrders;
        }
    }
}