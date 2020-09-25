pageextension 20655 "Service Dispatcher RC BF" extends "Service Dispatcher Role Center"
{
    actions
    {
        modify("Sales Or&der")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}