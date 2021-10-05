#if not CLEAN18
pageextension 20619 "Customer Template List BF" extends "Customer Template List"
{
    layout
    {
        modify("Country/Region Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Territory Code")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}
#endif