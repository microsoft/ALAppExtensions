pageextension 20661 "Vendor Card BF" extends "Vendor Card"
{
    actions
    {
        modify(Quotes)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Orders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewBlanketPurchaseOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewPurchaseQuote)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewPurchaseOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewPurchaseOrderAddin)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(OrderAddresses)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}