pageextension 57620 "Finance Manager Role Center BF" extends "Finance Manager Role Center"
{
    actions
    {
        modify("Posted Sales Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}