pageextension 57632 "Purchase Quote BF" extends "Purchase Quote"
{
    actions
    {
        modify(MakeOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}