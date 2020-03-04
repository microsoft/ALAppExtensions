pageextension 57633 "Acc Payables Coordinator RC BF" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Return Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Return Shipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Purchase Receipts")
        {
            ApplicationArea = BFOrders;
        }
    }
}