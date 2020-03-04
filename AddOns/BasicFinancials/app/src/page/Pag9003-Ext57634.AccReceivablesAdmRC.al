pageextension 57634 "Acc Receivables Adm RC BF" extends "Acc. Receivables Adm. RC"
{
    actions
    {
        modify("Sales &Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Return Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Return Receipts")
        {
            ApplicationArea = BFOrders;
        }
        modify("Posted Sales Shipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Combine Return S&hipments")
        {
            ApplicationArea = BFOrders;
        }
        modify("Combine Shi&pments")
        {
            ApplicationArea = BFOrders;
        }
    }
}