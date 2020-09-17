pageextension 20637 "PurchOrder From SalesOrder BF" extends "Purch. Order From Sales Order"
{
    actions
    {
        modify("Event")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Period)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(ShowAll)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(ShowUnavailable)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Timeline)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}