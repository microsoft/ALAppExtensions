pageextension 20631 "Purchase Agent Activities BF" extends "Purchase Agent Activities"
{
    actions
    {
        // Error in version 16.1, failed with code UnprocessableEntity. Reason: Object reference not set to an instance of an object.
        /*
        modify("New Purchase Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("New Purchase Quote")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        
        modify("New Purchase Return Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        */
    }
}