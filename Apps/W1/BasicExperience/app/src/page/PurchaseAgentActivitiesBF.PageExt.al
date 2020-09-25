pageextension 20631 "Purchase Agent Activities BF" extends "Purchase Agent Activities"
{
    actions
    {
        modify("New Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("New Purchase Quote")
        {
            ApplicationArea = Advanced, BFOrders;
        }

        modify("New Purchase Return Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}