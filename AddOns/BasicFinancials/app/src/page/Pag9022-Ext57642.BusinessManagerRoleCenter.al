pageextension 57642 "BusinessManagerRoleCenter BF" extends "Business Manager Role Center"
{

    actions
    {
        modify("Sales Order")
        {
            ApplicationArea = BFOrders;
        }
        modify("Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Blanket Sales Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("Purchase Quotes")
        {
            ApplicationArea = BFOrders;
        }
        modify("<Page Purchase Order>")
        {
            ApplicationArea = BFOrders;
        }
        modify("<Page Purchase Orders>")
        {
            ApplicationArea = BFOrders;
        }
        modify("Blanket Purchase Orders")
        {
            ApplicationArea = BFOrders;
        }
        modify("<Page Posted Purchase Receipts>")
        {
            ApplicationArea = BFOrders;
        }
        modify("Item Charges")
        {
            ApplicationArea = ItemCharges;
        }
        modify(Action131)
        {
            ApplicationArea = ItemCharges;
        }
    }
}