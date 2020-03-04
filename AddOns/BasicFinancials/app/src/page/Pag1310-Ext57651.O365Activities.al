pageextension 57651 "O365 Activities BF" extends "O365 Activities"
{
    layout
    {
        modify("Ongoing Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
    }
}