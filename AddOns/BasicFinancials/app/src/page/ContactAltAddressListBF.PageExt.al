pageextension 20610 "Contact Alt. Address List BF" extends "Contact Alt. Address List"
{
    layout
    {
        modify("Company Name 2")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Address 2")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("City")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Post Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("County")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Country/Region Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Fax No.")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("E-Mail")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}