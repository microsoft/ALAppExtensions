pageextension 57622 "Salesperson/Purchaser Card BF" extends "Salesperson/Purchaser Card"
{
    layout
    {
        modify("Job Title")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Commission %")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Phone No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Next Task Date")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Privacy Blocked")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
    actions
    {
        modify("Con&tacts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}