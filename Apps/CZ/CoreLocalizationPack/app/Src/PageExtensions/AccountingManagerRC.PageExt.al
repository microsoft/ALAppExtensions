pageextension 11796 "Accounting Manager RC CZL" extends "Accounting Manager Role Center"
{
    actions
    {
        addafter("&Closing Trial Balance")
        {
            action("Balance Sheet CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Balance Sheet';
                Image = PrintReport;
                RunObject = Report "Balance Sheet CZL";
                ToolTip = 'Open the report for balance sheet.';
            }
            action("Income Statement CZL")
            {
                ApplicationArea = Basic, Suite;
                Caption = 'Income Statement';
                Image = PrintReport;
                RunObject = Report "Income Statement CZL";
                ToolTip = 'Open the report for income statement.';
            }
        }
    }
}
