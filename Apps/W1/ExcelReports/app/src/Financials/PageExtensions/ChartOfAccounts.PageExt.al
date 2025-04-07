pageextension 4427 "Chart of Accounts" extends "Chart of Accounts"
{
    actions
    {
        addafter("Detail Trial Balance")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View the chart of accounts that have balances and net changes.';
            }
        }
        addafter("Detail Trial Balance_Promoted")
        {
            actionref(TrialBalanceExcel_Promoted; "Trial Balance - Excel")
            {
            }
        }
    }
}