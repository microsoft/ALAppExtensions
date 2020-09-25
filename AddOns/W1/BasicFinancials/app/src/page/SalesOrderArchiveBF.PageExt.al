pageextension 20646 "Sales Order Archive BF" extends "Sales Order Archive"
{
    layout
    {
        modify("Sell-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}