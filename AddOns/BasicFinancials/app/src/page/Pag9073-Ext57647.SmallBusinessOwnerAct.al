pageextension 57647 "Small Business Owner Act BF" extends "Small Business Owner Act."
{
    actions
    {
        modify("New Purchase Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("New Sales Order")
        {
            ApplicationArea = BFOrders;
        }
    }
}