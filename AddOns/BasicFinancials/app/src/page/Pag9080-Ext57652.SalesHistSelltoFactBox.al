pageextension 57652 "Sales Hist. Sell-to FactBox BF" extends "Sales Hist. Sell-to FactBox"
{
    layout
    {
        modify("No. of Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("No. of Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofOrdersTile)
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofBlanketOrdersTile)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}