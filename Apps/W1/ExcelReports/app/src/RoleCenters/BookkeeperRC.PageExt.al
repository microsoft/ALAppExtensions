pageextension 4424 "Bookkeeper RC" extends "Bookkeeper Role Center"
{
    actions
    {
        addafter("A&ccount Schedule")
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