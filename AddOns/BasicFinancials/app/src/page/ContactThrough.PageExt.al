pageextension 20614 "Contact Through BF" extends "Contact Through"
{
    layout
    {
        modify(Number)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}