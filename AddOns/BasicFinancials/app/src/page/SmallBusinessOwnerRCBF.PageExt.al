pageextension 20658 "Small Business Owner RC BF" extends "Small Business Owner RC"
{
    actions
    {
        modify("Sales Orders - Microsoft Dynamics 365 Sales") //ES: The action '"Sales Orders - Microsoft Dynamics 365 Sales"' is not found in the target 'Small Business Owner RC'
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Customer - Order Su&mmary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory - Sales &Back Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
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