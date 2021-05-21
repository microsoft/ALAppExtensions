pageextension 20657 "Small Business Owner Act BF" extends "Small Business Owner Act."
{
    actions
    {
        modify("New Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("New Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}