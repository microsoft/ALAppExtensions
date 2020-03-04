pageextension 57630 "Item Charge Ass. (Purch) BF" extends "Item Charge Assignment (Purch)"
{
    actions
    {
        modify(GetSalesShipmentLines)
        {
            ApplicationArea = BFOrders;
        }
    }
}