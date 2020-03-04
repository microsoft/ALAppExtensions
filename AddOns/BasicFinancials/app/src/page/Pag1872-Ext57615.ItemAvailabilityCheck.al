pageextension 57615 "Item Availability Check BF" extends "Item Availability Check"
{
    actions
    {
        modify("Purchase Order")
        {
            ApplicationArea = BFOrders;
        }
    }
}