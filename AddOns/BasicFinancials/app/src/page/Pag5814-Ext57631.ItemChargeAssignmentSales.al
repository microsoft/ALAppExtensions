pageextension 57631 "Item Charge Ass. (Sales) BF" extends "Item Charge Assignment (Sales)"
{
    actions
    {
        modify(GetShipmentLines)
        {
            ApplicationArea = BFOrders;
        }
    }
}