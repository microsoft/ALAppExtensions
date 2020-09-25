pageextension 20635 "Purchasing Manager RC BF" extends "Purchasing Manager Role Center"
{
    actions
    {
        modify("Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Purchase Return Order Archives")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Orders1") // Purchase Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Orders2") // Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify("Blanket Orders1") // Blanket Sales Orders
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}