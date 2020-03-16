pageextension 57656 "Shipping Agents BF" extends "Shipping Agents"
{
    actions
    {
        modify(ShippingAgentServices)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}