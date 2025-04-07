pageextension 4423 "Accounting Manager RC" extends "Accounting Manager Role Center"
{
    actions
    {
        addfirst(reporting)
        {
            action("G/L Trial Balance (Excel)")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'G/L Trial Balance (Excel)';
                Image = "Report";
                RunObject = Report "EXR Trial Balance Excel";
                ToolTip = 'View, print, or send a report that shows the balances for the general ledger accounts, including the debits and credits. You can use this report to ensure accurate accounting practices.';
            }
        }
    }
}