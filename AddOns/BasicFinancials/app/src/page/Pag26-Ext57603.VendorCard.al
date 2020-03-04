pageextension 57603 "Vendor Card BF" extends "Vendor Card"
{
    actions
    {
        modify(Quotes)
        {
            ApplicationArea = BFOrders;
        }
        modify(Orders)
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
        modify(NewPurchaseOrderAddin)
        {
            ApplicationArea = BFOrders;
        }
        modify(OrderAddresses)
        {
            ApplicationArea = BFOrders;
        }
    }
}