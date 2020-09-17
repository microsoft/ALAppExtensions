pageextension 20603 "Acc Payables Coordinator RC BF" extends "Acc. Payables Coordinator RC"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("&Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Return Orders")
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
    }
}