pageextension 57620 "Business Relations BF" extends "Business Relations"
{
    layout
    {
        modify("No. of Contacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
    actions
    {
        modify("C&ontacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }

}