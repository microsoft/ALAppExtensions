pageextension 20611 "Contact Card BF" extends "Contact Card"
{
    layout
    {
        modify("Salesperson Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("Business Relations")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(Statistics)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}