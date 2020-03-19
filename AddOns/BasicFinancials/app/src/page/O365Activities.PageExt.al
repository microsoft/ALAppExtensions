pageextension 20629 "O365 Activities BF" extends "O365 Activities"
{
    layout
    {
        modify("Ongoing Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}