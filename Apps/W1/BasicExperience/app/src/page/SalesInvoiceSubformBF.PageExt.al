pageextension 20643 "Sales Invoice Subform BF" extends "Sales Invoice Subform"
{
    actions
    {
        modify(GetShipmentLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}