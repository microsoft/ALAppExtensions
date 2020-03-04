pageextension 57645 "Team Member Role Center BF" extends "Team Member Role Center"
{
    actions
    {
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Blanket Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("<Page Posted Purchase Receipts>")
        {
            ApplicationArea = BFOrders;
        }
        modify("<Page Purchase Orders>")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = BFOrders;
        }
    }
}