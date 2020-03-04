pageextension 57606 "Item List BF" extends "Item List"
{
    actions
    {
        modify(Action40)
        {
            ApplicationArea = BFOrders;
        }
        modify("Inventory Order Details")
        {
            ApplicationArea = BFOrders;
        }
        modify("Inventory Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Inventory - Sales Back Orders")
        {
            ApplicationArea = BFOrders;
        }
    }
}