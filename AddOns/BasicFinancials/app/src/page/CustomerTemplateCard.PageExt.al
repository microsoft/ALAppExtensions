pageextension 57626 "Customer Template Card BF" extends "Customer Template Card"
{
    layout
    {
        modify("Territory Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Allow Line Disc.")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Invoice Disc. Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Payment Terms Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Payment Method Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Shipment Method Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
    actions
    {
        modify("Invoice &Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}