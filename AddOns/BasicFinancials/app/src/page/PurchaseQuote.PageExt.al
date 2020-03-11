pageextension 57702 "Purchase Quote BF" extends "Purchase Quote"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}