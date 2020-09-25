pageextension 20614 "Contact Through BF" extends "Contact Through"
{
    layout
    {
        modify(Number)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}