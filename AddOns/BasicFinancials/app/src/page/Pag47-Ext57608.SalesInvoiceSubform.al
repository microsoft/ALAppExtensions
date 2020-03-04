pageextension 57608 "Sales Invoice Subform BF" extends "Sales Invoice Subform"
{
    actions
    {
        modify(GetShipmentLines)
        {
            ApplicationArea = BFOrders;
        }
    }
}