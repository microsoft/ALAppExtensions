pageextension 20649 "Salesperson Statistics BF" extends "Salesperson Statistics"
{
    layout
    {
        modify("No. of Interactions")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Cost (LCY)")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(AvgCostPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify("Duration (Min.)")
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
        modify(AvgDurationPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasic;
        }
    }
}