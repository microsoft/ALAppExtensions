pageextension 57652 "Sales Hist. Sell-to FactBox BF" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        modify("No. of Blanket Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("No. of Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify(NoofOrdersTile)
        {
            ApplicationArea = BFOrders;
        }
        modify(NoofBlanketOrdersTile)
        {
            ApplicationArea = BFOrders;
        }
    }
}