pageextension 20638 "Reminder BF" extends "Reminder"
{
    actions
    {
        modify("Customer - Order Summary")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}