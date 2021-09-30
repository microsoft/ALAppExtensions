pageextension 31019 "Payment Reconc. Journal CZL" extends "Payment Reconciliation Journal"
{
    layout
    {
        addafter("Related-Party Name")
        {
#if not CLEAN19
            field("Posting Group CZL"; Rec."Posting Group")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies posting group for the payment reconciliation journal line';
                ObsoleteState = Pending;
                ObsoleteReason = 'Merge to W1.';
                ObsoleteTag = '19.0';
            }
#endif
        }
    }
}