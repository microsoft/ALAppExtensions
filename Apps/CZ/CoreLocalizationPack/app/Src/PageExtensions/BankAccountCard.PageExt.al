pageextension 11763 "Bank Account Card CZL" extends "Bank Account Card"
{
    layout
    {
        addlast(Posting)
        {
            field("Excl. from Exch. Rate Adj. CZL"; Rec."Excl. from Exch. Rate Adj. CZL")
            {
                ApplicationArea = Basic, Suite;
                ToolTip = 'Specifies whether entries will be excluded from exchange rates adjustment.';
            }
        }
    }
    actions
    {
        addafter("Check Details")
        {
            action("Reconcile Bank Account Entry CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Reconcile Bank Account Entry';
                Image = Report;
                RunObject = Report "Recon. Bank Account Entry CZL";
                ToolTip = 'Verify that the bank account balances from bank accout ledger entries match the balances on corresponding G/L accounts from the G/L entries.';
            }
            action("Joining Bank. Acc. Adjustment CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Joining Bank Account Adjustment';
                Image = Report;
                RunObject = Report "Joining Bank. Acc. Adj. CZL";
                ToolTip = 'Verify that selected bank account balance is cleared for selected document number.';
            }
        }
    }
}