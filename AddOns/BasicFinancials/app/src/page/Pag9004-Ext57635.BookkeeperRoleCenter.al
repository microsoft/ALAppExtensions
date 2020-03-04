pageextension 57635 "Bookkeeper Role Center BF" extends "Bookkeeper Role Center"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Return Shipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Return Receipts")
        {
            ApplicationArea = BFOrders;
        }
    }
}