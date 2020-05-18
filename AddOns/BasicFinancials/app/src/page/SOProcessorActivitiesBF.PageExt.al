pageextension 20659 "SO Processor Activities BF" extends "SO Processor Activities"
{
    layout
    {
        // Error in version 16.1, failed with code UnprocessableEntity. Reason: Object reference not set to an instance of an object.
        /*
        modify("Sales Orders - Open")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders Released Not Shipped")
        {
            Visible = false;
        }
        */
    }
    actions
    {
        // Error in version 16.1, failed with code UnprocessableEntity. Reason: Object reference not set to an instance of an object.
        /*
        modify("New Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        */
    }
}