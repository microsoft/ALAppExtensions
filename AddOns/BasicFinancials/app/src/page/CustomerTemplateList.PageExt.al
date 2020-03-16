pageextension 57619 "Customer Template List BF" extends "Customer Template List"
{
    layout
    {
        modify("Country/Region Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Territory Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}