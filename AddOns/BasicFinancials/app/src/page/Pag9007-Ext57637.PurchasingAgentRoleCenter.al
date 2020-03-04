pageextension 57637 "Purch Agent Role Center BF" extends "Purchasing Agent Role Center"
{
    actions
    {
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase &Order")
        {
            ApplicationArea = BFOrders;
        }
        modify(PurchaseOrders)
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase &Quote")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Inventory &Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = BFOrders;
        }
    }
}