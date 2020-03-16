pageextension 57615 "Customer Card BF" extends "Customer Card"
{
    actions
    {
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
            Visible = true;

        }
        modify(NewBlanketSalesOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesOrder)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Orders)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NewSalesOrderAddin)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
