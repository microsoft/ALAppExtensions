#if not CLEAN18
pageextension 20618 "Customer Template Card BF" extends "Customer Template Card"
{
    layout
    {
        modify("Territory Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Allow Line Disc.")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Invoice Disc. Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Payment Terms Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Payment Method Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Shipment Method Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
    actions
    {
        modify("Invoice &Discounts")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
#endif