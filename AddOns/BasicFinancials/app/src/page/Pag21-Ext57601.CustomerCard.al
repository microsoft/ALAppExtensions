pageextension 57601 "Customer Card BF" extends "Customer Card"
{
    actions
    {
        modify("Blanket Orders")
        {
            ApplicationArea = BFOrders;
            Visible = true;

        }
        modify(NewBlanketSalesOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify(NewSalesOrder)
        {
            ApplicationArea = BFOrders;
        }
        modify(Orders)
        {
            ApplicationArea = BFOrders;
        }
        modify(NewSalesOrderAddin)
        {
            ApplicationArea = BFOrders;
        }
    }
}
