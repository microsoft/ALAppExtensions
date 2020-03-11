pageextension 57637 "Purch Agent Role Center BF" extends "Purchasing Agent Role Center"
{
    actions
    {
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(PurchaseOrders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase &Quote")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory &Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}