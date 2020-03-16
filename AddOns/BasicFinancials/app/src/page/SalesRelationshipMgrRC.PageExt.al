pageextension 57654 "Sales Relation ship Mgr RC BF" extends "Sales & Relationship Mgr. RC"
{
    actions
    {
        modify("Blanket Sales Orders")
        {
            ApplicationArea = Advanced, BFOrders;
        }
        modify(Contacts)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Sales Quotes")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Customers)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Items)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Action65) // Sales Quotes
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Action63) // Customers
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Action62) // Items
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Cust. Invoice Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Vend. Invoice Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Item Disc. Groups")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Action38) // Contacts
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(Action21) // Customers
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(NewContact)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Sales Price &Worksheet")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Sales &Prices")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Sales Line &Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}