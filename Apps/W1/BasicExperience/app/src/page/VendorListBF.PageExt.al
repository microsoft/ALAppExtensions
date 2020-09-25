pageextension 20663 "Vendor List BF" extends "Vendor List"
{
    actions
    {
        modify(Quotes)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Vendor - Order Detail")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Vendor - Order Summary")
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
        modify(OrderAddresses)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}