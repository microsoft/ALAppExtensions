pageextension 20657 "Small Business Owner Act BF" extends "Small Business Owner Act."
{
    actions
    {
        // Error in version 16.1, failed with code UnprocessableEntity. Reason: Object reference not set to an instance of an object.
        /*
        modify("New Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("New Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        */
    }
}