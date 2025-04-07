pageextension 4430 "G/L Account Card" extends "G/L Account Card"
{
    actions
    {
        addafter("Detail Trial Balance")
        {
            action("Trial Balance - Excel")
            {
                ApplicationArea = Suite;
                Caption = 'Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View general ledger account balances and activities for all the selected accounts, one transaction per line.';
            }
        }
    }
}