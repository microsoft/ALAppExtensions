pageextension 20642 "Sales Hist. Sell-to FactBox BF" extends "Sales Hist. Sell-to FactBox"
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

        modify("No. of Pstd. Shipments")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofBlanketOrdersTile) // No. of Blanket Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(NoofOrdersTile) // No. of Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }

        modify(NoofPstdShipmentsTile) // No. of Pstd. Shipments
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}