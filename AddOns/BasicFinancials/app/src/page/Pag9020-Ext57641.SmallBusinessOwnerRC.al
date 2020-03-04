pageextension 57641 "Small Business Owner RC BF" extends "Small Business Owner RC"
{
    actions
    {
        //modify("Sales Orders - Microsoft Dynamics 365 for Sales") //BC14
        modify("Sales Orders - Microsoft Dynamics 365 Sales")       //BC15
        {
            ApplicationArea = BFOrders;
        }
        modify("Customer - Order Su&mmary")
        {
            ApplicationArea = BFOrders;
        }
        modify("Inventory - Sales &Back Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales &Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = BFOrders;
        }
    }
}