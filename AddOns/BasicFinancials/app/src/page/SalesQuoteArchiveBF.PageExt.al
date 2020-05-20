pageextension 20651 "Sales Quote Archive BF" extends "Sales Quote Archive"
{
    layout
    {
        modify("Bill-to Contact No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}