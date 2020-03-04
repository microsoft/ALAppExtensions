pageextension 57616 "Contact Card BF" extends "Contact Card"
{
    layout
    {
        modify("Salesperson Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
    actions
    {
        modify("Business Relations")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Statistics)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}