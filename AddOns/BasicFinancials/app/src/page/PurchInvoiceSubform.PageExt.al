pageextension 57636 "Purch Invoice Subform BF" extends "Purch. Invoice Subform"
{
    actions
    {
        modify(GetReceiptLines)
        {
            ApplicationArea = Advanced, BFOrders;
        }
    }
}