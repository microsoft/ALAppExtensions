pageextension 57624 "Contact Through BF" extends "Contact Through"
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