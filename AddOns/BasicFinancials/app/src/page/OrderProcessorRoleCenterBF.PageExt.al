pageextension 20630 "Order Processor Role Center BF" extends "Order Processor Role Center"
{
    layout
    {
        modify(Control1) // Trailing Sales Orders Chart
        {
            Visible = false;
        }
    }
    actions
    {
        modify("Customer - &Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Return Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Return Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesOrders) // Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesOrdersShptNotInv) // Shipped Not Invoiced
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesOrdersComplShtNotInv) // Completely Shipped Not Invoice
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders") // Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders - Microsoft Dynamics 365 Sales") // Sales Orders - Microsoft Dynamics 365 Sales
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Sales Orders") // Blanket Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipments") // Posted Sales Shipments
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Orders") // Purchase Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Purchase Orders") // Blanket Purchase Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts") // Posted Purchase Receipts
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Action40) // Posted Sales Shipments
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Action87) // Posted Purchase Return Shipments
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Action53) // Posted Purchase Receipts
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales &Order") // Sales Order
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales &Return Order") // Sales Return Order
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Inventory - Sales &Back Orders") // Inventory - Sales Back Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}

