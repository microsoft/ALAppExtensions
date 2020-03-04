pageextension 57606 "Item List BF" extends "Item List"
{
    actions
    {
        modify(Action40)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory Order Details")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory - Sales Back Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}