pageextension 57648 "Salespersons/Purchasers BF" extends "Salespersons/Purchasers"
{
    layout
    {
        modify(Name)
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasicFinancials;
        }
        modify("Commission %")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasicFinancials;
        }
        modify("Phone No.")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasicFinancials;
        }
        modify("Privacy Blocked")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasicFinancials;
        }
    }
    actions
    {
        modify("Con&tacts")
        {
            ApplicationArea = Suite, RelationshipMgmt, BFBasicFinancials;
        }
    }
}