pageextension 57609 "Purch Invoice Subform BF" extends "Purch. Invoice Subform"
{
    actions
    {
        modify(GetReceiptLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}