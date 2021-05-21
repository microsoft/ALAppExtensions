
pageextension 20667 "Whse. Basic Role Center BF" extends "Whse. Basic Role Center"
{
    actions
    {
        modify(SalesOrders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesOrdersReleased)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesOrdersPartShipped)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(SalesReturnOrders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(PurchaseOrders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(PurchaseOrdersReleased)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(PurchaseOrdersPartReceived)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(PurchaseReturnOrders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Sales Shipment")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Posted Return Receipts")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}

