pageextension 11721 "User Setup CZL" extends "User Setup"
{
    layout
    {
        addafter("Allow Posting To")
        {
            field("Allow VAT Posting From CZL"; Rec."Allow VAT Posting From CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the earliest VAT date on which the user is allowed to post to the company.';
            }
            field("Allow VAT Posting To CZL"; Rec."Allow VAT Posting To CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the latest VAT date on which the user is allowed to post to the company.';
            }
        }
    }
}
