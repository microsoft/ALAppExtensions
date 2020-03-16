pageextension 57644 "Sales List Archive BF" extends "Sales List Archive"
{
    layout
    {
        modify("Bill-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}