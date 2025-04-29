#pragma warning disable AA0247
pageextension 20609 "CEO and President RC BF" extends "CEO and President Role Center"
{
    actions
    {
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}
