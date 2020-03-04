pageextension 57632 "Acc Manager RoleCenter BF" extends "Accounting Manager Role Center"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
    }
}