pageextension 20602 "Acc Manager RoleCenter BF" extends "Accounting Manager Role Center"
{
    actions
    {
        modify("Purchase Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}