pageextension 31285 "Approval User Setup CZP" extends "Approval User Setup"
{
    layout
    {
        addafter("Unlimited Request Approval")
        {
            field("Cash Desk Amt. Appr. Limit"; Rec."Cash Desk Amt. Appr. Limit CZP")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies approval limit for approving cash desk document';
            }
            field("Unlimited Cash Desk Appr. CZP"; Rec."Unlimited Cash Desk Appr. CZP")
            {
                ApplicationArea = Suite;
                ToolTip = 'Specifies that the user on this line is allowed to approve cash desk documents with no maximum amount.';
            }
        }
    }
}
