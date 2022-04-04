pageextension 31210 "Chart of Accounts (G/L) CZL" extends "Chart of Accounts (G/L)"
{
    layout
    {
        addafter("Net Change")
        {
            field("Debit Amount CZL"; Rec."Debit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of the debit entries that have been posted to the account.';
                Visible = false;
            }
            field("Credit Amount CZL"; Rec."Credit Amount")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies the total of the credit entries that have been posted to the account.';
                Visible = false;
            }
        }
    }
}
