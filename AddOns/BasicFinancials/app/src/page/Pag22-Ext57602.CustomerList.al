pageextension 57602 "Customer List BF" extends "Customer List"
{
    actions
    {
        modify("Blanket Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify(NewSalesBlanketOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify(NewSalesOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify("Customer - Order Detail")
        {
            ApplicationArea = BFOrders;
        }
        modify("Customer - Order Summary")
        {
            ApplicationArea = BFOrders;
        }
    }
}