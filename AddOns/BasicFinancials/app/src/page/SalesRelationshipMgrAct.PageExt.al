
pageextension 57653 "Sales&Relationship Mgr Act BF" extends "Sales & Relationship Mgr. Act."
{
    layout
    {
        modify("Open Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Opportunities Due in 7 Days")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Overdue Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;

        }
        modify("Closed Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Open Sales Quotes")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}