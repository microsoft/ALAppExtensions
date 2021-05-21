
pageextension 20653 "Sales&Relationship Mgr Act BF" extends "Sales & Relationship Mgr. Act."
{
    layout
    {
        modify("Open Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Opportunities Due in 7 Days")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Overdue Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;

        }
        modify("Closed Opportunities")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Open Sales Quotes")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}