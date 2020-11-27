pageextension 11762 "Bank Account List CZL" extends "Bank Account List"
{
    actions
    {
        addafter("Bank Account Statements")
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