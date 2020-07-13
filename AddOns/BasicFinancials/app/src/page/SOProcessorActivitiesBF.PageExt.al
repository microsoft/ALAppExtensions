pageextension 20659 "SO Processor Activities BF" extends "SO Processor Activities"
{
    layout
    {
        modify("Sales Orders - Open")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders Released Not Shipped")
        {
            Visible = false;
        }
    }
    actions
    {
        modify("New Sales Order")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}