pageextension 57623 "Salesperson Statistics BF" extends "Salesperson Statistics"
{
    layout
    {
        modify("No. of Interactions")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Cost (LCY)")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(AvgCostPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify("Duration (Min.)")
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
        modify(AvgDurationPerResp)
        {
            ApplicationArea = RelationshipMgmt, BFBasicFinancials;
        }
    }
}