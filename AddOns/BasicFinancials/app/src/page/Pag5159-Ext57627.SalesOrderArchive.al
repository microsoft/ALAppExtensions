pageextension 57627 "Sales Order Archive BF" extends "Sales Order Archive"
{
    layout
    {
        modify("Sell-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}