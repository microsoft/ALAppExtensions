pageextension 57614 "PurchOrder From SalesOrder BF" extends "Purch. Order From Sales Order"
{
    actions
    {
        modify("Event")
        {
            ApplicationArea = BFOrders;
        }
        modify(Period)
        {
            ApplicationArea = BFOrders;
        }
        modify(ShowAll)
        {
            ApplicationArea = BFOrders;
        }
        modify(ShowUnavailable)
        {
            ApplicationArea = BFOrders;
        }
        modify(Timeline)
        {
            ApplicationArea = BFOrders;
        }
    }
}