pageextension 20625 "Item List BF" extends "Item List"
{
    actions
    {
        modify(Action40)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        //US: The action '"Inventory Order Details"' is not found in the target 'Item List'
        /*
        modify("Inventory Order Details")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        */
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