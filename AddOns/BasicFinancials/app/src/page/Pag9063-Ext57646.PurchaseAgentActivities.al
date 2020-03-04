pageextension 57646 "Purchase Agent Activities BF" extends "Purchase Agent Activities"
{
    actions
    {
        modify("New Purchase Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("New Purchase Quote")
        {
            ApplicationArea = BFOrders;
        }
        modify("New Purchase Return Order")
        {
            ApplicationArea = BFOrders;
        }
    }
}