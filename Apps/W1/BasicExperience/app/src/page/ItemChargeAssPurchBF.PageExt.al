pageextension 20623 "Item Charge Ass. (Purch) BF" extends "Item Charge Assignment (Purch)"
{
    actions
    {
        modify(GetSalesShipmentLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}