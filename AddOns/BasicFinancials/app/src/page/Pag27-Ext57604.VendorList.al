pageextension 57604 "Vendor List BF" extends "Vendor List"
{
    actions
    {
        modify(Quotes)
        {
            ApplicationArea = BFOrders;
        }
        modify("Vendor - Order Detail")
        {
            ApplicationArea = BFOrders;
        }
        modify("Vendor - Order Summary")
        {
            ApplicationArea = BFOrders;
        }
        modify("Blanket Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify(NewBlanketPurchaseOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify(NewPurchaseQuote)
        {
            ApplicationArea = BFOrders;
        }
        modify(NewPurchaseOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify(OrderAddresses)
        {
            ApplicationArea = BFOrders;
        }
    }
}