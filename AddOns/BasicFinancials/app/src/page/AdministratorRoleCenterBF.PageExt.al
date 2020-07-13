pageextension 20605 "Administrator Role Center BF" extends "Administrator Role Center"
{
    actions
    {
        modify("Purchase &Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}