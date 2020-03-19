pageextension 20660 "Team Member Role Center BF" extends "Team Member Role Center"
{
    actions
    {
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("<Page Posted Purchase Receipts>")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("<Page Purchase Orders>")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}